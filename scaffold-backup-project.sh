#!/usr/bin/env bash
# scaffold-backup-project.sh
# Adds the VM backup & restore project INSIDE the existing az-104 repo.
# Run this from inside your az-104 folder.
#
# Usage: bash scaffold-backup-project.sh [project-name]
#   project-name defaults to: vm-backup-restore

set -euo pipefail

PROJECT="${1:-vm-backup-restore}"

# --- Sanity check: must be inside the az-104 repo ---------------------------
if [[ ! -d .git ]]; then
  echo "❌ No .git found here. Run this from inside your az-104 repo root."
  exit 1
fi

if [[ "$(basename "$PWD")" != "az-104" ]]; then
  echo "⚠️  Current folder is '$(basename "$PWD")', expected 'az-104'."
  read -rp "Continue anyway? [y/N] " ans
  [[ "$ans" =~ ^[Yy]$ ]] || exit 1
fi

if [[ -e "$PROJECT" ]]; then
  echo "❌ '$PROJECT/' already exists. Aborting."
  exit 1
fi

echo "📁 Adding project '$PROJECT' inside $(pwd)"

# --- Project folder structure ------------------------------------------------
mkdir -p "$PROJECT"/{scripts,docs,screenshots,verification}

touch "$PROJECT/README.md"
touch "$PROJECT/scripts/01-create-resources.sh"
touch "$PROJECT/scripts/02-create-vms.sh"
touch "$PROJECT/scripts/03-enable-backup.sh"
touch "$PROJECT/scripts/04-backup-now.sh"
touch "$PROJECT/scripts/05-restore-disks.sh"
touch "$PROJECT/scripts/99-cleanup.sh"
touch "$PROJECT/docs/architecture.md"
touch "$PROJECT/docs/backup-policy.md"
touch "$PROJECT/docs/restore-procedure.md"
touch "$PROJECT/docs/troubleshooting.md"
touch "$PROJECT/verification/checklist.md"
touch "$PROJECT/screenshots/.gitkeep"

chmod +x "$PROJECT/scripts/"*.sh

# --- Ensure root README exists (create if missing, don't overwrite) ---------
if [[ ! -f README.md ]]; then
  cat > README.md <<'EOF'
# AZ-104 Portfolio

Hands-on Azure Administration (AZ-104) labs, built and documented end-to-end
with the Azure CLI.

## Projects

| Project | Skills | Status |
|---------|--------|--------|
| [vm-backup-restore](vm-backup-restore/) | Azure Backup, Recovery Services Vault, restore-disks | 🚧 |
EOF
  echo "📝 Created root README.md with project table."
else
  echo "ℹ️  Root README.md already exists — leaving it untouched."
  echo "   Add this row to your projects table manually:"
  echo "   | [$PROJECT]($PROJECT/) | Azure Backup, Recovery Services Vault, restore-disks | 🚧 |"
fi

# --- Ensure project path is ignored appropriately ---------------------------
if ! grep -q "screenshots/\*.tmp" .gitignore 2>/dev/null; then
  cat >> .gitignore <<'EOF'

# Project temp screenshots
projects/*/screenshots/*.tmp
screenshots/*.tmp
EOF
  echo "📝 Appended screenshot rule to .gitignore."
fi

# --- Summary -----------------------------------------------------------------
echo ""
echo "✅ Project added at: $(pwd)/$PROJECT"
echo ""
echo "Tree (project only):"
if command -v tree >/dev/null 2>&1; then
  tree -a -L 3 "$PROJECT"
else
  find "$PROJECT" | sort | sed 's|^|  |'
fi

echo ""
echo "Next steps:"
echo "  1. Fill in $PROJECT/scripts/01-create-resources.sh"
echo "  2. Add the README table row shown above"
echo "  3. git add . && git commit -m 'feat: add vm-backup-restore project scaffold'"
echo "  4. git push"