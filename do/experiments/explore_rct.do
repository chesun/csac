/* explore the RCT results  */


/* 
do $csacprojdir/do/experiments/explore_rct.do
 */
cap log close _all
log using $csacprojdir/log/experiments/explore_rct.txt, text replace

use $csacprojdir/dta/cln/csac_survey_ccc_merged.dta, clear  

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

log close 
