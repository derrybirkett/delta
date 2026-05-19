#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DELTA_DIR="$(dirname "$SCRIPT_DIR")"
REPO_ROOT="$(pwd)"

if [[ ! -f "$REPO_ROOT/.delta/BRIEF.md" ]]; then
  echo "Error: .delta/BRIEF.md not found. Run product agent first." >&2
  exit 1
fi

echo "=== Delta: Developer Agent starting ==="
echo "Date: $(date +%Y-%m-%d)"
echo "Brief: $(grep '^# Feature Brief:' "$REPO_ROOT/.delta/BRIEF.md" | sed 's/# Feature Brief: //')"

claude --print \
  --system-prompt "$(cat "$DELTA_DIR/agents/developer.md")" \
  --allowedTools "Read,Write,Edit,Glob,Grep,Bash" \
  "Implement the feature in .delta/BRIEF.md. Today is $(date +%Y-%m-%d). The repo root is $REPO_ROOT. Your branch has already been created."

# Check for BLOCKED.md — means agent gave up
if [[ -f "$REPO_ROOT/.delta/BLOCKED.md" ]]; then
  echo "Developer agent wrote BLOCKED.md — cycle will open a blocked issue." >&2
  exit 1
fi

echo "=== Delta: Developer Agent complete ==="
