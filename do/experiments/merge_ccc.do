/* merge CCC student data to survey data */

/* 
do $csacprojdir/do/experiments/merge_ccc.do
 */
cap log close _all
log using $csacprojdir/log/experiments/merge_ccc.txt, text replace



use $csacprojdir/dta/cln/csac_hs_senior_2023_brief_admin.dta, clear
rename first_name name_first 
rename last_name name_last 
replace name_first = strtrim(stritrim(strupper(name_first)))
replace name_last = strtrim(stritrim(strupper(name_last)))
replace dob_date = strtrim(dob_date)
drop if mi(idunique)
drop _merge
//---------- clean the treatment indicators 
destring summer_nudge, gen(treat_summer)
destring ccc_ft_nudge, gen(treat_calgrant)
// merge to the winnie xwalk
merge 1:1 idunique using $csacprojdir/dta/cln/ccc_xwalk_winnie.dta, keep(1 3) gen(xwalk_merge) 

drop incc 

// create a subdataset with obs not merged to the xwalk
preserve 
keep if xwalk_merge == 1
save $csacprojdir/dta/cln/csac_survey_noxwalk.dta, replace 
restore 

keep if xwalk_merge == 3

// merge to individual level sx data
merge 1:1 student_ssn using $csacprojdir/dta/cln/sx_2023_indiv_level.dta, gen(sx_merge) keep(1 3)

// merge to individual level sfa data
merge 1:1 student_ssn using $csacprojdir/dta/cln/sfa_2023_indiv_level.dta, gen(sfa_merge) keep(1 3)

append using $csacprojdir/dta/cln/csac_survey_noxwalk.dta

lab def merge 0 "Survey Only" 1 "Merged"
foreach v in xwalk_merge sx_merge sfa_merge {
    replace `v' = 0 if mi(`v') | `v'==1
    replace `v' = 1 if `v' == 3
    lab val `v' merge 
}

tab where_college sx_merge
tab where_college sfa_merge
tab sx_merge sfa_merge

 

// convert missings to zeros in the survey data 
foreach var in enr_su  enr_f units_att_su units_att_f units_earn_f units_earn_su {
    replace `var' = 0 if mi(`var') 
}

lab data "survey data merged to CCC credits, GPA, and SF Awards, only unique individual matches kept"
save $csacprojdir/dta/cln/csac_survey_ccc_merged.dta, replace 

