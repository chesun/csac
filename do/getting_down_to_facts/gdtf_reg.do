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
    estimates store segment_`demo'1
    estadd local demo_controls "No"

    logit segment b0.`demo'_cat `controls'
    estimates store segment_`demo'2
    estadd local demo_controls "Yes"


    * Export to Word showing only gender coefficients
    esttab segment_`demo'1 segment_`demo'2 using $csacprojdir/tab/thsj_rr/segment_models_`demo'.rtf, ///
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
    * ODDS RATIO TABLES (reviewer request)
    *===========================================================================

    * Re-export ordered logit tables with odds ratios and CIs
    esttab deg_`demo'1 deg_`demo'2 using $csacprojdir/tab/getting_down_to_facts/degree_or_`demo'.rtf, ///
        keep(*`demo'_cat*) ///
        nobaselevels ///
        eform ///
        b(%9.3f) ci(%9.3f) ///
        star(* 0.10 ** 0.05 *** 0.01) ///
        title("Ordered Logit Models: Highest Degree Plans (Odds Ratios)") ///
        nomtitles ///
        scalars("N Observations" "demo_controls Demographic Controls") ///
        label replace

    esttab deg_`demo'1 deg_`demo'2 using $csacprojdir/tab/getting_down_to_facts/degree_or_`demo'.csv, ///
        keep(*`demo'_cat*) ///
        nobaselevels ///
        eform ///
        b(%9.3f) ci(%9.3f) ///
        star(* 0.10 ** 0.05 *** 0.01) ///
        nomtitles ///
        scalars("N Observations" "demo_controls Demographic Controls") ///
        label replace

    * Also export 4-year segment logit as odds ratios
    esttab segment_`demo'1 segment_`demo'2 using $csacprojdir/tab/getting_down_to_facts/segment_or_`demo'.rtf, ///
        keep(*`demo'_cat*) ///
        nobaselevels ///
        eform ///
        b(%9.3f) ci(%9.3f) ///
        star(* 0.10 ** 0.05 *** 0.01) ///
        title("Logit Models: Intent to Attend 4-Year College (Odds Ratios)") ///
        nomtitles ///
        scalars("N Observations" "demo_controls Demographic Controls") ///
        label replace

    *===========================================================================
    * STACKED BAR: Predicted probability of each degree level by group
    *===========================================================================

    if "`demo'" == "gender" {
        local demo_title "Gender Identity"
    }
    else {
        local demo_title "Sexual Orientation"
    }

    * Run model with controls
    ologit highest_degree i.`demo'_cat `controls'

    * Extract category info and sample sizes from estimation sample before margins overwrites e()
    qui levelsof `demo'_cat, local(catvals)
    local ncat : word count `catvals'
    local i = 1
    foreach c of local catvals {
        local lab`i' : label (`demo'_cat) `c'
        qui count if `demo'_cat == `c' & e(sample)
        local n`i' = r(N)
        local lab`i' "`lab`i'' (N=`n`i'')"
        local ++i
    }

    * Get predicted probabilities for all outcomes at each category level
    margins `demo'_cat, predict(outcome(1)) predict(outcome(2)) ///
        predict(outcome(3)) predict(outcome(4)) predict(outcome(5)) atmeans ///
        post

    * Extract margins into a temporary dataset for plotting
    preserve

    * Build dataset of predicted probabilities
    clear
    set obs `ncat'
    gen group = .
    gen str60 group_lab = ""
    gen pr_cert = .
    gen pr_assoc = .
    gen pr_bach = .
    gen pr_mast = .
    gen pr_doct = .

    local i = 1
    foreach c of local catvals {
        qui replace group = `c' in `i'
        qui replace group_lab = "`lab`i''" in `i'
        * Margins stores results in order: outcome1 for all cats, then outcome2, etc.
        * Row index for cat `i', outcome j = (`j'-1)*ncat + `i'
        local r1 = 0*`ncat' + `i'
        local r2 = 1*`ncat' + `i'
        local r3 = 2*`ncat' + `i'
        local r4 = 3*`ncat' + `i'
        local r5 = 4*`ncat' + `i'

        matrix b = e(b)
        qui replace pr_cert  = b[1, `r1'] in `i'
        qui replace pr_assoc = b[1, `r2'] in `i'
        qui replace pr_bach  = b[1, `r3'] in `i'
        qui replace pr_mast  = b[1, `r4'] in `i'
        qui replace pr_doct  = b[1, `r5'] in `i'

        local ++i
    }

    * Convert to percentage for readability
    foreach v in pr_cert pr_assoc pr_bach pr_mast pr_doct {
        replace `v' = `v' * 100
    }

    * Compute cumulative positions for stacked bars
    gen cum0 = 0
    gen cum1 = pr_cert
    gen cum2 = cum1 + pr_assoc
    gen cum3 = cum2 + pr_bach
    gen cum4 = cum3 + pr_mast
    gen cum5 = cum4 + pr_doct

    * Midpoints for label placement
    gen mid1 = (cum0 + cum1) / 2
    gen mid2 = (cum1 + cum2) / 2
    gen mid3 = (cum2 + cum3) / 2
    gen mid4 = (cum3 + cum4) / 2
    gen mid5 = (cum4 + cum5) / 2

    * Y position (reverse so first group is at top)
    gen ypos = _N - _n + 1

    * Format labels — only show if segment >= 5% (otherwise too cramped)
    gen str8 slab1 = string(pr_cert, "%4.1f") + "%" if pr_cert >= 10
    gen str8 slab2 = string(pr_assoc, "%4.1f") + "%" if pr_assoc >= 10
    gen str8 slab3 = string(pr_bach, "%4.1f") + "%" if pr_bach >= 10
    gen str8 slab4 = string(pr_mast, "%4.1f") + "%" if pr_mast >= 10
    gen str8 slab5 = string(pr_doct, "%4.1f") + "%" if pr_doct >= 10

    * Collect y-axis labels for manual labeling
    local ylabels ""
    forvalues j = 1/`ncat' {
        local yval = _N - `j' + 1
        local glab = group_lab[`j']
        local ylabels `"`ylabels' `yval' "`glab'""'
    }

    * Stacked horizontal bar chart with text labels
    twoway ///
        (rbar cum0 cum1 ypos, horizontal fcolor("215 48 39") lcolor(white) lwidth(vthin) barwidth(0.7)) ///
        (rbar cum1 cum2 ypos, horizontal fcolor("252 141 89") lcolor(white) lwidth(vthin) barwidth(0.7)) ///
        (rbar cum2 cum3 ypos, horizontal fcolor("254 224 139") lcolor(white) lwidth(vthin) barwidth(0.7)) ///
        (rbar cum3 cum4 ypos, horizontal fcolor("145 191 219") lcolor(white) lwidth(vthin) barwidth(0.7)) ///
        (rbar cum4 cum5 ypos, horizontal fcolor("`aggieblue'") lcolor(white) lwidth(vthin) barwidth(0.7)) ///
        (scatter ypos mid1, msymbol(none) mlabel(slab1) mlabpos(0) mlabcolor(white) mlabsize(vsmall)) ///
        (scatter ypos mid2, msymbol(none) mlabel(slab2) mlabpos(0) mlabcolor(white) mlabsize(vsmall)) ///
        (scatter ypos mid3, msymbol(none) mlabel(slab3) mlabpos(0) mlabcolor(black) mlabsize(vsmall)) ///
        (scatter ypos mid4, msymbol(none) mlabel(slab4) mlabpos(0) mlabcolor(black) mlabsize(vsmall)) ///
        (scatter ypos mid5, msymbol(none) mlabel(slab5) mlabpos(0) mlabcolor(white) mlabsize(vsmall)) ///
        , ///
        title("Adjusted Predicted Probability of Degree Aspirations" "by `demo_title'", size(medium)) ///
        xtitle("Predicted Probability (%)", size(small)) ///
        xlabel(0(20)100, format(%3.0f)) ///
        ytitle("") ///
        ylabel(`ylabels', angle(0) labsize(tiny) nogrid) ///
        legend(order(1 "Certificate" 2 "Associate" 3 "Bachelor's" 4 "Master's" 5 "Doctoral") ///
            rows(1) size(small) position(6)) ///
        note("Predicted probabilities from ordered logit with demographic controls, evaluated at sample means.", size(vsmall)) ///
        scheme(white_tableau) ///
        graphregion(margin(l+18))

    graph export $csacprojdir/fig/getting_down_to_facts/degree_`demo'_stacked.png, replace width(4000)

    * Also export the predicted probabilities as a CSV table
    export delimited group_lab pr_cert pr_assoc pr_bach pr_mast pr_doct ///
        using $csacprojdir/tab/getting_down_to_facts/degree_margins_`demo'.csv, replace

    restore

    *===========================================================================
    * COLLAPSED CATEGORY: Stacked bar for 4-category version
    *===========================================================================

    ologit highest_degree_2 i.`demo'_cat `controls'

    * Extract category info and sample sizes from estimation sample
    qui levelsof `demo'_cat, local(catvals)
    local ncat : word count `catvals'
    local i = 1
    foreach c of local catvals {
        local lab`i' : label (`demo'_cat) `c'
        qui count if `demo'_cat == `c' & e(sample)
        local n`i' = r(N)
        local lab`i' "`lab`i'' (N=`n`i'')"
        local ++i
    }

    margins `demo'_cat, predict(outcome(1)) predict(outcome(2)) ///
        predict(outcome(3)) predict(outcome(4)) atmeans ///
        post

    preserve

    clear
    set obs `ncat'
    gen group = .
    gen str60 group_lab = ""
    gen pr_cert = .
    gen pr_assoc = .
    gen pr_bach = .
    gen pr_mastdoct = .

    local i = 1
    foreach c of local catvals {
        qui replace group = `c' in `i'
        qui replace group_lab = "`lab`i''" in `i'
        local r1 = 0*`ncat' + `i'
        local r2 = 1*`ncat' + `i'
        local r3 = 2*`ncat' + `i'
        local r4 = 3*`ncat' + `i'

        matrix b = e(b)
        qui replace pr_cert     = b[1, `r1'] in `i'
        qui replace pr_assoc    = b[1, `r2'] in `i'
        qui replace pr_bach     = b[1, `r3'] in `i'
        qui replace pr_mastdoct = b[1, `r4'] in `i'

        local ++i
    }

    foreach v in pr_cert pr_assoc pr_bach pr_mastdoct {
        replace `v' = `v' * 100
    }

    * Compute cumulative positions for stacked bars
    gen cum0 = 0
    gen cum1 = pr_cert
    gen cum2 = cum1 + pr_assoc
    gen cum3 = cum2 + pr_bach
    gen cum4 = cum3 + pr_mastdoct

    * Midpoints for label placement
    gen mid1 = (cum0 + cum1) / 2
    gen mid2 = (cum1 + cum2) / 2
    gen mid3 = (cum2 + cum3) / 2
    gen mid4 = (cum3 + cum4) / 2

    * Y position (reverse so first group is at top)
    gen ypos = _N - _n + 1

    * Format labels — only show if segment >= 5%
    gen str8 slab1 = string(pr_cert, "%4.1f") + "%" if pr_cert >= 10
    gen str8 slab2 = string(pr_assoc, "%4.1f") + "%" if pr_assoc >= 10
    gen str8 slab3 = string(pr_bach, "%4.1f") + "%" if pr_bach >= 10
    gen str8 slab4 = string(pr_mastdoct, "%4.1f") + "%" if pr_mastdoct >= 10

    * Collect y-axis labels
    local ylabels ""
    forvalues j = 1/`ncat' {
        local yval = _N - `j' + 1
        local glab = group_lab[`j']
        local ylabels `"`ylabels' `yval' "`glab'""'
    }

    twoway ///
        (rbar cum0 cum1 ypos, horizontal fcolor("215 48 39") lcolor(white) lwidth(vthin) barwidth(0.7)) ///
        (rbar cum1 cum2 ypos, horizontal fcolor("252 141 89") lcolor(white) lwidth(vthin) barwidth(0.7)) ///
        (rbar cum2 cum3 ypos, horizontal fcolor("254 224 139") lcolor(white) lwidth(vthin) barwidth(0.7)) ///
        (rbar cum3 cum4 ypos, horizontal fcolor("`aggieblue'") lcolor(white) lwidth(vthin) barwidth(0.7)) ///
        (scatter ypos mid1, msymbol(none) mlabel(slab1) mlabpos(0) mlabcolor(white) mlabsize(vsmall)) ///
        (scatter ypos mid2, msymbol(none) mlabel(slab2) mlabpos(0) mlabcolor(white) mlabsize(vsmall)) ///
        (scatter ypos mid3, msymbol(none) mlabel(slab3) mlabpos(0) mlabcolor(black) mlabsize(vsmall)) ///
        (scatter ypos mid4, msymbol(none) mlabel(slab4) mlabpos(0) mlabcolor(white) mlabsize(vsmall)) ///
        , ///
        title("Adjusted Predicted Probability of Degree Aspirations" "by `demo_title'", size(medium)) ///
        xtitle("Predicted Probability (%)", size(small)) ///
        xlabel(0(20)100, format(%3.0f)) ///
        ytitle("") ///
        ylabel(`ylabels', angle(0) labsize(tiny) nogrid) ///
        legend(order(1 "Certificate" 2 "Associate" 3 "Bachelor's" 4 "Master's/Doctoral") ///
            rows(1) size(small) position(6)) ///
        note("Predicted probabilities from ordered logit with demographic controls, evaluated at sample means.", size(vsmall)) ///
        scheme(white_tableau) ///
        graphregion(margin(l+18))

    graph export $csacprojdir/fig/getting_down_to_facts/degree2_`demo'_stacked.png, replace width(4000)

    export delimited group_lab pr_cert pr_assoc pr_bach pr_mastdoct ///
        using $csacprojdir/tab/getting_down_to_facts/degree2_margins_`demo'.csv, replace

    restore



}


tab gender_cat highest_degree, row 

log close 