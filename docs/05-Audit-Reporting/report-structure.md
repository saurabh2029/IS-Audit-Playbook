# IS Audit Report Structure

> **Purpose:** Standard structure for a formal Information Systems Audit Report  
> **Standard:** IIA International Standards for the Professional Practice of Internal Auditing (IPPF), ISACA IS Audit Guidelines

---

## Overview

Every formal IS audit report follows a consistent structure, regardless of the asset being audited. This ensures comparability across audit cycles, clarity for senior management and Board readers, and compliance with professional standards.

---

## Full Report Structure

```
1.  Report Header / Cover Page
2.  Transmittal Letter
3.  Executive Summary
4.  Report Background
    4.1 Audit Objectives
    4.2 Audit Scope
    4.3 Audit Period
    4.4 Limitations & Exclusions
5.  Audit Methodology
6.  Overall Audit Opinion
7.  Summary of Findings
8.  Detailed Findings (PCCER format)
9.  Management Responses
10. Recommendations Tracker
11. Appendices
```

---

## Section-by-Section Guide

---

### 1. Report Header / Cover Page

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        INFORMATION SYSTEMS AUDIT REPORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Audit Title:     [e.g., Active Directory Security Audit]
Audit Reference: [e.g., IS-AUDIT-2025-AD-001]
Auditee:         [Department / System Owner]
Audit Period:    [From Date] to [To Date]
Report Date:     [DD-MMM-YYYY]

Prepared by:     [Lead Auditor Name], [Designation]
Reviewed by:     [Senior Auditor / IS Audit Manager]
Approved by:     [CISO / Chief Internal Auditor]

CLASSIFICATION: CONFIDENTIAL — FOR INTERNAL USE ONLY

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

### 2. Transmittal Letter

```
[Letterhead / Organization Name]
Date: [DD-MMM-YYYY]

To:
[Name of Auditee / IT Head / CISO]
[Department]
[Organization]

Dear [Name],

Subject: Information Systems Audit Report — [Audit Title]

Please find enclosed the Information Systems Audit Report for the 
audit of [system/process] conducted during [audit period].

The audit was conducted in accordance with ISACA IS Audit Standards 
and the organization's Internal Audit Charter. The objective was to 
assess [brief objective statement].

The detailed findings and recommendations are presented in this 
report. We request management responses to all findings by 
[DD-MMM-YYYY] to enable us to finalize the report and present it 
to the Audit Committee.

We would like to thank the [department] team for their cooperation 
during the audit.

Yours sincerely,

[Lead Auditor Name]
[Designation]
[IS Audit Department]
```

---

### 3. Executive Summary

**Purpose:** 1–2 page summary for senior leadership (Board, CISO, CIO) who may not read the full report.

**Must include:**
- Overall audit opinion in a single, clear statement
- Number of findings by risk rating (summary table)
- 2–3 most significant findings in plain language
- Key recommendation areas
- Whether this is an improvement from prior audit cycle

**Template:**

```
EXECUTIVE SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

OVERALL OPINION:    [SATISFACTORY / NEEDS IMPROVEMENT / UNSATISFACTORY]

The IS Audit team conducted an audit of [subject] during [period]. 
The objective was to assess [objective]. The audit covered [scope 
summary].

KEY FINDINGS:
[2–3 sentences on the most significant risks identified]

FINDINGS SUMMARY:
┌──────────────┬───────┐
│ Risk Rating  │ Count │
├──────────────┼───────┤
│ 🔴 Critical  │   X   │
│ 🟠 High      │   X   │
│ 🟡 Medium    │   X   │
│ 🟢 Low       │   X   │
├──────────────┼───────┤
│ TOTAL        │   X   │
└──────────────┴───────┘

PRIORITY ACTIONS:
1. [Most urgent remediation needed]
2. [Second priority]
3. [Third priority]

COMPARISON TO PRIOR AUDIT:
[Improvement / Deterioration / New scope — brief statement]
```

---

### 4. Report Background

#### 4.1 Audit Objectives

State what the audit was designed to achieve:

```
The objectives of this audit were to:

1. Assess the adequacy and operating effectiveness of [control area] 
   controls in [system/department].

2. Evaluate compliance with [applicable policies/regulations], 
   including [RBI Cybersecurity Framework / ISO 27001 / CERT-In 
   Directions 2022] as applicable.

3. Identify control gaps that represent a risk to [data 
   confidentiality / integrity / availability / compliance].

4. Provide actionable recommendations to management to address 
   identified gaps.
```

