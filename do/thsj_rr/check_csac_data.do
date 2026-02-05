/* check the availability of CSAC admin data for LGBTQ students */



/* 
do $csacprojdir/do/thsj_rr/check_csac_data.do
 */

cap log close _all
log using $csacprojdir/log/thsj_rr/check_csac_data.txt, text replace 

* Load fully cleaned data
use "$csacprojdir/dta/cln/csac_hs_senior_2023_genderso.dta", clear

merge 1:1 id using  $csacprojdir/dta/cln/csac_admin, keep(1 3) gen(csac_merge)

gen gender_queer = .
replace gender_queer = 0 if inlist(gender_cat, 0, 1)
replace gender_queer = 1 if inrange(gender_cat, 2, 5)
replace gender_queer = 2 if gender_cat==6

lab def gender_queer 0 "Cisgender" 1 "Non-cisgender" 2 "Prefer not to say"
lab val gender_queer gender_queer

gen so_queer = .
replace so_queer = 0 if so_cat==0
replace so_queer = 1 if inrange(so_cat, 1, 4)
replace so_queer = 2 if so_cat==5

lab def so_queer 0 "Heterosexual" 1 "Non-heterosexual" 2 "Prefer not to say"
lab val so_queer so_queer

gen lgbtq = (gender_queer == 1 | so_queer == 1)


// check csac merge status 
tab csac_merge if so_queer==1 | gender_queer==1

// check csac variables missingness
    
mdesc nces_sch_code stdt_gpa derived_income derived_assets ///
    stdt_dep_stat_code pfc_mar_stat_code ///
    family_size efc stdt_ca_res_flag us_ctzn_elig_nonctzn if so_queer==1 | gender_queer == 1

// check who are missing these variables
tab gender_cat if mi(derived_income) & lgbtq==1
tab so_cat if mi(derived_income) & lgbtq==1

tab gender_cat if  mi(stdt_gpa) & lgbtq==1

local csacvars  nces_sch_code stdt_gpa derived_income derived_assets stdt_dep_stat_code pfc_mar_stat_code family_size efc stdt_ca_res_flag us_ctzn_elig_nonctzn

foreach var of local csacvars {
    di "missing `var'"
    tab gender_cat if mi(`var') & lgbtq==1
}


log close 