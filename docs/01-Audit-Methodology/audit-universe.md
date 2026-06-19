# Audit Universe

> **Purpose:** Define, catalogue, and prioritize all auditable IT entities within scope of the IS audit function  
> **Standard:** IIA Standard 2010-A1, ISACA IT Audit Framework (ITAF)

---

## What Is an Audit Universe?

The audit universe is the **complete inventory of all auditable entities** — every system, process, technology, and organizational unit that the IS audit function could potentially review. It is the master list from which each year's audit plan is drawn.

```
AUDIT UNIVERSE
│
├── IT Infrastructure
│   ├── Servers (Windows, Linux)
│   ├── Network Devices (Firewalls, Switches, Routers)
│   ├── Identity & Access (Active Directory, PAM, IAM)
│   └── Storage & Backup
│
├── Databases
│   ├── Oracle, MSSQL, MySQL, PostgreSQL
│   └── NoSQL, Data Warehouses
│
├── Applications
│   ├── Core Business Applications (CBS, ERP, CRM)
│   ├── Web Applications (Internet-facing)
│   └── Internal Tools & Portals
│
├── IT Governance Processes (ITGC)
│   ├── Change Management
│   ├── Access Management
│   ├── Backup & Recovery
│   └── Incident Management
│
└── Third-Party / Vendor
    ├── Cloud Service Providers
    ├── Outsourced IT Services
    └── Software Vendors (SaaS, licensed)
```

---

## Audit Universe for BFSI Organizations

The following is a reference audit universe tailored for a banking or financial services entity, aligned to RBI and CERT-In regulatory scope:

### Tier 1 — Critical Systems (Mandatory Annual Audit)

| Entity | Description | Regulatory Driver |
|--------|-------------|------------------|
| **Core Banking System (CBS)** | Finacle, Temenos, BaNCS, FIS | RBI IT Framework |
| **Internet Banking Portal** | Retail & corporate net banking | RBI Cyber Framework |
| **Mobile Banking Application** | iOS/Android banking app | RBI Mobile Banking Guidelines |
| **SWIFT Infrastructure** | Messaging interface and HSM | RBI SWIFT Circular 2018 |
| **Payment Gateways** | UPI, IMPS, NEFT, RTGS | NPCI Guidelines, RBI |
| **ATM Network & Switch** | ATM host and network | RBI ATM Guidelines |
| **Active Directory / IAM** | Identity backbone | RBI Cyber Framework §6 |
| **Perimeter Firewalls** | Internet edge controls | RBI Cyber Framework §5 |
| **SIEM / SOC Platform** | Security monitoring | RBI Cyber Framework §12 |
| **Data Center Infrastructure** | Primary and DR DC | RBI BCP Circular |

### Tier 2 — High Importance (Annual or Biennial Audit)

| Entity | Description | Regulatory Driver |
|--------|-------------|------------------|
| **Enterprise Data Warehouse** | Analytics and reporting | DPDP Act, Data Governance |
| **ERP System** | Finance, HR, procurement | Internal financial controls |
| **Email Infrastructure** | Office 365 / on-premise Exchange | CERT-In log retention |
| **VPN / Remote Access** | Employee remote connectivity | RBI Cyber Framework §7 |
| **Privileged Access Management (PAM)** | CyberArk, Delinea etc. | RBI PAM requirement |
| **Database Servers (Prod)** | Oracle, MSSQL hosting CBS data | DPDP Act, RBI |
| **Backup & Recovery Systems** | Veeam, NetBackup, tape | RBI BCP Requirements |
| **Endpoint Security / EDR** | Antivirus, EDR deployment | RBI Cyber Framework |
| **Cloud Environments** | Azure / AWS / GCP workloads | RBI Cloud Circular 2023 |
| **Third-party Service Providers** | Outsourced IT/processing | RBI Outsourcing Guidelines |

### Tier 3 — Standard Importance (Biennial or Cyclical Audit)

| Entity | Description |
|--------|-------------|
| Internal HR / Payroll System | Employee data processing |
| Document Management System | Internal records |
| Internal Intranet / SharePoint | Knowledge management |
| Physical Access Control (CCTV, Biometric) | Physical security |
| Printers and Peripheral Devices | Data leakage risk |
| Development / UAT Environments | Code quality and data masking |
| Wi-Fi Infrastructure | Wireless network security |
| Software License Management | Compliance and cost risk |

