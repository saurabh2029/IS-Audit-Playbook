# Oracle Database Audit Guide

> **Asset Type:** Oracle Database (12c / 19c / 21c)  
> **Audit Domain:** Database Security, ITGC — Access & Configuration Control  
> **Regulatory Mapping:** RBI Cyber Framework § Data Security | ISO 27001 A.8.3, A.8.4 | NIST SC, AU families | PCI DSS Req. 7, 8, 10  
> **Risk Level:** 🔴 Critical — Databases hold the most sensitive organizational and customer data

---

## Objective

To assess Oracle Database security controls covering:
- Authentication and access management
- Privileged account governance (SYS, SYSTEM, DBA roles)
- Object-level and data-level access controls
- Audit trail configuration and integrity
- Database configuration hardening
- Encryption and data protection
- Patch management status

---

## Pre-Audit Requirements

### Access Needed
- [ ] Read-only DBA account with SELECT on DBA_* and V$* views (minimum)
- [ ] SELECT ANY DICTIONARY system privilege (preferred)
- [ ] Access to Oracle Enterprise Manager (OEM) or SQL*Plus
- [ ] OS-level read access to `sqlnet.ora`, `listener.ora`, `init.ora` / `spfile`

### Tools Required
- SQL*Plus or Oracle SQL Developer
- Oracle Database Vault (if deployed) console access
- Oracle Audit Vault and Database Firewall (AVDF) console (if deployed)
- CIS Oracle Database Benchmark (download from cisecurity.org)

### Minimum Required Grants for Audit Account
```sql
-- Create a read-only audit account with minimum required privileges
CREATE USER db_auditor IDENTIFIED BY <strong_password>;
GRANT CREATE SESSION TO db_auditor;
GRANT SELECT ANY DICTIONARY TO db_auditor;
GRANT SELECT ON DBA_USERS TO db_auditor;
GRANT SELECT ON DBA_ROLES TO db_auditor;
GRANT SELECT ON DBA_SYS_PRIVS TO db_auditor;
GRANT SELECT ON V_$PARAMETER TO db_auditor;
GRANT SELECT ON V_$SESSION TO db_auditor;
GRANT SELECT ON UNIFIED_AUDIT_TRAIL TO db_auditor;
```

---

## Audit Checklist

### Section 1 — Database Version & Patch Status

| # | Control | SQL / Command | Expected | Risk |
|---|---------|--------------|----------|------|
| 1.1 | Database version is current and supported | `SELECT * FROM V$VERSION;` | Not on EOL version | High |
| 1.2 | Latest Critical Patch Update (CPU) applied | `SELECT * FROM DBA_REGISTRY_SQLPATCH ORDER BY ACTION_TIME DESC;` | CPU within last quarter | High |
| 1.3 | Database components are all valid | `SELECT COMP_NAME, STATUS, VERSION FROM DBA_REGISTRY;` | All VALID | Medium |
| 1.4 | OS-level patches applied to DB server | OS patch check | Within 30-day patch cycle | High |

```sql
-- Check database version and release
SELECT BANNER FROM V$VERSION;

-- Check installed patches (most recent first)
SELECT PATCH_ID, PATCH_UID, VERSION, ACTION, STATUS, 
       TO_CHAR(ACTION_TIME,'DD-MON-YYYY HH24:MI:SS') AS PATCH_DATE,
       DESCRIPTION
FROM   DBA_REGISTRY_SQLPATCH
ORDER  BY ACTION_TIME DESC
FETCH FIRST 10 ROWS ONLY;

-- Check for component validity
SELECT COMP_ID, COMP_NAME, VERSION, STATUS
FROM   DBA_REGISTRY
ORDER  BY COMP_NAME;
```

---

### Section 2 — User Account Management

