/* demographics summary table for qual sample */

/* 
do $csacprojdir/do/thsj_rr/qual_demo_tab.do
 */

cap log close _all
log using $csacprojdir/log/thsj_rr/qual_demo_tab.txt, text replace 

use "$csacprojdir/dta/cln/csac_hs_senior_2023_genderso.dta", clear
// SO is the lowest common denominator for missing demographics - results in smaller sample size, so use that sample
gen qual_sample = 1 if inrange(gender_cat, 2, 5) & (!mi(college_challenge) | !mi(college_excited) ) & !mi(so_cat, race_assn, parent_edu)

asdoc tabulate gender_cat if qual_sample==1, nocf save($csacprojdir/tab/thsj_rr/qual_sample_demo.doc) replace title(Summary Statistics for Qualitative Response Sample)
foreach var in so_cat race_assn parent_edu {
    asdoc tabulate `var' if qual_sample==1, nocf save($csacprojdir/tab/thsj_rr/qual_sample_demo.doc) append
}


log close 