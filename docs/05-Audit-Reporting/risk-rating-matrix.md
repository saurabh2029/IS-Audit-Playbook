# Risk Rating Matrix

> **Purpose:** Standardized criteria for rating the risk severity of IS audit findings  
> **Alignment:** ISO 31000, ISACA Risk IT Framework, RBI Risk Tiering

---

## Rating Scale

| Rating | Symbol | Color Code |
|--------|--------|-----------|
| Critical | C | 🔴 Red |
| High | H | 🟠 Orange |
| Medium | M | 🟡 Yellow |
| Low | L | 🟢 Green |

---

## Rating Criteria

### 🔴 Critical

| Dimension | Criteria |
|-----------|---------|
| **Impact — Confidentiality** | Breach of highly sensitive data (PII, financial, credentials) affecting large populations; reportable under CERT-In / DPDP Act |
| **Impact — Integrity** | Unauthorized modification of financial transactions, audit trails, or core system data |
| **Impact — Availability** | Disruption to critical banking / payment services affecting customers |
| **Impact — Compliance** | Direct violation of mandatory regulation (RBI, CERT-In, DPDP Act) with penalty risk |
| **Likelihood** | Control is absent, trivially bypassed, or currently exploited |
| **Remediation Timeline** | Immediate — within 7 days |
| **Examples** | No authentication on admin console; default credentials; RDP/3389 exposed to internet; no log retention; terminated employee accounts with active access; DBA role on app accounts |

---

### 🟠 High

| Dimension | Criteria |
|-----------|---------|
| **Impact — Confidentiality** | Risk of significant data exposure; may require regulatory notification |
| **Impact — Integrity** | Significant risk of unauthorized data modification; compensating controls partially mitigate |
| **Impact — Availability** | Material disruption risk to important (not critical) services |
| **Impact — Compliance** | Partial non-compliance with regulation; risk of adverse audit opinion |
| **Likelihood** | Control gap is exploitable with moderate effort; known threat vector |
| **Remediation Timeline** | Within 30 days |
| **Examples** | Excessive privileged accounts; no periodic access review; MFA not enforced for remote access; missing IPS profiles; VAPT not conducted in >12 months |

---

### 🟡 Medium

| Dimension | Criteria |
|-----------|---------|
| **Impact — Confidentiality** | Limited data exposure; compensating controls in place reduce impact |
| **Impact — Integrity** | Integrity risk is low due to mitigating controls |
| **Impact — Availability** | Minor service disruption; quick recovery expected |
| **Impact — Compliance** | Procedural non-compliance; no immediate regulatory risk |
| **Likelihood** | Gap requires specific conditions or insider knowledge to exploit |
| **Remediation Timeline** | Within 90 days |
| **Examples** | Password policy slightly below benchmark; missing login banners; log review not formalized; documentation gaps; non-critical system patches delayed |

---

### 🟢 Low

| Dimension | Criteria |
|-----------|---------|
| **Impact** | Negligible business impact; theoretical or edge-case risk only |
| **Likelihood** | Highly unlikely; requires very specific conditions |
| **Remediation Timeline** | Within 180 days or risk acceptance |
| **Examples** | Outdated policy document version without material change; missing screen lock timeout on internal workstations; minor naming convention deviations |

---

## Risk Rating Matrix (Likelihood × Impact)

```
             │     LOW      │   MEDIUM     │    HIGH      │  CRITICAL    │
             │    Impact    │   Impact     │   Impact     │   Impact     │
─────────────┼──────────────┼──────────────┼──────────────┼──────────────┤
HIGH         │   🟡 Medium  │   🟠 High    │   🔴 Critical│   🔴 Critical│
Likelihood   │              │              │              │              │
─────────────┼──────────────┼──────────────┼──────────────┼──────────────┤
MEDIUM       │   🟢 Low     │   🟡 Medium  │   🟠 High    │   🔴 Critical│
Likelihood   │              │              │              │              │
─────────────┼──────────────┼──────────────┼──────────────┼──────────────┤
LOW          │   🟢 Low     │   🟢 Low     │   🟡 Medium  │   🟠 High    │
Likelihood   │              │              │              │              │
─────────────┴──────────────┴──────────────┴──────────────┴──────────────┘
```

---

## Remediation SLA by Rating

| Rating | Remediation Deadline | Escalation if Missed |
|--------|---------------------|---------------------|
| 🔴 Critical | 7 days | Immediate escalation to CISO + CIO; report to Board if > 14 days |
| 🟠 High | 30 days | Escalate to IT Head at 30 days; CISO at 45 days |
| 🟡 Medium | 90 days | Reminder at 60 days; escalate at 90 days |
| 🟢 Low | 180 days | Close or risk-accept at 180 days |

---

*Part of [IS Audit Playbook](../README.md)*
