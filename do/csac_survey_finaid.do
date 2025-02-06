/*******************************************************************************
PROGRAM: csac_survey_finaid.do

AUTHOR: Betsey Friedmann

Date: April 2024

DESCRIPTION:  
This .do file identifies the FAFSA & financial aid questions from the Spring 2023
high school seniors survey, with flagged subgroup(s) to look at for the analysis. 

This is the short brief (by EFC and segment) to be co-branded with CSAC. 
Jaime will write a longer paper with other subgroups 
*******************************************************************************/

*Set directories with globals
global main "/home/research/ca_ed_lab/projects/csac_survey2023"

********************************************************************************
*Load in clean CSAC HS senior survey data + drop unnecessary variables
********************************************************************************
use "/$main/dta/cln/csac_hs_senior_2023_brief_admin.dta",  clear

*Drop unnecessary variables
drop startdate enddate recordeddate progress duration_sec device_browser ///
device_version device_os device_res t_conset t_senior t_hear_import_aid ///
t_hs_req_fafsa t_*
	/*Note: majority of these are when timing & logistics of survey completion
	(i.e. start/end, how long it took, devices used, etc.)*/

drop last_name first_name mdl_name cga_awd_status cgb_awd_status cgc_awd_status fl_pmt fl_adj_rsn_cd fl_sch fl_sch_segment wn_pmt wn_adj_rsn_cd wn_sch wn_sch_segment sp_pmt sp_adj_rsn_cd sp_sch su_pmt su_adj_rsn_cd su_sch su_sch_segment _mergexwalk dup
	*Most of these are student-level admin data we don't need.
	
********************************************************************************
*Create EFC categories (zero EFC, Pell-eligible, not Pell-eligible, missing)
********************************************************************************
codebook efc 
	*EFC is in string format - need to change to numerical 
	*1,432 missing observations

*Change EFC to numerical
destring efc, replace

*Generate EFC bins by Pell Grant eligibility: 0, 1-Pell max, Over Pell max
gen efc_bin=. // creates new variable for efc bins
replace efc_bin=1 if efc==0 // if a student has efc=0, they'll be in bin 1
replace efc_bin=2 if efc>0 & efc<=6656
replace efc_bin=3 if efc>6656 & efc!=. // "!." means to only include EFC that are NOT missing
replace efc_bin=4 if efc==. // if student has missing EFC, they'll be in bin 4

label define efc_bin 1 "Zero EFC" 2 "Pell-Eligible" 3 "Not Pell-Eligible" 4 "Missing EFC"
label value efc_bin efc_bin
tab efc_bin, m


/*******************************************************************************	
Cross-tabs of simple race with EFC and segment
*******************************************************************************/
/*tab race_simp, nol
/*
	race/ethnicity reduced to 9 categories
1	Black/African American
2	American Indian/Alaskan Native
3	Asian
4	Filipino
5	Hispanic/Latinx
6	Pacific Islander
7	White/Non-Hispanic
8	Other
9	Two or more
*/
tab race_simp efc_bin, m
tab race_simp efc_bin, r col

tab race_simp where_college if college_fall==1, r col 

gen race_income=.
replace race_income=1 if race_simp==1 & efc_bin==1
replace race_income=2 if race_simp==3 & efc_bin==1
replace race_income=3 if race_simp==5 & efc_bin==1
replace race_income=4 if race_simp==7 & efc_bin==1
replace race_income=5 if race_simp==1 & efc_bin==2
replace race_income=6 if race_simp==3 & efc_bin==2
replace race_income=7 if race_simp==5 & efc_bin==2
replace race_income=8 if race_simp==7 & efc_bin==2
replace race_income=9 if race_simp==1 & efc_bin==3
replace race_income=10 if race_simp==3 & efc_bin==3
replace race_income=11 if race_simp==5 & efc_bin==3
replace race_income=12 if race_simp==7 & efc_bin==3
tab race_income race_simp, m 
tab race_income efc_bin, m
 
