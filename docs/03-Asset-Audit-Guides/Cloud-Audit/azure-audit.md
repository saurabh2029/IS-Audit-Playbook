# Microsoft Azure Audit Guide

> **Asset Type:** Microsoft Azure Cloud Infrastructure  
> **Audit Domain:** Cloud Security, ITGC  
> **Regulatory Mapping:** RBI Cloud Computing Guidelines (2023) | ISO 27001 A.5.23 | NIST CSF | CIS Microsoft Azure Foundations Benchmark  
> **Risk Level:** 🔴 Critical — Misconfigured cloud resources are a leading cause of data breaches

---

## Objective

To assess Azure environment security covering Identity and Access Management (Azure AD/Entra ID), resource configuration, network security, storage security, logging/monitoring, and compliance with RBI's 2023 Cloud Computing Guidelines for regulated entities.

---

## Pre-Audit Requirements

### Access Needed
- [ ] Azure AD/Entra ID role: **Security Reader** or **Global Reader** (read-only, sufficient for most audit checks)
- [ ] Access to Azure Portal, Azure CLI, or PowerShell (Az module)
- [ ] Access to Microsoft Defender for Cloud / Azure Security Center
- [ ] Access to Azure Policy compliance dashboard

### Tools
```bash
# Install Azure CLI (if not present)
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Login
az login

# Set subscription context
az account set --subscription "<subscription-id>"
```

---

## Audit Checklist

### Section 1 — Identity and Access Management (Entra ID)

| # | Control | CLI / Portal Check | Expected | Risk |
|---|---------|--------------------|----------|------|
| 1.1 | MFA enforced for all users | Conditional Access policy review | MFA required for all sign-ins | 🔴 Critical |
| 1.2 | MFA enforced for Global Administrators | Conditional Access / Security Defaults | Mandatory MFA for all admin roles | 🔴 Critical |
| 1.3 | Number of Global Administrators is minimal | `az ad role assignment list --role "Global Administrator"` | 2–4 break-glass accounts only | 🔴 Critical |
| 1.4 | Privileged Identity Management (PIM) used for admin roles | PIM dashboard review | Just-in-time activation for admin roles | 🔴 Critical |
| 1.5 | Legacy authentication protocols blocked | Conditional Access policy | Legacy auth (POP, IMAP, basic auth) blocked | 🔴 Critical |
| 1.6 | Guest user access reviewed and restricted | `az ad user list --filter "userType eq 'Guest'"` | Guest access limited and reviewed | High |
| 1.7 | Conditional Access policies restrict sign-in by location/device | CA policy review | Risky sign-ins blocked or require MFA | High |
| 1.8 | Service Principal credentials (secrets) have expiration | App registration review | No non-expiring secrets | High |

```bash
# List all users with Global Administrator role
az ad role assignment list --role "Global Administrator" --query "[].principalName" -o table

# Check Conditional Access policies
az rest --method GET --uri "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies"

# List guest users
az ad user list --filter "userType eq 'Guest'" --query "[].{Name:displayName, Email:mail, Created:createdDateTime}" -o table

# Check for service principals with non-expiring or long-lived secrets
az ad app list --query "[].{Name:displayName, AppId:appId}" -o table
# For each app, check credential expiration:
az ad app credential list --id <app-id> --query "[].{Type:type, EndDateTime:endDateTime}"

# Check Security Defaults status (baseline MFA enforcement)
az rest --method GET --uri "https://graph.microsoft.com/v1.0/policies/identitySecurityDefaultsEnforcementPolicy"
```

---

### Section 2 — Resource & Subscription Management

| # | Control | CLI Check | Expected | Risk |
|---|---------|-----------|----------|------|
| 2.1 | Azure Policy is enforced for compliance baselines | `az policy assignment list` | CIS/RBI-aligned policies assigned | High |
| 2.2 | Resource locks applied to critical resources | `az lock list` | CanNotDelete locks on production resources | Medium |
| 2.3 | RBAC follows least privilege (minimal Owner role assignments) | `az role assignment list --role Owner` | Owner role limited to break-glass accounts | 🔴 Critical |
| 2.4 | Resource tagging enforced for cost/ownership tracking | Tag policy review | Mandatory tags (Owner, Environment, DataClass) | Medium |
| 2.5 | Subscription-level activity logs retained ≥ 180 days | Diagnostic settings | ≥ 180 days (CERT-In mandate) | 🔴 Critical |

```bash
# List all Owner role assignments at subscription level
az role assignment list --role "Owner" --query "[].{Principal:principalName, Scope:scope}" -o table

# Check resource locks
az lock list -o table

# Check Azure Policy compliance state
az policy state list --query "[?complianceState=='NonCompliant']" -o table

# Check diagnostic settings / activity log retention
az monitor diagnostic-settings subscription list
```

