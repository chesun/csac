/******************************************************************************
PROGRAM: THSJ Round-2 Revisions -- Reviewer 2 Comments 1-3 (Christina's)

WRITTEN BY: Christina Sun (ucsun@ucdavis.edu)
DATE CREATED: 2026-05-12

Plan: $csacprojdir/quality_reports/plans/2026-05-12_thsj-r2-revisions.md

To Run This Dofile (on server):
    do "$csacprojdir/do/thsj_rr/r2_revisions.do"

WHAT THIS PRODUCES
------------------
Three outputs, addressing R2 comments 1-3:

  Comment 1 (Table 2 - field of study by gender, with significance stars):
    tab/thsj_rr/r2_table2_field_by_gender_stars.docx
    tab/thsj_rr/r2_table2_field_by_gender_stars_audit.csv  (cell counts + p-values, for audit)

  Comment 2 (Table 3 - standardized HS experience by gender, t-tests vs. cis man):
    tab/thsj_rr/r2_table3_hsexp_standardized.docx

  Comment 3 (Figures 5-8 - standardized coefplots):
    fig/thsj_rr/r2_fig5_hsexp_z_color.png
    fig/thsj_rr/r2_fig6_worry_index1_z_color.png
    fig/thsj_rr/r2_fig7_worry_index2_z_color.png
    fig/thsj_rr/r2_fig8_worry_index3_z_color.png

KEY ASSUMPTIONS (documented per air-gapped-workflow rule)
--------------------------------------------------------
 - Dataset: csac_hs_senior_2023_genderso_constructs.dta (constructs persisted from
   paper_quant_analysis.do:622). hsexp_index and worry_index1/2/3 are already built.
   No need to re-run PCA.
 - Comment 1 test: two-sample test of proportions (prtest), comparing each
   gender group's rate of field f to the rate among the remaining respondents
   (G vs. not-G). "All respondents" row is computed from microdata.
   Asymptotic normal approximation; small-N caveat noted in the table Note.
 - Comment 2: cisgender man is the reference category (per reviewer's suggestion).
 - Comment 3: standardize each outcome over the UNCONDITIONAL regression sample,
   then run M1 (unconditional) and M2/M3 (controls) on the standardized outcome.
 - All four standardized coefplots use the color version (aggieblue unconditional,
   aggiegold controls) matching the paper's published figures.
*******************************************************************************/

* Settings
version 17.0
graph drop _all
set more off
set varabbrev off
set graphics off
set scheme s1color
set seed 1984

* Standalone-run defaults; comment out if running from a master do-file
cd "/home/research/ca_ed_lab/projects/csac_survey2023"
global csacprojdir "/home/research/ca_ed_lab/projects/csac_survey2023"

* Log
cap log close _all
log using "$csacprojdir/log/thsj_rr/r2_revisions.txt", text replace

* Load data with constructs
use "$csacprojdir/dta/cln/csac_hs_senior_2023_genderso_constructs.dta", clear

* Defensive assertions per air-gapped-workflow.md
assert _N > 0
foreach v in gender_cat major hsexp_index worry_index1 worry_index2 worry_index3 race_assn parent_edu {
    capture confirm variable `v'
    if _rc {
        di as error "FATAL: variable '`v'' not found in dataset. Stopping."
        exit _rc
    }
}

* Color palette (matches paper_quant_analysis.do:74-79)
local aggieblue "0 74 168"
local aggiegold "255 191 0"

* Output directories
local tabout "$csacprojdir/tab/thsj_rr"
local figout "$csacprojdir/fig/thsj_rr"
cap mkdir "`tabout'"
cap mkdir "`figout'"

********************************************************************************
* SECTION 1: COMMENT 1 -- Table 2 with significance stars
*   Two-sample test of proportions per (gender, field) cell, comparing each
*   gender group's rate of field f to the rate among the remaining respondents.
*   "All respondents" row is computed from microdata (not hand-coded).
********************************************************************************

