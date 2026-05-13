# r2_revisions.do Review — coder-critic (Round 3)

**Date:** 2026-05-12
**Reviewer:** coder-critic
**Target:** do/thsj_rr/r2_revisions.do
**Score:** 94/100
**Status:** Active
**Supersedes:** archive/2026-05-12_r2-revisions_coder_review_round2.md
**Mode:** Full (code + strategy alignment)
**Phase:** Execution (strict severity)

---

## Verdict

**PASS — SHIP TO SERVER.** Both Round-3 substantive changes are correctly implemented and independently verified against the Stata 17 documentation:

1. **prtest replaces bitesti** (Section 1 rewrite): the cited Stata 17 [R] r.pdf p.2066 citation is **accurate** — `r(p)` (lowercase) is the documented two-sided p-value scalar for two-sample prtest. The pdfgrep check was performed before implementation; the v1 bitesti/r(P) bug pattern is not repeated.

2. **memtable removed from both putdocx tables** (Sections 1 and 2): the cited Stata 17 [RPT] putdocx table p.71 fix is **correct and complete**. Per the manual (verified p.99 of the rpt.pdf in my read, which corresponds to p.71 in the Stata-supplied page numbering of the same section): "By default, the table is added to the document immediately after it is created." No separate commit step is required; `putdocx save` persists the in-document tables.

Sections 2 and 3 (the regression/figure body) are **content-identical** to the Round-2 verified version. All four Round-2 must-fix items remain in place; no regressions detected.

Score rises by +2 vs. Round 2: the M1 cosmetic residual remains, but the Round-3 changes themselves earn no new deductions, and Fix-6 (prtest) cleanly resolves the lingering m3 "case-sensitivity comment" lint that survived Round 2.

---

## Section 1 rewrite — Change 1 (prtest replaces bitesti)

### Independent verification of the `r(p)` citation

The coder's code comment at lines 209-214 reads:

> Per Stata 17 [R] r.pdf p.2066 (prtest Stored results, two-sample block), the two-sided p-value is stored in r(p) (lowercase p); one-sided bounds are r(p_l) and r(p_u). The asymptotic z formula for the two-sided test is 2{1 - Phi(|z|)} (p.2067 Methods and formulas). r() scalars are case-sensitive -- using r(P) (capital) would silently return missing.

I read `~/Documents/stata/docs/r.pdf` pages 2064-2069 directly. Findings:

- **p.2064** opens with "prtest — Tests of proportions" — confirms this is the prtest section, not proportion (the latter occupies a different page range).
- **p.2066, "Stored results"** has two relevant subsections:
  - *One-sample prtest and prtesti store the following in r():* includes `r(P)` for sample proportion (capital P), `r(p_l)` lower one-sided p-value, `r(p)` **two-sided p-value**, `r(p_u)` upper one-sided p-value, `r(level)`.
  - *Two-sample prtest and two-sample prtesti store the following in r():* (this is what the script calls — `prtest field_f, by(is_g)` is the two-sample form) includes `r(N1)`, `r(N2)`, `r(P1)`, `r(P2)`, `r(P_diff)` for proportions; then `r(se_diff)`, `r(z)`, `r(p_l)`, **`r(p)` two-sided p-value**, `r(p_u)` upper one-sided p-value.
- **p.2067, "Methods and formulas":** confirms the two-sided p-value is `2{1 - Phi(|z|)}` — matching the comment exactly.

**Verification: the citation is correct in both page number and scalar name.** The v1 bug pattern (capital-`r(P)` silently returning missing for a p-value query) cannot recur, because `r(p)` is the explicitly-documented two-sided p-value name for both one-sample and two-sample prtest.

### Structural verification of Section 1

**Line numbers of the prtest call and `r(p)` extraction:**

- Line 216: `qui prtest field_\`f' if !mi(major) & !mi(gender_cat), by(is_g_\`g')` — two-sample form via `by()`.
- Line 217: `local pval = r(p)` — immediate extraction of the two-sided p-value into a do-file local. No `cap local` wrapper, which is correct (no fallback path is needed; `r(p)` is always populated by a successful two-sample prtest).

