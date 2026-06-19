# Active Directory — Privileged Access Audit Guide

> **Companion to:** [AD Audit Guide](ad-audit-guide.md)  
> **Focus:** Deep-dive on privileged access governance, PAM integration, and Tiered Administration Model  
> **Regulatory Mapping:** RBI Cyber Framework §6.4, §7.1 | ISO 27001 A.8.2 | NIST PR.AC-4

---

## Why Privileged Access Gets Its Own Guide

Privileged accounts (Domain Admins, Enterprise Admins, server local admins) represent the highest-value target in any Active Directory environment. A single compromised privileged credential can result in complete domain compromise. This guide goes deeper than the general AD checklist into PAM architecture and the Tiered Administration Model.

---

## Microsoft Tiered Administration Model

Microsoft's reference architecture for privileged access separates administrative tiers to prevent credential theft from cascading across the environment:

```
┌─────────────────────────────────────────────────────────────┐
│  TIER 0 — Domain Controllers, AD, PKI, Identity Systems      │
│  Highest value — full forest control                         │
├─────────────────────────────────────────────────────────────┤
│  TIER 1 — Servers, Applications, Enterprise Services         │
│  Server admins, application admins                           │
├─────────────────────────────────────────────────────────────┤
│  TIER 2 — Workstations, End-user Devices, Helpdesk           │
│  Helpdesk and desktop support admins                         │
└─────────────────────────────────────────────────────────────┘

RULE: Tier N admin credentials must NEVER be used to log into Tier N-1 systems
      (a Tier 2 helpdesk admin must not use the same credential on a Tier 0 DC)
```

---

## Audit Checklist — Tiered Model Compliance

| # | Control | Test Method | Expected | Risk |
|---|---------|------------|----------|------|
| 1 | Tier 0 admin accounts are separate from Tier 1/2 accounts | Account naming/group review | Distinct accounts per tier | 🔴 Critical |
| 2 | Tier 0 admins use Privileged Access Workstations (PAWs) | Asset inventory | Dedicated, hardened PAWs for Tier 0 tasks | 🔴 Critical |
| 3 | Tier 0 credentials never used on Tier 1/2 systems | Logon event analysis | No DA logons to non-DC servers/workstations | 🔴 Critical |
| 4 | Helpdesk (Tier 2) admins cannot reset Tier 0/1 admin passwords | Delegation review | Restricted OU-based delegation | 🔴 Critical |
| 5 | Each tier has separate Group Policy management | GPO delegation review | Tier 0 GPOs only editable by Tier 0 admins | High |

```powershell
# Check for cross-tier logon — Domain Admin logons to non-DC machines
# (Run against centralized Security event logs / SIEM — example logic)
# Event ID 4624 (logon) where:
#   - TargetUserName is a Domain Admin
#   - LogonType = 2 (interactive) or 10 (RDP)
#   - Workstation is NOT a Domain Controller

Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4624} -MaxEvents 5000 |
    Where-Object { $_.Properties[8].Value -in @(2,10) } |
    Select-Object TimeCreated,
        @{N='TargetUser';E={$_.Properties[5].Value}},
        @{N='Workstation';E={$_.Properties[11].Value}},
        @{N='LogonType';E={$_.Properties[8].Value}}
```

---

## Privileged Access Management (PAM) Solution Review

If a PAM tool (CyberArk, Delinea/Thycotic, BeyondTrust, HashiCorp Vault) is deployed, audit the following:

| # | Control | Test Method | Expected | Risk |
|---|---------|------------|----------|------|
| 1 | All privileged accounts are onboarded to PAM | PAM vault inventory vs. AD privileged group export | 100% coverage of DA, Enterprise Admin, local admin accounts | 🔴 Critical |
| 2 | Passwords are rotated automatically (not static) | PAM rotation policy | Rotation ≤ 24–90 days depending on tier | 🔴 Critical |
| 3 | Check-out / check-in workflow enforced (no standing access) | PAM workflow review | Just-in-time access; auto check-in | 🔴 Critical |
| 4 | All privileged sessions are recorded | PAM session recording config | 100% session recording for Tier 0/1 | 🔴 Critical |
| 5 | Dual-control / approval workflow for highest-risk accounts | PAM approval workflow | Approval required before check-out for DA-level access | High |
| 6 | PAM vault itself is highly secured (HSM-backed, MFA) | PAM infrastructure review | MFA + HSM for vault access | 🔴 Critical |
| 7 | Break-glass / emergency access procedure documented and tested | DR/BCP documentation | Emergency access procedure exists and tested | High |
| 8 | PAM audit logs forwarded to SIEM | SIEM integration check | All check-out/check-in events in SIEM | High |

