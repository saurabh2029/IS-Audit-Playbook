# Microsoft SQL Server Audit Guide

> **Asset Type:** Microsoft SQL Server (2016 / 2019 / 2022)  
> **Audit Domain:** Database Security, ITGC — Access & Configuration Control  
> **Regulatory Mapping:** RBI Cyber Framework § Data Security | ISO 27001 A.8.3, A.8.4 | NIST SC, AU families | PCI DSS Req. 7, 8, 10  
> **Risk Level:** 🔴 Critical — SQL Server hosts critical business and customer data; misconfigurations are commonly exploited

---

## Objective

To assess Microsoft SQL Server security controls covering:
- Authentication mode and login management
- Role and permission governance (sysadmin, db_owner)
- SQL Server Agent and linked server security
- Audit and logging configuration
- Surface area configuration hardening
- Encryption (TDE, Always Encrypted, TLS)
- Patch and version compliance

---

## Pre-Audit Requirements

### Access Needed
- [ ] SQL Server login with `VIEW SERVER STATE` and `VIEW ANY DEFINITION`
- [ ] `sysadmin` or dedicated audit login (preferred for complete coverage)
- [ ] Access to SQL Server Management Studio (SSMS) or sqlcmd
- [ ] Windows Event Log access on SQL Server host
- [ ] SQL Server Configuration Manager access

### Create Minimum-Privilege Audit Account
```sql
-- Create a dedicated read-only audit login
USE master;
GO
CREATE LOGIN sql_auditor WITH PASSWORD = '<StrongPassword123!>';
GO

-- Grant minimum required server-level permissions
GRANT VIEW SERVER STATE       TO sql_auditor;
GRANT VIEW ANY DEFINITION     TO sql_auditor;
GRANT VIEW ANY DATABASE       TO sql_auditor;

-- For each database to audit, run:
USE [TargetDatabase];
GO
CREATE USER sql_auditor FOR LOGIN sql_auditor;
EXEC sp_addrolemember 'db_datareader', 'sql_auditor';
GO
```

---

## Audit Checklist

### Section 1 — Version & Patch Status

| # | Control | T-SQL / Method | Expected | Risk |
|---|---------|---------------|----------|------|
| 1.1 | SQL Server is a supported version | `SELECT @@VERSION` | Not on EOL (2014 or older) | High |
| 1.2 | Latest Cumulative Update (CU) applied | Check version build number | Within 2 CUs of current | High |
| 1.3 | OS patches current on DB server | OS patch check | Within 30-day cycle | High |
| 1.4 | SQL Server service packs applied | Check build against Microsoft table | Latest SP applied | High |

```sql
-- Check SQL Server version, edition, and build
SELECT  @@SERVERNAME                          AS ServerName,
        @@VERSION                             AS FullVersion,
        SERVERPROPERTY('ProductVersion')      AS ProductVersion,
        SERVERPROPERTY('ProductLevel')        AS ServicePack,
        SERVERPROPERTY('ProductUpdateLevel')  AS CumulativeUpdate,
        SERVERPROPERTY('Edition')             AS Edition,
        SERVERPROPERTY('EngineEdition')       AS EngineEdition;

-- Map build to known CU: https://buildnumbers.wordpress.com/sqlserver/
-- SQL Server 2022 RTM = 16.0.1000.6 | Latest CU = check Microsoft docs
```

---

### Section 2 — Authentication & Login Management

| # | Control | T-SQL / Method | Expected | Risk |
|---|---------|---------------|----------|------|
| 2.1 | Windows Authentication Mode only (not Mixed Mode) | Check auth mode | Windows Auth only | High |
| 2.2 | If Mixed Mode: SA account is disabled or renamed | Check SA account | SA disabled and renamed | 🔴 Critical |
| 2.3 | SA account does not use default/blank password | Attempt login | Login denied | 🔴 Critical |
| 2.4 | SQL logins have CHECK_POLICY = ON | Query sys.sql_logins | All ON | High |
| 2.5 | SQL logins have CHECK_EXPIRATION = ON | Query sys.sql_logins | All ON | High |
| 2.6 | Dormant logins (90+ days) are disabled | Check last login | Zero active dormant logins | High |
| 2.7 | Guest account access is revoked from all databases | Check db_guest | No CONNECT rights | High |
| 2.8 | Login failure auditing is enabled | Check audit level | Both success and failure | High |

