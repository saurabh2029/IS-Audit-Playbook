# IS Audit Interview Questions & Answers

> **Purpose:** Comprehensive Q&A bank for IS Audit interviews targeting roles at banks, NBFCs, DFIs, and consulting firms  
> **Roles covered:** IS Auditor, IT Audit Manager, Deputy Manager (IS Audit), Internal Auditor (IT)  
> **Level:** Entry to mid-level (0–5 years experience)

---

## Section 1 — IS Audit Fundamentals

**Q1. What is IS Audit and how does it differ from a financial audit?**

> **A:** Information Systems Audit is an independent examination of IT controls, processes, and infrastructure to assess whether they adequately protect assets, maintain data integrity, support business objectives, and comply with applicable regulations. Financial audit focuses on the accuracy and fairness of financial statements; IS audit focuses on the IT systems that produce, process, and protect financial and operational data. IS audit is a pre-condition for effective financial audit — if IT systems are unreliable, the financial data they generate cannot be trusted. IS audit covers areas such as access controls, change management, system configuration, logging, and disaster recovery that a financial auditor does not examine in depth.

---

**Q2. What are the four key IT General Controls (ITGCs)?**

> **A:** The four core ITGCs are:
> 1. **Access Management** — ensuring only authorized users have appropriate access to systems (provisioning, deprovisioning, access reviews, privilege management)
> 2. **Change Management** — ensuring changes to production systems are formally authorized, tested, and documented before deployment
> 3. **Backup & Recovery** — ensuring data is backed up regularly, backups are tested, and recovery procedures meet business continuity requirements
> 4. **Incident Management** — ensuring security and operational incidents are detected, logged, investigated, and resolved in a timely manner
>
> These four controls underpin all application-level controls — if ITGCs fail, application controls built on them cannot be relied upon.

---

**Q3. What is the PCCER format for audit findings?**

> **A:** PCCER is the standard structure for writing audit findings:
> - **P — Process/Control:** The control domain being examined (e.g., Access Management, Firewall Configuration)
> - **C — Condition:** What the auditor actually found — a factual, evidence-based observation with specific numbers and system names
> - **C — Criteria:** The benchmark against which the condition is measured — a specific policy section, regulation, or standard
> - **E — Effect:** The actual or potential business impact — confidentiality, integrity, availability, compliance, or financial harm
> - **R — Recommendation:** Specific, actionable steps to remediate the gap — immediate and long-term
>
> The PCCER format ensures findings are complete, defensible, and actionable — not just a list of problems without context or guidance.

---

**Q4. What is the difference between inherent risk, control risk, and residual risk?**

> **A:**
> - **Inherent Risk:** The risk that exists before any controls are applied. It reflects the nature of the asset, sensitivity of data, and the external threat environment. Example: An internet-facing payment gateway has high inherent risk by nature.
> - **Control Risk:** The risk that the controls in place fail to prevent or detect the inherent risk. High control risk means controls are poorly designed, not consistently applied, or insufficient.
> - **Residual Risk:** The risk that remains after controls are applied. Expressed as: Residual Risk = Inherent Risk × (1 − Control Effectiveness). The organization's risk appetite determines whether residual risk is acceptable.
>
> An auditor's primary job is to assess whether residual risk is within the organization's defined risk appetite.

---

**Q5. What is the audit lifecycle?**

> **A:** The IS audit lifecycle has five phases:
> 1. **Planning:** Define objectives, scope, risk assessment, audit program
> 2. **Fieldwork:** Evidence collection through inquiry, observation, inspection, re-performance, and data analysis
> 3. **Analysis:** Evaluate evidence against criteria; root cause analysis; assess control effectiveness
> 4. **Reporting:** Draft findings in PCCER format; overall audit opinion; management review
> 5. **Follow-up:** Track remediation of open findings; validate closure evidence; escalate overdue items

---

## Section 2 — Standards and Frameworks

**Q6. What is COBIT and how is it used in IS audits?**

> **A:** COBIT (Control Objectives for Information and Related Technologies), published by ISACA, is the primary IT governance framework used in IS audits. COBIT 2019 organizes IT governance and management into governance objectives (EDM domain) and management objectives (APO, BAI, DSS, MEA domains). IS auditors use COBIT in three ways: (1) as a source of audit criteria — what controls should exist, (2) as a capability maturity model — to rate how well controls are implemented (Level 0–5), and (3) as a mapping framework to align audit findings to specific governance objectives. For example, when auditing change management, the auditor references COBIT BAI06 (Manage IT Changes) and BAI07 (Manage IT Change Acceptance and Transitioning) as the control criteria.

