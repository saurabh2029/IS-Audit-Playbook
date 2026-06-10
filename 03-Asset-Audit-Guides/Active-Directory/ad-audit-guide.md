# Active Directory Audit Guide

> **Asset Type:** Microsoft Active Directory (AD DS)  
> **Audit Domain:** Identity & Access Management, ITGC  
> **Regulatory Mapping:** RBI Cyber Framework § Access Control | ISO 27001 A.9 | NIST AC, IA families  
> **Risk Level:** 🔴 High — AD is the identity backbone; compromise = full network compromise

---

## Objective

To assess the security posture of Active Directory by evaluating:
- User and account management controls
- Privileged access governance (Domain Admins, Enterprise Admins)
- Group Policy Objects (GPOs) and password policy enforcement
- Audit logging and monitoring configuration
- Stale objects, unnecessary access, and configuration weaknesses

---

## Pre-Audit Requirements

### Access Needed
- [ ] Read-only Domain Admin (or delegation with sufficient rights for enumeration)
- [ ] Access to Active Directory Users and Computers (ADUC)
- [ ] Access to Active Directory Administrative Center (ADAC)
- [ ] Group Policy Management Console (GPMC) access
- [ ] Event Viewer access on Domain Controllers
- [ ] PowerShell remoting to Domain Controllers (preferred)

### Tools Required
- PowerShell with ActiveDirectory module
- BloodHound / SharpHound (if authorized for attack path analysis)
- PingCastle (AD health and risk assessment)
- Microsoft Active Directory Assessment tools
- Event log access (Security, System logs on DCs)

---

## Audit Checklist

### Section 1 — Domain & Forest Configuration

| # | Control | Test Method | Expected | Risk if Fail |
|---|---------|------------|----------|--------------|
| 1.1 | Domain functional level is current | `Get-ADDomain \| select DomainMode` | Windows 2016 or higher | Medium |
| 1.2 | Forest functional level is current | `Get-ADForest \| select ForestMode` | Windows 2016 or higher | Medium |
| 1.3 | Domain controllers are fully patched | Check OS patch level on all DCs | All DCs within 30-day patch cycle | High |
| 1.4 | SYSVOL and NETLOGON shares are properly secured | Check share ACLs | Only Domain Admins + SYSTEM | High |
| 1.5 | DNS is secured and only DCs are authoritative | Review DNS ACLs | No unauthorized DNS admin rights | High |
| 1.6 | Tombstone lifetime is >= 180 days | `(Get-ADObject ...).tombstoneLifetime` | ≥ 180 days | Low |

---

### Section 2 — Privileged Account Management

| # | Control | Test Method | Expected | Risk if Fail |
|---|---------|------------|----------|--------------|
| 2.1 | Domain Admins count is minimal | `Get-ADGroupMember "Domain Admins"` | ≤ 5 accounts | 🔴 Critical |
| 2.2 | Enterprise Admins count is minimal | `Get-ADGroupMember "Enterprise Admins"` | Only used during forest changes | 🔴 Critical |
| 2.3 | Schema Admins is empty (not in use) | `Get-ADGroupMember "Schema Admins"` | Empty when not making schema changes | 🔴 Critical |
| 2.4 | Built-in Administrator account is disabled or renamed | Check CN=Administrator | Disabled or renamed | 🔴 Critical |
| 2.5 | No service accounts in Domain Admin group | Verify DA group composition | No service accounts as DA | 🔴 Critical |
| 2.6 | Privileged accounts have no email / not used for daily tasks | Review account properties | Separate admin accounts exist | High |
| 2.7 | Privileged accounts require MFA | Verify MFA enforcement for admins | MFA enforced for all DA accounts | 🔴 Critical |
| 2.8 | Protected Users security group in use | `Get-ADGroupMember "Protected Users"` | All tier-0 accounts added | High |

