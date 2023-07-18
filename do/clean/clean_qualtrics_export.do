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
import delimited $csacrawdatadir/csac_hs_senior_2023_export_07_05_2023.csv, varnames(1) rowrange(4:) clear

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
// remove leading and trailing blanks
foreach v in email email_fall {
    replace `v' = strtrim(`v')
}

// preserve dataset
preserve

keep id ipaddress latitude longitude email email_fall

label data "Identifying information crosswalk for CSAC HS Senior survey 2023"

compress
save $csacrawdatadir/csac_hs_senior_2023_id_xwalk.dta, replace


//---------------------------------------------------------------------------
// clean the anonymized dataset
//---------------------------------------------------------------------------
restore

// drop personally identifiable information 
drop id ipaddress latitude longitude email email_fall

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
rename q47 prop_online_class
label var prop_online_class "how many college classes do you plan to take online"

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
drop q68_pagesubmit 

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
    rename q76 hours_job
    label var hours_job "how many hours a wekk do you work at your job"

rename q77_pagesubmit t_asab
label var t_asab "time spent on 'what is your assigned sex at birth', in seconds"
rename q78 asab
label var asab "assigned sex at birth on birth certificate"

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

****** convert all timing vars from string to numeric 
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
// this is a check all that apply question 
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


****** recode were you required by your high school to file FAFSA
label define hs_req_fafsa 0 "No" 1 "Yes"
encode hs_req_fafsa, generate(hs_req_fafsa_temp) label(hs_req_fafsa)
label var hs_req_fafsa "`: var lab hs_req_fafsa'"
drop hs_req_fafsa
rename hs_req_fafsa_temp hs_req_fafsa

****** recode: support you received in completing FAFSA/CADAA, check all that apply
#delimit ;
label define fafsa_support
    1 "High school counselor"
    2 "Teacher"
    3 "FAFSA workshop or training at your high school"
    4 "FAFSA workshop at community location outside of high school"
    5 "Parent"
    6 "Family member other than parent"
    7 "Friend"
    8 "Nobody (I completed it on my own)"
    ;
#delimit cr

encode fafsa_support, generate(fafsa_support_temp) label(fafsa_support)
label var fafsa_support_temp "`: var lab fafsa_support'"
drop fafsa_support
rename fafsa_support_temp fafsa_support 


****** recode: do you plan to attend college in the fall?
label define college_fall 0 "No" 1 "Yes" 2 "I don't know"

encode college_fall, generate(college_fall_temp) label(college_fall)
label var college_fall_temp "`: var lab college_fall'"
drop college_fall
rename college_fall_temp college_fall

****** recode: where do you plan to attend college?
/* this question is only shown if participant answered Yes to college_fall */
#delimit ;
label define where_college
    1 "California Community College (CCC)"
    2 "California State University (CSU)"
    3 "University of California (UC)"
    4 "Private four-year college/university in California"
    5 "Vocational, technical, or career college in California"
    6 "College outside of California"
    ;
#delimit cr

encode where_college, generate(where_college_temp) label(where_college)
label var where_college_temp "`: var lab where_college'"
drop where_college
rename where_college_temp where_college

****** recode: has your college contacted you about your financial aid?
label define college_contact 0 "No" 1 "Yes"
encode college_contact, generate(college_contact_temp) label(college_contact)
label var college_contact_temp "`: var lab college_contact'"
drop college_contact
rename college_contact_temp college_contact

****** recode: has your college contacted you about the following regarding your financial aid?
/* this is a check all that reply question. It is only shown if college_contact is Yes */
#delimit ;
label define college_contact_item
    1 "FAFSA/CADAA verification (additional documentation needed to process financial aid)"
    2 "Financial aid offer/award letter"
    3 "Eligibility for work study"
    4 "Information about loans"
    ;
#delimit cr 
encode college_contact_item, generate(college_contact_item_temp) label(college_contact_item)
label var college_contact_item_temp "`: var lab college_contact_item'"
drop college_contact_item
rename college_contact_item_temp college_contact_item

****** recode: what do you think you'll be doing this fall?
/* this is check all that apply. It is only shown if college_fall is No */
#delimit ;
label define fall_plan
    1 "Work part-time"
    2 "Work full-time"
    3 "Family obligations"
    4 "Military"
    ;
