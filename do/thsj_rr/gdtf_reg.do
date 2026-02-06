/* regressions for Getting Down to Facts */

/* 
do $csacprojdir/do/thsj_rr/gdtf_reg.do
 */

cap log close _all
log using $csacprojdir/log/thsj_rr/gdtf_reg.txt, text replace 

use "$csacprojdir/dta/cln/csac_hs_senior_2023_genderso.dta", clear

local controls i.race_assn i.parent_edu


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

*===============================================================================
* DEGREE COMPLETION BY GENDER, FIGURE 4
*===============================================================================

foreach demo in gender so {
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
            plotopts(barwidth(0.6) fcolor(navy%70) lcolor(navy)) ///
            ciopts(color(black) lwidth(medium)) ///
            ylabel(0(0.1)1, format(%3.1f)) ///
            scheme(s2color)
        
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
        scheme(s2color) ///
        ycommon
    
    graph export $csacprojdir/fig/thsj_rr/degree_`demo'_combined.png, replace width(4000)
    
    * Alternative: Focus on highest degree (Doctoral) only
    margins `demo'_cat, predict(outcome(5)) atmeans
    marginsplot, ///
        title("Predicted Probability of Aspiring to Doctoral Degree by `demo_title'", size(med)) ///
        ytitle("Predicted Probability") ///
        xtitle("`demo_title' Category") ///
        recast(bar) ///
        plotopts(barwidth(0.6) fcolor(navy%70) lcolor(navy)) ///
        ciopts(color(black) lwidth(medium)) ///
        ylabel(0(0.1)0.5, format(%3.1f)) ///
        xlabel(, angle(45) labsize(small)) ///
        scheme(s2color)
    
    graph export $csacprojdir/fig/thsj_rr/degree_`demo'_doctoral.png, replace width(3000)

    * Alternative: Focus on master's degree only
    margins `demo'_cat, predict(outcome(4)) atmeans
    marginsplot, ///
        title("Predicted Probability of Aspiring to Master's Degree by `demo_title'", size(med)) ///
        ytitle("Predicted Probability") ///
        xtitle("`demo_title' Category") ///
        recast(bar) ///
        plotopts(barwidth(0.6) fcolor(navy%70) lcolor(navy)) ///
        ciopts(color(black) lwidth(medium)) ///
        ylabel(0(0.1)0.5, format(%3.1f)) ///
        xlabel(, angle(45) labsize(small)) ///
        scheme(s2color)
    
    graph export $csacprojdir/fig/thsj_rr/degree_`demo'_master.png, replace width(3000)

}


tab gender_cat, highest_degree, row 

log close 