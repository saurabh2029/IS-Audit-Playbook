# Amazon Web Services (AWS) Audit Guide

> **Asset Type:** AWS Cloud Infrastructure  
> **Audit Domain:** Cloud Security, ITGC  
> **Regulatory Mapping:** RBI Cloud Computing Guidelines (2023) | ISO 27001 A.5.23 | CIS AWS Foundations Benchmark  
> **Risk Level:** 🔴 Critical — Misconfigured S3 buckets and IAM are leading causes of cloud breaches

---

## Objective

To assess AWS environment security covering IAM, S3 storage, network security (VPC/Security Groups), logging (CloudTrail/CloudWatch), and compliance with RBI's 2023 Cloud Computing Guidelines.

---

## Pre-Audit Requirements

### Access Needed
- [ ] IAM read-only role: `SecurityAudit` managed policy (AWS-provided, ideal for audit purposes)
- [ ] AWS CLI or Console access
- [ ] Access to AWS Config, CloudTrail, and GuardDuty dashboards

```bash
# Configure AWS CLI with audit profile
aws configure --profile audit
aws sts get-caller-identity --profile audit
```

---

## Audit Checklist

### Section 1 — Identity and Access Management (IAM)

| # | Control | CLI Check | Expected | Risk |
|---|---------|-----------|----------|------|
| 1.1 | Root account MFA enabled | `aws iam get-account-summary` | `AccountMFAEnabled: 1` | 🔴 Critical |
| 1.2 | Root account access keys do not exist | IAM credential report | Zero root access keys | 🔴 Critical |
| 1.3 | MFA enforced for all IAM users | `aws iam generate-credential-report` | 100% MFA enabled | 🔴 Critical |
| 1.4 | No IAM users with AdministratorAccess policy directly attached | `aws iam list-attached-user-policies` | Admin access via roles, not direct user attachment | 🔴 Critical |
| 1.5 | IAM policies follow least privilege (no wildcard `*:*`) | Policy review | No `"Action": "*", "Resource": "*"` | 🔴 Critical |
| 1.6 | Access keys rotated within 90 days | Credential report | All keys < 90 days old | High |
| 1.7 | Unused IAM credentials (90+ days) are disabled | Credential report | No stale credentials | High |
| 1.8 | IAM password policy meets minimum standards | `aws iam get-account-password-policy` | Min 14 chars, complexity, 90-day rotation | High |
| 1.9 | Cross-account roles use external ID | Trust policy review | ExternalId condition present | High |

```bash
# Check root account MFA status
aws iam get-account-summary --query "SummaryMap.AccountMFAEnabled"

# Generate and download IAM credential report (comprehensive audit tool)
aws iam generate-credential-report
aws iam get-credential-report --query "Content" --output text | base64 -d > credential_report.csv

# Check for IAM users with AdministratorAccess directly attached
aws iam list-users --query "Users[].UserName" --output text | while read user; do
    aws iam list-attached-user-policies --user-name "$user" \
        --query "AttachedPolicies[?PolicyName=='AdministratorAccess']" --output text
done

# Check IAM password policy
aws iam get-account-password-policy

# Find access keys older than 90 days
aws iam list-users --query "Users[].UserName" --output text | while read user; do
    aws iam list-access-keys --user-name "$user" \
        --query "AccessKeyMetadata[].{User:'$user',KeyId:AccessKeyId,Created:CreateDate,Status:Status}" --output table
done

# Check for overly permissive IAM policies (wildcard actions/resources)
aws iam list-policies --scope Local --query "Policies[].PolicyName" --output text | while read policy; do
    arn=$(aws iam list-policies --query "Policies[?PolicyName=='$policy'].Arn" --output text)
    version=$(aws iam get-policy --policy-arn "$arn" --query "Policy.DefaultVersionId" --output text)
    aws iam get-policy-version --policy-arn "$arn" --version-id "$version" \
        --query "PolicyVersion.Document.Statement[?Action=='*' && Resource=='*']"
done
```

