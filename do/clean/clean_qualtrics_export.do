********************************************************************************
/* clean CSAC high school senior survey data exported from Qualtrics */
********************************************************************************
************************ Written by Christina Sun 07/05/2023 *******************

/* Change Log:
*/

/* Notes:
* The data imported by this do file is downloaded from Qualtrics on July 5, 2023
at 15:43. The 2nd and 3rd rows contain only question names and import tags and 
thus do not need to be imported. First row is variable names.
 */


 /* to run this do file:
 do $csacprojdir/do/clean/clean_qualtrics_export.do
 */

cap log close _all

log using $projdir/log/clean/clean_qualtrics_export.smcl, replace

graph drop _all
set more off
set varabbrev off
set graphics off
set scheme s1color
set seed 1984

local date1 = c(current_date)
local time1 = c(current_time)



// import csv data, variable names in first row, discard row 2 and 3 (question names and import tags, not data)
import delimited $csacdatadir/raw/csac_hs_senior_2023_export_07_05_2023.csv, varnames(1) rowrange(4:) clear 

// drop unused variables 
drop status recipientlastname recipientlastname recipientemail externalreference distributionchannel userlanguage
drop q1_version q1_resolution 
drop *firstclick *lastclick *clickcount

//---------------------------------------------------------------------------
// create identifier crosswalk 
//---------------------------------------------------------------------------

// minimal cleaning to produce crosswalk: rename variables and label them 
rename responseid id 
label id "unique response id"

rename locationlatitude latitude 
rename locationlongitude longitude 

rename q5 email 
label email "email address which received survey link"

rename q86 email_fall 
label email_fall "email to contact in the fall"

// delete observations with missing email
drop if email==""

// preserve dataset 
preserve 

keep id ipaddress latitude longitude email email_fall

label data "Identifying information crosswalk for CSAC HS Senior survey 2023"

save $csacdatadir/restricted/csac_hs_senior_2023_id_xwalk.dta, replace 


//---------------------------------------------------------------------------
// clean the anonymized dataset 
//---------------------------------------------------------------------------
restore 


// rename and label all other variables 
rename durationinseconds duration_sec
label duration_sec "survey duration in seconds"

// recode start date and end date into stata date time format 
foreach var in startdate enddate recordeddate {
    gen `var'_temp = Clock(`var', "YMD hms")
    format %tC `var'_temp
    drop `var'
    rename `var'_temp `var'
}
order startdate enddate recordeddate

// convert the progress and duration in seconds vars to numeric
destring progress duration_sec, replace 
label var progress "survey progress"
label var duration_sec "survey duration in seconds"

// rename and label metadata vars 
rename q1_browser device_browser
label var device_browser "browser"

rename q1_version device_version
label var device_version "browser version"

rename q1_operatingsystem device_os 
label var device_os "operating system"

rename q1_resolution device_res
label var device_res "device resolution"

//--------------------------------------------------------------
// go through vars in order, rename and label 
//--------------------------------------------------------------

// high school senior status and financial aid application
rename q3_pagesubmit t_conset
label var t_conset "time spent on consent and email page in seconds"

rename q6_pagesubmit t_current_senior
label var t_current_senior "time spent on 'are you a current hs senior', in seconds"
rename q7 current_senior 
label var current_senior "are you a current hs senior"

rename q8_pagesubmit t_hear_import_aid
label var t_hear_import_aid "time spent on 'how did you hear about the importance of fin aid app', in seconds"
rename q9 hear_import_aid
label var hear_import_aid "how did you hear about the importance of fin aid app"
rename q9_7_text hear_import_aid_other
label var hear_import_aid_other "other: specify for how did you hear about importance of fin aid"

rename q10_pagesubmit t_hs_req_fafsa
label var t_hs_req_fafsa "time spent on 'did your high school require FAFSA', in seconds"
rename q11 hs_req_fafsa
label var hs_req_fafsa "did your hs require FAFSA/CADAA"

rename q12_pagesubmit t_fafsa_support
label var t_fafsa_support "time spent on 'support you received completing FAFSA', in seconds"
rename q13 fafsa_support 
label var fafsa_support "support you received completing FAFSA/CADAA"


// college plans 
rename q14_pagesubmit t_college_fall
label var t_college_fall "time spent on 'do you plan to attend college in the fall', in seconds"
rename q15 college_fall 
label var college_fall "do you plan to attend college in the fall"

rename q16_pagesubmit t_where_college
label var t_where_college "time spent on 'where do you plan to attend college in the fall', in seconds"
rename q17 where_college
label var where_college "where do you plan to attend college this fall"

rename q18_pagesubmit t_college_contact
label var t_college_contact "time spent on 'has your college contacted you about fin aid', in seconds"
rename q19 college_contact 
label var college_contact "has your college contacted you about fin aid"

rename q20_pagesubmit t_college_contact_item
label var t_college_contact_item "time spent on 'has your college contacted about following about aid', in seconds"
rename q21 college_contact_item 
label var college_contact_item "has your college contacted you about following about aid"

// if not college
rename q22_pagesubmit t_fall_plan 
label var t_fall_plan "time spent on 'what you plan to do this fall', in seconds"
rename q23 fall_plan 
label var fall_plan "what is your plan for this fall"






local date2 = c(current_date)
local time2 = c(current_time)

di "Do file start date time: `date1' `time1'"
di "End date time: `date2' `time2'"



log close 
translate $projdir/log/clean/clean_qualtrics_export.smcl ///
    $projdir/log/clean/clean_qualtrics_export.txt, replace 

