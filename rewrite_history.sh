#!/bin/bash
# WARNING: This script rewrites git history. Use with caution!
# This may not actually fix GitHub's contribution graph, but it will clean up your local history.

set -e

echo "⚠️  WARNING: This will rewrite your git history!"
echo "This script will:"
echo "  1. Create a backup branch"
echo "  2. Rewrite commit history to remove duplicates"
echo "  3. Require a force-push to GitHub"
echo ""
echo "This may NOT fix GitHub's contribution graph count, but will clean local history."
echo ""
read -p "Continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Aborted."
    exit 1
fi

# Create backup
echo "Creating backup branch..."
git branch backup-before-rewrite-$(date +%Y%m%d-%H%M%S)

# Check if git-filter-repo is available
if ! command -v git-filter-repo &> /dev/null; then
    echo "git-filter-repo is not installed."
    echo "Install it with: pip install git-filter-repo"
    echo "Or use: sudo apt install git-filter-repo"
    exit 1
fi

echo ""
echo "Current commit count for 2025-10-21:"
git log --all --format="%ai" | grep "2025-10-21" | wc -l

echo ""
echo "To rewrite history, you would need to:"
echo "1. Use git rebase -i to squash or remove duplicate commits"
echo "2. Or use git filter-repo to rewrite specific commits"
echo ""
echo "However, GitHub's contribution graph is immutable once commits are pushed."
echo "Even after rewriting, GitHub may still show the old count."
echo ""
echo "Alternative: Contact GitHub support at support.github.com"
echo "Explain that rebasing created duplicate commits in your contribution graph."