---

### Section 2 — S3 Storage Security

| # | Control | CLI Check | Expected | Risk |
|---|---------|-----------|----------|------|
| 2.1 | S3 buckets block public access (account-level) | `aws s3control get-public-access-block` | All 4 settings = true | 🔴 Critical |
| 2.2 | No individual bucket allows public read/write | Bucket ACL/policy review | No public-read or public-read-write ACLs | 🔴 Critical |
| 2.3 | S3 buckets encrypted at rest (SSE-S3 or SSE-KMS) | `aws s3api get-bucket-encryption` | Encryption enabled on all buckets | 🔴 Critical |
| 2.4 | S3 bucket versioning enabled for critical buckets | `aws s3api get-bucket-versioning` | Enabled (ransomware/accidental deletion protection) | High |
| 2.5 | S3 access logging enabled | `aws s3api get-bucket-logging` | Logging target configured | High |
| 2.6 | S3 bucket policies reviewed for overly permissive principals | Bucket policy review | No `"Principal": "*"` without conditions | 🔴 Critical |

```bash
# Check account-level public access block
aws s3control get-public-access-block --account-id <account-id>

# List all buckets and check public access status individually
aws s3api list-buckets --query "Buckets[].Name" --output text | while read bucket; do
    echo "=== $bucket ==="
    aws s3api get-bucket-acl --bucket "$bucket" --query "Grants[?Grantee.URI=='http://acs.amazonaws.com/groups/global/AllUsers']"
    aws s3api get-public-access-block --bucket "$bucket" 2>/dev/null
done

# Check encryption status for all buckets
aws s3api list-buckets --query "Buckets[].Name" --output text | while read bucket; do
    echo "=== $bucket ==="
    aws s3api get-bucket-encryption --bucket "$bucket" 2>&1
done

# Check bucket policies for wildcard principals
aws s3api list-buckets --query "Buckets[].Name" --output text | while read bucket; do
    aws s3api get-bucket-policy --bucket "$bucket" --query "Policy" --output text 2>/dev/null |
        python3 -m json.tool 2>/dev/null | grep -A2 '"Principal"'
done
```

---

### Section 3 — Network Security (VPC / Security Groups)

| # | Control | CLI Check | Expected | Risk |
|---|---------|-----------|----------|------|
| 3.1 | No security groups allow unrestricted ingress (0.0.0.0/0) on all ports | `aws ec2 describe-security-groups` | No ANY-ANY rules | 🔴 Critical |
| 3.2 | RDP (3389) / SSH (22) not open to 0.0.0.0/0 | Security group rule review | Restricted to bastion/VPN CIDR | 🔴 Critical |
| 3.3 | Default VPC security group denies all traffic | Default SG review | No rules in default SG | High |
| 3.4 | VPC Flow Logs enabled | `aws ec2 describe-flow-logs` | Enabled for all production VPCs | High |
| 3.5 | NACLs configured for defense-in-depth | NACL review | Layered with security groups | Medium |
| 3.6 | Database instances not publicly accessible | `aws rds describe-db-instances` | `PubliclyAccessible: false` | 🔴 Critical |

```bash
# Find security groups with unrestricted ingress
aws ec2 describe-security-groups --query "SecurityGroups[].{Name:GroupName,ID:GroupId,Rules:IpPermissions[?IpRanges[?CidrIp=='0.0.0.0/0']]}" --output json

# Specifically check for open RDP/SSH
aws ec2 describe-security-groups --filters "Name=ip-permission.from-port,Values=22,3389" \
    --query "SecurityGroups[].{Name:GroupName,Rules:IpPermissions[?IpRanges[?CidrIp=='0.0.0.0/0']]}"

# Check VPC Flow Logs status
aws ec2 describe-flow-logs --query "FlowLogs[].{VpcId:ResourceId,Status:FlowLogStatus}"

# Check RDS public accessibility
aws rds describe-db-instances --query "DBInstances[].{ID:DBInstanceIdentifier,Public:PubliclyAccessible,Encrypted:StorageEncrypted}"
```

