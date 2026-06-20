/* create summary statistics tables  */


/* 
do $csacprojdir/do/experiments/sum_stats.do
 */
cap log close _all
set graphics off 
log using $csacprojdir/log/experiments/sum_stats.txt, text replace

local figdir $csacprojdir/fig/experiments
local tabdir $csacprojdir/tab/experiments

use $csacprojdir/dta/cln/csac_survey_ccc_merged_clean.dta, clear  


keep if !mi(treat_summer)

// race variables
gen black = .
replace black = (race_simp == 1) if !mi(race_simp)
lab var black "Black"

gen asian_filipino = .
replace asian_filipino = inlist(race_simp, 3, 4)  if !mi(race_simp)
lab var asian_filipino "Asian/Filipino"

gen hispanic = .
replace hispanic = (race_simp == 5) if !mi(race_simp)
lab var hispanic "Hispanic"

gen white = .
replace white = (race_simp == 7) if !mi(race_simp)
lab var white "White"

gen tworaces = .
replace tworaces = (race_simp == 9) if !mi(race_simp)
lab var tworaces "Two or More Races"

// gender
lab var gender_woman "Woman"
lab var gender_man "Man"

// LGBTQ
gen is_lgbtq = .
replace is_lgbtq = (lgbtq == 1) if !mi(lgbtq)
lab var is_lgbtq "LGBTQ+"

// HS type
gen hs_public = .
replace hs_public = (hs_type == 1) & !mi(hs_type)
lab var hs_public "Public High School"

gen hs_private = .
replace hs_private = (hs_type == 2) & !mi(hs_type)
lab var hs_private "Private High School"

gen hs_home = .
replace hs_home = (hs_type == 3) & !mi(hs_type)
lab var hs_home "Home School"

// parent edu
// first generation: parents did not attend college
// clean_csac_admin.do already creates & saves first_gen into the _clean
// dataset this file loads, so cap drop makes the re-derivation idempotent
// (avoids r(110) "already defined" in the full do_all.do run).
cap drop first_gen
gen first_gen = .
replace first_gen = inlist(parent_edu, 1, 2) if !mi(parent_edu)
lab var first_gen "First-Gen College Student"

// derived income in thousands
gen derived_income_thousand = derived_income/1000
lab var derived_income_thousand "Derived Income (Thousands)"

// EFC in thousands
gen efc_thousand = efc/1000
lab var efc_thousand "Expected Family Contribution (Thousands)"

// parents married
gen parent_married = .
replace parent_married = (parent_marital == 1) & !mi(parent_marital)
lab var parent_married "Parents Married/Remarried"
// there are on 10 percent married, is strange


local covars black asian_filipino hispanic white tworaces gender_woman gender_man ///
     hs_public hs_private hs_home first_gen hs_gpa derived_income_thousand ///
    efc_thousand parent_married

di "local content: `covars'"

eststo m0: estpost tabstat `covars' if treat_summer == 0, ///
         stat(mean sd count) columns(statistics)  

eststo m1: estpost tabstat `covars' if treat_summer == 1, ///
         stat(mean sd count) columns(statistics)  


esttab m* using `tabdir'/sum_stats.tex, replace ///
        main(mean %8.3fc)  ///
        collabels(none) ///
        nonumbers unstack booktabs ///
        parentheses  ///
        mtitles("Control" "Treatment") ///
        label  noobs nostar scalars("N Observations") ///
        nonotes

esttab m* using `tabdir'/sum_stats.csv, replace ///
        main(mean %8.3fc)  ///
        collabels(none) ///
        nonumbers unstack ///
        parentheses  ///
        mtitles("Control" "Treatment") ///
        label  noobs nostar scalars("N Observations") ///
        nonotes
est clear 


log close