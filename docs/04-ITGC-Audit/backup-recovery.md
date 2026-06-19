# ITGC — Backup & Recovery Audit Guide

> **ITGC Domain:** Backup, Recovery & Business Continuity  
> **Audit Scope:** Backup configuration, retention, restoration testing, DR planning and drills  
> **COBIT Objective:** DSS04 (Manage Continuity), BAI09 (Manage Assets)  
> **Regulatory Mapping:** RBI BCP Circular | ISO 27001 A.5.29, A.5.30, A.8.13 | NIST RC.RP, PR.IR

---

## Objective

To assess the adequacy of backup and recovery controls ensuring that data can be restored and business operations resumed within acceptable timeframes following a disruption, data loss, or cyber incident (including ransomware).

---

## Key Concepts

| Term | Definition |
|------|-----------|
| **RPO** (Recovery Point Objective) | Maximum acceptable data loss — "How old can the restored data be?" |
| **RTO** (Recovery Time Objective) | Maximum acceptable downtime — "How quickly must the system be back?" |
| **DR** (Disaster Recovery) | Restoring IT systems after a major disruption |
| **BCP** (Business Continuity Plan) | Maintaining business operations during and after disruption |
| **Air-gap backup** | Backup isolated from production network — critical for ransomware resilience |
| **3-2-1 Rule** | 3 copies of data, on 2 different media types, 1 copy offsite |

---

## Audit Checklist

### Section 1 — BCP/DR Policy & Governance

| # | Control | Test Method | Expected | Risk |
|---|---------|------------|----------|------|
| 1.1 | BCP/DR policy is documented and Board-approved | Document review | Current-year Board approval | 🟠 High |
| 1.2 | RTO and RPO defined for all critical systems | Review BCP document | RTO/RPO per system; aligned to business requirements | 🟠 High |
| 1.3 | BCP/DR owner designated | Policy review | Named owner with authority | Medium |
| 1.4 | DR site is operational and tested | DR site review | Hot/warm/cold site confirmed; equipment current | 🟠 High |
| 1.5 | BCP reviewed and updated at least annually | Document version | Last review < 12 months | Medium |
| 1.6 | Business Impact Analysis (BIA) conducted | BIA document | BIA identifies critical systems and MTD | 🟠 High |

---

### Section 2 — Backup Configuration

| # | Control | Test Method | Expected | Risk |
|---|---------|------------|----------|------|
| 2.1 | Backup schedule meets RPO for each critical system | Backup policy review | Backup frequency ≤ RPO | 🔴 Critical |
| 2.2 | Full, incremental, and differential backups are scheduled | Backup software config | Full weekly + daily incrementals minimum | 🟠 High |
| 2.3 | All critical systems are included in backup scope | Backup inventory vs. asset register | No critical system missed | 🔴 Critical |
| 2.4 | Backups are stored offsite or in secondary data center | Storage location review | Offsite copy confirmed | 🔴 Critical |
| 2.5 | Backups are encrypted | Backup software config | AES-256 encryption enabled | 🟠 High |
| 2.6 | Air-gapped or offline backup exists (ransomware resilience) | Config review | At least one immutable/offline copy | 🔴 Critical |
| 2.7 | Backup retention meets policy and regulatory requirements | Retention settings | Per policy; at least 90 days for financial data | 🟠 High |
| 2.8 | Backup media is protected with access controls | Physical and logical review | Only backup admins have access | 🟠 High |
| 2.9 | Backup jobs are monitored for failures | Monitoring config | Alerts on backup failure; daily review | 🟠 High |
| 2.10 | Database backups include transaction log backups | DB backup config | Log backups between full backups | 🟠 High |

---

### Section 3 — Backup Restoration Testing

**This is the most commonly failing control in backup audits.** Organizations take backups but rarely test restoration.

