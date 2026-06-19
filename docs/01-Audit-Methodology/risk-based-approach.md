# Risk-Based Audit Approach

> **Purpose:** Define how IS audits are scoped, prioritized, and resource-allocated using a risk-based methodology  
> **Standard:** IIA International Standards 2010 (Planning), ISACA IS Audit Standard S2, ISO 31000

---

## Why Risk-Based Auditing?

Traditional compliance-based audits check every control for every system — an approach that is resource-intensive and often misaligns audit effort with actual organizational risk. A **risk-based approach** concentrates audit effort where the potential for harm is greatest.

```
Compliance-Based:      All controls × All systems = Equal coverage
Risk-Based:            High-risk areas × Deep coverage + Low-risk areas × Light touch
```

The result is better use of limited audit resources, higher-value findings, and more credible assurance opinions.

---

## Core Risk Concepts

### Inherent Risk

The risk that exists **before any controls are applied**. It is driven by:

- Nature of the asset (what damage could result from failure?)
- Sensitivity of data processed (PII, financial, regulated)
- Complexity and exposure of the system
- External threat landscape

> Example: An internet-facing payment gateway has high inherent risk because it processes financial data, is exposed to external attackers, and failure causes immediate financial and reputational harm.

### Control Risk

The risk that the **controls in place fail to prevent or detect** the inherent risk. Factors include:

- Control design (does the control actually address the risk?)
- Control operating effectiveness (is the control applied consistently?)
- Frequency and automation (manual controls have higher failure rates)

### Residual Risk

```
Residual Risk = Inherent Risk × (1 − Control Effectiveness)
```

Residual risk is what remains after controls are applied. The auditor's job is to assess whether residual risk falls within the organization's risk appetite.

### Detection Risk

The risk that the auditor's procedures **fail to identify** a material control gap. Auditors manage detection risk by:

- Increasing sample sizes
- Using multiple test procedures
- Applying skepticism to management assertions
- Using automated data analysis

---

## Risk Assessment Process

### Step 1 — Build the Audit Universe

The **audit universe** is the complete set of auditable entities. Each entity is a defined system, process, or business unit that can be independently assessed.

See [Audit Universe](audit-universe.md) for the full framework.

### Step 2 — Score Inherent Risk

For each entity in the audit universe, score the following risk factors:

| Risk Factor | Weight | Scoring Criteria | Score (1–5) |
|-------------|--------|-----------------|-------------|
| **Data Sensitivity** | 25% | 1=Public, 3=Internal, 5=PII/Financial/Regulated | — |
| **Regulatory Significance** | 20% | 1=No regulation, 3=Partial, 5=Directly regulated (RBI/CERT-In) | — |
| **Business Criticality** | 20% | 1=Non-critical, 3=Important, 5=Core banking/payments | — |
| **System Complexity** | 15% | 1=Simple/static, 3=Moderate, 5=Complex/distributed | — |
| **External Exposure** | 10% | 1=Internal only, 3=Partner access, 5=Internet-facing | — |
| **Change Frequency** | 10% | 1=Rarely changed, 3=Monthly, 5=Continuous deployment | — |

**Inherent Risk Score = Σ (Factor Score × Weight)**

| Score Range | Inherent Risk Level |
|-------------|---------------------|
| 4.0 – 5.0 | 🔴 Very High |
| 3.0 – 3.9 | 🟠 High |
| 2.0 – 2.9 | 🟡 Medium |
| 1.0 – 1.9 | 🟢 Low |

### Step 3 — Score Control Environment

Assess the maturity of existing controls using prior audit results, management self-assessments, and preliminary surveys:

| Control Environment Factor | Score (1–5) |
|---------------------------|-------------|
| Documented and current policies exist | — |
| Controls are automated (not manual) | — |
| Prior audit findings in this area | — |
| Management oversight and review frequency | — |
| Vendor/third-party dependency | — |

**Control Score = Average of above factors**

| Control Score | Control Strength |
|--------------|-----------------|
| 4.0 – 5.0 | Strong — controls likely effective |
| 2.5 – 3.9 | Moderate — some gaps expected |
| 1.0 – 2.4 | Weak — significant gaps likely |

### Step 4 — Calculate Residual Risk & Prioritize

```
Audit Priority Score = Inherent Risk Score × (6 − Control Score) / 5
```

This formula produces a higher score when inherent risk is high **and** controls are weak — exactly where audit effort should concentrate.