la def race_income 1 "Zero-Black" 2 "Zero-Asian" 3 "Zero-Hisp" 4 "Zero-White" 5 "Pell-Black" 6 "Pell-Asian" 7 "Pell-Hisp" 8 "Pell-White" ///
9 "NoPell-Black" 10 "NoPell-Asian" 11 "NoPell-Hisp" 12 "NoPell-White"
la val race_income race_income
tab race_income, m 

gen race_zeroefc=.
replace race_zeroefc=1 if race_simp==1 & efc_bin==1
replace race_zeroefc=2 if race_simp==3 & efc_bin==1
replace race_zeroefc=3 if race_simp==5 & efc_bin==1
replace race_zeroefc=4 if race_simp==7 & efc_bin==1
tab race_zeroefc, m 
la def race_zeroefc 1 "Black" 2 "Asian" 3 "Latinx" 4 "White"
la val race_zeroefc race_zeroefc 
tab race_zeroefc, m 
*/

/*******************************************************************************
PACE Brief: update race variable (race_assn): students who indicated "two or more" are moved 
into a race/ethnicity group following the order of under-representativenes
*adopted from Baiyu's coding* 
********************************************************************************/

/* race_assn: move "two or more" into one of the eight based on URM by the following
hierarchy: native > black > hispanic > PI > Filipino > Asian > Other > White*/
cap drop race_assn
cap label drop race_assn_lbl

gen race_assn = . // initiate variable
label var race_assn "race/ethnicity with `Two or more' assigned to single race following URM hierachy"
local j = 8 // numerical value reflects assignment hierachical rank 1 - 8
label define race_assn_lbl 0 "" // initiate value label for race_assn

* Assign race according to hierarchy
foreach cat in white other asian flip pi hisp black native{ // replacement happen in reverse order to make sure the lower-raned one is always replaced by the higher-ranked one
	replace race_assn = `j' if race_`cat' == 1
	local varlab: variable label race_`cat' // copy value label from indicator variables
	local varlab = subinstr("`varlab'", "selected '", "",1) // keep only the categories
	local varlab = subinstr("`varlab'", "'", "",1)
	label define race_assn_lbl `j' "`varlab'", add // update value label
	local j = `j'-1 // update numerical value
}
label val race_assn race_assn_lbl // label value

*Race for main brief: combine Pacific Islander & Native Americans (low n-sizes)
gen race_brief = race_assn
replace race_brief = 1 if race_assn == 4 // move to native if pi
label var race_brief "race/ethnicity for the main brief"

*Relabel race_brief to show changes
label define race_brief_lbl 1 "American Indian/Alaskan Native/Pacific Islander" ///
2 "Black/African American" 3 "Hispanic/Latinx" 5 "Filipinx" 6 "Asian" ///
7 "Other" 8 "White/Non-Hispanic"
	/*label define indicates you will define a variable, followed by name
	for these changes (think of it as a bucket), then put the number 
	you want to (re)define followed by the name, repeat*/

label values race_brief race_brief_lbl
	/*this links the "bucket" of (re)defined labels to the race_brief so
	that tables display the label rather than the numbers*/
*/


*Confirm changes 
tab race_brief, m

tab race_simp race_brief,m 

gen race_income=.
replace race_income=1 if race_brief==2 & efc_bin==1
replace race_income=2 if race_brief==3 & efc_bin==1
replace race_income=3 if race_brief==6 & efc_bin==1
replace race_income=4 if race_brief==8 & efc_bin==1
replace race_income=5 if race_brief==2 & efc_bin==2
replace race_income=6 if race_brief==3 & efc_bin==2
replace race_income=7 if race_brief==6 & efc_bin==2
replace race_income=8 if race_brief==8 & efc_bin==2
replace race_income=9 if race_brief==2 & efc_bin==3
replace race_income=10 if race_brief==3 & efc_bin==3
replace race_income=11 if race_brief==6 & efc_bin==3
replace race_income=12 if race_brief==8 & efc_bin==3
tab race_income race_brief, m 
tab race_income efc_bin, m
 
la def race_income 1 "Zero-Black" 2 "Zero-Hisp" 3 "Zero-Asian" 4 "Zero-White" 5 "Pell-Black" 6 "Pell-Hisp" 7 "Pell-Asian" 8 "Pell-White" ///
9 "NoPell-Black" 10 "NoPell-Hisp" 11 "NoPell-Asian" 12 "NoPell-White"
la val race_income race_income
tab race_income, m

tab race_income race_brief,m  

/*******************************************************************************	
NOTE: flow of questions in the do file mirrors outline of brief, so it is NOT in
chronological order as students experienced it in the actual survey
*******************************************************************************/


/*******************************************************************************
FIGURE 1: Were you required by your high school to fill out the FAFSA/CADAA? 
*******************************************************************************/
*Overall results for whether students attended HS that required FAFSA/CADAA
tab hs_req_fafsa
	*70% attended HS that required FAFSA/CADAA; 14% sample missing

*Crosstab: HS requirement by EFC
tab hs_req_fafsa efc_bin, col


/*******************************************************************************
FIGURE 2. How did you hear about the importance of submitting a financial aid 
application? (HS Staff, word of mouth, online, other, print, public, social, 
workshop) 
*******************************************************************************/

*Global for Q2 responses
global hearimportaid hear_import_aid_ihsstaff hear_import_aid_imouth hear_import_aid_ionline hear_import_aid_iother hear_import_aid_iprint hear_import_aid_ipublic hear_import_aid_isocial hear_import_aid_iworkshop

*Overall tables for all hear_import_aid options (hear_import_aid_*; includes missing)
foreach var in $hearimportaid {
	tab `var'
}

