# Application Audit — Sample Findings

> **Companion to:** [Application Audit Checklist](checklist.md) | [Evidence Collection](evidence-collection.md)  
> **Format:** All findings follow PCCER structure

---

### Finding APP-001 — No MFA on Internet Banking Login

> **Condition:** Testing of the retail internet banking login flow confirmed that authentication is completed using only a username and password. No OTP, TOTP, or push-notification second factor is requested at any point in the login sequence, including for high-value fund transfer transactions.
> **Criteria:** RBI Cybersecurity Framework §6.3 and RBI Internet Banking Guidelines require two-factor authentication for all internet banking sessions and additional authentication for fund transfer transactions. CERT-In advisories on banking application security recommend MFA as a baseline control.
> **Effect:** Absence of MFA significantly increases the risk of account takeover through credential stuffing, phishing, or password reuse attacks. A compromised password alone is sufficient for an attacker to gain full access to a customer's account and initiate fraudulent transactions.
> **Recommendation:** Implement mandatory OTP-based or app-based second-factor authentication for all internet banking logins. Require step-up authentication (separate OTP) for fund transfers above a defined threshold. Conduct a phased rollout with customer communication to manage adoption.
> **Risk:** 🔴 Critical

---

### Finding APP-002 — Insecure Direct Object Reference (IDOR) on Account Statement API

> **Condition:** During testing of the account statement download API endpoint (`/api/v2/statements/{accountId}`), it was observed that modifying the `accountId` parameter to a sequential or known value belonging to a different customer returned that customer's full account statement, including transaction history and balance, without any authorization check.
> **Criteria:** OWASP Top 10 (A01:2021 — Broken Access Control) and the organization's Secure Development Policy Section 6.2 require that all API endpoints validate that the authenticated user is authorized to access the requested resource, not merely that the user is authenticated.
> **Effect:** This represents a direct, exploitable data breach vulnerability allowing any authenticated user to access any other customer's complete financial data by simply changing a parameter value. This is reportable under the DPDP Act 2023 and constitutes a severe breach of customer confidentiality.
> **Recommendation:** Implement server-side authorization checks on every API endpoint verifying that the requested `accountId` belongs to the authenticated session's customer. Conduct an immediate API security review across all endpoints for similar IDOR patterns. Engage a third party for an expedited penetration test of the API layer.
> **Risk:** 🔴 Critical

---

### Finding APP-003 — Verbose Error Messages Disclose Stack Trace

> **Condition:** Submitting an invalid input to the loan application form (`/loans/apply`) triggered an unhandled exception that returned a full stack trace to the browser, including the internal server file path, the application framework version (Spring Boot 2.3.1), and a partial database connection string.
> **Criteria:** OWASP ASVS V7 (Error Handling and Logging) requires that applications return generic error messages to end users while logging detailed errors server-side only. CIS Benchmark for web application configuration mandates that debug mode be disabled in production.
> **Effect:** Disclosure of framework version and internal architecture details provides reconnaissance information that significantly aids an attacker in identifying known vulnerabilities (e.g., for the specific Spring Boot version) and crafting targeted exploits. Partial database connection details increase risk of further compromise.
> **Recommendation:** Disable debug mode and verbose error output in the production environment immediately. Implement a global exception handler that returns a generic error message and reference ID to the user, while logging full details server-side for troubleshooting. Verify the framework version against known CVEs and patch if applicable.
> **Risk:** 🟠 High

---

### Finding APP-004 — No Maker-Checker on High-Value CBS Parameter Changes

> **Condition:** Review of the Core Banking System parameter change history revealed that interest rate and transaction limit parameters can be modified by a single Branch Manager-level user without requiring a second-level approval. Testing confirmed that one sampled user successfully modified the daily NEFT transaction limit without any secondary authorization step.
> **Criteria:** RBI guidelines on Core Banking Systems and the organization's Segregation of Duties Policy require maker-checker (4-eyes) controls for all critical parameter changes affecting transaction limits, interest rates, and fee structures.
> **Effect:** A single compromised or malicious user-level account could unilaterally modify critical financial parameters, potentially enabling fraud (e.g., raising transaction limits to facilitate large unauthorized transfers) or causing financial loss through incorrect parameter configuration with no independent verification.
> **Recommendation:** Implement mandatory maker-checker workflow for all parameter changes classified as financially material (transaction limits, interest rates, fee schedules). Retroactively review all parameter changes in the audit period for unauthorized or unusual modifications.
> **Risk:** 🔴 Critical

---

### Finding APP-005 — Session Does Not Expire on Browser Close (No SameSite/Secure Flags)

> **Condition:** Inspection of the session cookie issued by the corporate banking portal showed that the cookie lacked the `Secure` and `HttpOnly` flags and had no `SameSite` attribute configured. The session also remained valid for 24 hours regardless of activity, with no idle timeout enforced.
> **Criteria:** OWASP ASVS V3 (Session Management) requires session cookies to be flagged `Secure`, `HttpOnly`, and `SameSite=Strict` or `Lax`. The organization's Application Security Policy Section 5.4 requires a maximum idle session timeout of 15 minutes for financial applications.
> **Effect:** Absence of the `Secure` flag risks the session token being transmitted over unencrypted channels if any portion of the application inadvertently uses HTTP. Absence of `HttpOnly` exposes the cookie to theft via Cross-Site Scripting (XSS), and missing `SameSite` increases CSRF risk. The 24-hour session validity without idle timeout extends the window during which a stolen or abandoned session remains exploitable.
> **Recommendation:** Configure session cookies with `Secure`, `HttpOnly`, and `SameSite=Strict` flags. Implement a 15-minute idle timeout with a warning prompt before automatic logout. Re-test session behavior after remediation to confirm compliance.
> **Risk:** 🟠 High

---

## Finding Summary Table

| ID | Title | Risk Rating | Category |
|----|-------|-------------|----------|
| APP-001 | No MFA on Internet Banking Login | 🔴 Critical | Authentication |
| APP-002 | IDOR on Account Statement API | 🔴 Critical | Authorization |
| APP-003 | Verbose Error Messages | 🟠 High | Error Handling |
| APP-004 | No Maker-Checker on CBS Parameters | 🔴 Critical | CBS Controls |
| APP-005 | Insecure Session Cookie Configuration | 🟠 High | Session Management |

---

*Part of [IS Audit Playbook](../../README.md) | See also: [Application Checklist](checklist.md)*