| # | Control | SQL / Command | Expected | Risk |
|---|---------|--------------|----------|------|
| 2.1 | Default accounts (SCOTT, HR, OE, etc.) are locked | Query below | All locked | 🔴 Critical |
| 2.2 | Default account passwords are changed | Attempt login with default passwords | Login fails | 🔴 Critical |
| 2.3 | Accounts not logged in for 90+ days are locked | Query last login | Zero active dormant accounts | High |
| 2.4 | SYS and SYSTEM used only for admin tasks | Review session history | No application logins as SYS/SYSTEM | 🔴 Critical |
| 2.5 | Shared/generic accounts do not exist | Review account list | No accounts like app_user, generic, test | High |
| 2.6 | Failed login lockout is configured | Check profile settings | Lockout after ≤ 10 failed attempts | High |
| 2.7 | Password expiry is enforced | Check DEFAULT profile | MAX_DAYS ≤ 90 | High |
| 2.8 | Password complexity profile is assigned | Check profile constraints | Complexity function assigned | High |

```sql
-- List all database users with status and last login
SELECT USERNAME,
       ACCOUNT_STATUS,
       TO_CHAR(LAST_LOGIN,'DD-MON-YYYY HH24:MI:SS') AS LAST_LOGIN,
       TO_CHAR(CREATED,'DD-MON-YYYY') AS CREATED,
       PROFILE,
       AUTHENTICATION_TYPE
FROM   DBA_USERS
ORDER  BY ACCOUNT_STATUS, USERNAME;

-- Find default Oracle accounts that should be locked
SELECT USERNAME, ACCOUNT_STATUS, LAST_LOGIN
FROM   DBA_USERS
WHERE  USERNAME IN (
  'ANONYMOUS','APEX_PUBLIC_USER','CTXSYS','DBSNMP','DIP',
  'DVSYS','DVF','EXFSYS','FLOWS_FILES','HR','IX','LBACSYS',
  'MDDATA','MDSYS','MGMT_VIEW','OE','OJVMSYS','OLAPSYS','ORDDATA',
  'ORDPLUGINS','ORDSYS','OUTLN','OWBSYS','PM','SCOTT','SH',
  'SI_INFORMTN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SQLTXPLAIN',
  'SYS','SYSBACKUP','SYSDG','SYSKM','SYSTEM','WMSYS','XDB','XS$NULL'
)
AND ACCOUNT_STATUS != 'EXPIRED & LOCKED'
ORDER BY ACCOUNT_STATUS;

-- Find accounts with no login in 90+ days (dormant)
SELECT USERNAME, ACCOUNT_STATUS, 
       LAST_LOGIN,
       ROUND(SYSDATE - CAST(LAST_LOGIN AS DATE)) AS DAYS_INACTIVE
FROM   DBA_USERS
WHERE  ACCOUNT_STATUS = 'OPEN'
  AND  LAST_LOGIN < SYSDATE - 90
  AND  USERNAME NOT IN ('SYS','SYSTEM')
ORDER  BY DAYS_INACTIVE DESC;

-- Review DEFAULT profile password settings
SELECT RESOURCE_NAME, LIMIT
FROM   DBA_PROFILES
WHERE  PROFILE = 'DEFAULT'
  AND  RESOURCE_TYPE = 'PASSWORD'
ORDER  BY RESOURCE_NAME;

-- List all profiles and their lockout settings
SELECT PROFILE, RESOURCE_NAME, LIMIT
FROM   DBA_PROFILES
WHERE  RESOURCE_NAME IN (
  'FAILED_LOGIN_ATTEMPTS','PASSWORD_LOCK_TIME',
  'PASSWORD_LIFE_TIME','PASSWORD_REUSE_TIME',
  'PASSWORD_REUSE_MAX','PASSWORD_VERIFY_FUNCTION'
)
ORDER  BY PROFILE, RESOURCE_NAME;
```

---

### Section 3 — Privilege Management

