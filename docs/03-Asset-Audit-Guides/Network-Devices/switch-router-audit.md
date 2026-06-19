# Switch & Router Audit Guide

> **Asset Type:** Network Switches and Routers — Cisco IOS / IOS-XE (also applicable concepts for Juniper, Arista)  
> **Audit Domain:** Network Infrastructure Security, ITGC  
> **Regulatory Mapping:** RBI Cyber Framework §5 | ISO 27001 A.8.20, A.8.22 | CIS Benchmark for Cisco IOS  
> **Risk Level:** 🟠 High — Network infrastructure is the foundation for segmentation and traffic control

---

## Objective

To assess switch and router security covering management plane hardening, VLAN segmentation, routing protocol security, port security, and logging configuration.

---

## Pre-Audit Requirements

- [ ] Read-only (Level 5 / view) access via SSH to network devices
- [ ] Network topology diagram
- [ ] VLAN and IP addressing scheme documentation
- [ ] Change management records for network device configuration

---

## Audit Checklist

### Section 1 — Management Plane Hardening

| # | Control | CLI Command | Expected | Risk |
|---|---------|------------|----------|------|
| 1.1 | Telnet is disabled; SSH only | `show run \| include transport input` | `transport input ssh` only | 🔴 Critical |
| 1.2 | SSH version 2 only | `show ip ssh` | SSH version 2 | High |
| 1.3 | Enable secret (not enable password) is configured | `show run \| include enable` | `enable secret` (hashed) used | 🔴 Critical |
| 1.4 | Local user passwords use strong encryption (type 8/9, not type 7) | `show run \| include username` | Type 8 (SHA-256) or type 9 (scrypt) | High |
| 1.5 | AAA (TACACS+/RADIUS) is used for admin authentication | `show run \| include aaa` | Centralized AAA configured | 🟠 High |
| 1.6 | VTY access is restricted by ACL | `show run \| section line vty` | `access-class` applied | 🔴 Critical |
| 1.7 | Idle session timeout configured | `show run \| include exec-timeout` | ≤ 10 minutes | High |
| 1.8 | SNMP v3 only; default community strings removed | `show run \| include snmp` | No `public`/`private`; v3 only | 🔴 Critical |
| 1.9 | Login banner configured (legal notice) | `show run \| include banner` | Banner present | Medium |
| 1.10 | NTP configured and synchronized | `show ntp status` | Synchronized; NIC/NPL or internal hierarchy | High |

```bash
# Check transport input on VTY lines
show run | section line vty

# Check SSH configuration
show ip ssh

# Check for weak password encryption (type 7 is reversible!)
show run | include username
# RED FLAG: "username admin password 7 0822455D0A16" → Type 7 is crackable instantly

# Check SNMP configuration (flag default community strings)
show run | include snmp-server community
# RED FLAG: snmp-server community public RO  → Critical finding

# Check AAA configuration
show run | include aaa

# Check NTP status
show ntp status
show ntp associations

# Check configured banners
show run | section banner
```

---

### Section 2 — VLAN & Network Segmentation

| # | Control | CLI Command | Expected | Risk |
|---|---------|------------|----------|------|
| 2.1 | Default VLAN (VLAN 1) is not used for production traffic | `show vlan brief` | VLAN 1 unused or restricted | High |
| 2.2 | Native VLAN on trunk ports is changed from default | `show interface trunk` | Native VLAN ≠ 1 | High |
| 2.3 | Unused switch ports are disabled (shutdown) | `show interface status` | Unused ports in "disabled" state | High |
| 2.4 | Unused ports assigned to a "parking" VLAN | Port config review | Isolated unused-port VLAN | Medium |
| 2.5 | Inter-VLAN routing follows least privilege (ACLs between VLANs) | Router ACL review | ACLs restrict cross-VLAN traffic appropriately | 🟠 High |
| 2.6 | Management VLAN is separate from user/data VLANs | VLAN design review | Dedicated management VLAN | 🔴 Critical |
| 2.7 | DMZ segments are properly isolated from internal network | Topology + ACL review | DMZ traffic restricted to defined flows only | 🔴 Critical |

```bash
# Check VLAN configuration
show vlan brief

# Check trunk port native VLAN
show interface trunk

# Check port status — identify unused/unsecured ports
show interface status

# Verify unused ports are administratively shut down
show run | section interface
# Look for interfaces without "shutdown" that show "notconnect" in status
```

---

### Section 3 — Port Security (Layer 2)

| # | Control | CLI Command | Expected | Risk |
|---|---------|------------|----------|------|
| 3.1 | Port security enabled on access ports | `show port-security` | Enabled with MAC limit | High |
| 3.2 | DHCP snooping enabled (prevents rogue DHCP) | `show ip dhcp snooping` | Enabled on access VLANs | High |
| 3.3 | Dynamic ARP Inspection (DAI) enabled | `show ip arp inspection` | Enabled | High |
| 3.4 | BPDU Guard enabled on access ports | `show spanning-tree summary` | BPDU Guard active | Medium |
| 3.5 | Root Guard configured on appropriate ports | STP config review | Configured to protect root bridge | Medium |
| 3.6 | 802.1X / NAC enforced for endpoint connections | `show dot1x all` | Enabled where applicable | 🟠 High |

```bash
# Check port security status
show port-security
show port-security interface gi0/1

# Check DHCP snooping
show ip dhcp snooping
show ip dhcp snooping binding

# Check Dynamic ARP Inspection
show ip arp inspection
show ip arp inspection interfaces

# Check Spanning Tree and BPDU Guard
show spanning-tree summary
show run | include bpduguard
```

---

### Section 4 — Routing Protocol Security

