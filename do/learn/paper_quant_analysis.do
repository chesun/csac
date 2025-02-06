/******************************************************************************
PROGRAM: Gender/SO Paper
- Quantitative Analysis For CSAC LGBTQ+ Paper

WRITTEN BY: Baiyu Zhou (baizhou@ucdavis.edu)
DATE CREATED: March 26, 2024

To Run This Dofile:
do "/home/research/ca_ed_lab/projects/csac_survey2023/do/learn/paper_quant_analysis.do"
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
log using "$csacprojdir/log/learn/paper_quant_analysis.txt", text replace

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
// Note: decided to focus on gender
* crosstab caterogies: gender (sexual orientation)
global xtab gender_cat // so_cat

* outcomes
* hs experience & bullying 
global hsexp    hs_academic hs_social hs_community_belong hs_teacher_care                  hs_prepared_college
global allhsexp hs_academic hs_social hs_community_belong hs_teacher_care hs_good_advising hs_prepared_college 
global bully    times_bullied reasons_bullied_igenderso

* college plans
global plans    college_fall segment major highest_degree

* college worries
global worries    worry_tuition worry_living worry_academic worry_work worry_family worry_community worry_away worry_support worry_gender worry_so
global allworries worry_tuition worry_living worry_academic worry_work worry_family worry_community worry_away worry_support worry_gender worry_so worry_race worry_religion
global worries6   worry_tuition worry_living worry_academic worry_work worry_family worry_community  
global worries12                                                                                    worry_away worry_support worry_gender worry_so worry_race worry_religion

* indices
global indices worry_index1 worry_index2 worry_index3




**************************
* Descriptive - Crosstab *
**************************

foreach y in $plans { //  $worries $hsexp $bully 
    foreach cat in $xtab {
        tab `cat' `y', row col
    }
}

***********************************
* Reliability - Cronbach's Alpha  *
***********************************
/* Worries */

* All
alpha $allworries, item

/* HS Experience */

* All
alpha $allhsexp, item


********************************
* Principle Component Analysis *
********************************
// Check dimension of worries
// PCA on HS experience and their correlations see appendix

/* Worries */

pca $allworries


******************************
* Construct Indices of Worry *
******************************

pca $allworries, component(3)

* store PCA eigenvector to construct indices
mat A = e(L) // A is 12 x 3 matrix of eigenvectors
cap drop A1 A2 A3
svmat A // generate A1, A2, A3 corresponds to three 12x1 eigenvectors

* gnerate three indices based on eigenvectors of comp1 - comp3
cap drop worry_index*
forval n = 1/3{
    gen worry_index`n' = worry_tuition * A`n'[1] + worry_living    * A`n'[2]  + worry_academic * A`n'[3]  + worry_work     * A`n'[4] + ///
                         worry_family  * A`n'[5] + worry_community * A`n'[6]  + worry_away     * A`n'[7]  + worry_support  * A`n'[8] + ///
                         worry_gender  * A`n'[9] + worry_so        * A`n'[10] + worry_race     * A`n'[11] + worry_religion * A`n'[12] 

}

label var worry_index1 "general worries"
label var worry_index2 "worries about discrimination"
label var worry_index3 "worries about financial burdens"

**************************
* Index of HS experience *
**************************

* additive due to high reliablity (alpha > .7)
// notes hs_academic & hs_social range 1 to 5; hs_community, hs_teacher_case, hs_good_advising, hs_prepare_college range -2 to 2. SYN to all hsexp using -2 to 2 for easier interpreation
replace hs_academic = hs_academic - 3
replace hs_social = hs_social - 3

cap drop hsexp_index
egen hsexp_index = rowtotal($allhsexp) // range -12 to 12.

