# Firewall Audit Guide

> **Asset Type:** Next-Generation Firewall — Fortinet FortiGate & Palo Alto Networks  
> **Audit Domain:** Network Security, Perimeter Defense, ITGC  
> **Regulatory Mapping:** RBI Cyber Framework § Network Security | ISO 27001 A.8.20, A.8.22 | NIST PR.AC-5, PR.DS-5 | PCI DSS Req. 1  
> **Risk Level:** 🔴 Critical — Firewall is the primary perimeter control; misconfiguration = direct network exposure

---

## Objective

To assess Next-Generation Firewall security posture covering:
- Ruleset review (inbound, outbound, inter-zone policies)
- Administrative access controls (management plane security)
- High Availability (HA) configuration
- Intrusion Prevention System (IPS) and threat prevention profiles
- Logging and SIEM forwarding
- Firmware/OS patch status
- Configuration change management

---

## Pre-Audit Requirements

### Access Needed (Both Platforms)
- [ ] Read-only administrator access to management console (GUI and CLI)
- [ ] Full ruleset export (XML or CSV)
- [ ] Log access (local logs or SIEM)
- [ ] Configuration backup file (sanitized — no credentials)

### Evidence Collection Approach
- Export full policy ruleset in structured format
- Screenshot all management access settings
- CLI output for hardening parameters (paste into text file)
- Compare against CIS Benchmark for respective platform

---

## Part A — Fortinet FortiGate

> Applicable to FortiOS 7.x. Commands may vary slightly across versions.

### Section A1 — Firmware & Version

| # | Control | CLI Command | Expected | Risk |
|---|---------|------------|----------|------|
| A1.1 | FortiOS is on current major version | `get system status` | Not on EOL version (< 6.4) | High |
| A1.2 | Latest FortiOS patch applied | Check version vs. Fortinet PSIRT | Within 2 patches of latest | High |
| A1.3 | FortiGuard definitions current | `diagnose autoupdate versions` | AV/IPS definitions within 7 days | High |
| A1.4 | Hardware support contract active | GUI: Support → License | Valid support contract | Medium |

```bash
# Check FortiOS version and model
get system status

# Check FortiGuard subscription and update status
diagnose autoupdate versions

# Check for pending firmware upgrades
execute firmware-upgrade-status

# Verify NTP synchronization (critical for log integrity)
diagnose sys ntp status
get system ntp
```

---

### Section A2 — Administrative Access Hardening

| # | Control | CLI Command | Expected | Risk |
|---|---------|------------|----------|------|
| A2.1 | Admin access restricted to management VLAN/IP | `show system admin` | `trusted hosts` defined on all admin accounts | 🔴 Critical |
| A2.2 | Default admin account renamed or disabled | Check admin list | No account named `admin` | 🔴 Critical |
| A2.3 | MFA enforced for all admin accounts | Check FortiToken config | FortiToken/TOTP assigned | 🔴 Critical |
| A2.4 | HTTPS only (HTTP disabled) on management | `get system interface` | HTTP access-admin disabled | High |
| A2.5 | SSHv2 only; SSH v1 disabled | `get system global` | SSH v2 only | High |
| A2.6 | Admin idle timeout ≤ 10 minutes | `get system global` | ≤ 600 seconds | High |
| A2.7 | Login attempt lockout configured | `get system global` | `admin-lockout-threshold ≤ 5` | High |
| A2.8 | Management interface is not internet-facing | Interface review | Management on dedicated mgmt interface | 🔴 Critical |
| A2.9 | SNMP v3 only; SNMPv1/v2c disabled | `get system snmp sysinfo` | SNMPv3 only | High |
| A2.10 | Console access requires password | Physical/config review | Console requires authentication | Medium |

```bash
# List all admin accounts with trusted hosts
show system admin

# Check global settings (timeout, lockout, SSH version)
get system global | grep -E "admin-|ssh-|https-|telnet-|timeout"

# Check interface management access settings
show system interface | grep -A 20 "allowaccess"

# Verify HTTPS certificate is valid (not default FortiGate cert)
get system global | grep admin-server-cert

# Check SNMP configuration
get system snmp sysinfo
get system snmp community    # Should be empty or SNMPv3 only
get system snmp user         # SNMPv3 users

# Check admin lockout configuration
get system global | grep -E "lockout|admin-concurrent"

# List all admin accounts
config system admin
    show

# Check FortiToken (MFA) assignments
show user fortitoken
config system admin
    get admin_name  # Check two-factor setting per admin
```

---

### Section A3 — Firewall Policy Review

