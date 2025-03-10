/*  do helper file to create year and term from term_id when term_id is integer */

/* usage:

include $csacprojdir/do/experiments/int_gen_year_term.doh

 */

//---------------------------------------------------------
// clean term id, it is stored as an integer
tostring term_id, gen(term_id_str) format(%03.0f)
drop term_id
rename term_id_str term_id
lab var term_id "3-digit Year-Term ID (GI03)"

//-------------------- create year from term id
gen yeartemp = substr(term_id, 1, 2)
destring yeartemp, replace 
gen year =.
replace year = 2000 + yeartemp if yeartemp <30
replace year = 1900 + yeartemp if yeartemp >=30
drop yeartemp 

//------------------ create a term variable 
gen termtemp = substr(term_id, 3, 1)
gen term =.
forvalues n = 0/9 {
    replace term = `n' if termtemp == "`n'"
}

lab define term 0 "Annual" 1 "Winter Intersession" 2 "Winter Quarter" 3 "Spring Semester" 4 "Spring Quarter" 5 "Summer Term" 6 "Summer Quarter" 7 "Fall Semester" 8 "Fall Quarter" 9 "Fall First Census"
lab val term term 
drop termtemp 