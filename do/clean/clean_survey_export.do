********************************************************************************
/* clean CSAC high school senior survey data exported from Qualtrics */
********************************************************************************
************************ Written by Christina Sun 07/05/2023 *******************

/* Change Log:
*/

/* Notes:
* The data imported by this do file is downloaded from Qualtrics on July 5, 2023
at 15:43. The csv file needs to be opened and the 2nd and 3rd rows (question text
and tags) deleted manually before being imported to Stata.
 */


 /* to run this do file:
 do $csacprojdir/do/clean/clean_survey_export.do
 */

cap log close _all

log using $projdir/log/clean/clean_survey_export.smcl, replace

graph drop _all
set more off
set varabbrev off
set graphics off
set scheme s1color
set seed 1984

local date1 = c(current_date)
local time1 = c(current_time)



// import csv data, see notes for requirements for manual cleaning before import
import delimited $csacdatadir/raw/csac_hs_senior_2023_07_05_2023.csv, clear 





local date2 = c(current_date)
local time2 = c(current_time)

di "Do file start date time: `date1' `time1'"
di "End date time: `date2' `time2'"



log close 
translate $projdir/log/clean/clean_survey_export.smcl ///
    $projdir/log/clean/clean_survey_export.txt, replace 