di _newline(2) "===================================================="
di "SECTION 1: Table 2 (field of study) -- prtest G vs. not-G"
di "===================================================="

* Publication-friendly field labels (match the published Table 2 column headers,
* not the verbose Stata labels with parenthetical examples)
local field_1_lbl  "Business"
local field_2_lbl  "Engineering"
local field_3_lbl  "Natural sciences"
local field_4_lbl  "Social sciences"
local field_5_lbl  "Humanities & Arts"
local field_6_lbl  "Health sciences"
local field_7_lbl  "Education"
local field_8_lbl  "Applied sciences"
local field_9_lbl  "Public service"
local field_10_lbl "Undecided"

* Gender display labels (match paper's Table 2 row order)
local gender_0_lbl "Cisgender man"
local gender_1_lbl "Cisgender woman"
local gender_2_lbl "Transgender man"
local gender_3_lbl "Transgender woman"
local gender_4_lbl "Nonbinary"
local gender_5_lbl "Gender diverse/questioning"
local gender_6_lbl "Prefer not to say"

* --------------------------------------------------------------------------
* Step 1 -- compute the "All respondents" row from microdata.
* Analytical sample = students with non-missing gender_cat AND non-missing major
* (published Note reports n=7,499; sanity-check the count below).
* --------------------------------------------------------------------------
qui count if !mi(major) & !mi(gender_cat)
local n_all = r(N)
di _newline "Analytical sample (non-missing gender_cat & major): n_all = `n_all'"

forval f = 1/10 {
    qui count if major == `f' & !mi(gender_cat)
    local x_all_`f' = r(N)
    local p_all_`f' = `x_all_`f'' / `n_all'
}

* Sanity check: computed-from-microdata vs. published Table 2 "All respondents".
* Published values are the truth-baseline; flag diffs > 0.5pp.
local pub_1  = 0.100   // Business
local pub_2  = 0.162   // Engineering
local pub_3  = 0.163   // Natural sciences
local pub_4  = 0.123   // Social sciences
local pub_5  = 0.114   // Humanities & Arts
local pub_6  = 0.148   // Health sciences
local pub_7  = 0.035   // Education
local pub_8  = 0.034   // Applied sciences
local pub_9  = 0.048   // Public service
local pub_10 = 0.075   // Undecided

di _newline "Sanity: computed p_all from microdata vs. published Table 2 row"
di "  field  computed  published  diff (pp)"
forval f = 1/10 {
    local diff_pp = 100 * (`p_all_`f'' - `pub_`f'')
    di "  `f'      " %5.3f `p_all_`f'' "     " %5.3f `pub_`f'' "     " %5.2f `diff_pp'
    if abs(`diff_pp') > 0.5 {
        di as error "    WARNING: |diff| > 0.5pp for field `f' (`field_`f'_lbl') -- investigate."
    }
}

* --------------------------------------------------------------------------
* Step 2 -- per-cell two-sample test of proportions (G vs. not-G).
* For each (gender g, field f) cell: test whether group g's rate of field f
* differs from the rate among the remaining respondents. The displayed
* "All respondents" row is the marginal proportion (mechanically identical
* regardless of how prtest partitions the comparison sample).
* --------------------------------------------------------------------------

* Helper dummies for the prtest loop. Restricted to the analytical sample
* (non-missing major) for field_f, and over all observations for is_g_g
* (gender_cat already has no missing for codes 0..6 by construction of the
* analytical sample restriction inside prtest's `if` clause).
forval f = 1/10 {
    cap drop field_`f'
    gen byte field_`f' = (major == `f') if !mi(major)
}
forval g = 0/6 {
    cap drop is_g_`g'
    gen byte is_g_`g' = (gender_cat == `g')
}

