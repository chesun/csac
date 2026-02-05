/******************************************************************************
PROGRAM: Gender/SO Paper
GOAL: Prep data for gender paper
- Keep only college bound student
- Categorize gender and sexuality
     Reference meeting notes:
     https://docs.google.com/document/d/1FykKzpriJaFpczNqhGzwy1PWD7nZG997AbY5Sr5wZjc/edit
     https://docs.google.com/document/d/1coBVhwnTfx9hpFulsBI8N6F2AOaN0zNo4Fe_be2tKHw/edit
- Recode Segments to 2-year and 4-year schools
- Export cleaned dta-formatted data sets for quantitative analysis
- Export cleaned xls-formatted data sets with free responses, id, and demographics for qualitative analysis

WRITTEN BY: Baiyu Zhou (baizhou@ucdavis.edu)
DATE CREATED: Jan 29, 2024

02/05/2026 CS: edited gender and so labels for capitalization

To run this: 
do "/home/research/ca_ed_lab/projects/csac_survey2023/do/clean/genderso.do"
*******************************************************************************/
* Set settings
version 17.0
graph drop _all
set more off
set varabbrev off
set graphics off
set scheme s1color
set seed 1984

* Install package
ssc install codebookout /// to export codebook

* Set default directory // comment out if run the master do file
cd "/home/research/ca_ed_lab/projects/csac_survey2023"
global csacprojdir "/home/research/ca_ed_lab/projects/csac_survey2023"

* Create log
cap log close
log using "$csacprojdir/log/clean/genderso.txt", text replace

* Load fully cleaned data
use "$csacprojdir/dta/cln/csac_hs_senior_2023_brief", clear
*** Keep college bound students ***
keep if college_fall == 1

* Drop archives/duplicated/irelevant categories
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
cap drop lgbtq


* drop irrelevant variables
drop t_*
drop device_*


********************************
* Recode Segments by 2 or 4yrs *
********************************

gen segment = .
label var segment "plan to attend 2-yr or 4-yr schools this fall"
label def segment_lbl 0 "2-yr school" 1 "4-yr school", replace
label val segment segment_lbl

replace segment = 0 if inlist(where_college, 1,5)
replace segment = 1 if inlist(where_college, 2, 3, 4, 6)


****************************
* Create gender categories *
****************************
/*  Notes:
gender_cat 
= 0: cis man (asab == M & gender_raw == M)
= 1: cis woman (asab == F & gender_raw == W)
= 2: transgender (binary transgender, (asab == M & gender_raw == W) OR (asab == F & gender_raw == M)) 
= 3: gender diverse/nonbinary/questioning (including respondents who entered attack helicopter/irrelevant answers into the blank.)
= 4: prefer not to say (gender_raw == "PREFER NOT TO SAY")
*/


* Gen cleaned gender expression to store recoded "Other - specify"
gen gender_clean = gender_raw
label var gender_clean "cleaned gender expression"

* Manually recode "other - specify" 
*** MAN if MALE or HOMBRE
replace gender_clean = "MAN" if gender_raw == "OTHER" & gender_other_raw == "MALE"
replace gender_clean = "MAN" if gender_raw == "OTHER" & gender_other_raw == "MALE."
replace gender_clean = "MAN" if gender_raw == "OTHER" & gender_other_raw == "HOMBRE"

*** WOMAN if WOMAN or GIRL
replace gender_clean = "WOMAN" if gender_raw == "OTHER" & gender_other_raw == "I AM A STRAIGHT WOMAN"
replace gender_clean = "WOMAN" if gender_raw == "OTHER" & gender_other_raw == "GIRL"


