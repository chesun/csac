/* export qualitative question data */

/* 
do $csacprojdir/do/learn/qual_export.do
 */


use "$csacprojdir/dta/cln/csac_hs_senior_2023_genderso.dta", clear

export delimited ///
    id college_whynot college_excited college_challenge ///
    gender_cat so_cat race_assn parent_edu primary_english where_college ///
    if !mi(college_whynot) | !mi(college_excited) | !mi(college_challenge) ///
    using $csacprojdir/dta/open_response_lgbtq.csv, replace 