/*******************************************************************************
Appendix Figure 1: Race x EFC 
*******************************************************************************/
tab race_brief efc_bin, r

/*******************************************************************************
FIGURE 3. Please tell us which of the following helped you complete the FAFSA/CADAA. 
Check all that apply. (Workshop in the community, HS counselor, family other than
parent, friend, HS workshop, nobody, parent, teacher) 
*******************************************************************************/
*Global for Q3 responses
global fafsasupport fafsa_support_icmworkshop fafsa_support_icounselor fafsa_support_ifamily fafsa_support_ifriend fafsa_support_ihsworkshop fafsa_support_inobody fafsa_support_iparent fafsa_support_iteacher

*Overall results for each FAFSA support options (fafsa_support_*; includes missings)
foreach var in $fafsasupport {
	tab `var'
}
	
*Crosstab: Top 3 FAFSA support options x EFC 
foreach var in fafsa_support_iparent fafsa_support_icounselor fafsa_support_ihsworkshop {
	tab efc_bin `var', row 
}

*Crosstab: Top 3 FAFSA support options x EFC 
foreach var in fafsa_support_iparent fafsa_support_icounselor fafsa_support_ihsworkshop {
	tab race_income `var', row 
}	
	
/*******************************************************************************	
*Figure 4: Planned College Segment by EFC
*******************************************************************************/
*Overall results for whether students intend to enroll in college (with missing)
tab college_fall,m 
	*81% intend to go to college; 15% of sample missing
tab college_fall 	
/*
 do you plan |
   to attend |
  college in |
    the fall |      Freq.     Percent        Cum.
-------------+-----------------------------------
          No |        170        1.75        1.75
         Yes |      9,230       95.21       96.97
I don't know |        294        3.03      100.00
-------------+-----------------------------------
       Total |      9,694      100.00

95% of those who answered the question. 
*/

	/***********************************************************************	
	*Figure 4b: Segment by Race
	***********************************************************************/	
	
	**If yes, Q6. Where do you plan to attend college this fall?
	tab where_college if college_fall==1, m // only includes those that said "YES"
	/*Most popular option is CCC (38%), CSU (22%), then UC (21%). 
	0.63% of sample is missing*/

	tab efc_bin where_college if college_fall==1 , r freq
	
	*Race-Income
	tab race_income where_college if college_fall==1 , r freq

/*******************************************************************************
Q10. How do you plan to pay college tuition and fees? Check all that apply.  
(Credit cards, grants, loans, military/VA, money from others, own savings, 
scholarships, working while enrolled)
*******************************************************************************/	
*Global for Q10 responses (grants, loans, etc)
global payplan pay_plan_igrants pay_plan_ischolarships pay_plan_iloans ///
pay_plan_iworking pay_plan_isavings pay_plan_ipeople pay_plan_icredit pay_plan_imilitary

*Set up data to include only those going to college (including missing responses)
preserve 
keep if college_fall ==1

/*Overall results for each option to pay for college (pay_plan_*; includes missing)
foreach var in $payplan {
	tab `var'
	}

