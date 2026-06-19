# ITGC — Change Management Audit Guide

> **ITGC Domain:** IT Change Management  
> **Audit Scope:** Normal, emergency, and infrastructure changes to production systems  
> **COBIT Objective:** BAI06 (Manage IT Changes), BAI07 (Manage IT Change Acceptance & Transitioning)  
> **Regulatory Mapping:** RBI Cyber Framework §7 | ISO 27001 A.8.32 | NIST PR.IP-3

---

## Why Change Management Is a Key ITGC

Change Management ensures that modifications to production systems are authorized, tested, and documented — preventing unauthorized, untested, or poorly planned changes that could cause outages, introduce vulnerabilities, or enable fraud. It is one of the four core ITGCs because:

- **Unauthorized changes** bypass security controls and audit trails
- **Untested changes** cause production outages and data corruption
- **Undocumented changes** make incident investigation impossible
- **Emergency changes without retrospective approval** are a common audit deficiency

In BFSI environments, an unauthorized change to the CBS, SWIFT system, or payment parameters can have immediate and material financial impact.

---

## Change Types Covered

| Change Type | Definition | Approval Required |
|-------------|------------|------------------|
| **Standard / Pre-approved** | Low-risk, pre-authorized recurring changes (e.g., restart service) | Pre-approval via template |
| **Normal** | Planned change with full CAB approval | Change Advisory Board (CAB) |
| **Emergency** | Unplanned, urgent change to restore service | Emergency CAB or CTO; retrospective approval within 24–48 hrs |
| **Major / Significant** | High-risk change affecting critical systems | CAB + CISO + Business Head |

---

## Audit Checklist

### Section 1 — Change Management Policy & Governance

| # | Control | Test Method | Expected | Risk |
|---|---------|------------|----------|------|
| 1.1 | Change management policy is documented and approved | Document review | Board / IT Head approved policy | 🟠 High |
| 1.2 | Policy covers all change types (normal, emergency, major) | Policy review | Distinct procedures per type | 🟠 High |
| 1.3 | Change Advisory Board (CAB) is constituted | Review CAB charter / minutes | CAB members defined; quorum rules set | 🟠 High |
| 1.4 | CAB meets at defined frequency (weekly minimum) | Review CAB meeting records | Meeting minutes for audit period | Medium |
| 1.5 | Segregation: Developers cannot approve their own changes | Policy + access review | No self-approval mechanism | 🔴 Critical |
| 1.6 | CMDB / change register is maintained | Tool review (ServiceNow, Jira) | All changes traceable in single repository | 🟠 High |

---

### Section 2 — Normal Change Process

| # | Control | Test Method | Expected | Risk |
|---|---------|------------|----------|------|
| 2.1 | All changes are formally raised via ITSM tool | Sample test | No out-of-system changes | 🔴 Critical |
| 2.2 | Change requests include risk assessment | Sample review | Risk impact and likelihood scored | 🟠 High |
| 2.3 | Testing evidence (UAT/SIT) is attached before CAB approval | Sample review | Test results linked in ticket | 🔴 Critical |
| 2.4 | Rollback plan is defined for each change | Sample review | Rollback procedure documented | 🟠 High |
| 2.5 | CAB approval is obtained before deployment | Sample review | Approval timestamp precedes deployment timestamp | 🔴 Critical |
| 2.6 | Deployment is performed by a separate release team (not developer) | Process review | Developer ≠ deployer | 🔴 Critical |
| 2.7 | Post-implementation review (PIR) is conducted | Sample review | PIR completed within 5 days of deployment | Medium |
| 2.8 | Change success/failure is recorded | CMDB review | All changes have closure status | Medium |

**Sample Test Approach (Normal Changes):**

```
Population:   All normal changes in audit period (from ITSM tool)
Sample Size:  25–40 changes (or 60% if population < 50)

For each sample, verify:
✓ Change Request (CR) ticket exists with unique ID
✓ Business justification documented
✓ Risk assessment completed
✓ Testing evidence (UAT/SIT results) attached prior to CAB
✓ CAB approval with named approvers and timestamp
✓ Approval date < Deployment date (no post-facto approvals)
✓ Rollback plan documented
✓ Deployment team ≠ change requester / developer
✓ Post-implementation review completed
✓ Change closed in ITSM with outcome
```

---

### Section 3 — Emergency Change Process

Emergency changes represent the highest risk in change management — speed pressure leads to bypassed controls.

