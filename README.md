# Delta

An autonomous agent crew that ships one feature per day.

Delta installs into any repo as a git submodule and runs nightly via GitHub Actions — the Product agent picks what to build, the Developer agent builds it, and a PR lands in your inbox each morning.

## Install into a repo

```bash
git submodule add https://github.com/you/delta delta
bash delta/install.sh
```

## Run locally

```bash
make run-cycle     # full cycle: product → developer → PR
make run-product   # just the product agent (inspect BRIEF.md)
make run-developer # just the developer agent (inspect changes)
```

## Required secrets (in target repo)

- `ANTHROPIC_API_KEY` — your Anthropic API key
