# Session Log: 2026-04-28 — Full applied-micro workflow ship to csac

**Status:** COMPLETED
**Supersedes:** `2026-04-28_sync-adversarial-default.md` (minimal install — kept for the within-day decision history but now supplanted by the full ship below)

## Objective

Upgrade csac from a minimal Claude Code setup (one rule, one settings file, no agents) to the full applied-micro workflow: agents, hooks, skills, references, state, full settings, full rules library. Reconcile with csac-specific permissions and existing project documentation.

## Pre-ship state

- `CLAUDE.md` — detailed project doc (CSAC 2023 survey, server-based Stata execution, GDTF3 paper)
- `.claude/rules/` — only `output-length.md` and `adversarial-default.md` (latter from earlier-this-session minimal-install commit)
- `.claude/settings.json` — least-privilege permission allowlist (csac-specific: `Read`, `Glob`, `Grep`, `Agent(*)`, `Skill(*)`, `WebFetch(*)`, `WebSearch(*)`, MCP context7, narrow git permissions like `git show*` / `git blame*`)
- `.claude/state/verification-ledger.md` — from earlier-this-session minimal-install commit
- No agents, hooks, skills, references
- Auto-memory at `~/.claude/projects/.../csac/memory/` — user profile, permissions feedback, GDTF copyedit project memory

## Changes Made

| Operation | Detail |
|-----------|--------|
| Bulk extract | `git -C claude-code-my-workflow archive applied-micro -- .claude/ \| tar -x -C csac/`. Brings in 17 agents, 11 hook scripts, 17 skills, 8 references, applied-micro's `state/primary_source_surnames.txt`, the `WORKFLOW_QUICK_REF.md`, and overwrites `settings.json`. |
| Settings reconciliation | Saved csac's pre-extract settings.json; bulk extract overwrote with applied-micro's. Then merged back 10 csac-specific permissions: `Agent(*)`, `Skill(*)`, `Glob`, `Grep`, `WebFetch(*)`, `WebSearch(*)`, MCP context7 (×2), `Bash(git blame*)`, `Bash(git show*)`. Final permission count: 53. |
| `.gitignore` rewrite | Switched from narrow-allowlist (`.claude/*` + 6 exception lines) to applied-micro's pattern (track everything in `.claude/` by default, ignore only `settings.local.json`, `state/*` with 2 exceptions, `worktrees/`, `CLAUDE.local.md`). Project-level `.DS_Store` ignore preserved. |
| `.claude/state/primary_source_surnames.txt` | Added (from applied-micro). Empty allowlist by default — csac populates as cited authors accumulate. |
| `.claude/rules/output-length.md` | Already present from minimal-install commit; unchanged. |
| `.claude/rules/adversarial-default.md` | Already present; unchanged. |
| `.claude/state/verification-ledger.md` | Already present; unchanged. |

## What was preserved

| Preserved | Why |
|---|---|
| `CLAUDE.md` | csac-specific (CSAC 2023 project doc, server execution model, GDTF3 paper). Not generic template content. |
| `README.md` | csac-specific. |
| Auto-memory at `~/.claude/projects/.../csac/memory/` | Per-machine persistent memory (user profile, permissions feedback, GDTF v3 copyedit log). Untouched. |
| The 10 csac-specific permissions | Merged into the new settings.json so least-privilege custom allowlist is preserved on top of applied-micro's standard set. |
| Project research artifacts (`do/`, `doc/`, `dta/`, `fig/`, `lit/`, `log/`, `tab/`) | Untouched. |

## Reconciliation with auto-memory feedback

The auto-memory's `feedback_permissions_approach.md` says: "Use project-specific least-privilege allowlists, not global auto-approve; Edit/Write should prompt." Tension with full-workflow ship's broader permission list (gh, latexmk, R, Python, etc.). Resolution:

- The 53-entry permissions list is broader than the original csac 19-entry list, but each entry is still a specific glob (e.g., `Bash(latexmk *)`, not `Bash(*)`). Least-privilege applies at the granularity of "what specific tool can run," which is preserved.
- `Edit`/`Write` are NOT in the allowlist (neither in csac's original nor applied-micro's), so the user still gets prompted on file edits — consistent with the feedback.
- The new settings include hook entries (`PreToolUse` primary-source-check, `Stop` primary-source-audit, `PreCompact`, `PostToolUse` context-monitor + verify-reminder, `SessionStart` post-compact-restore). These add automated checks, not new permissions; consistent with least-privilege intent.

If the user finds any individual permission inappropriate for csac, removing the line keeps the rest functional.

## Verification

| Check | Result |
|---|---|
| All applied-micro `.claude/` files extracted | 79 new tracked files (`A` in git status) |
| `settings.json` includes csac-specific permissions | 53 entries; 10 csac-only ones merged back |
| `.gitignore` matches applied-micro pattern | Verified |
| `CLAUDE.md`, `README.md`, project dirs untouched | No `M` for these in `git status` |
| Auto-memory location not modified | `~/.claude/projects/.../csac/memory/` left as-is |

## Open Questions / Blockers

- The hooks (primary-source-check, primary-source-audit, context-monitor, etc.) will fire on csac sessions starting next session. They reference `master_supporting_docs/literature/{papers,reading_notes}/` for primary-source-first. csac doesn't have those yet — citations in load-bearing artifacts (decisions/, quality_reports/plans/, etc.) will trigger blocks. If/when csac authors a `decisions/` ADR or session log that cites a paper, the hooks will require a reading-notes file in `master_supporting_docs/literature/reading_notes/`. Resolution: produce notes via `pdf-learnings` skill, OR use the escape-hatch comment if the citation is illustrative.

## Reference

- Source: `claude-code-my-workflow@applied-micro` `eb2c2c1`.
- Companion ships in this same session: workflow main, applied-micro, behavioral; downstream va_consolidated, tx_peer_effects_local, bdm_bic, csac2025; minimal-install csac (now superseded by this ship).