---

**Q7. What are the key requirements of the RBI Cybersecurity Framework?**

> **A:** The RBI Cybersecurity Framework (2016 circular, updated by Master Direction 2021) mandates Indian banks to:
> - Appoint a CISO reporting to the Board
> - Maintain a Board-approved Cyber Security Policy reviewed annually
> - Implement network segmentation with DMZ, IDS/IPS, and DLP
> - Enforce MFA for privileged and remote access
> - Deploy a 24x7 SOC with centralized SIEM
> - Conduct VAPT at least annually
> - Maintain logs for 180 days (reinforced by CERT-In Directions 2022)
> - Develop a Cyber Crisis Management Plan (CCMP)
> - Report cyber incidents to RBI and CERT-In within 6 hours
> - Conduct annual DR drills with board reporting
>
> Non-compliance attracts regulatory action and adverse audit observations in the RBI IT Examination.

---

**Q8. What did CERT-In Directions 2022 mandate, and why are they significant?**

> **A:** CERT-In Directions (April 2022) under Section 70B(6) of the IT Act created three core mandatory obligations for all organizations in India: (1) Report cybersecurity incidents to CERT-In within **6 hours** of detection — this is a hard deadline with no grace period; (2) Maintain all ICT logs for a minimum of **180 days** on a rolling basis, stored within Indian jurisdiction; (3) Synchronize all system clocks with the **NIC or NPL NTP server**. These directions are significant because they apply to all Indian organizations (not just banks), non-compliance is a criminal offence under the IT Act, and they set a high bar for log retention that many organizations were not meeting. For IS auditors, testing CERT-In compliance is now a standard element of every audit engagement.

---

**Q9. How does ISO 27001 differ from the RBI Cybersecurity Framework?**

> **A:** ISO 27001 is a voluntary international standard for Information Security Management Systems (ISMS) — organizations can choose to pursue certification. It provides a comprehensive set of 93 controls across 4 organizational, 8 people, 14 physical, and 34 technological domains (2022 version). It is framework-agnostic and applicable globally. The RBI Cybersecurity Framework is a **mandatory regulation** for Indian scheduled commercial banks — non-compliance is a regulatory breach, not a certification gap. The RBI framework is more prescriptive in some areas (e.g., specific 6-hour reporting deadline) while ISO 27001 is principles-based. In practice, banks that are ISO 27001 certified still require additional controls to meet RBI-specific requirements. An IS auditor working in BFSI must understand both and map findings to both where applicable.

---

## Section 3 — Access Management

**Q10. What is the principle of least privilege and how do you test it in an audit?**

> **A:** Least privilege means every user, process, and system should have only the minimum access required to perform their defined function — no more, no less. To test it during an audit: (1) Obtain the list of all users and their assigned roles or permissions; (2) Compare assigned access against the role/job function definition — is there excess access? (3) Query for high-risk permissions granted to non-privileged accounts (e.g., DBA role in Oracle, sysadmin in SQL Server, Domain Admin in AD); (4) Check for accumulated access — users who changed roles but retained prior access; (5) Review the SoD matrix for toxic combinations. The goal is to identify cases where access exceeds business need, as excess access is the pre-condition for insider fraud and the blast radius of external compromise.

---

**Q11. What is Segregation of Duties? Give three examples of SoD conflicts in banking.**

> **A:** Segregation of Duties (SoD) is a control principle that ensures no single individual can perform two or more steps of a critical process that, if combined, could enable fraud or errors to go undetected. Three banking-specific SoD conflicts:
> 1. **Payment Initiator + Payment Approver:** A user who can both create and approve payment transactions can authorize unauthorized fund transfers.
> 2. **Vendor Master Maintenance + Payment Processing:** A user who can add/modify vendor bank accounts and also process payments could redirect legitimate payments to fraudulent accounts.
> 3. **Developer + Production System Access:** A developer with production access can deploy unauthorized or untested code changes, bypassing the change management control.
>
> In an audit, SoD is tested by obtaining the role/access matrix and cross-checking against a defined conflict matrix, then identifying any users who hold conflicting combinations.

