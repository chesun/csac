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
bysort idunique: egen num_indiv_matched = sum(uniquetag)



merge m:m college_id student_id using $csacprojdir/dta/raw/ccc_student_2023.dta, gen(ccc_merge) keep(1 3)

save $csacprojdir/dta/cln/csac_survey_ccc_merged_namedob.dta, replace 

