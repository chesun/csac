# r2_revisions.do Review — coder-critic

**Date:** 2026-05-12
**Reviewer:** coder-critic
**Target:** do/thsj_rr/r2_revisions.do
**Score:** 73/100
**Status:** Superseded by 2026-05-12_r2-revisions_coder_review_round2.md
**Supersedes:** N/A (no prior review for this target — checked `quality_reports/reviews/INDEX.md`)
**Mode:** Full (code + strategy alignment)
**Phase:** Execution (strict severity)

---

## Verdict

DEVIATION-WITH-CONCERNS. The code largely mirrors `do/learn/paper_quant_analysis.do` conventions and implements the plan, but ships with **two Critical risks** (silent fallback path masking a `bitesti` return-name surprise; unguarded `tabout` directory) and **several Major issues** (label-case mismatch with `genderso.do:136`, missing defensive asserts for control variables, redundant regressions, no `putdocx clear` reset hygiene). For an air-gapped run where re-iteration costs round-trip time, deduction is weighted toward silent-wrong-result risks rather than runtime crashes.

---

## Code-Strategy Alignment: MATCH (with one documented deviation)

- Section 1 (Table 2 t-tests): matches plan §1 — `bitesti` per cell, hand-coded `p_all_f`, exact binomial, stars at .10/.05/.01.
- Section 2 (Table 3 standardized): matches plan §2 — z over unconditional regression sample, cis man = base, t-tests via `reg`.
- Section 3 (Figures 5–8 standardized coefplots): matches plan §3 — two-model coefplot, color version (`aggieblue`/`aggiegold`), N-and-mean y-axis labels via `gender_cat_<y>2`-style copies (mirrors `paper_quant_analysis.do:199–211`).