| # | Control | CLI Command | Expected | Risk |
|---|---------|------------|----------|------|
| 4.1 | Routing protocol authentication enabled (OSPF/EIGRP/BGP) | `show ip protocols` | MD5 or SHA authentication configured | 🟠 High |
| 4.2 | Passive interfaces configured on non-routing-peer interfaces | `show ip protocols` | Passive-interface applied to user-facing VLANs | Medium |
| 4.3 | Route filtering / prefix lists applied where relevant | ACL/prefix-list review | Filters prevent unauthorized route injection | Medium |
| 4.4 | BGP — max-prefix limits configured (if applicable) | `show run \| section router bgp` | Limits configured to prevent route table exhaustion | Medium |

```bash
# Check routing protocol configuration
show ip protocols

# Check OSPF authentication
show ip ospf interface | include Authentication

# Check EIGRP authentication
show run | section router eigrp
```

---

### Section 5 — Access Control Lists (ACLs)

| # | Control | CLI Command | Expected | Risk |
|---|---------|------------|----------|------|
| 5.1 | ACLs follow least privilege (explicit deny default) | `show access-lists` | Specific permits; implicit/explicit deny | 🔴 Critical |
| 5.2 | No overly permissive ACL entries (`permit ip any any`) | ACL review | No unrestricted entries on critical interfaces | 🔴 Critical |
| 5.3 | ACLs are applied to the correct interfaces and direction | Interface config review | Correct in/out direction confirmed | High |
| 5.4 | ACL changes are logged | `show access-lists` with `log` keyword | Critical ACL entries include logging | Medium |

```bash
# Review all ACLs
show access-lists

# Check for dangerous "permit ip any any" entries
show access-lists | include permit ip any any

# Verify ACL application to interfaces
show ip interface gi0/1 | include access list
```

---

### Section 6 — Logging & SIEM Integration

| # | Control | CLI Command | Expected | Risk |
|---|---------|------------|----------|------|
| 6.1 | Syslog forwarding to central SIEM configured | `show run \| include logging` | Syslog server IP configured | 🔴 Critical |
| 6.2 | Logging level captures security-relevant events | `show logging` | Informational level minimum; debug for security events | High |
| 6.3 | Local buffer logging configured as backup | `show run \| include logging buffered` | Adequate buffer size | Medium |
| 6.4 | Configuration change logging enabled | `show archive log config all` | Archive logging active | High |
| 6.5 | AAA accounting enabled for command logging | `show run \| include aaa accounting` | Command accounting active | High |

```bash
# Check syslog configuration
show run | include logging

# Check logging buffer and levels
show logging

# Check configuration change archive (who changed what, when)
show archive log config all

# Check AAA command accounting
show run | include aaa accounting
```

---

## Evidence to Collect

| Evidence | Method | Format |
|----------|--------|--------|
| Full running-config (sanitized of passwords) | `show running-config` | TXT |
| VLAN configuration | `show vlan brief` | TXT |
| Port security status | `show port-security` | TXT |
| ACL listing | `show access-lists` | TXT |
| SNMP configuration | `show run \| include snmp` | TXT |
| Syslog/logging configuration | `show run \| include logging` | TXT |
| NTP synchronization status | `show ntp status` | Screenshot |
| AAA configuration | `show run \| include aaa` | TXT |

---

## Common Findings

### Finding NET-001 — Default SNMP Community Strings in Use

> **Condition:** Review of 14 network switches and routers identified SNMP configured with the default community strings "public" (read-only) and "private" (read-write) active on all devices.
> **Criteria:** CIS Benchmark for Cisco IOS Control 1.6 requires default SNMP community strings to be removed and replaced with SNMPv3 authentication. RBI Cyber Framework §7.1 requires hardening of all network devices.
> **Effect:** Default community strings are publicly known and trivially exploitable. An attacker with network access could use the "private" community string to read and modify device configuration, including routing tables, ACLs, and potentially gain full administrative control of network infrastructure.
> **Recommendation:** Immediately remove all default SNMP community strings. Migrate to SNMPv3 with authPriv (authentication and encryption). If SNMPv2c must be retained for legacy monitoring tools, restrict access via ACL to authorized monitoring servers only and use complex, unique community strings.
> **Risk:** 🔴 Critical

### Finding NET-002 — VTY Access Not Restricted by ACL

> **Condition:** SSH (VTY) management access on all reviewed network devices had no access-class ACL applied, permitting management connection attempts from any IP address reachable on the network, rather than being restricted to the dedicated network management subnet.
> **Criteria:** CIS Benchmark for Cisco IOS Control 1.1 and the organization's Network Security Policy require management access to network devices to be restricted to a defined management subnet via ACL.
> **Effect:** Unrestricted VTY access increases the attack surface for brute-force and credential-based attacks against network device management. Any compromised host on the internal network could attempt to access network device management interfaces.
> **Recommendation:** Create and apply an access-class ACL on all VTY lines restricting SSH access to the defined network management subnet only. Verify the change does not lock out legitimate administrative access before full deployment.
> **Risk:** 🔴 Critical

---

## Regulatory Mapping

| Control Area | RBI Cyber Framework | ISO 27001:2022 | CIS Benchmark |
|---|---|---|---|
| Management Access | §7.2 Remote Access | A.8.20 | Section 1 |
| Network Segmentation | §5.1 Segmentation | A.8.22 | Section 2 |
| Logging | §11.1 Log Management | A.8.15 | Section 3 |
| Authentication | §6.3 Authentication | A.9.4 | Section 1.4–1.5 |

---

*Part of [IS Audit Playbook](../../README.md) | See also: [Firewall Audit](firewall-audit.md)*
