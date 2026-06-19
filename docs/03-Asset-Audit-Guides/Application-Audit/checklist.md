# Application Audit Guide — Checklist

> **Asset Type:** Web Applications, Core Banking Systems, Internal Business Applications  
> **Audit Domain:** Application Security, ITGC  
> **Standards:** OWASP ASVS, OWASP Top 10, RBI Internet Banking Guidelines  
> **Risk Level:** 🔴 Critical for internet-facing; 🟠 High for internal applications

---

## Objective

To assess application-level security controls covering authentication, authorization, session management, input validation, error handling, audit logging, and SDLC practices.

---

## Audit Checklist by Category

### 1 — Authentication Controls

| # | Control | Test Method | Expected | Risk |
|---|---------|------------|----------|------|
| 1.1 | MFA enforced for all internet-facing application logins | Config review + test | OTP/TOTP/push required on login | 🔴 Critical |
| 1.2 | Account lockout after ≤ 5 failed login attempts | Test with wrong credentials | Account locks after 5 attempts | High |
| 1.3 | CAPTCHA on login page (bot protection) | UI inspection | CAPTCHA present | High |
| 1.4 | Passwords stored using bcrypt/scrypt/Argon2 (not MD5/SHA1) | Code review / config | Strong hashing algorithm | 🔴 Critical |
| 1.5 | Password reset uses secure token (not security questions) | Test reset flow | Time-limited token sent to registered email/mobile | High |
| 1.6 | Login page served over HTTPS only | Browser check | HTTP redirects to HTTPS; HSTS header present | High |
| 1.7 | Default / test credentials do not exist | Attempt common defaults | No admin/admin, test/test | 🔴 Critical |

```bash
# Test HTTPS enforcement
curl -I http://target-app.example.com
# Expected: 301 or 302 redirect to https://

# Check HSTS header
curl -sI https://target-app.example.com | grep -i "strict-transport"
# Expected: strict-transport-security: max-age=31536000; includeSubDomains

# Check for open redirect on login (common bypass)
curl -I "https://target-app.example.com/login?returnTo=https://evil.com"
```

---

### 2 — Authorization & Access Controls

| # | Control | Test Method | Expected | Risk |
|---|---------|------------|----------|------|
| 2.1 | Horizontal privilege escalation prevented | Test: access another user's data by modifying ID | Access denied; own data only visible | 🔴 Critical |
| 2.2 | Vertical privilege escalation prevented | Test: access admin functions as regular user | 403 Forbidden returned | 🔴 Critical |
| 2.3 | Insecure Direct Object References (IDOR) not present | Modify resource ID in URL/params | 403 or data not returned for unauthorized resource | 🔴 Critical |
| 2.4 | Role-based access control (RBAC) enforced | Review role matrix + test | Users can only access functions their role permits | High |
| 2.5 | Admin/management console not publicly accessible | URL and network check | Admin console on separate port or VPN only | 🔴 Critical |
| 2.6 | API endpoints enforce authorization | Test API with valid token of different user | Returns only authorized data | 🔴 Critical |

---

### 3 — Session Management

| # | Control | Test Method | Expected | Risk |
|---|---------|------------|----------|------|
| 3.1 | Session token is long (≥ 128 bits), random | Inspect token | No sequential or predictable pattern | High |
| 3.2 | Session cookie has Secure and HttpOnly flags | Browser DevTools | Both flags set | High |
| 3.3 | Session cookie has SameSite=Strict or Lax | Browser DevTools | SameSite attribute set | High |
| 3.4 | Session invalidated on logout | Test: logout then use old token | 401 Unauthorized | 🔴 Critical |
| 3.5 | Session expires after defined idle period | Leave idle, retry | Session expired after ≤ 15 minutes | High |
| 3.6 | New session token issued after login (session fixation prevention) | Compare pre- and post-login token | Token changes on successful login | High |

