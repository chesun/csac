********************************************************************************
/* 2023 CSAC high school senior survey master do file */
********************************************************************************

********************************* Preamble ************************************

*----------*
* Toggle
*----------*
global user_cs 0
global user_bz 1



* Toggle If First Time Running: to create output folders
local mkdir 0



if `mkdir' == 1 {
global csacprojdir "/home/research/ca_ed_lab/projects/csac_survey2023"

mkdir "$csacprojdir/dta"  //store all output tables
mkdir "$csacprojdir/dta/cln" // store cleaned data 

mkdir "$csacprojdir/tab"  //store all output tables
mkdir "$csacprojdir/tab/learn" // create subfolder within tables
mkdir "$csacprojdir/tab/learn/demog" 

mkdir "$csacprojdir/fig"  //store all output figures
mkdir "$csacprojdir/fig/learn" // create subfolder within figures
mkdir "$csacprojdir/fig/learn/crosstab" // create subfolder within figures
mkdir "$csacprojdir/fig/learn/brief"

mkdir "$csacprojdir/log" // store all log files
mkdir "$csacprojdir/log/clean" // create subfolder within log 
mkdir "$csacprojdir/log/learn" 
}

if $user_cs == 1{

/* To run this master do file, type:

cd "/home/research/ca_ed_lab/users/chesun/gsr/csac"
do %csacprojdir/do/do_all.do

 */

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


local date1 = c(current_date) 
local time1 = c(current_time)

ssc install ngram, replace 



// clean survey data exported from qualtrics 
do $csacprojdir/do/clean/clean_qualtrics_export.do





local date2 = c(current_date)
local time2 = c(current_time)

di "Do file start date time: `date1' `time1'"
di "End date time: `date2' `time2'"

log close 
translate $csacprojdir/log/do_all.smcl ///
    $csacprojdir/log/do_all.txt, replace 
}

if $user_bz == 1{
cd "/home/research/ca_ed_lab/projects/csac_survey2023" // first thing first


// overall project directory
global csacprojdir "/home/research/ca_ed_lab/projects/csac_survey2023"

// raw data directory
global csacrawdatadir "/home/research/ca_ed_lab/data/restricted_access/raw/csac_survey/2023"

// direcotry: a copy of cleaned data in project folder
global csacclndatadir "$csacprojdir/dta/cln"


* Clean and save ready-to-analyze data to project folder
do "$csacprojdir/do/clean/clean_qualtrics_export.do"

* Generate Codebook
do "$csacprojdir/do/clean/create_codebook.do"

* Prepare data for main brief
do "$csacprojdir/do/clean/prep_brief.do"

}
