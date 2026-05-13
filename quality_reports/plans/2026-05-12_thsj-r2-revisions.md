---
Status: DRAFT (awaiting approval)
Date: 2026-05-12
Author: Christina (CS) + Claude
Scope: THSJ R&R Round 2 — Christina's portion (Comments 1, 2, 3)
Target file: doc/thsj_final_revision/THSJ - Main Document Manuscript-Revised.docx
Coauthor split: Alex owns Comments 4–7 (already drafted in the response file)
---

# THSJ R2 Revisions — Christina's Comments (1, 2, 3)

## Context

The High School Journal has conditionally accepted the paper. Reviewer 2 has three substantive requests on the quantitative tables/figures, all assigned to Christina. Coauthorship is live in Google Docs (with Alex); this plan covers (i) the analysis code to generate the new numbers and (ii) the proposed manuscript edits, both of which need approval before execution.

Analysis is air-gapped (data on TERC server, paths under `/home/research/ca_ed_lab/...`). Per `.claude/rules/air-gapped-workflow.md`, I produce one new Stata do-file with documented assumptions; Christina runs it on the server and shares the outputs back.

**Scope of source code for THSJ outputs.** All THSJ submission outputs were produced from code in `do/learn/` and `do/thsj_rr/`. Some THSJ tables (including Table 2's "All respondents" row) are hand-built in Excel from aggregate stats — this is why we cannot recompute that row's underlying microdata. The `do/getting_down_to_facts/` folder is for a separate project (dissertation chapter 3) and is **not** in scope for this revision.

## Paper output → source code mapping (verified)

After reading every in-scope do-file:

| Paper output | Source | Notes |
|---|---|---|
| Figures 1, 2 (gender / SO word visualizations) | `do/learn/expression.do` | Uses `csac_hs_senior_2023_brief.dta` (raw write-in responses). Out of scope for R2. |
| Figure 3 (college segment 2yr/4yr) | **`do/getting_down_to_facts/gdtf_reg.do`** (the 10% gap) | Outputs land in `tab/thsj_rr/segment_models_*.rtf` and `fig/thsj_rr/segment_comparison*.png`. Despite naming-by-destination, the *source* is the dissertation-Ch3 folder. Out of scope for R2. |
| Figure 4 (degree completion) | Same source as Figure 3 (`gdtf_reg.do`) | Same caveat. Out of scope for R2. |
| Table 1 (summary statistics) | `do/learn/paper_quant_analysis.do` lines 218–228 (`asdoc tabulate gender_cat` etc., `summstats.doc`) | Likely hand-formatted from the .doc. |
| **Table 2** (field of study by gender) | **Hand-built in Excel from aggregate stats** | No do-file produces the displayed Table 2. `tab gender_cat major, row` could regenerate the gender-row breakdowns but the "All respondents" row was hand-coded. Confirms the aggregate-only constraint. |
| **Table 3** (HS experience index by gender) | `do/learn/paper_quant_analysis.do` lines 247–248 (`estpost tabstat hsexp_index ... by(gender_cat)` → `bygender.rtf`) | Displayed table in the paper is the row-formatted version of this output. |
| **Figure 5** (HS exp coefplot by gender) | `do/learn/paper_quant_analysis.do` lines 501–585, **color version** at lines 531–533 → `fig/learn/reg/hsexp_index_gender_w_Nmean_color.png` | Models: M1 unconditional + M2 demographics. |
| **Figures 6, 7, 8** (worry coefplots by gender) | `do/learn/paper_quant_analysis.do` lines 343–494, **color version** at lines 397–404 → `fig/learn/reg/worry_index{1,2,3}_gender_w_Nmean_color.png` | Models: M1 unconditional + M3 demographics + `hsexp_index`. |
| Appendix B (HS exp items + construct overall) | `do/learn/paper_quant_analysis.do` line 235 (`asdoc tabstat $allhsexp hsexp_index`) | Single `summstats.doc` block. |
| Appendix C (HS exp items by gender) | `do/learn/paper_quant_analysis.do` lines 253–269 → `hsexp_items_bygender.rtf` | Also produced under `do/thsj_rr/hsexp_worry_tab.do` line 57 → `hsexp_gender.docx` (duplicate cleaner copy). |
| Appendix D (worry items by gender) | `do/learn/paper_quant_analysis.do` lines 289–305 → `worry_items_bygender.rtf` | Also `do/thsj_rr/hsexp_worry_tab.do` line 57 → `worries_gender.docx`. |
| Appendix E (qualitative sample demographics) | `do/thsj_rr/qual_demo_tab.do` → `tab/thsj_rr/qual_sample_demo.doc` | |
| Appendix A (gender × SO crosstab) | `do/learn/paper_quant_analysis.do` line 228 (`asdoc tab gender_cat so_cat, row nofreq`) | |

**Color palette (line 74–79):** `aggieblue "0 74 168"`, `aggiegold "255 191 0"`. The paper's coefplots use **aggieblue** for the unconditional model and **aggiegold** for the with-controls model. This corrects my earlier mistake about B&W styling.

**Constructs persistence:** `worry_index1/2/3` and `hsexp_index` are saved into `csac_hs_senior_2023_genderso_constructs.dta` (line 622), so the new do-file can `use` that dataset directly — no need to re-run PCA or rebuild the HS index from scratch.

## Existing-code conventions (derived from `do/learn/paper_quant_analysis.do`)

Anchoring all new code to what's already in the repo so we don't introduce new conventions:

- **Dataset:** `$csacprojdir/dta/cln/csac_hs_senior_2023_genderso_constructs.dta` — saved at line 622 of `paper_quant_analysis.do`. Has `hsexp_index`, `worry_index1/2/3`, plus all gender/SO/demographic categoricals already labelled. (The non-constructs file `csac_hs_senior_2023_genderso.dta` does *not* have these.)
- **Gender variable:** `gender_cat` (0=cis man, 1=cis woman, 2=trans man, 3=trans woman, 4=nonbinary, 5=gender diverse/questioning, 6=prefer not to say). Value label `gender_cat_lbl`. Cisgender man is the omitted base in every regression.
- **Outcome variables:** `hsexp_index` (built line 179 as `egen rowtotal($allhsexp)`, set to . if any item missing; n=7,483); `worry_index1` "general worries", `worry_index2` "worries about discrimination", `worry_index3` "worries about financial burdens" (lines 156–165).
- **Globals already declared:** `$allhsexp`, `$allworries`, `$indices = worry_index1 worry_index2 worry_index3`, `$plans = college_fall segment major highest_degree`.
- **Field-of-study variable:** `major` is in `$plans` (line 93). `gdtf_latex_tables.do` has a header note "verify `major_cat` first" — suggesting there may be a derived `major_cat`. **Need to confirm which one drives the published Table 2.** See Open Questions below.
- **Controls in existing models:** `i.race_assn i.parent_edu`. For worry models, M3 additionally includes `c.hsexp_index`. These names propagate from `paper_quant_analysis.do` lines 365 / 372.
- **Coefplot styling (color version that appears in the paper):** symbol `O` for unconditional with line/marker color `"`aggieblue'"` (`0 74 168`); symbol `D` for controls with color `"`aggiegold'"` (`255 191 0`); `xline(0)`; subsample N and mean appended to y-axis labels via the auxiliary value labels `gender_cat_<y>2` built at lines 199–211. Legend: "unconditional" + "control for demographics" (HS index figure) or "control for demographics & HS index" (worry figures). See lines 531–533 (Figure 5) and 397–404 (Figures 6–8).

## Reviewer 2's three comments (verbatim, condensed)

1. **Table 2** (intended field of study by gender): add t-tests of significance comparing each gender population to the "all respondents" population. Significance stars per cell.

2. **Table 3** (General High School Experience Index by gender): convert the index to a standardized scale (mean=0, SD=1). Add t-tests against a reference category (cis men have the highest scores, so use them as the reference).

3. **Figure 5** (and the other coefplots — Figures 6, 7, 8): write out the regression equation(s); clarify whether it's one model and what controls are included; *also* report results on a standardized index scale rather than raw points.

## Reading-of-the-reviewer

Comment 3 is the most far-reaching: standardizing changes the y-axis units in **four** figures (5, 6, 7, 8), and adds one or two equations to the **Data Analysis** subsection of Methods. Comments 1 and 2 are localized.

## Identifying assumptions (will document in the do-file header)

- **Comment 1 test specification (REVISED 2026-05-12 — Section-1 scope correction).** The earlier draft of this plan assumed Table 2's "All respondents" row was hand-built in Excel (an Excel-only artifact from a non-microdata source). That was wrong — Table 2 is the **intended field of study** table, and the underlying survey microdata for the full analytical sample IS available in `csac_hs_senior_2023_genderso_constructs.dta`. We have everything.

  Correct test: **two-sample test of proportions, G vs. not-G**, per cell. For each (gender g, field f) cell:
  - Construct `is_g = (gender_cat == g)` over the analytical sample (non-missing `gender_cat` and `major`).
  - Construct `field_f = (major == f)`.
  - Run `prtest field_f if !mi(major) & !mi(gender_cat), by(is_g)` — Stata's two-sample test of proportions (asymptotic normal approximation).
  - Extract two-sided p-value from `r(p)` (lowercase p — must verify via `pdfgrep` of the Stata 17 manual before implementing, per the lesson from the Section-1 v1 bug).
  Stars: `*` p<0.10, `**` p<0.05, `***` p<0.01.

  This is what reviewers conventionally read "compare each group to the all-respondents population" to mean — it tests whether group G's rate of field f differs from the rate among the rest of the sample. The displayed "All respondents" row is the marginal proportion (mechanically identical regardless of how the test partitions the comparison sample).

  **Small-N caveat:** transgender women (n=20), transgender men (n=59), and gender diverse/questioning (n=71) have cells where the asymptotic normal approximation is weak (cells with expected count < 5). Two options for those rows:

  1. Use `prtest` everywhere and add a table note flagging that asymptotic p-values for small-N groups should be interpreted with caution.
  2. Use Fisher's exact test (`tabi` with `exact` option) for cells where `min(n_g, n_notg) * min(p_g, p_notg) < 5` — gives exact p-values regardless of cell size.

  Plan defaults to **Option 1** (uniform `prtest`) for simplicity and reader-uniformity, with a Note caveat. Switchable to Option 2 if preferred — about 15 extra lines of code.

  **"All respondents" row:** can now be regenerated programmatically from microdata (was previously hand-coded from a separate aggregate source). New code will (a) compute the published marginal from microdata, (b) log it next to the previously-hand-coded values for a sanity check, (c) display the freshly-computed row in the new Table 2 docx. This removes one source of error and ensures the displayed benchmark and the implicit comparison group are internally consistent.
- **Comment 2 standardization sample.** Standardize against the **analytical sample** (n=7,483, students with non-missing hsexp_index), not the universe. Means and SDs reported in Table 3 already use this denominator. So `hsexp_z = (hsexp_index - mean) / sd` over the regression sample.
- **Comment 2 t-test reference.** Cisgender man as the reference, per reviewer's suggestion. Each other group reports its standardized mean and a t-test of the difference from cis men. Implemented as `reg hsexp_z i.gender_cat` with cis man as base; the coefficients **are** the standardized differences and t-stats give significance.
- **Comment 3 — which outcomes to standardize.** Reviewer says "throughout most of your tables and figures rather than the various indexes." I will standardize the four outcomes in the existing coefplots — `hsexp_index`, `worry_general`, `worry_discrim`, `worry_finance` — so all four figures (5, 6, 7, 8) are now in SD units. The **PCA construct ranges** in Table 4's Note will need a parallel update so the reader sees the original scale once and the standardized scale in the figures.
- **Comment 3 — which models stay.** Two specifications per outcome, **but the controls differ by outcome** (matches what `paper_quant_analysis.do` already produces):
  - **Y = standardized `hsexp_index` (Figure 5):** M1 unconditional + M2 demographics-only (race/ethnicity + parental education). HS index can't appear on both sides — it IS the outcome here.
  - **Y = each standardized worry index (Figures 6, 7, 8):** M1 unconditional + M3 demographics + standardized `hsexp_index` as a covariate.
  The equations paragraph in Methods will write both specifications explicitly and note the asymmetry.

## What gets produced

### New Stata do-file: `do/thsj_rr/r2_revisions.do`

Single consolidated script. Reuses globals from `paper_quant_analysis.do` (allhsexp, gender_cat coding 0–6, major_cat, worry construct names). Outputs go to `tab/thsj_rr/` and `fig/thsj_rr/`.

Sections:

1. **`r2_table2_fieldofstudy_ttests.do` section (REVISED 2026-05-12 — Section-1 scope correction)**  
   - **Data:** full microdata available in `csac_hs_senior_2023_genderso_constructs.dta`. Earlier draft assumed Table 2's "All respondents" row was hand-built in Excel from a non-microdata source; that was wrong — Table 2 is the **intended field of study** table, and the underlying survey microdata for the full analytical sample IS in the saved file. The hand-coded `p_all_f` block from v1 of this plan is dropped.
   - **Analytical sample:** students with non-missing `gender_cat` AND non-missing `major` (n=7,499 per the published Note). Compute and assert.
   - **Step 1 — regenerate "All respondents" row from microdata.** For each f in 1..10: compute `p_all_f = x_all_f / n_all` where `n_all = count if !mi(major) & !mi(gender_cat)` and `x_all_f = count if major == f & !mi(gender_cat)`. Log next to the previously-published values for sanity (should match to one decimal place).
   - **Step 2 — per-cell two-sample test of proportions (G vs. not-G).** This is what reviewers conventionally read "compare each group to the all-respondents population" to mean — tests whether group G's rate of field f differs from the rate among the rest of the sample. The displayed "All respondents" row is the marginal proportion. Helper dummies:
     ```stata
     forval f = 1/10 { gen byte field_`f' = (major == `f') if !mi(major) }
     forval g = 0/6  { gen byte is_g_`g'  = (gender_cat == `g') }
     ```
     Then loop:
     ```stata
     forval g = 0/6 {
         forval f = 1/10 {
             qui prtest field_`f' if !mi(major) & !mi(gender_cat), by(is_g_`g')
             local pval = r(p)   // VERIFY scalar name via pdfgrep before implementing
             // store, assign stars, write to matrix and audit CSV
         }
     }
     ```
   - **Pre-implementation step:** invoke the `stata` skill and `pdfgrep` Stata 17 `r.pdf` for `prtest` Stored Results to confirm the two-sided p-value scalar name (likely `r(p)` per Stata's lowercase-p convention for p-values, but verify — the v1 bitesti bug came from skipping this check).
   - **Small-N caveat:** asymptotic `prtest` is unreliable for cells with expected count < 5 (relevant for trans women n=20, trans men n=59, gender diverse n=71 rows). Plan defaults to uniform `prtest` with a table-Note caveat about asymptotic limitations for small-N groups. **Switchable** to Fisher's exact for small-N rows (~15 additional lines via `tabi … , exact`) if you prefer — flag this as a question.
   - **Star levels:** `*` p<0.10, `**` p<0.05, `***` p<0.01.
   - **Word output:** `putdocx` table. "All respondents" row now programmatically computed (no longer hand-coded); gets NO stars (it's the row everyone is being tested against). Each gender row gets stars from the prtest result. N column and bottom-N row as before.
   - **Sentinel cells to verify after running** (predictions, given full microdata):
     - Cis man × Engineering: ~30% vs ~16% → highly significant +.
     - Cis man × Health sciences: ~8% vs ~15% → highly significant –.
     - Cis woman × Engineering: ~8% vs ~16% → highly significant –.
     - Gender diverse/questioning × Humanities: ~31% vs ~11% → highly significant + (small N=71, but effect size large).
   - **Output paths unchanged:** `tab/thsj_rr/r2_table2_field_by_gender_stars.docx` and `tab/thsj_rr/r2_table2_field_by_gender_stars_audit.csv`.

2. **`r2_table3_hsexp_standardized.do` section**  
   - `summarize hsexp_index if e(sample-equivalent)` → mean, SD.  
   - Create `hsexp_z`.  
   - `tabstat hsexp_z, by(gender_cat) stat(mean N)` → standardized means by group.  
   - `reg hsexp_z i.gender_cat` with cis man as base → t-tests of difference vs. cis men.  
   - Output: `tab/thsj_rr/r2_table3_hsexp_standardized.docx` with columns: N, standardized mean, diff vs. cis man (SE, stars).

3. **`r2_figs5to8_standardized_coefplots.do` section**  
   - For Y ∈ {`hsexp_index`, `worry_index1`, `worry_index2`, `worry_index3`}: build z-score `Y_z` over the regression sample.  
   - Also build `hsexp_z` once for use as a covariate in the worry models (matches the existing M3 spec but in SD units).  
   - **Re-estimate the same two specifications already used in the paper**, now on `Y_z`:  
     - For `hsexp_index_z` (Figure 5): M1 = `reg hsexp_index_z i.gender_cat`; M2 = `reg hsexp_index_z i.gender_cat i.race_assn i.parent_edu`.  
     - For each `worry_index*_z` (Figures 6–8): M1 = `reg worry_index*_z i.gender_cat`; M3 = `reg worry_index*_z i.gender_cat c.hsexp_z i.race_assn i.parent_edu`.  
   - Re-issue `coefplot` with new x-axis labels in SD units (likely `xlabel(-1.5(0.5)0.5)` for Fig 5, `xlabel(-0.5(0.5)1.5)` for worry figures — will tune to data after first pass). Preserve existing **color** styling (`color("`aggieblue'")` for unconditional, `color("`aggiegold'")` for controls), `xline(0)`, and the subsample-N-mean y-axis labels (`gender_cat_<y>2`). Mirrors the `_w_Nmean_color.png` pattern at lines 397–404 (worry) and 531–533 (HS exp).  
   - Outputs: `fig/thsj_rr/r2_fig5_hsexp_z.png`, `r2_fig6_worry_index1_z.png`, `r2_fig7_worry_index2_z.png`, `r2_fig8_worry_index3_z.png`.

4. **Adversarial-default sanity logs**: report the standardization mean/SD for each Y, the regression N for each spec, and the cis-man point estimate (should be 0 by construction — used to verify the reference category is correctly set).

### Proposed manuscript edits (Google Doc)

These will be **proposed only** in this plan; Alex and Christina apply them in the Google Doc after approval. Concrete language drafts:

- **Methods → Data Analysis** (around current §"Quantitative Analysis"): add a single paragraph plus equations:

  > To estimate differences in standardized outcomes by gender identity, we estimate two ordinary least squares specifications. Specification (1) is unconditional:
  >
  > $Y^z_i = \alpha + \sum_{g \neq \text{cis man}} \beta_g \cdot \mathbb{1}[\text{gender}_i = g] + \varepsilon_i$
  >
  > where $Y^z_i = (Y_i - \bar{Y})/\mathrm{SD}(Y)$ is the standardized outcome (mean 0, standard deviation 1 in the regression sample) and the gender indicators omit cisgender man as the reference category. Specification (2) adds demographic controls. When the outcome is the high-school-experience index (Figure 5), specification (2) is:
  >
  > $Y^z_i = \alpha + \sum_g \beta_g \mathbb{1}[\text{gender}_i = g] + \gamma' R_i + \delta' P_i + \varepsilon_i$
  >
  > where $R_i$ is a vector of race/ethnicity indicators and $P_i$ is a vector of parental-education indicators. When the outcome is a college-worry index (Figures 6–8), specification (2) additionally controls for the standardized high-school-experience index:
  >
  > $Y^z_i = \alpha + \sum_g \beta_g \mathbb{1}[\text{gender}_i = g] + \gamma' R_i + \delta' P_i + \theta \cdot \text{HSExp}^z_i + \varepsilon_i$
  >
  > Each $\beta_g$ is the difference in the standardized outcome relative to cisgender men, expressed in standard-deviation units.

- **Results — High School Experiences**: rewrite the magnitudes paragraph (currently "transgender men, transgender women, and nonbinary or gender questioning students" — adjectives only; once we have SD units, we add the actual number, e.g., "approximately X SDs below cisgender men").

- **Table 2 Note**: append: "Stars indicate two-sample tests of proportions comparing each gender group's rate of a given field to the rate among the remaining respondents. Significance levels: `*` p<0.10, `**` p<0.05, `***` p<0.01. P-values use the asymptotic normal approximation; for transgender women (n=20), transgender men (n=59), and gender diverse/questioning (n=71), p-values should be interpreted with caution where expected cell counts are small."

- **Table 3 Note**: replace the "ranges from -12 to 12" line with: "The general high school experience index has been standardized to mean 0 and standard deviation 1 across the analytical sample (n=7,483). Stars indicate t-tests of the difference from cisgender men (`*` p<0.10, `**` p<0.05, `***` p<0.01)."

- **Figure 5–8 Notes**: append "Outcome is standardized (mean 0, SD 1)." Update interpretive text in the body that refers to raw-point magnitudes.

- **Footnote 9** (current note explaining the -12 to 12 construct): keep one sentence describing the construct, then add: "We standardize this index to mean 0 and standard deviation 1 for use in regressions and tables."

- **Table 4 Note**: the PCA construct ranges line stays (it's the raw-units description, which is still accurate); I will add one sentence noting that the figures present standardized versions.

## Order of operations

1. **You / Alex approve this plan.** Any clarifications on the Comment 1 test choice (G vs. not-G vs. literal one-sample) get resolved before code runs.
2. I write `do/thsj_rr/r2_revisions.do` with the four sections above. Documented assumptions in the header.
3. You run it on the server. You send back the three table files (`r2_table2_*.docx`, `r2_table3_*.docx`) and four PNGs.
4. I draft the proposed prose edits into a small markdown file you can paste into the Google Doc, plus update the manuscript .docx if you want a marked-up version for Alex.
5. Verifier-style end-of-task check on the new files (exist, non-zero size, expected dimensions).

## What this plan does NOT do

- Does **not** touch Comments 4–7 (Alex's). The reviewer-response file already has Alex's draft responses; not modifying those.
- Does **not** rerun PCA. The three PCA worry indices stay as-is; we just standardize them post-hoc for figure interpretability.
- Does **not** change the regression sample. Same n as the published version (7,464 for the controls model). Standardization is a linear transform; t-stats are unchanged for binary covariates and inference is identical — just rescaled coefficients.
- Does **not** create new figures beyond what's currently in the paper.

## Verification checklist (end of task)

- [ ] `tab/thsj_rr/r2_table2_field_by_gender_stars.docx` exists, non-zero, all 7 gender rows × 10 fields populated, stars look sane (cis men in engineering should be highly significant +; cis men in humanities/health should be highly significant –).
- [ ] `tab/thsj_rr/r2_table3_hsexp_standardized.docx` exists; cis-man row should be the highest standardized mean (still positive); gender diverse/questioning row should be the most negative.
- [ ] Four PNGs render; reference category (cis man) sits at 0 on each; CI lines visible; sample sizes match the unstandardized models.
- [ ] Sanity-log lines in the .txt log: standardization means ≈ 0 and SDs ≈ 1 by construction (mechanical check).

## Open questions for you

All resolved as of 2026-05-12 — see "Resolved during planning" sections.

## Resolved during planning (additional)

- **Equation paragraph location:** Methods → Data Analysis section. (Confirmed by user.)
- **Alex's drafts for Comments 1–3:** none — Christina owns these entirely. (Confirmed by user.)
- **Coefplot styling:** color version (`aggieblue` + `aggiegold`). The paper uses the `_w_Nmean_color.png` output series, not the B&W variant. (Confirmed by user.)
- **PCA:** load `csac_hs_senior_2023_genderso_constructs.dta`, which already has `worry_index1/2/3` and `hsexp_index` baked in (saved at `paper_quant_analysis.do:622`). No need to re-run PCA.
- **Source-of-output:** Table 2 is **hand-built in Excel** from aggregate stats; Table 3 and Figures 5–8 trace to `paper_quant_analysis.do`. Figures 3–4 (out of scope for R2) trace to `gdtf_reg.do` — the 10% gap.
- **`major` value-label map (Q1 closed):**

  | code | label (publication-friendly) | published `p_all_f` (for sanity-check log) |
  |---|---|---|
  | 1 | Business | 0.100 |
  | 2 | Engineering | 0.162 |
  | 3 | Natural sciences | 0.163 |
  | 4 | Social sciences | 0.123 |
  | 5 | Humanities & Arts | 0.114 |
  | 6 | Health sciences | 0.148 |
  | 7 | Education | 0.035 |
  | 8 | Applied sciences | 0.034 |
  | 9 | Public service | 0.048 |
  | 10 | Undecided | 0.075 |

  The raw Stata labels include parenthetical examples (e.g., "Natural sciences (e.g., biology, chemistry, physics)"); the new table uses the abbreviated versions above to match the published Table 2 column headers. The published proportions above are NO LONGER used as test benchmarks — under the revised Comment 1 spec they are only logged next to the computed-from-microdata values for a sanity check (should match to one decimal place).
- **Z-scoring sample (Q2 + Q3 closed):** standardize **over the unconditional regression sample** for both Figure 5 (n=7,483) and Figures 6–8 (n=7,319). M1 and M2/M3 share a single z-scaling so the two specifications are plotted on a comparable scale. The controls-sample z-scores will have mean ≈ 0 and SD ≈ 1 but not exactly — add a one-sentence note to the table/figure notes:
  > "Outcome standardized to mean 0 and standard deviation 1 over the unconditional regression sample (n = X); for the model with controls, the standardized outcome therefore has mean and standard deviation very close to but not exactly 0 and 1."

## Resolved during planning

- **Comment 1 test (REVISED 2026-05-12).** Two-sample `prtest` per cell, G vs. not-G, using full microdata. Earlier draft of this section assumed Table 2 was a non-microdata-backed table; that was a scope error — Table 2 is the intended-field-of-study table and full microdata is available. The Round-1 implementation (one-sample exact binomial `bitesti` against hand-coded `p_all_f` benchmarks) is **superseded** by this two-sample approach. Small-N caveat (asymptotic approximation weak for trans women / trans men / gender diverse rows) handled via a Note in the table; switch to Fisher's exact for those rows is a flagged option if you prefer.
- **Comment 1 v1 lesson (do not repeat).** Stata r() scalars are case-sensitive and not all commands store p-values under intuitive names. Before reading `r(...)` for any new command, invoke the `stata` skill and `pdfgrep` `r.pdf` for the command's Stored Results section. The Round-1 `bitesti` bug (every cell returning p=1.000) came from skipping this check and guessing `r(P)` (capital) when the actual scalar is `r(p)` (lowercase).
