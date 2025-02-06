/******************************************************************************
PROGRAM: Gender/SO Paper
- How do students define/describe/express their identities?

WRITTEN BY: Baiyu Zhou (baizhou@ucdavis.edu)
DATE CREATED: Jan 23, 2024

*******************************************************************************/
* Set settings
version 17.0
graph drop _all
set more off
set varabbrev off
set graphics off
set scheme s1color
set seed 1984

* Set default directory // comment out if run the master do file
cd "/home/research/ca_ed_lab/projects/csac_survey2023"
global csacprojdir "/home/research/ca_ed_lab/projects/csac_survey2023"


* Create log
cap log close
log using "$csacprojdir/log/learn/expression.txt", text replace

* Load fully cleaned data
use "$csacprojdir/dta/cln/csac_hs_senior_2023_brief", clear

* Drop archives/duplicated categories
cap drop gender_clean
cap drop gender_missing
cap drop gender_cis
cap drop gender_woman
cap drop gender_man
cap drop gender_other
cap drop gender_unsure
cap drop gender_pnts
cap drop gender_brief
cap drop so_clean
cap drop so_missing
cap drop so_straight
cap drop so_queer
cap drop so_unsure
cap drop so_pnts
cap drop so_brief
cap drop agab

/* Tab of raw expressions */

*** Gender ***

* Fraction by listed options
tab gender_raw
tab asab
tab asab gender_raw

* Tab of "other - specify"
tab gender_other_raw


*** Sexual Orientation ***

* Fraction by listed options
tab so_raw

* Tab of "other - specify"
tab so_other_raw

*** Gender Identity X SO ***
tab so_raw gender_raw





/* Export Raw Expression to Excel*/

* Gender Other
preserve
keep gender_other_raw
drop if gender_other_raw == ""
export excel using "$csacprojdir//tab/learn/genderso/expression_raw.xls", sheet("gender_other") replace
restore

* SO Other
keep so_other_raw
drop if so_other_raw == ""
export excel using "$csacprojdir//tab/learn/genderso/expression_raw.xls", sheet("so_other")


log close