---

**Q12. What is the joiner-mover-leaver process and what are the key risks at each stage?**

> **A:** The joiner-mover-leaver framework defines the three lifecycle stages of a user's access:
> - **Joiner (Provisioning):** Risk — access granted without proper approval, or access is broader than the role requires. Test: verify formal access requests with manager approval exist for sampled new hires; access granted matches role definition.
> - **Mover (Modification):** Risk — old access from prior role is retained when the user changes roles ("access creep"). Test: sample internal transfers; verify old access was revoked before or concurrent with new access grant.
> - **Leaver (Deprovisioning):** Risk — accounts of ex-employees remain active after separation, enabling unauthorized access. This is the highest-risk stage. Test: cross-reference HR termination list against system accounts; verify disable date ≤ last working date; check for post-separation logon events.

---

## Section 4 — Database and Application Security

**Q13. What are the key areas you would test in an Oracle Database audit?**

> **A:** An Oracle database audit covers seven key areas:
> 1. **Version and patch status** — is the database running a supported, patched version?
> 2. **User account management** — are default accounts (SCOTT, HR, SH) locked? Are dormant accounts disabled?
> 3. **Privilege management** — how many accounts have the DBA role? Are service accounts granted DBA? Are dangerous system privileges like `EXECUTE ANY PROCEDURE` or `SELECT ANY TABLE` granted to non-DBA accounts?
> 4. **Listener and network security** — is the listener password-protected? Is EXTPROC disabled? Is `REMOTE_OS_AUTHENT = FALSE`?
> 5. **Audit trail** — is Unified Auditing enabled? Is `AUDIT_SYS_OPERATIONS = TRUE`? Are logs forwarded to a central SIEM with 180-day retention?
> 6. **Encryption** — is TDE enabled for sensitive tablespaces? Is the TDE wallet stored securely (HSM)?
> 7. **Hardening parameters** — is `07_DICTIONARY_ACCESSIBILITY = FALSE`? Are dangerous packages revoked from PUBLIC?

---

**Q14. What is TDE and why is it important in a BFSI context?**

> **A:** TDE (Transparent Data Encryption) is a database-level encryption feature that encrypts data files, redo logs, and backups at the storage layer without requiring application code changes. In Oracle, TDE can encrypt individual columns or entire tablespaces; in SQL Server, it encrypts the entire database. In a BFSI context, TDE is important for three reasons: (1) **Regulatory compliance** — DPDP Act 2023 and RBI Cyber Framework §8.1 require encryption of sensitive personal and financial data at rest; (2) **Data breach protection** — if physical storage media is stolen, TDE renders the data unreadable without the encryption key; (3) **Audit evidence** — absence of TDE on databases containing PII or financial data is a Critical finding in regulatory audits. An IS auditor tests TDE by querying `DBA_TABLESPACES.ENCRYPTED` in Oracle or `sys.dm_database_encryption_keys` in SQL Server.

---

## Section 5 — Network and Infrastructure Security

**Q15. What is the difference between a stateful firewall and a next-generation firewall (NGFW)?**

> **A:** A stateful firewall operates at Layers 3 and 4 (IP/TCP/UDP), tracking connection state and making allow/deny decisions based on IP address, port, and protocol. A next-generation firewall (NGFW) operates up to Layer 7 (application layer) and adds: **Application Identification (App-ID)** — identifies the actual application regardless of port; **User Identity** — links traffic to specific users; **Intrusion Prevention System (IPS)** — inspects traffic for threats; **SSL/TLS Inspection** — decrypts and inspects encrypted traffic; **URL/Web Filtering** — controls web access by category; **WildFire/Sandbox** — sends unknown files for cloud-based threat analysis. For IS audit purposes, NGFWs should have all security profiles (IPS, AV, URL filter) applied to all internet-facing rules — a policy review without these profiles applied is a High-risk finding regardless of whether the firewall is capable.

---

**Q16. What would you look for when reviewing firewall rules?**

