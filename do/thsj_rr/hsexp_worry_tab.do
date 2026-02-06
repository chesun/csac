/* create HS experience and worry item tables by gender/SO */

/* 
do $csacprojdir/do/thsj_rr/hsexp_worry_tab.do
 */

cap log close _all
log using $csacprojdir/log/thsj_rr/hsexp_worry_tab.txt, text replace 

use "$csacprojdir/dta/cln/csac_hs_senior_2023_genderso.dta", clear


* outcomes
* hs experience & bullying 
local allhsexp hs_academic hs_social hs_community_belong hs_teacher_care hs_good_advising hs_prepared_college 
local bully    times_bullied reasons_bullied_igenderso

* college plans
local plans    college_fall segment major highest_degree

* college worries
local allworries worry_tuition worry_living worry_academic worry_work worry_family worry_community worry_away worry_support worry_gender worry_so worry_race worry_religion

// gender labels
local gender_0_str "Cisgender Man" 
local gender_1_str "Cisgender Woman" 
local gender_2_str "Transgender Man" 
local gender_3_str "Transgender Woman" 
local gender_4_str "Non-binary" 
local gender_5_str "Gender Diverse/Questioning" 
local gender_6_str "Prefer Not to Say"

// SO labels
local so_0_str "Straight/Heterosexual" 
local so_1_str "Gay or Lesbian" 
local so_2_str "Bisexual/Pansexual/Omnisexual" 
local so_3_str "Asexual/Aromantic/Demisexual" 
local so_4_str "Other/Queer/Questioning" 
local so_5_str "Prefer Not to Say"


//----- Survey item table, by gender
foreach items in hsexp worries {
    foreach demo in gender so {
        table (var) `demo'_cat, statistic(mean `all`items'') statistic(count `all`items'') 
        * Customize formatting
        collect style cell result[mean], nformat(%9.3f)
        collect style cell result[count], nformat(%9.0fc)

        * Rename the count label to "N"
        collect label levels result mean "Mean", modify
        collect label levels result count "N", modify

        * Add spacing between variables
        collect style row stack, spacer
        
        collect export $csacprojdir/tab/thsj_rr/`items'_`demo'.docx, replace
    }
}



log close 