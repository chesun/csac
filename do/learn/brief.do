/******************************************************************************
PROGRAM: Generate Sharable Output CSAC HS Sr 2023 Main Survey

WRITTEN BY: Baiyu Zhou (baizhou@ucdavis.edu)

DATE CREATED: Sep 12, 2023

* NOTE: require install esttab packages
* do "/home/research/ca_ed_lab/projects/csac_survey2023/do/learn/brief.do"
*******************************************************************************/


********************************* Preamble ************************************
*----------*
* Toggle
*----------*
local standalone 1 // Set to 1 if running this program for the first time
local do_plot 0 // Set to 1 if want to re-generate all figures. Takes a while.

*----------*
* Settings
*----------*
* Install packages
*ssc install splitvallabels

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
log using "$csacprojdir/log/learn/brief.log", replace

********************************* Main *****************************************

* Load fully cleaned data
use "$csacprojdir/dta/cln/csac_hs_senior_2023_brief.dta", clear


*==================*
* Macros set up
*==================*


/* Global macros for crosstab variables */

* crosstab subgroups: race, gender, parental education
global xtab race_brief gender_brief_main parent_edu


/* Outcomes */

* hs experience & bullying 
global hsexp hs_academic hs_social hs_community_belong hs_teacher_care hs_good_advising hs_prepared_college hs_type times_bullied reasons_bullied_irace reasons_bullied_ireligion reasons_bullied_igender reasons_bullied_iso

* college plans
global plans college_fall where_college major highest_degree prop_online_class

* non-fa college worries
global nfaworries worry_academic worry_family worry_community worry_away worry_support //  worry_so 

* fa college worries
global faworries worry_tuition worry_living 


*--------------------------------------*
* Reasons for Bullying and Harassment  *
*--------------------------------------*

* Column: Each Reason of Being Bullied
* Row: Each subsample
* Cell: Fraction of respondents selected reason `X'


/* Note: */
* Use reg on a constant computationally
* It estimate the mean = share as dep vars are dummies
* For now formatted log file. Think of ways to put into exportable format later.

/* Reason: race OR gender */
gen reasons_race_or_gen = 0
replace reasons_race_or_gen = 1 if reasons_bullied_igender == 1
replace reasons_race_or_gen = 1 if reasons_bullied_irace == 1
replace reasons_race_or_gen = . if reasons_bullied == .

/* Count ever bullied */
gen ever_bullied = .
replace ever_bullied = 1 if inrange(times_bullied, 1, 3)
replace ever_bullied = 0 if times_bullied == 0
tab ever_bullied

*==========================================*
* Gen: Crosstab Variables for Main Brief
*==========================================*

/* RACE: race_brief */
* tab race_assn // PI < 100

cap drop race_brief
cap label drop race_brief_lbl

* Race for main brief: combine PI and native Americans
gen race_brief = race_assn
replace race_brief = 1 if race_assn == 4 // move to native if pi
label var race_brief "race/ethnicity for the main brief"

* modify value label
label copy race_assn_lbl race_brief_lbl, replace
label define race_brief_lbl 1 "American Indian/Alaskan Native/Pacific Islander" 4 "", modify
label val race_brief race_brief_lbl


/* GENDER: gender_brief_main */
cap drop gender_brief_main
cap label drop gender_brief_main_lbl

* combine categories for the main brief
gen gender_brief_main = gender_brief
replace gender_brief_main = 2 if gender_brief == 3 // combine binary trans & other
replace gender_brief_main = 4 if gender_brief == 5 // combine prefer not to say with unsure
label var gender_brief_main "gender for the main brief"

* modify value label
label copy gender_brief_lbl gender_brief_main_lbl, replace // copy from finer label
label define gender_brief_main_lbl 2 "gender variant" 4 "unsure/prefer not to say",  modify
label val gender_brief_main gender_brief_main_lbl


/* PARENT EDUCATION: parent_edu_brief */
cap drop parent_edu_brief
cap label drop parent_edu_brief_lbl

* combine asso & some college for the main brief
gen parent_edu_brief = parent_edu
replace parent_edu_brief = 3 if parent_edu == 4 
label var parent_edu_brief "highest level of education among parents"

* modify value label 
label copy parent_edu parent_edu_brief_lbl
label define parent_edu_brief_lbl 3 "Some college, no college degree/Associate degree", modify
label val parent_edu_brief parent_edu_brief_lbl


*=======*
* Prep 
*=======*

/* Store all questions into global macros for easy display during visualization */
foreach var in $xtab race_simp gender_brief so_brief lgbtq parent_edu primary_english hs_type college_fall fall_plan inf_no_college where_college major highest_degree worry_academic worry_family worry_community worry_away worry_support worry_race worry_gender worry_so worry_religion prop_online_class hs_academic hs_social hs_community_belong hs_teacher_care hs_good_advising hs_prepared_college times_bullied reasons_bullied{
	global `var' `: var label `var''
}