---

## Audit Universe Template

Use this template to document and maintain your organization's audit universe:

```
AUDIT UNIVERSE — [ORGANIZATION NAME]
VERSION: [X.X]  |  LAST UPDATED: [Date]  |  OWNER: IS Audit Team

┌────┬──────────────────────────┬────────────┬──────────────┬──────────┬───────────┬────────────────┐
│ ID │ Entity Name              │ Tier       │ System Owner │ Last     │ Next      │ Inherent Risk  │
│    │                          │            │              │ Audited  │ Audit Due │ Rating         │
├────┼──────────────────────────┼────────────┼──────────────┼──────────┼───────────┼────────────────┤
│ 01 │ Core Banking System      │ Tier 1     │ IT Head      │ Q1 2024  │ Q1 2025   │ Very High      │
│ 02 │ Internet Banking Portal  │ Tier 1     │ Digital Head │ Q2 2024  │ Q2 2025   │ Very High      │
│ 03 │ Active Directory         │ Tier 1     │ IT Infra Mgr │ Q3 2024  │ Q3 2025   │ High           │
│ 04 │ Oracle Production DB     │ Tier 2     │ DBA Lead     │ Q4 2023  │ Q2 2025   │ High           │
│ 05 │ Perimeter Firewall       │ Tier 1     │ Network Mgr  │ Q1 2024  │ Q1 2025   │ Very High      │
│ .. │ ...                      │ ...        │ ...          │ ...      │ ...       │ ...            │
└────┴──────────────────────────┴────────────┴──────────────┴──────────┴───────────┴────────────────┘
```

---

## Maintaining the Audit Universe

The audit universe is a **living document** and must be updated when:

| Trigger | Action |
|---------|--------|
| New system goes into production | Add to Tier 1 or 2; schedule initial audit within 12 months |
| System is decommissioned | Mark as retired; retain historical audit records |
| System undergoes major upgrade | Reassess risk rating; potentially bring forward next audit |
| New regulation published | Review all entities for regulatory applicability |
| Security incident occurs | Escalate affected entity to Tier 1; immediate re-audit |
| Outsourcing arrangement changes | Reassess vendor entity; update scope |

**Review Frequency:** Full audit universe review — minimum annually, before annual audit plan is finalized.

---

## Mapping Audit Universe to Audit Plan

Not every entity is audited every year. The annual audit plan is derived from the universe using the risk-based approach:

```
Step 1: Score all entities (Inherent Risk × Control Weakness) → Priority Score
Step 2: Tier 1 entities with score ≥ 3.5 → Mandatory this year
Step 3: Tier 1 entities with score < 3.5 → Annual unless prior year was clean
Step 4: Tier 2 entities → Rank by priority score; select top N given budget
Step 5: Remaining Tier 2 & Tier 3 → Defer with management attestation
Step 6: Present plan to Audit Committee for approval
```

### Coverage Principle

The audit universe ensures **rotational coverage** — every Tier 1 system is audited at least annually, and no Tier 2 system goes more than 24 months without at least a targeted review.

```
YEAR 1: CBS, Internet Banking, AD, Firewalls, SWIFT, Payment Gateway (Tier 1 full coverage)
YEAR 2: CBS, Internet Banking, AD (always annual) + Database, ERP, VPN, Cloud (Tier 2 rotation)
YEAR 3: CBS, Internet Banking, AD + Backup/DR, PAM, Third-Party (Tier 2 rotation)
```

---

## Connection to COBIT Governance Objectives

The audit universe maps to COBIT 2019 governance and management objectives:

| Audit Universe Domain | COBIT Domain | Governance Objective |
|-----------------------|-------------|---------------------|
| IT Infrastructure | DSS | Manage Infrastructure |
| Identity & Access | DSS05 | Manage Security Services |
| Change Management | BAI06 | Manage IT Changes |
| Backup & Recovery | DSS04 | Manage Continuity |
| Incident Management | DSS02 | Manage Service Requests & Incidents |
| Applications | APO, BAI | Application Portfolio, Projects |
| Third-Party | APO10 | Manage Vendors |

---

*Part of [IS Audit Playbook](../README.md) | See also: [Risk-Based Approach](risk-based-approach.md)*