---

### Section 4 — Logging & Monitoring

| # | Control | CLI Check | Expected | Risk |
|---|---------|-----------|----------|------|
| 4.1 | CloudTrail enabled in all regions | `aws cloudtrail describe-trails` | `IsMultiRegionTrail: true` | 🔴 Critical |
| 4.2 | CloudTrail log file validation enabled | Trail config | `LogFileValidationEnabled: true` | High |
| 4.3 | CloudTrail logs encrypted (KMS) | Trail config | `KmsKeyId` present | High |
| 4.4 | CloudTrail logs sent to centralized S3 + SIEM | Trail destination | Centralized logging account + SIEM ingestion | 🔴 Critical |
| 4.5 | Log retention ≥ 180 days | S3 lifecycle policy on CloudTrail bucket | ≥ 180 days (CERT-In mandate) | 🔴 Critical |
| 4.6 | GuardDuty enabled for threat detection | `aws guardduty list-detectors` | Active detector configured | 🔴 Critical |
| 4.7 | AWS Config enabled for configuration compliance | `aws configservice describe-configuration-recorders` | Recording all resource types | High |
| 4.8 | CloudWatch alarms for root account usage, IAM changes | Alarm review | Critical alarms configured | High |

```bash
# Check CloudTrail configuration
aws cloudtrail describe-trails --query "trailList[].{Name:Name,MultiRegion:IsMultiRegionTrail,Validation:LogFileValidationEnabled,KMS:KmsKeyId}"

# Check trail status (is logging actually active?)
aws cloudtrail get-trail-status --name <trail-name>

# Check GuardDuty status
aws guardduty list-detectors
aws guardduty get-detector --detector-id <detector-id> --query "Status"

# Check AWS Config status
aws configservice describe-configuration-recorders
aws configservice describe-configuration-recorder-status

# Check S3 lifecycle policy on CloudTrail log bucket (retention check)
aws s3api get-bucket-lifecycle-configuration --bucket <cloudtrail-log-bucket>
```

---

### Section 5 — Data Encryption

| # | Control | CLI Check | Expected | Risk |
|---|---------|-----------|----------|------|
| 5.1 | EBS volumes encrypted by default | `aws ec2 get-ebs-encryption-by-default` | Enabled | High |
| 5.2 | RDS instances encrypted at rest | `aws rds describe-db-instances` | `StorageEncrypted: true` | 🔴 Critical |
| 5.3 | KMS keys have rotation enabled | `aws kms get-key-rotation-status` | Enabled for CMKs | Medium |
| 5.4 | Secrets Manager / Parameter Store used (no hardcoded credentials) | Code/config review | No credentials in code, env files, or AMIs | 🔴 Critical |

```bash
# Check EBS default encryption
aws ec2 get-ebs-encryption-by-default

# Check RDS encryption status
aws rds describe-db-instances --query "DBInstances[].{ID:DBInstanceIdentifier,Encrypted:StorageEncrypted}"

# Check KMS key rotation
aws kms list-keys --query "Keys[].KeyId" --output text | while read key; do
    aws kms get-key-rotation-status --key-id "$key" 2>/dev/null
done
```

---

### Section 6 — RBI Cloud Computing Guidelines (2023) Specific Checks

| # | Control | Check | Expected | Risk |
|---|---------|-------|----------|------|
| 6.1 | Data residency — financial data in Mumbai (ap-south-1) region | Resource region audit | Critical workloads in ap-south-1 | 🔴 Critical |
| 6.2 | Cloud strategy Board-approved | Governance document | Documented approval | 🟠 High |
| 6.3 | Exit strategy and data portability plan exists | Contract/internal doc | Documented multi-cloud or repatriation plan | 🟠 High |
| 6.4 | Right-to-audit clause with AWS exists | Contract review | RBI right-to-audit present in agreement | 🟠 High |
| 6.5 | Shared responsibility model documented | Internal policy | Clear internal vs. AWS responsibility matrix | Medium |
| 6.6 | DR tested for cloud-hosted critical workloads | DR test records | Annual DR test includes cloud systems | 🔴 Critical |