---

## Service Account Governance

Service accounts are frequently over-privileged and rarely reviewed — a major blind spot.

| # | Control | Test Method | Expected | Risk |
|---|---------|------------|----------|------|
| 1 | Service account inventory exists with owner assigned | Service account register | 100% of service accounts have a named business owner | High |
| 2 | Service accounts use Group Managed Service Accounts (gMSA) where possible | `Get-ADServiceAccount` | gMSA used for new service accounts | High |
| 3 | Service accounts do not have interactive logon rights | GPO review | "Deny log on locally/interactively" applied | High |
| 4 | Service account passwords are rotated or use gMSA auto-rotation | Password age check | Rotation policy enforced | High |
| 5 | Service accounts are not members of Domain Admins | Privileged group review | Zero service accounts in DA | 🔴 Critical |
| 6 | Service accounts are not Kerberoastable (weak password + SPN) | `Get-ADUser -Filter {ServicePrincipalName -like "*"}` + password strength | Strong passwords (≥ 25 chars) or gMSA | 🔴 Critical |

```powershell
# Inventory all service accounts with SPNs (Kerberoastable targets)
Get-ADUser -Filter {ServicePrincipalName -like "*"} -Properties ServicePrincipalName, PasswordLastSet, MemberOf |
    Select-Object Name, SamAccountName, PasswordLastSet, ServicePrincipalName

# Check gMSA accounts in use
Get-ADServiceAccount -Filter * -Properties PrincipalsAllowedToRetrieveManagedPassword

# Find service accounts that are members of Domain Admins (critical finding)
Get-ADGroupMember "Domain Admins" | 
    Where-Object { (Get-ADUser $_.SamAccountName -Properties ServicePrincipalName).ServicePrincipalName }
```

---

## Common Findings

### Finding PA-001 — No Tiering Model; All Admins Use Single Account Across All Systems

> **Condition:** Interviews and access review confirmed that the IT administration team uses a single set of personal Domain Admin credentials for all administrative tasks — including managing Domain Controllers, logging into application servers, and providing helpdesk support on end-user workstations. No separation between Tier 0, Tier 1, and Tier 2 administrative functions exists.
> **Criteria:** Microsoft's Enterprise Access Model and industry best practice (referenced in RBI Cyber Framework §6.4 — Privileged Access Management) require administrative tiering to prevent credential theft on lower-trust systems from compromising the highest-value assets (Domain Controllers, AD).
> **Effect:** If a Domain Admin credential is captured via keylogger or memory-scraping malware on a single compromised end-user workstation (Tier 2), the attacker gains immediate Tier 0 access to Domain Controllers and the entire Active Directory forest. This single control gap effectively negates the value of all other security controls.
> **Recommendation:** Implement Microsoft's Tiered Administration Model. Create separate Tier 0, Tier 1, and Tier 2 administrative accounts for each administrator. Deploy Privileged Access Workstations (PAWs) for Tier 0 administration. Restrict Tier 0 credential use exclusively to Tier 0 systems via GPO-enforced logon restrictions.
> **Risk:** 🔴 Critical

### Finding PA-002 — Service Account with DA Privileges and Kerberoastable

> **Condition:** The service account `svc_backup` was found to be a member of the Domain Admins group, has a Service Principal Name (SPN) registered, and its password had not been changed in 1,140 days, making it a high-value Kerberoasting target.
> **Criteria:** AD Privileged Access governance requires service accounts to follow least privilege and never hold Domain Admin membership. NIST SP 800-63B and Microsoft security guidance recommend service account passwords be either fully randomized (≥25 characters) via gMSA or rotated regularly.
> **Effect:** Any authenticated domain user can request a Kerberos service ticket for this account and attempt to crack the password offline (Kerberoasting). Given the account's DA privileges, successful password cracking would grant the attacker full domain compromise.
> **Recommendation:** Migrate `svc_backup` to a Group Managed Service Account (gMSA) with auto-rotating, 240-character passwords. Remove DA membership and grant only the specific delegated rights required for backup operations. Audit all other service accounts for similar exposure.
> **Risk:** 🔴 Critical

---

*Part of [IS Audit Playbook](../../README.md) | See also: [AD Audit Guide](ad-audit-guide.md) | [GPO Review](gpo-review.md)*
