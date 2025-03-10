/* analyze summer school RCT */

/* 
do $csacprojdir/do/experiments/make_rct_data.do
 */
cap log close _all
log using $csacprojdir/log/experiments/make_rct_data.txt, text replace

use $csacprojdir/dta/cln/csac_survey_ccc_merged_namedob.dta, clear 

//---------- clean the treatment indicators 
destring summer_nudge, gen(treat_summer)
destring ccc_ft_nudge, gen(treat_calgrant)


//---------------------------------------------------
// summer 2023 enrollment, units, gpa
//---------------------------------------------------

// flag for enrolled in 2023 summer
gen sum23enr = (units_attempted_su >0 & year ==2023)
assert sum23enr== 0  if sxyear_merge==1

// summer units enrolled
gen sum23units_att = units_attempted_su if year==2023

// summer units earned
gen sum23units_earn = units_su if year==2023

//summer GPA
gen sum23gpa = sem_GPA_su if year == 2023




//----------------------------------------------------
// fall 2023 enrollment, units, GPA
//---------------------------------------------------

// flag for enrolled in 2023 fall
gen fall23enr = (units_attempted_f>0 & year==2023)

// fall units enrolled
gen fall23units_att = units_attempted_f if year==2023

// fall units earned 
gen fall23units_earn = units_f if year ==2023

// fall GPA
gen fall23gpa = sem_GPA_f if year==2023 


//----------------------------------------------------
// financial aid receipt
//---------------------------------------------------

// fall 2023 cal grant B receipt
gen cgb23_f = cgb_f if year==2023 

// fall 2023 student success completion grant receipt
gen sscg23_f = sscg_f if year==2023 

// 2023 cal grant B receipt
gen cgb23 = cgb if year ==2023

// 2023 Student Success Completion Grant receipt
gen sscg23 = sscg if year == 2023 

// create merge indicators for merged to year 2023 
gen tempsx = (sxyear_merge==3 & year==2023)
gen tempsfa = (sfayear_merge==3 & year==2023)
bysort idunique: egen sx23_merged = max(tempsx)
bysort idunique: egen sfa23_merged = max(tempsfa)

// collapse down to individual level
collapse (firstnm) sum23* fall23* cgb23* sscg23* (mean) sx23_merged sfa23_merged treat_*, by(idunique)



save $csacclndatadir/rct_collapsed_individual.dta, replace 

log close 