**Helper dummies created and dropped:**

- Lines 168-175 (creation block, before the result-matrix initialization):
  ```stata
  forval f = 1/10 {
      cap drop field_`f'
      gen byte field_`f' = (major == `f') if !mi(major)
  }
  forval g = 0/6 {
      cap drop is_g_`g'
      gen byte is_g_`g' = (gender_cat == `g')
  }
  ```
- Lines 322-328 (cleanup block, immediately before Section 2):
  ```stata
  forval f = 1/10 {
      cap drop field_`f'
  }
  forval g = 0/6 {
      cap drop is_g_`g'
  }
  ```
- `cap drop` guards are present BEFORE each `gen`, so re-running the script does not error if the dummies survived a previous run.
- 10 `field_*` + 7 `is_g_*` = **17 helper dummies** — matches the coder's claim. Cleanup happens before Section 2 begins (Section 2's first dataset-modifying op is `gen hsexp_z` at line 349), so there's no possibility of leakage into Section 2's `summarize` or `reg` calls.

**"All respondents" row reads from computed `p_all_\`f''`, not from `pub_\`f''`:**

- Lines 280-284 (the "All respondents" putdocx row):
  ```stata
  putdocx table tbl(2, 1) = ("All respondents")
  forval f = 1/10 {
      local pct_str = strofreal(100 * `p_all_`f'', "%4.1f")
      putdocx table tbl(2, `=`f'+1') = ("`pct_str'"), halign(center)
  }
  ```
- The `p_all_\`f''` locals were computed at lines 127-131 from microdata (`local p_all_\`f'' = \`x_all_\`f'' / \`n_all'`). The `pub_\`f''` locals (lines 135-144) are used ONLY in the sanity-check log loop at lines 148-154 (to compare computed vs. published), never in the rendered table cells. **Verified: the displayed "All respondents" row is microdata-derived, not hand-coded.**

**Sentinel-cell `di` predictions:**

- Lines 248-253:
  ```stata
  di "  Cisgender man x Engineering   (expect HIGH +, low p): " ...
  di "  Cisgender man x Health sciences (expect LOW -, low p): " ...
  di "  Gender diverse/questioning x Humanities (expect HIGH +, low p): " ...
  ```
- These signed predictions are correctly framed for the two-sample prtest interpretation ("group G's rate vs. the rest"), per the plan's two-sample test specification (plan §"Comment 1 test specification REVISED 2026-05-12").
- The directions are still expected to hold under the two-sample test because the rest-of-sample comparison group has a different (and larger) base rate than the cell group, so a substantially elevated or depressed cell rate produces a low two-sided p-value with the corresponding sign on `(p_g - p_notg)`.

**Audit CSV header (line 189):**

```
gender_code,gender_label,field_code,field_label,n_g,x_g,p_g,p_all_f,p_value,stars
```

This is unchanged from Round 2 (column names and order identical). Downstream parsing scripts remain compatible. **Note:** the `p_all_f` column still names the analytical-sample marginal (now microdata-derived), and `p_value` now corresponds to a two-sample prtest p-value (was: one-sample bitesti). Downstream interpreters of the CSV need to understand the test family has changed; flag this in the notes column or downstream documentation.

**Table 2 putdocx Note text (line 318):**

> Stars indicate two-sample tests of proportions comparing each gender group's rate of a given field to the rate among the remaining respondents: * p<0.10, ** p<0.05, *** p<0.01. P-values use the asymptotic normal approximation; for transgender women (n=20), transgender men (n=59), and gender diverse/questioning (n=71), p-values should be interpreted with caution where expected cell counts are small.

Matches the plan §"Table 2 Note" verbatim. The two-sample framing is correctly communicated; the small-N caveat is preserved.

**Sanity-check log block (lines 146-154):**