| # | Control | Test Method | Expected | Risk |
|---|---------|------------|----------|------|
| 3.1 | Emergency change criteria are defined | Policy review | Clear criteria — not used for convenience | 🟠 High |
| 3.2 | Emergency changes are formally raised (even if after-the-fact) | Sample test | CR ticket exists for every emergency change | 🔴 Critical |
| 3.3 | Emergency CAB or designated approver signs off | Sample review | Named approver with authority; approval documented | 🔴 Critical |
| 3.4 | Retrospective formal approval within 24–48 hours | Sample review | CAB sign-off within policy SLA | 🟠 High |
| 3.5 | Emergency changes reviewed at next CAB meeting | CAB minutes | All emergency changes tabled at next CAB | 🟠 High |
| 3.6 | Emergency change rate is monitored (not >10% of total) | Volume analysis | EC rate below threshold | Medium |
| 3.7 | Testing is still performed (post-deployment validation) | Sample review | Validation evidence exists | 🟠 High |

```
Emergency Change Rate Formula:
EC Rate = (Emergency Changes / Total Changes) × 100

If EC Rate > 10% → systemic issue (either poor planning or misuse of emergency process)
If EC Rate > 20% → High-risk finding; emergency change process being misused
```

---

### Section 4 — Segregation of Duties in Change Management

| # | Control | Test Method | Expected | Risk |
|---|---------|------------|----------|------|
| 4.1 | Developer cannot self-approve changes | ITSM access review | Approval workflow prevents self-approval | 🔴 Critical |
| 4.2 | Developer does not deploy to production | Access review (prod access) | Developer has no production deployment rights | 🔴 Critical |
| 4.3 | No single person can complete end-to-end change cycle | Process walkthrough | Minimum 2-person involvement (requester + approver + deployer) | 🔴 Critical |
| 4.4 | Production access is time-limited during deployment window | Privileged access review | Access granted only during change window; revoked after | 🟠 High |

---

### Section 5 — Infrastructure & Configuration Changes

| # | Control | Test Method | Expected | Risk |
|---|---------|------------|----------|------|
| 5.1 | Firewall rule changes follow change management | Firewall change log vs. ITSM | All rule changes traceable to approved CR | 🔴 Critical |
| 5.2 | Server configuration changes are change-controlled | Sample: compare baseline vs. actual | No unauthorized configuration drift | 🟠 High |
| 5.3 | Database schema changes follow formal process | DB change log vs. ITSM | All DDL changes traceable to CRs | 🔴 Critical |
| 5.4 | Network topology changes are change-controlled | Network diagram version history | All topology changes have approved CR | 🟠 High |
| 5.5 | Cloud resource provisioning follows change management | Cloud audit logs (Azure Activity / AWS CloudTrail) | No unauthorized resource creation | 🟠 High |

---

### Section 6 — Unauthorized / Out-of-Process Changes

Detecting unauthorized changes is a key objective of change management testing.

**Detection Methods:**

```bash
# 1. Compare number of changes in ITSM vs. changes in system logs
#    ITSM Changes: 142 this quarter
#    Production deployments in CI/CD: 167 this quarter
#    → Gap of 25 = potential unauthorized changes

# 2. Check production deployment logs vs. approved change windows
#    Any deployment outside the approved change window = unauthorized

# 3. Database: compare DDL audit trail vs. approved change tickets
#    SELECT * FROM UNIFIED_AUDIT_TRAIL
#    WHERE ACTION_NAME IN ('CREATE TABLE','ALTER TABLE','DROP TABLE')
#    AND EVENT_TIMESTAMP NOT BETWEEN [approved_window_start] AND [approved_window_end]

# 4. Active Directory: check production OU for unauthorized account creation
#    Get-ADUser -Filter * -SearchBase "OU=Production,DC=domain,DC=com" |
#    Where-Object {$_.Created -gt (Get-Date).AddDays(-90)} |
#    Select Name, Created

# 5. Firewall: compare current ruleset hash with last approved baseline
#    If hash differs without a corresponding approved CR → unauthorized change
```

---

### Section 7 — Change Traceability & Evidence

| # | Control | Test Method | Expected | Risk |
|---|---------|------------|----------|------|
| 7.1 | Changes are traceable from business requirement to deployment | End-to-end trace on sample | CR → Approval → Test → Deploy linked | 🟠 High |
| 7.2 | Change records retained for minimum 1 year | ITSM retention check | Records available for full audit period + 1 year | Medium |
| 7.3 | Deployment scripts / packages are version-controlled | Source control review (Git) | All code in version control; no manual deployment from desktop | 🟠 High |
| 7.4 | Change freeze periods are enforced | Check for deployments during freeze | No production changes during freeze (e.g., year-end, peak periods) | 🟠 High |

---

## Evidence to Collect

