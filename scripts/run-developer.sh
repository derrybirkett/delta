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
echo "Brief: $(grep '^# Feature Brief:' "$REPO_ROOT/.delta/BRIEF.md" | head -1 | sed 's/^# Feature Brief: *//')"

CLAUDE_EXIT=0
echo "Implement the feature in .delta/BRIEF.md. Today is $(date +%Y-%m-%d). The repo root is $REPO_ROOT. Your branch has already been created." | \
  claude --print \
    --system-prompt-file "$DELTA_DIR/agents/developer.md" \
    --allowedTools "Read,Write,Edit,Glob,Grep,Bash" \
    --dangerously-skip-permissions \
  || CLAUDE_EXIT=$?

# Check for BLOCKED.md — means agent gave up
if [[ -f "$REPO_ROOT/.delta/BLOCKED.md" ]]; then
  echo "Developer agent wrote BLOCKED.md — cycle will open a blocked issue." >&2
  exit 1
fi

# Propagate any non-zero exit from claude that wasn't a BLOCKED.md scenario
if [[ $CLAUDE_EXIT -ne 0 ]]; then
  echo "Developer agent exited with code $CLAUDE_EXIT" >&2
  exit $CLAUDE_EXIT
fi

echo "=== Delta: Developer Agent complete ==="