```bash
# Check cookie attributes
curl -c cookies.txt -sI https://target-app.example.com/login | grep -i "set-cookie"
# Look for: HttpOnly; Secure; SameSite=Strict

# Check if old session token still works after logout
# 1. Login, capture session token
# 2. Logout
# 3. Replay request with old token → should get 401/403
```

---

### 4 — Input Validation & Injection

| # | Control | Test Method | Expected | Risk |
|---|---------|------------|----------|------|
| 4.1 | SQL injection not present | Test with `'` in input fields | No SQL error returned; WAF blocks or input sanitized | 🔴 Critical |
| 4.2 | Cross-Site Scripting (XSS) not present | Test with `<script>alert(1)</script>` | Input encoded; script not executed | 🔴 Critical |
| 4.3 | XML/XXE injection not possible | Test with XXE payload if XML accepted | XML external entity not resolved | High |
| 4.4 | File upload restrictions enforced | Upload PHP/EXE file via file upload | File rejected; only allowed types accepted | High |
| 4.5 | Content Security Policy (CSP) header present | Browser / curl check | CSP header with restrictive policy | High |
| 4.6 | Input length validation enforced | Send oversized input | Input truncated or rejected | Medium |

```bash
# Quick header security check
curl -sI https://target-app.example.com | grep -iE "x-content-type|x-frame-options|content-security-policy|x-xss-protection|referrer-policy"

# Expected headers:
# X-Content-Type-Options: nosniff
# X-Frame-Options: DENY or SAMEORIGIN
# Content-Security-Policy: <policy>
# Referrer-Policy: strict-origin-when-cross-origin
```

---

### 5 — Error Handling & Information Disclosure

| # | Control | Test Method | Expected | Risk |
|---|---------|------------|----------|------|
| 5.1 | Detailed error messages not shown to users | Trigger error (invalid URL, 500) | Generic error page; no stack trace | High |
| 5.2 | Server version not disclosed in headers | Check `Server:` and `X-Powered-By:` headers | Headers not present or generic | Medium |
| 5.3 | Debug mode disabled in production | Code / config review | DEBUG = False; verbose logging off | High |
| 5.4 | API does not expose sensitive internal data | Review API responses | No internal IPs, DB names, stack traces | High |

```bash
# Check for server version disclosure
curl -sI https://target-app.example.com | grep -iE "server:|x-powered-by:|x-aspnet-version:"
```

---

### 6 — CBS-Specific Controls (Core Banking)

| # | Control | Test Method | Expected | Risk |
|---|---------|------------|----------|------|
| 6.1 | Transaction limits enforced per user role | Config review | Maker checker for large transactions | 🔴 Critical |
| 6.2 | Maker-checker enforced for critical transactions | Process review | No single user can initiate + authorize | 🔴 Critical |
| 6.3 | CBS audit trail captures all transactions with user ID + timestamp | Log review | Complete, tamper-proof audit trail | 🔴 Critical |
| 6.4 | CBS session timeout for teller terminals ≤ 5 minutes | Config review | Auto-logout after inactivity | High |
| 6.5 | CBS parameter changes are change-controlled | Change log vs. ITSM | All parameter changes traceable to approved CR | 🔴 Critical |
| 6.6 | CBS interfaces (SWIFT, NPCI, NEFT) reconciled daily | Reconciliation records | Daily reconciliation with zero unresolved exceptions | 🔴 Critical |

---

## Evidence to Collect

| Evidence | How | Format |
|----------|-----|--------|
| Application security scan report (SAST/DAST) | Obtain from security team | PDF |
| Last VAPT report for application | Obtain from security team | PDF |
| Authentication configuration | Screenshots from admin console | Screenshots |
| Cookie attributes | Browser DevTools screenshots | Screenshots |
| Security headers (curl output) | CLI output | TXT |
| Role-access matrix | Application admin export | CSV |
| CBS transaction limit configuration | CBS admin screenshot | Screenshot |
| CBS audit log sample | Log export | CSV |
| WAF configuration | WAF admin screenshot | Screenshot |

---

*Part of [IS Audit Playbook](../../README.md)*