| Evidence Item | Source | Format |
|--------------|--------|--------|
| Change management policy | Document repository | PDF |
| CAB charter and meeting minutes | IT Governance | PDF |
| Full change log for audit period | ITSM tool export | CSV |
| Sample: Normal change tickets (25–40) | ITSM tool | Screenshots / PDF |
| Sample: Emergency change tickets (all) | ITSM tool | Screenshots / PDF |
| Emergency change rate calculation | ITSM report | Screenshot |
| Production deployment logs | CI/CD or deployment tool | Export |
| Evidence of testing before deployment | UAT sign-off | PDF |
| Access control: who can approve in ITSM | ITSM admin screenshot | Screenshot |
| Access control: who has production deployment rights | AD / ITSM | CSV |

---

## Common Findings

### Finding CM-001 — Developers Have Production Deployment Access

> **Condition:** Review of production environment access revealed that 8 members of the application development team retained active deployment rights to production servers, including the ability to push code directly to the Finacle application server without going through the CI/CD pipeline or release team.
> **Criteria:** Change Management Policy v2.3 Section 5.2 requires that production deployments be performed exclusively by the designated Release Management team. COBIT BAI06.03 requires that production changes are managed by a separate deployment function from development.
> **Effect:** Developer access to production enables unauthorized, untested code to be deployed directly, circumventing the UAT gate, CAB approval, and audit trail. This eliminates the effectiveness of the change management control entirely and creates risk of code-borne fraud, application errors, and data corruption.
> **Recommendation:** (1) Immediately revoke production deployment access for all 8 developers. (2) Route all deployments through the CI/CD pipeline with mandatory UAT gate before production merge. (3) Implement break-glass access for emergency production access with CISO approval and full session recording.
> **Risk:** 🔴 Critical

---

### Finding CM-002 — Emergency Changes Without Retrospective Approval

> **Condition:** Analysis of the change register identified 31 emergency changes raised during the audit period. Of these, 18 (58%) had no evidence of retrospective formal CAB approval within the 48-hour policy SLA. For 7 of these changes, no formal emergency change ticket was raised at all — the changes were identified from deployment logs but have no corresponding CR in ServiceNow.
> **Criteria:** Change Management Policy v2.3 Section 8.1 requires that all emergency changes receive retrospective approval from the Change Advisory Board within 48 hours. Section 8.3 requires that all changes — including emergency changes — are recorded in the ITSM tool.
> **Effect:** Unrecorded and unapproved changes cannot be traced, reviewed, or investigated. This creates a significant risk that production changes — including potential unauthorized modifications — can occur without any audit trail or management oversight.
> **Recommendation:** (1) For the 7 unrecorded changes — immediately reconstruct CR tickets and seek retrospective CAB approval. (2) For the 18 without retrospective approval — CAB chair must review and approve or flag for investigation. (3) Implement a mandatory 48-hour alert in ServiceNow to flag any EC ticket without retrospective approval. (4) Investigate root cause of 7 unrecorded changes — potential unauthorized activity.
> **Risk:** 🔴 Critical

---

### Finding CM-003 — No Testing Evidence Before CAB Approval

> **Condition:** Testing of 35 sampled normal change requests found that 14 (40%) had no formal testing evidence (UAT results, SIT sign-off, or peer review) attached to the change ticket prior to CAB approval. CAB approval was granted based on the change requester's verbal confirmation that testing was completed.
> **Criteria:** Change Management Policy v2.3 Section 6.2 requires that formal testing evidence, including UAT results signed off by the business owner, must be attached to the change request before CAB can grant deployment approval.
> **Effect:** Without testing evidence, the CAB cannot make an informed approval decision. Changes may be deployed to production with unresolved defects, risking data corruption, service outages, or security vulnerabilities introduced by untested code.
> **Recommendation:** (1) Update the ITSM change request workflow to make testing evidence a mandatory field — the system should prevent CAB submission without an attachment. (2) Conduct awareness training with CAB members — approval without evidence attachment should not be granted. (3) Retrospectively review the 14 identified changes for any production impact.
> **Risk:** 🟠 High

---

## Regulatory Mapping

| Control Area | RBI Cyber Framework | ISO 27001:2022 | COBIT 2019 | NIST CSF |
|---|---|---|---|---|
| Change authorization | §7 — Secure Config | A.8.32 | BAI06.01 | PR.IP-3 |
| Testing before deployment | §7 — SDLC | A.8.25 | BAI07.02 | PR.IP-3 |
| Emergency change controls | §7 — Change Mgmt | A.8.32 | BAI06.03 | PR.IP-3 |
| SoD in change process | §6 — IAM | A.5.3 | APO01.02 | PR.AC-4 |
| Change traceability | §11 — Logging | A.8.15 | MEA02 | DE.CM-1 |

---

*Part of [IS Audit Playbook](../README.md) | See also: [Access Management](access-management.md) | [Backup & Recovery](backup-recovery.md)*
