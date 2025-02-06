/* clean CCC data */

/* First written by Christina Sun 01/30/2025 */

/* 
do $csacprojdir/do/experiments/clean_ccc.do
 */

cap log close _all
log using $csacprojdir/log/experiments/clean_ccc.txt, text replace
//---------------------------------------------------
// CCC

// get student data for 2023 and onwards
use "$cccrawdatadir/STTERM.dta" if inrange(term_id, 230, 250), clear 
save $csacprojdir/dta/raw/ccc_stterm_2023.dta, replace

 // merge dob from SBSTUDNT 
merge m:1 college_id student_id using "$cccrawdatadir/SBSTUDNT.dta", keep(1 3) keepusing(birthdate) nogen 

// get rid of leading and trailing blanks and collapse internal blanks in first and last name
replace name_first = ustrtrim(strtrim(stritrim(strupper(name_first))))
replace name_last = ustrtrim(strtrim(stritrim(strupper(name_last))))

// create new var in str# format, compress does not work to convert strL to str#
gen fname = name_first
gen lname = name_last

drop name_first name_last

rename fname name_first
rename lname name_last

gen dob_date = subinstr(birthdate, "00:00:00", "", .)
replace dob_date = strtrim(subinstr(dob_date, "-", "", .))

// distinguish from survey race var
rename race racestr
compress 

save $csacprojdir/dta/raw/ccc_student_2023.dta, replace 

keep name_first name_last dob_date college_id student_id 
collapse (firstnm) name_first name_last dob_date, by(college_id student_id)

compress 

// in this dataset collegeid + studentid does NOT uniquely identifies an individual
save $csacprojdir/dta/cln/ccc_name_id_xwalk.dta, replace 



// create xwalk for student SSN to student ID + college id
use $cccrawdatadir/HF_FIRST.dta, clear

// student ssn uniquely identifies an individual, but some individual has multiple observations
// observations are uniquely identified by collegeid + studentid 
merge 1:1 college_id student_id using $csacprojdir/dta/cln/ccc_name_id_xwalk.dta, keep(3) keepusing(dob_date name_first name_last) nogen 
 
keep college_id student_id student_ssn dob_date name_first name_last

compress 
// this dataset has one observation per each instance of a student in a college
save $csacprojdir/dta/cln/ccc_name_id_xwalk.dta, replace 

log close 