---

### Section 3 — Network Security

| # | Control | CLI Check | Expected | Risk |
|---|---------|-----------|----------|------|
| 3.1 | NSGs do not have overly permissive inbound rules (ANY/ANY) | `az network nsg rule list` | No source ANY to sensitive ports | 🔴 Critical |
| 3.2 | RDP (3389) / SSH (22) not exposed to internet (0.0.0.0/0) | NSG rule review | Restricted to VPN/Bastion subnet | 🔴 Critical |
| 3.3 | Azure Bastion or Just-In-Time VM access used for management | Bastion deployment check | JIT/Bastion deployed for admin access | High |
| 3.4 | Network Watcher / Flow Logs enabled | `az network watcher flow-log list` | Flow logs active for all NSGs | High |
| 3.5 | Private endpoints used for PaaS services (Storage, SQL) | Private endpoint review | Critical PaaS services not publicly accessible | 🔴 Critical |
| 3.6 | DDoS Protection Standard enabled for critical VNets | DDoS protection plan check | Enabled for production VNets | Medium |

```bash
# List all NSG rules across all NSGs — flag overly permissive entries
az network nsg list --query "[].name" -o tsv | while read nsg; do
    az network nsg rule list --nsg-name "$nsg" --resource-group "<rg>" \
        --query "[?access=='Allow' && (sourceAddressPrefix=='*' || sourceAddressPrefix=='0.0.0.0/0')].{NSG:'$nsg', Rule:name, Port:destinationPortRange, Source:sourceAddressPrefix}" -o table
done

# Check for RDP/SSH exposed to internet
az network nsg rule list --nsg-name "<nsg-name>" --resource-group "<rg>" \
    --query "[?destinationPortRange=='3389' || destinationPortRange=='22']"

# Check flow log status
az network watcher flow-log list --location "<region>" -o table

# Check storage accounts for public network access
az storage account list --query "[].{Name:name, PublicAccess:publicNetworkAccess, AllowBlobPublicAccess:allowBlobPublicAccess}" -o table
```

---

### Section 4 — Storage Security

| # | Control | CLI Check | Expected | Risk |
|---|---------|-----------|----------|------|
| 4.1 | Storage accounts disallow public blob access | `az storage account list` | `allowBlobPublicAccess: false` | 🔴 Critical |
| 4.2 | Storage accounts enforce HTTPS only | Storage account config | `enableHttpsTrafficOnly: true` | High |
| 4.3 | Storage accounts use minimum TLS 1.2 | Storage account config | `minimumTlsVersion: TLS1_2` | High |
| 4.4 | Storage account keys rotated regularly / SAS tokens have expiry | Access key/SAS review | Keys rotated; SAS tokens time-limited | High |
| 4.5 | Soft delete and versioning enabled for critical storage | Blob service properties | Soft delete ≥ 7 days; versioning enabled | Medium |
| 4.6 | Storage encrypted with customer-managed keys (for sensitive data) | Encryption settings | CMK used for regulated data | High |

```bash
# Check all storage accounts for public access and TLS settings
az storage account list --query "[].{Name:name, PublicBlobAccess:allowBlobPublicAccess, HttpsOnly:enableHttpsTrafficOnly, MinTLS:minimumTlsVersion}" -o table

# Check soft delete configuration
az storage blob service-properties show --account-name "<account>" --query "deleteRetentionPolicy"
```

---

### Section 5 — Logging & Monitoring

| # | Control | CLI Check | Expected | Risk |
|---|---------|-----------|----------|------|
| 5.1 | Azure Activity Log retention ≥ 180 days | Diagnostic settings | ≥ 180 days, exported to Log Analytics/Storage | 🔴 Critical |
| 5.2 | Microsoft Defender for Cloud enabled (Standard tier) | Defender for Cloud plan | Standard tier for critical resource types | 🔴 Critical |
| 5.3 | Azure Sentinel (or equivalent SIEM) ingesting Azure logs | Sentinel data connectors | Active ingestion of Activity, Sign-in, Audit logs | 🔴 Critical |
| 5.4 | Alerts configured for high-risk activities | Alert rules review | Alerts for role assignment changes, NSG changes, resource deletion | High |
| 5.5 | Log data residency in India region (CERT-In compliance) | Resource region check | Logs stored in Central India / South India region | 🔴 Critical |