| # | Control | CLI / GUI Check | Expected | Risk |
|---|---------|----------------|----------|------|
| A3.1 | No ANY/ANY/ANY (source/dest/service) rules | Policy export review | No unrestricted ANY rules | 🔴 Critical |
| A3.2 | Implicit deny-all is the last rule | Policy review | Default deny active | 🔴 Critical |
| A3.3 | Inbound rules from Internet are restricted | Policy review | Only necessary services; source IP restricted where possible | 🔴 Critical |
| A3.4 | RDP/SSH not directly exposed to Internet | Policy review | Port 3389/22 not allowed from 0.0.0.0 | 🔴 Critical |
| A3.5 | All policies have descriptions / comments | Policy review | All rules have business justification | Medium |
| A3.6 | Unused / disabled policies are removed | Policy review | No long-term disabled rules | Medium |
| A3.7 | Source NAT uses IP pools, not interface | NAT review | Dedicated NAT IP pool used | Medium |
| A3.8 | Security profiles (AV, IPS, Web Filter) applied to all outbound rules | Policy review | Profiles applied to all internet rules | High |
| A3.9 | Explicit deny rules exist before implicit deny | Policy structure | Logging enabled on deny rules | Medium |
| A3.10 | No test/temporary rules older than 30 days | Policy audit | No stale test rules | Medium |

```bash
# Export all firewall policies (from CLI)
show firewall policy

# Check for any-any-any rules (flag for manual review)
config firewall policy
    show | grep -B5 -A20 "srcaddr.*all.*dstaddr.*all"

# Check for policies allowing RDP/SSH from internet
# Review policies with dstintf = WAN interfaces
show firewall policy | grep -A30 "dstintf.*wan\|srcintf.*wan"

# List all firewall policies with action
config firewall policy
    show | grep -E "edit|action|srcaddr|dstaddr|service|srcintf|dstintf|status"

# Check if security profiles are applied
show firewall policy | grep -E "av-profile|ips-sensor|webfilter-profile|ssl-ssh-profile"

# Check logging configuration on policies
show firewall policy | grep -E "logtraffic|logtraffic-start"
```

---

### Section A4 — Threat Prevention Profiles

| # | Control | CLI / GUI Check | Expected | Risk |
|---|---------|----------------|----------|------|
| A4.1 | IPS sensor applied to all internet-facing policies | Policy review | IPS profile on all inbound/outbound | High |
| A4.2 | IPS signatures set to block (not detect-only) | IPS profile review | Action = block for High/Critical sigs | High |
| A4.3 | Antivirus profile applied to relevant policies | Policy review | AV on HTTP, SMTP, FTP, SMB protocols | High |
| A4.4 | SSL Inspection enabled for outbound HTTPS | SSL inspection profile | Full or certificate-inspection enabled | High |
| A4.5 | Web Filter profile applied to user traffic | Policy review | Web filter on user internet rules | High |
| A4.6 | Application Control profile applied | Policy review | App control on internet policies | Medium |
| A4.7 | DNS Filter enabled | DNS filter review | Malicious domain blocking active | High |
| A4.8 | FortiGuard Botnet IP/Domain blocking enabled | Settings review | Botnet C2 blocking enabled | High |

```bash
# Check IPS sensor configurations
show ips sensor

# Check which IPS sensor is in "block" vs "monitor"
config ips sensor
    show <sensor_name>

# Check AV profile settings
show antivirus profile

# Check SSL-SSH inspection profiles
show firewall ssl-ssh-profile

# Check application control profiles
show application list

# Check web filter profiles
show webfilter profile

# Check DNS filter
show dnsfilter profile

# Check botnet blocking status
get ips global | grep botnet
show system fortiguard | grep botnet
```

---

### Section A5 — Logging & SIEM

| # | Control | CLI Command | Expected | Risk |
|---|---------|------------|----------|------|
| A5.1 | Logging enabled on all deny and allow rules | Policy review | logtraffic = all on deny; at minimum on allow | High |
| A5.2 | Log forwarding to SIEM (Syslog/FortiAnalyzer) | `get log syslogd setting` | Active syslog or FortiAnalyzer configured | 🔴 Critical |
| A5.3 | Log transmission uses encrypted channel | Syslog config | Syslog over TLS (port 6514) | High |
| A5.4 | Local log retention configured | `get log disk setting` | Local logs as backup; ≥ 30 days local | Medium |
| A5.5 | Log timestamps are accurate (NTP synced) | `diagnose sys ntp status` | NTP active and synchronized | High |
| A5.6 | Admin activity logs forwarded | Log config review | Event logs include admin activity | High |
| A5.7 | Log retention in SIEM ≥ 180 days | SIEM policy check | ≥ 180 days (CERT-In mandate) | High |

