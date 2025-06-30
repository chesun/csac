/* explore the RCT results  */


/* 
do $csacprojdir/do/experiments/explore_rct.do
 */
cap log close _all
set graphics off 
log using $csacprojdir/log/experiments/explore_rct.txt, text replace

local figdir $csacprojdir/fig/experiments

use $csacprojdir/dta/cln/csac_survey_ccc_merged_clean.dta, clear  

di "************* merge rates***************"
di "merged to enrollment data (SX)"
tab sx_merge

di "merged to financial awards data (SFA)"
tab sfa_merge

di "merge rate by college plan"
tab where_college sx_merge, row
tab where_college sfa_merge, row

di "merge success for both sx and sfa"
tab sx_merge sfa_merge, row 


local controls_svy i.race_simp i.gender_brief i.hs_type i.lgbtq i.primary_eng i.parent_edu
local controls_csac i.derived_income_cat hs_gpa i.efc_cat i.parent_marital 
local controls_all `controls_svy' `controls_csac'

//----------- summer school 2023
preserve 
mdesc treat_summer
drop if mi(treat_summer)
di "******************* summer school nudge*******************"

*** survey summer class questions
tab plan_summer_class
gen summer_likely_final = plan_summer_class
replace summer_likely_final =  likely_summer_class if treat_summer==1

bysort treat_summer: sum summer_likely_final

di "summer class plan question"
tab summer_likely_final treat_summer, chi2
ttest summer_likely_final, by(treat_summer)

// pre vs post for treatment group
expand 2 if treat_summer==1, generate(post_treat_summer)
lab def post_treat_summer 0 "Pre" 1 "Post"
lab val post_treat_summer post_treat_summer
gen summer_question = plan_summer_class if post_treat_summer==0
replace summer_question = likely_summer_class if post_treat_summer==1
di "chi2 test for pre-post question in treatment group"
tab summer_question post_treat_summer if treat_summer==1, chi2
di "Mann whitney U test for pre-post question in treatment group"
ranksum summer_question if treat_summer==1, by(post_treat_summer)

// plot post vs pre
twoway (hist summer_question if treat_summer==1 & post_treat_summer==0, freq color(blue%50)) ///
    (hist summer_question if treat_summer==1 & post_treat_summer==1, freq color(red%50)) ///
    , legend(label(1 "Pre") label(2 "Post") pos(6) row(1))
graph export `figdir'/summer_question_pre_post.png, replace 

restore, preserve 

di "Enrolled in summer school 2023"
bysort treat_summer: sum enr_su
ttest enr_su, by(treat_summer)

di "units enrolled in summer 2023"
bysort treat_summer: sum units_att_su
ttest units_att_su, by(treat_summer)

di "units earned in summer 2023"
bysort treat_summer: sum units_earn_su
ttest units_earn_su, by(treat_summer)

di "summer 2023 GPA"
bysort treat_summer: sum gpa_su
ttest gpa_su, by(treat_summer)




//--------- cal grant 
restore, preserve 
mdesc treat_calgrant
drop if mi(treat_calgrant)
// fall enrollment, units, GPA
di "***************** cal grant ********************"
di "fall 2023 enrolled"
bysort treat_calgrant: sum enr_f
ttest enr_f, by(treat_calgrant)

di "fall 2023 units enrolled"
bysort treat_calgrant: sum units_att_f
ttest units_att_f, by(treat_calgrant)

di "fall 2023 units earned"
bysort treat_calgrant: sum units_earn_f
ttest units_earn_f, by(treat_calgrant)

di "fall 2023 GPA"
bysort treat_calgrant: sum gpa_f
ttest gpa_f, by(treat_calgrant)

// financial aid receipt
di "fall 2023 CGB receipt"
bysort treat_calgrant: sum cgb_f
ttest cgb_f, by(treat_calgrant)

di "fall 2923 SSCG receipt"
bysort treat_calgrant: sum sscg_f
ttest sscg_f, by(treat_calgrant)

di "2023 year CGB receipt"
bysort treat_calgrant: sum cgb
ttest cgb, by(treat_calgrant)

di "2023 year SSCG receipt"
bysort treat_calgrant: sum sscg
ttest sscg, by(treat_calgrant)

gen units_att_f_15 = 0
replace units_att_f_15 = 1 if units_att_f>=15

gen units_earn_f_15 = 0
replace units_earn_f_15 = 1 if units_earn_f >=15

di "enrolled in 15 or more units in fall"
reg units_att_f_15 i.treat_calgrant `controls_all'

di "earned 15 or more units in fall"
reg units_earn_f_15 i.treat_calgrant `controls_all'


//----------------------------------------------------
// additional analyses

restore
drop if mi(treat_summer)


//--------------- Summer Nudge
*** S1. Treatment balance for summer plans
di "Summer nudge treatment balance: first question on summer plan"
tab plan_summer_class treat_summer, chi2 

*** S2. treatment balance for summer nudge: demographics
di "summer nudge treatment balance: demographics"
gen lgbtq_dummy = 0
replace lgbtq_dummy = 1 if lgbtq==1
tabstat race_simp gender_woman gender_man lgbtq_dummy primary_eng parent_edu hs_type, by(treat_summer) s(mean sd)

*** S2.1 treatment balance regressions
di "summer nudge treatment balance: regressing treatment on covariates"
reg treat_summer `controls_all'