> **A:** During a firewall ruleset review, I would test for: (1) **ANY/ANY/ANY rules** — any rule permitting unrestricted source IP, destination, and service is a Critical finding; (2) **High-risk services exposed to internet** — RDP (3389), SMB (445), Telnet (23), raw SSH (22) directly accessible from 0.0.0.0; (3) **Security profiles missing** — outbound rules without IPS, AV, or URL filtering; (4) **Implicit deny** — the default last rule should deny-all; (5) **Disabled rules** — understand why they exist; remove if not required; (6) **Stale rules** — rules with zero hit counts or with comments like "temp", "test", "delete later"; (7) **Management access unrestricted** — the management interface should only accept connections from the dedicated admin network; (8) **Logging** — all deny rules and high-risk allow rules must have logging enabled; (9) **No descriptions/business justification** — each rule should state why it exists and who approved it.

---

## Section 6 — Audit Reporting and Professional Standards

**Q17. What is an overall audit opinion and how do you arrive at it?**

> **A:** The overall audit opinion is the auditor's professional conclusion on the adequacy and operating effectiveness of controls in the audit scope. There are typically three opinion levels: **Satisfactory** — controls are adequate and operating effectively; minor issues do not represent material risk. **Needs Improvement** — control gaps exist that create unacceptable risk if not remediated; management action is required. **Unsatisfactory** — material control failures that expose the organization to significant risk; immediate escalation to senior management and board may be required.
>
> I arrive at the opinion by: (1) considering the number and severity of findings — any Critical finding typically triggers at least Needs Improvement; (2) considering whether findings are isolated or systemic; (3) considering whether root cause is people, process, or technology — systemic root causes are more serious; (4) considering repeat findings from prior audits; (5) considering the overall risk landscape. The opinion is not a mathematical calculation — it requires professional judgment, but it should be defensible based on the evidence gathered.

---

**Q18. What is the difference between a finding and a recommendation?**

> **A:** A **finding** is an objective, evidence-based statement of what the auditor observed during fieldwork — a gap between the current state (condition) and the expected state (criteria). It is factual and backward-looking. A **recommendation** is the auditor's guidance on what should be done to address the finding — it is forward-looking, action-oriented, and specific. A common mistake is writing vague findings ("security needs improvement") or generic recommendations ("management should strengthen controls"). Effective findings are quantified ("47 dormant accounts active beyond 90 days") and effective recommendations name a specific action, owner, and timeframe ("IAM team should disable all 47 accounts by [date] and implement automated deprovisioning").

---

**Q19. What would you do if management disagrees with a finding?**

> **A:** Management disagreement with an audit finding is a professional situation that must be handled carefully. First, I would listen to management's position and consider whether they have additional facts that I may not have seen during fieldwork — if so, I would re-evaluate. If the factual basis of the finding is correct and management's disagreement is based on interpretation or opinion rather than new evidence, I would maintain the finding. I would record management's disagreement formally in the report under "Management Response" as "Not Agreed" with their rationale. I would not remove or downgrade a finding simply because management disagrees. For Critical or High-risk findings that management refuses to remediate, I would escalate to the Audit Committee or Board as required by professional standards. The auditor's independence and objectivity must be preserved — findings are based on evidence, not negotiation.

---

## Section 7 — BFSI-Specific Questions

**Q20. What is SWIFT and what are the key audit considerations for SWIFT infrastructure?**

> **A:** SWIFT (Society for Worldwide Interbank Financial Telecommunication) is the global messaging network used by banks for international fund transfers (wire transfers). SWIFT infrastructure includes: the SWIFT messaging interface (Alliance Gateway), HSM (Hardware Security Module) for key management, and the back-office systems that process SWIFT messages. Key IS audit considerations: (1) **Physical security** of SWIFT terminals and HSM; (2) **Access controls** — who can authorize SWIFT messages? Is the 4-eyes principle enforced? (3) **Reconciliation** — are sent messages reconciled with nostro accounts daily? (4) **SWIFT CSP (Customer Security Programme)** — has the bank completed the annual CSP self-attestation against SWIFT's mandatory controls? (5) **RBI SWIFT Circular compliance** — RBI's 2018 circular requires banks to implement specific controls including end-of-day reconciliation, operator and supervisor separation, and integration with core banking. The Bangladesh Bank heist (2016, $81M) occurred partly due to weak SWIFT controls and is frequently cited in IS audit discussions.

---

**Q21. What is the significance of the DPDP Act 2023 for IS auditors?**