---

## Evidence to Collect

| Evidence | Method | Format |
|----------|--------|--------|
| IAM credential report | AWS CLI export | CSV |
| List of users with AdministratorAccess | AWS CLI export | CSV |
| S3 public access block status (account + bucket level) | AWS CLI export | JSON |
| Security groups with open ingress | AWS CLI export | CSV |
| CloudTrail configuration | AWS CLI export | Screenshot/JSON |
| GuardDuty findings summary | Console export | PDF/CSV |
| RDS/EBS encryption status | AWS CLI export | CSV |
| Resource region report (data residency) | AWS CLI export | CSV |

---

## Common Findings

### Finding AWS-001 — S3 Bucket with Public Read Access Containing Customer Data

> **Condition:** The S3 bucket `prod-customer-documents` was found with a bucket policy granting `s3:GetObject` permission to Principal `"*"` with no IP or condition restrictions, making all objects in the bucket publicly readable via direct URL. The bucket contained 14,000+ customer KYC documents.
> **Criteria:** RBI Cloud Computing Guidelines (2023) and DPDP Act 2023 require appropriate technical safeguards for customer personal data in cloud storage. CIS AWS Foundations Benchmark Recommendation 2.1.5 requires S3 bucket policies to prohibit public access unless explicitly required and justified.
> **Effect:** This configuration exposed 14,000+ customer KYC documents — including identity proofs and financial information — to unauthenticated public access via the internet. This constitutes a severe, reportable data breach under the DPDP Act 2023 and CERT-In Directions, with significant regulatory and reputational consequences.
> **Recommendation:** (1) Immediately apply the S3 Block Public Access settings at both account and bucket level. (2) Remove the public bucket policy statement. (3) Conduct an access log review to determine if unauthorized access occurred during the exposure window and notify the Data Protection Board if confirmed. (4) Implement AWS Config rules to detect and auto-remediate public S3 buckets going forward.
> **Risk:** 🔴 Critical

### Finding AWS-002 — CloudTrail Not Enabled in All Regions

> **Condition:** CloudTrail was found configured and active only in the ap-south-1 (Mumbai) region. Activity in 3 other regions where resources existed (us-east-1, eu-west-1, ap-southeast-1) was not being logged at all.
> **Criteria:** CIS AWS Foundations Benchmark Recommendation 3.1 requires CloudTrail to be enabled in all regions (multi-region trail) to ensure complete visibility of account activity. CERT-In Directions require comprehensive logging of all ICT system activity.
> **Effect:** Any unauthorized activity, resource creation, or security configuration change occurring in the 3 unmonitored regions would go completely undetected and unrecorded, creating a significant blind spot for security monitoring and incident investigation.
> **Recommendation:** Enable a multi-region CloudTrail immediately, ensuring all current and future AWS regions are covered. Verify log delivery to the centralized logging S3 bucket and SIEM ingestion for all regions.
> **Risk:** 🔴 Critical

---

## Regulatory Mapping

| Control Area | RBI Cloud Guidelines 2023 | ISO 27001:2022 | CIS AWS Benchmark |
|---|---|---|---|
| IAM | Access Governance | A.5.15–5.18 | Section 1 |
| Storage Security | Data Protection | A.8.24 | Section 2 |
| Network Security | Security Architecture | A.8.20 | Section 5 |
| Logging | Audit & Monitoring | A.8.15 | Section 3, 4 |
| Data Residency | Data Localization | A.5.23 | — |

---

*Part of [IS Audit Playbook](../../README.md) | See also: [Azure Audit](azure-audit.md)*