| # | Control | SQL / Command | Expected | Risk |
|---|---------|--------------|----------|------|
| 3.1 | DBA role is granted to minimal users | Query DBA role members | ≤ 5 accounts | 🔴 Critical |
| 3.2 | No application accounts have DBA role | Verify DBA members | No app/service accounts | 🔴 Critical |
| 3.3 | SYSDBA privilege is restricted | `SELECT * FROM V$PWFILE_USERS;` | Only SYS + designated DBAs | 🔴 Critical |
| 3.4 | WITH ADMIN OPTION grants are minimized | Query admin options | No non-DBA accounts | High |
| 3.5 | WITH GRANT OPTION minimized | Query grant options | Only justified accounts | High |
| 3.6 | SELECT ANY TABLE not granted to app accounts | System privilege check | Not granted | High |
| 3.7 | PUBLIC role has no unnecessary privileges | Review PUBLIC grants | Minimal grants only | High |
| 3.8 | Object privileges follow least privilege | Review object grants | Role-based, not direct grants | Medium |

```sql
-- Find all DBA role members (direct and indirect)
SELECT GRANTEE, GRANTED_ROLE, ADMIN_OPTION, DEFAULT_ROLE
FROM   DBA_ROLE_PRIVS
WHERE  GRANTED_ROLE = 'DBA'
ORDER  BY GRANTEE;

-- Find users with SYSDBA or SYSOPER privileges
SELECT * FROM V$PWFILE_USERS;

-- All system privileges granted WITH ADMIN OPTION
SELECT GRANTEE, PRIVILEGE, ADMIN_OPTION
FROM   DBA_SYS_PRIVS
WHERE  ADMIN_OPTION = 'YES'
  AND  GRANTEE NOT IN ('DBA','SYS','SYSTEM')
ORDER  BY GRANTEE;

-- Dangerous system privileges granted to non-DBA users
SELECT GRANTEE, PRIVILEGE
FROM   DBA_SYS_PRIVS
WHERE  PRIVILEGE IN (
  'ALTER SYSTEM','ALTER DATABASE','CREATE ANY PROCEDURE',
  'DROP ANY TABLE','DROP ANY PROCEDURE','EXECUTE ANY PROCEDURE',
  'SELECT ANY TABLE','INSERT ANY TABLE','UPDATE ANY TABLE',
  'DELETE ANY TABLE','CREATE ANY TABLE','GRANT ANY PRIVILEGE',
  'GRANT ANY OBJECT PRIVILEGE','GRANT ANY ROLE',
  'AUDIT SYSTEM','BECOME USER','CREATE EXTERNAL JOB'
)
AND GRANTEE NOT IN ('SYS','SYSTEM','DBA','IMP_FULL_DATABASE','EXP_FULL_DATABASE')
ORDER BY PRIVILEGE, GRANTEE;

-- Privileges granted to PUBLIC (visible to all users)
SELECT GRANTEE, OWNER, TABLE_NAME, PRIVILEGE, GRANTABLE
FROM   DBA_TAB_PRIVS
WHERE  GRANTEE = 'PUBLIC'
ORDER  BY OWNER, TABLE_NAME;

-- Role hierarchy — who has what roles
SELECT GRANTEE, GRANTED_ROLE, ADMIN_OPTION, DEFAULT_ROLE
FROM   DBA_ROLE_PRIVS
WHERE  GRANTEE NOT IN (
  SELECT ROLE FROM DBA_ROLES
)
AND GRANTEE NOT IN ('SYS','SYSTEM')
ORDER  BY GRANTEE, GRANTED_ROLE;
```

---

### Section 4 — Listener & Network Security