| # | Control | Test Method | Expected | Risk |
|---|---------|------------|----------|------|
| 3.1 | Backup restoration is tested at defined frequency | Restoration test records | Full restore tested at least annually; partial quarterly | 🔴 Critical |
| 3.2 | Restoration tests cover all critical systems | Review test scope | All Tier 1 systems in annual test | 🔴 Critical |
| 3.3 | Restoration test results are documented | Test report review | Pass/fail, time taken, data verified | 🟠 High |
| 3.4 | Actual RTO is measured and compared to target during test | Test report | Measured RTO ≤ Target RTO | 🔴 Critical |
| 3.5 | Data integrity is verified post-restore | Test report | Checksum or functional verification done | 🟠 High |
| 3.6 | Failed restoration tests are escalated and retested | Process review | Failures trigger remediation + retest | 🔴 Critical |

**Audit Evidence for Backup Testing:**

```
✓ Restoration test plan (pre-test documentation)
✓ Test execution log with timestamps
✓ Data verification evidence (row counts, checksums, functional test results)
✓ Measured RTO vs. target RTO
✓ Sign-off by IT Head and Business Owner
✓ Remediation log for any failures

Red Flags:
✗ No restoration test records found → Critical finding (assumption backups work ≠ evidence)
✗ Last restoration test > 12 months → High finding
✗ Test only done for one system while others untested → High finding
✗ Test report says "successful" but no verification evidence → Not acceptable
```

---

### Section 4 — Disaster Recovery (DR) Testing

| # | Control | Test Method | Expected | Risk |
|---|---------|------------|----------|------|
| 4.1 | Full DR drill conducted at least annually | DR drill report | Annual drill with documented results | 🔴 Critical |
| 4.2 | DR drill includes all critical systems (CBS, payment, email) | Drill scope review | Tier 1 systems all included | 🔴 Critical |
| 4.3 | DR drill tests end-to-end failover (not just technical) | Drill report | Business process tested, not just technical recovery | 🟠 High |
| 4.4 | RTO achieved during DR drill | Drill report | Measured RTO ≤ Target RTO | 🔴 Critical |
| 4.5 | DR drill includes cyber incident scenario (e.g., ransomware) | Drill scope | At least one cyber-triggered DR scenario | 🟠 High |
| 4.6 | Lessons learned from DR drill are documented and actioned | Post-drill report | Action log with owners and due dates | 🟠 High |
| 4.7 | DR drill report presented to Board/Risk Committee | Board minutes | Board-level awareness confirmed | Medium |

---

### Section 5 — Ransomware Resilience

Given the prevalence of ransomware targeting banks and financial institutions, specific controls for ransomware recovery must be tested:

| # | Control | Test Method | Expected | Risk |
|---|---------|------------|----------|------|
| 5.1 | Immutable backups exist (cannot be encrypted or deleted) | Backup config | WORM storage or immutable cloud backup (Azure Blob Immutability) | 🔴 Critical |
| 5.2 | Backup solution has a separate admin credential from production AD | Backup admin review | Backup system NOT joined to production domain | 🔴 Critical |
| 5.3 | Backup system admin account uses MFA | Config review | MFA on backup portal/console | 🔴 Critical |
| 5.4 | Recovery from air-gapped backup has been tested | Test records | Successful recovery from offline copy | 🔴 Critical |
| 5.5 | Ransomware recovery runbook exists | Document review | Step-by-step playbook for ransomware scenario | 🟠 High |

```
Key Ransomware Backup Questions:
- If all domain admin passwords were changed by an attacker,
  can the backup system still be accessed? → If NO → Critical finding
- If all network shares were encrypted, is there an isolated copy? → If NO → Critical finding
- What is the earliest clean recovery point? → Must meet RPO
- How long would full recovery take? → Must meet RTO
```

---

## Evidence to Collect

| Evidence | Source | Format |
|----------|--------|--------|
| BCP/DR policy (Board-approved) | Document management | PDF |
| RTO/RPO schedule per system | BCP document | PDF |
| Backup configuration export | Backup software (Veeam, NetBackup) | Screenshot |
| Backup job success/failure logs (90 days) | Backup console | CSV |
| Backup inventory vs. asset register | Comparison | Spreadsheet |
| Last backup restoration test report | IT Operations | PDF |
| Last DR drill report | IT/BCP team | PDF |
| Immutable backup configuration | Backup console | Screenshot |
| Board minutes referencing DR drill | Board secretariat | PDF |