```bash
# Check Activity Log diagnostic settings
az monitor diagnostic-settings subscription list --query "[].{Name:name, Retention:logs[0].retentionPolicy}"

# Check Microsoft Defender for Cloud pricing tier (Standard vs Free)
az security pricing list --query "[].{Name:name, Tier:pricingTier}" -o table

# List configured alert rules
az monitor activity-log alert list --query "[].{Name:name, Enabled:enabled}" -o table
```

---

### Section 6 — RBI Cloud Computing Guidelines (2023) Specific Checks

| # | Control | Check | Expected | Risk |
|---|---------|-------|----------|------|
| 6.1 | Cloud adoption approved by Board/Risk Committee | Governance document review | Board-approved cloud strategy exists | 🟠 High |
| 6.2 | Data residency — critical data stored in Indian regions | Resource region audit | Customer/financial data in India Central/South | 🔴 Critical |
| 6.3 | Exit strategy / data portability plan exists | Vendor contract review | Documented exit plan with Microsoft | 🟠 High |
| 6.4 | Shared responsibility model is documented and understood | Internal documentation | Roles/responsibilities matrix exists | Medium |
| 6.5 | Right-to-audit clause exists in CSP contract | Contract review | RBI right-to-audit clause present | 🟠 High |
| 6.6 | Business continuity tested for cloud-hosted critical systems | DR test records | Cloud DR included in BCP testing | 🔴 Critical |
| 6.7 | Incident notification SLA with Microsoft is defined | Contract / SLA review | Defined notification timeline from CSP | High |

---

## Evidence to Collect

| Evidence | Method | Format |
|----------|--------|--------|
| List of Global Administrators | Azure CLI export | CSV |
| Conditional Access policy export | Portal screenshot / Graph API | JSON/Screenshot |
| Owner role assignments | Azure CLI export | CSV |
| NSG rules with permissive access | Azure CLI export | CSV |
| Storage account security configuration | Azure CLI export | CSV |
| Defender for Cloud pricing tier | Azure CLI export | Screenshot |
| Activity log retention configuration | Azure CLI export | Screenshot |
| Resource region/data residency report | Azure CLI export | CSV |

---

## Common Findings

### Finding AZ-001 — Excessive Global Administrator Assignments

> **Condition:** 17 user accounts were found assigned the Global Administrator role in Entra ID, including several accounts belonging to application developers and a service account used for automated deployment scripts.
> **Criteria:** CIS Microsoft Azure Foundations Benchmark Recommendation 1.1.1 requires limiting Global Administrator role assignments to fewer than 5 accounts. RBI Cloud Computing Guidelines (2023) require strict access governance for cloud administrative roles.
> **Effect:** Excessive Global Administrator assignments dramatically increase the attack surface for tenant-wide compromise. Any one of the 17 compromised accounts would grant an attacker complete control over the organization's Azure tenant, including all subscriptions, resources, and identity infrastructure.
> **Recommendation:** Reduce Global Administrator assignments to a maximum of 4–5 break-glass accounts with strong MFA and monitoring. Implement Privileged Identity Management (PIM) for just-in-time elevation. Move the automated deployment service account to a scoped custom role with only the specific permissions required.
> **Risk:** 🔴 Critical

### Finding AZ-002 — Storage Account Permits Public Blob Access

> **Condition:** 3 production storage accounts containing customer document uploads were found configured with `allowBlobPublicAccess: true`, and one container within these accounts had container-level public read access enabled.
> **Criteria:** RBI Cloud Computing Guidelines (2023) and DPDP Act 2023 require appropriate technical safeguards for personal data stored in cloud environments. CIS Azure Benchmark Recommendation 3.1 requires "Secure transfer required" and disabling public blob access by default.
> **Effect:** Publicly accessible blob storage containing customer documents represents a direct, unauthenticated data exposure. Any individual with the storage URL could access customer documents without any authentication, constituting a reportable data breach under the DPDP Act 2023.
> **Recommendation:** Immediately disable public access on all 3 storage accounts and the identified container. Audit access logs to determine if unauthorized access occurred during the exposure window. Implement Azure Policy to prevent public blob access at the subscription level going forward.
> **Risk:** 🔴 Critical

---

## Regulatory Mapping

| Control Area | RBI Cloud Guidelines 2023 | ISO 27001:2022 | CIS Azure Benchmark |
|---|---|---|---|
| Identity & Access | Access Governance | A.5.15–5.18 | Section 1 |
| Data Residency | Data Localization | A.5.23 | — |
| Network Security | Security Architecture | A.8.20 | Section 6 |
| Logging | Audit & Monitoring | A.8.15 | Section 5 |
| Exit Strategy | Vendor Lock-in Mitigation | A.5.20 | — |

---

*Part of [IS Audit Playbook](../../README.md) | See also: [AWS Audit](aws-audit.md)*