#delimit cr 
encode fall_plan, generate(fall_plan_temp) label(fall_plan)
label var fall_plan_temp "`: var lab fall_plan'"
drop fall_plan
rename fall_plan_temp fall_plan

****** recode: Which of the following might influence your decision of whether or not to attend college? 
/* this is check all that apply. only shown if college_fall is I don't know */
label define inf_no_college 1 "Financial support" 2 "Academic support" 3 "Family or other support"
encode inf_no_college, generate(inf_no_college_temp) label(inf_no_college)
label var inf_no_college_temp "`: var lab inf_no_college'"
drop inf_no_college
rename inf_no_college_temp inf_no_college

****** recode: Do you plan to take college classes this summer?
#delimit ;
label define plan_summer_class
    -2 "Definitely not"
    -1 "Probably not"
    0 "Not sure"
    1 "Probably yes"
    2 "Definitely yes"
    ;
#delimit cr 
encode plan_summer_class, generate(plan_summer_class_temp) label(plan_summer_class)
label var plan_summer_class_temp "`: var lab plan_summer_class'"
drop plan_summer_class
rename plan_summer_class_temp plan_summer_class

****** recode: After taking this information into account, how likely are you to take college classes this summer?
/*  this is the summer nudge question */
#delimit ;
label define likely_summer_class 
    -2 "Extremely unlikely"
    -1 "Somewhat unlikely"
    0 "Not sure"
    1 "Somewhat likely"
    2 "Extremely likely"
    ;
#delimit cr 
encode likely_summer_class, generate(likely_summer_class_temp) label(likely_summer_class)
label var likely_summer_class_temp "`: var lab likely_summer_class"
drop likely_summer_class
rename likely_summer_class_temp likely_summer_class

****** recode: What are you most likely to study in college?
#delimit ;
label define major
    1 "Business"
    2 "Engineering"
    3 "Natural sciences (e.g., biology, chemistry, physics)"
    4 "Social sciences (e.g., psychology, sociology, economics)"
    5 "Humanities & Arts (e.g., English, History, Arts)"
    6 "Health sciences"
    7 "Education"
    8 "Applied sciences (e.g., automotive repair, HVAC, construction)"
    9 "Public service (e.g., criminal justice, fire science)"
    10 "Undecided"
    ;
#delimit cr 
encode major, generate(major_temp) label(major)
label var major_temp "`: var lab major'"
drop major 
rename major_temp major 

****** recode: How do you plan to pay college tuition and fees? 
/* (Check all that apply) */
#delimit ;
label define pay_plan
    1 "Scholarships"
    2 "Grants (e.g., Pell Grant, Cal Grant)"
    3 "My own savings"
    4 "Working while enrolled"
    5 "Money from other people (e.g., family and friends)"
    6 "Student loans"
    7 "Military/VA benefits"
    8 "Credit card(s)"
    ;
#delimit cr 
encode pay_plan, generate(pay_plan_temp) label(pay_plan)
label var pay_plan_temp "`: var lab pay_plan'"
drop pay_plan
rename pay_plan_temp pay_plan

****** recode: 
/* Imagine that you borrowed $10,000 in student loans to pay for college. 
How much do you think you would actually be required to pay back? 
In other words, how much of these loans do you think would not be forgiven? */
destring loan_pay_10k, replace 

****** recode:
/* Imagine that you borrowed $50,000 in student loans to pay for college. 
How much do you think you would actually be required to pay back? 
In other words, how much of these loans do you think would not be forgiven? */
destring loan_pay_50k, replace 

****** recode: You indicated you plan to take out student loans. How much do you plan to borrow in student loans?
#delimit ;
label define loan_borrow_amount
    1 "Less than $5K"
    2 "$6K to $10K"
    3 "$11K to $20K"
    4 "$21K to $50K"
    5 "$51K to $100K"
    6 "More than $100K"
    ;
#delimit cr 
encode loan_borrow_amount, generate(loan_borrow_amount_temp) label(loan_borrow_amount)
label var loan_borrow_amount_temp "`: var lab loan_borrow_amount'"
drop loan_borrow_amount
rename loan_borrow_amount_temp loan_borrow_amount


