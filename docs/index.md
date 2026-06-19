# IS Audit Playbook

!!! tip "A practitioner-built reference for IS Auditors"
    Checklists, SQL/CLI queries, finding templates, and regulatory mappings for auditing IT assets in enterprise and BFSI environments. Built on real-world audit experience — not theory alone.

---

## What Is This?

The **IS Audit Playbook** is an open-source knowledge base covering the full Information Systems audit lifecycle — from planning and fieldwork through reporting and follow-up. Every guide includes:

- ✅ **Structured checklists** with pass/fail criteria
- 🖥️ **CLI and SQL queries** ready to run during fieldwork
- 📋 **Evidence collection guides** per control area
- 🔍 **Sample findings** in PCCER format with risk ratings
- 🏦 **BFSI regulatory mappings** (RBI, CERT-In, DPDP Act)

---

## Quick Start

=== "I'm an IS Auditor"

    1. Review the [Audit Lifecycle](01-Audit-Methodology/audit-lifecycle.md) to understand the end-to-end process
    2. Use the [Risk-Based Approach](01-Audit-Methodology/risk-based-approach.md) to scope your engagement
    3. Navigate to the relevant [Asset Audit Guide](#asset-audit-guides) for your fieldwork
    4. Write findings using the [Finding Writing Guide](05-Audit-Reporting/finding-writing-guide.md)

=== "I'm Preparing for Interviews"

    1. Start with [IS Audit Interview Q&A](06-Interview-QnA/IS-audit-interview-questions.md)
    2. Understand key frameworks: [COBIT](02-Standards-and-Frameworks/ISACA-COBIT.md), [ISO 27001](02-Standards-and-Frameworks/ISO-27001.md), [RBI Framework](02-Standards-and-Frameworks/RBI-Cyber-Framework.md)
    3. Practise PCCER finding writing using the [Finding Guide](05-Audit-Reporting/finding-writing-guide.md)

=== "I'm an IT/Security Professional"

    1. Use asset guides to understand what auditors check in your domain
    2. Self-assess using checklists before an external audit
    3. Refer to [ITGC guides](04-ITGC-Audit/access-management.md) for governance control awareness

---

## Asset Audit Guides

<div class="grid cards" markdown>

-   :material-microsoft-windows: **Active Directory**

    ---
    Privileged accounts, GPOs, Kerberos, audit logging, 50+ controls with PowerShell

    [:octicons-arrow-right-24: AD Audit Guide](03-Asset-Audit-Guides/Active-Directory/ad-audit-guide.md)

-   :material-database: **Oracle Database**

    ---
    Default accounts, DBA roles, TDE, listener, unified audit trail — full SQL query set

    [:octicons-arrow-right-24: Oracle Audit](03-Asset-Audit-Guides/Database-Audit/oracle-audit.md)

-   :material-database-cog: **MSSQL Server**

    ---
    SA account, sysadmin roles, surface area config, SQL Server Audit — T-SQL included

    [:octicons-arrow-right-24: MSSQL Audit](03-Asset-Audit-Guides/Database-Audit/mssql-audit.md)

-   :material-wall-fire: **Firewall (FortiGate + Palo Alto)**

    ---
    Dual-platform guide covering ruleset review, threat profiles, management hardening

    [:octicons-arrow-right-24: Firewall Audit](03-Asset-Audit-Guides/Network-Devices/firewall-audit.md)

</div>

---

## BFSI Regulatory Coverage

| Regulation | Covered In |
|-----------|-----------|
| RBI Cybersecurity Framework (2016) | All asset guides — regulatory mapping tables |
| RBI IT Framework for NBFCs | [COBIT](02-Standards-and-Frameworks/ISACA-COBIT.md), [Access Mgmt](04-ITGC-Audit/access-management.md) |
| CERT-In Directions 2022 | [CERT-In Guide](02-Standards-and-Frameworks/CERT-In-Directions.md), all log retention controls |
| DPDP Act 2023 | Database guides — encryption and data handling |
| ISO/IEC 27001:2022 | All guides — Annex A control mapping |
| NIST CSF 2.0 | All guides — function/category mapping |

---

## Finding Format Used Throughout

All sample findings follow the **PCCER structure**:

| | Component | Purpose |
|--|-----------|---------|
| **P** | Process / Control | Domain context |
| **C** | Condition | What was found (fact-based) |
| **C** | Criteria | What should exist (cited standard) |
| **E** | Effect | Business impact |
| **R** | Recommendation | Specific remediation action |

---

!!! note "Disclaimer"
    All checklists and templates are generalized for educational and professional development use. Adapt to your organization's specific regulatory obligations, risk appetite, and technology environment. No proprietary or client-specific information is contained in this repository.

---

*Maintained by [Saurabh Anand](https://linkedin.com/in/YOUR-HANDLE) | [GitHub](https://github.com/YOUR-USERNAME/IS-Audit-Playbook)*
