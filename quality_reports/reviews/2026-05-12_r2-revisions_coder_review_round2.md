# r2_revisions.do Review — coder-critic (Round 2)

**Date:** 2026-05-12
**Reviewer:** coder-critic
**Target:** do/thsj_rr/r2_revisions.do
**Score:** 92/100
**Status:** Active
**Supersedes:** ../archive/2026-05-12_r2-revisions_coder_review.md
**Mode:** Full (code + strategy alignment)
**Phase:** Execution (strict severity)

---

## Verdict

PASS — SHIP TO SERVER. All four must-fix items from Round 1 verified as correctly implemented; one of the should-fix items (M4 redundant in-loop regression) also implemented and verified. No regressions introduced. Remaining issues are residual Minor-tier items (M8 CSV quoting, M1 label-case sub-issue between figure y-axis and tables) that the coder explicitly chose not to address; one of these (M1) is partially resolved by Fix 4, leaving only a cosmetic gap between figure axis text and the per-cell labels used in CSV/notes. Score crosses both the commit threshold (≥80) and the PR threshold (≥90).

---

## Fix-by-Fix Verification

### Fix 1: `cap mkdir` for both `tabout` and `figout` near directory locals — **PASS**

**Claim:** Added `cap mkdir "\`tabout'"` and `cap mkdir "\`figout'"` together near where the directory locals are defined; removed the formerly-duplicate mkdir before Figure 5.

**Verification:**
- Lines 81-84:
  ```stata
  local tabout "$csacprojdir/tab/thsj_rr"
  local figout "$csacprojdir/fig/thsj_rr"
  cap mkdir "`tabout'"
  cap mkdir "`figout'"
  ```
- `grep -n mkdir do/thsj_rr/r2_revisions.do` returns exactly two matches (lines 83 and 84). The formerly-duplicate `cap mkdir "\`figout'"` that previously lived just before Figure 5 (Round-1 line 446) has been removed.
- Line 461 now reads only `* (output directories already created at top of script)` — a comment-only marker, no double-mkdir. **Verified.**
- `tabout` is created BEFORE its first use at line 160 (`file open auditfh using "\`tabout'/..."`). Crash mode from Round-1 C1 is eliminated.

**Status:** PASS. No regression.

### Fix 2: `foreach` loop with `capture confirm variable` + `_rc` for 8 variables — **PASS**

**Claim:** Replaced the entire `assert "\`: type var'" != ""` block with a single `foreach` loop using `capture confirm variable` covering 8 variables: gender_cat, major, hsexp_index, worry_index1/2/3, race_assn, parent_edu.

**Verification:**
- Lines 67-74:
  ```stata
  assert _N > 0
  foreach v in gender_cat major hsexp_index worry_index1 worry_index2 worry_index3 race_assn parent_edu {
      capture confirm variable `v'
      if _rc {
          di as error "FATAL: variable '`v'' not found in dataset. Stopping."
          exit _rc
      }
  }
  ```
- **Variable count:** `gender_cat, major, hsexp_index, worry_index1, worry_index2, worry_index3, race_assn, parent_edu` — exactly 8 variables, matching the claim and covering both the Round-1 M2 (race_assn, parent_edu) and M3 (`:type` idiom) gaps.
- **`_rc` handling:** `exit _rc` correctly terminates the script with the non-zero return code (Stata's idiomatic error path); `di as error` produces a clearly-formatted error message naming the missing variable. This is stronger than the original `assert` (assert just throws code 9 without identifying which variable failed).
- **No orphaned references** to the old `assert "\`: type ...'" != ""` idiom remain (`grep ': type'` returns 0 matches; `grep ':label'` returns 0 matches — see also Fix 4 verification).

**Status:** PASS. Cleanly resolves both Round-1 M2 and M3 in one block. No regression.

### Fix 3: WARNING `di as error` inside `n_g > 0` branch when pval missing after fallback — **PASS**

**Claim:** Added `di as error "WARNING: ..."` inside the `if \`n_g' > 0` branch after both the primary `r(P)` capture and the `r(P_l)/r(P_u)` fallback, gated by `if mi(\`pval')`.