| # | Control | File / Command | Expected | Risk |
|---|---------|---------------|----------|------|
| 4.1 | Listener has a password set (Oracle 11g and below) | `listener.ora` review | PASSWORDS_LISTENER set | High |
| 4.2 | Listener runs on non-default port if internet-facing | `listener.ora` | Not 1521 on public-facing DB | Medium |
| 4.3 | EXTPROC listener removed if not needed | `listener.ora` | No EXTPROC entry | High |
| 4.4 | `sqlnet.ora` SQLNET.ALLOWED_LOGON_VERSION set | `sqlnet.ora` review | ≥ 12 (Oracle 19c+) | High |
| 4.5 | Valid Node Checking (SQLNET.VALID_NODE_CHECKING) | `sqlnet.ora` | = SUBNET or LOCAL | High |
| 4.6 | DB accessible only from app server / bastion IPs | Network firewall review | Not exposed to 0.0.0.0 | 🔴 Critical |
| 4.7 | Database links are reviewed and minimized | `SELECT * FROM DBA_DB_LINKS` | Only justified links | High |

```sql
-- Find all database links
SELECT OWNER, DB_LINK, USERNAME, HOST, CREATED
FROM   DBA_DB_LINKS
ORDER  BY OWNER;

-- Check TCP.VALIDNODE_CHECKING parameter (via parameter view)
SELECT NAME, VALUE
FROM   V$PARAMETER
WHERE  NAME IN (
  'remote_login_passwordfile',
  'sec_max_failed_login_attempts',
  'sec_protocol_error_trace_action',
  'audit_trail',
  'audit_sys_operations',
  'os_authent_prefix',
  'remote_os_authent',
  'remote_os_roles',
  '07_dictionary_accessibility'
);

-- External password file usage
SELECT NAME, VALUE
FROM   V$PARAMETER
WHERE  NAME = 'remote_login_passwordfile';
```

---

### Section 5 — Audit Trail Configuration

| # | Control | SQL / Command | Expected | Risk |
|---|---------|--------------|----------|------|
| 5.1 | Unified Auditing is enabled (12c+) | Check UNIFIED_AUDIT_TRAIL | Active | 🔴 Critical |
| 5.2 | Audit of SYS operations is enabled | `AUDIT_SYS_OPERATIONS = TRUE` | TRUE | 🔴 Critical |
| 5.3 | Audit policies cover critical actions | Review audit policies | Logon, DDL, DML on sensitive tables | High |
| 5.4 | Audit trail is protected from modification | Check audit trail permissions | Only SYS can delete | 🔴 Critical |
| 5.5 | Audit data is exported to central SIEM | Verify AVDF or syslog forwarding | Logs in central store | High |
| 5.6 | Audit log retention ≥ 180 days | Check retention policy | ≥ 180 days (CERT-In mandate) | High |
| 5.7 | Failed login attempts are audited | Check audit policy | Audit logon failures | High |
| 5.8 | Privileged user activity (SYS/SYSTEM) audited | Check SYS audit settings | All SYS actions captured | 🔴 Critical |

