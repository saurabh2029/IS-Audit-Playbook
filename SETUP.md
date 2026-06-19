# Setup Guide — IS Audit Playbook

## 🚀 Step 1: Create GitHub Repository

1. Go to [github.com/new](https://github.com/new)
2. Repository name: `IS-Audit-Playbook`
3. Description: `Open-source IS Audit reference — checklists, methodology & reporting for BFSI`
4. Visibility: **Public** (for portfolio visibility)
5. ✅ Add README: No (we have our own)
6. ✅ License: MIT

---

## 🖥️ Step 2: Push This Content

```bash
# Initialize git in the IS-Audit-Playbook folder
git init
git add .
git commit -m "Initial commit: IS Audit Playbook structure and core content"

# Connect to GitHub
git remote add origin https://github.com/YOUR-USERNAME/IS-Audit-Playbook.git
git branch -M main
git push -u origin main
```

---

## 🌐 Step 3: Enable GitHub Pages (MkDocs)

### Option A — GitHub Actions (Recommended)
The `.github/workflows/deploy.yml` file handles this automatically.

1. Go to repo **Settings** → **Pages**
2. Source: **GitHub Actions**
3. Push any change to `main` — the site auto-deploys to:  
   `https://YOUR-USERNAME.github.io/IS-Audit-Playbook`

### Option B — Local Preview First
```bash
pip install mkdocs-material
mkdocs serve          # Preview at http://127.0.0.1:8000
mkdocs build          # Build static site to /site
```

---

## 📁 Step 4: Required docs/ Folder for MkDocs

MkDocs expects content in a `docs/` folder. Create a symlink or copy:

```bash
# Option: rename your content folder to docs
mv 01-Audit-Methodology docs/01-Audit-Methodology
# ... or use mkdocs.yml to point to root (see mkdocs.yml docs_dir setting)
```

Or add to `mkdocs.yml`:
```yaml
docs_dir: .          # Use repo root as docs directory
```

---

## 🏷️ Step 5: Add GitHub Topics

In your repo, click the gear icon next to "About" and add topics:
```
is-audit  it-audit  cybersecurity  active-directory  bfsi
rbi-compliance  iso27001  cism  audit-checklist  infosec
```

---

## 📌 Step 6: Pin to Your Profile

1. Go to your GitHub profile
2. Click "Customize your pins"
3. Select `IS-Audit-Playbook`

Your portfolio is live! 🎉
