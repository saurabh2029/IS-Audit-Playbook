# CISA & CISM Exam Preparation Guide

> **Certifications Covered:** CISA (Certified Information Systems Auditor) | CISM (Certified Information Security Manager)  
> **Publisher:** ISACA  
> **Target Audience:** IS audit professionals in BFSI and enterprise environments

---

## CISA Overview

### About CISA

The **CISA** is the globally recognized certification for IS auditors. It validates expertise in auditing, monitoring, and assessing IS and business systems. It is considered the gold standard for IS audit roles.

| Attribute | Detail |
|-----------|--------|
| Exam Format | 150 multiple-choice questions |
| Duration | 4 hours |
| Passing Score | 450/800 |
| Experience Required | 5 years in IS audit/control/security (substitutions allowed) |
| Renewal | 120 CPE hours over 3 years |
| Exam Fee | USD 575 (member) / USD 760 (non-member) |

---

### CISA Domain Breakdown (2023 Job Practice)

| Domain | Weight | Key Topics |
|--------|--------|-----------|
| **Domain 1** — IS Audit Process | 18% | Audit standards, risk-based approach, planning, evidence, reporting |
| **Domain 2** — IT Governance | 18% | Frameworks (COBIT), IT strategy, policies, organizational structure |
| **Domain 3** — Information Systems Acquisition, Development & Implementation | 12% | SDLC, project management, change management, testing |
| **Domain 4** — IS Operations & Business Resilience | 26% | Service management, asset management, BCP/DR, incident management |
| **Domain 5** — Protection of Information Assets | 26% | Access control, cryptography, network security, malware, monitoring |

---

### CISA Domain 1 — IS Audit Process (High Priority)

**Key Concepts:**

```
AUDIT STANDARDS (memorize these)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
S1  — Audit Charter
S2  — Independence (auditor must be independent)
S3  — Professional Ethics
S4  — Professional Competence
S5  — Planning
S6  — Performance of Audit Work
S7  — Reporting
S8  — Follow-Up Activities
S9  — Irregularities and Illegal Acts
S10 — IT Governance
S11 — Use of Risk Assessment in Audit Planning
S12 — Audit Materiality
S13 — Using the Work of Other Experts
S14 — Audit Evidence
S15 — IT Controls
S16 — E-Commerce
```

**Frequently Tested Concepts:**

- **Audit risk = Inherent Risk × Control Risk × Detection Risk**
- Auditor must have **organizational independence** — does not report to the head of IT being audited
- **Substantive testing** tests the actual data; **compliance testing** tests whether controls work
- **CAATs** (Computer-Assisted Audit Techniques) — ACL, IDEA, SQL queries
- **Sampling methods**: statistical (random, systematic, stratified) vs. non-statistical (judgmental, haphazard)
- **Attribute sampling** — tests yes/no controls (access review done: yes/no)
- **Variable sampling** — tests quantities (number of unauthorized accounts)

---

### CISA Domain 5 — Protection of Information Assets (26% — Highest Weight)

**Access Control Models (memorize for exam):**

| Model | Description | Example |
|-------|-------------|---------|
| **DAC** (Discretionary Access Control) | Owner decides who has access | File system permissions (Windows NTFS) |
| **MAC** (Mandatory Access Control) | System enforces based on labels | Government/military classification systems |
| **RBAC** (Role-Based Access Control) | Access based on job role | Most enterprise systems |
| **ABAC** (Attribute-Based Access Control) | Rules based on multiple attributes | Cloud IAM, zero trust |
| **Rule-Based** | Based on defined rules | Firewall rules |

**Cryptography Concepts (frequently tested):**

| Concept | Detail |
|---------|--------|
| **Symmetric encryption** | Same key for encrypt and decrypt; fast; AES, 3DES |
| **Asymmetric encryption** | Public key encrypts; private key decrypts; RSA, ECC |
| **Hashing** | One-way function; SHA-256, bcrypt; used for passwords and integrity |
| **Digital signature** | Sender encrypts hash with private key → recipient verifies with public key |
| **PKI** | Infrastructure for issuing/managing digital certificates; CA, RA, CRL |
| **SSL/TLS** | Asymmetric for key exchange; symmetric for data transfer |
| **Steganography** | Hiding data within other data (image, audio) |

