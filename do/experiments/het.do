/* RCT heterogeneity */


/* 
do $csacprojdir/do/experiments/het.do
 */
cap log close _all
set graphics off 
log using $csacprojdir/log/experiments/het.txt, text replace

local figdir $csacprojdir/fig/experiments

use $csacprojdir/dta/cln/csac_survey_ccc_merged_clean.dta, clear  


// create variables for sample cuts 

* 2year vs 4year 
gen where_college_2yr = .
replace where_college_2yr = (inlist(where_college, 1)) if !mi(where_college)
lab var where_college_2yr "CCC"

gen where_college_4yr = .
replace where_college_4yr = (inlist(where_college, 2,3,4)) if !mi(where_college)
lab var where_college_4yr "4-Year in CA"

* 2023-2024 EFC cutoff for Pell eligibility was 6656
gen pell_eligible = .
replace pell_eligible = (efc <= 6656) & !mi(efc)
lab var pell_eligible "Pell Eligible"

gen pell_ineligible = 1 - pell_eligible
lab var pell_ineligible "Pell Ineligible"

* baseline intention
gen base_su_plan = plan_summer_class+2
lab def base_su_plan 0 "Definitely Not" 1 "Probably Not" 2 "Not Sure" 3 "Probably Yes" 4 "Definitely Yes"
lab val base_su_plan base_su_plan

gen base_defyes = .
replace base_defyes = (plan_summer_class == 2) & !mi(plan_summer_class)

gen base_probyes = .
replace base_probyes = (plan_summer_class == 1) & !mi(plan_summer_class)

gen base_notsure = .
replace base_notsure = (plan_summer_class == 0) & !mi(plan_summer_class)

gen base_probno = .
replace base_probno = (plan_summer_class == -1) & !mi(plan_summer_class)

gen base_defno = .
replace base_defno = (plan_summer_class == -2) & !mi(plan_summer_class)

// a coarse category for baseline intentions
gen base_yes = (base_defyes == 1 | base_probyes == 1)
gen base_no = (base_defno == 1 | base_probno == 1)

gen cont_gen = 1- first_gen

// local for sample cuts
local het_vars where_college_2yr where_college_4yr pell_eligible pell_ineligible ///
    first_gen cont_gen ///
    gender_man gender_woman race_black race_white race_hisp race_asian ///
    base_no base_notsure base_yes



reg enr_su i.treat_summer 
estimates store all 

foreach v of local het_vars {
    reg enr_su i.treat_summer  if `v'==1
    estimates store `v'
}

coefplot (all, aseq("Full Sample")) ///
    (where_college_2yr, aseq("2-Year")) ///
    (where_college_4yr, aseq("4-Year")) ///
    (pell_eligible, aseq("Pell Eligible")) ///
    (pell_ineligible, aseq("Pell Ineligible")) ///
    (first_gen,  aseq("First-Gen")) ///
    (cont_gen, aseq("Continuing-Gen")) ///
    (base_no, aseq("Baseline: No")) ///
    (base_notsure, aseq("Baseline: Not Sure")) ///
    (base_yes, aseq("Baseline: Yes")) ///
    (gender_man, aseq("Man")) ///
    (gender_woman, aseq("Woman")) ///
    (race_black, aseq("Black")) ///
    (race_white, aseq("White")) ///
    (race_hisp, aseq("Hispanic")) ///
    (race_asian, aseq("Asian")) ///
    , keep(1.treat_summer) vertical ciopts(recast(rcap) lcolor(gray)) yline(0) ///
    xlabel(, angle(vertical)) swapnames legend(off) ///
    mcolor(black) 
graph export `figdir'/het_coef.png, replace 
graph export `figdir'/het_coef.eps, replace 


log close 