*==========================*
* Share: Aggregated Tables
*=========================*

/* Table 1 */
tab race_brief, mi
tab gender_brief_main, mi
tab parent_edu, mi

/* Figure 1: HS academic*/
tab hs_academic
foreach var in $xtab{
 tab `var'  hs_academic , nofreq row
}

/* Figure 2: HS social*/
tab hs_social
foreach var in $xtab{
 tab `var' hs_social , nofreq row
}

/* Figure 3: Bullied*/
tab times_bullied
foreach var in $xtab{
 tab `var' times_bullied , nofreq row
}


/* Table 2: Bullied Reason */
* All:
eststo clear 
di "All"
foreach y in reasons_bullied_igender reasons_bullied_irace reasons_bullied_ireligion{
	qui eststo: qui reg `y'
}

esttab, nostar not b(a3) coeflabels(_cons "All") mtitles("Gender" "Race" "Religion") nonum noline varwidth(20)


* By Gender & Race:
foreach cat in gender_brief_main race_brief{ // foreach crosstab variable
	di ""
	di "$`cat'"
	qui levelsof `cat', local(vals)
	foreach val in `vals'{ // foreach subsample
	eststo clear
	foreach y in reasons_bullied_igender reasons_bullied_irace reasons_bullied_ireligion{
		qui eststo: qui reg `y' if `cat' == `val'  // estimate the share
	}
	local lab: label(`cat') `val' // row name
	esttab, nostar not b(a3) coeflabels(_cons "`lab'") nomtitles varwidth(20) nonum nodep noline // each subsample is a row
	}
}


/* Figure 4: hs_teacher_care */
tab hs_teacher_care
foreach var in $xtab{
 tab `var' hs_teacher_care, nofreq row
}

/* Figure 5: hs_good_advising */
tab hs_good_advising
foreach var in $xtab{
 tab `var' hs_good_advising, nofreq row
}

/* Figure 6: hs_prepared_college */
tab hs_prepared_college
foreach var in $xtab{
 tab `var' hs_prepared_college, nofreq row
}

/* Figure 7: where_college */
tab where_college
foreach var in $xtab{
 tab `var' where_college, nofreq row
}


/* Table 3: Major*/
tab major
foreach var in $xtab{
 tab `var'  major , nofreq row
}

/* Figure 8: prop_online_class */
tab prop_online_class
foreach var in $xtab{
 tab `var' prop_online_class, nofreq row
}

/* Figure 9: worries */
foreach y in $nfaworries {
	tab `y'
}

/* Table 3 & 4*/
* Column: Each worry
* Row: Each Sample
* Cell: Fraction of respondents selected "VERY WORRIED"

/* Generate Indicator for Very Worried */
foreach y in $nfaworries $faworries{
         gen v_`y' = .
         replace v_`y' = 1 if `y' == 3
         replace v_`y' = 0 if inlist(`y', 0, 1, 2)
}

* All:
di "All"
eststo clear
foreach y in $nfaworries {
	qui eststo: qui reg v_`y'
}

esttab, nostar not b(a3) coeflabels(_cons "All") mtitles("academic" "family" "community" "away" "support" "race" "gender" "religion") nonum noline varwidth(20)

* Updating Table 3 & 4
foreach cat in race_brief gender_brief_main parent_edu { // foreach crosstab variable
	* Table 3
	foreach y in $nfaworries {
		tab `cat' v_`y', row nofreq
	}

	* Table 4
	foreach y in $faworries{
		tab `cat' v_`y', row nofreq
	}
}

foreach cat in parent_edu { // foreach crosstab variable
	* Table 3
	foreach y in $nfaworries {
		tab `cat' v_`y', row 
	}

	* Table 4
	foreach y in $faworries{
		tab `cat' v_`y', row 
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



* Stacked Bar Graphs
foreach var in $hsexp $plans $nfaworries {
* Stacked Bar Graph For Overall
	#delimit;
	graph hbar, over(`var', label(labsize(small))) asyvars stack 
		percentages missing
		title("$`var'", span size(medium))
		;
		// note: percentages option make the graph shows the within percentages
	#delimit cr 
	graph export "$csacprojdir/fig/learn/brief/`var'.png", replace

	* Stacked Bar Graph By Crosstab Vars
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
		graph export "$csacprojdir/fig/learn/brief/`var'X`cat'.png", replace
		}
	}
}




}







********************************* End Main ************************************

log close