*** Recode to missing if malicious/unserious/irrelevant
replace asab = "Male"                                   if strpos(gender_other_raw, "MEANT TO PUT MALE ON LAST QUESTION") !=0
replace gender_clean = "Malicious/unserious/irrelevant" if strpos(gender_other_raw, "MEANT TO PUT MALE ON LAST QUESTION") !=0
replace gender_clean = "Malicious/unserious/irrelevant" if strpos(gender_other_raw, "ATTACK HELICOPTER") !=0
replace gender_clean = "Malicious/unserious/irrelevant" if strpos(gender_other_raw, "BISEXUAL") !=0
replace gender_clean = "Malicious/unserious/irrelevant" if strpos(gender_other_raw, "HIM/ALPHA") !=0
replace gender_clean = "Malicious/unserious/irrelevant" if strpos(gender_other_raw, "I DON'T PLAY THAT STUPID STUFF") !=0
replace gender_clean = "Malicious/unserious/irrelevant" if strpos(gender_other_raw, "I WAS BORN A GIRL AND NO ONE CAN ") !=0
replace gender_clean = "Malicious/unserious/irrelevant" if strpos(gender_other_raw, "I'M A MAN MALE I DON'T BELIVE ") !=0
replace gender_clean = "Malicious/unserious/irrelevant" if strpos(gender_other_raw, "I’M A DUDE THIS IS A BULLSHIT") !=0
replace gender_clean = "Malicious/unserious/irrelevant" if strpos(gender_other_raw, "JEWISH") !=0
replace gender_clean = "Malicious/unserious/irrelevant" if strpos(gender_other_raw, "NIGGER KILLER 5000") !=0
replace gender_clean = "Malicious/unserious/irrelevant" if strpos(gender_other_raw, "NOT RELEVANT") !=0
replace gender_clean = "Malicious/unserious/irrelevant" if strpos(gender_other_raw, "ROCKET SHIP") !=0
replace gender_clean = "Malicious/unserious/irrelevant" if strpos(gender_other_raw, "THERE IS NO SUCH THING AS A") !=0
replace gender_clean = "Malicious/unserious/irrelevant" if strpos(gender_other_raw, "THIS SHOULD NOT BE A QUESTION") !=0
replace gender_clean = "Malicious/unserious/irrelevant" if strpos(gender_other_raw, "NO'); DROP TABLE RESPONSES;") !=0

* Generate new var to store gender category
gen gender_cat = . 
label var gender_cat "gender categories"

* Define gender categories value label
label define gender_cat_lbl 0 "Cisgender Man" 1 "Cisgender Woman" 2 "Transgender Man" 3 "Transgender Woman" 4 "Non-binary" 5 "Gender Diverse/Questioning" 6 "Prefer Not to Say", replace
label val gender_cat gender_cat_lbl

* Categorization - 
/* cis man */
replace gender_cat = 0 if gender_clean == "MAN" & asab == "Male"

/* =1 cis woman */
replace gender_cat = 1 if gender_clean == "WOMAN" & asab == "Female"

/* trans man */
replace gender_cat = 2 if gender_clean == "MAN" & asab == "Female"

/* trans woman */
replace gender_cat = 3 if gender_clean == "WOMAN" & asab == "Male"

/* nonbinary */
replace gender_cat = 4 if  gender_clean == "NONBINARY"

/* gender diverse/questioning */
replace gender_cat = 5 if  gender_clean == "OTHER"

/* prefer not to say */
replace gender_cat = 6 if gender_clean == "PREFER NOT TO SAY"

*** Check what's in Other/Questioning
di "Free responses recoded into 'gender diverse/questioning' "
tab gender_other_raw if gender_cat == 5



*******************************
* Create sexuality categories *
*******************************
/*  Notes:
so_cat 
= 0: Straight/Heterosexual 
= 1: Gay or lesbian
= 2: Bisexual/pansexual/omnisexual
= 3: Asexual/aromantic/demisexual
= 4: Other/queer/questioning (including respondents report more than one of the above categories, none of the above cateogries, attack helicopters, and irrelevant ansers)
= 5: prefer not to say 
*/

* Drop archived cleaned gender
cap drop so_clean

* Gen cleaned gender expression to store recoded "Other - specify" (string)
gen so_clean = so_raw
label var so_clean "cleaned sexual orientation"
replace so_clean = "BI/PAN/OMNISEXUAL" if so_raw == "BISEXUAL"
replace so_clean = "A/DEMISEXUAL/ROMANTIC" if so_raw == "ASEXUAL"
replace so_clean = "OTHER/QUEER/QUESTIONING" if so_raw == "OTHER (FEEL FREE TO SPECIFY)"

