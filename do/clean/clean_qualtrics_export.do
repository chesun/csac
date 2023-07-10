********************************************************************************
/* clean 2023 CSAC high school senior survey data exported from Qualtrics */
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

log using $csacprojdir/log/clean/clean_qualtrics_export.smcl, replace

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
drop status recipientfirstname recipientlastname recipientemail externalreference distributionchannel userlanguage
drop *firstclick *lastclick *clickcount

//---------------------------------------------------------------------------
// create identifier crosswalk
//---------------------------------------------------------------------------

// minimal cleaning to produce crosswalk: rename variables and label them
rename responseid id
label var id "unique response id"

rename locationlatitude latitude
rename locationlongitude longitude

rename q5 email
label var email "email address which received survey link"

rename q86 email_fall
label var email_fall "email to contact in the fall"

// delete observations with missing email
drop if email==""

// preserve dataset
preserve

keep id ipaddress latitude longitude email email_fall

label data "Identifying information crosswalk for CSAC HS Senior survey 2023"

compress
save $csacdatadir/restricted/csac_hs_senior_2023_id_xwalk.dta, replace


//---------------------------------------------------------------------------
// clean the anonymized dataset
//---------------------------------------------------------------------------
restore


// rename and label all other variables
rename durationinseconds duration_sec
label var duration_sec "survey duration in seconds"

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

rename q6_pagesubmit t_senior
label var t_senior "time spent on 'are you a current hs senior', in seconds"
rename q7 senior
label var senior "are you a current hs senior"

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


// if idk college
rename q24_pagesubmit t_inf_no_college
label var t_inf_no_college "time spent on 'which might influence decision not to attend college', in seconds"
rename q25 inf_no_college
label var inf_no_college "which of these might influence your decision not to attend college"

// summer shcool plans
rename q26_pagesubmit t_plan_summer_class
label var t_plan_summer_class "time spent on 'do you plan to take summer college class', in seconds"
rename q27 plan_summer_class
label var plan_summer_class "do you plan to take summer college classes"

// summer school nudge
rename q28_pagesubmit t_summer_nudge
label var t_summer_nudge "time spent on the summer nudge page, in seconds"
rename q30 likely_summer_class
label var likely_summer_class "after summer nudge how likely to take summer classes"

// majors and paying for college
rename q31_pagesubmit t_major
label var t_major "time spent on 'what are you most likely to study in college, in seconds"
rename q32 major
label var major "what are you most likely to study in college"

rename q33_pagesubmit t_pay_plan
label var t_pay_plan "time spent on 'how do you plan to pay for college', in seconds"
rename q34 pay_plan
label var pay_plan "how do you plan to pay for college tuition and fees"

// student loan
rename q36_pagesubmit t_loan_pay_10k
label var t_loan_pay_10k "time spent on 'how much do you have to pay back if you borrow 10k', in seconds"
rename q37_1 loan_pay_10k
label var loan_pay_10k "how much do you have to pay back if you borrow 10k"

rename q38_pagesubmit t_loan_pay_50k
label var t_loan_pay_50k "time spent on 'how much do you have to pay back if you borrow 50k', in seconds"
rename q39_1 loan_pay_50k
label var loan_pay_50k "how much do you have to pay back if you borrow 50k"

rename q40_pagesubmit t_loan_borrow_amount
label var t_loan_borrow_amount "time spent on 'how much do you plan to borrow', in seconds"
rename q41 loan_borrow_amount
label var loan_borrow_amount "how much do you plan to borrow"

// college experience expectation
rename q42_pagesubmit t_highest_degree
label var t_highest_degree "time spent on 'what is the highest degree you hope to complete', in seconds"
rename q43 highest_degree
label var highest_degree "what is the highest degree you hope to complete"

rename q44_pagesubmit t_worry
label var t_worry "time spent on 'how worried about following in college' (not discrim), in seconds"

