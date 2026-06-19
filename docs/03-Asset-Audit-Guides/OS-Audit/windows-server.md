# Windows Server Audit Guide

> **Asset Type:** Microsoft Windows Server (2016 / 2019 / 2022)  
> **Audit Domain:** OS Security, ITGC — Configuration & Access Control  
> **Regulatory Mapping:** RBI Cyber Framework §7 | ISO 27001 A.8.9 | NIST PR.PS | CIS Benchmark for Windows Server  
> **Risk Level:** 🟠 High — Windows servers host critical applications and services; misconfigurations are widely exploited

---

## Objective

To assess Windows Server security controls covering:
- Patch and version compliance
- Local account and password management
- Audit policy and event logging
- Security configuration and hardening
- Remote access and management security
- Service and scheduled task review

---

## Pre-Audit Requirements

### Access Needed
- [ ] Domain account with Local Administrator rights on target servers (or WinRM access)
- [ ] Remote PowerShell access (WinRM enabled)
- [ ] Group Policy Management Console access (for GPO review)
- [ ] Event Viewer access on target systems

---

## Audit Checklist

### Section 1 — Patch & Version Status

| # | Control | Command | Expected | Risk |
|---|---------|---------|----------|------|
| 1.1 | OS is a supported version | `winver` / `Get-ComputerInfo` | Not on EOL (2012 R2 or older is EOL) | High |
| 1.2 | Latest cumulative update applied | `Get-HotFix` / WSUS | Within 30-day patch cycle | High |
| 1.3 | Windows Update is configured to use WSUS | Registry / GPO check | WSUS configured; auto-update not disabled | High |

```powershell
# Check OS version and build
Get-ComputerInfo | Select-Object OsName, OsVersion, OsBuildNumber, WindowsVersion

# Check installed hotfixes (last 10)
Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 10 Description, HotFixID, InstalledBy, InstalledOn

# Check Windows Update configuration
Get-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" |
    Select-Object NoAutoUpdate, AUOptions, UseWUServer, WUServer, WUStatusServer
```

---

### Section 2 — Local Accounts & Authentication

| # | Control | Command | Expected | Risk |
|---|---------|---------|----------|------|
| 2.1 | Built-in Administrator account is renamed or disabled | `net user Administrator` | Renamed and/or disabled | 🔴 Critical |
| 2.2 | Built-in Guest account is disabled | `net user Guest` | Disabled | High |
| 2.3 | No unauthorized local admin accounts | `net localgroup Administrators` | Only domain groups + one break-glass account | High |
| 2.4 | Local admin passwords managed via LAPS | LAPS attribute check | ms-Mcs-AdmPwd or Windows LAPS attribute present | High |
| 2.5 | Password complexity enforced via local policy | `net accounts` | Complexity enabled; min 12 chars | High |
| 2.6 | Account lockout configured | `net accounts` | Lockout after ≤ 5 attempts | High |

```powershell
# Check local users and their status
Get-LocalUser | Select-Object Name, Enabled, LastLogon, PasswordExpires, PasswordLastSet, Description

# Check Local Administrators group members
Get-LocalGroupMember -Group "Administrators" | Select-Object Name, ObjectClass, PrincipalSource

# Check local security policy (password and lockout)
net accounts

# Check if built-in Administrator is renamed
Get-LocalUser | Where-Object { $_.SID -like "*-500" } | Select-Object Name, Enabled

# Check LAPS deployment (classic LAPS)
Get-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft Services\AdmPwd" -ErrorAction SilentlyContinue

# Check Windows LAPS (2022/newer)
Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\LAPS" -ErrorAction SilentlyContinue
```

---

### Section 3 — Audit Policy & Event Logging

| # | Control | Command | Expected | Risk |
|---|---------|---------|----------|------|
| 3.1 | Advanced audit policy configured per CIS benchmark | `auditpol /get /category:*` | All categories auditing Success and Failure | High |
| 3.2 | Security event log size ≥ 1 GB | Event log properties | ≥ 1,073,741,824 bytes | High |
| 3.3 | Event log set to "do not overwrite" or large size | Policy check | Archive or do-not-overwrite | High |
| 3.4 | Events forwarded to SIEM | SIEM check | Windows Event Forwarding or agent active | 🔴 Critical |
| 3.5 | PowerShell script block logging enabled | Registry check | ScriptBlockLogging = 1 | High |
| 3.6 | PowerShell module logging enabled | Registry check | ModuleLogging = 1 | High |

