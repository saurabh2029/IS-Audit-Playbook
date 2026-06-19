# ITGC — Incident Management Audit Guide

> **ITGC Domain:** Security Incident & Event Management  
> **Audit Scope:** Incident detection, logging, response, escalation, regulatory reporting, and post-incident review  
> **COBIT Objective:** DSS02 (Manage Service Requests & Incidents)  
> **Regulatory Mapping:** RBI Cyber Framework §13 | CERT-In Directions 2022 | ISO 27001 A.5.24–A.5.26 | NIST RS family

---

## Objective

To assess whether the organization can effectively detect, respond to, contain, and recover from security incidents — and whether mandatory regulatory reporting obligations (6-hour CERT-In timeline) are met.

---

## Audit Checklist

### Section 1 — Incident Management Policy & Governance

| # | Control | Test Method | Expected | Risk |
|---|---------|------------|----------|------|
| 1.1 | Incident Response (IR) policy is documented and approved | Document review | CISO/Board-approved IR policy | 🟠 High |
| 1.2 | Incident classification scheme is defined | Policy review | Severity P1–P4 or Critical/High/Medium/Low defined | 🟠 High |
| 1.3 | IR roles and responsibilities are defined | Policy + org chart | CISO, IR Lead, Legal, PR, Technical roles named | 🟠 High |
| 1.4 | Cyber Crisis Management Plan (CCMP) exists | Document review | CCMP Board-approved and current-year reviewed | 🔴 Critical |
| 1.5 | IR contact list is current | Contact directory | Key contacts verified within last 6 months | Medium |
| 1.6 | IR policy covers all incident types (ransomware, breach, DDoS, insider) | Policy review | Specific playbooks or procedures per incident type | 🟠 High |

---

### Section 2 — Incident Detection & Logging

| # | Control | Test Method | Expected | Risk |
|---|---------|------------|----------|------|
| 2.1 | All incidents are logged in a ticketing system | ITSM review | Incident ticket for every recorded event | 🔴 Critical |
| 2.2 | Detection sources feed into centralized SIEM | SIEM config review | AD, FW, DB, EDR, CBS all ingested | 🔴 Critical |
| 2.3 | SIEM alert rules cover critical attack scenarios | SIEM use case review | Brute-force, lateral movement, C2 comms, data exfiltration | 🟠 High |
| 2.4 | 24x7 SOC monitoring is in place | SOC roster / SLA | No unmonitored windows | 🔴 Critical |
| 2.5 | Mean Time to Detect (MTTD) is tracked | SOC metrics | MTTD tracked; target defined | 🟠 High |
| 2.6 | Security alerts have defined SLA for acknowledgment | SOC SLA | P1 alerts acknowledged within 15 minutes | 🟠 High |

---

### Section 3 — Incident Response Process

| # | Control | Test Method | Expected | Risk |
|---|---------|------------|----------|------|
| 3.1 | Incident response follows defined lifecycle (Detect → Contain → Eradicate → Recover → Review) | Process walkthrough | Defined and documented steps | 🟠 High |
| 3.2 | Containment actions are documented in incident ticket | Sample test — past incidents | Containment steps logged with timestamps | 🟠 High |
| 3.3 | Escalation matrix is followed | Sample test — P1/P2 incidents | CISO/CTO/MD escalated per matrix | 🟠 High |
| 3.4 | Evidence is preserved for forensics (chain of custody) | Process review | Forensic imaging or log preservation documented | 🟠 High |
| 3.5 | Mean Time to Respond (MTTR) is tracked | SOC metrics | MTTR tracked; within defined SLA | 🟠 High |
| 3.6 | Legal and compliance notified for data breach incidents | Process review | Notification to Legal/Compliance documented | 🔴 Critical |

---

### Section 4 — Regulatory Reporting Compliance

This section directly tests CERT-In Directions 2022 compliance — one of the most critical regulatory obligations.

