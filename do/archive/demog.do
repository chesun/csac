/******************************************************************************
PROGRAM: Ways to Categorize Race/Ethnicity, Gender, and Sexual Orientation
using Cleaned 2023 CSAC HS Senior Survey

WRITTEN BY: Baiyu Zhou (baizhou@ucdavis.edu)

DATE CREATED: July 25, 2023
*******************************************************************************/


********************************* Preamble ************************************
*----------*
* Toggle
*----------*
* Place Holder

*----------*
* Settings
*----------*
* Set settings
version 17.0
graph drop _all
set more off
set varabbrev off
*set graphics off
set scheme s1color
set seed 1984


* Set default directory // comment out if run the master do file
cd "/home/research/ca_ed_lab/projects/csac_survey2023"
global csacprojdir "/home/research/ca_ed_lab/projects/csac_survey2023"
global outtab "$csacprojdir/tab/learn/demog"

* Log results
cap log close
log using "$csacprojdir/log/learn/demog.txt", text replace

********************************* Main *****************************************

* Load fully cleaned data
use "$csacprojdir/dta/cln/csac_hs_senior_2023_clean.dta", clear

* Sample: HS senior
keep if senior == 1


*===================*
* Race/Ethnicity
*===================*

* Non-response
gen race_missing = .
label var race_missing "respondent skipped race/ethinicity questions"
replace race_missing = 0 if inrange(race,1,91)
replace race_missing = 1 if race == .
//validate
assert race_missing == 1 if !inrange(race,1,91)


*----------------------------------------------------------------------------*
* All-inclusive: 1 if a race/ethinicity was selected. Not mutually exclusive 
*----------------------------------------------------------------------------*

* Generate a string version of race to do text search
decode race, gen(race_str) 

* Selected Black/African American
gen race_black = 0 if !race_missing // set default to 0 if not missing
replace race_black = 1 if strpos(race_str, "Black/African American")!=0
label var race_black "selected 'Black/African American'"

* Selected American Indian/Alaskan Native
gen race_native= 0 if race_missing == 0 // set default to 0
replace race_native = 1 if strpos(race_str, "American Indian/Alaskan Native")!=0
label var race_native "selected 'American Indian/Alaskan Native'"

* Selected Asian
gen race_asian = 0 if race_missing == 0 // set default to 0
replace race_asian= 1 if strpos(race_str, "Asian")!=0
label var race_asian "selected 'Asian'"

* Selected Filipino 
gen race_flip = 0 if race_missing == 0 // set default to 0
replace race_flip = 1 if strpos(race_str, "Filipino")!=0
label var race_flip "selected 'Filipino'"

* Selected Hispanic/Latinx
gen race_hisp= 0 if race_missing == 0 // set default to 0
replace race_hisp = 1 if strpos(race_str, "Hispanic/Latinx")!=0
label var race_hisp "selected 'Hispanic/Latinx'"

* Selected Pacific Islander
gen race_pi= 0 if race_missing == 0 // set default to 0
replace race_pi = 1 if strpos(race_str, "Pacific Islander")!=0
label var race_pi "selected 'Pacific Islander'"

* Selected White/Non-Hispanic
gen race_white= 0 if race_missing == 0 // set default to 0
replace race_white = 1 if strpos(race_str, "White/Non-Hispanic")!=0
label var race_white "selected 'White/Non-Hispanic'"

* Selected Other
gen race_other= 0 if race_missing == 0 // set default to 0
replace race_other = 1 if strpos(race_str, "Other")!=0
label var race_other "selected 'Other'"


*---------------------------------------*
* Detailed: select all apply 
*---------------------------------------*

/* # of race/ethnic groups  */
egen race_num = rowtotal(race_black race_native race_asian race_flip race_hisp race_pi race_white race_other)
replace race_num = . if race == .
label var race_num "number of race/ethnicity selected" 
assert race_num == 1 if inrange(race, 1, 8)


* Created indicator for single, double, 3+
tab race_num, gen(race_n)

cap drop race_n3plus
egen race_n3plus = rowtotal(race_n3 race_n4 race_n5 race_n6) if race != .
label var race_n3plus "race_num >= 3"


*------------------------------------------------*
* Reduced: group two or more into one category
*------------------------------------------------*

/* Race 9: Mutually exclusive race using the 8 categories + 1 multi */
cap drop race9
gen race9 = .
label var race9 "race/ethnicity reduced to 9 categories"
replace race9 = race 	if race_num == 1
replace race9 = 9 	if inrange(race_num,2,8)
label copy race race9_lbl //, replace
label def race9_lbl 9 "Two or more", modify
label val race9 race9_lbl  


*-------------------------------------------*
* Print Tables: Google Doc Shareable Format
*-------------------------------------------*
ssc install asdoc, replace // use asdoc package

cd "$outtab" // change directory to use 

/* Reduced Race/Ethnicity [Common in reports] */
* Save as doc // asdoc doesn't sort one-way tabulate by frequency
qui asdoc tab race9, save(tab_race9.doc) replace