**Verification:**
- Lines 181-198 (Section 1 inner loop):
  ```stata
  if `n_g' > 0 {
      qui bitesti `n_g' `x_g' `p_all_`f''
      cap local pval = r(P)
      if mi(`pval') {
          local pl = r(P_l)
          local pu = r(P_u)
          local pval = min(1, 2 * min(`pl', `pu'))
      }
      * Degenerate cells (x_g == 0 or x_g == n_g) can still yield missing
      * pval if r(P_l) / r(P_u) are unset. Emit a visible warning so the
      * reader does not silently miss a star-less cell.
      if mi(`pval') {
          di as error "WARNING: missing p-value for gender=`g' (`gender_`g'_lbl'), field=`f' (`field_`f'_lbl') -- n=`n_g', x=`x_g'. Cell will display without stars."
      }
  }
  else {
      local pval = .
  }
  ```
- **Gating check:** WARNING is inside the `if \`n_g' > 0` branch (line 181), so it does NOT fire for empty groups (the `else` branch silently sets `pval = .`, which is the correct behavior — empty groups have no test to perform).
- **Over-firing check:** WARNING fires only when `mi(\`pval')` after BOTH the `r(P)` primary path AND the `r(P_l)/r(P_u)` fallback. Standard non-degenerate cells with normal `bitesti` returns will populate `r(P)` and never trigger the warning. The fallback's `min(1, 2*min(r(P_l), r(P_u)))` produces a non-missing value whenever both `r(P_l)` and `r(P_u)` are non-missing — which is the case for all non-degenerate test cells. So the warning is correctly scoped to genuine degenerate cells (`x_g == 0` AND p_all_f > 0, or `x_g == n_g` AND p_all_f < 1, where `r(P_l)` or `r(P_u)` may be unset).
- **Diagnostic content:** the WARNING includes gender label, field label, `n_g`, `x_g` — enough information for the user to pinpoint which cell was affected without re-running.
- Round-1 m3 (the misleading "Some Stata versions also store r(P)" comment) remains in place at lines 183-185. Not addressed; flagged below as a residual Minor.

**Status:** PASS. Correctly scoped, will not over-fire for ordinary missing-data cases. No regression.

### Fix 4: Section 3 value labels use hand-coded `gender_\`i'_lbl` from Section 1 — **PASS**

**Claim:** Section 3's value-label build now uses the hand-coded `gender_\`i'_lbl` locals from Section 1 instead of `:label gender_cat_lbl \`i''`. Claimed change at ~line 457.

**Verification:**
- Lines 445-458 (Section 3 label-build loop):
  ```stata
  foreach y in hsexp_z worry_index1_z worry_index2_z worry_index3_z {
      cap label drop gender_cat_`y'_lbl
      label copy gender_cat_lbl gender_cat_`y'_lbl

      forval i = 0/6 {
          qui summ `y' if gender_cat == `i'
          local ybar : display %4.2f r(mean)
          local nval = r(N)
          * Use the hand-coded sentence-case labels from Section 1
          * (gender_`i'_lbl) so the figure y-axis ticks match Tables 2 and 3
          * exactly ("Nonbinary" one word, "Cisgender man" sentence case, etc.).
          label define gender_cat_`y'_lbl `i' ///
              `" "`gender_`i'_lbl'" "(N=`nval', mean=`ybar')" "', modify
      }
  }
  ```
- **`label copy` seed step preserved:** Line 447 (`label copy gender_cat_lbl gender_cat_\`y'_lbl`) is still present. This seeds all 7 entries (g=0..6) from the title-case `gender_cat_lbl` defined in `genderso.do:136`. The subsequent `forval i = 0/6` loop then overwrites each entry with the sentence-case `gender_\`i'_lbl` + `(N=..., mean=...)` second line, via `modify`. **Correct three-step pattern preserved.**
- **No orphaned `:label gender_cat_lbl \`i''` reference:** `grep ':label'` returns 0 matches in the file. The fragile Round-1 idiom is fully replaced.
- **Naming consistency note:** the hand-coded labels at lines 125-131 use "Nonbinary" (one word) and "Cisgender man" (sentence case); these are now ALSO what appears on the figure y-axis. The figure axis and the in-cell table labels are now consistent with each other and with the audit CSV. **This resolves the within-submission inconsistency from Round-1 M1.**
- **Residual cosmetic gap:** the title-case `gender_cat_lbl` from `genderso.do:136` is still the project-wide canonical label, and the new Section 3 labels diverge from it. This is acceptable per the in-code comment at lines 453-455 — the script's intent is "match Tables 2 and 3" not "match `genderso.do`". The choice has been made deliberately and documented.

**Status:** PASS. Three-step `copy → forval → modify` pattern preserved. M1's primary failure mode (figure axis vs. table mismatch) is resolved.

### Fix 5: Pre-loop `qui reg` + persisted `_b[]/_se[]` reads in Section 2 — **PASS**