```sql
-- Check if Unified Auditing is enabled (Oracle 12c+)
SELECT VALUE
FROM   V$OPTION
WHERE  PARAMETER = 'Unified Auditing';

-- Check AUDIT_SYS_OPERATIONS parameter
SELECT NAME, VALUE
FROM   V$PARAMETER
WHERE  NAME = 'audit_sys_operations';

-- List all active unified audit policies
SELECT POLICY_NAME, ENABLED_OPTION, ENTITY_NAME, ENTITY_TYPE, SUCCESS, FAILURE
FROM   AUDIT_UNIFIED_ENABLED_POLICIES
ORDER  BY POLICY_NAME;

-- Review all unified audit policies and what they capture
SELECT POLICY_NAME, AUDIT_OPTION, OBJECT_SCHEMA, OBJECT_NAME, OBJECT_TYPE
FROM   AUDIT_UNIFIED_POLICIES
ORDER  BY POLICY_NAME, AUDIT_OPTION;

-- Recent audit trail — failed logins (last 7 days)
SELECT DBUSERNAME, OS_USERNAME, USERHOST, TERMINAL,
       ACTION_NAME, RETURN_CODE,
       TO_CHAR(EVENT_TIMESTAMP,'DD-MON-YYYY HH24:MI:SS') AS EVENT_TIME
FROM   UNIFIED_AUDIT_TRAIL
WHERE  ACTION_NAME = 'LOGON'
  AND  RETURN_CODE != 0
  AND  EVENT_TIMESTAMP > SYSDATE - 7
ORDER  BY EVENT_TIMESTAMP DESC
FETCH FIRST 100 ROWS ONLY;

-- Privileged user actions in last 30 days
SELECT DBUSERNAME, ACTION_NAME, OBJECT_SCHEMA, OBJECT_NAME,
       SQL_TEXT,
       TO_CHAR(EVENT_TIMESTAMP,'DD-MON-YYYY HH24:MI:SS') AS EVENT_TIME
FROM   UNIFIED_AUDIT_TRAIL
WHERE  DBUSERNAME IN ('SYS','SYSTEM')
  AND  EVENT_TIMESTAMP > SYSDATE - 30
ORDER  BY EVENT_TIMESTAMP DESC
FETCH FIRST 200 ROWS ONLY;

-- DDL actions (CREATE, DROP, ALTER) in last 30 days
SELECT DBUSERNAME, ACTION_NAME, OBJECT_SCHEMA, OBJECT_NAME, OBJECT_TYPE,
       TO_CHAR(EVENT_TIMESTAMP,'DD-MON-YYYY HH24:MI:SS') AS EVENT_TIME
FROM   UNIFIED_AUDIT_TRAIL
WHERE  ACTION_NAME IN (
  'CREATE TABLE','DROP TABLE','ALTER TABLE',
  'CREATE USER','DROP USER','ALTER USER',
  'GRANT','REVOKE',
  'CREATE PROCEDURE','DROP PROCEDURE',
  'CREATE TRIGGER','DROP TRIGGER'
)
AND EVENT_TIMESTAMP > SYSDATE - 30
ORDER BY EVENT_TIMESTAMP DESC;

-- Check audit trail size and space
SELECT OCCUPANT_NAME, OCCUPANT_DESC,
       ROUND(SPACE_USAGE_KBYTES/1024,2) AS SPACE_MB
FROM   V$SYSAUX_OCCUPANTS
WHERE  OCCUPANT_NAME = 'AUDSYS';
```

---

### Section 6 — Encryption & Data Protection

| # | Control | SQL / Command | Expected | Risk |
|---|---------|--------------|----------|------|
| 6.1 | Transparent Data Encryption (TDE) enabled for sensitive tablespaces | Query below | All PII/financial data tablespaces encrypted | 🔴 Critical |
| 6.2 | TDE Master Key stored in Oracle Wallet or HSM | Check wallet configuration | Wallet / HSM used, not file-based on DB server | High |
| 6.3 | Network encryption enabled (SQL*Net encryption) | Check `sqlnet.ora` | AES256 or NativeNetworkEncryption | High |
| 6.4 | Backup files are encrypted | Check RMAN configuration | Encryption enabled for RMAN backups | High |
| 6.5 | Passwords stored using strong hashing (SHA-512) | Check `password_versions` | No DES hashes (10G versions) | High |

```sql
-- Check TDE encrypted tablespaces
SELECT TABLESPACE_NAME, ENCRYPTED
FROM   DBA_TABLESPACES
ORDER  BY ENCRYPTED DESC, TABLESPACE_NAME;

-- Check individual encrypted columns (Column-Level Encryption)
SELECT OWNER, TABLE_NAME, COLUMN_NAME, ENCRYPTION_ALG, SALT
FROM   DBA_ENCRYPTED_COLUMNS
ORDER  BY OWNER, TABLE_NAME;

-- Check for weak/legacy password hashes (10G DES hash still present)
SELECT USERNAME, PASSWORD_VERSIONS
FROM   DBA_USERS
WHERE  PASSWORD_VERSIONS LIKE '%10G%'
   AND ACCOUNT_STATUS = 'OPEN';

-- Check network encryption parameters
SELECT NAME, VALUE
FROM   V$PARAMETER
WHERE  NAME IN (
  'sqlnet.encryption_server',
  'sqlnet.encryption_client', 
  'sqlnet.crypto_checksum_server',
  'sqlnet.crypto_checksum_client'
);

-- RMAN encryption status
-- Run from RMAN prompt: SHOW ALL;
-- Or query:
SELECT CF_RECORD_TYPE, CF_RECORD
FROM   V$RMAN_CONFIGURATION
WHERE  CF_RECORD LIKE '%ENCRYPTION%';
```

