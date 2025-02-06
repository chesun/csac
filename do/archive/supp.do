/******************************************************************************
PROGRAM: Gender/SO/LGBTQ supplemental analysis

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
* Install packages
*ssc install splitvallabels

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
log using "$csacprojdir/log/learn/supp.txt", text replace

********************************* Main *****************************************

* Load fully cleaned data
use "$csacprojdir/dta/cln/csac_hs_senior_2023_brief.dta", clear

*============================================*
* Define Gender/SO for supplemental analysis
*===========================================*
* Goal is as fine as possible

gen so_supp = so_clean


gen gender_supp = gender_clean
replace gender_supp = "TRANS WOMAN" if gender_cis == 0 & gender_woman == 1
replace gender_supp = "TRANS MAN" if gender_cis == 0 & gender_man == 1
replace gender_supp = "CIS WOMAN" if gender_supp == "WOMAN"
replace gender_supp = "CIS MAN"	if gender_supp == "MAN"

label var gender_supp "gender for supplemental analysis"


*==================*
* Macros set up
*==================*


/* Global macros for crosstab variables */
* crosstab subgroups: race, gender, parental education
global xtab so_supp gender_supp lgbtq


/* Outcomes */

* hs experience & bullying 
global hsexp hs_academic hs_social hs_community_belong hs_teacher_care hs_good_advising hs_prepared_college hs_type times_bullied reasons_bullied_irace reasons_bullied_ireligion reasons_bullied_igender reasons_bullied_iso

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




*================*
* Visualization  *
*================*

if `do_plot' == 1{

* Relabel Crosstab Variables to include counts
foreach var in $xtab{
	qui levelsof `var', local(vals)
	foreach val in `vals'{
		local oldlbl: label (`var') `val'
		qui count if `var' == `val'
		label define new_`var'_lbl `val' "`oldlbl' (N=`r(N)')", add
}
label val `var' new_`var'_lbl
}


* Stacked Bar Graph By Crosstab Vars
foreach var in college_fall $hsexp $plans $nfaworries {
	
foreach cat in $xtab{
	if "`var'" != "`cat'"{ // omit against itself
	#delimit;
	graph hbar, over(`var', label(labsize(small))) asyvars stack 
		over(`cat', label(labsize(small))) 
		percentages missing
		title("$`var'", span size(medium))
		;
		// note: percentages option make the graph shows the within percentages
	#delimit cr 
	graph export "$csacprojdir/fig/learn/crosstab/`var'X`cat'.png", replace
		}
	}
}

}

********************************* End Main ************************************

log close

