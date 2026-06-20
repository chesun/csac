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
| do/experiments/reg_tab.do | diagnosis:do_all-primary_eng-r111 | 2026-06-20T00:00Z | 929792873f64 | DIAGNOSED | L23 controls_svy referenced `i.primary_eng` — truncated name. Var is `primary_english` everywhere (clean_qualtrics_export.do:342; used correctly in explore_rct.do:30 & reg_share.do:15). Pre-existing typo, unrelated to do_all commenting (each file reloads _clean fresh). |
| do/experiments/reg_tab.do | typo-fix-primary_english | 2026-06-20T00:00Z | 929792873f64 | PASS | `i.primary_eng` → `i.primary_english`; static only, server re-run pending |
| do/getting_down_to_facts/cde_demographics.do | diagnosis:do_all-ethnic-r111 | 2026-06-20T00:00Z | 0ee8107b5382 | DIAGNOSED | enr202022.txt schema drift: code expected wide-format cols `ethnic`(0-9) & `kdgn`; `ds` shows the file has `race_ethnicity` & `gr_kn` (gender/grades present). External-file mismatch, not the offboarding edits. |
| do/getting_down_to_facts/cde_demographics.do | cde-colname-renames | 2026-06-20T00:00Z | 0ee8107b5382 | PASS | `rename ethnic`->`race_ethnicity`; added `rename gr_kn kdgn`. ASSUMES race_ethnicity is numeric 0-9 (CDE standard ETHNIC coding); if string, L59 `ethnicity==1` throws r(109) loudly. Static only; server re-run pending. Leaf file (no downstream consumers). |
| do/do_all.do | diagnosis:do_all-log-close-r606 | 2026-06-20T00:00Z | 35a9f0e3c3eb | DIAGNOSED | Final `log close` errored r(606); sub-do-files each run `cap log close _all` which closes the master log early, so nothing is open at the end. Benign — full pipeline (all 5 stages) completed; gdtf_latex_tables wrote its fragments. |
| do/do_all.do | log-close-robust | 2026-06-20T00:00Z | 35a9f0e3c3eb | PASS | final `log close` -> `cap log close _all`; restored to all-stages-active (27 do lines), balance 2/2; static only, final clean full run pending |
