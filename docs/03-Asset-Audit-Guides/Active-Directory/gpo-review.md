# Group Policy Object (GPO) Review Guide

> **Companion to:** [AD Audit Guide](ad-audit-guide.md)  
> **Focus:** Systematic review methodology for Group Policy Objects  
> **Regulatory Mapping:** RBI Cyber Framework §7.1 | ISO 27001 A.8.9 | CIS Benchmark for Windows

---

## Why GPOs Matter to Auditors

GPOs are the primary mechanism for enforcing security configuration at scale across a Windows domain. A misconfigured or missing GPO means that whatever security control it was meant to enforce (password policy, audit policy, software restriction) simply does not exist organization-wide. Reviewing GPOs is far more efficient than checking individual machines — but auditors must verify GPOs are actually **linked, enabled, and applying** — not just that they exist.

---

## GPO Review Methodology

```
STEP 1: Inventory   → List all GPOs in the domain
STEP 2: Link Check   → Verify which OUs each GPO is linked to
STEP 3: Scope Check  → Verify Security Filtering and WMI filters
STEP 4: Content Review → Examine actual settings within each GPO
STEP 5: Precedence Check → Identify conflicting GPOs and resolution order
STEP 6: Application Test → Confirm settings actually apply on target systems
```

---

## Step 1 — GPO Inventory

```powershell
# List all GPOs in the domain with key metadata
Get-GPO -All | Select-Object DisplayName, Id, GpoStatus, CreationTime, ModificationTime |
    Sort-Object DisplayName

# Generate full HTML report for all GPOs (best for evidence)
Get-GPO -All | ForEach-Object {
    Get-GPOReport -Guid $_.Id -ReportType Html -Path "C:\AuditEvidence\GPO_$($_.DisplayName -replace '[\\\/:*?"<>|]','_').html"
}

# Identify GPOs that are NOT linked anywhere (orphaned)
$allGPOs = Get-GPO -All
$linkedGPOs = Get-ADOrganizationalUnit -Filter * |
    Get-GPInheritance | Select-Object -ExpandProperty GpoLinks |
    Select-Object -ExpandProperty DisplayName -Unique
$allGPOs | Where-Object { $_.DisplayName -notin $linkedGPOs } | Select-Object DisplayName
```

---

## Step 2 — Link and Scope Verification

| # | Control | Test Method | Expected | Risk |
|---|---------|------------|----------|------|
| 2.1 | Critical security GPOs are linked at domain level (not just one OU) | `Get-GPInheritance` on domain root | Security baseline GPOs apply domain-wide | High |
| 2.2 | No orphaned/unlinked GPOs that should be active | GPO inventory vs. link check | Unlinked GPOs identified and explained | Medium |
| 2.3 | Security Filtering correctly restricts GPO scope where intended | Review GPO security filtering | Filtering matches intended target group | Medium |
| 2.4 | "Enforced" flag used appropriately (overrides block-inheritance) | GPO link properties | Used sparingly, only where justified | Medium |
| 2.5 | Block Inheritance is not misused to bypass security baselines | OU properties review | No OU blocks inheritance of security GPOs without compensating controls | High |

```powershell
# Check GPO inheritance and link status for a specific OU
Get-GPInheritance -Target "OU=Servers,DC=domain,DC=com"

# Check for OUs blocking inheritance (potential bypass of security policy)
Get-ADOrganizationalUnit -Filter * -Properties gPOptions |
    Where-Object { $_.gPOptions -eq 1 } |
    Select-Object Name, DistinguishedName
```

---

## Step 3 — Critical GPO Content Checklist

### Password & Account Lockout Policy GPO

| # | Setting | Path | Expected |
|---|---------|------|----------|
| 3.1 | Minimum password length | Computer Config > Windows Settings > Security Settings > Account Policies > Password Policy | ≥ 12 characters |
| 3.2 | Password complexity | Same path | Enabled |
| 3.3 | Maximum password age | Same path | ≤ 90 days |
| 3.4 | Account lockout threshold | Account Lockout Policy | ≤ 5 invalid attempts |
| 3.5 | Account lockout duration | Same path | ≥ 15 minutes |

### Audit Policy GPO

| # | Setting | Path | Expected |
|---|---------|------|----------|
| 3.6 | Audit Logon Events | Advanced Audit Policy Configuration | Success and Failure |
| 3.7 | Audit Account Management | Same path | Success and Failure |
| 3.8 | Audit Privilege Use | Same path | Success and Failure (sensitive) |
| 3.9 | Audit Policy Change | Same path | Success and Failure |
| 3.10 | Audit Directory Service Access | Same path | Success (at minimum) |

### Security Options GPO

| # | Setting | Expected |
|---|---------|----------|
| 3.11 | Interactive logon: Do not display last user name | Enabled |
| 3.12 | Network access: Do not allow anonymous enumeration of SAM accounts | Enabled |
| 3.13 | Microsoft network server: Digitally sign communications | Enabled (always) |
| 3.14 | Domain member: Digitally encrypt or sign secure channel data | Enabled |
| 3.15 | User Account Control: Admin Approval Mode | Enabled |