****** recode: What is the highest degree you hope to earn after you have completed all of your schooling?
#delimit ;
label define highest_degree
    1 "Get a certificate in a vocational or technical field"
    2 "Associate degree  (AA/AS/ADT)"
    3 "Bachelor’s Degree (BA/BS)"
    4 "Master’s Degree (MA/MS)"
    5 "Doctoral Degree (Ph.D., M.D., J.D., etc.)"
    ;
#delimit cr 
encode highest_degree, generate(highest_degree_temp) label(highest_degree)
label var highest_degree_temp "`: var lab highest_degree'"
drop highest_degree
rename highest_degree_temp highest_degree


****** recode: When you think about college, how worried are you about the following? (matrix)
****** recode: When you think about college, how worried are you about experiencing discrimination because of your: (matrix)
// define value label that's common to all questions in above two categories
#delimit ;
label define worry 
    0 "Not at all worried"
    1 "Slightly worried"
    2 "Somewhat worried"
    3 "Very worried"
    ;
#delimit cr 
foreach v of varlist worry_* {
    encode `v', generate(`v'_temp) label(worry)
    label var `v'_temp "`: var lab `v''"
    drop `v'
    rename `v'_temp `v'
}


****** recode: When thinking about your college classes, how many do you plan to take online?
#delimit ;
label define prop_online_class
    0 "None"
    -1 "One or two"
    -2 "Half"
    -3 "Most"
    -4 "All"
    ;
#delimit cr 
encode prop_online_class, generate(prop_online_class_temp) label(prop_online_class)
label var prop_online_class_temp "`: var lab prop_online_class'"
drop prop_online_class
rename prop_online_class_temp prop_online_class

****** recode: CCC full time nudge 
/* You indicated you plan to enroll in a California Community College next year. 
ommunity college students eligible for the Cal Grant can receive as much as $8000 a year 
in extra grant aid for taking 15 units each term (4-5 classes). This money could be used for 
living expenses and other costs, and would not need to be paid back.

Prior to taking this survey, did you know that Cal Grant recipients could get this additional 
money for enrolling in 15 units each term? */
label define ccc_ft_yn 0 "No" 1 "Yes"
encode ccc_ft_yn, generate(ccc_ft_yn_temp) label(ccc_ft_yn)
label var ccc_ft_yn_temp "`: ccc_ft_yn'"
drop ccc_ft_yn
rename ccc_ft_yn_temp ccc_ft_yn

****** recode: How would you rate your academic performance in high school?
****** recode: How would you rate your social experience in high school?
// common value label
#delimit ;
label define hs_experience
    1 "Poor"
    2 "Fair"
    3 "Good"
    4 "Very Good"
    5 "Excellent"
    ;
#delimit cr 

foreach v in hs_academic hs_social {
    encode `v', generate(`v'_temp) label(hs_experience)
    label var `v'_temp "`: var lab `v''"
    drop `v'
    rename `v'_temp `v'
}


****** recode: Please indicate your agreement with the following statements. 
/* this is a matrix question with 4 statements: 
hs_community_belong: I feel that I belong in my high school community  
hs_teacher_care: Teachers and staff at my high school care about my future
hs_good_advising: I received good advising from my high school about my college plans
hs_prepared_college: I feel prepared for college
*/
#delimit ;
label define hs_belong 
    -2 "Strongly disagree"
    -1 "Somewhat disagree"
    0 "Neither agree nor disagree"
    1 "Somewhat agree"
    2 "Strongly agree"
    ;
#delimit cr 

foreach v in hs_community_belong hs_teacher_care hs_good_advising hs_prepared_college {
    encode `v', generate(`v'_temp) label(hs_belong)
    label var `v'_temp "`: var lab `v''"
    drop `v'
    rename `v'_temp `v'
}

****** recode: During the past 12 months, how many times on school property were you harassed or bullied?
#delimit ;
label define times_bullied
    0 "0 times"
    1 "1 time"
    2 "2-3 times"
    3 "4 or more times"
    ; 
#delimit cr 

