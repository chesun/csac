/******************************************************************************
PROGRAM: GDTF Ad Hoc Reviewer Requests
GOAL: Address miscellaneous reviewer questions and requests

WRITTEN BY: Christina Sun (ucsun@ucdavis.edu)
DATE CREATED: Mar 16, 2026

To run this:
do $csacprojdir/do/getting_down_to_facts/gdtf_adhoc.do
*******************************************************************************/

local standalone 1

if `standalone' {
    version 17.0
    set more off
    set varabbrev off
    set graphics off
    set scheme s1color
    set seed 1984
    cd "/home/research/ca_ed_lab/projects/csac_survey2023"
    global csacprojdir "/home/research/ca_ed_lab/projects/csac_survey2023"
}

cap log close
log using "$csacprojdir/log/getting_down_to_facts/gdtf_adhoc.txt", text replace


*===============================================================================
* Load genderso dataset (college-bound students with gender/SO constructs)
*===============================================================================
use "$csacprojdir/dta/cln/csac_hs_senior_2023_genderso_constructs.dta", clear


*===============================================================================
* What percentage of students selected "Other" + write-in for gender and SO?
*===============================================================================

di _n "=============================================="
di "GENDER: Percentage selecting 'Other' with write-in"
di "=============================================="

* Respondents who answered the gender identity question
count if !mi(gender_raw) & gender_raw != ""
local N_gender_resp = r(N)

* Students who selected "Other" for gender (before any recoding)
count if gender_raw == "OTHER"
local N_gender_other = r(N)
local pct_gender_other : display %4.1f (`N_gender_other' / `N_gender_resp' * 100)

* Students who selected "Other" AND provided a write-in response
count if gender_raw == "OTHER" & !mi(gender_other_raw) & gender_other_raw != ""
local N_gender_writein = r(N)
local pct_gender_writein : display %4.1f (`N_gender_writein' / `N_gender_resp' * 100)

di "Responded to gender question: `N_gender_resp'"
di "Selected 'Other' for gender: `N_gender_other' (`pct_gender_other'%)"
di "Selected 'Other' AND wrote in: `N_gender_writein' (`pct_gender_writein'%)"
di ""

* Tabulate the write-in responses
di "Write-in responses for gender 'Other':"
tab gender_other_raw if gender_raw == "OTHER" & !mi(gender_other_raw) & gender_other_raw != "", sort


di _n "=============================================="
di "SEXUAL ORIENTATION: Percentage selecting 'Other' with write-in"
di "=============================================="

* Respondents who answered the sexual orientation question
count if !mi(so_raw) & so_raw != ""
local N_so_resp = r(N)

* Students who selected "Other" for SO (before any recoding)
count if so_raw == "OTHER (FEEL FREE TO SPECIFY)"
local N_so_other = r(N)
local pct_so_other : display %4.1f (`N_so_other' / `N_so_resp' * 100)

* Students who selected "Other" AND provided a write-in response
count if so_raw == "OTHER (FEEL FREE TO SPECIFY)" & !mi(so_other_raw) & so_other_raw != ""
local N_so_writein = r(N)
local pct_so_writein : display %4.1f (`N_so_writein' / `N_so_resp' * 100)

di "Responded to SO question: `N_so_resp'"
di "Selected 'Other' for sexual orientation: `N_so_other' (`pct_so_other'%)"
di "Selected 'Other' AND wrote in: `N_so_writein' (`pct_so_writein'%)"
di ""

* Tabulate the write-in responses
di "Write-in responses for SO 'Other':"
tab so_other_raw if so_raw == "OTHER (FEEL FREE TO SPECIFY)" & !mi(so_other_raw) & so_other_raw != "", sort


log close
