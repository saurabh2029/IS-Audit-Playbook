<#
.SYNOPSIS
    Active Directory Security Audit Script
.DESCRIPTION
    Runs a comprehensive set of read-only checks against Active Directory
    and exports results to CSV files for audit evidence.
    Companion to: 03-Asset-Audit-Guides/Active-Directory/ad-audit-guide.md
.NOTES
    Requires: ActiveDirectory PowerShell module
    Permissions: Domain read access (no write operations performed)
    Author: IS Audit Playbook
.EXAMPLE
    .\Invoke-ADSecurityAudit.ps1 -OutputPath "C:\AuditEvidence\AD"
#>

param(
    [string]$OutputPath = ".\AD-Audit-Output"
)

# Ensure output directory exists
if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
Write-Host "Starting AD Security Audit — $timestamp" -ForegroundColor Cyan
Write-Host "Output directory: $OutputPath`n" -ForegroundColor Cyan

Import-Module ActiveDirectory -ErrorAction Stop

# ── 1. Privileged Group Membership ──────────────────────────────────
Write-Host "[1/10] Checking privileged group memberships..." -ForegroundColor Yellow
$privilegedGroups = @("Domain Admins","Enterprise Admins","Schema Admins",
                       "Administrators","Account Operators","Backup Operators",
                       "Group Policy Creator Owners")
$privResults = foreach ($group in $privilegedGroups) {
    try {
        Get-ADGroupMember -Identity $group -Recursive -ErrorAction Stop | ForEach-Object {
            [PSCustomObject]@{
                Group       = $group
                Name        = $_.Name
                SamAccountName = $_.SamAccountName
                ObjectClass = $_.ObjectClass
            }
        }
    } catch { Write-Warning "Could not query group: $group" }
}
$privResults | Export-Csv "$OutputPath\01_PrivilegedGroups_$timestamp.csv" -NoTypeInformation

# ── 2. Dormant Accounts (90+ days inactive) ─────────────────────────
Write-Host "[2/10] Checking dormant accounts..." -ForegroundColor Yellow
$cutoffDate = (Get-Date).AddDays(-90)
Get-ADUser -Filter {LastLogonDate -lt $cutoffDate -and Enabled -eq $true} `
    -Properties LastLogonDate, PasswordNeverExpires, Department, Title |
    Select-Object Name, SamAccountName, LastLogonDate, Department, Title, PasswordNeverExpires |
    Sort-Object LastLogonDate |
    Export-Csv "$OutputPath\02_DormantAccounts_$timestamp.csv" -NoTypeInformation

# ── 3. Password Never Expires ───────────────────────────────────────
Write-Host "[3/10] Checking accounts with PasswordNeverExpires..." -ForegroundColor Yellow
Get-ADUser -Filter {PasswordNeverExpires -eq $true -and Enabled -eq $true} `
    -Properties PasswordNeverExpires, PasswordLastSet, Department |
    Select-Object Name, SamAccountName, PasswordLastSet, Department |
    Export-Csv "$OutputPath\03_PasswordNeverExpires_$timestamp.csv" -NoTypeInformation

# ── 4. Accounts Not Requiring Pre-Authentication (AS-REP Roastable) ──
Write-Host "[4/10] Checking AS-REP roastable accounts..." -ForegroundColor Yellow
Get-ADUser -Filter {DoesNotRequirePreAuth -eq $true} -Properties DoesNotRequirePreAuth |
    Select-Object Name, SamAccountName, Enabled |
    Export-Csv "$OutputPath\04_ASREPRoastable_$timestamp.csv" -NoTypeInformation

# ── 5. Unconstrained Delegation (excluding DCs) ─────────────────────
Write-Host "[5/10] Checking unconstrained delegation..." -ForegroundColor Yellow
Get-ADComputer -Filter {TrustedForDelegation -eq $true} -Properties TrustedForDelegation, OperatingSystem |
    Where-Object { $_.OperatingSystem -notlike "*Server*" -or $_.Name -notmatch "DC" } |
    Select-Object Name, DNSHostName, OperatingSystem |
    Export-Csv "$OutputPath\05_UnconstrainedDelegation_$timestamp.csv" -NoTypeInformation