#### 4.2 Audit Scope

Be explicit about what was and was not covered:

```
IN SCOPE:
- [System Name] version [X] hosted at [Location/DC]
- The period [From] to [To]
- [Specific domains covered: e.g., Access Management, Configuration, 
  Logging]
- [Specific user populations or data sets sampled]

OUT OF SCOPE:
- Physical security of data center facilities
- Third-party systems not directly managed by [Organization]
- [Any specific areas excluded and why]
```

#### 4.3 Limitations

Document constraints that affected the audit:

```
LIMITATIONS:
- [System X] logs prior to [date] were not available due to a 
  retention policy of 30 days. This limited the audit period for 
  log-based testing.

- The audit was conducted on a read-only basis. No penetration 
  testing or active exploitation attempts were performed.

- Interview findings are based on management representations and 
  have been corroborated with documentary evidence where possible.
```

---

### 5. Audit Methodology

```
METHODOLOGY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

This audit was conducted in accordance with:
- ISACA IS Audit and Assurance Standards
- IIA International Standards for Internal Auditing (IPPF)
- [Organization] Internal Audit Charter and Policy

The audit approach included:

1. PLANNING: Review of prior audit findings, regulatory requirements, 
   and system documentation to develop a risk-based audit program.

2. FIELDWORK: 
   - Walkthroughs with system owners and process owners
   - Inspection of configuration, policies, and logs
   - Re-performance of controls
   - Data analysis using [SQL / PowerShell / SIEM queries]
   - Sample testing (sample sizes determined by risk level)

3. ANALYSIS: Evaluation of evidence against defined criteria. 
   Root cause analysis for identified gaps.

4. REPORTING: Findings documented in PCCER format. Draft report 
   shared with management for factual accuracy review before issue.

STANDARDS AND CRITERIA REFERENCED:
- RBI Cybersecurity Framework (2016)
- CERT-In Directions (April 2022)
- ISO/IEC 27001:2022
- CIS Benchmarks (applicable versions)
- [Organization] IT Security Policy v[X.X]
```

---

### 6. Overall Audit Opinion

```
OVERALL AUDIT OPINION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Opinion: NEEDS IMPROVEMENT          [or Satisfactory / Unsatisfactory]

Based on the fieldwork performed, the IS Audit team concludes that 
the [system/process] has [material/some/no material] weaknesses in 
the design and/or operating effectiveness of key controls.

[1–2 sentences elaborating on the opinion basis]

The most significant concerns are in the areas of [e.g., privileged 
access management and audit logging], where [X] Critical and [X] 
High-risk findings were identified that require immediate attention.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
OPINION SCALE:
SATISFACTORY:       Controls are adequate and operating effectively.
                    Minor gaps exist but do not represent material risk.

NEEDS IMPROVEMENT:  Control gaps exist. Some controls are either not
                    designed adequately or not operating consistently.
                    Unacceptable risk if not remediated.

UNSATISFACTORY:     Material control failures identified. Significant
                    unacceptable risk to the organization. Escalation
                    to Board/Risk Committee required.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

### 7. Summary of Findings

```
SUMMARY OF FINDINGS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

┌──────┬──────────────────────────────────────────┬──────────┬──────────────┐
│  ID  │ Finding Title                            │ Rating   │ Status       │
├──────┼──────────────────────────────────────────┼──────────┼──────────────┤
│ F-01 │ Privileged Access — 23 Domain Admin      │ Critical │ Open         │
│      │ accounts including service accounts      │          │              │
├──────┼──────────────────────────────────────────┼──────────┼──────────────┤
│ F-02 │ Audit Log Retention — 30 days vs.        │ Critical │ Open         │
│      │ CERT-In mandated 180 days                │          │              │
├──────┼──────────────────────────────────────────┼──────────┼──────────────┤
│ F-03 │ Terminated Employee Accounts — 12        │ Critical │ Open         │
│      │ accounts active post-separation          │          │              │
├──────┼──────────────────────────────────────────┼──────────┼──────────────┤
│ F-04 │ Default Oracle Accounts Not Locked       │ High     │ Open         │
├──────┼──────────────────────────────────────────┼──────────┼──────────────┤
│ F-05 │ No Periodic Privileged Access Review     │ High     │ Open         │
├──────┼──────────────────────────────────────────┼──────────┼──────────────┤
│ F-06 │ Firewall Management Access Unrestricted  │ Critical │ Open         │
├──────┼──────────────────────────────────────────┼──────────┼──────────────┤
│ F-07 │ Password Policy — Min Length 8 chars     │ High     │ Open         │
├──────┼──────────────────────────────────────────┼──────────┼──────────────┤
│ F-08 │ RDP Exposed to Internet (Port 3389)      │ Critical │ Open         │
├──────┼──────────────────────────────────────────┼──────────┼──────────────┤
│ F-09 │ MSSQL xp_cmdshell Enabled                │ Critical │ Open         │
├──────┼──────────────────────────────────────────┼──────────┼──────────────┤
│ F-10 │ DR Test Not Conducted in Last 18 Months  │ High     │ Open         │
└──────┴──────────────────────────────────────────┴──────────┴──────────────┘

