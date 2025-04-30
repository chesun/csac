/* create a ssn - college+student id xwalk */

/* First written by Christina Sun 01/30/2025 */

/* 
do $csacprojdir/do/experiments/clean_ccc.do
 */

cap log close _all
log using $csacprojdir/log/experiments/clean_ccc.txt, text replace

// ------------ create xwalk for student SSN to student ID + college id
use $cccrawdatadir/HF_FIRST.dta, clear

// student ssn uniquely identifies an individual, but some individual has multiple observations
// observations are uniquely identified by collegeid + studentid 
 
keep college_id student_id student_ssn

compress 
// this dataset has one observation per each instance of a student in a college
save $csacprojdir/dta/cln/ccc_ssn_id_xwalk.dta, replace 



//--------------- clean SX_yearcollapsed
use $cccclndatadir/SX_yearcollapsed, clear 
// check that dataset is at college-student-year level 
unique college_id student_id year 
// a student may attend more than 1 college in 1 year
keep if year == 2023
// get the student ssn
merge 1:1 college_id student_id using $csacprojdir/dta/cln/ccc_ssn_id_xwalk.dta, nogen keep(3)

unique student_ssn

// create summer enrollment flag  and fall enrollment flag
gen enr_su = (units_attempted_su > 0 & !mi(units_attempted_su)) 
gen enr_f = (units_attempted_f > 0 & !mi(units_attempted_f)) 

*** clean units and gpa
sum units_attempted_su if enr_su==1
sum units_attempted_f if enr_f==1

replace units_attempted_su = 0 if enr_su==0
replace units_su = 0 if enr_su == 0
replace units_attempted_f = 0 if enr_f == 0
replace units_f = 0 if enr_f==0

// make sure units earned is non missing if enrolled
mdesc units_su if enr_su==1
mdesc units_f if enr_f==1
assert !mi(units_su) if enr_su==1
assert !mi(units_f) if enr_f==1

// check if GPA is missing if enrolled and earned units: about 90000 obs has GPA missing but enrolled
mdesc sem_GPA_su if enr_su==1 & !mi(units_su)
sum units_su if mi(sem_GPA_su) & enr_su==1 
sum units_su if mi(sem_GPA_su) & enr_su==1 & units_su>0


// create a weighted GPA for each individual if enrolled in summer
gen su_weighted = sem_GPA_su * units_su if !missing(sem_GPA_su, units_su) & enr_su==1
gen f_weighted  = sem_GPA_f  * units_f  if !missing(sem_GPA_f, units_f) & enr_f==1 
replace su_weighted = 0 if (mi(sem_GPA_su) | mi(units_su)) & enr_su==1
replace f_weighted = 0 if (mi(sem_GPA_f) | mi(units_f)) & enr_f==1

// collapse down to individual level, taking total units and weighted average GPA
collapse (sum) su_weighted  f_weighted ///
    units_earn_su=units_su units_earn_f=units_f ///
    units_att_f = units_attempted_f units_att_su=units_attempted_su ///
    (max) enr_su enr_f, by(student_ssn)

gen gpa_su = su_weighted / units_earn_su if units_earn_su > 0
gen gpa_f  = f_weighted  / units_earn_f  if units_earn_f > 0


drop f_weighted su_weighted


lab var gpa_su "Weighted avg summer GPA"
lab var gpa_f  "Weighted avg fall GPA"

lab var enr_su "enrolled in summer"
lab var units_att_su "total summer units attempted"
lab var units_earn_su "total summer units earned"
lab var enr_f "enrolled in fall"
lab var units_att_f "total fall units attempted"
lab var units_earn_f "total fall units earned"

label data "SX_yearcollapsed one copy per individual in 2023"

save $csacprojdir/dta/cln/sx_2023_indiv_level.dta, replace 


//------------- clean SFA_Collapsed_year
use $cccclndatadir/SFA_Collapsed_year, clear 
unique college_id student_id

keep if year == 2023
// get student ssn 
merge 1:1 college_id student_id using $csacprojdir/dta/cln/ccc_ssn_id_xwalk.dta, nogen keep(3)
unique student_ssn
// these financial award receipts are all dummies 
sum cgb_f sscg_f cgb sscg 

// collapse down to individual level
collapse (max) cgb_f sscg_f cgb sscg, by(student_ssn)

lab var cgb_f "receive CGB at any college in the fall"
lab var sscg_f "receive SSCG at any college in the fall"
lab var cgb "receive CGB at any college in 2023"
lab var sscg "receive SSCG at any college in 2023"

lab data "SFA year collapsed 2023 data one copy per individual"

save $csacprojdir/dta/cln/sfa_2023_indiv_level.dta, replace 

log close 