```sql
-- Check authentication mode (1 = Windows Only, 2 = Mixed Mode)
SELECT CASE SERVERPROPERTY('IsIntegratedSecurityOnly')
           WHEN 1 THEN 'Windows Authentication Only (Recommended)'
           WHEN 0 THEN '*** MIXED MODE ENABLED — SQL logins allowed ***'
       END AS AuthenticationMode;

-- Check SA account status
SELECT  name, is_disabled, 
        LOGINPROPERTY(name,'IsLocked')     AS IsLocked,
        LOGINPROPERTY(name,'IsMustChange') AS MustChangePassword,
        type_desc
FROM    sys.server_principals
WHERE   sid = 0x01;  -- SID 0x01 is always the SA account

-- All SQL logins with policy enforcement status
SELECT  name,
        is_disabled,
        is_policy_checked      AS CheckPolicy,
        is_expiration_checked  AS CheckExpiration,
        LOGINPROPERTY(name,'BadPasswordCount')      AS FailedAttempts,
        LOGINPROPERTY(name,'IsLocked')              AS IsLocked,
        LOGINPROPERTY(name,'PasswordLastSetTime')   AS PasswordLastSet,
        LOGINPROPERTY(name,'DaysUntilExpiration')   AS DaysToExpiry,
        create_date,
        modify_date
FROM    sys.sql_logins
ORDER   BY is_disabled, name;

-- Find logins that haven't connected recently (last login info)
-- Note: Requires sys.dm_exec_sessions for active, or Extended Events for historical
SELECT  sp.name         AS LoginName,
        sp.type_desc    AS LoginType,
        sp.is_disabled,
        sp.create_date,
        sp.modify_date,
        -- Last login requires XE session or SQL Audit; modify_date is proxy
        DATEDIFF(DAY, sp.modify_date, GETDATE()) AS DaysSinceModified
FROM    sys.server_principals sp
WHERE   sp.type IN ('S','U')  -- SQL logins and Windows logins
  AND   sp.name NOT IN ('sa','##MS_PolicyEventProcessingLogin##',
                        '##MS_SQLAuthenticatorCertificateUser##',
                        '##MS_SQLResourceSigningCertificate##',
                        '##MS_AgentSigningCertificate##')
ORDER   BY sp.is_disabled, sp.name;

-- Check if Guest user has CONNECT in any database
EXEC sp_MSforeachdb '
USE [?];
IF EXISTS (
    SELECT 1 FROM sys.database_permissions
    WHERE grantee_principal_id = DATABASE_PRINCIPAL_ID(''guest'')
      AND permission_name = ''CONNECT''
      AND state = ''G''
)
SELECT ''?'' AS DatabaseName, ''Guest CONNECT granted'' AS Issue;
';
```

---

### Section 3 — Privilege & Role Management

| # | Control | T-SQL / Method | Expected | Risk |
|---|---------|---------------|----------|------|
| 3.1 | sysadmin role membership is minimal | Query below | ≤ 5 accounts | 🔴 Critical |
| 3.2 | No service accounts or app logins in sysadmin | Check sysadmin members | No app/service accounts | 🔴 Critical |
| 3.3 | CONTROL SERVER permission not granted | Check server permissions | Not granted | 🔴 Critical |
| 3.4 | db_owner membership per database is reviewed | Query all DBs | Only DBAs + justified accounts | High |
| 3.5 | EXECUTE AS privilege reviewed | Query | Only justified accounts | High |
| 3.6 | Cross-database chaining disabled | Check `cross db ownership chaining` | 0 (disabled) | High |
| 3.7 | Application service accounts use least privilege | Review app account grants | Only required object permissions | High |