---

### Section 7 — Database Configuration Hardening

| # | Control | Parameter | Expected | Risk |
|---|---------|-----------|----------|------|
| 7.1 | `07_DICTIONARY_ACCESSIBILITY = FALSE` | V$PARAMETER | FALSE | 🔴 Critical |
| 7.2 | `REMOTE_OS_AUTHENT = FALSE` | V$PARAMETER | FALSE | 🔴 Critical |
| 7.3 | `REMOTE_OS_ROLES = FALSE` | V$PARAMETER | FALSE | High |
| 7.4 | `OS_AUTHENT_PREFIX = ''` (empty) | V$PARAMETER | Empty string | High |
| 7.5 | `SEC_MAX_FAILED_LOGIN_ATTEMPTS ≤ 10` | V$PARAMETER | ≤ 10 | High |
| 7.6 | `UTL_FILE_DIR` is restricted | V$PARAMETER | Not set to `*` | High |
| 7.7 | Unnecessary packages revoked from PUBLIC | Check PUBLIC grants | UTL_FILE, UTL_SMTP, UTL_TCP not on PUBLIC | High |
| 7.8 | XML DB (XMLDB) disabled if not required | Check component | Removed if unused | Medium |
| 7.9 | Trace/dump files have restricted OS permissions | OS check | No world-readable permissions | Medium |

```sql
-- Security-critical initialization parameters (all in one query)
SELECT NAME, VALUE, DESCRIPTION
FROM   V$PARAMETER
WHERE  NAME IN (
  '07_dictionary_accessibility',
  'remote_os_authent',
  'remote_os_roles',
  'os_authent_prefix',
  'sec_max_failed_login_attempts',
  'sec_protocol_error_trace_action',
  'sec_return_server_release_banner',
  'utl_file_dir',
  'remote_login_passwordfile',
  'audit_trail',
  'audit_sys_operations',
  'o7_dictionary_accessibility'
)
ORDER BY NAME;

-- Dangerous packages granted to PUBLIC
SELECT GRANTEE, OWNER, TABLE_NAME AS PACKAGE_NAME, PRIVILEGE
FROM   DBA_TAB_PRIVS
WHERE  GRANTEE = 'PUBLIC'
  AND  OWNER = 'SYS'
  AND  TABLE_NAME IN (
    'UTL_FILE','UTL_SMTP','UTL_TCP','UTL_HTTP','UTL_MAIL',
    'DBMS_RANDOM','DBMS_SCHEDULER','DBMS_JOB',
    'DBMS_SYS_SQL','DBMS_BACKUP_RESTORE','DBMS_OBFUSCATION_TOOLKIT'
  )
ORDER BY TABLE_NAME;

-- Check for jobs that run with elevated privileges
SELECT JOB_NAME, JOB_TYPE, JOB_ACTION, OWNER, 
       RUN_COUNT, LAST_RUN_DURATION, NEXT_RUN_DATE
FROM   DBA_SCHEDULER_JOBS
WHERE  ENABLED = 'TRUE'
ORDER  BY OWNER, JOB_NAME;
```

---

## Evidence to Collect

