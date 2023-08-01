/******************************************************************************
PROGRAM: Cross Tabulate Cleaned CSAC HS Sr 2023 Survey

WRITTEN BY: Baiyu Zhou (baizhou@ucdavis.edu)

DATE CREATED: July 17, 2023
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
log using "$csacprojdir/log/learn/crosstab.txt", text replace

********************************* Main *****************************************

* Load fully cleaned data
use "$csacprojdir/dta/cln/csac_hs_senior_2023_brief.dta", clear


*==================*
* Macros set up
*==================*

/* Store all questions into global macros for easy display during visualization */
foreach var in race_simp gender_brief so_brief lgbtq parent_edu primary_english hs_type college_fall fall_plan inf_no_college where_college major highest_degree worry_academic worry_family worry_community worry_away worry_support worry_race worry_gender worry_so worry_religion prop_online_class hs_academic hs_social hs_community_belong hs_teacher_care hs_good_advising hs_prepared_college times_bullied reasons_bullied{
	global `var' `: var label `var''
}

/* Global macros for crosstab variables */
* crosstab
global xtab race_simp gender_brief so_brief lgbtq parent_edu primary_english hs_type where_college

*** Outcomes: 
* college plans
global plans college_fall where_college major highest_degree prop_online_class

* non-fa college worries
global nfaworries worry_academic worry_family worry_community worry_away worry_support worry_race worry_gender worry_so worry_religion

* hs experience & bullying 
global hsexp hs_academic hs_social hs_community_belong hs_teacher_care hs_good_advising hs_prepared_college hs_type times_bullied reasons_bullied



*================*
* Tabulation
*================*
*-----------------------------*
* Demographics/ Background
*-----------------------------*

vl set // initiate varlist environment
vl clear, user // clear user defined varlist 
vl create vlxtab = ( $xtab ) // initiate a varlist that stores categorical variables

foreach var in $xtab{
vl modify vlxtab = vlxtab - (`var') 	// remove self from category
	di ""
	di "**************************************"
	di "$`var'"
	di "**************************************"
	di "One way tabulation: "
	tab `var' 
	local r wordcount("$vlxtab") 	// count length of varlist 
	if `r' > 0 {   			// only run crosstab if non-emply varlist 
	di "Interaction over: $vlxtab "
		foreach cat of varlist $vlxtab {
		tab `cat' `var', row	// cross tab over other crosstab categories	
	}
	}
}



*----------------------*
* Not Going or Unsure *
*---------------------*
* if not: alternative plan
tab fall_plan // check all apply

* if unsure (marginal students): potential effective treatment
tab inf_no_college // check all apply


*-----------------------------------------------*
* If going to college - Collge Plans & Worries  *
*-----------------------------------------------*
* College going within all HS Sr,
tab college_fall //q6 - college going

* Conditioning on Going - Detailed plans
tab where_college //q6
tab major //q9
tab highest_degree //q12
* Online class // q14
tab prop_online_class

* Non-FA-related Worries // q13
tab worry_academic
tab worry_family
tab worry_community
tab worry_away
tab worry_support 
tab worry_race 
tab worry_gender 
tab worry_so 
tab worry_religion



/* Cross Tab College Plans & Worries */
foreach var in $plans $nfaworries {
	di ""
	di "*******************************************************************"
	di "$`var'"
	di "*******************************************************************"
	di "Two way tabulation"
	foreach cat in $xtab {
	if "`var'" != "`cat'"{ // omit xtab against itself
		tab `cat' `var', row	// cross tab over other crosstab categories	
		}
	}
}



*---------------*
* HS Experience *
*---------------*

* Academic performance
tab hs_academic //q16

* Social experience
tab hs_social //q17

* Detailed social experience aspectes //q18
tab hs_community_belong 
tab hs_teacher_care 
tab hs_good_advising 
tab hs_prepared_college

* Bullying // q19, 20
tab times_bullied 
tab reasons_bullied


/* Cross Tab HS experience & bullying */
foreach var in $hsexp {
	di ""
	di "*******************************************************************"
	di "$`var'"
	di "*******************************************************************"
	di "Two way tabulation"
	foreach cat in $xtab {
	if "`var'" != "`cat'"{
		tab `cat' `var', row	// cross tab over other crosstab categories	
		}
	}
}

if `do_plot' == 1{
*================*
* Visualization  *
*================*

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
foreach var in college_fall $plans $nfaworries $hsexp  {
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

