/******************************************************************************
PROGRAM: Gender/SO/LGBTQ supplemental analysis
- Combine gender and sexuality

WRITTEN BY: Baiyu Zhou (baizhou@ucdavis.edu)

DATE CREATED: Sep 26, 2023

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


* Log results
cap log close
log using "$csacprojdir/log/learn/supp_comb.txt", text replace

********************************* Main *****************************************

* Load fully cleaned data
use "$csacprojdir/dta/cln/csac_hs_senior_2023_brief.dta", clear
drop t_*
drop device_*

*===========================================*
* Define Gender/SO for supplemental analysis
*===========================================*

* Use the broad gender category: cis man, ciswoman, binary trans, other, unsure, not to say

tab gender_brief so_clean
cap drop lgbtq 
* Interact broad gender and broad so to created subcategories within LGBTQ
gen lgbtq = .
label var lgbtq "gender by so subcategories"

// =0, hetero cis woman as base category
replace lgbtq = 0 if gender_brief == 0 & so_clean == "STRAIGHT"
// =1 hetero cis man
replace lgbtq = 1 if gender_brief == 1 & so_clean == "STRAIGHT"
// =2 homo cis woman
replace lgbtq = 2 if gender_brief == 0 & so_clean == "LESBIAN OR GAY"
// =3 homo cis man 
replace lgbtq = 3 if gender_brief == 1 & so_clean == "LESBIAN OR GAY"
// =4 bi cis woman
replace lgbtq = 4 if gender_brief == 0 & so_clean == "BISEXUAL"
// =5 bi cis man 
replace lgbtq = 5 if gender_brief == 1 & so_clean == "BISEXUAL"
// =6 other so cis woman
replace lgbtq = 6 if gender_brief == 0 & inlist(so_clean,"ASEXUAL","PAN/QUEER")
// =7 other so cis man 
replace lgbtq = 7 if gender_brief == 1 & inlist(so_clean,"ASEXUAL","PAN/QUEER")
// =8 not to say/questioning so cis woman
replace lgbtq = 8 if gender_brief == 0 & inlist(so_clean,"PREFER NOT TO SAY","UNSURE/QUESTIONING")
// =9 not to say/questioning so cis man 
replace lgbtq = 9 if gender_brief == 1 & inlist(so_clean,"PREFER NOT TO SAY","UNSURE/QUESTIONING")
// =10 any so binary trans
replace lgbtq = 10 if gender_brief == 2
// =11 any so other gender variants
replace lgbtq = 11 if gender_brief == 3
// =12 any so gender unsure/prefer not to say
replace lgbtq = 12 if inlist(gender_brief,4,5)

label def lgbtq_lbl 0 "hetero cis woman" 		1 "hetero cis man" , replace
label def lgbtq_lbl 2 "lesbian cis woman" 		3 "gay cis man" , add
label def lgbtq_lbl 4 "bi cis woman" 			5 "bi cis man" , add
label def lgbtq_lbl 6 "a/pan/queer cis woman" 		7 "a/pan/queer cis man" , add
label def lgbtq_lbl 8 "unsure/not to say cis woman" 	9 "unsure/not to say cis man" , add
label def lgbtq_lbl 10 "binary trans, any so" , add
label def lgbtq_lbl 11 "other gender variants, any so" , add
label def lgbtq_lbl 12 "gender unsure/not to say, any so" , add

label val lgbtq lgbtq_lbl

*======================================================*
* Combined reason for bullying: only so, only gender, both
*======================================================*

gen reasons_bullied_comb = .
label var reasons_bullied_comb "being bullied because of gender or so"

replace reasons_bullied_comb = 1 if reasons_bullied_igender == 1 & reasons_bullied_iso == 0
replace reasons_bullied_comb = 2 if reasons_bullied_igender == 0 & reasons_bullied_iso == 1
replace reasons_bullied_comb = 3 if reasons_bullied_igender == 1 & reasons_bullied_iso == 1
replace reasons_bullied_comb = 4 if reasons_bullied_igender == 0 & reasons_bullied_iso == 0

cap label drop bullied_comb_lbl
label def bullied_comb_lbl 1 "only gender"
label def bullied_comb_lbl 2 "only sexual orientation", add
label def bullied_comb_lbl 3 "both gender and sexual orientation", add
label def bullied_comb_lbl 4 "other than gender or so", add

label val reasons_bullied_comb bullied_comb_lbl


*==================*
* Macros set up
*==================*


/* Global macros for crosstab variables */
* crosstab subgroups: Gender X SO cateogries 
global xtab lgbtq


/* Outcomes */

* hs experience & bullying 
global hsexp hs_academic hs_social hs_community_belong hs_teacher_care hs_good_advising hs_prepared_college hs_type times_bullied reasons_bullied_irace reasons_bullied_ireligion 

* reasons being bullied
global reasons reasons_bullied_igender reasons_bullied_iso reasons_bullied_comb

* college plans
global plans college_fall where_college major highest_degree prop_online_class

* non-fa college worries
global nfaworries worry_academic worry_family worry_community worry_away worry_support worry_race worry_gender worry_so worry_religion


/* Store all questions into global macros for easy display during visualization */
foreach var in $xtab $hsexp $plans $nfaworries {
	global `var' `: var label `var''
}



*================*
* Tabulation
*================*

*--------------------------------------------------*
* Going: Collge Plans, HS Experience & HS Worries  *
*--------------------------------------------------*
* $`var' display survey question 
* For each question, showed one way tab, cross tab with frequency, row%, column%
* 	Showing frequency to know if cell sizes are too small to share 
* 	Showing row & freq percentages to detect varation across groups
*	Showing missing counts to capture nonresponse


foreach var in $hsexp $plans $nfaworries {
	di ""
	di "*******************************************************************"
	di "$`var'"
	di "*******************************************************************" 

	di "Two way tabulation"
	foreach cat in $xtab {
	if "`var'" != "`cat'"{ // omit xtab against itself
		tab `cat' `var', row col miss	// subgroup tabulation
		}
	}
}


* Tabluation reasons of bullying conditioning on being bullied

foreach var in $reasons {
	di ""
	di "*******************************************************************"
	di "$`var'"
	di "*******************************************************************" 

	di "Two way tabulation"
	foreach cat in $xtab {
	if "`var'" != "`cat'"{ // omit xtab against itself
		tab `cat' `var' if times_bullied > 0, row col miss 	// subgroup tabulation
		}
	}
}


********************************* End Main ************************************

log close

