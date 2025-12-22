/* final version of regression results */

/* 
do $csacprojdir/do/experiments/reg_share.do
 */

cap log close _all
set graphics off 
log using $csacprojdir/log/experiments/reg_share.txt, text replace

local figdir $csacprojdir/fig/experiments

use $csacprojdir/dta/cln/csac_survey_ccc_merged_clean.dta, clear  

local controls i.race_simp i.gender_brief i.hs_type i.primary_english ///
     i.parent_edu derived_income hs_gpa efc

/* balance test of demographics */

di "balance test"


reg treat_summer `controls', robust


/* HS GPA and baseline intention descriptives */
gen base_no = .
replace base_no = (plan_summer_class == -2 | plan_summer_class == -1) & !mi(plan_summer_class)

gen base_notsure = .
replace base_notsure = (plan_summer_class == 0) & !mi(plan_summer_class)

gen base_yes = .
replace base_yes = (plan_summer_class == 1 | plan_summer_class == 2) & !mi(plan_summer_class)

tabstat hs_gpa base_*, by(treat_summer)


/* results for summer school intentions */

//----------- summer school 2023
preserve 
mdesc treat_summer
drop if mi(treat_summer)

// pre/post summer intention questions in long form
expand 2 if treat_summer==1, generate(post_treat_summer)
lab def post_treat_summer 0 "Pre" 1 "Post"
lab val post_treat_summer post_treat_summer
gen summer_question = plan_summer_class if post_treat_summer==0
replace summer_question = likely_summer_class if post_treat_summer==1


gen plan_no = .
replace plan_no = (summer_question == -2 | summer_question == -1) & !mi(summer_question)

gen plan_notsure = .
replace plan_notsure = (summer_question == 0) & !mi(summer_question)

gen plan_yes = .
replace plan_yes = (summer_question == 1 | summer_question == 2) & !mi(summer_question)

reg plan_yes i.post_treat_summer, robust

tabstat plan_yes, by(post_treat_summer)

restore


/* regression results, with robust SE */

foreach v in enr_su units_att_su units_earn_su {

    di "mean of Y var for control group"

    sum `v' if treat_summer==0

    di "regression without controls"

    reg `v' i.treat_summer, robust 


    di "regression with controls"

    reg `v' i.treat_summer `controls', robust 
}

log close