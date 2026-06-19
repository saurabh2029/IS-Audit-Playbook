/* ═══════════════════════════════════════════════════════════════════
   SQL Server Security Audit Query Bundle
   Companion to: 03-Asset-Audit-Guides/Database-Audit/mssql-audit.md
   Usage: Run as a login with VIEW SERVER STATE + VIEW ANY DEFINITION
   ═══════════════════════════════════════════════════════════════════ */

PRINT '=== SECTION 1: Version and Build ===';
SELECT  @@SERVERNAME AS ServerName,
        SERVERPROPERTY('ProductVersion') AS ProductVersion,
        SERVERPROPERTY('ProductLevel') AS ServicePack,
        SERVERPROPERTY('Edition') AS Edition;
GO

PRINT '=== SECTION 2: Authentication Mode ===';
SELECT CASE SERVERPROPERTY('IsIntegratedSecurityOnly')
           WHEN 1 THEN 'Windows Authentication Only'
           WHEN 0 THEN 'MIXED MODE - SQL logins allowed'
       END AS AuthenticationMode;
GO

PRINT '=== SECTION 3: SA Account Status ===';
SELECT  name, is_disabled,
        LOGINPROPERTY(name,'IsLocked') AS IsLocked,
        LOGINPROPERTY(name,'PasswordLastSetTime') AS PasswordLastSet
FROM    sys.server_principals
WHERE   sid = 0x01;
GO

PRINT '=== SECTION 4: All SQL Logins with Policy Status ===';
SELECT  name, is_disabled, is_policy_checked, is_expiration_checked,
        LOGINPROPERTY(name,'BadPasswordCount') AS FailedAttempts,
        create_date, modify_date
FROM    sys.sql_logins
ORDER   BY is_disabled, name;
GO

PRINT '=== SECTION 5: sysadmin Role Members ===';
SELECT  sp.name AS LoginName, sp.type_desc, sp.is_disabled
FROM    sys.server_role_members srm
JOIN    sys.server_principals sp ON srm.member_principal_id = sp.principal_id
JOIN    sys.server_principals sr ON srm.role_principal_id = sr.principal_id
WHERE   sr.name = 'sysadmin'
ORDER   BY sp.name;
GO

PRINT '=== SECTION 6: Surface Area Configuration ===';
SELECT  name, CAST(value AS INT) AS Configured, CAST(value_in_use AS INT) AS Running
FROM    sys.configurations
WHERE   name IN (
    'xp_cmdshell','Ole Automation Procedures','Agent XPs',
    'remote access','Ad Hoc Distributed Queries','clr enabled',
    'cross db ownership chaining','scan for startup procs'
)
ORDER   BY name;
GO

PRINT '=== SECTION 7: Linked Servers ===';
SELECT  srv.name AS LinkedServerName, srv.data_source, srv.product,
        srv.is_remote_login_enabled, srv.is_rpc_out_enabled
FROM    sys.servers srv
WHERE   srv.is_linked = 1;
GO

PRINT '=== SECTION 8: TDE Encryption Status (All Databases) ===';
SELECT  d.name AS DatabaseName, d.is_encrypted AS TDE_Enabled,
        dek.encryption_state_desc
FROM    sys.databases d
LEFT JOIN sys.dm_database_encryption_keys dek ON d.database_id = dek.database_id
ORDER   BY d.name;
GO

PRINT '=== SECTION 9: SQL Server Audit Configuration ===';
SELECT  name AS AuditName, status_desc, type_desc, file_path
FROM    sys.server_audits
ORDER   BY name;
GO

PRINT '=== SECTION 10: db_owner Members (db_owner sweep) ===';
EXEC sp_MSforeachdb '
USE [?];
SELECT  DB_NAME() AS DatabaseName, dp.name AS UserName, dp.type_desc
FROM    sys.database_role_members drm
JOIN    sys.database_principals dp ON drm.member_principal_id = dp.principal_id
JOIN    sys.database_principals dr ON drm.role_principal_id = dr.principal_id
WHERE   dr.name = ''db_owner'' AND dp.name NOT IN (''dbo'')
ORDER   BY dp.name;
';
GO

PRINT '=== SECTION 11: Guest User CONNECT Permission (All Databases) ===';
EXEC sp_MSforeachdb '
USE [?];
IF EXISTS (
    SELECT 1 FROM sys.database_permissions
    WHERE grantee_principal_id = DATABASE_PRINCIPAL_ID(''guest'')
      AND permission_name = ''CONNECT'' AND state = ''G''
)
SELECT ''?'' AS DatabaseName, ''Guest CONNECT granted - FLAG'' AS Issue;
';
GO

PRINT '=== SECTION 12: SQL Agent Jobs with Owner ===';
SELECT  j.name AS JobName, j.enabled, sp.name AS OwnerLogin, j.last_run_outcome
FROM    msdb.dbo.sysjobs j
LEFT JOIN sys.server_principals sp ON j.owner_sid = sp.sid
ORDER   BY j.enabled DESC, j.name;
GO

PRINT '=== AUDIT QUERY BUNDLE COMPLETE ===';
PRINT 'Cross-reference output against: mssql-audit.md checklist sections 1-7';
GO
