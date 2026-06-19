# RBI Cybersecurity Framework — IS Auditor Reference

> **Issued by:** Reserve Bank of India (RBI)  
> **Primary Circular:** RBI/2015-16/418 — Cyber Security Framework in Banks (June 2016)  
> **Supplementary:** RBI IT Framework for NBFCs (2017), RBI Guidelines on Digital Lending, RBI Cloud Computing Circular (2023)  
> **Applicable to:** All Scheduled Commercial Banks, Urban Co-operative Banks, NBFCs (Tier-based)

---

## Overview

The RBI Cybersecurity Framework mandates that banks establish a **robust cybersecurity posture** commensurate with their size, risk profile, and digital footprint. Unlike ISO 27001 (which is voluntary), the RBI framework is **legally mandated** for Indian banks — non-compliance can attract regulatory action including fines and supervisory review.

---

## Key Regulatory Documents

| Document | Issued | Scope |
|----------|--------|-------|
| RBI Cyber Security Framework (2016) | Jun 2016 | All SCBs |
| RBI Master Direction — IT Framework for Banks | Apr 2021 | SCBs and UCBs |
| RBI IT Framework for NBFCs | Jun 2017 | NBFCs above threshold |
| CERT-In Directions under IT Act | Apr 2022 | All organizations |
| RBI Guidelines on Digital Lending | Sep 2022 | Digital lenders |
| RBI Cloud Computing Guidelines | Apr 2023 | Banks using cloud |
| RBI Outsourcing Master Direction | Oct 2023 | All banks and NBFCs |

---

## Framework Structure — 5 Pillars

The RBI framework is organized around five security pillars, each with specific controls that auditors test:

```
┌──────────────────────────────────────────────────────────┐
│  1. PREPARE/IDENTIFY   2. PROTECT   3. DETECT            │
│  4. RESPOND            5. RECOVER                        │
└──────────────────────────────────────────────────────────┘
```

---

## Pillar 1 — Prepare / Identify

### §3 — Cyber Security Policy

**What is required:**
- Board-approved Cyber Security Policy (reviewed annually)
- CISO appointment reporting to Board / Risk Committee
- Cyber risk formally included in Enterprise Risk Management

**Audit tests:**
- Verify policy document exists, is current-year approved, and Board minutes record approval
- Verify CISO has adequate authority and reports at least quarterly to Board/Risk Committee
- Review if cyber risk register exists and is updated

---

### §4 — IT Inventory and Asset Management

**What is required:**
- Comprehensive IT asset inventory including hardware, software, network components
- Classification of assets by criticality
- Identification of Critical Information Infrastructure (CII)

**Audit tests:**
- Obtain asset inventory; test completeness by comparing to network scan results
- Verify critical assets are classified and have designated owners
- Check if CMDB is maintained and current

---

## Pillar 2 — Protect

### §5 — Network Security

| Control | Requirement | Audit Test |
|---------|-------------|-----------|
| §5.1 | Network segmentation — DMZ, internal, management zones | Review network architecture diagram; test zone separation via firewall policy review |
| §5.2 | Perimeter firewalls with restrict-by-default policy | Firewall ruleset review (see [Firewall Audit](../03-Asset-Audit-Guides/Network-Devices/firewall-audit.md)) |
| §5.3 | IDS/IPS deployed at network perimeter | Verify IPS deployment; test signature currency and alert tuning |
| §5.4 | DLP (Data Loss Prevention) for outbound traffic | Verify DLP policy coverage; test against critical data types |
| §5.5 | Secure remote access (VPN + MFA) | Verify VPN config; confirm MFA enforced; no split tunneling for critical access |
| §5.6 | Wi-Fi separated from production network | Network diagram review; SSID segregation confirmed |

---

### §6 — Identity & Access Management

| Control | Requirement | Audit Test |
|---------|-------------|-----------|
| §6.1 | IAM policy covering provisioning, deprovisioning, review | Review IAM policy; test samples from joiner/mover/leaver process |
| §6.2 | Unique IDs — no shared accounts | Scan for generic accounts (admin, helpdesk, test) |
| §6.3 | Strong authentication (MFA) for all remote and privileged access | Verify MFA configuration on VPN, admin consoles, privileged accounts |
| §6.4 | Privileged access restricted; admin accounts separate from regular accounts | Review AD privileged groups; confirm separation of admin and user IDs |
| §6.5 | Periodic access review (minimum quarterly for privileged) | Obtain access review records; verify sign-off by data owners |
| §6.6 | Segregation of duties for critical functions | Review role conflicts in CBS, SWIFT, payment systems |

---

### §7 — Secure Configuration

| Control | Requirement | Audit Test |
|---------|-------------|-----------|
| §7.1 | Hardening baseline for all device types | Verify hardening SOP exists; test sample of devices against CIS benchmark |
| §7.2 | Patch management — critical patches within 30 days | Review patch management policy; sample test patch application dates |
| §7.3 | Vulnerability Assessment & Penetration Testing (VAPT) | Verify VAPT conducted at least annually; review scope and remediation tracking |
| §7.4 | Secure SDLC for in-house applications | Review SDLC policy; check if code reviews and SAST/DAST are done |

---

### §8 — Data Protection

| Control | Requirement | Audit Test |
|---------|-------------|-----------|
| §8.1 | Encryption of sensitive data at rest | Verify TDE/encryption on critical databases and storage |
| §8.2 | Encryption in transit (TLS 1.2+) | Test cipher suites on web applications and APIs |
| §8.3 | Data classification policy | Review policy; test if classifications are applied to sample datasets |
| §8.4 | Data masking in non-production | Verify masking controls in UAT/dev environments; spot-check for real customer data |
| §8.5 | Secure disposal of data and media | Review media disposal policy; verify certificates of destruction |