```sql
-- List all sysadmin role members (server level)
SELECT  sp.name          AS LoginName,
        sp.type_desc     AS LoginType,
        sp.is_disabled,
        srm.role_principal_id
FROM    sys.server_role_members srm
JOIN    sys.server_principals sp  ON srm.member_principal_id = sp.principal_id
JOIN    sys.server_principals sr  ON srm.role_principal_id   = sr.principal_id
WHERE   sr.name = 'sysadmin'
ORDER   BY sp.type_desc, sp.name;

-- All server-level role memberships
SELECT  sr.name  AS ServerRole,
        sp.name  AS LoginName,
        sp.type_desc
FROM    sys.server_role_members srm
JOIN    sys.server_principals sp  ON srm.member_principal_id = sp.principal_id
JOIN    sys.server_principals sr  ON srm.role_principal_id   = sr.principal_id
ORDER   BY sr.name, sp.name;

-- CONTROL SERVER grants (equivalent to sysadmin)
SELECT  pr.name     AS GranteeName,
        pr.type_desc,
        pe.permission_name,
        pe.state_desc
FROM    sys.server_permissions pe
JOIN    sys.server_principals  pr ON pe.grantee_principal_id = pr.principal_id
WHERE   pe.permission_name = 'CONTROL SERVER'
  AND   pe.state_desc      = 'GRANT';

-- db_owner members across all databases
EXEC sp_MSforeachdb '
USE [?];
SELECT  DB_NAME()   AS DatabaseName,
        dp.name     AS UserName,
        dp.type_desc AS UserType,
        sp.name     AS MappedLogin
FROM    sys.database_role_members drm
JOIN    sys.database_principals   dp ON drm.member_principal_id = dp.principal_id
JOIN    sys.database_principals   dr ON drm.role_principal_id   = dr.principal_id
LEFT JOIN sys.server_principals   sp ON dp.sid = sp.sid
WHERE   dr.name = ''db_owner''
  AND   dp.name NOT IN (''dbo'',''##MS_PolicyEventProcessingLogin##'')
ORDER   BY dp.name;
';

-- Check cross-database ownership chaining
SELECT  name, value, value_in_use, description
FROM    sys.configurations
WHERE   name = 'cross db ownership chaining';
```

---

### Section 4 — SQL Server Feature Surface Area

| # | Control | T-SQL / Method | Expected | Risk |
|---|---------|---------------|----------|------|
| 4.1 | xp_cmdshell is disabled | Check sp_configure | 0 (disabled) | 🔴 Critical |
| 4.2 | Ole Automation Procedures disabled | Check sp_configure | 0 (disabled) | High |
| 4.3 | SQL Server Agent XPs disabled if Agent not used | Check sp_configure | 0 if not needed | Medium |
| 4.4 | Remote Access disabled | Check sp_configure | 0 (disabled) | Medium |
| 4.5 | Ad Hoc Distributed Queries disabled | Check sp_configure | 0 (disabled) | High |
| 4.6 | Scan for Startup Procs disabled | Check sp_configure | 0 (disabled) | Medium |
| 4.7 | Linked servers are reviewed and minimized | `SELECT * FROM sys.servers` | Only necessary, no public access | High |
| 4.8 | CLR Integration disabled if not required | Check sp_configure | 0 (disabled) | Medium |

```sql
-- Full surface area configuration check
SELECT  name,
        CAST(value           AS INT) AS ConfiguredValue,
        CAST(value_in_use    AS INT) AS RunningValue,
        description
FROM    sys.configurations
WHERE   name IN (
    'xp_cmdshell',
    'Ole Automation Procedures',
    'Agent XPs',
    'remote access',
    'Ad Hoc Distributed Queries',
    'scan for startup procs',
    'clr enabled',
    'clr strict security',
    'cross db ownership chaining',
    'Database Mail XPs',
    'SQL Mail XPs',
    'Web Assistant Procedures',
    'remote admin connections'
)
ORDER   BY name;

-- Review all linked servers and their security configuration
SELECT  srv.name                AS LinkedServerName,
        srv.data_source         AS DataSource,
        srv.product             AS Product,
        srv.provider            AS Provider,
        lnk.uses_self_credential,
        lnk.remote_name         AS RemoteLogin,
        srv.is_remote_login_enabled,
        srv.is_rpc_out_enabled,
        srv.create_date
FROM    sys.servers  srv
LEFT JOIN sys.linked_logins lnk ON srv.server_id = lnk.server_id
WHERE   srv.is_linked = 1
ORDER   BY srv.name;

-- Check SQL Server Agent service account and proxy accounts
SELECT  sp.name        AS ProxyName,
        sp.description,
        sp.is_enabled,
        c.name         AS CredentialName,
        c.credential_identity
FROM    msdb.dbo.sysproxies sp
JOIN    sys.credentials c ON sp.credential_id = c.credential_id
ORDER   BY sp.name;
```