* set to missing if any of the hs experience is missing
foreach var in $hsexp{
    replace hsexp_index = . if mi(`var')
}

label var hsexp_index "general HS experience"

********************************
* Descriptive Stats of Indices *
********************************

foreach var in $indices hsexp_index{
    tabstat `var', stat(N mean) by(gender_cat)
}

*********************************************************
* gen new label with subsamp mean to display on y-axis
*********************************************************
foreach y in $indices hsexp_index {
    label copy gender_cat_lbl gender_cat_`y' 
    label copy gender_cat_lbl gender_cat_`y'2

    forval i = 0/6{
        summ `y' if gender_cat == `i'
        local ybar: display  %3.2f `r(mean)' // ensure mean values show only two digits after decimal point, and 3 digits in total
        label define gender_cat_`y'  `i' "`:label gender_cat_lbl `i'' (mean=`ybar')", modify // add (mean=XXX) after gender cat
        label define gender_cat_`y'2 `i' `" "`:label gender_cat_lbl `i''" "(N=`r(N)', mean=`ybar')" "', modify // add (N=xx mean=xx) after gender cat in a separate line
    }
}

**********************
* Summary Statistics *
**********************
* Export to DOC format

cd "/home/research/ca_ed_lab/projects/csac_survey2023/tab/share" // save to destiniation folder


*** Demographics ***
asdoc tabulate gender_cat, nocf save(summstats.doc) replace title(Summary Statistics)
foreach var in so_cat race_assn parent_edu {
    asdoc tabulate `var', nocf save(summstats.doc) append
}

*** Appendix: gender X so ***
asdoc tab gender_cat so_cat, row nofreq append 

/* Overall */
*** Intemized and Construct - Worries ***
asdoc tabstat $allworries worry_index1 worry_index2 worry_index3, stat(N mean) label abb(.) append title(College Worries Items and Constructs) // abb(.) allows lengthy label

*** Intemized and Construct - HS experience ***
asdoc tabstat $allhsexp hsexp_index, stat(N mean) label abb(.) append  title(High School Experience Items and Construct) // NOTE: times_bullied not included in the construct


/* By Gender */
*asdoc tabstat $allhsexp, stat(mean) by(gender_cat) save(bygender.doc) replace title(High School Experience, by Gender)
*asdoc tabstat $worries6, stat(mean) by(gender_cat) append title(College Worries, by Gender)
*asdoc tabstat $worries12, stat(mean) by(gender_cat) append title(College Worries, by Gender (cont.)


* NOTE: asdoc tabstats, by() does work. It messes up the labelin of the gender variable!!

estpost tabstat hsexp_index, listwise stat(N mean) by(gender_cat) columns(statistics)
esttab . using bygender.rtf, cells("N mean(fmt(a3))") replace 


*******************************
* Reg Worry Indices by Gender *
*******************************
// can't do crosstabs, too many values

* Change value lable from "Graduate/Professional degree beyond Bachelor's degree (Master's, PhD, JD, MD, etc.)" to "Graduate degree" to make the results more readible
label def parent_edu 6 "Graduate degree", modify

* Check functional form of using hsexp_index as a regressor
foreach index in index1 index2 index3{
    twoway scatter worry_`index' hsexp_index
    graph export "/home/research/ca_ed_lab/projects/csac_survey2023/fig/learn/fn_form/`index'.png", replace
}
// Note: assuming linear - discuss if need a different functional form.
// Present the results using coefplot
* ssc install coefplot

foreach y in $indices {

    cap drop `y'_m1 `y'_m2 `y'_m3
    di "M1: only using gender to predict worry"
    reg `y' i.gender_cat
    est store `y'_m1
    * coefplot, drop(_cons) baselevels label // visualization
    * graph export "/home/research/ca_ed_lab/projects/csac_survey2023/fig/learn/reg/`y'_m1.png", replace
    * predict `y'_m1 // potential post-estimation

    di "M2: using gender to predict worry, controlling for demographics"
    reg `y' i.gender_cat i.race_assn i.parent_edu
    est store `y'_m2
    * coefplot, drop(_cons *.race_assn *.parent_edu) baselevels label
    * graph export "/home/research/ca_ed_lab/projects/csac_survey2023/fig/learn/reg/`y'_m2.png", replace
    * predict `y'_m2

    di "M3: using gender and hsexp index to predict worry, controlling for demographics"
    reg `y' i.gender_cat c.hsexp_index i.race_assn i.parent_edu
    est store `y'_m3
    * coefplot, drop(_cons hsexp_index *.race_assn *.parent_edu) baselevels label
    * graph export "/home/research/ca_ed_lab/projects/csac_survey2023/fig/learn/reg/`y'_m3.png", replace
    * predict `y'_m3

    label val gender_cat gender_cat_lbl
    coefplot (`y'_m1, msymbol(O) ciopts( lwidth(*2) color(black)) mcolor(black) ) (`y'_m3, msymbol(D) ciopts( lwidth(*2) color(gs10)) mcolor(gs10))  , drop(_cons hsexp_index *.race_assn *.parent_edu) baselevels label legend(order(2 "unconditional" 4 "control for demographics & HS index") span size(small) cols(1) region(lwidth(none))) xlabel(-.5(1)2.5) ylabel(,labsize(small)) // title( "`: var label `y''")
    graph export "/home/research/ca_ed_lab/projects/csac_survey2023/fig/learn/reg/`y'.png", replace 

    label val gender_cat gender_cat_`y'
    coefplot (`y'_m1, msymbol(O) ciopts( lwidth(*2) color(black)) mcolor(black) ) (`y'_m3, msymbol(D) ciopts( lwidth(*2) color(gs10)) mcolor(gs10)) , drop(_cons hsexp_index *.race_assn *.parent_edu) baselevels label legend(order(2 "unconditional" 4 "control for demographics & HS index") span size(small) cols(1) region(lwidth(none))) xlabel(-.5(1)2.5) ylabel(,labsize(vsmall)) // title( "`: var label `y''")
    graph export "/home/research/ca_ed_lab/projects/csac_survey2023/fig/learn/reg/`y'_w_mean.png", replace 

    label val gender_cat gender_cat_`y'2
    coefplot (`y'_m1, msymbol(O) ciopts( lwidth(*2) color(black)) mcolor(black) ) (`y'_m3, msymbol(D) ciopts( lwidth(*2) color(gs10)) mcolor(gs10)) , drop(_cons hsexp_index *.race_assn *.parent_edu) baselevels label legend(order(2 "unconditional" 4 "control for demographics & HS index") span size(small) cols(1) region(lwidth(none))) xlabel(-.5(1)2.5) ylabel(,labsize(vsmall)) // title( "`: var label `y''")
    graph export "/home/research/ca_ed_lab/projects/csac_survey2023/fig/learn/reg/`y'_w_Nmean.png", replace 

}


