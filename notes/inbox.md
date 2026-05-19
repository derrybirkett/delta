## Handover — 2026-05-19 (2)

**From this session:**
Added GitHub Pages docs site (v0.2.0) — live at https://derrybirkett.github.io/delta/ via `gh-pages` branch, plain HTML/CSS, auto-deployed on push to main.

**Next steps:**
- [ ] Verify the live site at https://derrybirkett.github.io/delta/ once Pages finishes building
- [ ] Update `README.md` to link to the docs site

---

## Handover — 2026-05-19

**From this session:**
Built Delta v0.1.0 — the full autonomous agent submodule: product + developer agents, shell scripts, Docker, GH Actions workflow, and installer. Validated against the todo-app test repo with a live cycle that produced PR #1.

**Next steps:**
- [ ] Rename `crew/` directory locally to `delta/` to match the GitHub repo name (`mv ../crew ../delta`)
- [ ] Test `install.sh` using the real GitHub remote URL (`https://github.com/derrybirkett/delta.git`) — the local-path submodule test passed but the real-remote path hasn't been exercised
- [ ] Trigger the GH Actions workflow manually on todo-app to verify the cloud path (Actions tab → Delta Daily Cycle → Run workflow)
- [ ] Consider adding a `--model` flag to the `claude --print` invocations in the scripts so users can pin a specific model version
- [ ] The `docker/compose.yml` mounts `../..` — document that this assumes Delta is installed one level deep inside the target repo (i.e. `target-repo/delta/`) in the README

---
