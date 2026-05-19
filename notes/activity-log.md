## 2026-05-19 (2) | Session Wrap-Up

**Version:** v0.2.0
**Commits:**
- feat: add GitHub Pages docs site
- chore: opt into Node.js 24 for pages workflow actions

Added a GitHub Pages homepage at https://derrybirkett.github.io/delta/ — plain HTML/CSS, no build step, deployed via `gh-pages` branch so it never appears in submodule checkouts. Also added CLAUDE.md for repo context. Set up via `peaceiris/actions-gh-pages@v4` with Node.js 24 opt-in to clear deprecation warnings.

> `gh-pages` branch is invisible to submodule consumers — only files on the checked-out commit of `main` land in their repo. This makes it the right choice for any docs/tooling overhead you want to keep out of the submodule footprint. Configure Pages via `gh api --method POST /repos/{owner}/{repo}/pages --field 'source[branch]=gh-pages'` after the branch is first created by the workflow.

---

## 2026-05-19 | Session Wrap-Up

**Version:** v0.1.0
**Commits:**
- chore: init delta repo structure
- chore: ignore .superpowers and .claude dirs
- feat: add product agent prompt
- fix: product agent prompt — backlog atomicity, in-progress guard, first-run, date field
- feat: add developer agent prompt
- feat: add run-product.sh script
- feat: add run-developer.sh script
- fix: address code quality issues in developer agent and run script
- feat: add PR and blocked-issue scripts
- feat: add run-cycle.sh orchestrator
- feat: add Makefile targets
- feat: add Docker configuration
- feat: add GH Actions workflow template
- feat: add install.sh
- fix: use --system-prompt-file and stdin for non-interactive claude invocation

Built Delta from scratch — a portable git submodule that installs an autonomous two-agent crew (Product + Developer) into any repo. The product agent reads config.yml and the backlog each night, picks one feature, and writes a scoped BRIEF.md. The developer agent implements it with TDD, commits, and opens a tagged PR for human review. Validated end-to-end against a Next.js todo-app test repo deployed on Vercel with Neon PostgreSQL — the first live cycle autonomously built a "Filter todos by status" feature (PR #1, 9 unit tests, 7 e2e tests).