**************************
* Reg HS index by Gender *
**************************
foreach y in hsexp_index {
    cap drop `y'_m1 `y'_m2 `y'_m3
    di "M1: only using gender to predict worry"
    reg `y' i.gender_cat
    est store `y'_m1
    * coefplot, drop(_cons) baselevels label // visualization
    * graph export "/home/research/ca_ed_lab/projects/csac_survey2023/fig/learn/reg/`y'_m1.png", replace
    * predict `y'_m1 // potential post-estimation

    di "M2: using gender to predict worry, controlling for demographics"
    reg `y' i.gender_cat i.race_assn i.parent_edu
    est store `y'_m2
    * coefplot, drop(_cons *.race_assn *.parent_edu) baselevels label
    * graph export "/home/research/ca_ed_lab/projects/csac_survey2023/fig/learn/reg/`y'_m2.png", replace
    * predict `y'_m2

// Change colors to be compatible with B&W prints
    label val gender_cat gender_cat_lbl
    coefplot (`y'_m1, msymbol(O) ciopts( lwidth(*2) color(black)) mcolor(black) ) (`y'_m2, msymbol(D) ciopts( lwidth(*2) color(gs10)) mcolor(gs10)) , drop(_cons *.race_assn *.parent_edu) baselevels label legend(order(2 "unconditional" 4 "control for demographics") span size(small) cols(1) region(lwidth(none))) xlabel(-4(1)1) ylabel(,labsize(small))  // title( "`: var label `y''")
    graph export "/home/research/ca_ed_lab/projects/csac_survey2023/fig/learn/reg/`y'.png", replace 

    label val gender_cat gender_cat_`y'
    coefplot (`y'_m1, msymbol(O) ciopts( lwidth(*2) color(black)) mcolor(black) ) (`y'_m2, msymbol(D) ciopts( lwidth(*2) color(gs10)) mcolor(gs10)) , drop(_cons *.race_assn *.parent_edu) baselevels label legend(order(2 "unconditional" 4 "control for demographics") span size(small) cols(1) region(lwidth(none))) xlabel(-4(1)1) ylabel(,labsize(vsmall)) // title( "`: var label `y''")
    graph export "/home/research/ca_ed_lab/projects/csac_survey2023/fig/learn/reg/`y'_w_mean.png", replace 

    label val gender_cat gender_cat_`y'2
    coefplot  (`y'_m1, msymbol(O) ciopts( lwidth(*2) color(black)) mcolor(black) ) (`y'_m2, msymbol(D) ciopts( lwidth(*2) color(gs10)) mcolor(gs10)) , drop(_cons *.race_assn *.parent_edu) baselevels label legend(order(2 "unconditional" 4 "control for demographics") span size(small) cols(1) region(lwidth(none))) xlabel(-4(1)1) ylabel(,labsize(vsmall)) // title( "`: var label `y''")
    graph export "/home/research/ca_ed_lab/projects/csac_survey2023/fig/learn/reg/`y'_w_Nmean.png", replace

}



************
* Appendix *
************
* (results are not included in the current version of the papar but has been used to inform decisions) 


* PCA chose not to include
pca $allhsexp
pca $allworries $allhsexp


* Correlation between Worry & HS experience
forval n = 1/3{
    corr worry_index`n' hsexp_index
}


* Check alternative modeling choice for regression
foreach y in $indices {
    di "M1: only using gender to predict worry"
    reg `y' i.gender_cat
    di "M1b: using gender and hsexp to predict worry"
    reg `y' i.gender_cat c.hsexp_index
    di "M1c: using gender, hsexp, and hsexp^2 to predict worry"
    reg `y' i.gender_cat c.hsexp_index##c.hsexp_index
    di "M2: using gender to predict worry, controlling for demographics"
    reg `y' i.gender_cat i.race_assn i.parent_edu
    di "M3: using gender and hsexp index to predict worry, controlling for demographics"
    reg `y' i.gender_cat c.hsexp_index i.race_assn i.parent_edu 
    di "M3b: using gender, hsexp, and hsexp^2 to predict worry, controlling for demographics"
    reg `y' i.gender_cat c.hsexp_index##c.hsexp_index i.race_assn i.parent_edu 
}



log close