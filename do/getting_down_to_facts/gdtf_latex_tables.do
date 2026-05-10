* ============================================================================
* gdtf_latex_tables.do
* ============================================================================
* Produces bare-tabular LaTeX fragments for dissertation Chapter 3 tables that
* have a Stata source. Outputs to: $csacprojdir/tab/dissertation_chapter3/
*
* These fragments are designed to be \input{}-ed inside a \begin{table} ...
* \caption{} ... \label{} wrapper that lives in the chapter3.tex source. Per
* .claude/rules/tables.md, generated .tex files contain ONLY the tabular
* content -- not the float wrapper or captions/notes.
*
* NOTE: do NOT use /* ... */ block comments here. The output path contains
* a literal "/" followed by "*" (in $csacprojdir/tab/dissertation_chapter3/),
* and Stata's lexer interprets "*/" mid-path as the end of a block comment,
* terminating it early and breaking everything that follows. Use leading-*
* line comments throughout the file.
*
* Tables produced (numbering matches the FINAL published GDTF paper):
*   Table 2  hsexp_summary_gender   HS Experience Index summary by Gender
*   Table 3  hsexp_summary_so       HS Experience Index summary by SO
*   Table 4  worry_items_pca        Worry items + PCA constructs (overall N + mean)
*   Table 6  logit_4yr_gender       Logit: 4-yr enrollment by Gender (odds ratios)
*   Table 7  logit_4yr_so           Logit: 4-yr enrollment by SO (odds ratios)
*   Table 8  ologit_degree_gender   Ordered Logit: degree plans by Gender (odds ratios)
*   Table 9  ologit_degree_so       Ordered Logit: degree plans by SO (odds ratios)
*   Tab A1   gender_so_crosstab     Gender x SO row percentages
*   Tab C1   hsexp_items_gender     HS exp items by Gender (cross-tab of means)
*   Tab C2   hsexp_items_so         HS exp items by SO
*   Tab D1   worry_items_gender     Worry items by Gender
*   Tab D2   worry_items_so         Worry items by SO
*
* Tables NOT produced here (kept hand-formatted in chapter3.tex Tables/):
*   Table 1, A2, E -- demographics / external CDE data / qualitative sample
*   Table 5        -- intended field of study by gender (verify major_cat first)
*
* (Note: Appendix B/Table B from v3 was DROPPED in the final paper, so we no
*  longer generate hsexp_items_construct.)
*
* To run on the server:
*   do $csacprojdir/do/getting_down_to_facts/gdtf_latex_tables.do
*
* Outputs go to tab/dissertation_chapter3/. Sync them back via FileZilla to
* doc/dissertation/chapter3/Tables/, replacing the pandoc-converted versions.
* ============================================================================

version 17.0
set more off
set varabbrev off
set graphics off
set scheme s1color
set seed 1984

cap log close _all

* If running standalone (not via master do_all.do), set project dir
local standalone 1
if `standalone' == 1 {
    cd "/home/research/ca_ed_lab/projects/csac_survey2023"
    global csacprojdir "/home/research/ca_ed_lab/projects/csac_survey2023"
}

log using "$csacprojdir/log/getting_down_to_facts/gdtf_latex_tables.txt", text replace

* Output directory for bare LaTeX tabular fragments
local outdir "$csacprojdir/tab/dissertation_chapter3"
cap mkdir "`outdir'"

* Load cleaned data
use "$csacprojdir/dta/cln/csac_hs_senior_2023_genderso_constructs.dta", clear

* Globals from paper_quant_analysis.do (re-declare in case running standalone)
global allhsexp    hs_academic hs_social hs_community_belong hs_teacher_care hs_good_advising hs_prepared_college
global allworries  worry_tuition worry_living worry_academic worry_work worry_family worry_community worry_away worry_support worry_gender worry_so worry_race worry_religion

