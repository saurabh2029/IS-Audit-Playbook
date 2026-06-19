# ISACA COBIT 2019 — IS Auditor Reference

> **Standard:** COBIT 2019 (Control Objectives for Information and Related Technologies)  
> **Publisher:** ISACA  
> **Replaces:** COBIT 5 (2012)  
> **Primary Use:** IT Governance assurance, IS audit criteria, control objective mapping

---

## What Is COBIT?

COBIT (Control Objectives for Information and Related Technologies) is a globally recognized framework for **IT governance and management**. Published by ISACA, it provides:

- A comprehensive set of governance and management **objectives** for IT
- **Design factors** to tailor the framework to organizational context
- **Capability and maturity models** for assessing control effectiveness
- **Audit criteria** used by IS auditors to evaluate IT governance

COBIT 2019 restructured the earlier COBIT 5 model from process domains into a **system of governance and management objectives**.

---

## COBIT 2019 Structure

```
COBIT 2019
│
├── GOVERNANCE (EDM Domain)           — Board/Leadership level
│   ├── EDM01  Ensure Governance Framework
│   ├── EDM02  Ensure Benefits Delivery
│   ├── EDM03  Ensure Risk Optimization
│   ├── EDM04  Ensure Resource Optimization
│   └── EDM05  Ensure Stakeholder Engagement
│
└── MANAGEMENT (APO, BAI, DSS, MEA Domains)  — Management/IT level
    │
    ├── ALIGN, PLAN & ORGANIZE (APO)
    ├── BUILD, ACQUIRE & IMPLEMENT (BAI)
    ├── DELIVER, SERVICE & SUPPORT (DSS)
    └── MONITOR, EVALUATE & ASSESS (MEA)
```

---

## Management Objectives — IS Audit Reference

### APO — Align, Plan & Organize

| Objective | Name | IS Audit Relevance |
|-----------|------|--------------------|
| APO01 | Manage the IT Management Framework | IT governance structure, policies, roles |
| APO02 | Manage Strategy | IT strategy alignment with business |
| APO03 | Manage Enterprise Architecture | IT architecture governance |
| APO04 | Manage Innovation | Technology change risk |
| APO05 | Manage Portfolio | Project and investment governance |
| APO06 | Manage Budget and Costs | IT financial management |
| APO07 | Manage Human Resources | IT staffing, training, segregation of duties |
| **APO08** | **Manage Relationships** | Vendor and stakeholder management |
| **APO09** | **Manage Service Agreements** | SLA governance, third-party assurance |
| **APO10** | **Manage Vendors** | Vendor risk, third-party audits |
| **APO11** | **Manage Quality** | Quality assurance processes |
| **APO12** | **Manage Risk** | IT risk assessment and treatment |
| **APO13** | **Manage Security** | Information security governance |
| APO14 | Manage Data | Data governance and lifecycle |

> 🔍 **Audit Focus:** APO12 and APO13 are most frequently evaluated in IS audits. APO10 is critical for organizations with significant outsourcing.

---

### BAI — Build, Acquire & Implement

| Objective | Name | IS Audit Relevance |
|-----------|------|--------------------|
| **BAI01** | **Manage Programs** | Project governance, IT project oversight |
| BAI02 | Manage Requirements Definition | System requirements and approvals |
| BAI03 | Manage Solutions Identification & Build | SDLC controls |
| BAI04 | Manage Availability & Capacity | Performance and capacity planning |
| BAI05 | Manage Organizational Change Enablement | Change adoption controls |
| **BAI06** | **Manage IT Changes** | **Change management — core ITGC** |
| **BAI07** | **Manage IT Change Acceptance & Transitioning** | Release management, go-live controls |
| BAI08 | Manage Knowledge | Knowledge management |
| BAI09 | Manage Assets | IT asset management |
| BAI10 | Manage Configuration | CMDB, configuration baseline |
| BAI11 | Manage Projects | IT project execution |

> 🔍 **Audit Focus:** BAI06 (Change Management) is one of the four key ITGCs tested in every IS audit. BAI07 covers release and deployment controls.

---

### DSS — Deliver, Service & Support

| Objective | Name | IS Audit Relevance |
|-----------|------|--------------------|
| **DSS01** | **Manage Operations** | Operational controls, job scheduling |
| **DSS02** | **Manage Service Requests & Incidents** | Incident management ITGC |
| DSS03 | Manage Problems | Problem management, root cause analysis |
| **DSS04** | **Manage Continuity** | BCP/DR — backup and recovery ITGC |
| **DSS05** | **Manage Security Services** | Security operations, access control |
| DSS06 | Manage Business Process Controls | Application controls |

> 🔍 **Audit Focus:** DSS05 maps directly to access management and security controls. DSS04 maps to backup/recovery and BCP testing.

---

### MEA — Monitor, Evaluate & Assess

| Objective | Name | IS Audit Relevance |
|-----------|------|--------------------|
| **MEA01** | **Manage Performance & Conformance Monitoring** | KPIs, dashboards, control monitoring |
| **MEA02** | **Manage System of Internal Control** | Control self-assessment, ITGC monitoring |
| **MEA03** | **Manage Compliance with External Requirements** | Regulatory compliance (RBI, CERT-In) |
| MEA04 | Manage Assurance | Internal and external audit coordination |