* Manually recode text response
/* STRAIGHT/HETERO */
replace so_clean = "STRAIGHT" if so_raw == "STRAIGHT (NOT GAY OR LESBIAN)"
replace so_clean = "STRAIGHT" if so_other_raw == "STRAIGHT"
replace so_clean = "STRAIGHT" if so_other_raw == "HETERO"
replace so_clean = "STRAIGHT" if so_other_raw == "HETEROSEXUAL"

/* BI/PAN/OMNI */
*** indicated BI but not others
replace so_clean = "BI/PAN/OMNISEXUAL" if so_other_raw == "BICURIOUS"
*** indicated PAN but not others
replace so_clean = "BI/PAN/OMNISEXUAL" if strpos(so_other_raw, "PAN")!=0 & strpos(so_other_raw, "DEMI")==0 & strpos(so_other_raw, "ASEX")==0 & strpos(so_other_raw, "AROM")==0 
*** indicated POLY but not others
replace so_clean = "BI/PAN/OMNISEXUAL" if strpos(so_other_raw, "POLY")!=0 & strpos(so_other_raw, "DEMI")==0 & strpos(so_other_raw, "ASEX")==0 & strpos(so_other_raw, "AROM")==0
*** indicated OMNI but not others
replace so_clean = "BI/PAN/OMNISEXUAL" if so_other_raw == "OMNISEXUAL"


/* A/DEMISEXUAL/ROMANTIC */
*** indicate ASEXUAL but not others
replace so_clean = "A/DEMISEXUAL/ROMANTIC" if strpos(so_other_raw, "ASEX")!=0 & strpos(so_other_raw, "BI")==0 & strpos(so_other_raw, "QUEER")==0 & strpos(so_other_raw, "OMNI")==0 & strpos(so_other_raw, "POLY")==0
*** indicate AROMANTIC but not others
replace so_clean = "A/DEMISEXUAL/ROMANTIC" if strpos(so_other_raw, "ARO")!=0 & strpos(so_other_raw, "BI")==0 & strpos(so_other_raw, "QUEER")==0 & strpos(so_other_raw, "OMNI")==0 & strpos(so_other_raw, "POLY")==0
*** indicate DEMI* but not others
replace so_clean = "A/DEMISEXUAL/ROMANTIC" if strpos(so_other_raw, "DEMI")!=0 & strpos(so_other_raw, "BI")==0 & strpos(so_other_raw, "PAN")==0 & strpos(so_other_raw, "OMNI")==0 & strpos(so_other_raw, "POLY")==0 

/* Malicious/unserious/irrelevant */
replace so_clean = "Malicious/unserious/irrelevant" if strpos(so_other_raw, "ATTRACTED TO CARS")!=0
replace so_clean = "Malicious/unserious/irrelevant" if strpos(so_other_raw, "BIG TITTY JEWS")!=0
replace so_clean = "Malicious/unserious/irrelevant" if strpos(so_other_raw, "I AM A MINOR. YOU SHOULD NOT BE ")!=0
replace so_clean = "Malicious/unserious/irrelevant" if strpos(so_other_raw, "MAN")!=0
replace so_clean = "Malicious/unserious/irrelevant" if strpos(so_other_raw, "MENTALLY ILL PEOPLE GOD WILL")!=0
replace so_clean = "Malicious/unserious/irrelevant" if strpos(so_other_raw, "MUJER")!=0
replace so_clean = "Malicious/unserious/irrelevant" if strpos(so_other_raw, "NOBODY’S BUSINESS BUT MINE.")!=0
replace so_clean = "Malicious/unserious/irrelevant" if strpos(so_other_raw, "NORMAL")!=0
replace so_clean = "Malicious/unserious/irrelevant" if strpos(so_other_raw, "THIS IS PRIVATE INFORMATION")!=0
replace so_clean = "Malicious/unserious/irrelevant" if strpos(so_other_raw, "THIS SHOULD NOT BE A QUESTION")!=0
replace so_clean = "Malicious/unserious/irrelevant" if strpos(so_other_raw, "TRANS FEMALE")!=0
replace so_clean = "Malicious/unserious/irrelevant" if strpos(so_other_raw, "WHY THE FUCK DOES THIS MATTER")!=0
replace so_clean = "Malicious/unserious/irrelevant" if strpos(so_other_raw, "WOW, NOT REALLY RELEVANT TO")!=0
replace so_clean = "Malicious/unserious/irrelevant" if strpos(so_other_raw, "NO'); DROP TABLE RESPONSES;")!=0
replace so_clean = "Malicious/unserious/irrelevant" if strpos(so_other_raw, "NOT RELEVANT")!=0


