# Linux Systems Audit Guide

> **Asset Type:** Linux Servers (RHEL / CentOS / Ubuntu — production distributions)  
> **Audit Domain:** OS Security, ITGC — Configuration & Access Control  
> **Regulatory Mapping:** RBI Cyber Framework §7 | ISO 27001 A.8.9 | CIS Benchmark for Linux  
> **Risk Level:** 🟠 High — Linux servers often run critical middleware, databases, and payment systems

---

## Pre-Audit Requirements

- [ ] Non-root audit account with `sudo` read access or root on a read-only basis
- [ ] SSH access to target systems
- [ ] Access to `/etc/passwd`, `/etc/shadow`, `/etc/sudoers`, syslog, audit logs

---

## Audit Checklist

### Section 1 — Patch & Version Status

```bash
# OS version and kernel
cat /etc/os-release
uname -r

# Last patch date / pending updates
# RHEL/CentOS:
yum check-update 2>/dev/null | wc -l
rpm -qa --last | head -20

# Ubuntu/Debian:
apt list --upgradable 2>/dev/null | wc -l
grep "install\|upgrade" /var/log/dpkg.log | tail -20
```

---

### Section 2 — User Account Management

| # | Control | Command | Expected | Risk |
|---|---------|---------|----------|------|
| 2.1 | No accounts with empty passwords | `awk -F: '($2==""){print $1}' /etc/shadow` | Zero results | 🔴 Critical |
| 2.2 | Root login via SSH disabled | `grep PermitRootLogin /etc/ssh/sshd_config` | `PermitRootLogin no` | 🔴 Critical |
| 2.3 | All accounts with UID 0 are reviewed | `awk -F: '($3==0){print $1}' /etc/passwd` | Only root | 🔴 Critical |
| 2.4 | No accounts with /bin/bash shell that are system accounts | Shell review | Only service accounts have nologin/false shell | High |
| 2.5 | Inactive users are locked | Last login check | No users inactive > 90 days | High |
| 2.6 | Password aging enforced | `chage -l <user>` | Max age ≤ 90 days; warn at 14 days | High |

```bash
# Accounts with empty passwords
sudo awk -F: '($2 == "" || $2 == "!!" ){print "No password: "$1}' /etc/shadow

# All UIDs of 0 (should only be root)
awk -F: '($3 == 0) {print $1}' /etc/passwd

# Accounts with interactive shell (potential unused accounts)
awk -F: '($7 !~ /nologin|false|sync|shutdown|halt/) {print $1, $7}' /etc/passwd

# Last login for all users
lastlog | grep -v "Never logged in" | grep -v "Username"

# Password expiry for all users
for user in $(awk -F: '($7 !~ /nologin|false/) {print $1}' /etc/passwd); do
    chage -l $user 2>/dev/null | grep -E "Last|Maximum|Password" | head -3
    echo "User: $user"
    echo "---"
done
```

---

### Section 3 — Sudo and Privileged Access

| # | Control | Command | Expected | Risk |
|---|---------|---------|----------|------|
| 3.1 | Sudo access is restricted to authorized users | `visudo -c; cat /etc/sudoers` | Only specific users/groups; no NOPASSWD | 🔴 Critical |
| 3.2 | No NOPASSWD entries in sudoers | `grep NOPASSWD /etc/sudoers /etc/sudoers.d/*` | Zero results | 🔴 Critical |
| 3.3 | Sudo log is enabled | `grep logfile /etc/sudoers` | Logfile path defined or journald captures | High |
| 3.4 | Root access uses sudo (not direct su) | Process review | No direct root logins except break-glass | High |

```bash
# Show full sudoers (safe read-only)
sudo cat /etc/sudoers
sudo cat /etc/sudoers.d/* 2>/dev/null

# Find NOPASSWD entries (critical finding if found for privileged commands)
sudo grep -rn "NOPASSWD" /etc/sudoers /etc/sudoers.d/ 2>/dev/null

# Check who is in wheel/sudo group
grep -E "^(wheel|sudo)" /etc/group
getent group wheel
getent group sudo

# Check sudo logs (if configured)
sudo grep "sudo" /var/log/secure 2>/dev/null | tail -30
sudo journalctl -u sudo --since "30 days ago" 2>/dev/null | tail -30
```

---

### Section 4 — SSH Configuration Hardening

| # | Control | Check | Expected | Risk |
|---|---------|-------|----------|------|
| 4.1 | Root login disabled | `PermitRootLogin` | `no` | 🔴 Critical |
| 4.2 | Password authentication disabled (key-based only) | `PasswordAuthentication` | `no` (keys only) | High |
| 4.3 | SSH protocol version 2 only | `Protocol` | `2` | High |
| 4.4 | Max auth attempts ≤ 4 | `MaxAuthTries` | ≤ 4 | High |
| 4.5 | Idle timeout configured | `ClientAliveInterval` | ≤ 300 seconds | High |
| 4.6 | AllowUsers or AllowGroups restricts SSH access | `AllowUsers`/`AllowGroups` | Explicit whitelist | High |
| 4.7 | SSH listening on non-standard port (optional) | `Port` | Consider 2222 or other | Low |
| 4.8 | X11 forwarding disabled | `X11Forwarding` | `no` | Medium |

