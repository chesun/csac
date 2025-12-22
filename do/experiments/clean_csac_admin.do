/* clean CSAC admin variables */

/* usage:
do $csacprojdir/do/experiments/clean_csac_admin.do

 */


cap log close _all
log using $csacprojdir/log/experiments/clean_csac_admin.txt, text replace

use $csacprojdir/dta/cln/csac_survey_ccc_merged.dta, clear

// high school GPA
destring stdt_gpa, replace 
rename stdt_gpa hs_gpa
lab var hs_gpa "High School GPA (0-4)"

// student adjusted gross income
destring stdt_agi, replace 
rename stdt_agi student_inc
lab var student_inc "Student adjusted gross income"

// parent adjusted income 
destring par_agi, replace 
rename par_agi parent_inc 
lab var parent_inc "parent adjusted gross income"

// derived income and assets
destring derived_income derived_assets, replace 
lab var derived_income "CSAC derived income"
lab var derived_assets "CSAC derived assets"

********** categorical income variables 
foreach var in student_inc parent_inc derived_income derived_assets {
    gen `var'_cat = .
    replace `var'_cat = 99 if mi(`var')
    replace `var'_cat = 1 if `var' <  -1000000 & !mi(`var')
    replace `var'_cat = 2 if `var' >= -1000000 & `var' < -500000 & !mi(`var')
    replace `var'_cat = 3 if `var' >= -500000 & `var' < -300000 & !mi(`var')
    replace `var'_cat = 4 if `var' >= -300000 & `var' < -100000 & !mi(`var')
    replace `var'_cat = 5 if `var' >= -100000 & `var' < -75000 & !mi(`var')
    replace `var'_cat = 6 if `var' >= -75000 & `var' < -50000 & !mi(`var')
    replace `var'_cat = 7 if `var' >= -50000 & `var' < -25000 & !mi(`var')
    replace `var'_cat = 8 if `var' >= -25000 & `var' < 0 & !mi(`var')
    replace `var'_cat = 9 if `var' >= 0 & `var' < 25000 & !mi(`var')
    replace `var'_cat = 10 if `var' >= 25000 & `var' < 50000 & !mi(`var')
    replace `var'_cat = 11 if `var' >= 50000 & `var' < 75000 & !mi(`var')
    replace `var'_cat = 12 if `var' >= 75000 & `var' < 100000 & !mi(`var')
    replace `var'_cat = 13 if `var' >= 100000 & `var' < 300000 & !mi(`var')
    replace `var'_cat = 14 if `var' >= 300000 & `var' < 500000 & !mi(`var')
    replace `var'_cat = 15 if `var' >= 500000 & `var' < 1000000 & !mi(`var')
    replace `var'_cat = 16 if `var' >= 1000000 & !mi(`var')

    lab def `var'_cat 1 "< -1M" 2 "-1M to -500K" 3 "-500K to -300K" 4 "-300K to -100K" ///
        5 "-100K to -75K" 6 "-75K to -50K" 7 "-50K to -25K" 8 "-25K to 0" ///
        9 "0 to 25K" 10 "25K to 50K" 11 "50K to 75K" 12 "75K to 100K" ///
        13 "100K to 300K" 14 "300K to 500K" 15 "500K to 1M" ///
        16 ">1M" 99 "Missing"
    lab val `var'_cat `var'_cat
}


// family size
destring family_size, replace 
lab var family_size "Family size"

// expected family contribution 
destring efc, replace 
lab var efc "Expected family contribution"

gen efc_cat = .
replace efc_cat = 99 if mi(efc)
replace efc_cat = 1 if inrange(efc, 0, 25000)
replace efc_cat = 2 if inrange(efc, 25000, 50000)
replace efc_cat = 3 if inrange(efc, 50000, 75000)
replace efc_cat = 4 if inrange(efc, 75000, 100000)
replace efc_cat = 5 if inrange(efc, 100000, 300000)
replace efc_cat = 6 if inrange(efc, 300000, 500000)
replace efc_cat = 7 if efc > 500000 & !mi(efc)

lab def efc_cat 1 "0-25k" 2 "25k-50k" 3 "50k-75k" 4 "75k-100k" ///
    5 "100k-300k" 6 "300k-500k" 7 ">500k" 99 "Missing"

lab val efc_cat efc_cat

// calgrant
foreach g in cga cgb cgc {
    destring `g'_awd_status, replace 
    gen `g'_cat = 0
    replace `g'_cat = 1 if inlist(`g'_awd_status, 45, 50)
    lab def `g'_cat 0 "Missing, Ineligible or withdrawn" 1 "Qualified/Accepted"
    lab val `g'_cat `g'_cat
    lab var `g'_cat "cal grant `g' status"
}

// marital status 
destring sfc_mar_stat_code pfc_mar_stat_code, replace 
rename sfc_mar_stat_code student_marital
rename pfc_mar_stat_code parent_marital
lab var student_marital "student marital status"
lab var parent_marital "parent marital status"
replace student_marital = 99 if mi(student_marital)
replace parent_marital = 99 if mi(parent_marital)

lab def student_marital 1 "Single" 2 "Married/remarried" 3 "Separated" 4 "Divorced or widowed" 99 "Missing"
lab def parent_marital 1 "Married/remarried" 2 "Never married" 3 "Divorced/separated" ///
    4 "Widowed" 5 "Unmarried and both parents living together" 99 "Missing"

lab val student_marital student_marital
lab val parent_marital parent_marital

// first generation: parents did not attend college
gen first_gen = .
replace first_gen = inlist(parent_edu, 1, 2) if !mi(parent_edu)
lab var first_gen "First-Gen College Student"

save $csacprojdir/dta/cln/csac_survey_ccc_merged_clean.dta, replace 



log close 