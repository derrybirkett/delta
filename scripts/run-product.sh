#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DELTA_DIR="$(dirname "$SCRIPT_DIR")"
REPO_ROOT="$(pwd)"

if [[ ! -d "$REPO_ROOT/.delta" ]]; then
  echo "Error: .delta/ not found. Run install.sh first." >&2
  exit 1
fi

echo "=== Delta: Product Agent starting ==="
echo "Date: $(date +%Y-%m-%d)"
echo "Vision: $(grep 'vision:' "$REPO_ROOT/.delta/config.yml" | head -1 | sed 's/.*vision: //')"

echo "Run your daily product cycle. Today is $(date +%Y-%m-%d). The repo root is $REPO_ROOT." | \
  claude --print \
    --system-prompt-file "$DELTA_DIR/agents/product.md" \
    --allowedTools "Read,Write,Edit,Glob,Grep,Bash" \
    --dangerously-skip-permissions

echo "=== Delta: Product Agent complete ==="
