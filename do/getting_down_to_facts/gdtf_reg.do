/* regressions for Getting Down to Facts */

/* 
do $csacprojdir/do/getting_down_to_facts/gdtf_reg.do
 */
version 17.0
graph drop _all
set more off
set varabbrev off
set graphics off
set scheme white_tableau
set seed 1984

cap log close _all
log using $csacprojdir/log/getting_down_to_facts/gdtf_reg.txt, text replace 

use "$csacprojdir/dta/cln/csac_hs_senior_2023_genderso.dta", clear

local controls i.race_assn i.parent_edu

// color macros 
local aggieblue "0 74 168"   
local aggiegold "255 191 0"
local tabblue "78 121 167"
local taborange "242 142 43"
local mdgray "118 118 118"   

gen highest_degree_2 = highest_degree
replace highest_degree_2 = 4 if highest_degree==5
lab def highest_degree_2 1 "Certificate in vocational/technical field" 2 "Associate degree" 3 "Bachelor's degree" 4 "Master's or Doctoral Degree"


*===============================================================================
* 2 year vs 4 year, Figure 3
*===============================================================================

// segment is a dummy for attending 4 year
foreach demo in gender so {
    logit segment b0.`demo'_cat 
    estimates store segment1
    estadd local demo_controls "No"

    logit segment b0.`demo'_cat `controls'
    estimates store segment2 
    estadd local demo_controls "Yes"


    * Export to Word showing only gender coefficients
    esttab segment1 segment2 using $csacprojdir/tab/thsj_rr/segment_models_`demo'.rtf, ///
        keep(*`demo'_cat*) ///
        nobaselevels ///
        b(%9.3f) se(%9.3f) ///
        star(* 0.10 ** 0.05 *** 0.01) ///
        title("Logit Models: Intent to Attend 4-Year College") ///
        nomtitles ///
        scalars("N Observations" "demo_controls Demographic Controls") ///
        label replace

}


