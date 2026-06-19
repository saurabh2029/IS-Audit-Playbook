# Audit Finding Writing Guide

> **Purpose:** Provide a structured approach to writing clear, defensible, and actionable audit findings  
> **Standard:** Aligned with IIA Standards, ISACA IS Audit Guidelines, and RBI audit reporting requirements

---

## The PCCER Framework

Every audit finding must tell a complete story using five components:

```
┌──────────────────────────────────────────────────────────────────┐
│  P — Process / Control Area     What domain are we examining?    │
│  C — Condition                  What did we actually find?       │
│  C — Criteria                   What should it look like?        │
│  E — Effect                     What is the business impact?     │
│  R — Recommendation             What should be done about it?    │
└──────────────────────────────────────────────────────────────────┘
```

---

## Component-by-Component Guide

### P — Process / Control Area

This identifies **what domain** the finding relates to. It gives context before the detail.

**Good examples:**
- "User Access Management — Privileged Account Governance"
- "Change Management — Emergency Change Authorization"
- "Database Security — Oracle Listener Configuration"

**Avoid:**
- Vague labels like "IT Security" or "Systems"
- Naming the finding after the symptom ("Password Problem")

---

### C — Condition (The Observation)

This is **what you found**. It must be:
- **Factual** — based on evidence, not opinion
- **Specific** — with numbers, dates, system names
- **Objective** — free from blame or subjective language

| ❌ Weak Condition | ✅ Strong Condition |
|------------------|---------------------|
| "Many user accounts are not managed properly." | "As of audit date, 47 enabled user accounts had not been accessed in over 90 days. Of these, 12 belonged to employees confirmed as separated by Human Resources." |
| "The firewall rules look risky." | "Review of the perimeter firewall (Fortinet FG-200E) identified 3 inbound rules permitting ANY source IP to TCP port 3389 (RDP), with no IP restriction or MFA requirement." |
| "Passwords are weak." | "The default domain password policy enforces a minimum length of 8 characters with no complexity requirement, no history enforcement, and no lockout threshold configured." |

**Template:**
```
During [audit procedure], [specific observation] was identified.
[Quantify with numbers/percentages where possible].
[Name specific systems/accounts/configurations if relevant].
```

---

### C — Criteria (The Standard)

This answers: **"What should it look like?"** — the benchmark against which the condition is measured.

Criteria can come from:

| Source | Example |
|--------|---------|
| **Internal Policy** | "IT Security Policy v3.2, Section 4.5 requires…" |
| **Regulatory Requirement** | "CERT-In Directions (April 2022) mandate log retention for a minimum of 180 days…" |
| **Industry Standard** | "CIS Benchmark for Windows Server 2022 (v2.0) recommends…" |
| **Vendor Best Practice** | "Microsoft security baseline for Active Directory recommends…" |
| **Contractual Obligation** | "PCI DSS Requirement 8.2.6 requires…" |

**Template:**
```
[Policy/Standard name], [specific section/requirement], requires/mandates/recommends
that [what should be in place].
```

> 💡 **Tip:** Always cite the specific version and section. "Per policy" is not sufficient.

---

### E — Effect (The Business Impact)

This answers: **"Why does this matter?"** — the actual or potential consequence if the condition persists.

Frame effect in terms of:
- **Confidentiality** — unauthorized data access or disclosure
- **Integrity** — unauthorized modification of data or systems
- **Availability** — disruption to business operations
- **Compliance** — regulatory penalty, audit qualification
- **Reputational** — customer trust, brand damage
- **Financial** — fraud, fines, recovery costs

| ❌ Weak Effect | ✅ Strong Effect |
|---------------|-----------------|
| "This is a security risk." | "Unauthorized access to customer financial data could result in breach of the DPDP Act 2023, exposing the organization to regulatory penalties and reputational harm." |
| "It could cause problems." | "Absence of account lockout policy allows unlimited brute-force login attempts against all domain accounts, significantly increasing the risk of credential compromise." |

**Template:**
```
[Condition] creates a risk of [threat/consequence].
If exploited, this could result in [specific impact — financial/compliance/operational].
[Refer to any regulatory consequence if applicable].
```

---

### R — Recommendation

This answers: **"What should be done?"** — specific, actionable, and proportionate to the risk.

**Characteristics of a good recommendation:**
- **Action-oriented** — starts with a verb (Implement, Disable, Review, Enforce)
- **Specific** — not "improve controls" but "disable all accounts inactive for 90+ days"
- **Feasible** — considers operational reality
- **Prioritized** — suggests urgency based on risk rating
- **Ownership-ready** — implies which team should act

| ❌ Weak Recommendation | ✅ Strong Recommendation |
|-----------------------|--------------------------|
| "Security should be improved." | "The IAM team should disable all 47 dormant accounts immediately. Implement an automated account deactivation process triggered by HR offboarding workflow. Conduct quarterly access certification reviews for all privileged accounts." |
| "Fix the firewall." | "Remove or restrict the three ANY-to-ANY RDP rules immediately. Replace with IP-restricted rules permitting only the Jump Server subnet (10.10.5.0/24). Enforce MFA for all remote management access per RBI Cyber Framework Section 7.2." |

**Template:**
```
[Immediate action] — [responsible team] should [specific action] by [timeframe].
[Longer-term action] — Implement [sustainable control] to prevent recurrence.
[Reference to applicable policy/standard for future guidance].
```

---

## Risk Rating Criteria

### 🔴 Critical

| Dimension | Criteria |
|-----------|---------|
| **Impact** | Could result in full system/data compromise, regulatory sanction, or significant financial loss |
| **Likelihood** | Control failure is currently exploitable or being actively exploited |
| **Timeline** | Immediate remediation required (within 7 days) |
| **Examples** | No encryption on customer data, no authentication on admin systems, known exploited vulnerability unpatched |

