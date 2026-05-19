# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working in this repository.

## What Delta is

Delta is a git submodule that installs into any repo and runs an autonomous two-agent crew nightly via GitHub Actions. Each cycle: the **Product agent** picks the next feature and writes a spec, the **Developer agent** implements it with TDD, and a PR lands in the host repo for human review.

Delta itself contains no application code — it is the tooling that drives development of the host repo.

## Commands (run from the host repo root after install)

```bash
make run-cycle      # full cycle: product → branch → developer → PR
make run-product    # product agent only (inspect .delta/BRIEF.md)
make run-developer  # developer agent only (requires .delta/BRIEF.md)
make docker-build   # build Docker image
make docker-cycle   # run full cycle inside Docker
```

The Makefile in this repo (`delta/`) uses `$(DELTA_SCRIPTS)` pointing at `delta/scripts/`. After `install.sh` runs, the host repo gets `Makefile.template` copied as its own `Makefile` with `DELTA_SCRIPTS := delta/scripts`.

## Architecture

```
delta/                      ← this repo, installed as git submodule
  agents/
    product.md              ← system prompt for Product agent
    developer.md            ← system prompt for Developer agent
  scripts/
    run-cycle.sh            ← orchestrates product → branch → developer → PR
    run-product.sh          ← invokes claude with product.md system prompt
    run-developer.sh        ← invokes claude with developer.md system prompt
    open-pr.sh              ← gh pr create from BRIEF.md
    open-blocked-issue.sh   ← gh issue create from BLOCKED.md
  workflows/
    delta.yml               ← GitHub Actions workflow template (copied to host)
  docker/
    Dockerfile              ← node:24-slim + gh CLI + claude-code CLI
    compose.yml
  install.sh                ← idempotent installer for host repos
  Makefile                  ← make targets resolving DELTA_SCRIPTS absolutely
  Makefile.template         ← version copied to host repo with relative path
```

### State directory in the host repo (`.delta/`)

Installed by `install.sh` and owned by the agents at runtime:

| File | Owner | Purpose |
|------|-------|---------|
| `config.yml` | Human | Product vision, stack constraints, `allowed_deps`, `avoid` list |
| `BACKLOG.md` | Product agent | Ranked backlog with `## In Progress / Ready / Ideas / Completed` sections |
| `BRIEF.md` | Product agent | Current feature spec: acceptance criteria, constraints, out-of-scope |
| `COMPLETED.md` | Developer agent | Append-only log of shipped features |
| `BLOCKED.md` | Developer agent | Written when agent gives up after 3 attempts; triggers a GH issue instead of PR |

### Agent invocation pattern

Both agents are invoked via the Claude Code CLI:

```bash
echo "<prompt>" | claude --print \
  --system-prompt-file delta/agents/<agent>.md \
  --allowedTools "Read,Write,Edit,Glob,Grep,Bash" \
  --dangerously-skip-permissions
```

`run-cycle.sh` orchestrates the full flow: verifies clean main, runs product agent, extracts feature slug from `BRIEF.md` to name the branch (`delta/<slug>-<YYYYMMDD>`), commits BRIEF + BACKLOG, runs developer agent, then pushes and opens the PR.

### Blocked cycle handling

If the developer agent writes `.delta/BLOCKED.md` (or exits non-zero), `run-cycle.sh` stashes changes, deletes the feature branch, and calls `open-blocked-issue.sh` to file a GitHub issue. Humans resolve by editing `BRIEF.md` or `BACKLOG.md` and deleting `BLOCKED.md` before the next cycle.

## GitHub Actions

`workflows/delta.yml` runs at `0 2 * * *` UTC. It checks out the repo with submodules, installs Node.js 24 + `@anthropic-ai/claude-code` + `gh` CLI, sets git identity to `delta@autonomous.agent`, then runs `bash delta/scripts/run-cycle.sh`.

Required secrets in the host repo: `ANTHROPIC_API_KEY`. `GITHUB_TOKEN` is automatic.

## Adding or editing agent behaviour

Agent prompts are in `agents/product.md` and `agents/developer.md`. Changes take effect on the next cycle. The prompts define strict output formats — `BRIEF.md`, `BACKLOG.md`, and `COMPLETED.md` schemas are load-bearing; scripts and downstream tooling parse them with `grep`/`sed`.