encode times_bullied, generate(times_bullied_temp) label(times_bullied)
label var times_bullied_temp "`: var lab times_bullied'"
drop times_bullied
rename times_bullied_temp times_bullied

    ****** recode: During the past 12 months, were you harassed or bullied for any of the following reasons? 
    /* (Check all that apply) this is only shown if time_bullied is not 0 */
    #delimit ;
    label define reasons_bullied
        1 "Because of your race or ethnicity"
        2 "Because of your religion"
        3 "Because of your gender identity"
        4 "Because of your sexual orientation"
        ;
    #delimit cr 

    encode reasons_bullied, generate(reasons_bullied_temp) label(reasons_bullied)
    label var reasons_bullied_temp "`: var lab reasons_bullied'"
    drop reasons_bullied
    rename reasons_bullied_temp reasons_bullied

****** recode: Please tell us what type of high school you are graduating from:
#delimit ;
label define hs_type
    1 "Public high school (including charter)"
    2 "Private/Parochial high school"
    3 "Home school"
    ;
#delimit cr 

encode hs_type, generate(hs_type_temp) label(hs_type)
label var hs_type_temp "`: var lab hs_type'"
drop hs_type
rename hs_type_temp hs_type



****** recode: Please indicate your race/ethnicity 
/* (Check all that apply) */
#delimit ;
label define race
    1 "Black/African American"
    2 "American Indian/Alaskan Native"
    3 "Asian"
    4 "Filipino"
    5 "Hispanic/Latinx"
    6 "Pacific Islander"
    7 "White/Non-Hispanic"
    8 "Other"
    ;
#delimit cr 

encode race, generate(race_temp) label(race)
label var race_temp "`: var lab race'"
drop race 
rename race_temp race 

****** recode: When you were growing up, was English the primary language spoken in your home?
label define primary_english 0 "No" 1 "Yes"

encode primary_english, generate(primary_english_temp) label(primary_english)
label var primary_english_temp "`: var lab primary_english'"
drop primary_english
rename primary_english_temp primary_english

****** do not need to recode: What language was primarily spoken in your home when you were growing up?
/* this is a text entry question . it is only shown if primary_english is No */

****** recode: Do you currently have a job?
label define has_job 0 "No" 1 "Yes"

encode has_job, generate(has_job_temp) label(has_job)
label var has_job_temp "`: var lab has_job'"
drop has_job
rename has_job_temp has_job

****** recode: How many hours a week do you work at your job?
/* this is only shown if has_job is Yes */
#delimit ;
label define hours_job
    1 "Less than 10"
    2 "10-19"
    3 "20-30"
    4 "More than 30"
    ;
#delimit cr 

encode hours_job, generate(hours_job_temp) label(hours_job)
label var hours_job_temp "`: var lab hours_job'"
drop hours_job
rename hours_job_temp hours_job



//-------------------------------------------------------
// cleaning and recoding the gender and sexual orientation variables 
//-------------------------------------------------------

****** recode gender variable 
replace gender = "Other" if gender=="Other (please feel free to specify)"

****** generate a var for assigned gender at birth
/* translate male/female from assigned sex at birth to man/woman for assigned gender at birth */
gen agab =""
replace agab = "MAN" if asab=="Male"
replace agab = "WOMAN" if asab=="Female"
label var agab "assigned gender at birth"




****** generate new variables for gender and sexual orientation 
tab gender 
tab so 
tab gender_other 
tab so_other 

// first clean the gender and so vars and gender_other and so_other text responses 
foreach v in gender so gender_other so_other {
    // convert to upper case
    replace `v' = strupper(`v')
    // collapse internal multiple blanks to one blank 
    replace `v' = stritrim(`v')
    // remove leading and trailing blanks
    replace `v' = strtrim(`v')
    // remove dashes "-"
    replace `v' = subinstr(`v', "-", "", .)
} 

// check tabulation again 
tab gender 
tab so 
tab gender_other
tab so_other

****** create a cleaned gender variable 
// clean the gender_other free response text 
gen gender_other_clean = gender_other
label var gender_other_clean "cleaned gender other free text response"