> **A:** The Digital Personal Data Protection Act 2023 is India's first comprehensive data privacy legislation, analogous to the GDPR. For IS auditors, it introduces several new audit considerations: (1) **Data Principal rights** — organizations must have mechanisms for individuals to access, correct, and erase their personal data — auditors must test if these mechanisms exist and work; (2) **Consent management** — personal data can only be processed with valid consent — auditors test consent capture, storage, and withdrawal processes; (3) **Data Fiduciary obligations** — organizations processing personal data must implement "appropriate technical and organizational measures" — encryption, access controls, and audit trails are relevant; (4) **Significant Data Fiduciaries** — certain categories (large-scale processors of children's data, etc.) face additional obligations including data audits; (5) **Data breach notification** — breaches must be notified to the Data Protection Board; (6) **Cross-border restrictions** — some countries may be restricted for data transfers. DPDP Act compliance testing is an emerging IS audit area that will become standard in BFSI audits.

---

**Q22. What would you check when auditing a Core Banking System (CBS)?**

> **A:** A CBS audit (systems like Finacle, FIS Systematics, Temenos T24, BaNCS) would cover: (1) **Access controls** — are CBS roles defined by job function? Is the 4-eyes principle enforced for critical transactions (account opening, large transfers)? Are dormant accounts disabled? (2) **Segregation of duties** — can one user both initiate and approve transactions? Is there separation between tellers, supervisors, and back-office? (3) **Audit trail integrity** — are all CBS transactions logged with user ID, timestamp, and terminal? Are logs tamper-proof? Are they forwarded to SIEM? (4) **Interface controls** — are integrations to SWIFT, NPCI (UPI/IMPS), and NEFT/RTGS authorized and reconciled? (5) **Parameterization** — are critical parameters (interest rates, transaction limits) change-controlled and auditable? (6) **Patch management** — is the CBS version supported by the vendor? (7) **Data masking** — is customer PII masked in the CBS test environment? (8) **Batch processing** — are end-of-day batch jobs monitored and exceptions reviewed?

---

## Section 8 — Practical and Situational Questions

**Q23. You find that the log retention in the SIEM is only 30 days but CERT-In requires 180 days. Walk me through how you would document this finding.**

> **A:** I would document this as a Critical finding using the PCCER format:
> - **Process/Control:** Log Management — Centralized SIEM Retention Policy
> - **Condition:** During fieldwork on [date], the SIEM (Splunk) retention policy was found set to 30 days rolling. Testing confirmed that queries for events older than 30 days returned no results. Log sources reviewed included Active Directory, Firewall, and Core Banking System.
> - **Criteria:** CERT-In Directions (April 2022), Section 6(1), issued under Section 70B(6) of the IT Act, mandate that all organizations maintain ICT logs for a minimum period of 180 days on a rolling basis.
> - **Effect:** The current 30-day retention is 150 days short of the mandatory requirement. Non-compliance with CERT-In Directions is a criminal offence under Section 70B(7) of the IT Act. Additionally, audit trails and forensic evidence for incidents detected in months 2–6 would be unavailable, severely limiting the organization's ability to investigate historical events or demonstrate compliance during regulatory inspections.
> - **Recommendation:** Immediately update the SIEM retention policy to 180 days. Verify adequate storage capacity. Confirm all log sources are forwarding to the SIEM. Obtain written confirmation of compliance from the SIEM administrator. Document as closed only after a retention test (query for 175-day-old events) confirms compliance.

---

**Q24. What is the difference between an IS audit and a penetration test?**

> **A:** An IS audit is an **independent assurance exercise** that evaluates the design and operating effectiveness of controls against defined criteria (policies, standards, regulations). It uses techniques like inspection, inquiry, observation, and data analysis. The output is an audit report with findings and recommendations. The auditor assesses risk but does not actively exploit vulnerabilities. A penetration test (pentest) is a **simulated attack** where security professionals actively attempt to exploit vulnerabilities to determine if systems can be compromised. The output is a pentest report showing what was successfully exploited and how. IS audit is broader (covers governance, process, and technical controls) while a pentest is narrower and technical. They are complementary: VAPT results can serve as audit evidence for the control testing phase of an IS audit.

---

*Part of [IS Audit Playbook](../README.md) | See also: [CISA/CISM Prep](CISA-CISM-prep.md)*