```powershell
# Enumerate all privileged groups
$privilegedGroups = @("Domain Admins","Enterprise Admins","Schema Admins","Administrators","Group Policy Creator Owners","Account Operators","Backup Operators")
foreach ($group in $privilegedGroups) {
    Write-Host "`n=== $group ===" -ForegroundColor Yellow
    Get-ADGroupMember -Identity $group -Recursive | Select-Object Name, SamAccountName, ObjectClass
}
```

---

### Section 3 — User Account Controls

| # | Control | Test Method | Expected | Risk if Fail |
|---|---------|------------|----------|--------------|
| 3.1 | Dormant accounts disabled after 90 days | Query last logon < 90 days ago | Zero active dormant accounts | High |
| 3.2 | Terminated employee accounts disabled/deleted | Cross-check HR list vs. AD | No active accounts for ex-employees | 🔴 Critical |
| 3.3 | Service accounts have no interactive logon rights | Check logon rights in GPO | Deny interactive logon applied | High |
| 3.4 | Guest account is disabled | `Get-ADUser Guest` | Disabled | High |
| 3.5 | Accounts with "Password Never Expires" are reviewed | Query `PasswordNeverExpires` flag | Only justified exceptions exist | High |
| 3.6 | Accounts with "Password Not Required" = 0 | Query `PasswordNotRequired` flag | Zero accounts | 🔴 Critical |
| 3.7 | Shared/generic accounts are prohibited | Review naming conventions | No shared accounts (helpdesk, admin, test) | High |
| 3.8 | User accounts are placed in correct OUs | Spot check OU placement | No user accounts in default containers | Medium |

```powershell
# Find dormant accounts (no login in 90+ days)
$cutoffDate = (Get-Date).AddDays(-90)
Get-ADUser -Filter {LastLogonDate -lt $cutoffDate -and Enabled -eq $true} `
    -Properties LastLogonDate, PasswordNeverExpires, Department |
    Select-Object Name, SamAccountName, LastLogonDate, Department |
    Sort-Object LastLogonDate

# Find accounts with Password Never Expires
Get-ADUser -Filter {PasswordNeverExpires -eq $true -and Enabled -eq $true} `
    -Properties PasswordNeverExpires, PasswordLastSet |
    Select-Object Name, SamAccountName, PasswordLastSet

# Find accounts with Password Not Required
Get-ADUser -Filter {PasswordNotRequired -eq $true} |
    Select-Object Name, SamAccountName
```

---

### Section 4 — Password Policy

| # | Control | Test Method | Expected | Risk if Fail |
|---|---------|------------|----------|--------------|
| 4.1 | Minimum password length ≥ 12 characters | `Get-ADDefaultDomainPasswordPolicy` | ≥ 12 | High |
| 4.2 | Password complexity is enforced | Check `ComplexityEnabled` | True | High |
| 4.3 | Password history ≥ 24 | Check `PasswordHistoryCount` | ≥ 24 | Medium |
| 4.4 | Maximum password age ≤ 90 days | Check `MaxPasswordAge` | ≤ 90 days | Medium |
| 4.5 | Account lockout threshold ≤ 5 attempts | Check `LockoutThreshold` | ≤ 5 | High |
| 4.6 | Lockout duration ≥ 15 minutes | Check `LockoutDuration` | ≥ 15 min | Medium |
| 4.7 | Fine-Grained Password Policies (FGPP) for privileged accounts | Check PSOs for admin accounts | Stricter policy for DA/admins | High |

```powershell
# Check default domain password policy
Get-ADDefaultDomainPasswordPolicy

# Check Fine-Grained Password Policies
Get-ADFineGrainedPasswordPolicy -Filter * | Select-Object Name, MinPasswordLength, LockoutThreshold, Precedence

# List all PSOs and their targets
Get-ADFineGrainedPasswordPolicySubject -Identity "AdminPSO"
```

---

### Section 5 — Group Policy Objects (GPOs)

| # | Control | Test Method | Expected | Risk if Fail |
|---|---------|------------|----------|--------------|
| 5.1 | Default Domain Policy is not modified (custom GPOs used) | Review Default Domain Policy | Only password/lockout settings; no custom configs | Medium |
| 5.2 | GPO permissions — only authorized admins can edit | Review GPMC permissions | Only GPO Admins or Domain Admins | High |
| 5.3 | AppLocker / WDAC GPO is deployed | Review software restriction policies | Whitelist-based application control active | High |
| 5.4 | PowerShell execution policy is set to Restricted/AllSigned | Check via GPO | Not Unrestricted | High |
| 5.5 | SMBv1 is disabled via GPO | Check registry/GPO | SMBv1 disabled | 🔴 Critical |
| 5.6 | LLMNR and NBT-NS are disabled | Check GPO network settings | Both disabled | High |
| 5.7 | Local Administrator account disabled via GPO | Check via GPO Computer settings | Disabled or LAPS managed | High |
| 5.8 | LAPS (Local Admin Password Solution) is deployed | Check for LAPS schema attributes | ms-Mcs-AdmPwd attribute present | High |
| 5.9 | Audit policies are configured (Success and Failure) | `auditpol /get /category:*` | Per CIS benchmark settings | High |

```powershell
# Check SMBv1 status
Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol

# Check if LAPS is installed
Get-ADObject -SearchBase (Get-ADDomain).DistinguishedName `
    -Filter {name -like "ms-Mcs-AdmPwd"} -SearchScope SubTree

# List all GPOs and their links
Get-GPO -All | Select-Object DisplayName, GpoStatus, CreationTime, ModificationTime
```

---

### Section 6 — Kerberos Configuration

| # | Control | Test Method | Expected | Risk if Fail |
|---|---------|------------|----------|--------------|
| 6.1 | Kerberos ticket lifetime is ≤ 10 hours | Check default domain policy | ≤ 10 hours | Medium |
| 6.2 | KRBTGT account password reset within 1 year | Check KRBTGT `PasswordLastSet` | Reset within 12 months | 🔴 Critical |
| 6.3 | No accounts with unconstrained delegation (except DCs) | `Get-ADComputer -Filter {TrustedForDelegation -eq $true}` | Only Domain Controllers | 🔴 Critical |
| 6.4 | No accounts with Kerberoastable SPNs and weak passwords | Check service accounts with SPNs | Service accounts with strong passwords | High |
| 6.5 | AS-REP Roasting prevention — Pre-auth required | `Get-ADUser -Filter {DoesNotRequirePreAuth -eq $true}` | Zero accounts | 🔴 Critical |

```powershell
# Find accounts NOT requiring Kerberos pre-auth (AS-REP Roastable)
Get-ADUser -Filter {DoesNotRequirePreAuth -eq $true} -Properties DoesNotRequirePreAuth |
    Select-Object Name, SamAccountName

# Find computers with unconstrained delegation (excluding DCs)
Get-ADComputer -Filter {TrustedForDelegation -eq $true} -Properties TrustedForDelegation, OperatingSystem |
    Where-Object {$_.OperatingSystem -notlike "*Server*"} |
    Select-Object Name, DNSHostName, OperatingSystem

# Check KRBTGT password age
Get-ADUser krbtgt -Properties PasswordLastSet | Select-Object Name, PasswordLastSet
```

---

### Section 7 — Audit Logging & Monitoring

| # | Control | Test Method | Expected | Risk if Fail |
|---|---------|------------|----------|--------------|
| 7.1 | Advanced Audit Policy configured on all DCs | `auditpol /get /category:*` on DCs | Per CIS DC Benchmark | High |
| 7.2 | Security event logs are forwarded to SIEM | Confirm in SIEM (e.g., Splunk) | All DC logs ingested | 🔴 Critical |
| 7.3 | Event log size is sufficient (minimum 1 GB Security) | Check Event Log settings | ≥ 1 GB for Security log | High |
| 7.4 | Alerting exists for critical AD events | Review SIEM alert rules | Alerts for Event IDs below | High |
| 7.5 | Log retention meets regulatory requirement | Check SIEM/log retention policy | ≥ 180 days (CERT-In mandate) | High |

**Critical Event IDs to Monitor:**

| Event ID | Description | Priority |
|----------|------------|----------|
| 4720 | User account created | High |
| 4722 | User account enabled | High |
| 4725 | User account disabled | Medium |
| 4726 | User account deleted | High |
| 4728 | Member added to security group | 🔴 Critical |
| 4756 | Member added to universal group | 🔴 Critical |
| 4768 | Kerberos TGT requested | Medium |
| 4771 | Kerberos pre-auth failed | High |
| 4776 | NTLM authentication | High |
| 4624 | Successful logon | Medium |
| 4625 | Failed logon | High |
| 4648 | Logon with explicit credentials | High |
| 4672 | Special privileges assigned | 🔴 Critical |
| 4698 | Scheduled task created | High |
| 4699 | Scheduled task deleted | High |
| 4702 | Scheduled task updated | High |