*Crosstab: pay_plan_* x all subgroups
foreach var in $payplan {
	tab efc_bin `var;', r
}

*Crosstab: pay_plan_* x race- zero EFC
foreach var in $payplan {
	tab race_zeroefc `var', r
}


foreach var in $payplan {
	tab efc_bin `var', r
}

foreach var in $payplan {
	tab where_college `var', r
}
*/

*Crosstab by race/income (Figure A4)
foreach var in $payplan {
	tab race_income `var', r
}	

*Loans by all Race-Income 
*tab race_income pay_plan_iloans, r 

*Restore data 
restore

/*******************************************************************************
Loan Questions
The next questions ask about your beliefs about student loan repayment. We are interested in your beliefs even if you do not plan to take out any loans.
 
Q12a. Imagine that you borrowed $10,000 in student loans to pay for college. How much do you think you would actually be required to pay back? In other words, how much of these loans do you think would not be forgiven?  [Slider from 0 to 10k-  No default value]

Q12b. Now imagine that you borrowed $50,000 in student loans to pay for college. How much do you think you would actually be required to pay back? In other words, how much of these loans do you think would not be forgiven?  [Slider from 0 to $50k -  No default value] 

******************************************************************************/
codebook loan_pay_10k loan_pay_50k if college_fall==1
hist loan_pay_10k if college_fall==1, freq title("Expected Repayment: $10k")
graph export "/$main/Loan_ten.png"
hist loan_pay_50k if college_fall==1, freq title("Expected Repayment: $50k")
graph export "/$main/Loan_fifty.png"

/*Q12c. [IF LOAN on question 11]: You indicated you plan to take out student loans. How much do you plan to borrow?
●	Less than $5k
●	$6k-$10k
●	$11k-$20k
●	$21k-$50k
●	$50k-$100k
●	More than $100k
*/

tab pay_plan_iloans if college_fall==1

tab where_college loan_borrow_amount if college_fall==1 & pay_plan_iloans==1, r
tab efc_bin loan_borrow_amount if college_fall==1 & pay_plan_iloans==1, r
tab race_income loan_borrow_amount if college_fall==1 & pay_plan_iloans==1, r 
tab race_simp loan_borrow_amount if college_fall==1 & pay_plan_iloans==1, r 
tab race_simp pay_plan_iloans if college_fall==1, r
tab race_income pay_plan_iloans if college_fall==1, r


/*******************************************************************************
FIGURE 4. Has your college contacted you (e.g. email, letter, phone call) about your 
financial aid? (Q7)
*******************************************************************************/	
*Set up data to include only those going to college (including missing responses)
preserve 
keep if college_fall==1

*Overall results if colleges contacted students (including missings)
tab college_contact
	*59% that responded said they were contacted; 21% did not; 20% sample missing

*Crosstabs: If College contacted student by segment 
tab where_college college_contact, r

restore 

	/***********************************************************************
	*If Yes: Q7b. Has your college contacted you about the following regarding
	your financial aid? (Check all that apply: fin aid letter, info on loans,
	verification, workstudy 
	************************************************************************/	
	*Global for Q7b responses (fin aid letter, loans, etc)
	global collegecontactitem college_contact_ifaoffer college_contact_iloans ///
	college_contact_iverification college_contact_iworkstudy

	*Set up data to include only those going to college (including missing responses)
	preserve 
	keep if college_fall ==1
	keep if college_contact==1 // keeps only those who said "YES" to college contact

	*Overall results for each college contact item (college_contact_*; includes missings)
	foreach var in $collegecontactitem {	
		tab  `var'
	}

	*Crosstab: Each college contact item x all subgroups
	foreach var in $collegecontactitem {
		tab where_college `var', r
		}

	restore

/*******************************************************************************
Q13.When you think about college, how worried are you about the following 
(not at all worried to very worried): 
-being able to afford college tuition,fees, books, and equipment
-being able to afford living expenses (rent, food, transportation, etc.)
-balancing work obligations
*******************************************************************************/
*Global for Q13 responses (tuition, living expenses,etc)
global worry worry_tuition worry_living worry_work

*Set up data to include only those going to college 
preserve 
keep if college_fall ==1

/*Overall results for fin aid-related worries students have (worry_*)
foreach var in $worry {
	tab `var'
}