---

### Section 5 — SQL Server Audit & Logging

| # | Control | T-SQL / Method | Expected | Risk |
|---|---------|---------------|----------|------|
| 5.1 | SQL Server Audit is enabled | Check sys.server_audits | Active audit specification | 🔴 Critical |
| 5.2 | Audit covers login events (success + failure) | Review audit spec | LOGIN_GROUP included | High |
| 5.3 | Audit covers DDL events | Review audit spec | DDL_DATABASE_LEVEL included | High |
| 5.4 | Audit covers privilege use | Review audit spec | SERVER_PRINCIPAL_CHANGE_GROUP | High |
| 5.5 | Audit log written to secure location | Check audit destination | Not overwritten; secure share or SIEM | High |
| 5.6 | SQL Server Error Log is reviewed regularly | Process review | Reviewed or forwarded to SIEM | Medium |
| 5.7 | Windows Event Logs forwarded to SIEM | SIEM check | All SQL Server events in SIEM | High |
| 5.8 | Audit log retention ≥ 180 days | Check retention | ≥ 180 days (CERT-In) | High |

```sql
-- Check all SQL Server Audits (server level)
SELECT  audit_id,
        name                AS AuditName,
        status_desc,
        audit_action_id,
        type_desc           AS AuditType,
        on_failure_desc,
        file_path,
        max_file_size,
        max_files,
        reserve_disk_space
FROM    sys.server_audits
ORDER   BY name;

-- Check Server Audit Specifications
SELECT  sa.name                AS AuditName,
        sas.name               AS SpecName,
        sas.is_state_enabled,
        sasd.audit_action_name AS AuditAction,
        sasd.audited_result
FROM    sys.server_audit_specifications sas
JOIN    sys.server_audits              sa  ON sas.audit_guid = sa.audit_guid
JOIN    sys.server_audit_specification_details sasd ON sas.server_specification_id = sasd.server_specification_id
ORDER   BY sa.name, sasd.audit_action_name;

-- Check Database Audit Specifications (per database)
EXEC sp_MSforeachdb '
USE [?];
SELECT  DB_NAME()   AS DatabaseName,
        das.name    AS SpecName,
        das.is_state_enabled,
        dasd.audit_action_name,
        dasd.object_name
FROM    sys.database_audit_specifications das
JOIN    sys.database_audit_specification_details dasd
        ON das.database_specification_id = dasd.database_specification_id
ORDER   BY dasd.audit_action_name;
';

-- Read recent SQL Server audit events (if audit to file)
-- Use fn_get_audit_file to read audit files
SELECT  event_time,
        action_id,
        succeeded,
        server_principal_name,
        database_name,
        object_name,
        statement
FROM    sys.fn_get_audit_file('C:\SQLAudit\*.sqlaudit', DEFAULT, DEFAULT)
ORDER   BY event_time DESC;

-- Check SQL Server login auditing level (2 = Failed only, 3 = All)
EXEC xp_loginconfig 'audit level';
```

---

### Section 6 — Encryption

| # | Control | T-SQL / Method | Expected | Risk |
|---|---------|---------------|----------|------|
| 6.1 | TDE enabled for databases with sensitive data | Check is_encrypted | All sensitive DBs encrypted | 🔴 Critical |
| 6.2 | TDE certificate backed up to secure location | Process review | Certificate backup exists off-server | 🔴 Critical |
| 6.3 | SQL Server using TLS 1.2 or higher | Registry check | TLS 1.2 minimum | High |
| 6.4 | SSL/TLS certificate is valid (not self-signed for prod) | Check certificate | CA-signed cert | Medium |
| 6.5 | Backup encryption configured | Check backup commands | ENCRYPTION option used | High |

