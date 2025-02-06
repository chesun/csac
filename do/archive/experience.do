/******************************************************************************
PROGRAM: Gender/SO Paper
- Cross tab HS and College Experience by Gender and SO

WRITTEN BY: Baiyu Zhou (baizhou@ucdavis.edu)
DATE CREATED: Jan 29, 2024

To Run This Dofile:
do "/home/research/ca_ed_lab/projects/csac_survey2023/do/learn/experience.do"
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
log using "$csacprojdir/log/learn/experience.txt", text replace

* Load fully cleaned data
use "$csacprojdir/dta/cln/csac_hs_senior_2023_genderso.dta", clear

*** Add bully reasons : either gender or so
gen reasons_bullied_igenderso = reasons_bullied_igender
replace reasons_bullied_igenderso = 1 if reasons_bullied_iso == 1

label var reasons_bullied_igenderso "being bullied because of gender or sexual orientation"
label def reasons_bullied_lbl 0 "No" 1 "Yes", replace
label val reasons_bullied_igenderso reasons_bullied_lbl


***************
* Macro Setup *
***************

* crosstab caterogies: gender, sexual orientation
global xtab gender_cat so_cat

* outcomes
* hs experience & bullying 
global hsexp hs_academic hs_social hs_community_belong hs_teacher_care hs_prepared_college times_bullied reasons_bullied_igenderso

* college plans
global plans college_fall segment major highest_degree

* college worries
global worries worry_tuition worry_living worry_academic worry_work worry_family worry_community worry_away worry_support worry_gender worry_so 



***********
* Sample *
**********
* Gender minority count
tab gender_cat, mi
* So minority count
tab so_cat, mi
* Gender X So
tab gender_cat so_cat, mi

* Overall LGBTQ count (exclude prefer not to say)
gen lgbtq = .
replace lgbtq = 1 if inlist(gender_cat,2,3) 
replace lgbtq = 1 if inrange(so_cat,1,4) 
tab lgbtq

* Alt LGBTQ count (include prefer not to say)
gen lgbtq_alt = .
replace lgbtq_alt = 1 if inlist(gender_cat,2,4) 
replace lgbtq_alt = 1 if inrange(so_cat,1,5) 
tab lgbtq_alt


************
* Crosstab *
************

foreach y in $plans $worries $hsexp {
    foreach cat in $xtab {
        tab `cat' `y', row col
    }
}

***********************************
* Reliability - Cronbach's Alpha  *
***********************************
/* Worries */

* All
alpha worry_tuition worry_living worry_academic worry_work worry_family worry_community worry_away worry_support, item

* Within gender
forval val = 0/4{
    di " "
    di "Gender: `: label (gender_cat) `val''"
    alpha worry_tuition worry_living worry_academic worry_work worry_family worry_community worry_away worry_support if gender_cat == `val', item
}

/* HS Experience */

* All
alpha hs_academic hs_social hs_community_belong hs_teacher_care hs_prepared_college, item

* Within gender
forval val = 0/4{
    di " "
    di "Gender: `: label (gender_cat) `val''"
    alpha hs_academic hs_social hs_community_belong hs_teacher_care hs_prepared_college if gender_cat == `val', item
}

*********************************************
* Correlation btw HS Experience and Worries *
*********************************************
// Note: 
// HS experence scale from -2 to 2, where -2 represents strongly disagree
// Worries scale from 0 to 3, 0 represents not worried at all


