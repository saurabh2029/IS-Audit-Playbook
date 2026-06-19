# Contributing to IS Audit Playbook

Thank you for your interest in contributing! This playbook is built by practitioners, for practitioners.

## How to Contribute

### 1. Fork and Clone
```bash
git clone https://github.com/YOUR-USERNAME/IS-Audit-Playbook.git
cd IS-Audit-Playbook
```

### 2. Create a Branch
```bash
git checkout -b feature/add-oracle-audit-checklist
```

### 3. Make Your Changes
Follow the content standards below.

### 4. Submit a Pull Request
Include a clear description of what you added and why it's valuable.

---

## Content Standards

### For Audit Checklists
- Include Control #, Control Description, Test Method, Expected Result, and Risk Rating
- Reference specific policies/standards (not generic "best practices")
- Include PowerShell / SQL / CLI commands where relevant

### For Finding Examples
- Use the PCCER format (see [Finding Writing Guide](05-Audit-Reporting/finding-writing-guide.md))
- Anonymize all organizational details
- Include realistic but generalized risk ratings

### For Scripts
- Comment all scripts thoroughly
- Include a header with Purpose, Usage, Required Permissions
- Test before submitting

---

## What We Need Most
- Checklist additions: SAP, VMware ESXi, Kubernetes, AWS GovCloud
- BFSI-specific findings (anonymized)
- Additional regulatory mappings (SEBI, IRDAI, NaBFID)
- Interview Q&A additions

---

## Code of Conduct
Be respectful. This is a learning resource for the audit community. No proprietary or confidential content from current employers.
