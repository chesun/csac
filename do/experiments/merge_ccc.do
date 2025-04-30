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
merge 1:1 idunique using $csacprojdir/dta/cln/ccc_xwalk_winnie.dta, keep(3) nogen 

drop incc 

// merge to individual level sx data
merge 1:1 student_ssn using $csacprojdir/dta/cln/sx_2023_indiv_level.dta, gen(sx_merge) keep(1 3)

// merge to individual level sfa data
merge 1:1 student_ssn using $csacprojdir/dta/cln/sfa_2023_indiv_level.dta, gen(sfa_merge) keep(1 3)

tab where_college sx_merge
tab where_college sfa_merge
tab sx_merge sfa_merge

lab data "survey data merged to CCC credits, GPA, and SF Awards, only unique individual matches kept"
save $csacprojdir/dta/cln/csac_survey_ccc_merged.dta, replace 