/* Worry about academic */
* Academic experience and academic worries
di "Relations between (`: var label hs_academic') and (`: var label worry_academic'): "
corr hs_academic worry_academic // All
// Within gender
forval val = 0/4{
    di " "
    di "Gender: `: label (gender_cat) `val''"
    corr hs_academic worry_academic if gender_cat == `val'
}

* Feeling prepared and academic worries
di "Relations between (`: var label hs_prepared_college') and (`: var label worry_academic'): "
corr hs_prepared_college worry_academic // All
// Within gender
forval val = 0/4{
    di " "
    di "Gender: `: label (gender_cat) `val''"
    corr hs_prepared_college worry_academic if gender_cat == `val'
}

/* Worry about community */
* Social experience and community worries
di "Correlation between `: var label hs_social' and `: var label worry_community': "
corr hs_social worry_community  // All
// Within gender
forval val = 0/4{
    di " "
    di "Gender: `: label (gender_cat) `val''"
    corr hs_social worry_community if gender_cat == `val'
}

* Feeling belong and community worries
di "Correlation between `: var label hs_community_belong' and `: var label worry_community': "
corr hs_community_belong worry_community // All
// Within gender
forval val = 0/4{
    di " "
    di "Gender: `: label (gender_cat) `val''"
    corr hs_community_belong worry_community if gender_cat == `val'
}

/* Worry about support */
* Social experience and support worries
di "Correlation between `: var label hs_social' and `: var label worry_support': "
corr hs_social worry_support // All
// Within gender
forval val = 0/4{
    di " "
    di "Gender: `: label (gender_cat) `val''"
    corr hs_social worry_support if gender_cat == `val'
}

* Feeling belong and support worries
di "Correlation between `: var label hs_community_belong' and `: var label worry_support': "
corr hs_community_belong worry_support // All
// Within gender
forval val = 0/4{
    di " "
    di "Gender: `: label (gender_cat) `val''"
    corr hs_community_belong worry_support if gender_cat == `val'
}

* Teacher care and support worries
di "Correlation between `: var label hs_teacher_care' and `: var label worry_support': "
corr hs_teacher_care worry_support // All
// Within gender
forval val = 0/4{
    di " "
    di "Gender: `: label (gender_cat) `val''"
    corr hs_teacher_care worry_support if gender_cat == `val'
}



log close



********************************************
* For Christina's Mar 1, 2024 Presentation *
********************************************

net install http://www.stata.com/users/kcrow/tab2xl, replace

cap erase "$csacprojdir/tab/learn/aefp/aefp_poster.xlsx"

tab2xl gender_cat using "$csacprojdir/tab/learn/aefp/aefp_poster", col(1) row(1) sheet("gender", replace)
tab2xl so_cat using "$csacprojdir/tab/learn/aefp/aefp_poster", col(1) row(1) sheet("so", replace)

* HS experience & college plan 
rename reasons_bullied_igenderso igenderso
rename hs_community_belong hs_community

foreach y in times_bullied igenderso hs_social hs_community segment major highest_degree{
    tab2xl `y' using "$csacprojdir/tab/learn/aefp/aefp_poster", col(1) row(1) sheet("`y'", replace)
    tab2xl gender_cat `y' using "$csacprojdir/tab/learn/aefp/aefp_poster", percentage col(1) row(1) sheet("`y'Xgen", replace)
    tab2xl so_cat `y' using "$csacprojdir/tab/learn/aefp/aefp_poster", percentage col(1) row(1) sheet("`y'Xso", replace)
}


* College Worries 
foreach y in worry_support worry_gender worry_so worry_community{
    gen `y'_a = 3 - `y' // to start from very worried
    label define `y'_albl 0 "Very worried" 1 "Somewhat worried" 2 "Slightly worried" 3 "Not at all worried", replace
    label val `y'_a `y'_albl

    tab2xl `y'_a using "$csacprojdir/tab/learn/aefp/aefp_poster", col(1) row(1) sheet("`y'", replace) // overall
    tab2xl gender_cat `y'_a using "$csacprojdir/tab/learn/aefp/aefp_poster", percentage col(1) row(1) sheet("`y'Xgen", replace)
    tab2xl so_cat `y'_a using "$csacprojdir/tab/learn/aefp/aefp_poster", percentage col(1) row(1) sheet("`y'Xso", replace)
}