| Priority Score | Audit Frequency |
|----------------|----------------|
| ≥ 3.5 | Annual full-scope audit |
| 2.5 – 3.4 | Annual targeted audit |
| 1.5 – 2.4 | Biennial audit or management attestation |
| < 1.5 | Triennial or risk-acceptance review |

---

## Risk Assessment Matrix Template

```
ENTITY: [System/Process Name]
PERIOD: [Audit Year]
ASSESSED BY: [Auditor Name]
DATE: [Assessment Date]

┌─────────────────────────────────────────────────────────────────┐
│ INHERENT RISK FACTORS                                           │
├────────────────────────┬────────┬───────┬──────────────────────┤
│ Factor                 │ Weight │ Score │ Weighted Score       │
├────────────────────────┼────────┼───────┼──────────────────────┤
│ Data Sensitivity       │  25%   │       │                      │
│ Regulatory Significance│  20%   │       │                      │
│ Business Criticality   │  20%   │       │                      │
│ System Complexity      │  15%   │       │                      │
│ External Exposure      │  10%   │       │                      │
│ Change Frequency       │  10%   │       │                      │
├────────────────────────┼────────┼───────┼──────────────────────┤
│ TOTAL INHERENT RISK    │ 100%   │  —    │                      │
└────────────────────────┴────────┴───────┴──────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ CONTROL ENVIRONMENT                                             │
├────────────────────────────────────────────────┬───────────────┤
│ Factor                                         │ Score (1–5)   │
├────────────────────────────────────────────────┼───────────────┤
│ Policy documentation completeness              │               │
│ Control automation level                       │               │
│ Prior audit finding history                    │               │
│ Management oversight maturity                  │               │
│ Third-party / vendor reliance                  │               │
├────────────────────────────────────────────────┼───────────────┤
│ AVERAGE CONTROL SCORE                          │               │
└────────────────────────────────────────────────┴───────────────┘

RESIDUAL RISK / PRIORITY SCORE: ________
AUDIT RECOMMENDATION: Full Audit / Targeted / Attestation / Defer
```

---

## Applying Risk-Based Approach During Fieldwork

Risk-based thinking does not stop at planning — it applies throughout the audit:

### Scope Adjustment During Fieldwork

If initial testing reveals controls to be significantly weaker than assessed, the auditor should expand scope:

```
Initial test → Control failure rate > 10% → Expand sample or extend to additional areas
Initial test → Control operating well → May reduce sample on lower-risk controls
```

### Materiality in IS Audit

Not every gap is worth reporting. Apply a materiality threshold:

| Risk Rating | Always Report | Report if Recurring | May Waive |
|-------------|:---:|:---:|:---:|
| 🔴 Critical | ✅ | ✅ | ❌ |
| 🟠 High | ✅ | ✅ | ❌ |
| 🟡 Medium | ✅ | ✅ | Context-dependent |
| 🟢 Low | ✅ (brief) | ✅ | ✅ if compensating control exists |

### Risk Aggregation

Individual low-risk findings can aggregate to a high-risk conclusion:

> Example: Weak password policy (Low) + No MFA for admins (High) + No account lockout (Medium) + Dormant accounts (High) = Aggregated identity control failure of 🔴 Critical severity at the domain level.

Always assess findings in aggregate, not just individually.

---

## Risk-Based Sampling

Sample sizes should reflect the risk level of the control being tested:

| Control Risk | Attribute Sampling (Yes/No controls) | Substantive Testing (Transaction-level) |
|-------------|--------------------------------------|----------------------------------------|
| High | 60–100% or 25 items minimum | 30–60 items |
| Medium | 30–60% or 15 items minimum | 20–30 items |
| Low | 10–30% or 10 items minimum | 10–20 items |

For **IT General Controls** (access provisioning, change approval), which are population-based:
- Populations < 25: Test all items
- Populations 26–100: Test 25 items
- Populations > 100: Use statistical sampling (confidence 95%, tolerance 5%)

---

## BFSI-Specific Risk Considerations

For Indian banking and financial sector audits, the following automatically elevate inherent risk:

| Condition | Risk Elevation |
|-----------|---------------|
| System processes SWIFT/RTGS/NEFT transactions | → Very High |
| System stores Aadhaar or PAN data | → High (DPDP Act) |
| System is internet-facing or cloud-hosted | → High |
| System has not been patched in > 90 days | → High |
| No security audit in past 24 months | → High |
| System subject to RBI IT/Cyber Framework | → High |
| Prior CERT-In non-compliance | → Very High |
| System involved in prior security incident | → Very High |

---

*Part of [IS Audit Playbook](../README.md) | Next: [Audit Universe](audit-universe.md)*