* Generate new var to store gender category
gen so_cat = . 
label var so_cat "sexual orientation categories"

* Define gender categories value label
label define so_cat_lbl 0 "Straight/Heterosexual " 1 "Gay or Lesbian" 2 "Bisexual/Pansexual/Omnisexual" 3 "Asexual/Aromantic/Demisexual" 4 "Other/Queer/Questioning" 5 "Prefer Not to Say", replace
label val so_cat so_cat_lbl

* Categorization (numeric)
replace so_cat = 0 if so_clean == "STRAIGHT"
replace so_cat = 1 if so_clean == "LESBIAN OR GAY"
replace so_cat = 2 if so_clean == "BI/PAN/OMNISEXUAL"
replace so_cat = 3 if so_clean == "A/DEMISEXUAL/ROMANTIC"
replace so_cat = 4 if so_clean == "OTHER/QUEER/QUESTIONING"
replace so_cat = 5 if so_clean == "PREFER NOT TO SAY"

*** Check what's in Other/queer/questioning
di "Free responses recoded into BI/PAN/OMNI"
tab so_other_raw if so_cat == 2
di "Free responses recoded into A/DEMISEXUAL/ROMANTIC"
tab so_other_raw if so_cat == 3
di "Free responses recoded into OTHER/QUEER/QUESTIONING"
tab so_other_raw if so_cat == 4




********************************
* Tab Expression *
********************************
tab gender_cat
tab so_cat
tab gender_cat so_cat, row col freq



**************************
* Save Cleaned Data sets *
**************************

/* Quantitative analysis */
*** Save Dataset
save "$csacprojdir/dta/cln/csac_hs_senior_2023_genderso.dta", replace

*** Create Codebook
codebookout "$csacprojdir/doc/genderso_codebook.xls", replace 





/* Qualitative analysis */
*** Keep trans and gender-diverse students
keep if inrange(gender_cat, 2, 5)

*** Keep obs answers open-ended questions about excitement and challenges
keep if college_excited != "" | college_challenge != ""

*** Restructure some variables to simplify data structure
rename race race_raw
replace primary_lang = "English" if primary_english == 1

*** Keep id, open responses, demographics (gender, so, race, parental edu, primary language at home)
keep id college_excited college_challenge gender_cat so_cat race_assn parent_edu primary_lang asab gender_raw gender_other_raw so_raw so_other_raw race_raw
order id college_excited college_challenge gender_cat so_cat race_assn parent_edu primary_lang asab gender_raw gender_other_raw so_raw so_other_raw race_raw

*** Save Cleaned datasets
save "$csacprojdir/dta/cln/csac_hs_senior_2023_genderso_qual.dta", replace

*** Export to Excel to Put Into Box
export excel using "$csacprojdir/tab/learn/genderso/qual.xls", first(var) sheet("non-cis") replace

*** Create Codebook
codebookout "$csacprojdir/doc/genderso_qual_codebook.xls", replace 

log close



* Export gender_other_raw for "OTHER" to export
use "$csacprojdir/dta/cln/csac_hs_senior_2023_genderso.dta", clear
keep if gender_cat == 5
keep gender_cat gender_other_raw
export excel using "$csacprojdir/tab/learn/genderso/gender_other_raw.xls", first(var) sheet("genderdiverse") replace