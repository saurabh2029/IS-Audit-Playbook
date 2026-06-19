# ITGC — Access Management Audit Guide

> **ITGC Domain:** Logical Access Management  
> **Audit Scope:** User provisioning, deprovisioning, privilege management, periodic access review, segregation of duties  
> **COBIT Objective:** DSS05.04, APO01.02, APO07  
> **Regulatory Mapping:** RBI Cyber Framework §6 | ISO 27001 A.9 | NIST PR.AC | PCI DSS Req. 7, 8

---

## Why Access Management Is a Key ITGC

Access Management is one of the **four core IT General Controls** tested in virtually every IS audit (the others being Change Management, Backup & Recovery, and Incident Management). It addresses a fundamental control principle:

> *"The right people should have access to the right systems with the right level of privilege — no more, no less — and only for as long as they need it."*

Failures here directly enable unauthorized access, insider fraud, data breaches, and regulatory violations. Access Management findings appear in the majority of IS audit reports.

---

## Access Management Control Framework

```
JOINER          MOVER           LEAVER
   │               │               │
   ▼               ▼               ▼
Provisioning → Role Change → Deprovisioning
   │               │               │
   └───────────────┴───────────────┘
                   │
            Periodic Review
          (Access Certification)
                   │
          Segregation of Duties
          (Toxic Combination Check)
```

---

## Audit Checklist

### Section 1 — Access Management Policy & Governance

| # | Control | Test Method | Expected | Risk |
|---|---------|------------|----------|------|
| 1.1 | Access management policy exists and is Board/CISO approved | Document review | Current-year approved policy | 🟠 High |
| 1.2 | Policy covers joiner/mover/leaver process | Policy review | All three lifecycle stages covered | 🟠 High |
| 1.3 | Data/system owners are designated for all critical systems | Owner register | Named owner for each critical asset | 🟠 High |
| 1.4 | Role-Based Access Control (RBAC) model is defined | Review role matrix | Roles defined; no individual exceptions | Medium |
| 1.5 | Privileged access management (PAM) policy exists | Policy review | Separate PAM policy or dedicated section | 🟠 High |
| 1.6 | Policy review cycle is annual | Policy properties | Last reviewed within 12 months | Medium |

---

### Section 2 — User Provisioning (Joiner Process)

| # | Control | Test Method | Expected | Risk |
|---|---------|------------|----------|------|
| 2.1 | Formal access request raised for all new users | Sample test — trace new joiners | Approved request exists for each | 🟠 High |
| 2.2 | Manager/data owner approval required before provisioning | Sample review | Approval documented in ticket | 🟠 High |
| 2.3 | Access granted matches role/job function | Sample review | No excess access beyond role | 🟠 High |
| 2.4 | Unique IDs assigned to every user (no shared accounts) | AD/system query | Zero shared accounts | 🔴 Critical |
| 2.5 | Default/temporary passwords are changed on first login | Policy and system check | `Must change on first login` enforced | 🟠 High |
| 2.6 | Access is provisioned from date of joining, not earlier | Compare provision date vs. start date | No pre-provisioning > 1 day | Medium |
| 2.7 | HR system is source of truth for provisioning | Process review | HR triggers provisioning workflow | Medium |

**Sample Test Approach (Joiner):**

```
Population:   All new hires in audit period (e.g., April 2024 – March 2025)
Sample Size:  25 users (or 100% if population < 25)

For each sample, obtain:
✓ Access Request Form / IT ticket
✓ Manager approval evidence (email / workflow)
✓ Account creation date vs. joining date
✓ Access provisioned (role/groups) vs. role authorized in request
✓ Default password change enforcement
```

---

### Section 3 — User Modification (Mover Process)

| # | Control | Test Method | Expected | Risk |
|---|---------|------------|----------|------|
| 3.1 | Role changes trigger access review and update | Sample test internal transfers | Old access removed; new access granted | 🟠 High |
| 3.2 | Promotion/demotion adjusts access appropriately | Sample — promotions | Prior access revoked before new granted | 🟠 High |
| 3.3 | Temporary access grants have defined expiry | Review temp access | All temp access has defined end date | 🟠 High |
| 3.4 | Inter-department transfers are communicated to IT | Process review | HR → IT notification SLA defined | Medium |
| 3.5 | Excess access from prior roles does not accumulate | Access review | No residual access from past roles | 🟠 High |

---

### Section 4 — User Deprovisioning (Leaver Process)

This is the **highest-risk** area in access management — terminated employee accounts are a frequent finding.

