# Network Scan Templates — Audit Use

> **Companion to:** [Firewall Audit](../../03-Asset-Audit-Guides/Network-Devices/firewall-audit.md) | [Switch & Router Audit](../../03-Asset-Audit-Guides/Network-Devices/switch-router-audit.md)  
> **Purpose:** Standard scan templates to validate firewall rule effectiveness and identify exposed services during IS audit fieldwork

> ⚠️ **Authorization required:** Network scanning must only be performed with explicit written authorization from the system owner / CISO, as part of an approved audit engagement. Unauthorized scanning may violate organizational policy and law.

---

## 1. External Exposure Scan (Internet-Facing Assets)

Validates what is actually reachable from the internet, independent of what the firewall ruleset claims.

```bash
# Using nmap for external port scan (run from outside the network, with authorization)
nmap -Pn -sS -p 1-65535 --open -oN external_scan_results.txt <target-public-ip>

# Common high-risk ports to specifically verify are CLOSED externally
nmap -Pn -p 21,22,23,135,139,445,1433,1521,3306,3389,5432,5900 \
    --open -oN high_risk_ports.txt <target-public-ip-range>

# Service version detection (for patch level assessment)
nmap -Pn -sV -p 80,443 --open -oN service_versions.txt <target-public-ip>
```

**Expected Result:** Only explicitly approved services (typically 80, 443) should be open. Any other open port requires immediate investigation and cross-reference against the firewall ruleset and change records.

---

## 2. Internal Network Segmentation Validation

Confirms VLAN/segment isolation is actually enforced, not just configured.

```bash
# From a host in VLAN A, attempt to reach hosts in VLAN B (should fail if segmented)
nmap -Pn -p 22,445,3389,1433,3306 --open <vlan-b-subnet-range>

# Test specific segmentation boundary (e.g., User VLAN → Server VLAN)
nmap -Pn -sn <server-vlan-subnet>  # Host discovery only

# Validate DMZ isolation — DMZ hosts should NOT reach internal network directly
# (Run from a DMZ host with authorization)
nmap -Pn -sn <internal-subnet-range>
```

**Expected Result:** No connectivity between segments that should be isolated, except through explicitly approved and logged paths (e.g., via a proxy or jump server).

---

## 3. Firewall Rule Verification Matrix

Use this template to systematically validate that the firewall ruleset matches actual behavior:

```
TEST CASE TEMPLATE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Source:          [IP/Subnet]
Destination:      [IP/Subnet]
Port/Protocol:    [e.g., TCP/443]
Expected Result:  [Allow / Deny per ruleset]
Actual Result:    [Allow / Deny observed]
Match:            [Yes/No]
Evidence:         [Screenshot/output reference]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

| Test # | Source | Destination | Port | Expected | Actual | Match |
|--------|--------|-------------|------|----------|--------|-------|
| 1 | Internet | Web Server | 443/TCP | Allow | | |
| 2 | Internet | Web Server | 22/TCP | Deny | | |
| 3 | Internet | DB Server | 1433/TCP | Deny | | |
| 4 | User VLAN | Server VLAN | 3389/TCP | Deny | | |
| 5 | DMZ | Internal LAN | Any | Deny | | |
| 6 | Mgmt Subnet | Firewall Mgmt IP | 443/TCP | Allow | | |
| 7 | Any (non-mgmt) | Firewall Mgmt IP | 443/TCP | Deny | | |

---

## 4. TLS/SSL Configuration Scan

For all internet-facing services using HTTPS:

```bash
# Using nmap ssl-enum-ciphers script
nmap -p 443 --script ssl-enum-ciphers <target>

# Using testssl.sh (more comprehensive — recommended)
./testssl.sh --severity HIGH https://target-domain.com

# Quick check for deprecated protocols (SSLv3, TLS 1.0, TLS 1.1)
nmap -p 443 --script ssl-enum-ciphers <target> | grep -E "SSLv|TLSv1.0|TLSv1.1"
```

**Audit Criteria:** Only TLS 1.2 and TLS 1.3 should be enabled. SSLv2, SSLv3, TLS 1.0, and TLS 1.1 must be disabled per PCI DSS and RBI guidance.

---

## 5. Vulnerability Scan (Authenticated, for VAPT cross-reference)

```bash
# Basic vulnerability scan using nmap NSE vuln scripts (lightweight check)
nmap -Pn --script vuln <target>

# For comprehensive VAPT, use a dedicated tool (Nessus, OpenVAS, Qualys)
# This is typically performed by a specialized VAPT team, but IS auditors
# should review and cross-reference these results, not necessarily run them.
```

> 📌 **Audit role clarification:** Full vulnerability scanning and penetration testing is typically the responsibility of a dedicated security/VAPT team. The IS auditor's role is generally to: (1) verify VAPT was conducted on schedule, (2) review the VAPT report for completeness, (3) verify remediation of identified vulnerabilities, and (4) perform limited, scoped verification scans as described above to validate firewall/network control effectiveness — not to replace formal VAPT.

---

## Evidence Documentation Template

```
NETWORK SCAN EVIDENCE LOG
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Scan Date:        [DD-MMM-YYYY]
Performed By:     [Auditor Name]
Authorization Ref:[Change ticket / approval email reference]
Tool Used:        [nmap version / testssl.sh version]
Target Scope:     [IP ranges / domains scanned]

Scan Command:
[Exact command executed]

Raw Output File:  [filename.txt — attach as evidence]

Summary of Findings:
[Open ports found that should be closed]
[Segmentation failures identified]
[Deprecated TLS protocols identified]

Cross-Reference:
[Link to corresponding firewall-audit.md finding ID if applicable]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

*Part of [IS Audit Playbook](../../README.md) | See also: [Firewall Audit](../../03-Asset-Audit-Guides/Network-Devices/firewall-audit.md)*
