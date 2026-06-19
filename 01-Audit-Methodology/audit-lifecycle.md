# IS Audit Lifecycle

> **Scope:** End-to-end Information Systems audit process from engagement setup through reporting and follow-up.  
> **Applicable Standards:** ISACA IS Audit Standards, IIA Standards, ISO 19011

---

## Overview

An IS audit follows a structured lifecycle to ensure objectivity, completeness, and regulatory defensibility. The five phases are:

```
┌─────────────────────────────────────────────────────────────────────┐
│  PHASE 1     PHASE 2       PHASE 3       PHASE 4       PHASE 5      │
│  Planning  → Fieldwork  → Analysis  →  Reporting  →  Follow-up     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Phase 1 — Audit Planning

### 1.1 Engagement Setup

| Activity | Description | Output |
|----------|-------------|--------|
| Define audit objective | What is being audited and why | Audit Charter / Engagement Letter |
| Determine scope | Systems, processes, time period | Scope Statement |
| Identify regulations | Applicable standards (RBI, ISO, CERT-In) | Regulatory Matrix |
| Assess risk | Inherent and control risk | Risk Assessment Document |
| Assign team | Auditor skills vs. audit area | Team Assignment Matrix |
| Notify auditee | Formal communication | Notification Letter |

### 1.2 Preliminary Survey

Before fieldwork begins, gather background information:

- **Organization charts** — understand IT structure, reporting lines
- **Prior audit reports** — open findings, repeat issues
- **Policies and procedures** — IS policy, IT governance documents
- **System inventory** — all in-scope assets, versions, owners
- **Previous incidents** — security events, breaches, RCA reports
- **Vendor/third-party contracts** — outsourced IT components

### 1.3 Audit Program Development

Develop a structured **Audit Program** that maps:

```
Control Objective → Test Procedure → Evidence Required → Responsible Auditor
```

> 💡 **BFSI Note:** For Indian banks, the audit program must also reference RBI IT Framework controls and CERT-In direction compliance requirements.

### 1.4 Risk Assessment Matrix

| Risk Factor | Weight | Score (1–5) | Weighted Score |
|-------------|--------|-------------|----------------|
| Data sensitivity | 30% | — | — |
| Complexity of system | 20% | — | — |
| Prior audit findings | 20% | — | — |
| Regulatory significance | 20% | — | — |
| Change frequency | 10% | — | — |
| **Total** | 100% | — | **Risk Rating** |

**Risk Rating Scale:**
- 4.0–5.0 → **High Risk** — Full audit scope
- 2.5–3.9 → **Medium Risk** — Standard audit scope
- 1.0–2.4 → **Low Risk** — Limited / high-level review

---

## Phase 2 — Fieldwork

### 2.1 Audit Evidence Collection

Four types of audit evidence:

| Type | Examples | Strength |
|------|----------|----------|
| **Physical** | System screenshots, hardware inspection | Strong |
| **Documentary** | Policies, logs, configuration exports | Strong |
| **Testimonial** | Interviews, walkthroughs | Moderate |
| **Analytical** | Data analysis, reconciliation | Moderate–Strong |

### 2.2 Audit Techniques

**Inquiry**
- Conduct structured interviews with system owners, IT managers, and users
- Use open-ended questions; corroborate with documentary evidence
- Document: who was asked, what was asked, what was answered

**Observation**
- Observe actual procedures being performed
- Useful for access control, physical security, change management
- Document: date, observer, what was observed, deviations noted

**Inspection / Examination**
- Review configuration files, policy documents, logs
- Compare actual settings against benchmarks (CIS, vendor hardening guides)

**Re-performance**
- Re-execute a control to verify it works as described
- Example: attempt to access a restricted resource to verify access controls

**Data Analysis / CAATs** (Computer-Assisted Audit Techniques)
- Query databases for access violations, dormant accounts, exceptions
- Use tools: SQL queries, ACL/IDEA, Excel, PowerShell, Python scripts

### 2.3 Walkthrough Procedure

For each key control:

```
Step 1: Obtain written description of the control from management
Step 2: Trace one transaction/event through the entire control process
Step 3: Verify each step matches the described control
Step 4: Document exceptions and deviations
Step 5: Assess design effectiveness (does the control design address the risk?)
Step 6: Assess operating effectiveness (is the control consistently applied?)
```

### 2.4 Sample Selection

| Approach | Use When | Sample Size (General) |
|----------|----------|-----------------------|
| **Statistical Random** | Large population, high reliance | Per AICPA/IIA tables |
| **Judgmental** | Small population, specific risk | 25–100% |
| **100% (Full Population)** | Critical controls, small dataset | All items |
| **Attribute Sampling** | Yes/No controls (access reviews) | Per confidence level |

> 📌 For BFSI audits: RBI and SEBI audits typically require evidence for the entire audit period, not just samples.

---

## Phase 3 — Analysis & Evaluation

### 3.1 Control Effectiveness Assessment

For each control tested:

| Rating | Meaning |
|--------|---------|
| **Effective** | Control is designed and operating effectively |
| **Partially Effective** | Control exists but has gaps in design or operation |
| **Ineffective** | Control is absent, not designed correctly, or consistently fails |
| **Not Applicable** | Control does not apply to this environment |

### 3.2 Root Cause Analysis

For each finding, determine root cause category:

- **People** — Lack of training, negligence, insufficient staffing
- **Process** — Missing or inadequate procedure, no ownership
- **Technology** — Tool limitations, misconfiguration, missing features
- **Policy** — Policy gap, ambiguity, outdated requirement
- **Third-party** — Vendor failure, outsourced process gap

### 3.3 Compensating Controls

If a primary control fails, document whether compensating controls mitigate the risk:

```
Primary Control Failure → Identify Compensating Controls → 
Assess Residual Risk → Document in Finding
```

---

## Phase 4 — Audit Reporting

### 4.1 Finding Structure (PCCER)

Each audit finding must follow the **PCCER format**:

| Component | Question Answered | Example |
|-----------|------------------|---------|
| **Process/Control** | What control area? | User Access Management |
| **Condition** | What did we find? | 47 dormant accounts active beyond 90 days |
| **Criteria** | What should be? | Policy Section 4.2 — disable after 90 days of inactivity |
| **Effect** | What is the impact? | Unauthorized access risk; potential data breach exposure |
| **Recommendation** | What should change? | Disable dormant accounts immediately; implement automated review |

### 4.2 Risk Rating

See [Risk Rating Matrix](risk-rating-matrix.md) for full criteria.

| Rating | Impact | Likelihood | Action Required |
|--------|--------|------------|----------------|
| 🔴 Critical | Catastrophic | High | Immediate remediation |
| 🟠 High | Major | Medium–High | Remediate within 30 days |
| 🟡 Medium | Moderate | Medium | Remediate within 90 days |
| 🟢 Low | Minor | Low | Accept or remediate within 180 days |

### 4.3 Report Structure

1. **Executive Summary** — High-level overview for leadership
2. **Audit Scope and Objectives** — What was and wasn't covered
3. **Audit Methodology** — How the audit was conducted
4. **Overall Audit Opinion** — Satisfactory / Needs Improvement / Unsatisfactory
5. **Summary of Findings** — Tabular summary with risk ratings
6. **Detailed Findings** — Full PCCER for each observation
7. **Management Responses** — Auditee's agreed actions and timelines
8. **Appendices** — Evidence listings, tools used, glossary

### 4.4 Audit Opinion Categories

| Opinion | Meaning |
|---------|---------|
| **Satisfactory** | Controls are adequate and operating effectively |
| **Needs Improvement** | Some control gaps exist; risk is manageable with action |
| **Unsatisfactory** | Significant control failures; unacceptable risk exposure |
| **Advisory** | No formal opinion; observation-based review only |

---

## Phase 5 — Follow-Up

### 5.1 Tracking Open Findings

Maintain a **Finding Tracker** with:

| Field | Description |
|-------|------------|
| Finding ID | Unique reference (e.g., IS-2024-AD-001) |
| Finding Title | Short description |
| Risk Rating | Critical / High / Medium / Low |
| Auditee Owner | Responsible person |
| Agreed Action | What will be done |
| Due Date | Committed remediation date |
| Status | Open / In Progress / Closed / Risk Accepted |
| Evidence of Closure | Document reference confirming remediation |

### 5.2 Closure Criteria

A finding is considered **closed** when:

1. Auditee provides evidence of remediation
2. Auditor validates the evidence (re-test or review)
3. Evidence is documented and linked to the finding
4. No residual gap exists

> ⚠️ **Never close a finding based on management assertion alone — always validate with evidence.**

### 5.3 Escalation Path

```
Finding Open > 30 days past due date
    → Reminder to Process Owner
Finding Open > 60 days past due date
    → Escalate to Department Head
Finding Open > 90 days past due date
    → Escalate to CISO / CIO
Finding Open > 120 days (Critical/High)
    → Report to Audit Committee / Board
```

---

## Audit Documentation Standards

All audit workpapers must meet the **COMPLETE** standard:

| Letter | Requirement |
|--------|------------|
| **C** | Complete — covers all objectives |
| **O** | Objective — free from bias |
| **M** | Material — relevant, not excessive |
| **P** | Pertinent — supports the finding |
| **L** | Logical — organized and clear |
| **E** | Evidential — based on factual observation |
| **T** | Timely — prepared promptly after work |
| **E** | Easy to review — navigable with index |

---

## Regulatory Alignment

| Audit Phase | RBI / CERT-In Reference |
|------------|------------------------|
| Planning | RBI IT Framework Annex — IT Audit Guidelines |
| Evidence Collection | CERT-In Directions — Log Retention (180 days minimum) |
| Finding Classification | RBI Cyber Framework — Risk Tiering |
| Reporting | RBI Circular on IT Audit — Board Reporting |
| Follow-up | RBI Master Direction — Closure Certification |

---

*Last Updated: 2025 | Part of [IS Audit Playbook](../README.md)*