| # | Control | Test Method | Expected | Risk |
|---|---------|------------|----------|------|
| 4.1 | Accounts of separated employees are disabled on last working day | Cross-check HR termination list vs. AD/system | Zero active accounts for ex-employees | 🔴 Critical |
| 4.2 | Deprovisioning SLA is defined (e.g., within 24 hours of separation) | Policy review | Clear SLA documented | 🟠 High |
| 4.3 | IT is notified by HR on or before last working day | Process review | Formal notification mechanism exists | 🟠 High |
| 4.4 | Privileged access of leavers is revoked immediately | Sample — leavers with admin access | Revoked on or before departure | 🔴 Critical |
| 4.5 | Remote access tokens/certificates revoked | VPN and MFA review | Certificates and tokens revoked | 🔴 Critical |
| 4.6 | Business email access terminated | Email system review | Mailbox disabled on departure | 🟠 High |
| 4.7 | Contractor accounts have defined end dates | System query | All contractor accounts have expiry set | 🟠 High |

**Sample Test Approach (Leaver):**

```
Population:   All separations in audit period (HR termination list)
Sample Size:  25–40 users

For each sample, obtain:
✓ Last working date from HR records
✓ Account disable date in AD (compare to last working date)
✓ VPN/MFA token revocation date
✓ Application access termination date
✓ Any logins AFTER last working date (critical finding if found)

PowerShell — check logins after termination date:
Get-ADUser <username> -Properties LastLogonDate | Select Name, LastLogonDate
```

---

### Section 5 — Privileged Access Management

| # | Control | Test Method | Expected | Risk |
|---|---------|------------|----------|------|
| 5.1 | Privileged accounts are separate from regular accounts | AD and system review | Admin accounts follow naming convention; not daily-use accounts | 🔴 Critical |
| 5.2 | Privileged access is time-limited / checked out via PAM | PAM tool review | No standing privileged access; just-in-time where possible | 🔴 Critical |
| 5.3 | Privileged account sessions are recorded | PAM / session recording | Sessions logged and recordings retained | 🔴 Critical |
| 5.4 | Privileged account list is reviewed quarterly | Review records | Last review within 90 days; sign-off by CISO | 🟠 High |
| 5.5 | Shared admin accounts (e.g., root, local admin) are managed via LAPS/PAM | Review | No static shared passwords | 🔴 Critical |
| 5.6 | Multi-person authorization for critical operations | Process review | 4-eyes principle for critical commands | 🟠 High |
| 5.7 | MFA enforced for all privileged access | System check | No privileged access without MFA | 🔴 Critical |

---

### Section 6 — Periodic Access Review (Access Certification)

| # | Control | Test Method | Expected | Risk |
|---|---------|------------|----------|------|
| 6.1 | Access review is conducted at defined frequency | Review records | Minimum quarterly for privileged; semi-annual for regular | 🟠 High |
| 6.2 | Access reviews are performed by system/data owners | Review sign-offs | Not performed by IT only | 🟠 High |
| 6.3 | Exceptions identified in reviews are actioned | Trace exceptions to remediation | 100% of exceptions remediated within SLA | 🟠 High |
| 6.4 | Review covers all critical systems | Scope review | All Tier 1 systems included | 🟠 High |
| 6.5 | Review records are retained | Documentation | Review sign-off sheets retained ≥ 1 year | Medium |
| 6.6 | Dormant account identification is part of review | Review criteria | Accounts inactive > 90 days flagged | 🟠 High |

---

### Section 7 — Segregation of Duties (SoD)

SoD ensures no single individual can perform conflicting actions that would enable fraud or undetected error.

| # | Control | Test Method | Expected | Risk |
|---|---------|------------|----------|------|
| 7.1 | SoD matrix is defined for critical business processes | Document review | Formal SoD matrix exists | 🟠 High |
| 7.2 | No single user has conflicting roles in CBS/ERP | SoD tool or manual review | No toxic combinations identified | 🔴 Critical |
| 7.3 | IT Operations cannot also perform security admin | Role review | Separate IT Ops and IS functions | 🟠 High |
| 7.4 | Developers do not have production access | Access review | Dev access blocked in production | 🔴 Critical |
| 7.5 | Payment initiator and approver are different users | CBS role review | No user can both initiate and approve payments | 🔴 Critical |
| 7.6 | SoD conflicts are tracked and mitigated with compensating controls | Exception log | All conflicts documented with mitigating controls | 🟠 High |

**Common Toxic SoD Combinations in BFSI:**

| Role A | Role B | Risk |
|--------|--------|------|
| Payment Initiator | Payment Approver | Fraud — unauthorized payments |
| IT Developer | Production System Admin | Unauthorized code changes |
| Vendor Master Creator | Payment Approver | Fictitious vendor fraud |
| User Account Creator | User Account Approver | Ghost employee creation |
| General Ledger Entry | GL Approval | Financial misstatement |
| Trade Initiation | Trade Settlement | Trading fraud |

---