### Software Restriction / AppLocker GPO

| # | Setting | Expected |
|---|---------|----------|
| 3.16 | AppLocker / WDAC policy deployed | Enforced (not audit-only) for production |
| 3.17 | PowerShell Constrained Language Mode for standard users | Enabled where AppLocker is enforced |
| 3.18 | Removable storage write access restricted | Restricted per data loss prevention policy |

```powershell
# Extract specific settings from a GPO report for review
$report = Get-GPOReport -Name "Default Domain Policy" -ReportType Xml
[xml]$xmlReport = $report
$xmlReport.GPO.Computer.ExtensionData.Extension.Account |
    Select-Object Name, SettingNumber, SettingBoolean
```

---

## Step 4 — Precedence and Conflict Resolution

GPO precedence order (later wins): **Local > Site > Domain > OU** (LSDOU), with OUs closest to the object applying last (highest precedence).

| # | Control | Test Method | Expected | Risk |
|---|---------|------------|----------|------|
| 4.1 | No conflicting settings between domain-level and OU-level GPOs that weaken security | Resultant Set of Policy (RSoP) review | OU-level GPOs do not weaken domain baseline | High |
| 4.2 | GPO precedence order is documented and understood | GPMC review | Clear understanding of link order | Medium |
| 4.3 | "Enforced" GPOs are minimal and justified | GPO link review | Enforced flag used only for non-negotiable baselines | Medium |

```powershell
# Generate Resultant Set of Policy for a specific computer (run ON or AGAINST target)
gpresult /h C:\AuditEvidence\RSoP_Report.html /scope computer

# Remote RSoP generation
Invoke-Command -ComputerName "SERVER01" -ScriptBlock { gpresult /r }
```

---

## Step 5 — Application Verification (Trust but Verify)

The most important step — auditors must confirm GPOs are **actually applying**, not just configured.

```powershell
# Check GPO application status on a sample of target machines
Invoke-Command -ComputerName "SERVER01","SERVER02","WS001" -ScriptBlock {
    gpresult /r | Select-String "Last time Group Policy was applied|Applied Group Policy Objects"
}

# Verify specific registry settings that should result from GPO application
# Example: verify password complexity is actually active
Invoke-Command -ComputerName "SERVER01" -ScriptBlock {
    net accounts
}

# Check Group Policy event logs for application errors
Get-WinEvent -ComputerName "SERVER01" -FilterHashtable @{
    LogName = 'System'; ProviderName = 'Microsoft-Windows-GroupPolicy'
} -MaxEvents 20 | Where-Object { $_.LevelDisplayName -eq 'Error' }
```

---

## Common Findings

### Finding GPO-001 — Critical Security GPO Not Linked to All OUs

> **Condition:** The "Domain Security Baseline" GPO, which enforces audit policy and account lockout settings, was found linked only to the "Servers" OU. The "Workstations" OU and "Service Accounts" OU had no equivalent baseline applied, resulting in inconsistent audit logging and account lockout configuration across the domain.
> **Criteria:** CIS Benchmark for Windows requires consistent security baseline application across all domain-joined systems. The organization's Configuration Management Policy requires a single enforced baseline domain-wide.
> **Effect:** Workstations and service account-hosting systems lack the audit logging and account lockout protections applied to servers, creating inconsistent security posture and blind spots in security monitoring for a significant portion of the domain.
> **Recommendation:** Link the Domain Security Baseline GPO to all relevant OUs (Workstations, Service Accounts) or move the link to the domain root with appropriate exceptions via Security Filtering. Verify application via RSoP testing on a sample of affected machines.
> **Risk:** 🟠 High

### Finding GPO-002 — AppLocker Configured in Audit-Only Mode

> **Condition:** The AppLocker GPO was found configured with all rules set to "Audit Only" rather than "Enforce" across all production workstations and servers. Application execution events were being logged but no application was actually being blocked.
> **Criteria:** RBI Cyber Framework §7.1 and the organization's Endpoint Security Policy require application whitelisting controls to be in enforcement mode for production systems, not solely audit/monitoring mode.
> **Effect:** Despite AppLocker being deployed and appearing functional in management consoles, it provides zero actual protection against unauthorized or malicious application execution since no blocking occurs. This creates a false sense of security while leaving endpoints fully exposed to malware execution.
> **Recommendation:** After validating audit logs show no legitimate application would be blocked (false positive analysis), transition AppLocker rules to Enforce mode in a phased rollout, starting with high-risk server groups, followed by workstations.
> **Risk:** 🟠 High

---

*Part of [IS Audit Playbook](../../README.md) | See also: [AD Audit Guide](ad-audit-guide.md) | [Privileged Access](privileged-access.md)*