**Network Security (frequently tested):**

| Technology | Purpose |
|-----------|---------|
| **Firewall** | Filters traffic by IP/port/protocol |
| **IDS** | Detects attacks; alerts but doesn't block |
| **IPS** | Detects AND blocks attacks inline |
| **WAF** | Inspects HTTP/HTTPS traffic; blocks web attacks |
| **Proxy** | Intermediary for web traffic; provides caching/filtering |
| **Honeypot** | Decoy system to detect attackers |
| **DMZ** | Demilitarized Zone — semi-trusted network for internet-facing servers |
| **NAT** | Translates private to public IPs |
| **VPN** | Encrypted tunnel over internet |
| **Zero Trust** | Never trust, always verify; micro-segmentation |

---

### CISA Exam Tips

1. **Read questions carefully** — ISACA questions often have 2 plausible answers; choose the "BEST" option
2. **Auditor perspective** — when in doubt, choose the answer that involves the auditor reviewing, verifying, or testing (not just accepting management's word)
3. **Independence is paramount** — any answer that compromises auditor independence is wrong
4. **Risk-based thinking** — audit effort should concentrate on highest risk areas
5. **Evidence > assertion** — auditors test and verify; they do not rely on management self-attestation alone
6. **Sequence matters** — plan before execute; test before report; report before follow-up

**Common wrong-answer traps:**
- "Rely on management's representation" → Usually wrong; auditors must verify
- "Immediately report to authorities" → Usually wrong unless fraud is confirmed
- "Expand the audit scope" → Usually wrong if the finding is outside the defined scope
- Answers that describe the IS auditor performing IT functions → Wrong (independence violation)

---

## CISM Overview

### About CISM

The **CISM** validates expertise in managing and governing an enterprise's information security program. It is more management-focused than the CISA, and is suited for CISO / IS audit management roles.

| Attribute | Detail |
|-----------|--------|
| Exam Format | 150 multiple-choice questions |
| Duration | 4 hours |
| Passing Score | 450/800 |
| Experience Required | 5 years in IS management (with substitutions) |
| Renewal | 120 CPE hours over 3 years |

---

### CISM Domain Breakdown (2022 Job Practice)

| Domain | Weight | Key Topics |
|--------|--------|-----------|
| **Domain 1** — IS Governance | 17% | Strategy, governance frameworks, policies, roles (CISO) |
| **Domain 2** — IS Risk Management | 20% | Risk identification, assessment, treatment, monitoring |
| **Domain 3** — IS Program | 33% | Security programs, controls, awareness, metrics, vendor management |
| **Domain 4** — Incident Management | 30% | IR lifecycle, business continuity, forensics, recovery |

---

### CISM Domain 2 — IS Risk Management (High Priority)

**Risk Treatment Options (memorize):**

| Option | Description | Example |
|--------|-------------|---------|
| **Avoid** | Stop the activity causing the risk | Don't launch internet-facing service |
| **Transfer** | Move risk to third party | Cyber insurance; outsourcing |
| **Mitigate / Reduce** | Implement controls to reduce likelihood or impact | Deploy MFA, encryption, IPS |
| **Accept** | Acknowledge risk and do nothing (within appetite) | Accept low-risk finding |

**Risk Appetite vs. Risk Tolerance:**
- **Risk Appetite** = how much risk the organization is willing to take (strategic)
- **Risk Tolerance** = acceptable variance around risk appetite (operational)

**Quantitative vs. Qualitative Risk Assessment:**

| Approach | Method | Output |
|----------|--------|--------|
| **Quantitative** | ALE = SLE × ARO | Financial value (₹ amount) |
| **Qualitative** | Rating scales (High/Medium/Low) | Risk heat map |

```
Quantitative Risk Formulae (memorize for CISM/CISA):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SLE  = Asset Value × Exposure Factor
     (Single Loss Expectancy — loss per incident)

ARO  = Annualized Rate of Occurrence
     (How often the incident is expected per year)

ALE  = SLE × ARO
     (Annual Loss Expectancy — expected loss per year)

Example:
Asset Value = ₹10,00,000
Exposure Factor = 30% (data breach affects 30% of data value)
SLE = ₹10,00,000 × 0.30 = ₹3,00,000
ARO = 0.5 (once every 2 years)
ALE = ₹3,00,000 × 0.5 = ₹1,50,000 per year
```

---

### CISM Domain 4 — Incident Management (30% — Highest Weight)

**Incident Response Lifecycle:**

```
PREPARE → IDENTIFY → CONTAIN → ERADICATE → RECOVER → LESSONS LEARNED
```

**Business Continuity vs. Disaster Recovery:**

| Concept | Focus | Goal |
|---------|-------|------|
| **BCP** | Keeping business running during disruption | Business process continuity |
| **DRP** | Restoring IT systems after disruption | IT system recovery |
| **COOP** | Government continuity of operations | Mission-essential functions |

**Recovery Site Types (memorize):**

| Site Type | Readiness | Cost | RTO |
|-----------|-----------|------|-----|
| **Hot Site** | Fully operational; live data sync | Very High | Minutes to Hours |
| **Warm Site** | Hardware ready; data restore needed | Medium | Hours to Days |
| **Cold Site** | Space and power only; no equipment | Low | Days to Weeks |
| **Mobile Site** | Truck-based portable facility | Variable | Hours |
| **Reciprocal** | Agreement to use another org's facility | Low | Variable |

---

### CISM Exam Tips

1. **Think like a CISO** — management perspective, not technical hands-on
2. **Business alignment** — security decisions should align to business objectives and risk appetite
3. **Risk-based decisions** — the "best" answer considers risk, not just security best practice
4. **Governance first** — policies, frameworks, and governance questions should reference top management/board involvement
5. **Senior management owns risk** — the CISO manages the program; senior management/board owns the risk

---

## CISA vs. CISM — Which First?

| Factor | Choose CISA | Choose CISM |
|--------|------------|------------|
| **Career goal** | IS Audit, Internal Audit, External Audit | IS Management, CISO, Security Manager |
| **Current role** | Auditor, compliance analyst | Security manager, risk manager |
| **Focus** | Testing and verifying controls | Designing and governing security programs |
| **BFSI recommendation** | IS Audit → CISA first | Security leadership → CISM first |

> **For your profile:** Given SOC Operations background and IS Audit transition goal — **CISA is the more directly relevant certification**. It is also what IS Audit JDs at NaBFID, SBI IAD, and RBI typically list. CISM can follow to position for senior IS Audit or Head of IS Audit roles.

---

## Study Resources

| Resource | Type | Notes |
|----------|------|-------|
| ISACA CISA Review Manual | Official | Primary resource; dense but comprehensive |
| ISACA CISA Question Bank | Practice Questions | 1000+ official questions |
| CISA All-in-One Exam Guide (Peter Gregory) | Book | Very readable; strong conceptual explanations |
| Hemang Doshi CISA Notes | Video + Notes | Popular among Indian aspirants |
| ISACA Community Study Groups | Forum | Good for exam experience sharing |
| This Playbook — Audit Guides | Practical | Maps exam concepts to real-world application |

---

## Quick Reference — Exam Day Mnemonics

```
RISK TREATMENT: AMMA → Avoid, Mitigate, Move (transfer), Accept

AUDIT EVIDENCE TYPES: PAID → Physical, Analytical, Inquiry (testimonial), Documentary

SAMPLING: SARJ → Statistical (Attribute/Random), Judgmental

INCIDENT RESPONSE: PICKER → Prepare, Identify, Contain, Keep evidence,
                            Eradicate, Recover

BCP SEQUENCE: BIRD → BIA, Identify critical, Recovery strategy, Develop plan

CONTROLS: PAD → Preventive (stop), Audit/Detective (find), Directive/Corrective (fix)
```

---

*Part of [IS Audit Playbook](../README.md)*