```bash
# Check syslog forwarding configuration
get log syslogd setting
get log syslogd2 setting
get log syslogd3 setting

# Check FortiAnalyzer logging (if deployed)
get log fortianalyzer setting

# Check disk logging settings
get log disk setting

# Check log filter settings (ensure not filtering out important events)
get log syslogd filter
get log eventfilter

# Verify log integrity: check if logs are being generated
diagnose log test
execute log display  # View recent logs
```

---

## Part B — Palo Alto Networks

> Applicable to PAN-OS 10.x / 11.x

### Section B1 — PAN-OS Version & Licensing

| # | Control | CLI Command | Expected | Risk |
|---|---------|------------|----------|------|
| B1.1 | PAN-OS is current supported release | `show system info` | Not on EOL release | High |
| B1.2 | Latest maintenance release applied | Check against Palo Alto advisories | Within 1–2 maintenance releases | High |
| B1.3 | Threat Prevention license active | `show system info` | License valid | High |
| B1.4 | WildFire license active | `show system info` | License valid | High |
| B1.5 | Content updates current (Threat, App-ID, URL) | `show system state \| match content` | Within 24–48 hours | High |

```bash
# Check PAN-OS version and system info
show system info

# Check software and content update status
show system software status
show content-updates installed

# Check license status
show license

# Check high-availability state
show high-availability state
show high-availability all
```

---

### Section B2 — Management Plane Hardening

| # | Control | CLI Command | Expected | Risk |
|---|---------|------------|----------|------|
| B2.1 | Management interface on dedicated OOB network | `show interface management` | Not on production zone | 🔴 Critical |
| B2.2 | Permitted IP range on management interface | `show interface management` | Specific admin IP range, not 0.0.0.0/0 | 🔴 Critical |
| B2.3 | MFA enforced for all admin accounts | Admin profile review | RADIUS/SAML/TOTP with MFA | 🔴 Critical |
| B2.4 | HTTPS and SSH only (Telnet/HTTP disabled) | Management interface config | HTTP/Telnet unchecked | High |
| B2.5 | Admin idle timeout ≤ 10 minutes | `show deviceconfig system` | ≤ 10 minutes | High |
| B2.6 | Login lockout after ≤ 5 failed attempts | Admin account settings | ≤ 5 attempts, lockout ≥ 5 minutes | High |
| B2.7 | Custom admin roles — no unnecessary permissions | Admin role review | Least privilege per admin role | High |
| B2.8 | SNMPv3 only | SNMP config review | V3 with authPriv | High |
| B2.9 | Minimum TLS 1.2 for management HTTPS | `show deviceconfig system` | TLS 1.2 minimum | High |

```bash
# Check management interface settings
show interface management

# Check global admin settings
show deviceconfig system | match "login-banner\|idle-timeout\|max-failed\|lockout\|tls"

# List all admin accounts
show admins

# Check admin roles
show admin-role

# Check password complexity settings
show deviceconfig system | match password

# Check SNMP configuration
show snmp
show snmp v3 user

# Check management access profile
show system setting management-interface-ip

# Check certificate for management HTTPS
show sslmgr-store device-certificate
```

---

### Section B3 — Security Policy Review

| # | Control | CLI / GUI Check | Expected | Risk |
|---|---------|----------------|----------|------|
| B3.1 | No Any/Any/Any allow rules without profiles | Policy review | All allow rules have Security Profiles | 🔴 Critical |
| B3.2 | Default deny-all at bottom of rulebase | Policy review | Implicit deny active | 🔴 Critical |
| B3.3 | Rules use App-ID, not port-based for applications | Policy review | Application ≠ "any" on critical rules | High |
| B3.4 | Rules have descriptions (tags/owner metadata) | Policy audit | All rules have description and tags | Medium |
| B3.5 | Intrazone default action is deny | Zone protection review | Intrazone default = deny | Medium |
| B3.6 | No rules with source and destination = any | Policy review | No unrestricted rules | 🔴 Critical |
| B3.7 | Unused rules (hit count = 0) reviewed | Policy audit | Zero-hit rules are reviewed quarterly | Medium |
| B3.8 | Shadowed rules identified and removed | Policy consistency | No rules completely shadowed | Medium |
| B3.9 | Inter-zone traffic follows least privilege | Policy review | Zones enforce segmentation | High |