> 🔍 **Audit Focus:** MEA03 is the primary objective tested when auditing regulatory compliance (RBI, ISO 27001, CERT-In).

---

## COBIT Capability Model

COBIT 2019 uses a **capability model** (0–5) to rate how well a management objective is achieved:

| Level | Name | Description |
|-------|------|-------------|
| **0** | Incomplete | Process is not implemented or does not achieve its purpose |
| **1** | Initial | Process achieves its purpose through undocumented, ad hoc practices |
| **2** | Managed | Process is planned, monitored, and adjusted; outputs are defined |
| **3** | Defined | Process is documented, standardized, and consistently followed |
| **4** | Quantitative | Process performance is measured and controlled quantitatively |
| **5** | Optimizing | Process is continuously improved based on performance data |

**For most IS audit purposes:**
- Level 1 → 🔴 High risk finding — controls exist but are informal
- Level 2 → 🟠 Finding — controls exist but are inconsistently applied
- Level 3 → 🟡 Satisfactory for most controls
- Level 4–5 → Best practice; uncommon outside mature organizations

---

## Key COBIT Mappings for BFSI IS Audits

### Access Management Audit → COBIT Mapping

| Control Area | COBIT Objective | Control Activity |
|-------------|----------------|-----------------|
| User provisioning process | DSS05.04 | Access requests require approval |
| Privileged access governance | APO13, DSS05.04 | Privileged accounts are documented and reviewed |
| Access review / recertification | DSS05.04 | Periodic access review by data owners |
| Account termination | DSS05.04 | Timely deprovisioning on separation |
| Segregation of duties | APO01.02 | Conflicting roles are identified and mitigated |

### Change Management Audit → COBIT Mapping

| Control Area | COBIT Objective | Control Activity |
|-------------|----------------|-----------------|
| Change request and approval | BAI06.01 | All changes are formally raised, reviewed, approved |
| Change testing | BAI06.02 | Changes tested in non-production before deployment |
| Emergency change process | BAI06.03 | Emergency changes have retrospective approval |
| Change failure and rollback | BAI06.04 | Rollback plans defined for all significant changes |

### Incident Management Audit → COBIT Mapping

| Control Area | COBIT Objective | Control Activity |
|-------------|----------------|-----------------|
| Incident detection | DSS02.01 | Alerts and detection mechanisms exist |
| Incident logging | DSS02.02 | All incidents are recorded in a ticket system |
| Incident escalation | DSS02.03 | Escalation matrix is defined and followed |
| Post-incident review | DSS02.07 | RCAs conducted for major incidents |

---

## COBIT Design Factors

COBIT 2019 introduced **Design Factors** — variables that determine how the framework should be applied to a specific organization. IS auditors use these to tailor their audit criteria:

| Design Factor | Questions to Ask |
|--------------|-----------------|
| Enterprise Strategy | Is IT strategy aggressive/defensive/cost-focused? |
| Enterprise Goals | What are the top IT-related enterprise goals? |
| Risk Profile | What is the organization's risk appetite? |
| I&T Related Issues | Are there recurring IT problems? |
| Threat Landscape | What external threats is the organization facing? |
| Compliance Requirements | Which regulations apply? (RBI, ISO, CERT-In) |
| Role of IT | Is IT a strategic enabler or utility? |
| IT Implementation Model | Cloud, outsourced, on-premises, hybrid? |

---

## How to Use COBIT in an IS Audit

### Step 1 — Map Audit Objectives to COBIT
Identify which COBIT management objectives relate to your audit scope.

```
Audit: Change Management → COBIT BAI06, BAI07
Audit: Access Management → COBIT DSS05.04, APO07
Audit: Incident Management → COBIT DSS02
Audit: BCP/DR → COBIT DSS04
```

### Step 2 — Define Control Activities
For each management objective, identify the specific control activities that should exist.

### Step 3 — Test Against COBIT Criteria
Test whether each control activity is designed and operating at the required capability level.

### Step 4 — Report Gaps Against COBIT
In findings, cite specific COBIT objectives as criteria alongside internal policy.

```
Example criteria line:
"COBIT 2019 BAI06.01 requires that all changes to production systems are 
formally documented, assessed, authorized, and tracked through a defined 
change management process."
```

---

## COBIT vs Other Frameworks

| Framework | Publisher | Focus | Best Used For |
|-----------|-----------|-------|--------------|
| **COBIT 2019** | ISACA | IT Governance | IS audit criteria, IT governance assurance |
| **ISO/IEC 27001** | ISO | Information Security | ISMS audit, security certification |
| **NIST CSF** | NIST (US) | Cybersecurity | Risk-based cyber posture assessment |
| **ITIL 4** | AXELOS | IT Service Management | Service delivery quality |
| **ISO 20000** | ISO | IT Service Mgmt | Service management certification |
| **RBI Cyber Framework** | RBI | Banking Cybersecurity | Indian banking regulatory compliance |

> 💡 **Practical tip:** In Indian BFSI audits, COBIT provides the **governance criteria**, ISO 27001 provides **security control criteria**, and the **RBI/CERT-In frameworks** provide **regulatory compliance criteria**. An effective IS auditor maps findings across all three.

---

*Part of [IS Audit Playbook](../README.md) | See also: [ISO 27001](ISO-27001.md) | [RBI Framework](RBI-Cyber-Framework.md)*