### 🟠 High

| Dimension | Criteria |
|-----------|---------|
| **Impact** | Significant data exposure, regulatory non-compliance, major operational disruption |
| **Likelihood** | Reasonably likely given current environment and threat landscape |
| **Timeline** | Remediate within 30 days |
| **Examples** | Excessive privileged accounts, dormant accounts of ex-employees, missing MFA for admin access |

### 🟡 Medium

| Dimension | Criteria |
|-----------|---------|
| **Impact** | Moderate risk; existing compensating controls reduce the impact |
| **Likelihood** | Possible but requires specific conditions or deliberate action |
| **Timeline** | Remediate within 90 days |
| **Examples** | Weak password policy for standard users, missing log retention for non-critical systems |

### 🟢 Low

| Dimension | Criteria |
|-----------|---------|
| **Impact** | Minor operational or compliance gap; limited business impact |
| **Likelihood** | Unlikely; theoretical or edge-case scenario |
| **Timeline** | Remediate within 180 days or accept risk |
| **Examples** | Missing banners on internal systems, outdated documentation |

---

## Complete Finding Examples

### Example 1 — Network Device

**Finding ID:** NET-2024-FW-001  
**Control Area:** Network Security — Perimeter Firewall Rule Management  
**Risk Rating:** 🔴 Critical

**Condition:**  
Review of the perimeter firewall ruleset (Fortinet FortiGate 200E, policy version reviewed on [date]) identified three rules permitting inbound access from ANY source IP address to TCP port 3389 (RDP) on the production network segment (172.16.0.0/16). No IP restriction, MFA requirement, or time-based restriction was applied to these rules.

**Criteria:**  
RBI Cybersecurity Framework (2016), Annex III, Section 5.2 requires that remote access to critical infrastructure be restricted to known, authorized IP ranges. CIS Benchmark for FortiOS (v2.0) Control 3.5 recommends disabling direct RDP access from external networks and routing all remote access through a hardened bastion host or VPN.

**Effect:**  
The unrestricted inbound RDP access allows any internet-connected host to attempt authentication against production servers. This significantly increases exposure to brute-force attacks, credential stuffing, and exploitation of RDP vulnerabilities (e.g., BlueKeep, CVE-2019-0708). Successful exploitation could result in unauthorized access to production systems and customer financial data, constituting a reportable breach under CERT-In Directions (2022) and the DPDP Act 2023.

**Recommendation:**  
1. **Immediate (within 48 hours):** Remove or disable all three ANY-source RDP rules.
2. **Short-term (within 7 days):** Replace with IP-restricted rules permitting RDP access only from the approved Jump Server subnet (confirm with network team). Enforce VPN + MFA as the mandatory path for all remote administrative access.
3. **Long-term:** Implement a Privileged Access Workstation (PAW) model. Conduct quarterly firewall rule reviews as part of the change management cycle.

---

### Example 2 — Application Audit

**Finding ID:** APP-2024-CBS-003  
**Control Area:** Application Security — Core Banking System Audit Trail  
**Risk Rating:** 🟠 High

**Condition:**  
During review of the Core Banking System (Finacle v11.3.1) audit log configuration, it was observed that audit logs for four transaction categories — bulk fund transfers, SWIFT message generation, account parameter changes, and user role modifications — were not being forwarded to the central SIEM (Splunk). These events were being generated locally but were retained only on the application server's local storage (30-day retention).

**Criteria:**  
CERT-In Directions (April 2022), Section 6(1) mandates maintenance of ICT-related logs for a rolling period of 180 days. RBI Cybersecurity Framework (2016), Annex I, Control 11.3, requires logs for financial transactions and administrative actions to be centrally stored, tamper-proof, and monitored in near real-time.

**Effect:**  
Absence of SIEM forwarding for these high-risk transaction categories creates a blind spot in the organization's security monitoring. Fraudulent transactions, unauthorized account modifications, or insider threats in these categories would not trigger real-time alerts. Additionally, local 30-day retention does not meet the 180-day CERT-In mandate, creating regulatory non-compliance exposure.

**Recommendation:**  
1. **Immediate:** Configure Finacle log forwarding for the four identified transaction categories to the existing Splunk SIEM deployment. Validate receipt of events in Splunk within 48 hours.
2. **Short-term:** Create detection rules in Splunk for anomalous activity in SWIFT and bulk fund transfer logs.
3. **Compliance:** Extend local log retention to 180 days as an interim measure pending SIEM forwarding confirmation. Document compliance with CERT-In log retention mandate.

---

## Common Language to Avoid

| ❌ Avoid | ✅ Use Instead |
|----------|---------------|
| "Management should consider…" | "Management should implement…" |
| "It appears that…" | "Testing confirmed that…" |
| "The team was unable to provide…" | "No evidence was provided to demonstrate…" |
| "This is clearly a major issue" | "This represents a High risk based on [criteria]" |
| "John from IT said that…" | "During walkthrough on [date], the IT Manager confirmed…" |
| "Best practices suggest…" | "[Specific standard, version, section] requires…" |

---

## Management Response Format

After the finding is issued, management provides a response:

```
Management Response:
━━━━━━━━━━━━━━━━━━
Agreed / Partially Agreed / Not Agreed

Action Plan:
[Specific steps management will take]

Responsible Owner: [Name, Title]
Target Completion Date: [DD-MMM-YYYY]

Management Comments:
[Any context, constraints, or clarifications]
```

> ⚠️ If management disagrees with a Critical or High finding, the auditor must escalate to the Audit Committee with a formal disagreement note. Never simply remove a finding because management disagrees.

---

*Part of [IS Audit Playbook](../README.md)*