---

## Pillar 3 — Detect

### §11 — Log Management and Monitoring

This is the most frequently cited section in RBI audit observations.

| Control | Requirement | Audit Test |
|---------|-------------|-----------|
| §11.1 | Centralized log management (SIEM) | Verify SIEM deployment; confirm critical sources (AD, DB, FW, CBS) are ingested |
| §11.2 | Log retention minimum 180 days | Confirm SIEM retention policy; verify actual retention |
| §11.3 | Audit trail for financial transactions | Verify CBS audit logs are complete, tamper-proof, and monitored |
| §11.4 | NTP synchronization across all devices | Verify NTP config on sample devices; ensure log timestamps are consistent |
| §11.5 | Log integrity controls | Confirm logs cannot be deleted by regular users; verify hash/signature on critical logs |

> ⚠️ **Critical note:** CERT-In Directions (2022) mandate **180-day log retention** for all ICT systems. This supersedes any shorter retention periods. Non-compliance is a direct regulatory breach.

---

### §12 — Security Operations & Monitoring

| Control | Requirement | Audit Test |
|---------|-------------|-----------|
| §12.1 | 24x7 Security Operations Centre (SOC) | Verify SOC operational hours; check escalation matrix |
| §12.2 | Threat Intelligence feeds integrated into SOC | Verify TI feed subscriptions; test if IoCs are operationalized in SIEM |
| §12.3 | Anomaly detection and alerting | Review SIEM use cases; verify alerts exist for critical event types |
| §12.4 | User and Entity Behavior Analytics (UEBA) | Verify UEBA or equivalent capability (optional but recommended) |

---

## Pillar 4 — Respond

### §13 — Cyber Crisis Management

| Control | Requirement | Audit Test |
|---------|-------------|-----------|
| §13.1 | Cyber Crisis Management Plan (CCMP) documented | Verify CCMP document; check Board approval and annual review |
| §13.2 | Incident response procedures defined | Review IR runbooks; verify coverage for ransomware, data breach, insider threat |
| §13.3 | Cyber incident reporting to RBI within 6 hours | Verify process for RBI reporting; test against past incidents |
| §13.4 | CERT-In reporting within 6 hours of detection | Verify CERT-In reporting SOP; confirm designated CERT-In point of contact |

> ⚠️ **CERT-In Directions 2022** require reporting of cybersecurity incidents to CERT-In **within 6 hours** of detection. This is a hard regulatory deadline with no grace period.

---

## Pillar 5 — Recover

### §14 — Business Continuity and Disaster Recovery

| Control | Requirement | Audit Test |
|---------|-------------|-----------|
| §14.1 | BCP/DR policy approved by Board | Verify BCP/DR policy document and Board sign-off |
| §14.2 | RTO and RPO defined for critical systems | Obtain RTO/RPO schedule; verify alignment with business requirements |
| §14.3 | DR drill conducted at least annually | Obtain DR drill report; verify test scenarios included cyber incidents |
| §14.4 | Backup tested — recovery verification | Verify backup restoration tests; confirm frequency and scope |
| §14.5 | Air-gapped / offline backups for ransomware | Verify at least one offline copy exists for critical data |

---

## RBI Reporting Requirements for IS Auditors

### Internal Audit Requirements

| Requirement | Frequency | Recipients |
|-------------|-----------|-----------|
| IS Audit Report — Critical Systems | Annual | Board Audit Committee |
| VAPT Report and Remediation Status | Annual (minimum) | IT Steering Committee |
| Cyber Security Posture Assessment | Annual | Risk Committee, Board |
| Incident Summary Report | Quarterly | IT Steering Committee |
| Open Audit Finding Tracker | Quarterly | IT Head, Board Audit Committee |

### Regulatory Reporting (Banks)

| Report | Frequency | Submitted to |
|--------|-----------|-------------|
| Cyber Security Incident Report | Within 6 hours of detection | CERT-In, RBI |
| Annual Cyber Security Return | Annual | RBI |
| IT Audit Report (Form IT-I) | Annual | RBI (via statutory auditor) |
| VAPT Report | Annual | RBI (on request) |

---

## Common Audit Findings Mapped to RBI Framework

| Finding Type | RBI Section | Typical Risk Rating |
|-------------|------------|---------------------|
| No CISO appointment | §3 | 🔴 Critical |
| Cyber policy not Board-approved | §3 | 🔴 Critical |
| Shared privileged accounts | §6.2 | 🔴 Critical |
| No MFA for admin access | §6.3 | 🔴 Critical |
| SIEM not deployed | §11.1 | 🔴 Critical |
| Log retention < 180 days | §11.2 | 🔴 Critical |
| No 24x7 SOC | §12.1 | 🟠 High |
| VAPT not conducted | §7.3 | 🟠 High |
| No DR drill in last 12 months | §14.3 | 🟠 High |
| Patch cycle > 30 days for critical | §7.2 | 🟠 High |
| No data classification | §8.3 | 🟡 Medium |
| Production data in non-prod | §8.4 | 🟠 High |

---

## Quick Reference — Key RBI Timelines

| Obligation | Deadline |
|-----------|---------|
| Incident report to CERT-In | Within 6 hours of detection |
| Incident report to RBI | Within 6 hours of detection |
| Critical patch deployment | Within 30 days of release |
| Log retention | Minimum 180 days (rolling) |
| DR drill | Minimum annual |
| VAPT | Minimum annual |
| Cyber policy review | Annual (Board-approved) |
| Privileged access review | Minimum quarterly |
| Annual IS Audit | Annual (before Board Audit Committee) |

---

*Part of [IS Audit Playbook](../README.md) | See also: [CERT-In Directions](CERT-In-Directions.md) | [ISO 27001](ISO-27001.md)*
