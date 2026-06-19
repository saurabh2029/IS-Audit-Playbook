# CERT-In Directions 2022 — IS Auditor Reference

> **Issued by:** Indian Computer Emergency Response Team (CERT-In)  
> **Under:** Section 70B(6) of the Information Technology Act, 2000  
> **Direction:** No. 20(3)/2022-CERT-In dated **28 April 2022**  
> **Effective:** 60 days from issue (28 June 2022)  
> **Applicable to:** All entities in India — service providers, intermediaries, data centres, corporates, government bodies

---

## Why This Matters for IS Auditors

CERT-In Directions 2022 represent the most significant mandatory cybersecurity compliance obligation for Indian organizations since the IT Act itself. Unlike the RBI framework (applicable only to banks/NBFCs), CERT-In directions apply to **all entities operating in India** — making compliance verification a standard IS audit requirement across all sectors.

Non-compliance is a **criminal offence** under Section 70B(7) of the IT Act, punishable with imprisonment up to one year and/or fine.

---

## Key Mandatory Requirements

### 1. Cybersecurity Incident Reporting — 6-Hour Timeline

**Requirement:** All cybersecurity incidents must be reported to CERT-In **within 6 hours** of being noticed or brought to notice.

**Covered Incident Types (non-exhaustive):**

| Category | Examples |
|----------|---------|
| Targeted Scanning / Probing | Port scans of critical infrastructure |
| Compromise of Critical Systems | Server/database/endpoint compromise |
| Unauthorized Access | Unauthorized login to IT systems |
| Website Defacement | Defacement of government/critical websites |
| Malicious Code | Ransomware, malware, Trojans, worms |
| Attacks on Servers | Denial of Service, distributed DoS |
| Identity Theft / Spoofing | Phishing, fake websites, social engineering |
| Attacks on IoT / Critical Infrastructure | OT/SCADA systems, power, telecom |
| Data Breaches | Unauthorized exfiltration of data |
| Attacks on Fintech Applications | Digital payments, mobile banking apps |

**Audit Tests:**
- Verify an Incident Response procedure exists with CERT-In reporting step
- Verify designated point of contact for CERT-In reporting is appointed
- Check CERT-In reporting template is known to SOC/IR team
- Review past incidents — were reportable incidents reported within 6 hours?
- Check if CERT-In email/portal contact details are current

**Report to:** incident@cert-in.org.in  
**Portal:** https://www.cert-in.org.in

---

### 2. Mandatory Log Retention — 180 Days

**Requirement:** All ICT systems must maintain logs for a rolling period of **180 days** (approximately 6 months). Logs must be stored **within Indian jurisdiction**.

**Covered Log Types:**

| Log Type | Examples |
|----------|---------|
| Network logs | Firewall, IDS/IPS, router, switch logs |
| System logs | OS event logs, syslog, audit logs |
| Application logs | Web server, application server, API logs |
| Database logs | DBA activity, query logs, audit trail |
| Security device logs | SIEM, EDR, DLP, email gateway |
| Authentication logs | Active Directory, RADIUS, SSO, MFA |
| Physical access logs | CCTV, biometric, badge access |
| Virtual infrastructure logs | Hypervisor, cloud, container logs |

**Audit Tests:**
- Verify SIEM or centralized log store retention policy is set to ≥ 180 days
- Spot-check: query SIEM for logs from 170 days ago — do they exist?
- Verify logs are stored within India (not in foreign cloud regions)
- Verify log storage has adequate capacity and alerts for space exhaustion
- Confirm logs cannot be modified or deleted by regular/admin users
- Verify all covered log sources are actually forwarded to the log store

**Common Finding:** Many organizations have SIEM deployed but default retention of 30–90 days — direct CERT-In non-compliance.

---

### 3. Accurate System Clocks — NTP Synchronization

**Requirement:** All ICT systems must have **accurate system clocks** synchronized with the **Network Time Protocol (NTP) server of National Informatics Centre (NIC)** or **National Physical Laboratory (NPL)** or with NTP servers traceable to these.

**NTP Servers:**

| Server | IP / URL |
|--------|---------|
| NIC NTP (Primary) | time.nic.in |
| NIC NTP (Secondary) | time.pool.nic.in |
| NPL NTP | time.nplindia.org |

**Why this matters:** Log timestamps across different systems must be consistent. Time drift causes log correlation failures and can make incident investigation impossible.

**Audit Tests:**

