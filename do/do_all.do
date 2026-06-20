********************************************************************************
/* 2023 CSAC high school senior survey master do file */
* Author: Christina Sun
* ucsun@ucdavis.edu
* christinasun101@gmail.com
********************************************************************************
/* 
CHANGE LOG:
- May 31, 2026: add full do file pipeline, remove user toggle, absorbed do_all_baiyu.do -CS
 */
********************************* Preamble ************************************


// set working directory and set global project settings
cd "/home/research/ca_ed_lab/projects/csac_survey2023"
do do/settings.do

cap log close _all

log using $csacprojdir/log/do_all.smcl, replace 

clear all
pause off


graph drop _all
set more off
set varabbrev off
set graphics off
set scheme s1color
set seed 1984



ssc install ngram, replace 

* Toggle If First Time Running: to create output folders
local mkdir 0



if `mkdir' == 1 {
global csacprojdir "/home/research/ca_ed_lab/projects/csac_survey2023"

cap mkdir "$csacprojdir/dta"  //store all output tables
cap mkdir "$csacprojdir/dta/cln" // store cleaned data 

cap mkdir "$csacprojdir/tab"  //store all output tables
cap mkdir "$csacprojdir/tab/learn" // create subfolder within tables
cap mkdir "$csacprojdir/tab/learn/demog" 

cap mkdir "$csacprojdir/fig"  //store all output figures
cap mkdir "$csacprojdir/fig/learn" // create subfolder within figures
cap mkdir "$csacprojdir/fig/learn/crosstab" // create subfolder within figures
cap mkdir "$csacprojdir/fig/learn/brief"

cap mkdir "$csacprojdir/log" // store all log files
cap mkdir "$csacprojdir/log/clean" // create subfolder within log 
cap mkdir "$csacprojdir/log/learn" 
}

*-------------- DATA CLEANING
* clean survey data exported from qualtrics 
do $csacprojdir/do/clean/clean_qualtrics_export.do
* Generate Codebook
do "$csacprojdir/do/clean/create_codebook.do"
* Prepare data for main brief
do "$csacprojdir/do/clean/prep_brief.do"
* Prep data for gender paper analysis - detailed categorization of gender & so
do "$csacprojdir/do/clean/genderso.do"

*------------- DATA ANALYSIS: PACE BRIEF + GENDER PAPER
* crosstabs for PACE brief
do "$csacprojdir/do/learn/brief.do"
* Export Gender/SO other raw expresions to create word cloud
do "$csacprojdir/do/learn/expression.do"
* Quantitative Analsis: some crosstabs, factor analysis, PCA, regressions
do "$csacprojdir/do/learn/paper_quant_analysis.do"
* export qualitative question data for gender paper for qual analysis 
do $csacprojdir/do/learn/qual_export.do


*------------ SUMMER SCHOOL RCT PAPER
* construct dataset with survey data and CSAC admin data
do $csacprojdir/do/experiments/make_csac_data.do
* clean CCC data and create a ssn - college+student id xwalk
do $csacprojdir/do/experiments/clean_ccc.do
* merge CCC student data to survey data
do $csacprojdir/do/experiments/merge_ccc.do
* clean CSAC admin variables
do $csacprojdir/do/experiments/clean_csac_admin.do
* explore the RCT results, crosstabs and t tests, export to log files
do $csacprojdir/do/experiments/explore_rct.do
* create summary statistics tables 
do $csacprojdir/do/experiments/sum_stats.do
* create regression tables: summer enrollment, units attempted, units earned, GPA
do $csacprojdir/do/experiments/reg_tab.do
* final version of regression results
do $csacprojdir/do/experiments/reg_share.do
* heterogeneity analysis by 2y vs 4y, Pell status, baseline intentions
do $csacprojdir/do/experiments/het.do


*------------- R&R GENDER PAPER: THE HIGH SCHOOL JOURNAL
// CS: some of the changes for R&R and GDTF was implemented in paper_quant_analysis.do
* check the availability of CSAC admin data for LGBTQ students, auxiliary file.
do $csacprojdir/do/thsj_rr/check_csac_data.do
* create HS experience and worry item tables by gender/SO
do $csacprojdir/do/thsj_rr/hsexp_worry_tab.do
* demographics summary table for qualitative analysis sample
do $csacprojdir/do/thsj_rr/qual_demo_tab.do
*------- THSJ round 2 revisions
* reviewer 2 comments 1-3
do "$csacprojdir/do/thsj_rr/r2_revisions.do"
* print standardized worry index regression coefs
do "$csacprojdir/do/thsj_rr/r2_worry_coefs.do"

*-------------- GETTING DOWN TO FACTS REPORT 
* summary statistics for demographics using CDE annual enrollment data 
do $csacprojdir/do/getting_down_to_facts/cde_demographics.do
* regressions for Getting Down to Facts 
do $csacprojdir/do/getting_down_to_facts/gdtf_reg.do
* Address miscellaneous reviewer questions and requests
do $csacprojdir/do/getting_down_to_facts/gdtf_adhoc.do
* Produces bare-tabular LaTeX fragments for CS dissertation Chapter 3 tables
* Personal use, non-production code
do $csacprojdir/do/getting_down_to_facts/gdtf_latex_tables.do



* sub-do-files each run `cap log close _all`, which closes this master log
* early, so a bare `log close` here errors r(606). cap makes the exit clean.
cap log close _all
translate $csacprojdir/log/do_all.smcl ///
    $csacprojdir/log/do_all.txt, replace 




