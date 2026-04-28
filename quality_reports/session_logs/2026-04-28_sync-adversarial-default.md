# Session Log: 2026-04-28 — Sync adversarial-default rule (minimal install)

**Status:** COMPLETED

## Objective

Add the new universal `adversarial-default` rule and verification ledger to csac while respecting csac's existing minimal Claude Code setup. csac is not a full applied-micro workflow project — it has no agents/, hooks/, or skills/ — so this ship is rule + ledger only, no critic infrastructure.

## Reconciliation with existing setup

Existing csac state, all preserved:

| Artifact | Notes |
|---|---|
| `CLAUDE.md` | Detailed project doc (CSAC 2023 survey, server-based Stata execution, GDTF3 paper). Untouched. |
| `.claude/settings.json` | Project-specific permission allowlist (least-privilege per the auto-memory feedback at `~/.claude/projects/.../csac/memory/feedback_permissions_approach.md`). Untouched. No new permissions added. |
| `.claude/rules/output-length.md` | The repo's only existing rule. Was previously local-only (gitignored under `.claude/*` blanket). Now tracked, alongside `adversarial-default.md`. |
| Auto-memory | `~/.claude/projects/-Users-christinasun-github-repos-csac/memory/` retains: user profile, permissions feedback, GDTF copyedit project memory. Untouched. |

## Changes Made

| Operation | Detail |
|-----------|--------|
| `.gitignore` updated | Added 3 narrow exceptions to the `.claude/*` blanket: `!.claude/rules/`, `!.claude/rules/*.md`, `!.claude/state/`, `!.claude/state/verification-ledger.md`. Everything else in `.claude/` (settings.local.json, future hooks, etc.) stays gitignored. |
| `.claude/rules/adversarial-default.md` | Added (synced from `claude-code-my-workflow@applied-micro`). Six per-domain checklists: code (Stata + R + Python), data, design, identification, replication, bibliography. |
| `.claude/state/verification-ledger.md` | Added (cache file with example rows; populated as work proceeds). |
| `.claude/rules/output-length.md` | Now tracked as a side effect of the new gitignore exception. Was always present locally. |

## What was intentionally NOT done

| Skipped | Rationale |
|---|---|
| Agents (coder-critic, writer-critic, verifier, strategist-critic) | csac has no `.claude/agents/`. The user's auto-memory shows preference for minimal/least-privilege setup. The rule's principle still applies via Claude reading and following it; ledger still works as a manual tracking file. Not adding 17 agent files where none existed before. |
| Hooks | Same reason. csac has no `.claude/hooks/`. |
| Skills | Same. csac has no `.claude/skills/`. |
| Settings.json widening | Existing settings is already a curated allowlist; auto-memory's `feedback_permissions_approach.md` says "Use project-specific least-privilege allowlists, not global auto-approve; Edit/Write should prompt." Respected. |
| CLAUDE.md edits | csac's CLAUDE.md is project-documentation-heavy (paper details, table refs). The new rule is loaded via `.claude/rules/`; no CLAUDE.md change needed. |

## How this works without critics

- **Rule** is loaded by Claude on session start (`.claude/rules/*.md` convention). Adversarial-default principle applies during work in csac: when claiming compliance with a convention (no hardcoded paths, seed once, dtypes verified, etc.), produce the actual `grep`/diagnostic output, don't just assert.
- **Ledger** is manually maintained. When Claude verifies something, Claude appends a row. When the user reviews verifications, they can `grep '| FAIL |' .claude/state/verification-ledger.md` to see open violations.
- No automated deductions (no critics) means enforcement relies on Claude self-discipline + user audit, rather than scored gates. For a small minimal-install project this is appropriate.

## Verification

| Check | Result |
|---|---|
| `.claude/rules/adversarial-default.md` present | YES |
| `.claude/state/verification-ledger.md` present | YES |
| `.gitignore` un-ignores them | YES (`git status` shows them as untracked-pending-add) |
| Existing files (`output-length.md`, settings.json, CLAUDE.md) unchanged | YES |

## Reference

- Source: `claude-code-my-workflow@applied-micro` `eb2c2c1`.
- Companion ships in this same session: workflow main, applied-micro, behavioral; downstream va_consolidated, tx_peer_effects_local, bdm_bic, csac2025.