**Claim:** Pulled the per-iteration `qui reg hsexp_z i.gender_cat` out of the Section 2 loop; captured `e(df_r)` once into a local `df_t3` after the display reg (~line 332); inner loop now reads `_b[]` / `_se[]` from persisted regression results.

**Verification:**
- **(a) Regression is run BEFORE the loop, not inside:**
  - Line 321: `qui reg hsexp_z i.gender_cat` (the quiet run that establishes `e()`)
  - Line 328: `reg hsexp_z i.gender_cat` (the loud run for the log — also re-establishes `e()`)
  - Line 332: `local df_t3 = e(df_r)` — captured immediately after the display run
  - Lines 364-389: `forval g = 1/6` loop — **no `reg` command inside the loop body**. `grep 'qui reg|reg hsexp'` shows lines 321, 328, 469, 473, 502, 506 — none of these are inside the `forval g = 1/6` loop at lines 364-389. **Confirmed.**

- **(b) `_b[]` / `_se[]` / `e()` are not disturbed by the loop's `qui count` and `qui summarize` calls:**
  - The inner loop contains only `qui count` (line 366) and `qui summarize` (line 368), then reads `_b[\`g'.gender_cat]` (line 373) and `_se[\`g'.gender_cat]` (line 374). 
  - `count` and `summarize` are r-class — they update `r()` but do NOT touch `e()` or the saved `_b[]`/`_se[]` system vectors (which are populated from `e(b)` and `e(V)` and persist until the next e-class command like `regress`).
  - Stata's `_b[]` and `_se[]` reference the most-recent estimation results' coefficient vector and SE; these are unaffected by r-class commands. **Correctness preserved.**

- **(c) `e(df_r)` captured into a local before the loop starts:**
  - Line 332: `local df_t3 = e(df_r)` — captured before the `forval g = 1/6` loop opens at line 364.
  - Inside the loop, line 376: `local pval = 2 * ttail(\`df_t3', abs(\`tval'))` — uses the cached `df_t3`. No reliance on `e(df_r)` being current at iteration time. **Robust against any future code change that injects an r-class command between iterations.**

- **No regression to Section 3:** Section 3's `reg` calls (lines 469, 473, 502, 506) are unchanged. Section 3 uses `est store` + `coefplot` (which reads from stored estimates by name), not `_b[]/_se[]`, so Section 3 is not affected by the Section 2 refactor.

**Status:** PASS. Refactor preserves correctness and removes 6 redundant regression runs from the section. No regression.

---

## Analytical-Logic Preservation Check