---

## Common Findings

### Finding BR-001 — No Backup Restoration Testing in 18 Months

> **Condition:** No backup restoration test records were available for the audit period (April 2024–March 2025). The last documented restoration test was in October 2023 (18 months prior), covering only 2 of 11 critical systems. The Core Banking System, Oracle production database, and SWIFT messaging server had no restoration testing evidence at any point in the available records.
> **Criteria:** BCP/DR Policy v1.3 Section 7.2 requires full backup restoration testing at least annually for all Tier 1 critical systems. RBI BCP Guidelines require annual testing of recovery procedures. ISO 27001:2022 A.8.13 requires that backup testing includes verification that data can be effectively restored.
> **Effect:** Untested backups may be corrupt, incomplete, or unrestorable. If a major incident (ransomware, hardware failure, data corruption) required restoration of the CBS, the organization would discover the backup is unusable only at the point of crisis — with no fallback. This creates an existential operational risk.
> **Recommendation:** (1) Immediately schedule restoration tests for all 11 Tier 1 critical systems — complete within 30 days. (2) Implement a quarterly restoration test calendar for critical systems. (3) Establish a formal test report template including measured RTO, data verification evidence, and sign-off. (4) Include backup restoration results in the quarterly IT Steering Committee report.
> **Risk:** 🔴 Critical

---

### Finding BR-002 — No Air-Gapped Backup for Ransomware Resilience

> **Condition:** Review of the backup architecture revealed that all backup copies (primary and secondary) are stored on network-attached storage connected to the production Active Directory domain and accessible via domain admin credentials. No immutable, air-gapped, or offline backup exists. A ransomware attack that obtained domain admin credentials would have the ability to encrypt or delete all backup copies.
> **Criteria:** RBI Cyber Crisis Management Plan (CCMP) requirements and CERT-In advisories on ransomware resilience recommend maintaining at least one isolated, immutable backup copy not accessible from the production network. ISO 27001:2022 A.5.30 (ICT Readiness for Business Continuity) requires recovery capabilities to be resilient to the organization's identified threat scenarios.
> **Effect:** In the event of a ransomware attack — the most prevalent cyber threat to Indian banking in 2024 — all backup copies would be vulnerable to encryption alongside production data. This could render the organization unable to restore operations, resulting in prolonged service disruption, significant financial loss, and regulatory intervention.
> **Recommendation:** (1) Implement immutable backup storage (e.g., Veeam Hardened Repository, Azure Blob immutability, tape with air-gap rotation) within 60 days. (2) Ensure backup system admin credentials are NOT domain accounts — use local accounts with MFA. (3) Test recovery from the isolated copy as part of the next DR drill. (4) Document the ransomware recovery procedure in the CCMP.
> **Risk:** 🔴 Critical

---

## Regulatory Mapping

| Control Area | RBI Framework | ISO 27001:2022 | COBIT 2019 | NIST CSF |
|---|---|---|---|---|
| BCP/DR Policy | RBI BCP Circular | A.5.29 | DSS04.01 | RC.RP-1 |
| Backup Configuration | §8 Data Protection | A.8.13 | DSS04.02 | PR.DS-4 |
| Restoration Testing | RBI BCP Circular | A.8.13 | DSS04.03 | RC.RP-1 |
| DR Drill | RBI BCP Circular §14.3 | A.5.30 | DSS04.04 | RC.RP-1 |
| Ransomware Resilience | RBI CCMP | A.5.30 | DSS04 | RC.RP, PR.IR |
| RTO/RPO Definition | RBI BCP Guidelines | A.5.29 | DSS04.02 | RC.RP-1 |

---

*Part of [IS Audit Playbook](../README.md) | See also: [Incident Management](incident-management.md)*