TOTALS:  Critical: 6   High: 3   Medium: 0   Low: 0
```

---

### 8. Detailed Findings (PCCER Format)

Each finding follows this structure:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FINDING F-01
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Title:          [Short descriptive title]
Risk Rating:    🔴 CRITICAL / 🟠 HIGH / 🟡 MEDIUM / 🟢 LOW
Control Area:   [ITGC Domain / System / Process]
Reference:      [Policy / Regulation cited]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

PROCESS / CONTROL:
[The control objective being tested and the domain it belongs to]

CONDITION (What was found):
[Factual, specific, quantified observation based on evidence]

CRITERIA (What should exist):
[Specific policy section, regulation, or standard that defines 
the expected control]

EFFECT (Business impact):
[Actual or potential consequence if condition persists — financial, 
compliance, reputational, or operational]

RECOMMENDATION:
[Specific, actionable steps — immediate and long-term]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MANAGEMENT RESPONSE:
Agreed / Partially Agreed / Not Agreed

Action Plan:
[Management's committed remediation steps]

Owner:          [Name, Designation]
Target Date:    [DD-MMM-YYYY]

Comments:
[Any clarification or context from management]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

### 9. Recommendations Tracker

```
OPEN RECOMMENDATIONS TRACKER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

┌──────┬──────────────────────────┬──────────┬────────────────┬─────────────┬────────┐
│  ID  │ Recommendation           │ Owner    │ Target Date    │ Status      │ Notes  │
├──────┼──────────────────────────┼──────────┼────────────────┼─────────────┼────────┤
│ F-01 │ Reduce DA accounts to ≤5 │ IT Mgr   │ 31-Jan-2025    │ Open        │        │
│ F-02 │ Extend log retention     │ CISO     │ 28-Feb-2025    │ In Progress │        │
│ F-03 │ Disable ex-employee accs │ IAM Team │ 07-Jan-2025    │ Open        │        │
│ ...  │ ...                      │ ...      │ ...            │ ...         │        │
└──────┴──────────────────────────┴──────────┴────────────────┴─────────────┴────────┘
```

---

### 10. Appendices

**Appendix A — Audit Team**

| Role | Name | Qualification |
|------|------|---------------|
| Lead Auditor | [Name] | CISM, CISA |
| Auditor | [Name] | CEH, ISO 27001 LA |
| Reviewer | [Name] | CISM, CRISC |

**Appendix B — Documents Reviewed**

| # | Document | Version | Date |
|---|----------|---------|------|
| 1 | IT Security Policy | v3.2 | Apr 2024 |
| 2 | Access Management Policy | v2.1 | Jan 2024 |
| 3 | Network Security Policy | v1.4 | Jun 2024 |

**Appendix C — Abbreviations**

| Abbreviation | Full Form |
|-------------|-----------|
| CERT-In | Indian Computer Emergency Response Team |
| CISM | Certified Information Security Manager |
| COBIT | Control Objectives for Information and Related Technologies |
| ITGC | IT General Controls |
| MFA | Multi-Factor Authentication |
| PCCER | Process-Condition-Criteria-Effect-Recommendation |
| RBI | Reserve Bank of India |

---

## Distribution List

```
REPORT DISTRIBUTION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Primary Recipients:
  □ Chief Information Security Officer (CISO)
  □ Chief Technology Officer (CTO) / IT Head
  □ Process / System Owner (Auditee)

Secondary Recipients (Summary Only):
  □ Board Audit Committee
  □ Chief Risk Officer (CRO)
  □ Chief Internal Auditor (CIA)

External (if regulatory):
  □ RBI (Annual IT Audit Form — via Statutory Auditor)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

*Part of [IS Audit Playbook](../README.md) | See also: [Finding Writing Guide](finding-writing-guide.md) | [Risk Rating Matrix](risk-rating-matrix.md)*