```powershell
# Check full advanced audit policy
auditpol /get /category:* /r | ConvertFrom-Csv | Format-Table -AutoSize

# Check Security event log configuration
$log = Get-WinEvent -ListLog Security
[PSCustomObject]@{
    LogName         = $log.LogName
    MaxSizeMB       = [math]::Round($log.MaximumSizeInBytes/1MB, 0)
    RecordCount     = $log.RecordCount
    IsEnabled       = $log.IsEnabled
    LogMode         = $log.LogMode
}

# Check PowerShell logging (Script Block)
Get-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -ErrorAction SilentlyContinue

# Check PowerShell module logging
Get-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging" -ErrorAction SilentlyContinue

# Check Windows Event Forwarding configuration
Get-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\EventForwarding\SubscriptionManager" -ErrorAction SilentlyContinue
```

---

### Section 4 — Security Hardening

| # | Control | Command | Expected | Risk |
|---|---------|---------|----------|------|
| 4.1 | SMBv1 is disabled | Registry check | SMBv1 = disabled | 🔴 Critical |
| 4.2 | LLMNR disabled (prevents poisoning) | Registry / GPO | LLMNR = 0 | High |
| 4.3 | NetBIOS over TCP/IP disabled where possible | Adapter settings | Disabled on non-WINS networks | High |
| 4.4 | RDP encryption set to high | Registry | SecurityLayer ≥ 2; MinEncryptionLevel = 3 | High |
| 4.5 | NLA (Network Level Authentication) enabled for RDP | Registry | UserAuthentication = 1 | High |
| 4.6 | Windows Firewall enabled on all profiles | `Get-NetFirewallProfile` | Enabled on Domain/Private/Public | High |
| 4.7 | Unnecessary services are stopped and disabled | `Get-Service` | No Telnet, FTP, TFTP, IIS on non-web servers | Medium |
| 4.8 | Windows Defender / AV is active and updated | `Get-MpComputerStatus` | Real-time protection ON; definitions < 3 days | High |

```powershell
# Check SMBv1 status
Get-SmbServerConfiguration | Select-Object EnableSMB1Protocol

# Alternative SMB check
Get-WindowsOptionalFeature -Online -FeatureName "SMB1Protocol" | Select-Object FeatureName, State

# Check LLMNR
Get-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" |
    Select-Object EnableMulticast

# Check RDP security settings
Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" |
    Select-Object SecurityLayer, MinEncryptionLevel, UserAuthentication

# Check Windows Firewall profiles
Get-NetFirewallProfile | Select-Object Name, Enabled, DefaultInboundAction, DefaultOutboundAction

# Check running services (look for unnecessary ones)
Get-Service | Where-Object { $_.Status -eq "Running" } |
    Select-Object Name, DisplayName, StartType |
    Where-Object { $_.Name -in @("Telnet","FTPSVC","TFTPd","SNMPTRAP","RemoteRegistry","W3SVC") }

# Windows Defender status
Get-MpComputerStatus | Select-Object AMServiceEnabled, AntispywareEnabled,
    AntivirusEnabled, RealTimeProtectionEnabled, AntivirusSignatureLastUpdated,
    AntivirusSignatureVersion, NISEnabled
```

---

### Section 5 — Remote Management Security

| # | Control | Command | Expected | Risk |
|---|---------|---------|----------|------|
| 5.1 | RDP restricted to jump server / VPN users | Firewall rule check | Port 3389 not open from internet | 🔴 Critical |
| 5.2 | WinRM (PowerShell Remoting) restricted to admin hosts | `Get-WSManInstance` | Listener restricted or require HTTPS | High |
| 5.3 | Remote Registry service disabled | `Get-Service RemoteRegistry` | Disabled | Medium |
| 5.4 | Local admin account not used for remote management | Process review | Domain accounts used; local admin via LAPS only | High |