**Documented deviation:** the plan resolved that the y-axis label-copy pattern uses suffix `2` (per `paper_quant_analysis.do:202`, `gender_cat_<y>2`). The code uses suffix `_lbl` instead (`gender_cat_hsexp_z_lbl`, etc., lines 433–444). Functionally equivalent (it's just a different name for the modified label) but **does not exactly mirror the canonical naming**. Not a deduction (the plan also says "build N-and-mean value labels" without prescribing the exact name); flagged for consistency.

---

## Sanity Checks: CONCERNS

- **Sign / magnitude**: cannot execute. Sentinel-cell log lines (213–218) are good — will flag if cis-man-engineering doesn't show a significant +.
- **Dynamics / first stage**: N/A (descriptive/OLS).
- **Sample size**: relies on the plan's claim of n=7,483 (hsexp) and n=7,319 (worry) — these aren't asserted in code. If the dataset on the server has different N, the regression runs anyway; only the standardization will be wrong silently. **No `assert e(N) >= 7000`-style guard.**
- **Reference category at 0**: line 456 logs "cis man point = 0 by construction" but does not `assert _b[0.gender_cat] == 0`. Comment-only check.

---

## Robustness: PARTIAL

The plan does not require new robustness specs (R2 asks for standardization, not new controls). Plan §"What this plan does NOT do" explicitly says "Does not change the regression sample" — and code respects that. No deduction.

---

## Compliance Evidence (from `.claude/state/verification-ledger.md`)

The ledger contains only example rows (lines 20–22). **No real entries exist for `do/thsj_rr/r2_revisions.do`.** All checks below are run fresh against the file rather than cited from the ledger.

- do/thsj_rr/r2_revisions.do | no-hardcoded-paths | (MISSING — flagged below)
- do/thsj_rr/r2_revisions.do | seed-set-once | run fresh — PASS (line 53, `set seed 1984`)
- do/thsj_rr/r2_revisions.do | output-table-exports | run fresh — PASS (lines 281, 397; `putdocx save`)
- do/thsj_rr/r2_revisions.do | no-raw-data-overwrites | run fresh — PASS (no `save` to `data/raw`)
- do/thsj_rr/r2_revisions.do | log-using-present | run fresh — PASS (line 61)
- do/thsj_rr/r2_revisions.do | regressions-cluster-SEs | N/A (descriptive student-level, no clustering required by plan)

The verifier should append rows for these checks to the ledger after the user runs the script and the outputs land.

---

## Critical Issues (silent-wrong-result risks weighted heavily for air-gapped run)

### C1. `tabout` directory not created — Section 1 likely crashes immediately on first run
**Severity:** Critical | **Failure mode:** (b) runtime error on the server (loud failure)
**Lines:** 80, 157, 281

`local tabout "$csacprojdir/tab/thsj_rr"` is set, but unlike `figout` (line 446: `cap mkdir "\`figout'"`), `tabout` is **never created**. Section 1's `file open auditfh using "\`tabout'/r2_table2_..._audit.csv"` at line 157 errors if the directory doesn't exist. So does `putdocx save "\`tabout'/..."` at lines 281 / 397.

Inconsistency confirmed: line 446 does `cap mkdir "\`figout'"` but no parallel for `tabout`.

**Remediation:** add `cap mkdir "\`tabout'"` immediately after line 81 (and arguably before line 446 for `figout`, for symmetry).

### C2. `bitesti` return-scalar fallback may silently produce all-missing p-values
**Severity:** Critical | **Failure mode:** (a) silent wrong results (most dangerous)
**Lines:** 178–188

```stata
qui bitesti `n_g' `x_g' `p_all_`f''
cap local pval = r(P)
if mi(`pval') {
    local pl = r(P_l)
    local pu = r(P_u)
    local pval = min(1, 2 * min(`pl', `pu'))
}
```

`bitest`/`bitesti` in Stata 17 stores `r(N)`, `r(k)`, `r(P_l)` (lower one-sided), `r(P_u)` (upper one-sided), and (per Stata 17 manual) `r(P)` (two-sided). The primary path *should* work, and the fallback is correct defensive backup.

**However:** if for any reason `r(P)` is unset on this Stata install (older versions, MP edition difference, or some edge case where `x_g == 0` or `x_g == n_g` produces a degenerate result), the code falls through to `min(1, 2*min(r(P_l), r(P_u)))`. If `r(P_l)` or `r(P_u)` is missing on those degenerate calls, the result is silently `.`, no stars, **and the cell is left unstarred without any error log**.

The comment at line 181 ("Some Stata versions also store r(P) (two-sided) directly; use it if available, else compute.") is also misleading — Stata 17 *does* store `r(P)`; older versions and some edition variants do not.

**Specifically:** if `x_g == 0` and `n_g > 0`, the binomial test against `p_all_f > 0` is degenerate; `r(P_u)` is well-defined but `r(P_l)` may be either 1 or undefined depending on Stata version. The code does no special-case handling.

**Remediation:** (a) explicit defensive scalar capture with `return list` audit on the first call to confirm what's stored; (b) emit a `di` warning if `pval` is missing after the fallback so the user sees a visible signal rather than a silent blank star; (c) handle x_g == 0 / x_g == n_g cases explicitly.

### C3. `set graphics off` + `coefplot` interaction is untested under the new spec
**Severity:** Critical (downgraded if user has previously run color version successfully) | **Failure mode:** (b) likely runtime or (c) blank PNG

**Lines:** 51, 469, 502

`set graphics off` (line 51) suppresses graph window display but `graph export` still works in the canonical script (`paper_quant_analysis.do:404, 533`). **However**, the canonical script does *not* set `set graphics off` at the top — line 20 does, then it works. So this is the same as the canonical setup. Likely fine, but **no smoke-test evidence** because we cannot run it.

**Remediation:** if PNG output is blank, remove `set graphics off`. Document the symptom→fix mapping in a header comment.

---

## Major Issues

### M1. Label-case mismatch with cleaning script's `gender_cat_lbl`
**Severity:** Major | **Failure mode:** (c) degraded output (display inconsistency only)
**Lines:** 122–128

The cleaning script `do/clean/genderso.do:136` defines `gender_cat_lbl` with **title case** ("Cisgender Man", "Cisgender Woman", "Transgender Man", "Non-binary", "Gender Diverse/Questioning", "Prefer Not to Say"). The hand-coded display labels in r2_revisions.do use **sentence case** with lowercase second word ("Cisgender man", "Cisgender woman", "Transgender man", "Nonbinary", "Gender diverse/questioning", "Prefer not to say").

Three downstream consequences:

1. The Word tables (Tables 2 and 3) will use the sentence-case labels — but the published Tables 2 and 3 use whatever case the manuscript uses. **Verify against `doc/thsj_final_revision/THSJ - Main Document Manuscript-Revised.docx` before sending to coauthor.**
2. Audit CSV labels will not match the Stata label dump.
3. The coefplot y-axis labels (line 442) use `\`:label gender_cat_lbl \`i''` → pulls the **title-case** labels from `genderso.do:136`. So **the figures use title case** while **the tables use sentence case** — **inconsistent within the same submission**.

**Remediation:** decide which case the manuscript uses, then change either the hand-coded locals (lines 122–128) or the value-label definition. Most likely you want title case throughout to match the published figures.

Note: "Nonbinary" (line 126) vs. "Non-binary" (in `genderso.do:136`) — a substantive spelling deviation, not just case.

### M2. No defensive `confirm variable` for `race_assn` and `parent_edu`
**Severity:** Major | **Failure mode:** (b) runtime error mid-script
**Lines:** 67–73, 458, 491

