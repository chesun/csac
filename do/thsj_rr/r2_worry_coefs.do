/******************************************************************************
PROGRAM: THSJ R2 -- Print standardized worry-index regression coefficients
         (for filling in Edit 10 of the prose-edit bundle)

WRITTEN BY: Christina Sun (ucsun@ucdavis.edu)
DATE CREATED: 2026-05-12

To Run This Dofile (on TERC server):
    do "$csacprojdir/do/thsj_rr/r2_worry_coefs.do"

WHAT THIS PRODUCES
------------------
Two outputs:
 - log/thsj_rr/r2_worry_coefs.txt -- noisily prints all 6 regressions (M1+M3 for
   each of the 3 worry indices) so the gender-category coefficients are visible.
 - tab/thsj_rr/r2_worry_coefs_table.txt -- compact esttab dump of the gender_cat
   coefficients only, ready to paste/parse.

This is a READ-ONLY helper -- does not save back any modified .dta files.
*******************************************************************************/

version 17.0
set more off
set varabbrev off

cd "/home/research/ca_ed_lab/projects/csac_survey2023"
global csacprojdir "/home/research/ca_ed_lab/projects/csac_survey2023"

cap log close _all
log using "$csacprojdir/log/thsj_rr/r2_worry_coefs.txt", text replace

* Load data with constructs (same dataset as r2_revisions.do)
use "$csacprojdir/dta/cln/csac_hs_senior_2023_genderso_constructs.dta", clear

* Standardize the 4 outcomes -- mirrors r2_revisions.do's naming convention
* exactly: Section 2 creates `hsexp_z` (NOT `hsexp_index_z`), Section 3 creates
* `worry_index{1,2,3}_z`. Reproducing that naming so the M3 specs below match
* the ones used to generate the published figures.

* (1) hsexp_index -> hsexp_z  (special-cased to match r2_revisions.do Section 2)
qui summarize hsexp_index if !mi(gender_cat)
cap drop hsexp_z
gen hsexp_z = (hsexp_index - r(mean)) / r(sd) if !mi(gender_cat)
di "Standardized hsexp_index -> hsexp_z: mean = " %6.3f r(mean) ", SD = " %6.3f r(sd)

* (2-4) worry_index{1,2,3} -> worry_index{1,2,3}_z
foreach y of varlist worry_index1 worry_index2 worry_index3 {
    qui summarize `y' if !mi(gender_cat)
    cap drop `y'_z
    gen `y'_z = (`y' - r(mean)) / r(sd) if !mi(gender_cat)
    di "Standardized `y' -> `y'_z: mean = " %6.3f r(mean) ", SD = " %6.3f r(sd)
}

* Noisily print M1 + M3 for each worry index
foreach y in worry_index1 worry_index2 worry_index3 {
    di _newline(2) "===================================================="
    di "OUTCOME: `y'_z   (label: `:var label `y'')"
    di "===================================================="

    di _newline "--- M1 (unconditional): reg `y'_z i.gender_cat ---"
    reg `y'_z i.gender_cat
    eststo `y'_m1

    di _newline "--- M3 (with controls): reg `y'_z i.gender_cat c.hsexp_z i.race_assn i.parent_edu ---"
    reg `y'_z i.gender_cat c.hsexp_z i.race_assn i.parent_edu
    eststo `y'_m3
}

* Compact dump of just the gender_cat coefficients across all 6 models
esttab worry_index1_m1 worry_index1_m3 worry_index2_m1 worry_index2_m3 worry_index3_m1 worry_index3_m3 ///
    using "$csacprojdir/tab/thsj_rr/r2_worry_coefs_table.txt", ///
    keep(*.gender_cat) ///
    b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    mtitles("worry1 M1" "worry1 M3" "worry2 M1" "worry2 M3" "worry3 M1" "worry3 M3") ///
    label nonum nogaps replace

di _newline(2) "===================================================="
di "DONE."
di "  Log:   log/thsj_rr/r2_worry_coefs.txt"
di "  Table: tab/thsj_rr/r2_worry_coefs_table.txt"
di "===================================================="

log close
