# 🛡️ IS Audit Playbook

> **A practitioner's open-source reference for Information Systems Audit** — covering methodology, checklists, evidence templates, findings, and reporting for enterprise IT environments, with a focus on BFSI regulatory compliance (RBI, CERT-In, DPDP Act).

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Maintained](https://img.shields.io/badge/Maintained-Yes-green.svg)]()
[![Frameworks](https://img.shields.io/badge/Frameworks-COBIT%20%7C%20ISO27001%20%7C%20NIST-blue)]()
[![BFSI Focus](https://img.shields.io/badge/Focus-BFSI%20%7C%20RBI%20%7C%20CERT--In-orange)]()

---

## 📌 About This Repository

This playbook is built from real-world IS audit experience in Banking and Financial Services environments. It is designed to serve:

- **IS Auditors** looking for structured checklists and evidence guides
- **SOC / Security professionals** transitioning into IS audit roles
- **IT teams** seeking to understand what auditors look for
- **Students and aspirants** preparing for CISA, CISM, or IS audit interviews

> ⚠️ All checklists and templates are generalized for educational use. Adapt to your organization's specific context, regulatory obligations, and risk appetite.

---

## 📂 Repository Structure

```
IS-Audit-Playbook/
│
├── 01-Audit-Methodology/           ← IS Audit lifecycle, risk-based approach
├── 02-Standards-and-Frameworks/    ← COBIT, ISO 27001, RBI, CERT-In, NIST
├── 03-Asset-Audit-Guides/
│   ├── Application-Audit/
│   ├── OS-Audit/                   ← Windows Server, Linux
│   ├── Network-Devices/            ← Firewall, Switch, Router
│   ├── Active-Directory/           ← AD, GPO, Privileged Access
│   ├── Database-Audit/             ← Oracle, MSSQL, MySQL
│   ├── Cloud-Audit/                ← Azure, AWS
│   └── Endpoint-EDR-Audit/
├── 04-ITGC-Audit/                  ← Change, Access, BCP, Incident Mgmt
├── 05-Audit-Reporting/             ← Templates, finding writing, risk matrix
├── 06-Interview-QnA/               ← IS Audit interview preparation
└── 07-Tools-and-Scripts/           ← AD scripts, DB queries, scan templates
```

---

## 🗺️ Quick Navigation

### 🔁 Methodology
| Document | Description |
|----------|-------------|
| [Audit Lifecycle](01-Audit-Methodology/audit-lifecycle.md) | End-to-end IS audit process |
| [Risk-Based Approach](01-Audit-Methodology/risk-based-approach.md) | How to scope and prioritize audits |
| [Audit Universe](01-Audit-Methodology/audit-universe.md) | Defining auditable entities |

### 📜 Standards & Frameworks
| Standard | Focus Area |
|----------|-----------|
| [ISACA COBIT 2019](02-Standards-and-Frameworks/ISACA-COBIT.md) | IT Governance & Management |
| [ISO/IEC 27001:2022](02-Standards-and-Frameworks/ISO-27001.md) | Information Security Management |
| [RBI Cybersecurity Framework](02-Standards-and-Frameworks/RBI-Cyber-Framework.md) | Indian Banking Regulations |
| [CERT-In Directions 2022](02-Standards-and-Frameworks/CERT-In-Directions.md) | Incident Reporting Compliance |
| [NIST CSF 2.0](02-Standards-and-Frameworks/NIST-CSF.md) | Cybersecurity Framework |

### 🖥️ Asset Audit Guides
| Asset Type | Checklist | Evidence Guide | Sample Findings |
|-----------|-----------|---------------|-----------------|
| [Application Audit](03-Asset-Audit-Guides/Application-Audit/checklist.md) | ✅ | ✅ | ✅ |
| [Windows Server](03-Asset-Audit-Guides/OS-Audit/windows-server.md) | ✅ | ✅ | ✅ |
| [Linux Systems](03-Asset-Audit-Guides/OS-Audit/linux-systems.md) | ✅ | ✅ | ✅ |
| [Firewall Audit](03-Asset-Audit-Guides/Network-Devices/firewall-audit.md) | ✅ | ✅ | ✅ |
| [Switch & Router](03-Asset-Audit-Guides/Network-Devices/switch-router-audit.md) | ✅ | ✅ | ✅ |
| [Active Directory](03-Asset-Audit-Guides/Active-Directory/ad-audit-guide.md) | ✅ | ✅ | ✅ |
| [Oracle Database](03-Asset-Audit-Guides/Database-Audit/oracle-audit.md) | ✅ | ✅ | ✅ |
| [MSSQL Database](03-Asset-Audit-Guides/Database-Audit/mssql-audit.md) | ✅ | ✅ | ✅ |
| [Azure Cloud](03-Asset-Audit-Guides/Cloud-Audit/azure-audit.md) | ✅ | ✅ | ✅ |

### 📋 ITGC Domains
| Domain | Coverage |
|--------|----------|
| [Access Management](04-ITGC-Audit/access-management.md) | Provisioning, review, termination |
| [Change Management](04-ITGC-Audit/change-management.md) | SDLC, approvals, testing, rollback |
| [Backup & Recovery](04-ITGC-Audit/backup-recovery.md) | BCP/DR testing, RTO/RPO |
| [Incident Management](04-ITGC-Audit/incident-management.md) | Detection, response, reporting |

### 📝 Audit Reporting
| Resource | Description |
|----------|------------|
| [Finding Writing Guide](05-Audit-Reporting/finding-writing-guide.md) | PCCER structure for observations |
| [Risk Rating Matrix](05-Audit-Reporting/risk-rating-matrix.md) | Critical / High / Medium / Low criteria |
| [Report Structure](05-Audit-Reporting/report-structure.md) | Full audit report format |
| [Audit Report Template](05-Audit-Reporting/templates/audit-report-template.md) | Ready-to-use template |

---

## 🏦 BFSI Regulatory Mapping

This playbook includes specific mappings to Indian BFSI regulations:

| Regulation | Scope |
|-----------|-------|
| **RBI Cybersecurity Framework (2016)** | Baseline cyber controls for banks |
| **RBI IT Framework for NBFCs** | IT governance for NBFCs |
| **CERT-In Directions (April 2022)** | Mandatory incident reporting, log retention |
| **DPDP Act 2023** | Data privacy obligations for financial entities |
| **NPCI Guidelines** | UPI / payment system security controls |
| **SEBI Cybersecurity Circular** | Controls for market infrastructure institutions |

---

## 🧩 How to Use This Playbook

### For Audit Planning
1. Start with [Audit Lifecycle](01-Audit-Methodology/audit-lifecycle.md)
2. Map audit scope to the [Audit Universe](01-Audit-Methodology/audit-universe.md)
3. Apply [Risk-Based Approach](01-Audit-Methodology/risk-based-approach.md) to prioritize

### For Fieldwork
1. Navigate to the relevant asset audit guide under `03-Asset-Audit-Guides/`
2. Use the checklist to drive walkthroughs and testing
3. Follow the evidence collection guide for documentation

### For Reporting
1. Draft findings using the [Finding Writing Guide](05-Audit-Reporting/finding-writing-guide.md)
2. Rate risk using the [Risk Rating Matrix](05-Audit-Reporting/risk-rating-matrix.md)
3. Compile using the [Audit Report Template](05-Audit-Reporting/templates/audit-report-template.md)

---

## 📊 Audit Finding Format (PCCER)

All findings in this playbook follow the **PCCER structure**:

| Component | Description |
|-----------|------------|
| **P** — Process/Control | The control area being reviewed |
| **C** — Condition | What was observed (the gap) |
| **C** — Criteria | What should exist (policy/standard/regulation) |
| **E** — Effect | Business impact of the gap |
| **R** — Recommendation | Suggested remediation action |

---

## 🤝 Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) before submitting pull requests. Areas where contributions are especially valuable:

- Audit checklists for additional asset types (SAP, VMware, Kubernetes)
- Regulatory mappings for other countries or sectors
- Sample findings based on anonymized real-world observations
- Automation scripts in `07-Tools-and-Scripts/`

---

## 📄 License

This project is licensed under the [MIT License](LICENSE). Use freely for personal, professional, or educational purposes with attribution.

---

## 👤 Author

**Saurabh Anand**  
Assistant Manager — Security Operations | CISM | CEH | AZ-500 | SC-200  
State Bank of India  

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue?logo=linkedin)](https://linkedin.com/in/YOUR-HANDLE)
[![GitHub](https://img.shields.io/badge/GitHub-Follow-black?logo=github)](https://github.com/YOUR-HANDLE)

---

> *"The goal of an IS audit is not to find fault — it is to provide assurance that controls are working as intended, and to add value by identifying where they are not."*