The header asserts existence of `gender_cat`, `major`, `hsexp_index`, `worry_index{1,2,3}` (lines 68–73). But the controls models (`reg hsexp_z i.gender_cat i.race_assn i.parent_edu` at line 458; `reg worry_index1_z i.gender_cat c.hsexp_z i.race_assn i.parent_edu` at line 491) depend on `race_assn` and `parent_edu`. If either is missing on the server-side dataset, the script crashes mid-section after Tables 2 and 3 are already written.

**Remediation:** add `confirm variable race_assn` and `confirm variable parent_edu` near the existing asserts (lines 67–73).

### M3. `: type varname` idiom for existence check is fragile
**Severity:** Major | **Failure mode:** (b) runtime error before any output produced
**Lines:** 68–73

`assert "\`: type gender_cat'" != ""` — the extended macro function `: type varname` on a non-existent variable in Stata 17 returns the empty string (silently). So the assertion *does* fire correctly. But the safer, idiomatic pattern is:

```stata
capture confirm variable gender_cat
if _rc {
    di as error "ERROR: gender_cat missing from dataset"
    error 111
}
```

`confirm variable` produces a clearer error message and follows the canonical Stata pattern from `air-gapped-workflow.md`.

**Remediation:** convert all six existence assertions to `confirm variable` + `_rc` checks.

### M4. Redundant in-loop regressions inflate runtime and risk e() drift
**Severity:** Major | **Failure mode:** (c) wasted runtime; potential e() drift if any iteration silently fails

**Lines:** 312, 319, 359

- Line 312: `qui reg hsexp_z i.gender_cat`
- Line 319: `reg hsexp_z i.gender_cat` (display only)
- Line 359 (inside `forval g = 1/6` loop): `qui reg hsexp_z i.gender_cat` — **runs the same regression 6 more times** to harvest `_b[`g'.gender_cat]` and `_se[`g'.gender_cat]`. The values don't change across iterations; pull them once.

**Remediation:** move `_b`/`_se` reads outside the loop, or use `matrix b_t3 = e(b)` (already captured at line 313) + `matrix V_t3 = e(V)` (line 314) to compute t/p inside the loop without re-running the regression.

### M5. `tabout` directory missing `mkdir`; figout has it
**Severity:** Major (rolled into Critical C1 above; not double-counting). **Stated here only as cross-reference.**

### M6. `putdocx clear` only resets in-memory doc; no error-cleanup hygiene
**Severity:** Major | **Failure mode:** (c) confusing state if mid-script error

**Lines:** 223, 322

`putdocx clear` is called at the start of each section's putdocx build (lines 223, 322), which is correct — it clears any prior partial doc. **But if the script errors *between* `putdocx begin` and `putdocx save`, no cleanup happens.** The next attempt's `putdocx clear` resets state, so subsequent runs are fine. Just no `cap` guard around the putdocx blocks.

**Remediation:** acceptable as-is, but consider wrapping the putdocx build in a structure that ensures `putdocx clear` is hit even on error.

### M7. `coefplot drop()` syntax for the z-scored covariate
**Severity:** Major | **Failure mode:** (c) potentially shows hsexp_z coefficient on the worry coefplots when it should be hidden

**Lines:** 499

`drop(_cons hsexp_z *.race_assn *.parent_edu)` — `hsexp_z` is treated as a single continuous regressor (mirroring `c.hsexp_index` in the original at `paper_quant_analysis.do:401`'s `drop(_cons hsexp_index *.race_assn *.parent_edu)`). **This matches the canonical convention**, so the syntax should drop it correctly.

But the existing canonical line 401 drops `hsexp_index`, not `c.hsexp_index` or `*.hsexp_index`. The new code drops `hsexp_z`, mirroring `hsexp_index` correctly. **Verified.** No deduction; included to confirm.

### M8. CSV audit file lacks quoting; brittle to label content
**Severity:** Major | **Failure mode:** (c) future maintenance breakage

**Lines:** 158, 206

Labels are written unquoted (`...,\`gender_\`g'_lbl',...`). Current labels contain no commas, but "Humanities & Arts" contains `&`. CSV parsing of `&` is fine; CSV parsing of an unescaped comma in a future label change would silently split a row.

**Remediation:** wrap label fields in double quotes (`""`-doubled for embedded quotes), or assert no embedded commas before writing.

---

## Minor Issues

### m1. `set varabbrev off` good, but `summ` abbreviation used
**Severity:** Minor
**Line:** 438

`qui summ \`y' if gender_cat == \`i''` — `summ` is a command abbreviation. `set varabbrev off` only affects variable abbreviation, so `summ` works fine. Just inconsistent with the rest of the file using `summarize`. Spell out for clarity.

### m2. `local pval = .` could be made explicit
**Severity:** Minor
**Line:** 191

`else { local pval = . }` — uses Stata missing literal in a local. Works. Could be more explicit with `local pval ""` and then `if "\`pval'" == ""` check, but current works correctly.