| # | Control | Test Method | Expected | Risk |
|---|---------|------------|----------|------|
| 4.1 | CERT-In reporting SOP exists with 6-hour timeline | Policy review | Clear procedure with 6-hour hard deadline | 🔴 Critical |
| 4.2 | Designated CERT-In Point of Contact is appointed | POC register | Named individual with contact details | 🟠 High |
| 4.3 | CERT-In contact details are current | Verify email/portal | incident@cert-in.org.in accessible | Medium |
| 4.4 | RBI incident reporting SOP exists | Policy review | RBI reporting procedure documented | 🔴 Critical |
| 4.5 | Past reportable incidents were reported within 6 hours | Review incident history vs. CERT-In report logs | 100% compliance with 6-hour deadline | 🔴 Critical |
| 4.6 | Staff are trained on CERT-In reporting obligations | Training records | IR team trained; awareness of 6-hour rule | 🟠 High |
| 4.7 | Tabletop exercise included CERT-In reporting step | Exercise report | CERT-In notification tested in last exercise | 🟠 High |

**Audit Test for Past Incident Reporting:**

```
1. Obtain: ITSM incident list for audit period — all P1/P2 incidents
2. Obtain: CERT-In incident report logs (submission receipts or email copies)
3. For each potentially reportable incident:
   - Determine if it meets CERT-In reporting criteria
     (unauthorized access, malware, data breach, DDoS, etc.)
   - If yes: verify a report was submitted to CERT-In
   - Check submission timestamp vs. incident detection timestamp
   - Gap > 6 hours = non-compliance = Critical finding

Common gap: Organizations classify incidents as "internal" to avoid reporting.
Test: Cross-check EDR alerts, SIEM detections, and SOC tickets for
any event that resembles CERT-In-reportable criteria.
```

---

### Section 5 — Post-Incident Review

| # | Control | Test Method | Expected | Risk |
|---|---------|------------|----------|------|
| 5.1 | Root Cause Analysis (RCA) conducted for all P1/P2 incidents | Sample test | RCA documented within 5 business days | 🟠 High |
| 5.2 | Lessons learned are documented | RCA reports | Specific lessons, not just incident summary | 🟠 High |
| 5.3 | Action items from PIR are tracked to closure | Action log | Named owner + due date + closure evidence | 🟠 High |
| 5.4 | IR playbooks updated based on new incident patterns | Playbook version history | Evidence of updates following major incidents | Medium |
| 5.5 | Major incident summary reported to senior management | Management report | Quarterly or per-incident report to CISO/Board | 🟠 High |

---

### Section 6 — Tabletop Exercises & IR Drills

| # | Control | Test Method | Expected | Risk |
|---|---------|------------|----------|------|
| 6.1 | Tabletop exercise conducted at least annually | Exercise records | Annual exercise with documented outcomes | 🟠 High |
| 6.2 | Exercise tests realistic scenario (ransomware, data breach, insider) | Exercise report | Scenario relevant to organization's threat profile | 🟠 High |
| 6.3 | Exercise includes business stakeholders (not just IT) | Participant list | Legal, HR, Communications, Business heads included | 🟠 High |
| 6.4 | Exercise tests regulatory reporting decision and timing | Exercise report | CERT-In 6-hour reporting step included | 🟠 High |
| 6.5 | Gaps identified in exercise are tracked to closure | Action log | All gap items have owners and due dates | Medium |

---

## Incident Severity Classification Reference

| Severity | Definition | Response SLA | Escalation |
|----------|-----------|-------------|-----------|
| **P1 — Critical** | Active breach / ransomware / SWIFT fraud / data exfiltration | Acknowledge: 15 min; Contain: 1 hr | CISO, CTO, MD, Legal, RBI/CERT-In |
| **P2 — High** | Suspected compromise / significant malware / major outage | Acknowledge: 30 min; Contain: 4 hrs | CISO, CTO, IT Head |
| **P3 — Medium** | Security alert requiring investigation / minor outage | Acknowledge: 2 hrs; Resolve: 8 hrs | SOC Lead, IT Manager |
| **P4 — Low** | Informational events / policy violation / user complaints | Acknowledge: 4 hrs; Resolve: 24 hrs | SOC Analyst |

---

## Evidence to Collect