di "treatment balance: bivariate regressions of treatment on controls"
foreach v of local controls_all {
    di "regressing summer treatment on `v' "
    reg treat_summer `v'
}

*** S3: Histogram for number of units enrolled in summer
hist units_att_su, width(0.25) by(treat_summer)
graph export `figdir'/hist_units_att_su.png, replace 

*** S4: effect of summer nudge on fall enrollment
di "summer nudge effect on fall enrollment"
bysort treat_summer: sum enr_f

*** S5: effect on fall units
di "summer nudge effect on fall units enrolled"
bysort treat_summer: sum units_att_f
ttest units_att_f, by(treat_summer)

di "summer nudge effect on fall units earned"
bysort treat_summer: sum units_earn_f
ttest units_earn_f, by(treat_summer)

*** S6: regressions on summer enrollment
lab define where_college 1 "CCC" 2 "CSU" 3 "UC" 4 "Private" 5 "Vocational" 6 "Outside", replace 



// sensitivity to demographic controls
di "summer enrollment: sensitivity to demographic controls"
reg enr_su i.treat_summer 

reg enr_su i.treat_summer `controls_all'

// heterogeneity by college plans 
gen ccc_vocation = 0
replace ccc_vocation = 1 if inlist(where_college, 1, 5)

di "summer enrollment: heterogeneity by college plan"
reg enr_su i.treat_summer##i.where_college 

reg enr_su i.treat_summer##i.where_college  `controls_all'

// separate regressions by college intention
forvalues i = 1/6 {
    labelbook where_college
    di "where college = `i'"
    reg enr_su i.treat_summer `controls_all' if where_college==`i'
}


forvalues i = 0/1 {
    di "ccc_vocation = `i'"
    reg enr_su i.treat_summer `controls_all' if ccc_vocation==`i'
}


// heterogeneity by baseline stated summer class intention
di "summer enrollment: heterogeneity by baseline summer class intention"
gen base_su_plan = plan_summer_class+2
lab def base_su_plan 0 "Definitely Not" 1 "Probably Not" 2 "Not Sure" 3 "Probably Yes" 4 "Definitely Yes"
lab val base_su_plan base_su_plan

reg enr_su i.treat_summer##i.base_su_plan
reg enr_su i.treat_summer##i.base_su_plan `controls_all'

*** S7: regressions on summer units enrolled
// sensitivity to demographic controls
di "summer units enrolled: sensitivity to demographic controls"
reg units_att_su i.treat_summer 

reg units_att_su i.treat_summer `controls_all'

// units enrolled conditional on enrolling
di "summer units enrolled conditional on enrolling"
reg units_att_su i.treat_summer if enr_su==1
reg units_att_su i.treat_summer `controls_all' if enr_su==1

// heterogeneity by college plans 
di "summer units enrolled: heterogeneity by college plan"
reg units_att_su i.treat_summer##i.where_college 
reg units_att_su i.treat_summer##i.where_college `controls_all'

di "separate regression for each baseline college intention"
forvalues i = 1/6 {
    labelbook where_college
    di "where college = `i'"
    reg units_att_su i.treat_summer `controls_all' if where_college==`i'
}


forvalues i = 0/1 {
    di "ccc_vocation = `i'"
    reg units_att_su i.treat_summer `controls_all' if ccc_vocation==`i'
}

di "full interactions between treatment and ccc/vocational"
reg units_att_su i.treat_summer##i.ccc_vocation `controls_all'

// heterogeneity by baseline stated summer class intention
di "summer units enrolled: heterogeneity by baseline summer class intention"

reg units_att_su i.treat_summer##i.base_su_plan
reg units_att_su i.treat_summer##i.base_su_plan `controls_all'


*** S8: regressions on summer units earned
// sensitivity to demographic controls
di "summer units enrolled: sensitivity to demographic controls"
reg units_earn_su i.treat_summer 
reg units_earn_su i.treat_summer `controls_all'

// units earned conditional on enrolling
di "summer units earned conditional on enrolling"
reg units_earn_su i.treat_summer if enr_su==1
reg units_earn_su i.treat_summer `controls_all' if enr_su==1


di "summer units enrolled: heterogeneity by college plan"
reg units_earn_su i.treat_summer##i.where_college 
reg units_earn_su i.treat_summer##i.where_college `controls_all'

di "separate regression for each baseline college intention"
forvalues i = 1/6 {
    labelbook where_college
    di "where college = `i'"
    reg units_earn_su i.treat_summer `controls_all' if where_college==`i'
}

forvalues i = 0/1 {
    di "ccc_vocation = `i'"
    reg units_earn_su i.treat_summer `controls_all' if ccc_vocation==`i'
}


// heterogeneity by baseline stated summer class intention
di "summer units earned: heterogeneity by baseline summer class intention"

reg units_earn_su i.treat_summer##i.base_su_plan
reg units_earn_su i.treat_summer##i.base_su_plan `controls_all'

log close 