```sql
-- Check TDE status for all databases
SELECT  d.name          AS DatabaseName,
        d.state_desc    AS DBState,
        d.is_encrypted  AS TDE_Enabled,
        dek.encryption_state_desc,
        dek.percent_complete,
        dek.encryptor_type,
        dek.key_algorithm,
        dek.key_length
FROM    sys.databases d
LEFT JOIN sys.dm_database_encryption_keys dek ON d.database_id = dek.database_id
ORDER   BY d.name;

-- Check service master key and database master key
SELECT  name, principal_id, symmetric_key_id,
        key_algorithm, key_length,
        create_date, modify_date
FROM    sys.symmetric_keys
WHERE   name IN ('##MS_DatabaseMasterKey##','##MS_ServiceMasterKey##');

-- Check if TDE certificate is backed up (check backup history)
SELECT  bs.database_name,
        bs.type,
        bmf.physical_device_name,
        bs.backup_start_date
FROM    msdb.dbo.backupset   bs
JOIN    msdb.dbo.backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
WHERE   bs.database_name = 'master'
ORDER   BY bs.backup_start_date DESC;
```

---

### Section 7 — SQL Server Agent Security

| # | Control | T-SQL / Method | Expected | Risk |
|---|---------|---------------|----------|------|
| 7.1 | SQL Agent service account is least-privilege | Check service account | Not LocalSystem or sysadmin | High |
| 7.2 | SQL Agent jobs reviewed for security | Review job steps | No xp_cmdshell in job steps | High |
| 7.3 | SQL Agent job owners are not SA | Check job ownership | No jobs owned by SA | Medium |
| 7.4 | Operators and alerts are configured for failures | Check operators | At least one DBA operator defined | Medium |

```sql
-- SQL Agent jobs and their owners
SELECT  j.name          AS JobName,
        j.enabled,
        j.description,
        sp.name         AS OwnerLogin,
        j.date_created,
        j.date_modified,
        j.last_run_date,
        j.last_run_outcome
FROM    msdb.dbo.sysjobs j
LEFT JOIN sys.server_principals sp ON j.owner_sid = sp.sid
ORDER   BY j.enabled DESC, j.name;

-- SQL Agent job steps — check for xp_cmdshell usage or OS commands
SELECT  j.name      AS JobName,
        js.step_id,
        js.step_name,
        js.subsystem,
        -- Redact full command for security; flag xp_cmdshell usage
        CASE WHEN js.command LIKE '%xp_cmdshell%' 
             THEN '*** ALERT: xp_cmdshell in step ***'
             WHEN js.subsystem = 'CmdExec'
             THEN '*** ALERT: OS Command Execution step ***'
             ELSE 'No immediate concern'
        END AS SecurityFlag
FROM    msdb.dbo.sysjobs      j
JOIN    msdb.dbo.sysjobsteps  js ON j.job_id = js.job_id
ORDER   BY j.name, js.step_id;
```

---

## Evidence to Collect

| Evidence Item | Collection Method | Format |
|--------------|------------------|--------|
| SQL Server version and CU | Query output | Screenshot |
| Authentication mode | Query output | Screenshot |
| SA account status | Query output | Screenshot |
| All SQL logins with policy status | Query export | CSV |
| sysadmin role members | Query export | CSV |
| All server role memberships | Query export | CSV |
| Surface area config parameters | Query export | CSV |
| Linked servers list | Query export | CSV |
| TDE status per database | Query output | Screenshot |
| SQL Server Audit specifications | Query export | CSV |
| SQL Agent jobs summary | Query export | CSV |
| sp_configure output | `EXEC sp_configure` export | TXT |

---

## Common Findings

