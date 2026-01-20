#!/bin/bash
# Script to safely migrate repository to fix GitHub contribution graph
# This preserves your current code but creates a fresh git history

set -e

echo "=== Repository Migration Script ==="
echo ""
echo "This script will:"
echo "  1. Create a backup of your current repository"
echo "  2. Export your current files"
echo "  3. Initialize a fresh git repository"
echo "  4. Create a single initial commit with all current files"
echo "  5. Prepare instructions for creating a new GitHub repo"
echo ""
echo "⚠️  WARNING: This will create a NEW repository with NO history"
echo "   Your old commits will be lost (but backed up)"
echo ""
read -p "Continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Aborted."
    exit 1
fi

REPO_DIR="$(pwd)"
PARENT_DIR="$(dirname "$REPO_DIR")"
REPO_NAME="$(basename "$REPO_DIR")"
BACKUP_DIR="${PARENT_DIR}/${REPO_NAME}-backup-$(date +%Y%m%d-%H%M%S)"
TEMP_DIR="${PARENT_DIR}/${REPO_NAME}-fresh"

echo ""
echo "Repository: $REPO_DIR"
echo "Backup will be created at: $BACKUP_DIR"
echo ""

# Step 1: Create backup
echo "Step 1: Creating backup..."
cp -r "$REPO_DIR" "$BACKUP_DIR"
echo "✓ Backup created at: $BACKUP_DIR"

# Step 2: Get remote URL for reference
REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "none")
echo ""
echo "Current remote: $REMOTE_URL"
echo ""

# Step 3: Create temporary directory with files (excluding .git)
echo "Step 2: Preparing fresh repository..."
mkdir -p "$TEMP_DIR"

# Copy all files except .git
rsync -av --exclude='.git' --exclude='.gitignore' "$REPO_DIR/" "$TEMP_DIR/" 2>/dev/null || \
    find "$REPO_DIR" -mindepth 1 -maxdepth 1 ! -name '.git' ! -name '.gitignore' -exec cp -r {} "$TEMP_DIR/" \;

# Step 4: Initialize fresh git repo
cd "$TEMP_DIR"
git init
git add .
git commit -m "Initial commit: migrated from old repository

This repository was recreated to fix GitHub contribution graph issues.
All previous history has been removed."

echo ""
echo "✓ Fresh repository created at: $TEMP_DIR"
echo ""

# Step 5: Show instructions
echo "=== Next Steps ==="
echo ""
echo "1. Review the fresh repository:"
echo "   cd $TEMP_DIR"
echo "   git log"
echo ""
echo "2. Delete the old GitHub repository:"
echo "   - Go to: https://github.com/$(echo $REMOTE_URL | sed -E 's/.*github\.com[:/]([^/]+\/[^/]+)(\.git)?$/\1/')"
echo "   - Settings → Danger Zone → Delete this repository"
echo "   - Wait a few minutes for GitHub to process"
echo ""
echo "3. Create a NEW repository on GitHub with the SAME name (or different)"
echo ""
echo "4. Push the fresh repository:"
echo "   cd $TEMP_DIR"
echo "   git remote add origin <NEW_REPO_URL>"
echo "   git push -u origin main"
echo ""
echo "5. Once confirmed the contribution graph is fixed, you can:"
echo "   - Delete the backup: rm -rf $BACKUP_DIR"
echo "   - Replace the old repo with the new one"
echo ""
echo "=== Summary ==="
echo "Backup:     $BACKUP_DIR"
echo "Fresh repo: $TEMP_DIR"
echo ""