*Crosstab: worry_* x EFC and segment 
foreach var in $worry {
	foreach type in efc_bin where_college{
	tab `type' `var', row
	}
}
*/
*Crosstab: Race x Income 
foreach var in $worry {
	foreach type in race_income {
	tab `type' `var', row
	}
}
*Restore data
restore










/*******************************************************************************
Other questions: financing college, working 
*******************************************************************************/






/*******************************************************************************
Q24. Do you currently have a job? 
*******************************************************************************/
*Overall results if students currently have a job (includes missing)
tab has_job, m
	*23% have job; 47% do not; 30% of sample missing
	
*Graph: overall results if students currenlty have job (includes missing)
graph hbar, over(has_job) missing ///
blabel(bar, size(small) position(outside) format(%5.0g)) ///
title("Students Who Currently Have a Job", size(medsmall))

*Crosstabs: If student had job x race/efc/gender (includes missing)
foreach var in has_job {
	foreach type in race_brief efc_bin gender_brief parent_edu where_college {
		tab `type' `var', col row missing 
	}
}

*Overall results if students currently have a job + intend to enroll (includes missing)
tab has_job if college_fall==1, m

*Graph: overall results if students currenlty have job + intend to enroll (includes missing)
	*Set up data to include only those with a job (including missing responses)
	preserve
	keep if college_fall==1

	graph hbar, over(has_job) missing ///
	blabel(bar, size(small) position(outside) format(%5.0g)) ///
	title("Students Who Currently Have a Job" "& Enroll in College", size(medsmall))

*Crosstabs: If student had job + intend to enroll x race/efc/gender (includes missing)
	foreach var in has_job {
		foreach type in race_brief efc_bin gender_brief parent_edu where_college {
			tab `type' `var', col row missing 
		}
	}

	restore


	/***********************************************************************	
	*If yes, Q24b: How many hours a week do you work at your job?
	***********************************************************************/
	*Overall responses for average hours/week
	tab hours_job if has_job==1, m
	*Of those that work, 40% work 10-19 hrs/wk, followed by less than 10 hrs (30%)

	*Set up data to include only those with a job (including missing responses)
	preserve
	keep if has_job==1
	
	
	*Graph overall table (includes missings)
	graph hbar, over(hours_job) missing ///
	blabel(bar, size(small) position(outside) format(%5.0g)) ///
	title("Hours per Week a Student Works", size(medsmall))
	
	*Crosstabs: Students with jobs x all subgroups (including missings)
	foreach var in hours_job {
		foreach type in race_brief efc_bin gender_brief parent_edu where_college {
			tab `type' `var', col row missing
		}
	}

	*Restore data
	restore 
	
	/*Overall responses for has job + average hours/week + intending to 
	enroll in college (includes missing)*/
	tab hours_job if ///
	has_job==1 & /// only includes students with jobs AND
	college_fall==1, m // those intending to enroll + missings
	
	/*Set up data to include only those with job + avg hours + intends to 
	enroll in college (including missing responses)*/
	preserve
	keep if has_job==1 & college_fall==1
	
	
	*Graph: Overall results for hours for students intending to enroll in college (includes missings)
	graph hbar, over(hours_job) missing ///
	blabel(bar, size(small) position(outside) format(%5.0g)) ///
	title("Hours per Week a Student" "Intending to Go to College Works", size(medsmall))
	
	*Crosstabs: Students with jobs & enrolling in college x all subgroups (including missings)
	foreach var in hours_job {
		foreach type in race_brief efc_bin gender_brief parent_edu where_college {
			tab `type' `var', col row missing
		}
	}

	*Restore data
	restore





