/* construct dataset with survey data and CSAC admin data */

/* First written by Christina Sun 01/30/2025 */

/* 
do $csacprojdir/do/experiments/make_csac_data.do
 */

cap log close _all
log using $csacprojdir/log/experiments/make_csac_data.txt, text replace

// import Jaime's dataset with CSAC admin data merged on 
use $csacprojdir/dta/cln/csac_hs_senior_2023_brief_admin.dta, clear 
// keep only matched records
keep if _mergexwalk == 3
// csac admin data with qualtrics response id
keep idunique -  id 
drop if mi(idunique)

save $csacprojdir/dta/cln/csac_admin, replace 





log close 