| Evidence | Source | Format |
|----------|--------|--------|
| IR / CCMP policy (current-year approval) | Document management | PDF |
| Incident log for audit period | ITSM export | CSV |
| P1/P2 incident sample — full ticket history | ITSM screenshots | PDF |
| CERT-In report submissions (receipts) | Email / portal log | PDF |
| SIEM alert use cases list | SIEM admin | Screenshot |
| SOC roster / on-call schedule | IT Operations | PDF |
| Last tabletop exercise report | IR team | PDF |
| RCA reports for major incidents | Incident reports | PDF |
| Training records — IR team | HR/Training system | PDF |

---

## Common Findings

### Finding IM-001 — No CERT-In Reporting Procedure

> **Condition:** Review of the Incident Response Policy and CCMP found no documented procedure for reporting cybersecurity incidents to CERT-In. During interviews with the SOC Lead and CISO, no awareness of the 6-hour CERT-In reporting deadline was demonstrated. No CERT-In incident reports were found in the organization's records for the audit period, despite 3 incidents meeting the CERT-In reporting criteria (ransomware infection on endpoint, unauthorized login from foreign IP, data exfiltration alert).
> **Criteria:** CERT-In Directions (April 2022), Section 4, require all service providers, intermediaries, data centres, and body corporate to report cybersecurity incidents to CERT-In within 6 hours of noticing or becoming aware of the incident. Non-compliance is an offence under Section 70B(7) of the IT Act, 2000.
> **Effect:** The 3 identified incidents were not reported to CERT-In, constituting direct violations of the CERT-In Directions — a criminal provision of the IT Act. Future non-reporting of incidents exposes the organization and its officers to regulatory action, fines, and reputational harm.
> **Recommendation:** (1) Immediately update the IR policy to include CERT-In reporting with the 6-hour deadline. (2) Appoint a designated CERT-In POC. (3) Conduct mandatory training for SOC team and CISO. (4) Review the 3 identified incidents and submit retrospective reports to CERT-In. (5) Test CERT-In reporting in the next tabletop exercise.
> **Risk:** 🔴 Critical

---

### Finding IM-002 — No RCA for Major Incidents

> **Condition:** Review of the P1 incident log identified 7 Critical severity incidents in the audit period, including 2 suspected ransomware infections and 1 SWIFT anomaly alert. Of the 7 incidents, only 2 had post-incident Root Cause Analysis (RCA) reports. The remaining 5 were closed in ServiceNow with status "Resolved" and a single-line closure note, with no RCA, no lessons-learned documentation, and no action items.
> **Criteria:** Incident Management Policy v1.4 Section 9.1 requires a formal RCA to be completed for all P1 incidents within 5 business days of closure. COBIT DSS02.07 requires post-incident reviews for significant events to identify root cause and prevent recurrence.
> **Effect:** Without RCA, the same vulnerabilities and control gaps that allowed these incidents to occur remain unaddressed, increasing the likelihood of recurrence. Repeat incidents in the same area indicate systemic risk and will attract adverse regulatory scrutiny.
> **Recommendation:** (1) Complete RCAs for the 5 identified incidents immediately — escalate to CISO for sign-off. (2) Enforce the RCA process by making RCA completion a mandatory field in ServiceNow before P1 tickets can be closed. (3) Create a monthly "Incident Lessons Learned" briefing for the CISO and IT Head.
> **Risk:** 🟠 High

---

## Regulatory Mapping

| Control Area | CERT-In 2022 | RBI Cyber Framework | ISO 27001:2022 | NIST CSF |
|---|---|---|---|---|
| Incident reporting | 6-hr reporting mandate | §13.4 — Reporting | A.5.26 | RS.CO-2 |
| IR policy / CCMP | — | §13.1 — CCMP | A.5.24 | RS.MA-1 |
| Detection / SIEM | — | §12.1 — SOC | A.8.16 | DE.CM-1 |
| Post-incident review | — | — | A.5.27 | RS.AN-5 |
| Log retention | 180-day mandate | §11.2 — Log retention | A.8.15 | DE.CM-1 |
| Tabletop exercises | — | §13 (implied) | A.5.24 | RS.MA-2 |

---

*Part of [IS Audit Playbook](../README.md) | See also: [Backup & Recovery](backup-recovery.md)*