# ── 6. Service Accounts with SPNs (Kerberoastable) ──────────────────
Write-Host "[6/10] Checking Kerberoastable service accounts..." -ForegroundColor Yellow
Get-ADUser -Filter {ServicePrincipalName -like "*"} -Properties ServicePrincipalName, PasswordLastSet, MemberOf |
    Select-Object Name, SamAccountName, PasswordLastSet,
        @{N="ServicePrincipalNames";E={$_.ServicePrincipalName -join "; "}},
        @{N="IsInPrivilegedGroup"; E={
            $memberOf = $_.MemberOf -join " "
            ($memberOf -match "Domain Admins|Enterprise Admins")
        }} |
    Export-Csv "$OutputPath\06_KerberoastableSPNs_$timestamp.csv" -NoTypeInformation

# ── 7. Default / Built-in Account Status ────────────────────────────
Write-Host "[7/10] Checking default account status..." -ForegroundColor Yellow
$defaultAccounts = @("Administrator","Guest","krbtgt")
$defaultResults = foreach ($acct in $defaultAccounts) {
    try {
        Get-ADUser -Identity $acct -Properties Enabled, PasswordLastSet, LastLogonDate |
            Select-Object Name, SamAccountName, Enabled, PasswordLastSet, LastLogonDate
    } catch { Write-Warning "Could not query account: $acct" }
}
$defaultResults | Export-Csv "$OutputPath\07_DefaultAccounts_$timestamp.csv" -NoTypeInformation

# ── 8. Domain Password Policy ───────────────────────────────────────
Write-Host "[8/10] Checking domain password policy..." -ForegroundColor Yellow
Get-ADDefaultDomainPasswordPolicy |
    Select-Object MinPasswordLength, ComplexityEnabled, PasswordHistoryCount,
        MaxPasswordAge, MinPasswordAge, LockoutThreshold, LockoutDuration, LockoutObservationWindow |
    Export-Csv "$OutputPath\08_DomainPasswordPolicy_$timestamp.csv" -NoTypeInformation

# ── 9. Fine-Grained Password Policies ───────────────────────────────
Write-Host "[9/10] Checking fine-grained password policies..." -ForegroundColor Yellow
Get-ADFineGrainedPasswordPolicy -Filter * |
    Select-Object Name, MinPasswordLength, ComplexityEnabled, LockoutThreshold, Precedence |
    Export-Csv "$OutputPath\09_FineGrainedPasswordPolicies_$timestamp.csv" -NoTypeInformation

# ── 10. Domain/Forest Functional Level Summary ──────────────────────
Write-Host "[10/10] Capturing domain/forest summary..." -ForegroundColor Yellow
$domain = Get-ADDomain
$forest = Get-ADForest
[PSCustomObject]@{
    DomainName          = $domain.DNSRoot
    DomainMode          = $domain.DomainMode
    ForestMode          = $forest.ForestMode
    PDCEmulator         = $domain.PDCEmulator
    DomainControllers   = ($forest.Domains | ForEach-Object { (Get-ADDomainController -Filter * -Server $_).Count } | Measure-Object -Sum).Sum
} | Export-Csv "$OutputPath\10_DomainForestSummary_$timestamp.csv" -NoTypeInformation

Write-Host "`n✅ AD Security Audit complete. Results exported to: $OutputPath" -ForegroundColor Green
Write-Host "Review each CSV file against the corresponding control in ad-audit-guide.md" -ForegroundColor Green

# ── Summary Output ──────────────────────────────────────────────────
Write-Host "`n──────────── QUICK SUMMARY ────────────" -ForegroundColor Cyan
Write-Host "Domain Admins count        : $((Get-ADGroupMember 'Domain Admins').Count)"
Write-Host "Dormant accounts (90+ days): $((Get-ADUser -Filter {LastLogonDate -lt $cutoffDate -and Enabled -eq $true}).Count)"
Write-Host "Password never expires     : $((Get-ADUser -Filter {PasswordNeverExpires -eq $true -and Enabled -eq $true}).Count)"
Write-Host "AS-REP roastable accounts  : $((Get-ADUser -Filter {DoesNotRequirePreAuth -eq $true}).Count)"
Write-Host "────────────────────────────────────────`n" -ForegroundColor Cyan
