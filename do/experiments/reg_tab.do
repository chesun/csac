/* create regression tables 
outcomes: 
- summer enrollment
- units attempted
- units earned
- GPA
 */


/* 
do $csacprojdir/do/experiments/reg_tab.do
 */
cap log close _all
set graphics off 
log using $csacprojdir/log/experiments/reg_tab.txt, text replace

local figdir $csacprojdir/fig/experiments
local tabdir $csacprojdir/tab/experiments

use $csacprojdir/dta/cln/csac_survey_ccc_merged_clean.dta, clear  


local controls_svy i.race_simp i.gender_brief i.hs_type i.lgbtq i.primary_eng i.parent_edu
local controls_csac i.derived_income_cat hs_gpa i.efc_cat i.parent_marital 
local controls_all `controls_svy' `controls_csac'


foreach yvar in enr_su units_att_su units_earn_su gpa_su {
    sum `yvar'
    local mean_`yvar': di %4.3f r(mean)
    local sd_`yvar': di %4.3f r(sd)

    reg `yvar' i.treat_summer
    estadd local ind_controls "No"
    estadd scalar ymean = `mean_`yvar''
    estadd scalar ysd = `sd_`yvar''
    eststo m_`yvar'_noc 

    reg `yvar' i.treat_summer `controls_all'
    estadd local ind_controls "Yes"
    estadd scalar ymean = `mean_`yvar''
    estadd scalar ysd = `sd_`yvar''
    eststo m_`yvar'_yesc
}

#delimit ;
    esttab m_*
        using `tabdir'/reg_main.tex, replace
        nonumbers unstack booktabs   
        parentheses  
        label  noobs  scalars("N Observations") 
        nocons
        keep(1.treat_summer)
        coeflabels(1.treat_summer "Summer Nudge Treatment") 
        mtitles("Enrollment" "Enrollment" "Units Enrolled" "Units Enrolled" 
            "Units Earned" "Units Earned" "GPA" "GPA") 
        b(%12.3fc) se(%12.3fc) 
        star(* 0.1 ** 0.05 *** 0.01) 
        s(ymean ysd ind_controls N 
            , fmt(%9.0f) 
            label("Mean of Y" "SD of Y" "Individual Controls" "Observations"))
        nonotes 
    ;

    esttab m_*
        using `tabdir'/reg_main.csv, replace
        nonumbers unstack    
        parentheses  
        label  noobs  scalars("N Observations") 
        nocons
        keep(1.treat_summer)
        coeflabels(1.treat_summer "Summer Nudge Treatment") 
        mtitles("Enrollment" "Enrollment" "Units Enrolled" "Units Enrolled" 
            "Units Earned" "Units Earned" "GPA" "GPA") 
        b(%12.3fc) se(%12.3fc) 
        star(* 0.1 ** 0.05 *** 0.01) 
        s(ymean ysd ind_controls N 
            , fmt(%4.3f %4.3f %9.0f) 
            label("Mean of Y" "SD of Y" "Individual Controls" "Observations"))
        nonotes 
    ;
#delimit cr
    
est clear 