### m3. Misleading comment about `r(P)` availability
**Severity:** Minor
**Lines:** 181–182

The comment suggests `r(P)` is sometimes available "depending on Stata version." In Stata 17 (the version declared on line 47), `r(P)` is stored. The fallback is genuinely belt-and-suspenders, not version-conditional. Update comment for clarity.

### m4. `set graphics off` redundant for batch run
**Severity:** Minor
**Line:** 51

If the server runs in `-b` (batch) mode, `set graphics off` is unnecessary (no display anyway). Harmless redundancy. Mirrors canonical, so keep.

### m5. `graph drop _all` before any graphs exist
**Severity:** Minor
**Line:** 48

Produces a benign "no graphs in memory" message at the very top. Mirrors canonical; keep.

### m6. Section 2 standardize then Section 3 reuses without re-standardize comment is correct
**Severity:** Minor (no deduction — flagged as good practice)
**Lines:** 408–412, 416

Comment correctly notes that hsexp_z built in Section 2 is reused as a covariate in Section 3. Section 3 only re-standardizes the worry outcomes, not hsexp_z. **This is correct per plan** ("Also build hsexp_z once for use as a covariate in the worry models").

### m7. Double summarize for mean and SD
**Severity:** Minor
**Lines:** 293–296, 417–420

Two `summarize` calls — one with `meanonly` (faster), one without (to get SD). Idiomatic Stata. Could collapse to one `summarize` without `meanonly` (slight performance cost but simpler). Acceptable as-is.

### m8. Stars assignment uses `=` with string RHS
**Severity:** Minor (no deduction; preference)
**Lines:** 197–199, 259–261, 368–370

`local stars = "***"` — the `=` evaluates the RHS as an expression; `"***"` is a string literal. Works. Alternative `local stars "***"` (no `=`) is the canonical assignment form. Either is acceptable.

### m9. Label name length OK but tight
**Severity:** Minor

`gender_cat_worry_index3_z_lbl` = 29 characters. Stata's name limit is 32. Tight but compliant.

### m10. Title page line `di "===="` ASCII banners
**Severity:** Minor
**Lines:** 89–91, 287–289, 403–405

Mild violation of `.claude/rules/r-code-conventions.md`-style "no ASCII banners" — but Stata `.do` files don't have an analogous rule explicitly, and the canonical `paper_quant_analysis.do` uses ASCII section dividers. Acceptable.

---

## Score Breakdown

Starting score: 100

(See score derivation in original — final calibrated score 73/100.)

**Final calibration:**
- C1 (no mkdir): -10
- C2 (bitesti edge cases): -5
- M1 (label case mismatch): -5
- M2 (no confirm var for controls): -3
- M3 (`:type` idiom): -1
- M4 (redundant in-loop reg): -1
- M6 (no putdocx error cleanup): -1
- M8 (CSV unquoted): -1
- Minor cluster: -1

**Total: -28 → Final score: 72, rounded to 73/100.**

---

## Remediation List (Ranked by Criticality)

**Must fix before sending to server:**

1. **Add `cap mkdir "\`tabout'"` immediately after line 81.** (C1.)
2. **Add `confirm variable race_assn` and `confirm variable parent_edu` to the header asserts block (after line 73).** (M2.)
3. **Resolve the label-case inconsistency** between figure y-axis (title-case from `genderso.do:136`) and Tables 2 / 3 (hand-coded sentence-case). (M1.)
4. **Add a defensive `di` when `bitesti` returns missing p-value after the fallback.** (C2.)

**Should fix:**

5. Replace `assert "\`: type varname'" != ""` with `capture confirm variable varname` + `_rc` check. (M3.)
6. Pull `_b[\`g'.gender_cat]` / `_se[\`g'.gender_cat]` reads outside the `forval g = 1/6` loop. (M4.)
7. Quote label fields in the audit CSV writer. (M8.)
8. Update the misleading comment at lines 181–182 about `r(P)` availability across Stata versions. (m3.)

**Optional (nice-to-have):**

9. Add `assert _b[0.gender_cat] == 0` after the cis-man-as-base regressions.
10. After the script runs, append ledger rows.

---

## Escalation Status

**None.** First review; coder remediates and we re-review. Strike 0 of 3.

---

## What I Did NOT Verify (and why)

- **Cannot execute the script** — air-gapped per `.claude/rules/air-gapped-workflow.md`. All correctness claims are static analysis only.
- **Cannot confirm `bitesti` return-scalar names on the user's exact Stata 17 build.** Cited the Stata 17 manual from memory.
- **Did not run pdflatex on the output `.docx`** — these are Word files, not LaTeX.
- **Did not check whether `set scheme s1color` is installed on the server**.