Confirmed unchanged from Round-1 (spot-checked against Round-1 review's line references and the current file):

- **`bitesti` invocation form** (line 182): `qui bitesti \`n_g' \`x_g' \`p_all_\`f''` — identical to Round-1; Section 1 test family unchanged (one-sample exact binomial, two-sided).
- **Hand-coded `p_all_f` benchmark values** (lines 100-109): unchanged.
- **Standardization formulas** (lines 311, 436): `(var - mean) / sd` over the unconditional regression sample (gender_cat non-missing). Unchanged.
- **Reference category**: cis man (gender_cat = 0) is the base for all `i.gender_cat` regressions; Section 3 uses `est store` for two-model coefplot. Unchanged.
- **Coefplot drop-list** (lines 481, 514): `drop(_cons *.race_assn *.parent_edu)` for Figure 5; `drop(_cons hsexp_z *.race_assn *.parent_edu)` for Figures 6-8. Unchanged.
- **Color values** (lines 77-78): `aggieblue "0 74 168"`, `aggiegold "255 191 0"`. Unchanged.
- **Output filenames** (lines 290, 409, 484, 517): unchanged.
- **xlabel ranges** (lines 483, 516): `-1.5(0.5)0.5` (Fig 5), `-0.5(0.5)1.5` (Figs 6-8). Unchanged.
- **Star thresholds** (lines 206-208, 268-270, 380-382): 0.10/0.05/0.01. Unchanged.

No silent strategy drift introduced by the remediation.

---

## Additional Sweep (per instructions)

- **Orphaned references to old idioms:** `grep ': type'` and `grep ':label'` both return 0 matches in the file. **No orphans.**
- **Local-variable scope issues:** all new locals (`df_t3`, `pl`, `pu`, etc.) are defined within the do-file's natural scope. The `df_t3` local survives across the `forval g = 1/6` loop because Stata locals persist for the duration of the do-file unless explicitly cleared. **No scope issue.**
- **putdocx state:** `putdocx clear` is called at lines 232 and 335 before each `putdocx begin`. No new putdocx call was added; the Round-1 M6 (no error-cleanup if mid-section error) is unchanged. Acceptable as-is (Round-1 m6 was already classified as low-deduction).
- **coefplot state:** `eststo clear` is called before each coefplot section (lines 468, 501). Estimates from Section 2's regression (lines 321, 328) are not stored via `est store`, so they don't pollute the `est store` namespace used by Section 3. **No leak.**
- **TODO/FIXME comments:** `grep -i 'TODO|FIXME|XXX'` returns 0 matches. **None.**
- **Inadvertent dataset variable changes:** the only `gen`/`cap drop` commands are for `hsexp_z` (line 311), `worry_index1_z`/`worry_index2_z`/`worry_index3_z` (line 436) — all are documented and explicit per the plan. The `label val gender_cat gender_cat_<y>_lbl` at lines 477 and 510 and `label val gender_cat gender_cat_lbl` at lines 487 and 519 toggle the displayed value label for `gender_cat` during plotting and restore it after — `gender_cat` data values are not modified. **No drift.**

---

## Compliance Evidence (from `.claude/state/verification-ledger.md`)

The ledger still contains only example rows. **No real entries exist for `do/thsj_rr/r2_revisions.do`** after Round-2. All checks below are run fresh against the file rather than cited from the ledger; the verifier should append rows after the user runs the script.

- do/thsj_rr/r2_revisions.do | no-hardcoded-paths | run fresh — `cd "/home/research/..."` at line 56 and `global csacprojdir "/home/research/..."` at line 57 mirror canonical `paper_quant_analysis.do:25-26`. **Server-side absolute path is the project convention** (TERC server). Not a deduction per Round-1 finding.
- do/thsj_rr/r2_revisions.do | seed-set-once | run fresh — PASS (line 53, `set seed 1984`)
- do/thsj_rr/r2_revisions.do | output-table-exports | run fresh — PASS (lines 290, 409; `putdocx save`)
- do/thsj_rr/r2_revisions.do | no-raw-data-overwrites | run fresh — PASS (no `save` to `dta/raw` or `data/raw`)
- do/thsj_rr/r2_revisions.do | log-using-present | run fresh — PASS (line 61)
- do/thsj_rr/r2_revisions.do | confirm-variable-defensive | run fresh — PASS (lines 68-74, foreach loop over 8 vars)
- do/thsj_rr/r2_revisions.do | output-directories-created | run fresh — PASS (lines 83-84, before first use at line 160)
- do/thsj_rr/r2_revisions.do | regressions-cluster-SEs | N/A (descriptive student-level, no clustering required by plan)

---

## Residual Issues (not addressed; intentional or low-priority)

### Carried forward from Round 1, unaddressed by design

- **M8 (CSV labels unquoted, line 215):** coder explicitly skipped this. Current labels contain no commas; works today; brittle to future label changes. Minor deduction stands.
- **m3 (misleading comment at lines 183-185 about r(P) availability across Stata versions):** comment still present. Cosmetic only — does not affect execution. Minor deduction stands.
- **M6 (no error-cleanup hygiene around `putdocx`):** unchanged. Acceptable as-is; rerunning the script triggers `putdocx clear` at the start of each section.
- **M1 residual cosmetic:** the figure y-axis now uses the hand-coded sentence-case labels (which is consistent with Tables 2 and 3), but these still differ from the project-wide canonical `gender_cat_lbl` defined in `genderso.do:136`. This is a deliberate choice documented in the in-code comment at lines 453-455. The within-submission inconsistency from Round 1 is resolved; what remains is a cross-script naming gap that future maintenance should reconcile.

### New (not flagged in Round 1) — minor observations

- **Section 2 line 332** (`local df_t3 = e(df_r)`): the local is captured after the display `reg` at line 328, NOT after the `qui reg` at line 321. The two regressions are identical, so `e(df_r)` is the same. Confirmed correct. Worth noting that if a future edit removes the display `reg` (line 328) and `df_t3` capture moves further away, the `e(df_r)` reference could go stale; but this is hypothetical and not a current bug.
- **No `assert _b[0.gender_cat] == 0`** after the cis-man-as-base regression. Round-1 flagged this as optional; still not present. Comment-only sanity at line 471 ("cis man point = 0 by construction"). Not a deduction; flagged for completeness.

---

## Score Breakdown

Starting score: 100

| Issue | Round-1 deduction | Round-2 deduction | Notes |
|---|---|---|---|
| C1 (no `mkdir` for tabout) | -10 | **0** | Resolved by Fix 1 |
| C2 (bitesti silent-missing pval) | -5 | **0** | Resolved by Fix 3 |
| M1 (label-case inconsistency figs vs. tables) | -5 | **-1** | Within-submission inconsistency resolved by Fix 4; residual cross-script gap with `genderso.do` is a minor cosmetic note |
| M2 (no `confirm variable` for race_assn, parent_edu) | -3 | **0** | Resolved by Fix 2 (now covers 8 vars) |
| M3 (`:type` idiom fragility) | -1 | **0** | Resolved by Fix 2 |
| M4 (redundant in-loop reg) | -1 | **0** | Resolved by Fix 5 |
| M6 (no putdocx error cleanup) | -1 | **-1** | Unchanged; coder explicitly chose not to address |
| M8 (CSV labels unquoted) | -1 | **-1** | Unchanged; coder explicitly chose not to address |
| Minor cluster (m1-m10 residual incl. m3 comment) | -1 | **-1** | Largely unchanged |
| Air-gapped exec — cannot run | (-4 reserved) | **-4** | Same as Round 1 — unverifiable runtime |

**Total deductions: 8**

**Final score: 100 - 8 = 92/100**

---

## Pass/Fail Status

| Threshold | Cutoff | Status |
|---|---|---|
| Commit | ≥80 | **PASS** (92) |
| PR | ≥90 | **PASS** (92) |
| Submission | ≥95 + all components ≥80 | Not applicable (this is an in-revision analysis script, not a submission-gated artifact) |
| Block | <80 | Not blocked |

---

## Recommendation

**SHIP TO SERVER.**

All four Round-1 must-fix items are correctly implemented; Fix 5 (the lower-priority refactor) is a clean win with no functional change to analytical output. No regressions detected. Remaining issues are residual Minor-tier items that the coder explicitly chose not to address; none affect correctness for the upcoming run.

The user can proceed with the air-gapped upload to TERC. After the server run produces outputs (.docx tables and .png figures), have the user:

1. Share back the log file (`log/thsj_rr/r2_revisions.txt`) and confirm:
   - The "Sanity check: computed p_all from microdata vs. hand-coded p_all_f" block (lines 137-147) shows ≤ ~1pp discrepancies — confirms the published Table 2 "All respondents" row matches our analytical sample within rounding.
   - The "Sentinel cells" block (lines 220-227) shows cis-man × Engineering with a HIGH positive proportion and a low p-value (expected highly significant +); cis-man × Health sciences with a LOW negative proportion and a low p-value (expected highly significant −); gender-diverse × Humanities with a HIGH positive proportion and a low p-value.
   - The hsexp_z "Sanity" line (line 316) shows mean ≈ 0 and SD ≈ 1.
   - No WARNING lines from Fix 3 are present (or if they are, the user understands which cells are degenerate and confirms those cells' star-less display is the intended behavior).
2. Spot-check that `r2_table2_field_by_gender_stars_audit.csv` opens cleanly in Excel/Stata and that no rows have been split by unquoted-comma issues (residual M8 risk; current labels contain no commas, so should be fine).
3. Share back the resulting `.docx` files and `.png` files for a final visual review.

If any sentinel-cell check fails or the WARNING line appears for an unexpected cell, escalate back to the coder for a Round 3.

---

## Escalation Status

**None.** Strike 0 of 3. Round-1 → Round-2 transition was clean; no recurring issues.

---

## What I Did NOT Verify (and why)

- **Cannot execute the script** — air-gapped per `.claude/rules/air-gapped-workflow.md`. All correctness claims remain static analysis. The -4 deduction in the score for unverifiable runtime is held over from Round 1.
- **Cannot confirm `bitesti` return-scalar behavior on the user's exact Stata 17 build.** Fix 3's WARNING line will make any silent-failure mode visible if it occurs at runtime.
- **Did not visually inspect the `.docx` outputs** — these will be produced server-side and reviewed downstream.
- **Did not append ledger rows** — the `.claude/state/verification-ledger.md` should be updated by the verifier post-run with the eight rows enumerated in "Compliance Evidence" above.

---

## Lifecycle Note

Round-1 review (`2026-05-12_r2-revisions_coder_review.md`) is being moved to `archive/` per `.claude/rules/agents.md` § 2a. A redirect tombstone was placed at the original path because the critic tool cannot perform `git mv` directly; a manual `git mv quality_reports/reviews/2026-05-12_r2-revisions_coder_review.md quality_reports/reviews/archive/` is appropriate before commit (the archived copy was written separately and contains the original content with the `Status:` line updated to `Superseded by 2026-05-12_r2-revisions_coder_review_round2.md`).