```bash
# Export full security rulebase
show running security-policy

# Check for rules with any-any source/destination
show security policies | match "any"

# Check rule hit counts (identify unused rules)
show running security-policy | match "hit-count"

# Alternatively, show detailed policy with hit count
show running security-policy rule <rule_name>

# Check all rules and their associated security profile groups
show running security-policy | match "profile"

# List all zones
show zone

# Check zone protection profiles
show zone-protection-profile

# Check DoS protection policies
show dos-policy
```

---

### Section B4 — Security Profiles & Threat Prevention

| # | Control | CLI / GUI Check | Expected | Risk |
|---|---------|----------------|----------|------|
| B4.1 | Vulnerability Protection profile applied to all rules | Policy review | Assigned to all internet-facing rules | High |
| B4.2 | Vulnerability profile set to block (not default) | Profile settings | Critical/High = block-ip; not alert-only | High |
| B4.3 | Antivirus profile applied to relevant rules | Policy review | Assigned to HTTP, SMTP, FTP, SMB policies | High |
| B4.4 | WildFire Analysis profile applied | Policy review | Unknown files sent for cloud analysis | High |
| B4.5 | URL Filtering profile applied to user traffic | Policy review | Assigned; block malicious/phishing categories | High |
| B4.6 | Anti-Spyware profile applied | Policy review | Assigned; DNS sinkholing enabled | High |
| B4.7 | SSL Decryption policy configured | Decryption policy review | Forward proxy active for HTTPS | High |
| B4.8 | Zone Protection profiles on all zones | Zone review | All external zones protected | High |
| B4.9 | DoS Protection policy configured | DoS policy | Thresholds defined for SYN, UDP, ICMP floods | High |

```bash
# Check Vulnerability Protection profiles
show profiles vulnerability

# Check Antivirus profiles
show profiles virus

# Check Anti-Spyware profiles (includes DNS sinkholing)
show profiles spyware

# Check URL Filtering profiles
show profiles url-filtering

# Check WildFire profiles
show profiles wildfire-analysis

# Check decryption policy
show running decryption-policy

# Check zone protection profiles applied
show zone | match "zone-protection-profile"

# Check WildFire submission status
show wildfire status
show wildfire statistics

# Check threat logs (recent blocks)
show threat-logs direction equal threat num-logs 100
```

---

### Section B5 — Logging & SIEM (Palo Alto)

| # | Control | CLI Command | Expected | Risk |
|---|---------|------------|----------|------|
| B5.1 | Log Forwarding Profile applied to all rules | Policy review | All rules have Log Forwarding Profile | 🔴 Critical |
| B5.2 | Syslog server / Panorama configured for forwarding | `show syslog` | Active syslog destination | 🔴 Critical |
| B5.3 | All log types forwarded (Traffic, Threat, System, Config) | Log forwarding profile | All 4 log types in profile | High |
| B5.4 | Log forwarding uses TLS (Syslog over TLS) | Syslog server config | TLS transport configured | High |
| B5.5 | Log retention in SIEM ≥ 180 days | SIEM policy | ≥ 180 days | High |
| B5.6 | Configuration change audit logged | Config audit log | All changes captured with username | High |
| B5.7 | NTP synchronized (accurate timestamps) | `show ntp` | Both NTP servers synced | High |

```bash
# Check syslog server configuration
show syslog

# Check log forwarding profiles
show log-forwarding-profile

# Check Panorama configuration (centralized management)
show panorama-status

# Verify all log types are being forwarded
show logging-status

# Check NTP synchronization
show ntp

# Review recent configuration changes (config audit log)
show config audit-log direction equal forward

# Check local log storage
show system disk-space
```

---

## Common Findings — Both Platforms

### Finding FW-001 — Management Access Not Restricted by Source IP

> **Condition:** The firewall management interface (HTTPS on port 443, SSH on port 22) was found accessible from any IP address (0.0.0.0/0) with no source IP restriction configured.  
> **Criteria:** CIS Benchmark for FortiGate (v1.0) Control 1.1.1 and CIS Benchmark for Palo Alto Networks (v1.1) Control 1.1 both require management access to be restricted to specific, authorized IP ranges. RBI Cybersecurity Framework Annex III Section 5.3 requires administrative access to network devices to be strictly controlled.  
> **Effect:** Unrestricted management access exposes the firewall console to brute-force attacks, credential stuffing, and exploitation of management interface vulnerabilities from any internet-connected source. Successful compromise of the firewall management plane grants the attacker full control over all network traffic policies.  
> **Recommendation:** (1) Restrict management access to the dedicated network management subnet (e.g., 10.0.200.0/24) on both HTTPS and SSH. (2) Disable HTTP and Telnet access. (3) Implement MFA for all administrative accounts. (4) Consider deploying a dedicated Out-of-Band (OOB) management network for firewall administration.  
> **Risk:** 🔴 Critical

