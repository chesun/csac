# Verification Ledger

Cache of verification results for the adversarial-default rule (`.claude/rules/adversarial-default.md`). Each row is one `(path, check)` pair. Agents consult this before running a check; if `File hash` matches the current `sha256(path) | head -c 12` AND `Result == PASS`, the cached result is cited and the check is not re-run.

**Columns:**

- *Path* — repo-relative path to the artifact under check.
- *Check* — slug from the per-domain table in `adversarial-default.md` (e.g., `no-hardcoded-paths`, `seed-set-once`, `parallel-trends`, `incentive-compatibility`).
- *Verified At* — ISO 8601 UTC, minute precision.
- *File hash* — `sha256(<path>) | head -c 12`. Content hash, not metadata.
- *Result* — `PASS`, `FAIL`, or `ASSUMED` (cost-prohibitive / infrastructure-unavailable).
- *Evidence* — short headline with the specific detail (line number, count, p-value, etc.). Full output → session log.

**Update protocol** is in `.claude/rules/adversarial-default.md` § Verification ledger. Stale rows (file hash mismatch, or convention rule modified after `Verified At`) are re-run on access.

---

| Path | Check | Verified At | File hash | Result | Evidence |
|------|-------|-------------|-----------|--------|----------|
| do/clean/clean_qualtrics_export.do | no-hardcoded-paths | 2026-06-14T00:00Z | c36142720eb5 | PASS | grep `"/Users\|"/home\|"C:\\` returned 0 matches; uses $csac* globals |
| do/getting_down_to_facts/cde_demographics.do | no-hardcoded-paths | 2026-06-14T00:00Z | cd4fd426bcfa | PASS | 0 matches; output now `$csacprojdir/dta/cln/cde/` |
| do/csac_survey_finaid.do | no-hardcoded-paths | 2026-06-14T00:00Z | f40aed59c206 | PASS | 1 match at L17 = in-file `global main` project-root def (self-contained settings, like settings.do); analysis code uses the global, 0 stray paths |
| do/clean/clean_qualtrics_export.do | offboarding-pathfix | 2026-06-14T00:00Z | c36142720eb5 | PASS | coder-critic 94/100 (`quality_reports/reviews/2026-06-13_offboarding-pathfixes_coder_review.md`); static only — server run pending |
| do/getting_down_to_facts/cde_demographics.do | offboarding-pathfix | 2026-06-14T00:00Z | cd4fd426bcfa | PASS | `local fall_year=2022` resolves undefined macro; coder-critic 94/100; static only |
| do/csac_survey_finaid.do | offboarding-pathfix | 2026-06-14T00:00Z | f40aed59c206 | PASS | loan figs → `fig/finaid/`, `, replace` added; coder-critic 94/100; static only |

<!-- Real entries replace the _example_ rows above. Keep one row per (path, check). When a file changes, its rows become stale and are re-evaluated on next access. -->
| do/experiments/sum_stats.do | diagnosis:do_all-first_gen-r110 | 2026-06-20T00:00Z | 604587c05a2b | DIAGNOSED | clean_csac_admin.do:114 creates+saves first_gen into csac_survey_ccc_merged_clean.dta (L118); sum_stats.do:14 reloads it then re-gens first_gen → r(110). Only collision (cross-checked all experiments/ gens vs saved vars). do_all.do order: clean_csac_admin(91)→sum_stats(95) |
| do/experiments/sum_stats.do | offboarding-pathfix | 2026-06-20T00:00Z | 604587c05a2b | PASS | added `cap drop first_gen` before `gen first_gen = .` (idempotent); static only — server re-run pending |