rename tuition worry_tuition
label var worry_tuition "how worried are you about affording tuition fees"
rename living worry_living
label var worry_living "how worried are you about living expenses"
rename academic worry_academic
label var worry_academic "how worried are you about performing well academically"
rename work worry_work
label var worry_work "how worried are you about balancing work obligations"
rename family worry_family
label var worry_family "how worried are you about balancing family obligations"
rename community worry_community
label var worry_community "how worried are you about finding community"
rename living_away worry_away
label var worry_away "how worried are you about living away from home"
rename support worry_support
label var worry_support "how worried about having adequate support for emotional and mental health needs"

// note: there is not a timing question for worry about discrimination in college
rename race worry_race
label var worry_race "how worried about discrimination based on race"
rename gender worry_gender
label var worry_gender "how worried about discrimination based on gender"
rename so worry_so
label var worry_so "how worried about discrimination based on sexual orientation"
rename religion worry_religion
label var worry_religion "how worried about discrimination based on religion"

// note: there is no timing question for the number of online class question
rename q47 num_online_class
label var num_online_class "how many college classes do you plan to take online"

// CCC full time nudge
rename q48_pagesubmit t_ccc_ft
label var t_ccc_ft "time spent on CCC FT nudge, in seconds"

rename q49 ccc_ft_yn
label var ccc_ft_yn "did you know cal grant $8000 for 15 credits"

// high school experience
rename q52_pagesubmit t_hs_academic
label var t_hs_academic "time spent on 'how do you rate HS academic experience', in seconds"
rename q53 hs_academic
label var hs_academic "how do you rate HS academic experience"

rename q54_pagesubmit t_hs_social
label var t_hs_social "time spent on 'how do you rate HS social experience', in seconds"
rename q55 hs_social
label var hs_social "how do you rate your HS social experience"

// high school belonging
rename q56_pagesubmit t_hs_belong
label var t_hs_belong "time spent on high school belonging questions, in seconds"
rename q57_1 hs_community_belong
label var hs_community_belong "I belong in my high school community"
rename q57_2 hs_teacher_care
label var hs_teacher_care "teachers and staff at my HS care about my future"
rename q57_3 hs_good_advising
label var hs_good_advising "I received good advising from HS about college"
rename q57_4 hs_prepared_college
label var hs_prepared_college "I feel prepared for college"

// high school bullying
rename q58_pagesubmit t_times_bullied
label var t_times_bullied "time spent on 'in last 12 months how many times were you bullied', in seconds"
rename q59 times_bullied
label var times_bullied "number of times bullied or harassed at school last 12 months"

    // reasons bullied was displayed only if number of times bullied in previous question was greater than 0
    rename q60_pagesubmit t_reasons_bullied
    label var t_reasons_bullied "time spent on 'were you bullied for any of following reasons', in seconds"
    rename q61 reasons_bullied
    label var reasons_bullied "in last 12 months were you harassed or bullied for any of the following reasons"

// demographics
rename q62_pagesubmit t_hs_type
label var t_hs_type "time spent on 'type of hs you are graduating from', in seconds"
rename q63 hs_type
label var hs_type "type of high school you are graduating from"

rename q64_pagesubmit t_intro_demo
label var t_intro_demo "time spent on the introduction paragraph for demographics section, in seconds"

rename q66_pagesubmit t_race
label var t_race "time spent on race/ethnicity, in seconds"
rename q67 race
label var race "race/ethnicity"

/* note: there was a page break between the timing question (q68) and the parent education question (q69)
so the time spent on parent education question was not captured */
rename q69 parent_edu
label var parent_edu "highest level of education among parents"

rename q70_pagesubmit t_primary_english
label var t_primary_english "time spent on 'was English primary language at home', in seconds"
rename q71 primary_english
label var primary_english "growing up was English the primary language spoken at home"

rename q72_pagesubmit t_primary_lang
label var t_primary_lang "time spent on 'what was primary language at home when growing up', in seconds"
rename q73 primary_lang
label var primary_lang "primary lanaguage at home growing up"

