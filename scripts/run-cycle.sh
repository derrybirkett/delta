#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TODAY=$(date +%Y%m%d)

echo "=============================="
echo " Delta Daily Cycle — $TODAY"
echo "=============================="

# Ensure clean main
git checkout main
git pull origin main

# Run product agent — writes BRIEF.md and updates BACKLOG.md
"$SCRIPT_DIR/run-product.sh"

# Verify BRIEF was written
if [[ ! -f ".delta/BRIEF.md" ]]; then
  echo "Error: product agent did not write .delta/BRIEF.md" >&2
  exit 1
fi

# Extract slug for branch name
FEATURE_SLUG=$(grep "^# Feature Brief:" .delta/BRIEF.md \
  | head -1 \
  | sed 's/^# Feature Brief: *//' \
  | tr '[:upper:]' '[:lower:]' \
  | tr -cs '[:alnum:]' '-' \
  | sed 's/^-//;s/-$//')
BRANCH="delta/${FEATURE_SLUG}-${TODAY}"

echo "Creating branch: $BRANCH"
git checkout -b "$BRANCH"

# Stage BRIEF.md and BACKLOG.md changes from product agent
git add .delta/BRIEF.md .delta/BACKLOG.md
git commit -m "chore(delta): product agent brief — $FEATURE_SLUG" || true

# Run developer agent — implements feature, appends to COMPLETED.md
DEVELOPER_EXIT=0
"$SCRIPT_DIR/run-developer.sh" || DEVELOPER_EXIT=$?

if [[ $DEVELOPER_EXIT -ne 0 ]]; then
  echo "Developer agent failed — opening blocked issue"
  git add .delta/BLOCKED.md 2>/dev/null || true
  git stash 2>/dev/null || true
  git checkout main
  git branch -D "$BRANCH" 2>/dev/null || true
  "$SCRIPT_DIR/open-blocked-issue.sh" "$FEATURE_SLUG"
  exit 1
fi

# Push and open PR
echo "Pushing branch and opening PR..."
git push origin "$BRANCH"
"$SCRIPT_DIR/open-pr.sh" "$BRANCH"

echo ""
echo "Delta cycle complete. PR opened for: $FEATURE_SLUG"