### Finding SQL-001 — xp_cmdshell Enabled
> **Condition:** SQL Server configuration parameter `xp_cmdshell` was found enabled (`value_in_use = 1`) on the production SQL Server instance hosting the core banking application database.  
> **Criteria:** CIS SQL Server Benchmark (v1.4) Control 2.1 requires `xp_cmdshell` to be disabled unless explicitly required. Microsoft SQL Server hardening guides recommend disabling all unnecessary surface area features.  
> **Effect:** `xp_cmdshell` permits execution of OS-level commands directly from SQL Server. Any account with `EXECUTE` permission on this procedure, or any account that escalates to `sysadmin`, can execute arbitrary OS commands, move laterally to the host OS, and potentially compromise the entire server.  
> **Recommendation:** Execute `EXEC sp_configure 'xp_cmdshell', 0; RECONFIGURE;` immediately. If any application or process requires OS command execution, implement a SQL Agent CmdExec job step with a dedicated, least-privilege service account as an alternative.  
> **Risk:** 🔴 Critical

### Finding SQL-002 — Mixed Mode Authentication with Weak SA Password
> **Condition:** SQL Server is configured in Mixed Mode authentication. The SA account is enabled and the password was found to meet only the minimum complexity requirement (8 characters). CHECK_EXPIRATION is disabled for the SA account.  
> **Criteria:** CIS SQL Server Benchmark Control 3.1 requires Windows Authentication only. RBI Cyber Framework Section 6.3 mandates strong authentication for all privileged access. SQL Server best practice requires SA to be disabled or have a complex password with expiration enabled.  
> **Effect:** Mixed mode with a predictable SA password is a common initial access vector. SA login is targeted by automated credential stuffing tools. Successful SA compromise grants `sysadmin` access over all databases on the instance.  
> **Recommendation:** (1) Disable the SA account. (2) Rename if disable is not immediate. (3) Switch to Windows Authentication mode where application compatibility permits. (4) Where Mixed Mode is retained, enforce CHECK_POLICY and CHECK_EXPIRATION on all SQL logins.  
> **Risk:** 🔴 Critical

### Finding SQL-003 — No SQL Server Audit Configured
> **Condition:** No SQL Server Audit objects or Audit Specifications were found configured on the production SQL Server instance. Login events, DDL changes, and privileged user actions are not being captured.  
> **Criteria:** CERT-In Directions (April 2022) Section 6(1) require maintenance of logs for 180 days. RBI Cybersecurity Framework Control 11.3 requires comprehensive audit logging for database access and administrative actions.  
> **Effect:** Without audit logging, unauthorized access, data exfiltration, or insider fraud cannot be detected, investigated, or evidenced. This also constitutes direct non-compliance with CERT-In log retention mandates.  
> **Recommendation:** Create and enable SQL Server Audit covering at minimum: FAILED_LOGIN_GROUP, SUCCESSFUL_LOGIN_GROUP, LOGOUT_GROUP, DATABASE_OBJECT_CHANGE_GROUP, SERVER_PRINCIPAL_CHANGE_GROUP, AUDIT_CHANGE_GROUP. Forward audit files to central SIEM. Retain for 180 days.  
> **Risk:** 🔴 Critical

---

## Regulatory Mapping

| Control Area | RBI Cyber Framework | ISO 27001:2022 | NIST CSF | CERT-In 2022 | DPDP Act 2023 |
|---|---|---|---|---|---|
| Authentication | §6.3 Authentication | A.9.4.2 | PR.AC-7 | — | §4 Technical safeguards |
| Privileged Access | §7.1 PAM | A.9.2.3 | PR.AC-4 | — | — |
| Surface Area Reduction | §5.2 Config Mgmt | A.8.9 | PR.IP-1 | — | — |
| Encryption at Rest | §8.1 Data Protection | A.8.24 | PR.DS-1 | — | §4 Encryption |
| Audit Logging | §11.1 Log Management | A.8.15 | DE.CM-1 | 180-day retention | — |
| Patch Management | §5.1 VAPT | A.8.8 | ID.RA-1 | — | — |

---

*Part of [IS Audit Playbook](../../README.md) | See also: [Oracle Audit](oracle-audit.md)*