rename q74_pagesubmit t_has_job
label var t_has_job "time spent on 'do you currentlly have a job', in seconds"
rename q75 has_job
label var has_job "do you currently have job"

    // there is no timing for this question; displayed only if previous question answer is yes
    rename q76 job_hours
    label var job_hours "how many hours a wekk do you work at your job"

rename q77_pagesubmit t_agab
label var t_agab "time spent on 'what is your assigned sex at birth', in seconds"
rename q78 agab
label var agab "assigned sex at birth on birth certificate"

rename q79_pagesubmit t_gender
label var t_gender "time spent on 'what is yoru current gender identity', in seconds"
rename q80 gender
label var gender "current gender identity"
rename q80_5_text gender_other
label var gender_other "current gender other: please specify"

rename q81_pagesubmit t_so
label var t_so "time spent on sexual orientation, in seconds"
rename q82 so
label var so "sexual orientation"
rename q82_6_text so_other
label var so_other "sexual orientation other: please specify"

rename q83_pagesubmit t_followup
label var t_followup "time spent on 'woudl you like to participate in future interviews', in seconds"
rename q84 followup
label var followup "would you like to participate in future interview about transition to college"

// fall email question is already renamed when creating identifier crosswalk
rename q85_pagesubmit t_email_fall
label var t_email_fall "time spent on fall email"


// open ended why not college
rename q87_pagesubmit t_college_whynot
label var t_college_whynot "time spent on 'why not planning to attend college in fall', in seconds"
rename q88 college_whynot
label var college_whynot "why not planning to attend college in fall"

// open ended college expectation
rename q89_pagesubmit t_college_excited
label var t_college_excited "time spent on 'what are you most excited about college', in seconds"
rename q90 college_excited
label var college_excited "what are you most excited about college"

rename q91_pagesubmit t_college_challenge
label var t_college_challenge "time spent on 'what is the biggest challenge you'll face in college', in seconds"
rename q92 college_challenge
label var college_challenge "what is the biggest challenge you'll face in college"



//--------------------------------------------------------------
// clean embedded data
//--------------------------------------------------------------
drop attend_college attend_ccc expect_loan

label var summer_nudge "in summer class nudge treatment"
label var ccc_ft_nudge "in CCC full time nudge treatment"


//--------------------------------------------------------------
// drop incomplete responses
//--------------------------------------------------------------
keep if finished=="True"

// double check using the finished and progress vars 
tab finished 
tab progress


//--------------------------------------------------------------
// recode variables 
//--------------------------------------------------------------

// convert all timing vars from string to numeric 
destring t_*, replace 
// put all timing vars at end of dataset
order t_*, last

****** convert senior to dummy
// define value label for senior dummy
label define senior 0 "No" 1 "Yes"
encode senior, generate(senior_temp) label(senior)
 
// assign var label of senior to the temp dummy
label var senior_temp "`: var lab senior'"
drop senior 
rename senior_temp senior 

****** recode how did you hear about importance of aid app
// define value label for new categorical variable 
#delimit ;
label define hear_import_aid 
    1 "High school staff (counselor, teacher, etc.)"
    2 "Financial aid workshop"
    3 "Online website"
    4 "Print media (Flyer, postcard, billboard, bus ad, etc.)"
    5 "Public service announcement"
    6 "Word of mouth"
    7 "Other (please specify)"
    ;
#delimit cr
// create categorical variable based on original string var
encode hear_import_aid, generate(hear_import_aid_temp) label(hear_import_aid)
// copy var label 
label var hear_import_aid_temp "`: var lab hear_import_aid'"
drop hear_import_aid
rename hear_import_aid_temp hear_import_aid




local date2 = c(current_date)
local time2 = c(current_time)

di "Do file start date time: `date1' `time1'"
di "End date time: `date2' `time2'"



log close
translate $csacprojdir/log/clean/clean_qualtrics_export.smcl ///
    $csacprojdir/log/clean/clean_qualtrics_export.txt, replace
