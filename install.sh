#!/usr/bin/env bash
set -euo pipefail

DELTA_ORIGIN="${1:-}"
TARGET_DIR="$(pwd)"
DELTA_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing Delta into $TARGET_DIR..."

# Detect delta origin URL if not passed
if [[ -z "$DELTA_ORIGIN" ]]; then
  DELTA_ORIGIN="$(git -C "$DELTA_DIR" remote get-url origin 2>/dev/null || echo "")"
  if [[ -z "$DELTA_ORIGIN" ]]; then
    echo "Error: could not detect Delta's git remote URL."
    echo "Usage: bash install.sh <delta-repo-url>"
    exit 1
  fi
fi

# Add delta as git submodule (idempotent)
if [[ ! -f "$TARGET_DIR/.gitmodules" ]] || ! grep -q '\[submodule "delta"\]' "$TARGET_DIR/.gitmodules" 2>/dev/null; then
  git submodule add "$DELTA_ORIGIN" delta
else
  echo "  Submodule 'delta' already exists — skipping."
fi

# Create .delta/ state directory
mkdir -p .delta

# Scaffold config.yml
if [[ ! -f ".delta/config.yml" ]]; then
  cat > .delta/config.yml <<'EOF'
product:
  name: My App
  vision: "Describe your product vision here — what is this app for?"
  target_user: "Describe your primary user"
  principles:
    - simplicity first
    - mobile responsive
    - performance matters
  avoid: []

stack:
  framework: nextjs
  styling: tailwind
  testing: vitest
  allowed_deps: []
EOF
  echo "  Created .delta/config.yml"
  echo "  !! IMPORTANT: Edit .delta/config.yml with your product vision before the first cycle."
fi

# Scaffold BACKLOG.md
if [[ ! -f ".delta/BACKLOG.md" ]]; then
  cat > .delta/BACKLOG.md <<'EOF'
# Product Backlog

<!-- The product agent owns this file. You may edit it directly to override priorities. -->

## Ready
<!-- Product agent will populate this from the vision in config.yml -->

## Ideas
<!-- Unranked ideas — agent will promote to Ready when appropriate -->

## Completed
<!-- Agent appends here when features ship -->
EOF
  echo "  Created .delta/BACKLOG.md"
fi

# Scaffold COMPLETED.md
if [[ ! -f ".delta/COMPLETED.md" ]]; then
  cat > .delta/COMPLETED.md <<'EOF'
# Completed Features

<!-- Developer agent appends entries here after each successful cycle -->
EOF
  echo "  Created .delta/COMPLETED.md"
fi

# Install GH Actions workflow
mkdir -p .github/workflows
cp "$DELTA_DIR/workflows/delta.yml" .github/workflows/delta.yml
echo "  Installed .github/workflows/delta.yml"

# Install Makefile (only if none exists)
if [[ ! -f "Makefile" ]]; then
  cp "$DELTA_DIR/Makefile.template" Makefile
  echo "  Installed Makefile"
else
  echo "  Makefile already exists — skipping (add targets manually from delta/Makefile.template)"
fi

echo ""
echo "Delta installed successfully!"
echo ""
echo "Next steps:"
echo "  1. Edit .delta/config.yml — describe your product vision"
echo "  2. Add ANTHROPIC_API_KEY to your GitHub repo secrets"
echo "  3. Run 'make run-cycle' to test locally (requires ANTHROPIC_API_KEY + GH_TOKEN env vars)"
echo "  4. git add .delta/ .github/ Makefile .gitmodules && git commit -m 'chore: install delta'"
echo "  5. Push — the daily cycle will fire at 2am UTC"
