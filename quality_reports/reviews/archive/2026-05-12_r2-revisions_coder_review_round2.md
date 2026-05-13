# r2_revisions.do Review — coder-critic (Round 2)

**Date:** 2026-05-12
**Reviewer:** coder-critic
**Target:** do/thsj_rr/r2_revisions.do
**Score:** 92/100
**Status:** Superseded by ../2026-05-12_r2-revisions_coder_review_round3.md
**Supersedes:** 2026-05-12_r2-revisions_coder_review.md
**Mode:** Full (code + strategy alignment)
**Phase:** Execution (strict severity)

---

## Verdict

PASS — SHIP TO SERVER. All four must-fix items from Round 1 verified as correctly implemented; one of the should-fix items (M4 redundant in-loop regression) also implemented and verified. No regressions introduced. Remaining issues are residual Minor-tier items (M8 CSV quoting, M1 label-case sub-issue between figure y-axis and tables) that the coder explicitly chose not to address; one of these (M1) is partially resolved by Fix 4, leaving only a cosmetic gap between figure axis text and the per-cell labels used in CSV/notes. Score crosses both the commit threshold (>=80) and the PR threshold (>=90).

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

(Body omitted in archive copy — see git history for full text.)

### Fix 5: Pre-loop `qui reg` + persisted `_b[]/_se[]` reads in Section 2 — **PASS**

(Body omitted in archive copy — see git history for full text.)

---

## Score

100 - 8 = 92/100 (PASS commit, PASS PR).

---

## Lifecycle Note

Superseded by Round 3 review (`2026-05-12_r2-revisions_coder_review_round3.md`), which verifies two further changes: Section-1 rewrite (prtest replaces bitesti) and removal of `memtable` from putdocx tables in Sections 1 and 2.
