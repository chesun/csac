/* merge CCC student data to survey data */

/* 
do $csacprojdir/do/experiments/merge_ccc.do
 */
cap log close _all
log using $csacprojdir/log/experiments/merge_dob.txt, text replace



use $csacprojdir/dta/cln/csac_hs_senior_2023_brief_admin.dta, clear 
rename first_name name_first 
rename last_name name_last 
replace name_first = strtrim(stritrim(strupper(name_first)))
replace name_last = strtrim(stritrim(strupper(name_last)))
replace dob_date = strtrim(dob_date)
drop if mi(idunique)
drop _merge
// first name last name and birth date uniquely identifies observations in master data but not using
merge 1:m name_first name_last dob_date using $csacprojdir/dta/cln/ccc_name_id_xwalk.dta, keep(1 3) nogen 
// tag unique individuals, tag one obs per individual 
egen uniquetag = tag(student_ssn)
bysort idunique: egen num_indiv_matched = total(uniquetag)
tab num_indiv_matched
// keep only unique matches or non-matches 
drop if num_indiv_matched>1

// merge with the cleaned student-college-year level dataset, with calculated units and GPA info 
merge m:m college_id student_id using $cccclndatadir/SX_yearcollapsed, gen(sxyear_merge) keep(1 3)
tab where_college sxyear_merge


// merge with cleaned student financial award dataset
// drop the financial award variables from CSAC admin 
drop efc-su_sch 
merge m:1 college_id student_id year using $cccclndatadir/SFA_Collapsed_year, keep(1 3) gen(sfayear_merge)

tab sxyear_merge sfayear_merge 

lab data "survey data merged to CCC credits, GPA, and SF Awards, only unique individual matches kept"
save $csacprojdir/dta/cln/csac_survey_ccc_merged_namedob.dta, replace 