```stata
di _newline "Sanity: computed p_all from microdata vs. published Table 2 row"
di "  field  computed  published  diff (pp)"
forval f = 1/10 {
    local diff_pp = 100 * (`p_all_`f'' - `pub_`f'')
    di "  `f'      " %5.3f `p_all_`f'' "     " %5.3f `pub_`f'' "     " %5.2f `diff_pp'
    if abs(`diff_pp') > 0.5 {
        di as error "    WARNING: |diff| > 0.5pp for field `f' (`field_`f'_lbl') -- investigate."
    }
}
```

`>0.5pp` is the documented flag threshold (slightly stricter than the plan's "one decimal place" language but consistent in spirit). Will fire if the analytical-sample marginal differs from the published Table 2 row by more than 0.5 percentage points.

**No orphaned `bitesti`:** `grep -nE 'bitesti' do/thsj_rr/r2_revisions.do` returns zero matches. The v1 test family is fully replaced; no dead code remains.

**Status of Section 1: PASS.** All Round-3 verification checklist items satisfied.

---

## Section 1 + Section 2 — Change 2 (memtable removed)

### Independent verification of the memtable fix

I read `~/Documents/stata/docs/rpt.pdf` putdocx table section directly. Findings:

- **p.93** ("putdocx table — Add tables to an Office Open XML (.docx) file"), Description: "putdocx table creates and modifies tables in the active .docx file."
- **p.99** (table_options table, first row):

  > **memtable** specifies that the table be created and held in memory instead of being added to the active document. By default, the table is added to the document immediately after it is created. This option is useful if the table is intended to be added to a cell of another table or to be used multiple times later.

The coder's claim ("table built in memory but never inserted into the document — title paragraph attached normally, hence title-only output") matches the documented behavior of `memtable` exactly. **Removing `memtable` is the correct fix.**

Per the documentation, the default workflow is:

1. `putdocx begin` — opens the active document.
2. `putdocx paragraph` + `putdocx text` — adds content (e.g., the title).
3. `putdocx table tbl = (nrows, ncols)` — creates a table **and adds it to the active document immediately**.
4. `putdocx table tbl(i, j) = (...)` — writes to cells **of the in-document table**.
5. `putdocx save filename, replace` — persists the document to disk.

No auxiliary "commit" or "flush" step is required. The in-document table autoflushes at `putdocx save`. **No additional code change is needed beyond removing `memtable`.**

### Structural verification

**Both `memtable` removals confirmed:**

- `grep -nE 'memtable' do/thsj_rr/r2_revisions.do` returns 4 matches (lines 265, 266, 267, 380) — **all four are comments**, none are actual `memtable` keyword passes to `putdocx table`.
- Line 269 (Section 1): `putdocx table tbl = (\`nrows', \`ncols'), border(all, nil) border(top, single) border(bottom, single)` — no `memtable`.
- Line 381 (Section 2): `putdocx table t3 = (\`t3_nrows', \`t3_ncols'), border(all, nil) border(top, single) border(bottom, single)` — no `memtable`.

Both calls now follow the default (add-to-document) workflow.

**Inline comment at lines 265-268** (Section 1) and **line 380** (Section 2) documents the v1 bug so future maintainers don't reintroduce `memtable`:

```stata
* NOTE: do NOT pass `memtable` -- per Stata 17 [RPT] putdocx table p.71,
* memtable keeps the table in memory only and does not add it to the active
* document. The v1 of this script used memtable and produced empty .docx
* files (title paragraph attached but tables orphaned in memory).
```

(The page-71 citation in the comment corresponds to the manual's internal numbering of the putdocx table topic; I verified the same text on p.99 of the rpt.pdf I read, which is the same section.)

**No other Stata commands rely on the table being in memory:**

I checked the putdocx-related grep output. The only uses of the table names `tbl` and `t3` are:

- `putdocx table tbl(i, j) = (...)` cell-writes (lines 272-314) — these write to the in-document table.
- `putdocx table t3(i, j) = (...)` cell-writes (lines 384-440) — same.

No `putdocx table foo(i, j) = table(tbl)` or `table(t3)` references (the `table(mem_tablename)` cell-content syntax described at p.98). **No downstream code expected `tbl` or `t3` to be in-memory tables to nest inside another table.** The fix is complete and breaks nothing.

**`putdocx save` semantics verified:**

- Line 320 (Section 1): `putdocx save "\`tabout'/r2_table2_field_by_gender_stars.docx", replace` — persists the document with the now-in-document table.
- Line 448 (Section 2): `putdocx save "\`tabout'/r2_table3_hsexp_standardized.docx", replace` — same.

Per p.65 of rpt.pdf ("Saving or clearing the .docx file"): "Issuing the putdocx save command automatically clears the active document from memory and closes it after it is saved." No additional close is needed; the next `putdocx clear` (line 373, before Section 2's table) re-opens cleanly.

**`putdocx clear` before each section:** lines 258 and 373 — preserved from Round 2. Standard hygiene; no regression.

**Status of memtable fix: PASS.** Verified against the manual; both removals confirmed; no auxiliary changes required.

---

## Regression check — Sections 2 and 3 unchanged

### Round-2 must-fix items still in place

All four Round-2 must-fix items from the Round-1 → Round-2 transition remain correctly implemented:

| Round-2 must-fix | Where in Round-3 file | Status |
|---|---|---|
| Fix 1: `cap mkdir` for both tabout and figout | Lines 82-83 | **Preserved** — comment-only marker at line 511 ("(output directories already created at top of script)") |
| Fix 2: `foreach` + `capture confirm variable` for 8 vars | Lines 67-74 | **Preserved** — same 8 variables (gender_cat, major, hsexp_index, worry_index1/2/3, race_assn, parent_edu); `_rc` handling identical |
| Fix 4: Section 3 value labels use `gender_\`i'_lbl` from Section 1 | Lines 495-509 | **Preserved** — three-step `copy → forval → modify` pattern intact; no `:label gender_cat_lbl \`i''` orphan |
| Fix 5: Pre-loop `qui reg` + persisted `_b[]/_se[]` in Section 2 | Lines 359 (qui reg), 366 (display reg), 370 (`local df_t3 = e(df_r)`), 412-415 (in-loop `_b[]/_se[]`) | **Preserved** — no `reg` command inside the `forval g = 1/6` loop at lines 403-428 |

The Round-2 Fix 3 (bitesti WARNING) is **superseded** by the Section-1 rewrite itself — the entire bitesti block is replaced by prtest, so the WARNING-after-fallback construct is no longer needed. Section 1's new prtest WARNING (lines 219-221) fires only if `r(p)` is missing, which is essentially never for a successful two-sample prtest call. The diagnostic remains, simplified.

### Section 3 specifics (unchanged from Round 2)

- **orig_glbl runtime-fetched value-label name** (line 486): `local orig_glbl : value label gender_cat` — preserved. Defensive against upstream label renames.
- **Section 3 label-build loop** (lines 495-509): uses hand-coded `gender_\`i'_lbl` from Section 1 — preserved.
- **Color palette** (lines 76-77): `aggieblue "0 74 168"`, `aggiegold "255 191 0"` — unchanged.
- **Coefplot drop-lists** (lines 531, 564): `drop(_cons *.race_assn *.parent_edu)` and `drop(_cons hsexp_z *.race_assn *.parent_edu)` — unchanged.
- **xlabel ranges** (lines 533, 566): `xlabel(-1.5(0.5)0.5)` (Fig 5) and `xlabel(-0.5(0.5)1.5)` (Figs 6-8) — unchanged.
- **Output filenames** (lines 534, 567): `r2_fig5_hsexp_z_color.png`, `r2_fig{6,7,8}_worry_index{1,2,3}_z_color.png` — unchanged.
- **`label val gender_cat \`orig_glbl'` restore step** (lines 537, 569): preserved.

### Line-number shift summary

Section 1 grew by ~50 lines due to the rewrite (helper-dummy gen/drop blocks, sanity-check log, two-sample prtest comments). Sections 2 and 3 shift accordingly, but content is identical. Verified line shifts:

| Section | Round-2 line range | Round-3 line range | Content delta |
|---|---|---|---|
| Header / preamble | 1-84 | 1-84 | None |
| Section 1 | 86-298 | 86-328 | **Rewrite** (bitesti → prtest, memtable → no memtable, helper dummies + cleanup) |
| Section 2 | 300-411 | 330-448 | None (memtable removed at line 380, same as Round-2 line 350 sans memtable; ~30 lines shifted from Section 1 growth) |
| Section 3 | 413-585 | 450-584 | None (~37 lines shifted) |

---

## Independent verifications run this round

| Check | Command / source | Result |
|---|---|---|
| `r(p)` is two-sided p-value for two-sample prtest | `Read r.pdf p.2065-2069` — confirmed in Stored Results table, both one-sample and two-sample blocks list `r(p)` as two-sided p-value | **PASS** |
| `2{1 - Phi(|z|)}` is the two-sided p-value formula | r.pdf p.2067 Methods and formulas | **PASS** |
| memtable causes in-document orphan | `Read rpt.pdf p.99 table_options table` — confirmed: memtable keeps in memory, default adds to active document | **PASS** |
| Default putdocx workflow needs no auxiliary commit | rpt.pdf p.65 ("putdocx save … automatically clears the active document from memory and closes it after it is saved") | **PASS** |
| No orphaned bitesti | `grep -n bitesti do/thsj_rr/r2_revisions.do` returns 0 | **PASS** |
| Both memtable keyword passes removed | `grep -nE 'memtable' do/thsj_rr/r2_revisions.do` returns 4 lines, all comments | **PASS** |
| 17 helper dummies created and dropped | grep on `field_\|is_g_` shows gen at lines 170, 174; cap drop at lines 169, 173, 324, 327 | **PASS** |
| `cap drop` guards before each `gen` | Lines 169, 173, 348, 474 — present in all four spots | **PASS** |
| `field_\`f''` not present in Section 2 or 3 | `grep -nE 'field_' do/thsj_rr/r2_revisions.do` returns only lines 98-107 (labels), 152, 165, 169, 170, 220, 239, 275, 324, 504 — all in Section 1 or in helper-label references, none after the line-322-328 cleanup block | **PASS — no leakage** |
| Audit CSV header unchanged | Line 189 matches Round-2 header verbatim | **PASS** |

---

## Compliance Evidence (from `.claude/state/verification-ledger.md`)

The ledger still contains only example rows. **No real entries exist for `do/thsj_rr/r2_revisions.do`** after Round-3. All checks below are run fresh against the file rather than cited from the ledger; the verifier should append rows after the user runs the script.

- do/thsj_rr/r2_revisions.do | no-hardcoded-paths | run fresh — `cd "/home/research/..."` at line 55 and `global csacprojdir "/home/research/..."` at line 56 mirror canonical `paper_quant_analysis.do:25-26`. **Server-side absolute path is the project convention** (TERC server). Not a deduction per Round-1 finding.
- do/thsj_rr/r2_revisions.do | seed-set-once | run fresh — PASS (line 52, `set seed 1984`)
- do/thsj_rr/r2_revisions.do | output-table-exports | run fresh — PASS (lines 320, 448; `putdocx save`)
- do/thsj_rr/r2_revisions.do | no-raw-data-overwrites | run fresh — PASS (no `save` to `dta/raw` or `data/raw`)
- do/thsj_rr/r2_revisions.do | log-using-present | run fresh — PASS (line 60)
- do/thsj_rr/r2_revisions.do | confirm-variable-defensive | run fresh — PASS (lines 67-73, foreach loop over 8 vars)
- do/thsj_rr/r2_revisions.do | output-directories-created | run fresh — PASS (lines 82-83, before first use at line 188)
- do/thsj_rr/r2_revisions.do | prtest-stored-results-r(p) | run fresh — PASS (line 217; verified against r.pdf p.2066 two-sample block)
- do/thsj_rr/r2_revisions.do | putdocx-no-memtable | run fresh — PASS (lines 269, 381; verified against rpt.pdf p.99 table_options)
- do/thsj_rr/r2_revisions.do | regressions-cluster-SEs | N/A (descriptive student-level, no clustering required by plan)

---

## Residual Issues (carried forward, unchanged)

### Carried forward from Round 2 — unaddressed by design

- **M8 (CSV labels unquoted, line 239):** still unaddressed. Current gender/field labels (`Cisgender man`, `Engineering`, etc.) contain no commas, so this works today; brittle to future label changes. Minor deduction stands.
- **M6 (no error-cleanup hygiene around `putdocx`):** unchanged. `putdocx clear` at the start of each section (lines 258, 373) handles re-runs but not mid-section failures. Minor deduction stands.
- **M1 residual cosmetic:** figure y-axis now uses hand-coded sentence-case labels consistent with Tables 2 and 3, but these still differ from the project-wide canonical `gender_cat_lbl` defined in `genderso.do:136`. Documented choice (in-code comment at lines 503-505). Within-submission consistency achieved; cross-script gap remains. Minor deduction stands at -1.

### New (Round 3) — observations

- **Audit CSV `p_value` column now reports a two-sample prtest p-value, not a one-sample bitesti p-value.** The column name is unchanged but the test family has changed. Downstream consumers of `r2_table2_field_by_gender_stars_audit.csv` need to know this. **Recommendation:** add a `test_type` column to the CSV in a future iteration, or document this in the file's header comment. Not deducted — the column name is generic enough that the change isn't actively misleading.
- **No `assert _b[0.gender_cat] == 0` after the cis-man-as-base regression in Section 2.** Carried forward from Round 2; comment-only sanity at line 521 ("M1 (unconditional): N = " e(N) ", cis man point = 0 by construction"). Not deducted.
- **No `notrim` or `trim` option used on `putdocx text` calls** — the long Note paragraph on line 318 is fine as a single-line `putdocx text` invocation; Stata handles word-wrap inside `putdocx`. Not an issue.

---

## Score Breakdown

Starting score: 100

| Issue | Round-2 deduction | Round-3 deduction | Notes |
|---|---|---|---|
| C1 (no `mkdir` for tabout) | 0 (resolved) | **0** | Preserved fix |
| C2 (bitesti silent-missing pval) | 0 (resolved by Round-2 WARNING) | **0** | Superseded by Section-1 rewrite — bitesti gone, replaced by prtest with documented `r(p)` extraction |
| M1 (label-case inconsistency figs vs. tables) | -1 | **-1** | Within-submission resolved; cross-script gap with genderso.do persists by design |
| M2 (no `confirm variable` for race_assn, parent_edu) | 0 (resolved) | **0** | Preserved fix |
| M3 (`:type` idiom fragility) | 0 (resolved) | **0** | Preserved fix |
| M4 (redundant in-loop reg) | 0 (resolved) | **0** | Preserved fix |
| M6 (no putdocx error cleanup) | -1 | **-1** | Unchanged; coder explicitly chose not to address |
| M8 (CSV labels unquoted) | -1 | **-1** | Unchanged; coder explicitly chose not to address |
| Minor cluster (m1-m10 residual incl. m3 comment) | -1 | **0** | **m3 comment about "Stata version case-sensitivity" was tied to the bitesti block; Section-1 rewrite removed both bitesti and that comment.** Cluster now empty. **+1 vs. Round 2.** |
| Air-gapped exec — cannot run | -4 | **-3** | Same air-gapped limitation as before, but **the two Round-3 changes are independently verified against the Stata manual to a degree the original Round-1/Round-2 changes weren't** (the prtest `r(p)` claim is directly traceable to the documented Stored Results table; the memtable fix is directly traceable to the documented behavior of the option). The static-analysis confidence is higher this round. Penalty reduced by 1. |

**Total deductions: 6**

**Final score: 100 - 6 = 94/100**

(+2 vs. Round 2.)

---

## Pass/Fail Status

| Threshold | Cutoff | Status |
|---|---|---|
| Commit | >=80 | **PASS** (94) |
| PR | >=90 | **PASS** (94) |
| Submission | >=95 + all components >=80 | Not applicable (in-revision analysis script, not a submission-gated artifact) |
| Block | <80 | Not blocked |

---

## Recommendation

**SHIP TO SERVER.**

Both Round-3 substantive changes are correctly implemented and independently verified against the authoritative Stata 17 documentation:

1. The `r(p)` claim in the prtest citation is the documented two-sided p-value scalar for two-sample prtest (r.pdf p.2066).
2. The `memtable` removal is the correct and complete fix for the v2 "title only" Word output (rpt.pdf p.99: by default the table is added to the document immediately).

The pdfgrep / Read verification was performed both by the coder (per the in-code citation) and independently by me. The v1-style "skip the Stata-manual check" bug pattern is not present in Round 3.

The user can proceed with the air-gapped upload to TERC. After the server run produces outputs (.docx tables and .png figures), have the user:

1. Confirm the log file (`log/thsj_rr/r2_revisions.txt`) shows:
   - **Section 1 sanity-check block** (lines 146-154): `|diff|` between computed and published `p_all_f` is below 0.5pp for all 10 fields (no WARNING lines).
   - **Section 1 sentinel cells** (lines 247-253): cis-man × Engineering with a HIGH proportion and a low p; cis-man × Health sciences with a LOW proportion and a low p; gender-diverse × Humanities with a HIGH proportion and a low p.
   - **Section 1 no WARNING lines** from line 220 (would fire only if `r(p)` is missing from prtest, essentially never for a successful two-sample call).
   - **Section 2 standardization sanity** (line 354): mean ≈ 0 and SD ≈ 1.
2. **Open the .docx files in Word** and confirm they contain populated tables (not just titles). If either file is title-only, escalate immediately — the memtable fix wasn't sufficient and additional putdocx scaffolding is needed.
3. Spot-check that `r2_table2_field_by_gender_stars_audit.csv` opens cleanly and the `p_value` column contains the two-sample prtest p-values (not all 1.000, which was the v1 bitesti failure mode).
4. Share back the .docx files and .png figures for a final visual review.

If the .docx files are still title-only despite the memtable removal, escalate back to the coder for Round 4 — the root cause is something other than memtable, and a deeper putdocx investigation (e.g., examining the .docx XML to see whether the table is in the body or in headers/footers) will be needed.

---

## Escalation Status

**None.** Strike 0 of 3. Round-2 → Round-3 transition is clean; no recurring or new must-fix items.

---

## What I Did NOT Verify (and why)

- **Cannot execute the script** — air-gapped per `.claude/rules/air-gapped-workflow.md`. The two key Round-3 changes are now traceable to the Stata 17 documentation (not just to coder-claim), but the actual runtime behavior remains unverified until the server run. The -3 deduction is held over for this irreducible uncertainty.
- **Did not visually inspect the `.docx` outputs.** Will need post-run confirmation per the recommendation block.
- **Did not append ledger rows** to `.claude/state/verification-ledger.md`. The two new rows enumerated in "Compliance Evidence" (prtest-stored-results-r(p) and putdocx-no-memtable) should be appended by the verifier post-run.

---

## Lifecycle Note

Round-2 review (`2026-05-12_r2-revisions_coder_review_round2.md`) is being superseded by this Round-3 review. Per `.claude/rules/agents.md` § 2a:

1. A copy of the Round-2 review with `Status: Superseded by …round3.md` has been written to `quality_reports/reviews/archive/2026-05-12_r2-revisions_coder_review_round2.md`.
2. The current top-level Round-2 review file at `quality_reports/reviews/2026-05-12_r2-revisions_coder_review_round2.md` should be removed via `git mv ... archive/` — the critic tool cannot perform `git mv` directly, so a manual cleanup is appropriate before commit.
3. `INDEX.md` has been updated to point to this Round-3 review.
