# NIST Cybersecurity Framework 2.0 — IS Auditor Reference

> **Standard:** NIST Cybersecurity Framework (CSF) Version 2.0  
> **Publisher:** National Institute of Standards and Technology (NIST), USA  
> **Released:** February 2024 (CSF 2.0); original CSF 1.1 published 2018  
> **Applicability:** Originally for US critical infrastructure; now used globally as a cybersecurity risk management reference

---

## Overview

NIST CSF provides a **risk-based, outcome-focused** approach to cybersecurity governance. Unlike ISO 27001 (controls-based) or RBI Framework (banking-specific), NIST CSF is a flexible, high-level framework organized around six core functions. It is widely used by IS auditors as a maturity assessment tool and a common language for communicating cybersecurity posture to executive and board audiences.

---

## CSF 2.0 Core Functions (6)

CSF 2.0 added the **GOVERN** function to the original five, reflecting the increased emphasis on cybersecurity governance.

```
┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐
│ GOVERN  │  │IDENTIFY │  │ PROTECT │  │  DETECT │  │ RESPOND │  │RECOVER  │
│  (GV)   │  │  (ID)   │  │  (PR)   │  │  (DE)   │  │  (RS)   │  │  (RC)   │
└─────────┘  └─────────┘  └─────────┘  └─────────┘  └─────────┘  └─────────┘
```

---

## Function Breakdown for IS Auditors

### GV — Govern (New in 2.0)
Establishes cybersecurity strategy, expectations, policy, and oversight.

| Category | IS Audit Test |
|----------|--------------|
| GV.OC — Organizational Context | Cyber risk appetite defined? Board oversight exists? |
| GV.RM — Risk Management Strategy | Risk management framework formally adopted? |
| GV.RR — Roles & Responsibilities | CISO appointed? Security roles documented? |
| GV.PO — Policy | Security policies Board-approved and current? |
| GV.OV — Oversight | Board reviews cybersecurity posture at least annually? |
| GV.SC — Cybersecurity Supply Chain | Vendor risk management program exists? |

---

### ID — Identify
Understand the organization's assets, risks, and vulnerabilities.

| Category | IS Audit Test |
|----------|--------------|
| ID.AM — Asset Management | Is an IT asset inventory maintained and current? |
| ID.RA — Risk Assessment | Is a formal cyber risk assessment conducted annually? |
| ID.IM — Improvement | Are lessons learned from incidents incorporated? |

---

### PR — Protect
Implement safeguards to limit or contain a cybersecurity event.

| Category | IS Audit Test |
|----------|--------------|
| PR.AA — Identity Management & Authentication | MFA enforced? Least privilege applied? |
| PR.AT — Awareness & Training | Security training conducted? Phishing tests run? |
| PR.DS — Data Security | Encryption at rest and in transit? DLP deployed? |
| PR.PS — Platform Security | Hardening baselines applied? Patch cycle met? |
| PR.IR — Technology Infrastructure Resilience | BCP/DR tested? Redundancy verified? |

---

### DE — Detect
Develop and implement activities to identify cybersecurity events.

| Category | IS Audit Test |
|----------|--------------|
| DE.CM — Continuous Monitoring | SIEM deployed? 24x7 SOC operational? |
| DE.AE — Adverse Event Analysis | Alert tuning in place? Correlation rules active? |

---

### RS — Respond
Take action regarding a detected cybersecurity incident.

| Category | IS Audit Test |
|----------|--------------|
| RS.MA — Incident Management | IR plan exists? Roles defined? Tabletop exercised? |
| RS.AN — Incident Analysis | RCA process defined? Forensic capability exists? |
| RS.CO — Incident Response Reporting | Regulatory reporting SOP (CERT-In 6-hr) exists? |
| RS.MI — Incident Mitigation | Containment playbooks for ransomware, breach? |

---

### RC — Recover
Restore capabilities after a cybersecurity incident.

| Category | IS Audit Test |
|----------|--------------|
| RC.RP — Incident Recovery Plan Execution | DR plan tested? RTO/RPO verified in testing? |
| RC.CO — Incident Recovery Communication | Communication plan for stakeholders exists? |

---

## NIST CSF Maturity Tiers

CSF uses four **Implementation Tiers** to describe the sophistication of cybersecurity risk management:

| Tier | Name | Description |
|------|------|-------------|
| 1 | Partial | Ad hoc, reactive, limited awareness of risk |
| 2 | Risk Informed | Risk-aware but not organization-wide; some policies |
| 3 | Repeatable | Formally defined, consistently implemented, risk-informed |
| 4 | Adaptive | Adaptive, continuously improving, advanced threat response |

> **For IS audit reporting:** Map overall posture to a Tier. Most organizations should target Tier 3. BFSI organizations are expected by RBI to operate at Tier 3–4 for critical systems.

---

## NIST CSF → RBI → ISO 27001 Mapping (Key Controls)

| NIST CSF | RBI Cyber Framework | ISO 27001:2022 |
|----------|--------------------|--------------------|
| GV.OV (Governance) | §3 — CISO, Policy | A.5.1, A.5.2 |
| ID.AM (Asset Mgmt) | §4 — IT Inventory | A.5.9 |
| PR.AA (Access Control) | §6 — IAM | A.5.15–5.18 |
| PR.DS (Data Security) | §8 — Data Protection | A.8.24 |
| PR.PS (Platform Security) | §7 — Hardening, Patching | A.8.8, A.8.9 |
| DE.CM (Monitoring) | §11, §12 — SIEM, SOC | A.8.15, A.8.16 |
| RS.MA (Incident Mgmt) | §13 — CCMP | A.5.24 |
| RS.CO (Reporting) | §13 — 6-hr CERT-In | CERT-In Directions |
| RC.RP (Recovery) | §14 — BCP/DR | A.5.29, A.5.30 |

---

*Part of [IS Audit Playbook](../README.md)*