```bash
# Linux — check NTP synchronization
timedatectl status
chronyc tracking
ntpq -p

# Windows — check W32tm synchronization
w32tm /query /status
w32tm /query /peers

# Fortinet
diagnose sys ntp status

# Palo Alto
show ntp
```

- Verify all production systems are pointing to NIC/NPL NTP or an internal NTP hierarchy that itself syncs to NIC/NPL
- Check time drift on sample devices — acceptable drift < 1 second
- Verify NTP configuration is protected (no unauthorized NTP server changes)

---

### 4. Virtual Asset Service Provider (VASP) Requirements

Organizations providing cryptocurrency exchanges, cryptocurrency wallets, or other virtual asset services must:
- Maintain Know Your Customer (KYC) records
- Maintain financial records for 5 years
- Report incidents to CERT-In

*(Primarily relevant for fintech organizations)*

---

### 5. Cloud & VPN Service Provider Requirements

Cloud Service Providers (CSPs) and Virtual Private Network (VPN) service providers must:
- Maintain accurate user registration and KYC data for **5 years** even after cancellation
- Maintain logs of subscribers and customers for **5 years**
- Report incidents to CERT-In

**Audit relevance:** When auditing third-party cloud providers, verify their CERT-In compliance certificates or confirm contractual obligations.

---

### 6. Data Localization

All log data and required records must be **stored within the territory of India**. Organizations using global SIEM or cloud logging services must verify their data residency settings.

**Audit Tests:**
- Verify SIEM / log storage is hosted in Indian data centers
- For cloud SIEM (Azure Sentinel, Splunk Cloud): verify region is `India Central`, `India South`, or equivalent
- Obtain data residency certificates from cloud providers if applicable

---

## CERT-In Incident Report Format

When reporting incidents, the following information must be provided:

```
CERT-IN INCIDENT REPORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. REPORTING ENTITY
   Organization Name:
   Organization Type: (Bank / Corporate / Government / Other)
   Contact Name:
   Designation:
   Email:
   Phone:

2. INCIDENT DETAILS
   Date/Time of Discovery:           [DD-MM-YYYY HH:MM]
   Date/Time of Occurrence (if known): [DD-MM-YYYY HH:MM]
   Incident Type:                    (from covered incident types)
   Incident Description:
   (What happened, how discovered, initial assessment)

3. AFFECTED SYSTEMS
   Systems/Services Affected:
   Number of Users Impacted:
   Geographic Scope:
   Sensitive Data Involved: [Yes/No — PII/Financial/Government]

4. INITIAL IMPACT ASSESSMENT
   Business Impact:
   Operational Impact:
   Financial Impact (if known):

5. ACTIONS TAKEN SO FAR
   Containment Actions:
   Notification to Other Authorities:

6. ASSISTANCE REQUIRED FROM CERT-In
   Technical Assistance:
   Forensic Support:
   Other:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Report to: incident@cert-in.org.in
```

---

## Compliance Checklist for IS Auditors

| # | Requirement | Audit Test | Status |
|---|------------|-----------|--------|
| 1 | Incident reporting SOP includes CERT-In 6-hour timeline | Review IR procedure | — |
| 2 | CERT-In POC designated and communicated to SOC | Verify POC appointment | — |
| 3 | CERT-In reporting tested in at least one drill | Check drill records | — |
| 4 | All log sources forwarded to central log store | SIEM source inventory | — |
| 5 | Log retention set to ≥ 180 days | Check retention policy | — |
| 6 | Log data stored in India | Verify data residency | — |
| 7 | Logs are tamper-proof / read-only | Verify access controls on log store | — |
| 8 | All systems synchronized to NIC/NPL NTP | Sample NTP status check | — |
| 9 | Cloud/VPN providers are CERT-In compliant | Verify vendor compliance | — |
| 10 | Past incidents were reported within 6 hours | Review incident history | — |

---

## Common Audit Findings under CERT-In 2022

| Finding | Risk Rating |
|---------|------------|
| No CERT-In incident reporting procedure | 🔴 Critical |
| Log retention < 180 days | 🔴 Critical |
| No NTP synchronization | 🟠 High |
| Logs stored outside India (foreign cloud region) | 🔴 Critical |
| Reportable incident not reported to CERT-In | 🔴 Critical |
| SIEM sources incomplete (key systems not forwarded) | 🔴 Critical |
| No designated CERT-In POC | 🟠 High |
| NTP not configured to NIC/NPL | 🟡 Medium |

---

*Part of [IS Audit Playbook](../README.md) | See also: [RBI Cyber Framework](RBI-Cyber-Framework.md)*