* Result matrices.
* Rows: 7 gender groups (cis man ... prefer not to say)
* Cols: 10 fields
matrix prop_mat = J(7, 10, .)
matrix pval_mat = J(7, 10, .)
matrix n_mat    = J(7, 10, .)  // x_g (successes) for audit

* Per-gender sample sizes (n_g) -- denominator for proportions
matrix ng_vec   = J(7, 1, .)

* Open audit CSV (header preserved verbatim from v1 for downstream parsing)
file open auditfh using "`tabout'/r2_table2_field_by_gender_stars_audit.csv", write replace
file write auditfh "gender_code,gender_label,field_code,field_label,n_g,x_g,p_g,p_all_f,p_value,stars" _n

forval g = 0/6 {
    qui count if gender_cat == `g' & !mi(major)
    local n_g = r(N)
    matrix ng_vec[`g'+1, 1] = `n_g'

    forval f = 1/10 {
        qui count if gender_cat == `g' & major == `f'
        local x_g = r(N)

        * Group's observed proportion of field f
        if `n_g' > 0 {
            local p_g = `x_g' / `n_g'
        }
        else {
            local p_g = .
        }

        * Two-sample test of proportions: G (is_g_g==1) vs. not-G (is_g_g==0).
        * Per Stata 17 [R] r.pdf p.2066 (prtest Stored results, two-sample
        * block), the two-sided p-value is stored in r(p) (lowercase p);
        * one-sided bounds are r(p_l) and r(p_u). The asymptotic z formula
        * for the two-sided test is 2{1 - Phi(|z|)} (p.2067 Methods and
        * formulas). r() scalars are case-sensitive -- using r(P) (capital)
        * would silently return missing.
        if `n_g' > 0 {
            qui prtest field_`f' if !mi(major) & !mi(gender_cat), by(is_g_`g')
            local pval = r(p)        // two-sided p-value; r.pdf p.2066

            if mi(`pval') {
                di as error "WARNING: missing p-value for gender=`g' (`gender_`g'_lbl'), field=`f' (`field_`f'_lbl') -- n=`n_g', x=`x_g'. Cell will display without stars."
            }
        }
        else {
            local pval = .
        }

        * Star levels: * p<0.10, ** p<0.05, *** p<0.01
        local stars = ""
        if !mi(`pval') {
            if `pval' < 0.01      local stars = "***"
            else if `pval' < 0.05 local stars = "**"
            else if `pval' < 0.10 local stars = "*"
        }

        matrix prop_mat[`g'+1, `f'] = `p_g'
        matrix pval_mat[`g'+1, `f'] = `pval'
        matrix n_mat[`g'+1, `f']    = `x_g'

        file write auditfh "`g',`gender_`g'_lbl',`f',`field_`f'_lbl',`n_g',`x_g'," (`p_g') "," (`p_all_`f'') "," (`pval') ",`stars'" _n
    }
}
file close auditfh

* Sanity-check log: cells whose direction (vs. the rest of the sample) should
* be obvious under the two-sample prtest. Predictions are signed relative to
* the not-G rate, not relative to the published "All respondents" row.
di _newline "Sentinel cells -- should be highly significant in the expected direction:"
di "  Cisgender man x Engineering   (expect HIGH +, low p): " ///
    %5.3f prop_mat[1,2] "  p=" %5.3f pval_mat[1,2]
di "  Cisgender man x Health sciences (expect LOW -, low p): " ///
    %5.3f prop_mat[1,6] "  p=" %5.3f pval_mat[1,6]
di "  Gender diverse/questioning x Humanities (expect HIGH +, low p): " ///
    %5.3f prop_mat[6,5] "  p=" %5.3f pval_mat[6,5]

* Build the Word table via putdocx
* Layout: 10 rows (header + 7 gender rows + All respondents + N row) x 12 cols
*         (gender label, 10 fields, N column)
putdocx clear
putdocx begin
putdocx paragraph
putdocx text ("Table 2 (R2 revision): Intended Field of Study by Gender Identity, with significance stars"), bold

local nrows = 10  // header + 7 gender + All + N
local ncols = 12  // label + 10 fields + N
* NOTE: do NOT pass `memtable` -- per Stata 17 [RPT] putdocx table p.71,
* memtable keeps the table in memory only and does not add it to the active
* document. The v1 of this script used memtable and produced empty .docx
* files (title paragraph attached but tables orphaned in memory).
putdocx table tbl = (`nrows', `ncols'), border(all, nil) border(top, single) border(bottom, single)

* Header row
putdocx table tbl(1,1) = (""), bold
forval f = 1/10 {
    local col = `f' + 1
    putdocx table tbl(1, `col') = ("`field_`f'_lbl'"), bold halign(center)
}
putdocx table tbl(1, `ncols') = ("N"), bold halign(center)

* "All respondents" row (no stars; benchmark from published values)
putdocx table tbl(2, 1) = ("All respondents")
forval f = 1/10 {
    local pct_str = strofreal(100 * `p_all_`f'', "%4.1f")
    putdocx table tbl(2, `=`f'+1') = ("`pct_str'"), halign(center)
}
qui count if !mi(major) & !mi(gender_cat)
putdocx table tbl(2, `ncols') = ("`r(N)'"), halign(center)

* 7 gender rows with stars
forval g = 0/6 {
    local row = `g' + 3   // rows 3-9
    putdocx table tbl(`row', 1) = ("`gender_`g'_lbl'")
    forval f = 1/10 {
        local pct = 100 * prop_mat[`g'+1, `f']
        local pct_str = strofreal(`pct', "%4.1f")
        local pval = pval_mat[`g'+1, `f']
        local stars = ""
        if !mi(`pval') {
            if `pval' < 0.01      local stars = "***"
            else if `pval' < 0.05 local stars = "**"
            else if `pval' < 0.10 local stars = "*"
        }
        putdocx table tbl(`row', `=`f'+1') = ("`pct_str'`stars'"), halign(center)
    }
    putdocx table tbl(`row', `ncols') = ("`=ng_vec[`g'+1, 1]'"), halign(center)
}

* Bottom N row (column totals)
putdocx table tbl(`nrows', 1) = ("N"), bold
forval f = 1/10 {
    qui count if major == `f' & !mi(gender_cat)
    putdocx table tbl(`nrows', `=`f'+1') = ("`r(N)'"), halign(center)
}
qui count if !mi(major) & !mi(gender_cat)
putdocx table tbl(`nrows', `ncols') = ("`r(N)'"), bold halign(center)

* Notes paragraph
putdocx paragraph
putdocx text ("Note. The rates depicted represent respondents who indicated their intended field of study. Each cell represents the row percentage. Stars indicate two-sample tests of proportions comparing each gender group's rate of a given field to the rate among the remaining respondents: * p<0.10, ** p<0.05, *** p<0.01. P-values use the asymptotic normal approximation; for transgender women (n=20), transgender men (n=59), and gender diverse/questioning (n=71), p-values should be interpreted with caution where expected cell counts are small.")

putdocx save "`tabout'/r2_table2_field_by_gender_stars.docx", replace

* Cleanup: drop helper dummies so they do not persist into Section 2.
forval f = 1/10 {
    cap drop field_`f'
}
forval g = 0/6 {
    cap drop is_g_`g'
}

********************************************************************************
* SECTION 2: COMMENT 2 -- Standardized HS Experience Index + t-tests vs. cis man
********************************************************************************

di _newline(2) "===================================================="
di "SECTION 2: Table 3 (HS experience) -- standardized + t-tests"
di "===================================================="

* Standardize hsexp_index over the unconditional regression sample
* (students with non-missing hsexp_index AND non-missing gender_cat)
qui summarize hsexp_index if !mi(gender_cat), meanonly
local hsexp_mean = r(mean)
qui summarize hsexp_index if !mi(gender_cat)
local hsexp_sd   = r(sd)
local hsexp_n    = r(N)

di "Standardization sample: n = `hsexp_n', mean = `hsexp_mean', SD = `hsexp_sd'"

cap drop hsexp_z
gen hsexp_z = (hsexp_index - `hsexp_mean') / `hsexp_sd' if !mi(gender_cat)
label var hsexp_z "Standardized HS experience (z-score)"

* Sanity check: mean ~ 0 and SD ~ 1 in the standardization sample
qui summarize hsexp_z
di "Sanity: hsexp_z over standardization sample -- mean = " %5.3f r(mean) ///
    ", SD = " %5.3f r(sd) "  (should be ~0 and ~1 by construction)"

* Compute group N and standardized mean for each gender
* Estimate differences vs. cis man via regression
qui reg hsexp_z i.gender_cat
matrix b_t3 = e(b)
matrix V_t3 = e(V)
local int_t3 = _b[_cons]   // intercept = mean for cis man (by construction)

* Display regression for the log
di _newline "Regression: hsexp_z on i.gender_cat (cis man = base)"
reg hsexp_z i.gender_cat

* Capture df once so the loop below does not need to re-run the regression
* (the same regression was previously re-run six times to harvest _b/_se).
local df_t3 = e(df_r)

* Build Table 3 via putdocx
putdocx clear
putdocx begin
putdocx paragraph
putdocx text ("Table 3 (R2 revision): Standardized General High School Experience by Gender Identity"), bold

local t3_nrows = 9   // header + 7 gender + Total
local t3_ncols = 5   // label, N, std mean, diff vs cis man, p
* memtable removed -- see Section 1 NOTE above (kept table in memory only)
putdocx table t3 = (`t3_nrows', `t3_ncols'), border(all, nil) border(top, single) border(bottom, single)

* Header
putdocx table t3(1, 1) = (""), bold
putdocx table t3(1, 2) = ("N"), bold halign(center)
putdocx table t3(1, 3) = ("Std. mean"), bold halign(center)
putdocx table t3(1, 4) = ("Diff. vs. cis man"), bold halign(center)
putdocx table t3(1, 5) = ("Stars"), bold halign(center)

* Cis man row (g=0): N, mean, no diff
local row = 2
qui count if gender_cat == 0 & !mi(hsexp_z)
local n_g = r(N)
qui summarize hsexp_z if gender_cat == 0, meanonly
local m_g_str = strofreal(r(mean), "%5.3f")
putdocx table t3(`row', 1) = ("`gender_0_lbl' (ref.)")
putdocx table t3(`row', 2) = ("`n_g'"), halign(center)
putdocx table t3(`row', 3) = ("`m_g_str'"), halign(center)
putdocx table t3(`row', 4) = ("--"), halign(center)
putdocx table t3(`row', 5) = (""), halign(center)

* Other gender groups (g=1..6): diff from cis man + stars
forval g = 1/6 {
    local row = `g' + 2
    qui count if gender_cat == `g' & !mi(hsexp_z)
    local n_g = r(N)
    qui summarize hsexp_z if gender_cat == `g', meanonly
    local m_g_str = strofreal(r(mean), "%5.3f")

    * Extract coefficient and p-value on `g'.gender_cat from the single
    * regression already run above (no need to re-estimate per iteration).
    local coef = _b[`g'.gender_cat]
    local se   = _se[`g'.gender_cat]
    local tval = `coef' / `se'
    local pval = 2 * ttail(`df_t3', abs(`tval'))

    local diff_str = strofreal(`coef', "%5.3f")
    local stars = ""
    if `pval' < 0.01      local stars = "***"
    else if `pval' < 0.05 local stars = "**"
    else if `pval' < 0.10 local stars = "*"

    putdocx table t3(`row', 1) = ("`gender_`g'_lbl'")
    putdocx table t3(`row', 2) = ("`n_g'"), halign(center)
    putdocx table t3(`row', 3) = ("`m_g_str'"), halign(center)
    putdocx table t3(`row', 4) = ("`diff_str'"), halign(center)
    putdocx table t3(`row', 5) = ("`stars'"), halign(center)
}

* Total row
local row = `t3_nrows'
qui count if !mi(hsexp_z)
local n_tot = r(N)
qui summarize hsexp_z, meanonly
local m_tot_str = strofreal(r(mean), "%5.3f")
putdocx table t3(`row', 1) = ("Total"), bold
putdocx table t3(`row', 2) = ("`n_tot'"), halign(center)
putdocx table t3(`row', 3) = ("`m_tot_str'"), halign(center)
putdocx table t3(`row', 4) = (""), halign(center)
putdocx table t3(`row', 5) = (""), halign(center)

* Notes
putdocx paragraph
local hsexp_mean_str = strofreal(`hsexp_mean', "%4.2f")
local hsexp_sd_str = strofreal(`hsexp_sd', "%4.2f")
putdocx text ("Note. The general high school experience index has been standardized to mean 0 and standard deviation 1 over the standardization sample (n = `hsexp_n', raw mean = `hsexp_mean_str', raw SD = `hsexp_sd_str'). Standardized means by gender identity are reported in column 3. Column 4 reports the difference in standard-deviation units relative to cisgender men, estimated via OLS regression with cisgender man as the omitted reference category. Stars indicate t-tests of the difference: * p<0.10, ** p<0.05, *** p<0.01.")

putdocx save "`tabout'/r2_table3_hsexp_standardized.docx", replace

********************************************************************************
* SECTION 3: COMMENT 3 -- Figures 5-8 standardized coefplots
********************************************************************************

di _newline(2) "===================================================="
di "SECTION 3: Figures 5-8 -- standardized coefplots (color version)"
di "===================================================="

* Standardize all four outcomes over their respective UNCONDITIONAL regression
* samples. hsexp_z was already built in Section 2; rebuild here defensively in
* case Section 2's sample differs from Fig 5's.

* For Figure 5: standardization sample = students with non-missing hsexp_index
* AND non-missing gender_cat. (Already computed above; reuse.)

* For Figures 6-8: each worry_index has its own non-missing pattern. Standardize
* each over the unconditional regression sample (non-missing y and gender_cat).
foreach y of varlist worry_index1 worry_index2 worry_index3 {
    qui summarize `y' if !mi(gender_cat), meanonly
    local `y'_mean = r(mean)
    qui summarize `y' if !mi(gender_cat)
    local `y'_sd   = r(sd)
    local `y'_n    = r(N)

    cap drop `y'_z
    gen `y'_z = (`y' - ``y'_mean') / ``y'_sd' if !mi(gender_cat)
    label var `y'_z "`: var label `y'' (z-score)"

    di "Standardized `y': n = ``y'_n', raw mean = " %6.3f ``y'_mean' ///
        ", raw SD = " %6.3f ``y'_sd'
}

* Fetch the actual value-label name attached to gender_cat. The cleaning
* script(s) upstream may have named it `gender_cat`, `gender_cat_lbl`, or
* something else; the extended macro `: value label var` returns whatever
* it is, so we don't hardcode an assumption that broke at runtime.
local orig_glbl : value label gender_cat
if "`orig_glbl'" == "" {
    di as error "FATAL: gender_cat has no value label attached. Cannot build coefplot y-axis labels."
    exit 198
}
di "Detected gender_cat value-label name: `orig_glbl'"

* Build N-and-mean value labels for the y-axis of each coefplot.
* Mirrors paper_quant_analysis.do:199-211 but for the *standardized* outcomes.
foreach y in hsexp_z worry_index1_z worry_index2_z worry_index3_z {
    cap label drop gender_cat_`y'_lbl
    label copy `orig_glbl' gender_cat_`y'_lbl

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

* (output directories already created at top of script)

* --------------------------------------------------------------------------
* FIGURE 5: hsexp_z by gender (M1 unconditional + M2 demographics)
* --------------------------------------------------------------------------
di _newline "FIGURE 5: standardized HS experience coefplot"

eststo clear
qui reg hsexp_z i.gender_cat
est store hsexp_z_m1
di "  M1 (unconditional): N = " e(N) ", cis man point = 0 by construction"

qui reg hsexp_z i.gender_cat i.race_assn i.parent_edu
est store hsexp_z_m2
di "  M2 (demographics): N = " e(N)

label val gender_cat gender_cat_hsexp_z_lbl
coefplot ///
    (hsexp_z_m1, msymbol(O) ciopts(lwidth(*2) color("`aggieblue'")) mcolor("`aggieblue'")) ///
    (hsexp_z_m2, msymbol(D) ciopts(lwidth(*2) color("`aggiegold'")) mcolor("`aggiegold'")), ///
    drop(_cons *.race_assn *.parent_edu) baselevels label ///
    legend(order(2 "unconditional" 4 "control for demographics") span size(small) cols(1) region(lwidth(none))) ///
    xlabel(-1.5(0.5)0.5) ylabel(, labsize(vsmall)) xline(0)
graph export "`figout'/r2_fig5_hsexp_z_color.png", replace width(1600)

* Restore default label
label val gender_cat `orig_glbl'

* --------------------------------------------------------------------------
* FIGURES 6-8: each worry_index_z by gender (M1 unconditional + M3 demographics + hsexp_z)
* --------------------------------------------------------------------------
* Note: for the worry figures, the controls model adds hsexp_z (the standardized
* HS experience index) as a covariate -- mirrors paper_quant_analysis.do:372 with
* hsexp_index replaced by hsexp_z. Coefficient on hsexp_z is interpretable in
* SD-of-hsexp units.

local figno 6
foreach y in worry_index1 worry_index2 worry_index3 {
    di _newline "FIGURE `figno': standardized `y' coefplot"

    eststo clear
    qui reg `y'_z i.gender_cat
    est store `y'_z_m1
    di "  M1 (unconditional): N = " e(N)

    qui reg `y'_z i.gender_cat c.hsexp_z i.race_assn i.parent_edu
    est store `y'_z_m3
    di "  M3 (demographics + hsexp_z): N = " e(N)

    label val gender_cat gender_cat_`y'_z_lbl
    coefplot ///
        (`y'_z_m1, msymbol(O) ciopts(lwidth(*2) color("`aggieblue'")) mcolor("`aggieblue'")) ///
        (`y'_z_m3, msymbol(D) ciopts(lwidth(*2) color("`aggiegold'")) mcolor("`aggiegold'")), ///
        drop(_cons hsexp_z *.race_assn *.parent_edu) baselevels label ///
        legend(order(2 "unconditional" 4 "control for demographics & HS index") span size(small) cols(1) region(lwidth(none))) ///
        xlabel(-0.5(0.5)1.5) ylabel(, labsize(vsmall)) xline(0)
    graph export "`figout'/r2_fig`figno'_`y'_z_color.png", replace width(1600)

    label val gender_cat `orig_glbl'
    local ++figno
}

di _newline(2) "===================================================="
di "DONE. Outputs:"
di "  `tabout'/r2_table2_field_by_gender_stars.docx"
di "  `tabout'/r2_table2_field_by_gender_stars_audit.csv"
di "  `tabout'/r2_table3_hsexp_standardized.docx"
di "  `figout'/r2_fig5_hsexp_z_color.png"
di "  `figout'/r2_fig6_worry_index1_z_color.png"
di "  `figout'/r2_fig7_worry_index2_z_color.png"
di "  `figout'/r2_fig8_worry_index3_z_color.png"
di "===================================================="

log close