* Print in log
tab race9, sort


/* All-inclusive */
* Save as doc
qui asdoc tabstat race_missing race_n1 race_n2 race_n3plus race_black race_native race_asian race_flip race_hisp race_pi race_white race_other, stat(mean sum count) col(stat) save(tabstat_allrace.doc) replace

* Print in log
tabstat race_missing race_n1 race_n2 race_n3plus race_black race_native race_asian race_flip race_hisp race_pi race_white race_other, stat(mean sum count) col(stat)

/* Detailed Combiniation */

* Save as doc
qui bys race_num: asdoc tab race, sort save(tab_race.doc) replace

* Print in log
tab race if race_num == 1, sort
tab race if race_num == 2, sort
tab race if race_num >= 3, sort



*=====================================*
* Gender, Sex, and Sexual Orientation
*=====================================*

*---------*
* Gender  *
*---------*
gen gender_missing = 1 if gender_clean == ""
replace gender_missing = 0 if gender_clean != ""
label var gender_missing "respondent skipped gender-identity question"

/* Gender is diverse */
* Save to doc
qui asdoc tab gender_clean asab, save(xtab_genderasab.doc) replace

* print in log
tab gender_clean asab

/* Mutually exclusive 3-category gender-sex combination */
gen genderasab = .
label var genderasab "gender-sex at birth"
replace genderasab = 0 if gender_cis == 1
replace genderasab = 1 if gender_trans_gnc == 1
replace genderasab = 2 if gender_cis == 0 & gender_trans_gnc == 0 // unsure & not to say
assert genderasab == . if gender_clean == ""

label def genderasab_lbl 0 "same" 1 "different" 2 "gender unsure"
label val genderasab genderasab_lbl

tab genderasab

/* Reduce into broader category */
* Indicator for non-binary/other gender identity (exclude unsure/prefer not to say)
gen gender_other = .
label var gender_other "gender nonbinary, fluid, nonconforming"
replace gender_other = 0 if gender_missing == 0
replace gender_other = 1 if gender_clean == "GENDERFLUID" | gender_clean == "NONBINARY" | gender_clean == "OTHERGNC" 
assert gender_other == . if gender_clean == ""

* Indicator for unsure/prefer not to say
gen gender_unsure = .
label var gender_unsure "gender unsure/prefer not to say"
replace gender_unsure = 0 if gender_man == 1 | gender_woman == 1 | gender_other == 1
replace gender_unsure = 1 if gender_clean == "PREFER NOT TO SAY" | gender_clean == "UNSURE/QUESTIONING"
assert gender_other == . if gender_clean == ""

* Mutually exclusive 4-category gender variable: Man Woman Nonbinary/Other Unsure
assert gender_man + gender_woman + gender_other + gender_unsure == 1 if gender_missing == 0

gen gender4 = .
label var gender4 "gender identity in 4 categories"
replace gender4 = 0 if gender_man == 1
replace gender4 = 1 if gender_woman == 1
replace gender4 = 2 if gender_other == 1
replace gender4 = 3 if gender_unsure == 1
assert gender4 == . if gender_clean == ""

label def gender4_lbl 0 "man" 1 "woman" 2 "non-binary/other" 3 "unsure"
label val gender4 gender4_lbl
tab gender4 

* ender-identity by if agree with sex
asdoc tab gender4 genderasab, save(xtab_gigs.doc) replace


*--------------------*
* Sexual Orientation *
*--------------------*
gen so_missing = 1 if so_clean == ""
replace so_missing = 0 if so_clean != ""
label var so_missing "respondent skipped sexual orientation question"

gen so_unsure = 0 if so_missing == 0
replace so_unsure = 1 if so_clean == "PREFER NOT TO SAY" | so_clean == "UNSURE/QUESTIONING"

* Mutually exclusive so: 
assert so_unsure + so_queer_narrow + so_straight == 1 if so_missing == 0



*-----------------------------*
* Gender x Sexual Orientation *
*-----------------------------*
* Detailed 
asdoc tab so_clean gender_clean, save(xtab_genderso.doc) replace
* tab so_clean gender4

* Broad 
asdoc tab so_straight gender4, save(xtab_genderso_broad) replace 

*---------*
* LGBTQ+  *
*---------*

/* Overall LGBTQ */
gen lgbtq = .
replace lgbtq = 0 if gender_cis == 1 & so_straight == 1 // non-LGBTQ+ if cis & straight
replace lgbtq = 1 if gender_cis == 0 | so_straight == 0 // LGBTQ+ if non-cis or not straight
label var lgbtq "LGBTQ+"


*--------------------------------------------*
* Print Overall Gender/SO Minority
*--------------------------------------------*
asdoc tabstat gender_missing so_missing gender_trans_gnc gender_unsure so_queer_narrow so_unsure lgbtq, stat(mean sum count) col(stat) save(tabstat_genderso) replace 



********************************* End Main ************************************

log close