---

### Finding FW-002 — Security Profiles Not Applied to All Outbound Rules

> **Condition:** Of 47 active outbound firewall policies, 23 rules (49%) had no Antivirus, IPS/Vulnerability, or URL Filtering security profiles applied. These rules covered user workstation segments (VLAN 10, 20) accessing the internet.  
> **Criteria:** Firewall policy best practice (NIST SP 800-41, PCI DSS Requirement 1.3.3) and the organization's Network Security Policy Section 8.4 require all internet-destined traffic to be inspected by threat prevention controls.  
> **Effect:** Outbound traffic from user workstations traverses the firewall without malware inspection, phishing protection, or command-and-control (C2) detection. Compromised workstations can communicate with C2 infrastructure undetected, exfiltrate data, and download secondary payloads without triggering any firewall-based alerts.  
> **Recommendation:** Create a Unified Security Profile Group containing AV, IPS, URL Filtering, Anti-Spyware, and WildFire profiles. Apply this group to all 23 identified outbound policies. Enable SSL Inspection to ensure encrypted traffic is not bypassing inspection.  
> **Risk:** 🟠 High

---

### Finding FW-003 — Firewall Logs Not Forwarded to SIEM

> **Condition:** Firewall traffic, threat, and system logs are being stored locally on the device only, with a 14-day rolling retention due to storage capacity. No syslog forwarding to the central SIEM (Splunk) was configured.  
> **Criteria:** CERT-In Directions (April 2022) Section 6(1) mandates 180-day log retention for ICT infrastructure. RBI Cybersecurity Framework Control 11.3 requires security device logs to be centrally stored and available for real-time monitoring.  
> **Effect:** 14-day local retention fails the CERT-In 180-day mandate, creating regulatory non-compliance. Absence of SIEM integration means threat events, policy violations, and administrative changes are not visible to the SOC, creating a blind spot for detection and incident investigation.  
> **Recommendation:** (1) Configure syslog forwarding (TLS-encrypted, port 6514) to Splunk immediately. (2) Forward all log types: Traffic, Threat, System, Configuration. (3) Create Splunk detection rules for: repeated failed logins, policy-deny spikes, IPS block events, admin config changes.  
> **Risk:** 🔴 Critical

---

### Finding FW-004 — Inbound ANY Rules for RDP and SMB

> **Condition:** Review of the inbound firewall policy identified two rules permitting TCP port 3389 (RDP) and TCP port 445 (SMB) from source `any` (0.0.0.0/0) to internal server segments.  
> **Criteria:** RBI Cybersecurity Framework Section 5.2 prohibits direct internet exposure of remote management and file-sharing protocols without access restriction. CIS Controls v8, Control 12.2 requires network access to be restricted to authorized business need.  
> **Effect:** Direct internet exposure of RDP is a leading initial access vector for ransomware operators and nation-state actors. Exposed SMB (Port 445) is the vector for EternalBlue/WannaCry-class exploits. Active exploitation of these two rules could result in full network compromise and ransomware deployment.  
> **Recommendation:** (1) Remove both rules immediately. (2) Route all RDP access through a VPN or PAM solution with MFA. (3) Ensure SMB 445 is never exposed to the internet; block at both perimeter and WAF if applicable. (4) Conduct a full ruleset review to identify any additional exposed high-risk ports.  
> **Risk:** 🔴 Critical

---

## Regulatory Mapping

| Control Area | RBI Cyber Framework | ISO 27001:2022 | NIST CSF | PCI DSS | CERT-In 2022 |
|---|---|---|---|---|---|
| Perimeter Access Control | §5.2 Network Security | A.8.20 | PR.AC-5 | Req. 1.3 | — |
| Management Plane Security | §7.2 Remote Access | A.8.21 | PR.IP-1 | Req. 2.2 | — |
| Threat Prevention / IPS | §12.2 Threat Intelligence | A.8.16 | DE.CM-4 | Req. 6.4 | — |
| Firewall Logging | §11.1 Log Management | A.8.15 | DE.CM-7 | Req. 10.2 | 180-day retention |
| Configuration Management | §5.1 Config Baseline | A.8.9 | PR.IP-1 | Req. 2.2 | — |
| Patch Management | §5.1 VAPT | A.8.8 | ID.RA-1 | Req. 6.3 | — |

---

*Part of [IS Audit Playbook](../../README.md) | Next: [Switch & Router Audit](switch-router-audit.md)*
