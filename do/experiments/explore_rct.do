/* explore the RCT results  */


/* 
do $csacprojdir/do/experiments/explore_rct.do
 */
cap log close _all
log using $csacprojdir/log/experiments/explore_rct.txt, text replace

use $csacclndatadir/rct_collapsed_individual.dta, clear  

// observations for the summer school rct
count if !mi(treat_summer) & !mi(sum23enr)

// observations for the fall enrollment 
count if !mi(treat_summer) & !mi(treat_calgrant) & !mi(fall23enr)

/* // observations for the finaid receipt
count if !mi(treat_summer) & !mi(treat_calgrant)  */

//----------- summer school 2023
preserve 
drop if mi(treat_summer)
di "Enrolled in summer school 2023"
bysort treat_summer: sum sum23enr


di "units enrolled in summer 2023"
bysort treat_summer: sum sum23units_att

di "units earned in summer 2023"
bysort treat_summer: sum sum23units_earn
ttest sum23units_earn, by(treat_summer)

di "summer 2023 GPA"
bysort treat_summer: sum sum23gpa


//--------- cal grant 
restore, preserve 
drop if mi(treat_calgrant)


// fall enrollment, units, GPA

di "fall 2023 enrolled"
bysort treat_calgrant: sum fall23enr

di "fall 2023 units enrolled"
bysort treat_calgrant: sum fall23units_att

di "fall 2023 units earned"
bysort treat_calgrant: sum fall23units_earn

di "fall 2023 GPA"
bysort treat_calgrant: sum fall23gpa

// financial aid receipt
di "fall 2023 CGB receipt"
bysort treat_calgrant: sum cgb23_f

di "fall 2923 SSCG receipt"
bysort treat_calgrant: sum sscg23_f

di "2023 year CGB receipt"
bysort treat_calgrant: sum cgb23

di "2023 year SSCG receipt"
bysort treat_calgrant: sum sscg23

log close 