---

## Evidence to Collect

| Evidence Item | How to Collect | File Format |
|--------------|---------------|-------------|
| Domain Admins membership | PowerShell export | CSV |
| All privileged group memberships | PowerShell export | CSV |
| Default domain password policy | GPMC screenshot + PowerShell | Screenshot + TXT |
| Dormant accounts list | PowerShell query | CSV |
| Accounts with Password Never Expires | PowerShell query | CSV |
| GPO list with links and settings | GPMC HTML report | HTML |
| DC audit policy settings | auditpol output | TXT |
| KRBTGT password age | PowerShell | Screenshot |
| Unconstrained delegation accounts | PowerShell query | CSV |
| AS-REP Roastable accounts | PowerShell query | CSV |
| SIEM forwarding configuration | Screenshot from SIEM | Screenshot |

---

## Common Findings & Sample Observations

### Finding AD-001 — Excessive Domain Admin Accounts

> **Condition:** 23 user accounts were found in the Domain Admins group, including service accounts and general IT staff accounts.  
> **Criteria:** Industry best practice (CIS Controls, NIST SP 800-53 AC-6) and the organization's own Privileged Access Policy require Domain Admin access to be limited to a maximum of 5 dedicated administrative accounts.  
> **Effect:** Excessive privileged accounts significantly expand the attack surface. Compromise of any single account grants full control over the Active Directory environment and all domain-joined systems.  
> **Recommendation:** Immediately remove all non-essential accounts from Domain Admins. Implement a Privileged Access Management (PAM) solution. Create a dedicated admin workstation (PAW) program for privileged tasks.  
> **Risk Rating:** 🔴 Critical

---

### Finding AD-002 — Dormant Accounts Not Disabled

> **Condition:** 147 enabled user accounts had not logged in for more than 90 days, including 12 accounts belonging to employees confirmed as separated by HR.  
> **Criteria:** IT Security Policy Section 5.3 requires user accounts to be disabled after 90 days of inactivity. HR offboarding procedure requires immediate access revocation upon separation.  
> **Effect:** Dormant accounts represent an unauthorized access risk. Accounts of separated employees are particularly dangerous as they may be unknown to current staff and not monitored.  
> **Recommendation:** Disable all identified dormant accounts immediately. Implement an automated account lifecycle management process integrated with HR. Conduct quarterly access certification reviews.  
> **Risk Rating:** 🔴 Critical

---

### Finding AD-003 — KRBTGT Password Not Rotated

> **Condition:** The KRBTGT account password had not been reset for 847 days.  
> **Criteria:** Microsoft and NIST SP 800-63B recommend KRBTGT password rotation at least annually, and immediately following any suspected domain compromise. CIS Controls recommend bi-annual rotation.  
> **Effect:** A stale KRBTGT password increases the viability of Golden Ticket attacks. If the NTLM hash of KRBTGT is obtained by a threat actor, forged Kerberos tickets can be created that persist even after user account changes.  
> **Recommendation:** Immediately rotate the KRBTGT password twice (to invalidate any existing tickets). Schedule semi-annual KRBTGT rotation. Consider Microsoft's recommended rotation playbook.  
> **Risk Rating:** 🔴 Critical

---

## Regulatory Mapping

| Control Area | RBI Cyber Framework | ISO 27001:2022 | NIST CSF | CERT-In |
|-------------|--------------------|-----------------|-----------|---------| 
| Privileged Access | § 7.1 — Privileged Access Management | A.9.2.3 | PR.AC-4 | — |
| Account Management | § 6.1 — IAM Policy | A.9.2.1, A.9.2.2 | PR.AC-1 | — |
| Password Policy | § 6.3 — Authentication | A.9.4.3 | PR.AC-7 | — |
| Audit Logging | § 11.1 — Log Management | A.8.15 | DE.CM-1 | Log retention ≥ 180 days |
| Monitoring | § 12.1 — SOC/SIEM | A.8.16 | DE.CM-7 | 6-hr breach reporting |

---

*Part of [IS Audit Playbook](../../README.md) | Next: [GPO Review Guide](gpo-review.md)*
