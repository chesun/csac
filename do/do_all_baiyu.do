********************************************************************************
/* 2023 CSAC high school senior survey - Baiyu's Dofiles */
* Baiyu Zhou (Off Board Spring 2024)
* UC Davis Email: baizhou@ucdavis.edu
* Personal Email: baiyu.b.zhou@mgmail.com

* To run all the dofiles:
* do "/home/research/ca_ed_lab/projects/csac_survey2023/do/do_all_baiyu.do"
********************************************************************************


/* Change Directory */
cd "/home/research/ca_ed_lab/projects/csac_survey2023" // first thing first

global csacprojdir "/home/research/ca_ed_lab/projects/csac_survey2023"
global csacrawdatadir "/home/research/ca_ed_lab/data/restricted_access/raw/csac_survey/2023"
global csacclndatadir "$csacprojdir/dta/cln"



*** First Round Processing for All Projects ***

// Clean and save ready-to-analyze data to project folder
do "$csacprojdir/do/clean/clean_qualtrics_export.do"

// Generate Codebook
do "$csacprojdir/do/clean/create_codebook.do"



*** PACE Brief Analysis ***
// Prep data set for PACE analysis: categorize race & gender
do "$csacprojdir/do/clean/prep_brief.do"

// Analysis: crosstabs
do "$csacprojdir/do/learn/brief.do"


*** Gender Paper ***
// Prep data for gender paper analysis - detailed categorization of gender & so; Export an excel spreadsheet for qualitative analysis 
do "$csacprojdir/do/clean/genderso.do"

// Export Gender/SO other raw expresions to create word clouse
do "$csacprojdir/do/learn/expression.do"

// Quantitative Analsis: some crosstabs, factor analysis, PCA, regressions
do "$csacprojdir/do/learn/paper_quant_analysis.do"




