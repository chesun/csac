/******************************************************************************
PROGRAM: Gender/SO/LGBTQ supplemental analysis
- Create crosswalk with survey id & gender for Kairo

WRITTEN BY: Baiyu Zhou (baizhou@ucdavis.edu)

DATE CREATED: Oct 11, 2023

Note for catergorization under gender_brief: 
	binary trans - umbrella for trans man & trans woman (identified by opposite assigned sex at birth and current gender identity)
	other - umbrella term for nonbinary, noncomformoing, genderfluid, & other gender variants
	unsure - Chrisina identified as 'unsure' according to free text response if respondents chose other
	prefer not to say - respondents who chose the provided option 'prefer not to say' & respondents who answered assigned sex at birth but did not answer current gender identity

*******************************************************************************/


********************************* Preamble ************************************
*----------*
* Toggle
*----------*
local standalone 1 // Set to 1 if running this program for the first time
local do_plot 0

*----------*
* Settings
*----------*

if `standalone' == 1{

* Set default directory // comment out if run the master do file
cd "/home/research/ca_ed_lab/projects/csac_survey2023"
global csacprojdir "/home/research/ca_ed_lab/projects/csac_survey2023"

* Set settings
version 17.0
graph drop _all
set more off
set varabbrev off
set graphics off
set scheme s1color
set seed 1984
}

* Log results
cap log close
log using "$csacprojdir/log/clean/crosswalk_gender_minority.txt", text replace

********************************* Main *****************************************

* Load fully cleaned data
use "$csacprojdir/dta/cln/csac_hs_senior_2023_brief.dta", clear

/* Crosswalk with survey id & gender groups */

* Also keep raw gender & free response (if other)
* (maybe helpful to keep gender expression text & compare to experience expression text)
keep id gender_brief gender_other_raw gender_raw

* Keep binary trans and other gender variants
keep if inlist(gender_brief, 2, 3)


* save crosswalk into dta folder
save "$csacprojdir/dta/cln/crosswalk_gender_minority.dta" , replace

********************************* End Main ************************************

log close