```powershell
# Check WinRM listener configuration
Get-WSManInstance winrm/config/Listener -Enumerate |
    Select-Object Transport, Address, Port, Enabled

# Check remote registry service
Get-Service RemoteRegistry | Select-Object Name, Status, StartType

# Check who is allowed to connect via RDP (local policy)
Get-LocalGroupMember -Group "Remote Desktop Users"
```

---

### Section 6 — Scheduled Tasks & Startup Programs

Attackers commonly use scheduled tasks for persistence. Auditors should flag unexpected tasks.

```powershell
# List all scheduled tasks (non-Microsoft)
Get-ScheduledTask | Where-Object {
    $_.TaskPath -notlike "\Microsoft\*"
} | Select-Object TaskName, TaskPath, State,
    @{N="Actions"; E={($_.Actions | Select-Object -ExpandProperty Execute) -join ", "}} |
    Sort-Object TaskPath, TaskName

# Scheduled tasks running as SYSTEM
Get-ScheduledTask | Where-Object {
    ($_.Principal.UserId -eq "SYSTEM" -or $_.Principal.RunLevel -eq "Highest") -and
    ($_.TaskPath -notlike "\Microsoft\*")
} | Select-Object TaskName, TaskPath, State

# Startup items in registry (persistence check)
@(
  "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
  "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce",
  "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
) | ForEach-Object {
    if (Test-Path $_) {
        Write-Host "`n[$_]"
        Get-ItemProperty $_ | Select-Object * -ExcludeProperty PS*
    }
}
```

---

## Sample Findings

### Finding WS-001 — SMBv1 Enabled

> **Condition:** SMBv1 protocol was found enabled on 14 of 22 production Windows servers tested. SMBv1 has been deprecated by Microsoft since 2014 and disabled by default since Windows Server 2016.
> **Criteria:** CIS Benchmark for Windows Server 2019 (v2.0) Control 18.3.3 requires SMBv1 to be disabled. Microsoft Security Advisory ADV170012 recommends immediate disablement.
> **Effect:** SMBv1 is the vector for the EternalBlue exploit (MS17-010), used by WannaCry ransomware and NotPetya. Enabled SMBv1 on any domain-joined machine creates lateral movement risk across the network.
> **Recommendation:** Disable SMBv1 immediately: `Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force`. Deploy via GPO to prevent re-enablement.
> **Risk:** 🔴 Critical

### Finding WS-002 — Built-in Administrator Account Active and Unnamed

> **Condition:** The built-in local Administrator account (RID 500) was found enabled and using the default name "Administrator" on all 22 servers tested. No LAPS deployment was found to manage local admin passwords.
> **Criteria:** CIS Benchmark for Windows Server Controls 2.3.1.1 and 2.3.1.2 require the built-in Administrator account to be renamed and that its use be tracked. RBI Cyber Framework §7.1 requires hardening baselines to be applied.
> **Effect:** A known account name combined with password spray attacks or credential reuse greatly increases the risk of compromise. Without LAPS, local admin passwords are likely identical across all servers — one compromised server exposes all.
> **Recommendation:** Rename the built-in Administrator account to a non-obvious name via GPO. Deploy Windows LAPS (built into Windows Server 2019+) to manage unique, rotating local admin passwords. Monitor usage of RID-500 accounts.
> **Risk:** 🟠 High

---

## Regulatory Mapping

| Control Area | RBI Cyber Framework | ISO 27001:2022 | CIS Benchmark |
|---|---|---|---|
| Patch Management | §7.2 | A.8.8 | Section 3 |
| Hardening | §7.1 | A.8.9 | Section 2, 18 |
| Audit Logging | §11.1 | A.8.15 | Section 17 |
| Account Management | §6.2 | A.9.2 | Section 2.3 |
| Remote Access | §7.2 | A.8.20 | Section 18 |

---

*Part of [IS Audit Playbook](../../README.md) | See also: [Linux Systems](linux-systems.md)*