* Common esttab options (LaTeX bare tabular)
* booktabs       -- LaTeX output with \toprule/\midrule/\bottomrule
*                  (NOTE: 'booktabs' is itself a LaTeX format -- DO NOT also
*                   pass 'tex'; they are mutually exclusive output formats and
*                   esttab will error with "only one allowed of ... tex,
*                   booktabs, ...". Use one or the other.)
* fragment       -- output ONLY \begin{tabular}...\end{tabular} (no float wrapper)
* nonotes        -- suppress default footer notes (we add via minipage in chapter3.tex)
* label          -- use variable labels instead of raw variable names
local texopts booktabs fragment nonotes label replace

*===============================================================================
* TABLE 2  HS Experience Index summary by Gender Identity
* TABLE 3  HS Experience Index summary by Sexual Orientation
*===============================================================================
estimates clear
estpost tabstat hsexp_index, listwise stat(N mean sd) by(gender_cat) columns(statistics)
esttab . using "`outdir'/tab02_hsexp_by_gender.tex", `texopts' ///
    cells("count(fmt(%9.0f)) mean(fmt(%9.2f)) sd(fmt(%9.2f))") ///
    nostar unstack noobs nonumber

estimates clear
estpost tabstat hsexp_index, listwise stat(N mean sd) by(so_cat) columns(statistics)
esttab . using "`outdir'/tab03_hsexp_by_so.tex", `texopts' ///
    cells("count(fmt(%9.0f)) mean(fmt(%9.2f)) sd(fmt(%9.2f))") ///
    nostar unstack noobs nonumber

*===============================================================================
* TABLE 4  Worry items + PCA constructs (overall N + mean)
*===============================================================================
estimates clear
estpost tabstat $allworries worry_index1 worry_index2 worry_index3, ///
    statistics(N mean) columns(statistics)
esttab . using "`outdir'/tab04_concerns_pca.tex", `texopts' ///
    cells("count(fmt(%9.0f)) mean(fmt(%9.2f))") nostar unstack noobs nonumber

* (Table B from v3 was DROPPED in the final paper -- no longer generated.)

*===============================================================================
* TABLE C1, C2  HS experience items, by Gender / by SO (cross-tab of means)
*===============================================================================
foreach demo in gender so {
    local label_var = cond("`demo'" == "gender", "gender_cat_lbl", "so_cat_lbl")
    estimates clear
    levelsof `demo'_cat, local(cats)
    foreach c of local cats {
        estpost tabstat $allhsexp if `demo'_cat == `c', stat(mean N) columns(statistics)
        est store col_`c'
    }
    esttab col_* using "`outdir'/tab_appC1_hsexp_items_by_`demo'.tex" if "`demo'" == "gender", ///
        `texopts' cells("mean(fmt(%9.2f)) count(fmt(%9.0f))") nostar unstack noobs nonumber
    esttab col_* using "`outdir'/tab_appC2_hsexp_items_by_`demo'.tex" if "`demo'" == "so", ///
        `texopts' cells("mean(fmt(%9.2f)) count(fmt(%9.0f))") nostar unstack noobs nonumber
}

*===============================================================================
* TABLE D1, D2  Worry items, by Gender / by SO (cross-tab of means)
*===============================================================================
foreach demo in gender so {
    estimates clear
    levelsof `demo'_cat, local(cats)
    foreach c of local cats {
        estpost tabstat $allworries if `demo'_cat == `c', stat(mean N) columns(statistics)
        est store col_`c'
    }
    esttab col_* using "`outdir'/tab_appD1_concerns_by_`demo'.tex" if "`demo'" == "gender", ///
        `texopts' cells("mean(fmt(%9.2f)) count(fmt(%9.0f))") nostar unstack noobs nonumber
    esttab col_* using "`outdir'/tab_appD2_concerns_by_`demo'.tex" if "`demo'" == "so", ///
        `texopts' cells("mean(fmt(%9.2f)) count(fmt(%9.0f))") nostar unstack noobs nonumber
}

*===============================================================================
* TABLE A1  Gender x SO row percentages
*===============================================================================
* asdoc-style cross-tab; estpost-tabulate writes contingency to e()
estpost tabulate gender_cat so_cat, percent
esttab . using "`outdir'/tab_appA1_gender_so_crosstab.tex", `texopts' ///
    cell(rowpct(fmt(%9.1f))) unstack noobs nonumber nostar

*===============================================================================
* TABLE 6  Logit: 4-yr enrollment by Gender (odds ratios)  -- replaces segment_or_gender
* TABLE 7  Logit: 4-yr enrollment by SO     (odds ratios)  -- replaces segment_or_so
*===============================================================================
local controls i.race_assn i.parent_edu

foreach demo in gender so {
    estimates clear
    logit segment b0.`demo'_cat
    estimates store seg_`demo'1
    estadd local demo_controls "No"
    estadd local afab_control  "No"

    logit segment b0.`demo'_cat `controls'
    estimates store seg_`demo'2
    estadd local demo_controls "Yes"
    estadd local afab_control  "No"

    if "`demo'" == "so" {
        logit segment b0.`demo'_cat `controls' i.afab
        estimates store seg_`demo'3
        estadd local demo_controls "Yes"
        estadd local afab_control  "Yes"
    }

    local fname = cond("`demo'" == "gender", "tab06_logit_4yr_gender.tex", "tab07_logit_4yr_so.tex")
    if "`demo'" == "gender" {
        esttab seg_gender1 seg_gender2 using "`outdir'/`fname'", `texopts' ///
            keep(*gender_cat*) nobaselevels eform b(%9.3f) ci(%9.3f) ///
            star(* 0.10 ** 0.05 *** 0.01) nomtitles ///
            scalars("N Observations" "demo_controls Demographic Controls")
    }
    else {
        esttab seg_so1 seg_so2 seg_so3 using "`outdir'/`fname'", `texopts' ///
            keep(*so_cat*) nobaselevels eform b(%9.3f) ci(%9.3f) ///
            star(* 0.10 ** 0.05 *** 0.01) nomtitles ///
            scalars("N Observations" "demo_controls Demographic Controls" "afab_control Assigned Sex at Birth")
    }
}

*===============================================================================
* TABLE 8  Ordered Logit: degree plans by Gender (odds ratios)
* TABLE 9  Ordered Logit: degree plans by SO     (odds ratios)
*===============================================================================
foreach demo in gender so {
    estimates clear
    ologit highest_degree i.`demo'_cat
    estimates store deg_`demo'1
    estadd local demo_controls "No"
    estadd local afab_control  "No"

    ologit highest_degree i.`demo'_cat `controls'
    estimates store deg_`demo'2
    estadd local demo_controls "Yes"
    estadd local afab_control  "No"

    if "`demo'" == "so" {
        ologit highest_degree i.`demo'_cat `controls' i.afab
        estimates store deg_`demo'3
        estadd local demo_controls "Yes"
        estadd local afab_control  "Yes"
    }

    local fname = cond("`demo'" == "gender", "tab08_olm_degree_gender.tex", "tab09_olm_degree_so.tex")
    if "`demo'" == "gender" {
        esttab deg_gender1 deg_gender2 using "`outdir'/`fname'", `texopts' ///
            keep(*gender_cat*) nobaselevels eform b(%9.3f) ci(%9.3f) ///
            star(* 0.10 ** 0.05 *** 0.01) nomtitles ///
            scalars("N Observations" "demo_controls Demographic Controls")
    }
    else {
        esttab deg_so1 deg_so2 deg_so3 using "`outdir'/`fname'", `texopts' ///
            keep(*so_cat*) nobaselevels eform b(%9.3f) ci(%9.3f) ///
            star(* 0.10 ** 0.05 *** 0.01) nomtitles ///
            scalars("N Observations" "demo_controls Demographic Controls" "afab_control Assigned Sex at Birth")
    }
}

di as text "Done. LaTeX fragments written to `outdir'/"
di as text "Sync to doc/dissertation/chapter3/Tables/ via FileZilla."

cap log close
