/* To run this master do file, type:

cd "/home/research/ca_ed_lab/projects/csac_survey2023/christina"
do $csacprojdir/do/do_all.do

 */

// set working directory and set global project settings

cd "/home/research/ca_ed_lab/projects/csac_survey2023/christina"
do do/settings.do

cap log close _all

log using $cs_csacprojdir/log/do_all.smcl, replace 

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


// clean survey data exported from qualtrics 
do $cs_csacprojdir/do/clean/clean_qualtrics_export.do





local date2 = c(current_date)
local time2 = c(current_time)

di "Do file start date time: `date1' `time1'"
di "End date time: `date2' `time2'"

log close 
translate $cs_csacprojdir/log/do_all.smcl ///
    $cs_csacprojdir/log/do_all.txt, replace 