```bash
# Full SSH daemon configuration review
sudo sshd -T 2>/dev/null | grep -E "permitrootlogin|passwordauthentication|protocol|maxauthtries|clientaliveinterval|allowusers|allowgroups|x11forwarding|usepam|permitemptypasswords|banner|logingracetime"

# Alternative: cat the config file
sudo cat /etc/ssh/sshd_config | grep -v "^#" | grep -v "^$"

# Check SSH host key fingerprints
ssh-keygen -lf /etc/ssh/ssh_host_rsa_key.pub
ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
```

---

### Section 5 — Audit Logging (auditd)

| # | Control | Command | Expected | Risk |
|---|---------|---------|----------|------|
| 5.1 | auditd is installed and running | `systemctl status auditd` | Active (running) | 🔴 Critical |
| 5.2 | Audit rules cover privileged command use | `auditctl -l` | Rules for `/usr/bin/sudo`, `/bin/su`, etc. | High |
| 5.3 | Audit logs forwarded to SIEM | rsyslog/auditd config | auditd → rsyslog → SIEM | 🔴 Critical |
| 5.4 | Audit log retention ≥ 180 days | Log config | ≥ 180 days (CERT-In mandate) | High |
| 5.5 | Audit log file modifications are audited | auditctl rules | `-w /var/log/audit/ -p wa` | High |

```bash
# Check auditd status
sudo systemctl status auditd

# List all active audit rules
sudo auditctl -l

# Check audit log configuration
sudo cat /etc/audit/auditd.conf | grep -v "^#" | grep -v "^$"

# Recommended audit rules (verify these are in place)
# Should find rules similar to:
# -w /etc/passwd -p wa -k identity
# -w /etc/shadow -p wa -k identity
# -w /etc/sudoers -p wa -k sudoers
# -a always,exit -F arch=b64 -S execve -k exec_commands
# -w /var/log/wtmp -p wa -k session
# -w /var/run/utmp -p wa -k session

# View recent audit events
sudo ausearch -ts today | tail -50

# Check rsyslog forwarding to SIEM
sudo cat /etc/rsyslog.conf | grep -E "@@|@[0-9]"
```

---

### Section 6 — System Hardening

| # | Control | Command | Expected | Risk |
|---|---------|---------|----------|------|
| 6.1 | SELinux / AppArmor enabled and enforcing | `getenforce` / `aa-status` | Enforcing | High |
| 6.2 | Unnecessary services disabled | `systemctl list-units --state=running` | Only needed services | High |
| 6.3 | Host-based firewall active (firewalld/iptables/ufw) | `firewall-cmd --state` | Running | High |
| 6.4 | Core dumps disabled | `/proc/sys/kernel/core_pattern` | Restricted | Medium |
| 6.5 | SUID/SGID binaries reviewed | `find / -perm /4000` | Only expected binaries | High |
| 6.6 | World-writable files do not exist | `find / -perm -0002` | Zero unexpected results | High |

```bash
# SELinux status
getenforce
sestatus 2>/dev/null

# AppArmor status (Ubuntu)
sudo aa-status 2>/dev/null

# Running services
sudo systemctl list-units --type=service --state=running

# Firewall status
sudo firewall-cmd --state 2>/dev/null
sudo iptables -L -n 2>/dev/null | head -30
sudo ufw status verbose 2>/dev/null

# Find SUID binaries (compare against expected baseline)
sudo find / -perm /4000 -type f 2>/dev/null | sort

# World-writable files (excluding /tmp, /proc)
sudo find / -perm -0002 -type f ! -path "/proc/*" ! -path "/sys/*" ! -path "/tmp/*" 2>/dev/null

# Check cron jobs for unauthorized entries
cat /etc/crontab
ls -la /etc/cron.d/
ls -la /etc/cron.daily/ /etc/cron.weekly/ /etc/cron.monthly/
sudo crontab -l 2>/dev/null
```

---

## Common Findings

### Finding LNX-001 — Root Login via SSH Permitted

> **Condition:** SSH daemon configuration on all 8 Linux servers had `PermitRootLogin yes`, permitting direct root login via SSH from any authenticated source.
> **Criteria:** CIS Benchmark for RHEL 8 Control 5.2.7 requires `PermitRootLogin no`. RBI Cyber Framework §7.1 mandates hardening baselines aligned to industry benchmarks.
> **Effect:** Direct root SSH access bypasses sudo logging, removes the two-step privileged access requirement, and allows an attacker with stolen root credentials to immediately achieve full system compromise without leaving a sudo audit trail.
> **Recommendation:** Set `PermitRootLogin no` in `/etc/ssh/sshd_config` and reload SSH. Establish a break-glass procedure using sudo from a named admin account for emergency root access.
> **Risk:** 🔴 Critical

### Finding LNX-002 — auditd Not Running

> **Condition:** The `auditd` service was found stopped and disabled on 5 of 8 Linux servers. No alternative audit logging mechanism was in place. System activity logs were limited to `/var/log/secure` and `/var/log/messages`, which do not capture privileged command execution or file modification events.
> **Criteria:** CIS Benchmark for RHEL 8 Section 4 requires `auditd` to be enabled and running. CERT-In Directions mandate log retention for 180 days covering all ICT activity logs.
> **Effect:** Without auditd, privileged command execution, file changes to critical system files (`/etc/passwd`, `/etc/sudoers`), and unauthorized access cannot be detected or investigated retrospectively.
> **Recommendation:** Enable and start auditd on all 5 affected servers. Deploy a standard audit rule set (based on CIS or DISA STIG) via configuration management (Ansible/Chef). Forward audit logs to the central SIEM.
> **Risk:** 🔴 Critical

---

*Part of [IS Audit Playbook](../../README.md) | See also: [Windows Server](windows-server.md)*
