-- ═══════════════════════════════════════════════════════════════════
-- Oracle Database Security Audit Query Bundle
-- Companion to: 03-Asset-Audit-Guides/Database-Audit/oracle-audit.md
-- Usage: Run as a user with SELECT ANY DICTIONARY privilege
-- Output: Spool each section to a file for audit evidence
-- ═══════════════════════════════════════════════════════════════════

SET PAGESIZE 1000
SET LINESIZE 200
SET FEEDBACK ON
COLUMN report_section NEW_VALUE section_name

-- ───────────────────────────────────────────────────────────────────
-- SECTION 1: Database Version and Patch Status
-- ───────────────────────────────────────────────────────────────────
SPOOL oracle_audit_01_version.txt
SELECT BANNER FROM V$VERSION;
SELECT PATCH_ID, ACTION, STATUS, TO_CHAR(ACTION_TIME,'DD-MON-YYYY') AS PATCH_DATE
FROM   DBA_REGISTRY_SQLPATCH
ORDER  BY ACTION_TIME DESC
FETCH FIRST 10 ROWS ONLY;
SPOOL OFF

-- ───────────────────────────────────────────────────────────────────
-- SECTION 2: User Account Audit
-- ───────────────────────────────────────────────────────────────────
SPOOL oracle_audit_02_users.txt
SELECT USERNAME, ACCOUNT_STATUS,
       TO_CHAR(LAST_LOGIN,'DD-MON-YYYY HH24:MI') AS LAST_LOGIN,
       TO_CHAR(CREATED,'DD-MON-YYYY') AS CREATED,
       PROFILE
FROM   DBA_USERS
ORDER  BY ACCOUNT_STATUS, USERNAME;

-- Default accounts that should be locked
SELECT USERNAME, ACCOUNT_STATUS
FROM   DBA_USERS
WHERE  USERNAME IN (
  'ANONYMOUS','APEX_PUBLIC_USER','CTXSYS','DBSNMP','HR','OE',
  'SCOTT','SH','OUTLN','XDB','XS$NULL'
)
AND ACCOUNT_STATUS != 'EXPIRED & LOCKED';

-- Dormant accounts (90+ days inactive)
SELECT USERNAME, LAST_LOGIN,
       ROUND(SYSDATE - CAST(LAST_LOGIN AS DATE)) AS DAYS_INACTIVE
FROM   DBA_USERS
WHERE  ACCOUNT_STATUS = 'OPEN'
  AND  LAST_LOGIN < SYSDATE - 90
  AND  USERNAME NOT IN ('SYS','SYSTEM')
ORDER  BY DAYS_INACTIVE DESC;
SPOOL OFF

-- ───────────────────────────────────────────────────────────────────
-- SECTION 3: Privilege Audit
-- ───────────────────────────────────────────────────────────────────
SPOOL oracle_audit_03_privileges.txt
-- DBA role members
SELECT GRANTEE, GRANTED_ROLE, ADMIN_OPTION
FROM   DBA_ROLE_PRIVS
WHERE  GRANTED_ROLE = 'DBA'
ORDER  BY GRANTEE;

-- SYSDBA/SYSOPER holders
SELECT * FROM V$PWFILE_USERS;

-- Dangerous system privileges on non-DBA accounts
SELECT GRANTEE, PRIVILEGE
FROM   DBA_SYS_PRIVS
WHERE  PRIVILEGE IN (
  'ALTER SYSTEM','DROP ANY TABLE','SELECT ANY TABLE',
  'GRANT ANY PRIVILEGE','GRANT ANY ROLE','EXECUTE ANY PROCEDURE'
)
AND GRANTEE NOT IN ('SYS','SYSTEM','DBA');

-- PUBLIC grants (visible to everyone)
SELECT OWNER, TABLE_NAME, PRIVILEGE
FROM   DBA_TAB_PRIVS
WHERE  GRANTEE = 'PUBLIC'
  AND  OWNER = 'SYS'
  AND  TABLE_NAME IN ('UTL_FILE','UTL_SMTP','UTL_TCP','UTL_HTTP','DBMS_SCHEDULER');
SPOOL OFF

-- ───────────────────────────────────────────────────────────────────
-- SECTION 4: Audit Trail Configuration
-- ───────────────────────────────────────────────────────────────────
SPOOL oracle_audit_04_audittrail.txt
SELECT VALUE FROM V$OPTION WHERE PARAMETER = 'Unified Auditing';
SELECT NAME, VALUE FROM V$PARAMETER WHERE NAME = 'audit_sys_operations';
SELECT POLICY_NAME, ENABLED_OPTION, SUCCESS, FAILURE
FROM   AUDIT_UNIFIED_ENABLED_POLICIES
ORDER  BY POLICY_NAME;
SPOOL OFF

-- ───────────────────────────────────────────────────────────────────
-- SECTION 5: Encryption Status
-- ───────────────────────────────────────────────────────────────────
SPOOL oracle_audit_05_encryption.txt
SELECT TABLESPACE_NAME, ENCRYPTED
FROM   DBA_TABLESPACES
ORDER  BY ENCRYPTED DESC;

SELECT USERNAME, PASSWORD_VERSIONS
FROM   DBA_USERS
WHERE  PASSWORD_VERSIONS LIKE '%10G%'
   AND ACCOUNT_STATUS = 'OPEN';
SPOOL OFF

-- ───────────────────────────────────────────────────────────────────
-- SECTION 6: Hardening Parameters
-- ───────────────────────────────────────────────────────────────────
SPOOL oracle_audit_06_hardening.txt
SELECT NAME, VALUE
FROM   V$PARAMETER
WHERE  NAME IN (
  '07_dictionary_accessibility','remote_os_authent','remote_os_roles',
  'os_authent_prefix','sec_max_failed_login_attempts','utl_file_dir',
  'remote_login_passwordfile'
)
ORDER BY NAME;

SELECT OWNER, DB_LINK, USERNAME, HOST
FROM   DBA_DB_LINKS
ORDER  BY OWNER;
SPOOL OFF

PROMPT
PROMPT ═══════════════════════════════════════════════════════════════
PROMPT  Audit complete. Review the following files:
PROMPT  oracle_audit_01_version.txt   through   oracle_audit_06_hardening.txt
PROMPT  Cross-reference against: oracle-audit.md checklist sections 1-7
PROMPT ═══════════════════════════════════════════════════════════════