// collapse categories of free response gender
/* collapsed categories:
1. NONBINARY
    includes mentions of nonbinary, they/them
2. GENDERFLUID:
    includes mentions of genderfluid  
3. OTHERGNC (other gender nonconforming)
    includes mentions of gender non conforming, androgyne, demiboy(girl), bigender, twospirit,
    agender, genderqueer
4. UNSURE/QUESTIONING
    includes mentions of unsure, unknown, uncertain, questioning, i don't know, IDK
5. WOMAN
    includes mentions of transfem, woman, girl
6. MAN
    includes mentions of transmasc, man, boy
** NOTE: by coding nonbinary first, any mention of nonbinary transmasc/fem will be coded as nonbinary 
7. CISGENDER/OTHER
    includes any other responses not in the previous 6 categories, such as overtly queerphobic ones, e.g. attack helicopter
    assume they are cisgender 
*/
#delimit ;

replace gender_other_clean = "NONBINARY"
    if strpos(gender_other, "NONBINARY")!=0
    | strpos(gender_other, "NON BINARY")!=0
    | strpos(gender_other, "THEY/THEM")!=0
    ;

replace gender_other_clean = "GENDERFLUID"
    if strpos(gender_other, "GENDERFLUID")!=0
    | strpos(gender_other, "GENDER FLUID")!=0
    | strpos(gender_other, "FLUID")!=0
    ;

replace gender_other_clean = "OTHERGNC"
    if strpos(gender_other, "GENDER NONCONFORMING")!=0
    | strpos(gender_other, "GENDERNONCONFORMING")!=0
    | strpos(gender_other, "GENDER NON CONFORMING")!=0
    | strpos(gender_other, "ANDROGYNE")!=0
    | strpos(gender_other, "ANDROGYNOUS")!=0
    | strpos(gender_other, "DEMIBOY")!=0
    | strpos(gender_other, "DEMOGIRL")!=0
    | strpos(gender_other, "BIGENDER")!=0 
    | strpos(gender_other, "TWOSPIRIT")!=0 
    | strpos(gender_other, "TWO SPIRIT")!=0
    | strpos(gender_other, "AGENDER")!=0
    | strpos(gender_other, "GENDERQUEER")!=0
    | strpos(gender_other, "GENDER QUEER")!=0
    ;

replace gender_other_clean = "UNSURE/QUESTIONING"
    if strpos(gender_other, "UNSURE")!=0
    | strpos(gender_other, "UNKNOWN")!=0
    | strpos(gender_other, "UNCERTAIN")!=0
    | strpos(gender_other, "QUESTIONING")!=0
    | strpos(gender_other, "I DON'T KNOW")!=0
    | strpos(gender_other, "IDK")!=0
    | strpos(gender_other, "NOT SURE")!=0
    ;

replace gender_other_clean = "WOMAN"
    if strpos(gender_other, "WOMAN")!=0
    | strpos(gender_other, "GIRL")!=0
    | strpos(gender_other, "TRANSFEM")!=0
    | strpos(gender_other, "TRANSFEMME")!=0
    | strpos(gender_other, "TRANSFEM")!=0
    ;

replace gender_other_clean = "MAN"
    if strpos(gender_other, "MAN")!=0
    | strpos(gender_other, "BOY")!=0
    | strpos(gender_other, "TRANSMASCULINE")!=0
    | strpos(gender_other, "TRANSMASC")!=0
    ;

replace gender_other_clean = "CISGENDER/OTHER"
    if 
    gender_other_clean!="NONBINARY"
    & gender_other_clean!="GENDERFLUID"
    & gender_other_clean!="OTHERGNC"
    & gender_other_clean!="UNSURE/QUESTIONING"
    & gender_other_clean!="WOMAN"
    & gender_other_clean!="MAN"
    & !mi(gender_other_clean)
    ;

#delimit cr 



// create an overall gender variable that combines the free text response with the choice question
gen gender_clean = gender
label var gender_clean "cleaned current gender identity"
replace gender_clean = gender_other_clean if !mi(gender_other_clean)
// assume that people who responded irrelevant/quetab geerphobic text are cisgender, populate with assigned gender at birth 
replace gender_clean = agab if gender_other_clean=="CISGENDER/OTHER"

tab gender_clean

rename gender gender_raw 
rename gender_other gender_other_raw

// there are 5 observations which chose "other" for gender but did not write text response. assume they are cisgender
replace gender_clean = agab if gender_clean=="OTHER"

