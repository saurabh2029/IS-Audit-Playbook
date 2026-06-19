# Application Audit — Evidence Collection Guide

> **Companion to:** [Application Audit Checklist](checklist.md)  
> **Purpose:** Define exactly what evidence to capture for each control area during application audit fieldwork

---

## Evidence Collection Principles

Evidence must be **sufficient, reliable, relevant, and useful** (ISACA's SRRU principle) to support audit conclusions. For application audits specifically:

- Screenshots must include the **URL/timestamp** visible where possible
- Configuration exports should be **system-generated**, not manually typed
- Test results (e.g., SQLi attempts) must show **both the request and response**
- All evidence must be **traceable** to the specific control tested

---

## Evidence Matrix by Control Area

### Authentication Evidence

| Evidence Item | How to Capture | Naming Convention |
|--------------|----------------|-------------------|
| MFA enforcement screenshot | Login flow screenshot showing OTP/TOTP prompt | `APP-AUTH-01-MFA-Screenshot.png` |
| Account lockout test | Screenshots of 5 failed attempts + lockout message | `APP-AUTH-02-Lockout-Test.png` |
| Password hashing algorithm | Code review extract or config file (sanitized) | `APP-AUTH-03-HashConfig.txt` |
| Password reset flow | Screen recording or sequential screenshots | `APP-AUTH-04-ResetFlow.mp4` |
| HTTPS enforcement | curl output showing 301/302 redirect | `APP-AUTH-05-HTTPS-Redirect.txt` |
| Default credential test | Login attempt screenshot with result | `APP-AUTH-06-DefaultCreds.png` |

### Authorization Evidence

| Evidence Item | How to Capture | Naming Convention |
|--------------|----------------|-------------------|
| IDOR test | Burp Suite / Postman request-response pair showing unauthorized access attempt | `APP-AUTHZ-01-IDOR-Test.json` |
| Privilege escalation test | Before/after screenshots of role-restricted function access | `APP-AUTHZ-02-PrivEsc-Test.png` |
| Role matrix | Export from application admin console | `APP-AUTHZ-03-RoleMatrix.csv` |
| API authorization test | API request/response showing cross-user data leak attempt | `APP-AUTHZ-04-API-Test.json` |

### Session Management Evidence

| Evidence Item | How to Capture | Naming Convention |
|--------------|----------------|-------------------|
| Cookie attributes | Browser DevTools → Application → Cookies screenshot | `APP-SESS-01-CookieFlags.png` |
| Session invalidation test | Logout, then replay request with old token — capture response | `APP-SESS-02-LogoutTest.png` |
| Idle timeout test | Timestamped screenshots before/after idle period | `APP-SESS-03-IdleTimeout.png` |

### Input Validation Evidence

| Evidence Item | How to Capture | Naming Convention |
|--------------|----------------|-------------------|
| SQLi test attempt | Request payload + application response (error or safe handling) | `APP-INPUT-01-SQLi-Test.txt` |
| XSS test attempt | Payload submitted + rendered output (encoded vs executed) | `APP-INPUT-02-XSS-Test.png` |
| Security headers | curl -I output showing all response headers | `APP-INPUT-03-Headers.txt` |
| File upload test | Screenshot of rejected malicious file upload attempt | `APP-INPUT-04-FileUpload.png` |

### CBS-Specific Evidence

| Evidence Item | How to Capture | Naming Convention |
|--------------|----------------|-------------------|
| Maker-checker configuration | CBS admin console screenshot showing workflow rules | `APP-CBS-01-MakerChecker.png` |
| Transaction limit matrix | Export from CBS parameter table | `APP-CBS-02-TxnLimits.csv` |
| Audit trail sample | Export of 20 sample transactions with full audit fields | `APP-CBS-03-AuditTrail.csv` |
| Reconciliation report | Daily reconciliation report for sample dates | `APP-CBS-04-Reconciliation.pdf` |

---

## Evidence Handling and Chain of Custody

```
1. CAPTURE   → Take screenshot/export immediately during test
2. TIMESTAMP → Ensure system clock visible or note capture time manually
3. HASH      → For critical evidence, calculate SHA-256 hash for integrity
4. STORE     → Save to dedicated audit evidence folder (read-only after capture)
5. REFERENCE → Link each piece of evidence to its corresponding finding ID
6. RETAIN    → Retain per audit documentation retention policy (≥ 3 years typical)
```

```bash
# Generate hash for evidence integrity
sha256sum APP-AUTH-01-MFA-Screenshot.png > APP-AUTH-01-MFA-Screenshot.png.sha256
```

---

## Sensitive Data Handling During Testing

> ⚠️ **Critical:** When testing IDOR, privilege escalation, or data access controls, auditors may inadvertently access real customer data.

- Use **test/dummy accounts** wherever possible, not production customer data
- If real data is unavoidably exposed during testing, **redact before saving as evidence**
- Never export bulk customer data as "evidence" — a single representative redacted sample suffices
- Document any incidental exposure to real PII in the audit workpaper with a note to Compliance/DPO

---

*Part of [IS Audit Playbook](../../README.md) | See also: [Application Checklist](checklist.md) | [Sample Findings](sample-findings.md)*