## Evidence to Collect

| Evidence | Source | Format |
|----------|--------|--------|
| Access management policy | Document management | PDF |
| New joiner sample — access requests + approvals | ITSM tool (ServiceNow, Jira) | Screenshots / PDF |
| Leaver list from HR | HR system export | CSV (anonymized) |
| Leaver disable dates from AD | PowerShell query | CSV |
| Privileged account list with last review sign-off | AD export + review sheets | CSV + PDF |
| Access review records with owner sign-offs | ITSM or email | PDF |
| SoD matrix | IT Governance document | Excel / PDF |
| SoD exception log | GRC tool or Excel | CSV |
| Contractor account list with expiry dates | AD / system export | CSV |

---

## Common Findings

### Finding AM-001 — Active Accounts for Terminated Employees

> **Condition:** Cross-referencing the HR termination list for the audit period with Active Directory confirmed that 23 accounts belonging to ex-employees remained enabled beyond their last working date. Of these, 6 accounts had recorded logon events after the employee's official departure date.  
> **Criteria:** Access Management Policy v2.1 Section 6.3 requires user accounts to be disabled on the last working date. RBI Cybersecurity Framework §6.1 mandates immediate revocation of access upon separation.  
> **Effect:** Active accounts of ex-employees represent a direct insider threat and unauthorized access risk. The 6 accounts with post-separation logins indicate that unauthorized access may have occurred, constituting a reportable security incident.  
> **Recommendation:** (1) Disable all 23 identified accounts immediately. (2) Investigate the 6 accounts with post-separation logins; determine if access was legitimate (e.g., read-only handover) or unauthorized. (3) Implement automated deprovisioning triggered by HR system upon separation. (4) Designate a maximum 4-hour SLA for privileged account deprovisioning.  
> **Risk:** 🔴 Critical

---

### Finding AM-002 — No Quarterly Privileged Access Review

> **Condition:** Review of access certification records showed that the last formal review of privileged accounts (Domain Admins, DBA role holders, SWIFT system administrators) was conducted 14 months ago, with no evidence of review in the current financial year.  
> **Criteria:** RBI Cybersecurity Framework §6.5 requires periodic access review, with a minimum quarterly cycle for privileged accounts. ISO 27001:2022 A.9.2.5 requires user access rights to be reviewed at regular intervals.  
> **Effect:** Without periodic review, access creep goes undetected — accounts that should be revoked retain privileged access. This creates unauthorized access risk to the most sensitive systems in the environment.  
> **Recommendation:** Conduct an immediate privileged access review involving system/data owners. Establish a quarterly calendar for privileged access certification. Implement an automated reminder process in the GRC tool. Sign-off by CISO required for each cycle.  
> **Risk:** 🟠 High

---

### Finding AM-003 — Developer Access to Production Environment

> **Condition:** 12 members of the application development team were found to have active, unrestricted access to the production Core Banking System (Finacle) environment, including read access to the production database and ability to deploy code to production servers.  
> **Criteria:** Segregation of Duties Policy §4.1 prohibits development team members from having access to production environments. COBIT BAI06 and ISO 27001 A.12.1.2 require environment separation. PCI DSS Requirement 6.2.3 mandates separation of development and production environments.  
> **Effect:** Developer access to production enables unauthorized code modifications, potential data extraction, and circumvents the change management control — as developers can deploy untested or unauthorized code directly, bypassing the UAT-to-production pipeline.  
> **Recommendation:** Revoke production environment access for all 12 developers with immediate effect. Implement firewall and network-level controls to enforce environment separation. Establish an emergency access ("break-glass") procedure for genuine production troubleshooting that requires CISO approval and full session recording.  
> **Risk:** 🔴 Critical

---

## Regulatory Mapping

| Control Area | RBI Cyber Framework | ISO 27001:2022 | COBIT 2019 | NIST CSF |
|---|---|---|---|---|
| Provisioning | §6.1 IAM Policy | A.9.2.1, A.9.2.2 | DSS05.04 | PR.AC-1 |
| Deprovisioning | §6.1 IAM Policy | A.9.2.6 | DSS05.04 | PR.AC-1 |
| Privileged Access | §6.4 Privileged Access | A.9.2.3 | APO13, DSS05.04 | PR.AC-4, PR.AC-6 |
| Access Review | §6.5 Periodic Review | A.9.2.5 | DSS05.04 | PR.AC-1 |
| Segregation of Duties | §7 (Implicit in IAM) | A.5.3, A.9.2.3 | APO01.02 | PR.AC-4 |
| Unique IDs | §6.2 Authentication | A.9.2.1 | DSS05.04 | PR.AC-1 |

---

*Part of [IS Audit Playbook](../README.md) | See also: [Change Management](change-management.md)*
