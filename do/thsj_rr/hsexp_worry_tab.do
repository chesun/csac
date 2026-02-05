/* create HS experience and worry item tables by gender/SO */

/* 
do $csacprojdir/do/thsj_rr/hsexp_worry_tab.do
 */

use "$csacprojdir/dta/cln/csac_hs_senior_2023_genderso.dta", clear


* outcomes
* hs experience & bullying 
local allhsexp hs_academic hs_social hs_community_belong hs_teacher_care hs_good_advising hs_prepared_college 
local bully    times_bullied reasons_bullied_igenderso

* college plans
local plans    college_fall segment major highest_degree

* college worries
local allworries worry_tuition worry_living worry_academic worry_work worry_family worry_community worry_away worry_support worry_gender worry_so worry_race worry_religion


estpost tabstat `allhsexp', stat(mean N) by(gender_cat) columns(variables)
esttab . using $csacprojdir/tab/thsj_rr/hsexp_items_bygender.rtf, cells("mean(fmt(a3)) N") replace 
estpost tabstat `allhsexp', stat(mean N) by(so_cat) columns(variables)
esttab . using $csacprojdir/tab/thsj_rr/hsexp_items_byso.rtf, cells("mean(fmt(a3)) N") append 