/* NOTE: of the 147 people who reported prefer not to say for gender, 
- 11 are straight
- 58 chose prefer not to say for sexual orientation
- the rest are all non-straight  
Therefore, there is good reason to classify them as likely to be not cisgender 
*/
tab so if gender_clean=="PREFER NOT TO SAY"
tab so_other if gender_clean=="PREFER NOT TO SAY"

//------------------------------------------------
/* NOTE: gender_trans_binary==1 is a subset of 
gender_trans_gnc==1, which is a subset of 
cisgender==0 */
//------------------------------------------------
// create a dummy for cisgender
/* code prefer not to say and unsure/questioning as non-cis */
gen gender_cis = .
replace gender_cis=0 if gender_clean!=agab & !mi(gender_clean) 
replace gender_cis=1 if gender_clean==agab & !mi(gender_clean)
label var gender_cis "cisgender"

tab gender_cis 

// create a dummy for umbrella transgender, a broad definition that inludes everyone whose agab is different from current gender
// this includes trans, nb, gnc, genderfluid, EXCLUDES unsure/questioning and prefer not to say
// ***** !!!!!NOTE: THIS VARIABLE IS NOT THE COMPLEMENT OF gender_cis!!!!! *****
gen gender_trans_gnc =.
replace gender_trans_gnc=1 if gender_cis==0
replace gender_trans_gnc=0 if gender_cis==1 | (gender_cis==0 & gender_clean=="PREFER NOT TO SAY") | (gender_cis==0 & gender_clean=="UNSURE/QUESTIONING")
label var gender_trans_gnc "umbrella transgender, exclude unsure and prefer not to say"

tab gender_trans_gnc

// create a dummy for transgender and not nonbinary/other gnc: binary trans folks whose current gender is either man or woman
gen gender_trans_binary =.
// define not binary trans as cisgender or non-cisgender and do not identify with neither woman nor man 
replace gender_trans_binary=0 if gender_cis==1 | (gender_cis==0 & gender_clean!="WOMAN" & gender_clean!="MAN")
replace gender_trans_binary=1 if (gender_clean=="WOMAN" & agab=="MAN") | (gender_clean=="MAN" & agab=="WOMAN")
label var gender_trans_binary "binary transgender"

tab gender_trans_binary

// create a dummy for current gender is woman 
gen gender_woman =.
replace gender_woman=0 if gender_clean!="WOMAN" & !mi(gender_clean)
replace gender_woman=1 if gender_clean=="WOMAN" 
label var gender_woman "current gender is woman"

// create a dummy for current gender is man
gen gender_man =.
replace gender_man=0 if gender_clean!="MAN" & !mi(gender_clean)
replace gender_man=1 if gender_clean=="MAN" & !mi(gender_clean)
label var gender_man "current gender is man"


//-----------------------------------------------------------
// clean sexual orientation variables
//-----------------------------------------------------------
/* first clean the so_other free text response, collapse down to the following categories: 
1. PAN/QUEER
    includes mentions of PAN, QUEER, ANTHROSEXUAL, ANTROSEXUAL, OMNI, NOT STRAIGHT
2. BISEXUAL
    includes mentions of BISEXUAL, BICURIOUS
3. ASEXUAL
    includes mentions of ASEXUAL, ACE, ARO, DEMI
4. UNSURE/QUESTIONING
    includes mentions of UNSURE, UNKNOWN, UNCERTAIN, QUESTIONING, I DON'T KNOW, IDK
5. STRAIGHT/OTHER
    all others

*/

gen so_other_clean=so_other
label var so_other_clean "cleaned free text response for sexual orientation"

#delimit ;

replace so_other_clean = "PAN/QUEER"
    if 
    strpos(so_other, "PAN")!=0
    | strpos(so_other, "QUEER")!=0
    | strpos(so_other, "ANTHROSEXUAL")!=0
    | strpos(so_other, "ANTROSEXUAL")!=0
    | strpos(so_other, "OMNI")!=0
    | strpos(so_other, "NOT STRAIGHT")!=0
    ;

replace so_other_clean = "BISEXUAL"
    if 
    strpos(so_other, "BISEXUAL")!=0
    | strpos(so_other, "BICURIOUS")!=0
    ;