| Evidence Item | Collection Method | Format |
|--------------|------------------|--------|
| DB version and patch level | SQL query output | TXT / Screenshot |
| All user accounts with status | SQL export | CSV |
| Default accounts status | SQL export | CSV |
| DBA role members | SQL export | CSV |
| SYSDBA privilege holders | SQL output | Screenshot |
| Dangerous system privileges | SQL export | CSV |
| Profile password settings | SQL export | Screenshot |
| Audit policy list | SQL export | CSV |
| Encrypted tablespaces | SQL output | Screenshot |
| Critical init parameters | SQL export | TXT |
| Init.ora / spfile content | File review | TXT (sanitized) |
| Listener.ora | File review | TXT (sanitized) |
| sqlnet.ora | File review | TXT (sanitized) |
| SIEM log forwarding config | Screenshot | Screenshot |

---

## Common Findings

### Finding ORA-001 — DBA Role Granted to Application Accounts
> **Condition:** 3 application service accounts (APP_USER, FINACLE_SVC, BATCH_USR) were found with the DBA role granted directly.  
> **Criteria:** CIS Oracle Benchmark v3.0 Control 2.2 and the organization's Database Security Policy require application accounts to be granted only the minimum privileges required for their function.  
> **Effect:** Application account compromise would grant an attacker full DBA access, including ability to read all data, modify audit trails, create backdoor accounts, and disable security controls.  
> **Recommendation:** Revoke DBA from all three application accounts immediately. Perform privilege analysis (`DBMS_PRIVILEGE_CAPTURE`) to identify actual required privileges and re-grant minimally.  
> **Risk:** 🔴 Critical

### Finding ORA-002 — Audit Trail Not Centrally Forwarded
> **Condition:** Oracle Unified Audit trail is active but audit records are retained locally on the database server (AUDSYS.AUD$UNIFIED) with a 30-day purge policy. No forwarding to the central SIEM (Splunk) was configured.  
> **Criteria:** CERT-In Directions (April 2022) Section 6(1) mandate log retention for 180 days. RBI Cybersecurity Framework Annex I Control 11.3 requires centralized, tamper-proof audit log storage.  
> **Effect:** Local storage is accessible to DBAs who could potentially modify or purge audit records. 30-day retention does not satisfy CERT-In's 180-day mandate, creating regulatory non-compliance.  
> **Recommendation:** Configure Oracle Audit Vault (AVDF) or a syslog forwarder to push unified audit trail to Splunk. Extend local purge policy to 180 days as interim measure.  
> **Risk:** 🔴 Critical

### Finding ORA-003 — Sensitive Tablespaces Not Encrypted
> **Condition:** TDE is not enabled for CUSTOMER_DATA, TRANSACTION_LOG, and ACCOUNT_MASTER tablespaces, which contain customer PII and financial records.  
> **Criteria:** DPDP Act 2023 Section 4 requires appropriate technical safeguards for personal data. RBI Cybersecurity Framework Annex I Control 8.1 requires encryption of sensitive data at rest.  
> **Effect:** Physical theft of storage media or unauthorized OS-level access to datafiles would expose customer financial data in plaintext, constituting a reportable data breach.  
> **Recommendation:** Enable TDE for identified tablespaces. Store TDE master key in a hardware security module (HSM) or Oracle Key Vault — not on the database server filesystem.  
> **Risk:** 🔴 Critical

---

## Regulatory Mapping

| Control Area | RBI Cyber Framework | ISO 27001:2022 | NIST CSF | CERT-In 2022 | DPDP Act 2023 |
|---|---|---|---|---|---|
| Access Control | §6.1 IAM | A.9.2, A.9.4 | PR.AC-4 | — | §4 Technical safeguards |
| Privileged Access | §7.1 PAM | A.9.2.3 | PR.AC-6 | — | — |
| Encryption at Rest | §8.1 Data Protection | A.8.24 | PR.DS-1 | — | §4 Encryption |
| Audit Logging | §11.1 Logs | A.8.15 | DE.CM-1 | 180-day retention | — |
| Patch Management | §5.1 VAPT | A.8.8 | ID.RA-1 | — | — |
| Network Exposure | §5.2 Network Sec | A.8.20 | PR.AC-5 | — | — |

---

*Part of [IS Audit Playbook](../../README.md) | See also: [MSSQL Audit](mssql-audit.md)*