foreach demo in gender so {
    *===============================================================================
    * DEGREE COMPLETION BY GENDER, FIGURE 4
    *===============================================================================

    * Model 1: Gender only
    ologit highest_degree i.`demo'_cat
    estimates store deg_`demo'1
    estadd local demo_controls "No"

    * Model 2: Gender with controls
    ologit highest_degree i.`demo'_cat `controls'
    estimates store deg_`demo'2
    estadd local demo_controls "Yes"

    * Export to Word
    esttab deg_`demo'1 deg_`demo'2 using $csacprojdir/tab/thsj_rr/degree_`demo'.rtf, ///
        keep(*`demo'_cat*) ///
        nobaselevels ///
        b(%9.3f) se(%9.3f) ///
        star(* 0.10 ** 0.05 *** 0.01) ///
        title("Ordered Logit Models: Highest Degree Plans") ///
        nomtitles ///
        scalars("N Observations" "demo_controls Demographic Controls") ///
        label replace

    *===============================================================================
    * DEGREE COMPLETION collapsed category BY GENDER
    *===============================================================================
    * Model 1: Gender only
    ologit highest_degree_2 i.`demo'_cat
    estimates store deg2_`demo'1
    estadd local demo_controls "No"

    * Model 2: Gender with controls
    ologit highest_degree_2 i.`demo'_cat `controls'
    estimates store deg2_`demo'2
    estadd local demo_controls "Yes"

    * Export to Word
    esttab deg2_`demo'1 deg2_`demo'2 using $csacprojdir/tab/thsj_rr/degree2_`demo'.rtf, ///
        keep(*`demo'_cat*) ///
        nobaselevels ///
        b(%9.3f) se(%9.3f) ///
        star(* 0.10 ** 0.05 *** 0.01) ///
        title("Ordered Logit Models: Highest Degree Plans") ///
        nomtitles ///
        scalars("N Observations" "demo_controls Demographic Controls") ///
        label replace
    
    *===========================================================================
    * VISUALIZATION FOR MODEL WITH CONTROLS
    *===========================================================================
    
    * Re-run model with controls for visualization
    ologit highest_degree i.`demo'_cat `controls'
    
    * Create separate margins plots for each degree level
    local outcomes `" "Certificate" "Associate" "Bachelor's" "Master's" "Doctoral" "'
    local outcome_num = 1
    
    foreach outcome of local outcomes {
        margins `demo'_cat, predict(outcome(`outcome_num')) atmeans
        marginsplot, ///
            name(deg_`demo'_`outcome_num', replace) ///
            title("`outcome'") ///
            ytitle("Predicted Probability") ///
            xtitle("") ///
            recast(bar) ///
            plotopts(barwidth(0.6) fcolor("`aggieblue'%70") lcolor("`aggieblue'")) ///
            ciopts(color(black) lwidth(medium)) ///
            ylabel(0(0.1)1, format(%3.1f)) ///
            scheme(white_tableau)
        
        local ++outcome_num
    }
    
    * Combine all degree levels into one graph
    if "`demo'" == "gender" {
        local demo_title "Gender"
    }
    else {
        local demo_title "Sexual Orientation"
    }
    
    graph combine deg_`demo'_1 deg_`demo'_2 deg_`demo'_3 deg_`demo'_4 deg_`demo'_5, ///
        title("Predicted Probability of Degree Aspirations by `demo_title'", size(med)) ///
        cols(3) ///
        scheme(white_tableau) ///
        ycommon
    
    graph export $csacprojdir/fig/thsj_rr/degree_`demo'_combined.png, replace width(4000)
    
    * Alternative: Focus on highest degree (Doctoral) only
    margins `demo'_cat, predict(outcome(5)) atmeans
    marginsplot, ///
        title("Predicted Probability of Aspiring to Doctoral Degree", size(med)) ///
        ytitle("Predicted Probability") ///
        xtitle("`demo_title' Category", size(med)) ///
        recast(bar) ///
        plotopts(barwidth(0.6) fcolor("`aggieblue'%70") lcolor("`aggieblue'")) ///
        ciopts(color(black) lwidth(medium)) ///
        ylabel(0(0.1)0.5, format(%3.1f)) ///
        xlabel(, angle(45) labsize(small)) ///
        scheme(white_tableau)
    
    graph export $csacprojdir/fig/thsj_rr/degree_`demo'_doctoral.png, replace width(3000)

    * Alternative: Focus on master's degree only
    margins `demo'_cat, predict(outcome(4)) atmeans
    marginsplot, ///
        title("Predicted Probability of Aspiring to Master's Degree", size(med)) ///
        ytitle("Predicted Probability") ///
        xtitle("`demo_title' Category", size(med)) ///
        recast(bar) ///
        plotopts(barwidth(0.6) fcolor("`aggieblue'%70") lcolor("`aggieblue'")) ///
        ciopts(color(black) lwidth(medium)) ///
        ylabel(0(0.1)0.5, format(%3.1f)) ///
        xlabel(, angle(45) labsize(small)) ///
        scheme(white_tableau)
    
    graph export $csacprojdir/fig/thsj_rr/degree_`demo'_master.png, replace width(3000)




    ************** collapsed category margins plot
    ologit highest_degree_2 i.`demo'_cat `controls'

    margins `demo'_cat, predict(outcome(4)) atmeans
    marginsplot, ///
        title("Predicted Probability of Aspiring to Master's/Doctoral Degree", size(med)) ///
        ytitle("Predicted Probability") ///
        xtitle("`demo_title' Category", size(med)) ///
        recast(bar) ///
        plotopts(barwidth(0.6) fcolor("`aggieblue'%70") lcolor("`aggieblue'")) ///
        ciopts(color(black) lwidth(medium)) ///
        ylabel(0(0.1)0.5, format(%3.1f)) ///
        xlabel(, angle(45) labsize(small)) ///
        scheme(white_tableau)
    
    graph export $csacprojdir/fig/thsj_rr/degree2_`demo'_master.png, replace width(3000)



}


tab gender_cat highest_degree, row 

log close 