replace so_other_clean = "ASEXUAL"
    if 
    strpos(so_other, "ASEXUAL")!=0
    | strpos(so_other, "ACE")!=0
    | strpos(so_other, "ARO")!=0
    | strpos(so_other, "DEMI")!=0
    ;

replace so_other_clean = "UNSURE/QUESTIONING"
    if strpos(so_other, "UNSURE")!=0
    | strpos(so_other, "UNKNOWN")!=0
    | strpos(so_other, "UNCERTAIN")!=0
    | strpos(so_other, "QUESTIONING")!=0
    | strpos(so_other, "I DON'T KNOW")!=0
    | strpos(so_other, "IDK")!=0
    | strpos(so_other, "NOT SURE")!=0
    ;

replace so_other_clean = "STRAIGHT/OTHER"
    if 
    so_other_clean!="PAN/QUEER"
    & so_other_clean!="BISEXUAL"
    & so_other_clean!="ASEXUAL"
    & so_other_clean!="UNSURE/QUESTIONING"
    & !mi(so_other_clean)
    ;

#delimit cr 

tab so_other_clean

// create a cleaned sexual orientation variable
gen so_clean = so 
label var so_clean "cleaned sexual orientation including free text response"
replace so_clean = so_other_clean if strpos(so, "OTHER")!=0
replace so_clean = "STRAIGHT" if strpos(so_clean, "STRAIGHT")!=0
tab so_clean


/* **************
NOTE: so_queer_narrow==1 is a subset of 
so_queer_broad==1 which is a subset of 
so_straight==0 */
// create a dummy for striaght
// this excludes prefer not to say and unsure/questioning
gen so_straight =.
label var so_straight "straight"
replace so_straight=0 if so_clean!="STRAIGHT" & !mi(so_clean)
replace so_straight=1 if so_clean=="STRAIGHT"

tab so_straight

// create a dummy for queer (non straight) sexual orientation, narrowly defined
// excludes prefer not to say and unsure/questioning
gen so_queer_narrow =.
label var so_queer_narrow "non-straight, narrowly defined"
replace so_queer_narrow=0 if so_straight==1 | so_clean=="PREFER NOT TO SAY" | so_clean=="UNSURE/QUESTIONING"
replace so_queer_narrow=1 if so_straight==0 & so_clean!="PREFER NOT TO SAY" & so_clean!="UNSURE/QUESTIONING"

tab so_queer_narrow

// create a dummy for queer (non straight) sexual orientation, broadly defined
gen so_queer_broad = so_queer_narrow
label var so_queer_broad "non straight, broadly defined"
replace so_queer_broad=1 if so_clean=="PREFER NOT TO SAY" | so_clean=="UNSURE/QUESTIONING"

tab so_queer_broad

rename so so_raw 
rename so_other so_other_raw




****** recode: What is the highest level of education completed among either of your parents (or those who raised you)?
#delimit ;
label define parent_edu
    1 "Did not complete high school"
    2 "High school diploma"
    3 "Some college, no college degree"
    4 "Associate degree"
    5 "Bachelor's degree"
    6 "Graduate/Professional degree beyond Bachelor's degree (Master's, PhD, JD, MD, etc.)"
    7 "Don't know"
    ;
#delimit cr 

encode parent_edu, generate(parent_edu_temp) label(parent_edu)
label var parent_edu_temp "`: var lab parent_edu'"
drop parent_edu
rename parent_edu_temp parent_edu

****** clean the open ended college questions at the end
foreach v in college_whynot college_excited college_challenge {
    // convert to upper case 
    replace `v' = strupper(`v')
    // collapse internal blanks to one space, and remove leading and trailing blanks
    replace `v' = stritrim(`v')
    replace `v' = strtrim(`v')
}


label data "Fully cleaned CSAC 2023 HS senior survey data"
compress 

save $csacclndatadir/csac_hs_senior_2023_clean, replace 


local date2 = c(current_date)
local time2 = c(current_time)

di "Do file start date time: `date1' `time1'"
di "End date time: `date2' `time2'"



log close
translate $csacprojdir/log/clean/clean_qualtrics_export.smcl ///
    $csacprojdir/log/clean/clean_qualtrics_export.txt, replace
