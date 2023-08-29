/******************************************************************************
PROGRAM: Prepare data for brief. 

Description: This program use cleaned data, restrict sample to HS senior, and
construct ready to use race, gender, and sexual orientaion variables.
RACE:
- race_assn: mutually exlusive with multi-ethnic assigned by hierachy or URM
- race_simp: mutually exclusive with multi-ethnic group into "two or more"
GENDER: 
- gender_brief: muturally exclusive 5 categories: cis-woman, cis-man, 
		trans-binary (both man and women), nonbinary/other, unsure
SEXUAL ORIENTATION:
- so_brief: mutually exclusive 3 categories: straight, non-straight, unsure


WRITTEN BY: Baiyu Zhou (baizhou@ucdavis.edu)

DATE CREATED: July 25, 2023

UPDATES: 
[BZ]08/29/2023: Completed race_assn for multi-race/ethinicity
		Include reasons_bully into Check-all-that-apply decomp
[BZ]08/02/2023: Check-all-that-apply combo -> all inclusive dummy
including: race_clean hear_import_aid fafsa_support fall_plan inf_no_college college_contact_item pay_plan

*******************************************************************************/


********************************* Preamble ************************************
*----------*
* Toggle
*----------*
local standalone 1


*----------*
* Settings
*----------*
if `standalone' == 1{

* Set settings
version 17.0
graph drop _all
set more off
set varabbrev off
*set graphics off
set scheme s1color
set seed 1984


* Set default directory // comment out if run the master do file
cd "/home/research/ca_ed_lab/projects/csac_survey2023"
global csacprojdir "/home/research/ca_ed_lab/projects/csac_survey2023"

}

* Log results
cap log close
log using "$csacprojdir/log/clean/prep_brief.txt", text replace

********************************* Main ****************************************

* Load fully cleaned data
use "$csacprojdir/dta/cln/csac_hs_senior_2023_clean.dta", clear

* Sample: HS senior
keep if senior == 1


*===================================*
* ChecK All That Apply To Dummies
*===================================*
*------*
* Prep *
*------*
summ hear_import_aid fafsa_support fall_plan inf_no_college college_contact_item pay_plan reasons_bullied // verify numerical

* decode categories from num to string for text search
foreach var in hear_import_aid fafsa_support fall_plan inf_no_college college_contact_item pay_plan reasons_bullied{
	decode `var', gen(`var'_str)
}


*----------*
* Generate *
*----------*
*** Each indicator has the format: `var'_i`abbrcat' ***

/* Q2: hear_import_aid */

* hsstaff: High school staff (counselor, teacher, etc.)
gen hear_import_aid_ihsstaff = 0 if !mi(hear_import_aid) // set default to 0 if not missing
replace hear_import_aid_ihsstaff = 1 if strpos(hear_import_aid_str, "High school staff (counselor, teacher, etc.)")!=0
label var hear_import_aid_ihsstaff "selected 'High school staff (counselor, teacher, etc.)'"

* social: Social media
gen hear_import_aid_isocial = 0 if !mi(hear_import_aid) // set default to 0 if not missing
replace hear_import_aid_isocial = 1 if strpos(hear_import_aid_str, "Social media")!=0
label var hear_import_aid_isocial "selected 'Social media'"

* online: Online website
gen hear_import_aid_ionline = 0 if !mi(hear_import_aid) // set default to 0 if not missing
replace hear_import_aid_ionline = 1 if strpos(hear_import_aid_str, "Online website")!=0
label var hear_import_aid_ionline "selected 'Online website'"

* mouth: Word of mouth
gen hear_import_aid_imouth = 0 if !mi(hear_import_aid) // set default to 0 if not missing
replace hear_import_aid_imouth = 1 if strpos(hear_import_aid_str, "Word of mouth")!=0
label var hear_import_aid_imouth "selected 'Word of mouth'"

* workshop: Financial aid workshop
gen hear_import_aid_iworkshop = 0 if !mi(hear_import_aid) // set default to 0 if not missing
replace hear_import_aid_iworkshop = 1 if strpos(hear_import_aid_str, "Financial aid workshop")!=0
label var hear_import_aid_iworkshop "selected 'Financial aid workshop'"

* print: Print media
gen hear_import_aid_iprint = 0 if !mi(hear_import_aid) // set default to 0 if not missing
replace hear_import_aid_iprint = 1 if strpos(hear_import_aid_str, "Print media")!=0
label var hear_import_aid_iprint "selected 'Print media'"


* public: Public service announcement
gen hear_import_aid_ipublic = 0 if !mi(hear_import_aid) // set default to 0 if not missing
replace hear_import_aid_ipublic = 1 if strpos(hear_import_aid_str, "Public service announcement")!=0
label var hear_import_aid_ipublic "selected 'Public service announcement'"


* other: Other 
// note var hear_import_aid_other stores text response if iother == 1
// the i here is to differentiate from the free response variable
gen hear_import_aid_iother = 0 if !mi(hear_import_aid) // set default to 0 if not missing
replace hear_import_aid_iother = 1 if strpos(hear_import_aid_str, "Other")!=0
label var hear_import_aid_iother "selected 'Other'"


/* Q6: fafsa_support */

tab fafsa_support 

* counselor
gen fafsa_support_icounselor = 0 if !mi(fafsa_support) // set default to 0 if not missing
replace fafsa_support_icounselor = 1 if strpos(fafsa_support_str, "High school counselor")!=0
label var fafsa_support_icounselor "selected 'High school counselor'"

* teacher
gen fafsa_support_iteacher = 0 if !mi(fafsa_support) // set default to 0 if not missing
replace fafsa_support_iteacher = 1 if strpos(fafsa_support_str, "Teacher")!=0
label var fafsa_support_iteacher "selected 'Teacher'"

* hsworkshop
gen fafsa_support_ihsworkshop = 0 if !mi(fafsa_support) // set default to 0 if not missing
replace fafsa_support_ihsworkshop = 1 if strpos(fafsa_support_str, "FAFSA workshop or training at your high school")!=0
label var fafsa_support_ihsworkshop "selected 'FAFSA workshop or training at your high school'"

* cmworkshop
**# google doc options different from value label
gen fafsa_support_icmworkshop = 0 if !mi(fafsa_support) // set default to 0 if not missing
replace fafsa_support_icmworkshop = 1 if strpos(fafsa_support_str, "FAFSA workshop at community location")!=0
label var fafsa_support_icmworkshop "selected 'FAFSA training at community location outside of your high school'"

* parent
gen fafsa_support_iparent = 0 if !mi(fafsa_support) // set default to 0 if not missing
replace fafsa_support_iparent = 1 if strpos(fafsa_support_str, "Parent")!=0
label var fafsa_support_iparent "selected 'Parent'"

* family
gen fafsa_support_ifamily = 0 if !mi(fafsa_support) // set default to 0 if not missing
replace fafsa_support_ifamily = 1 if strpos(fafsa_support_str, "Family member other than parent")!=0
label var fafsa_support_ifamily "selected 'Family member other than parent'"

* friend
gen fafsa_support_ifriend = 0 if !mi(fafsa_support) // set default to 0 if not missing
replace fafsa_support_ifriend = 1 if strpos(fafsa_support_str, "Friend")!=0
label var fafsa_support_ifriend "selected 'Friend'"

* nobody 
**# google doc options different from value label
gen fafsa_support_inobody = 0 if !mi(fafsa_support) // set default to 0 if not missing
replace fafsa_support_inobody = 1 if strpos(fafsa_support_str, "Nobody")!=0
label var fafsa_support_inobody "selected 'Nobody (I completed it on my own)'"


/* Q7a: fall_plan */
* workpt
gen fall_plan_iworkpt = 0 if !mi(fall_plan) // set default to 0 if not missing
replace fall_plan_iworkpt = 1 if strpos(fall_plan_str, "Work part-time")!=0
label var fall_plan_iworkpt "selected 'Work part-time'"

* workft
gen fall_plan_iworkft = 0 if !mi(fall_plan) // set default to 0 if not missing
replace fall_plan_iworkft = 1 if strpos(fall_plan_str, "Work full-time")!=0
label var fall_plan_iworkft "selected 'Work full-time'"

* family
gen fall_plan_ifamily = 0 if !mi(fall_plan) // set default to 0 if not missing
replace fall_plan_ifamily = 1 if strpos(fall_plan_str, "Family obligations")!=0
label var fall_plan_ifamily "selected 'Family obligations'"

* military
gen fall_plan_imilitary = 0 if !mi(fall_plan) // set default to 0 if not missing
replace fall_plan_imilitary = 1 if strpos(fall_plan_str, "Military")!=0
label var fall_plan_imilitary "selected 'Military'"


/* Q6b: inf_no_college */
* financial
gen inf_no_college_ifinancial = 0 if !mi(inf_no_college) // set default to 0 if not missing
replace inf_no_college_ifinancial = 1 if strpos(inf_no_college_str, "Financial support")!=0
label var inf_no_college_ifinancial "selected 'Financial support'"

* academic
gen inf_no_college_iacademic = 0 if !mi(inf_no_college) // set default to 0 if not missing
replace inf_no_college_iacademic = 1 if strpos(inf_no_college_str, "Academic support")!=0
label var inf_no_college_iacademic "selected 'Academic support'"

* fam_other
gen inf_no_college_ifam_other = 0 if !mi(inf_no_college) // set default to 0 if not missing
replace inf_no_college_ifam_other = 1 if strpos(inf_no_college_str, "Family or other support")!=0
label var inf_no_college_ifam_other "selected 'Family or other support'"


/* Q7b: college_contact_item */
// varname too long. abbr to college_contact_i`cat'
* verification
gen college_contact_iverification = 0 if !mi(college_contact_item) // set default to 0 if not missing
replace college_contact_iverification = 1 if strpos(college_contact_item_str, "FAFSA/CADAA verification")!=0
label var college_contact_iverification "selected 'FAFSA/CADAA verification (additional documentation needed to process financial aid)'"

* faoffer
gen college_contact_ifaoffer = 0 if !mi(college_contact_item) // set default to 0 if not missing
replace college_contact_ifaoffer = 1 if strpos(college_contact_item_str, "Financial aid offer/award letter")!=0
label var college_contact_ifaoffer "selected 'Financial aid offer/award letter'"

* workstudy
gen college_contact_iworkstudy = 0 if !mi(college_contact_item) // set default to 0 if not missing
replace college_contact_iworkstudy = 1 if strpos(college_contact_item_str, "Eligibility for work study")!=0
label var college_contact_iworkstudy "selected 'Eligibility for work study'"

* loans
gen college_contact_iloans = 0 if !mi(college_contact_item) // set default to 0 if not missing
replace college_contact_iloans = 1 if strpos(college_contact_item_str, "Information about loans")!=0
label var college_contact_iloans "selected 'Information about loans'"


/* Q10: pay_plan */
* scholarships
gen pay_plan_ischolarships = 0 if !mi(pay_plan) // set default to 0 if not missing
replace pay_plan_ischolarships = 1 if strpos(pay_plan_str, "Scholarships")!=0
label var pay_plan_ischolarships "selected 'Scholarships'"

* grants
gen pay_plan_igrants = 0 if !mi(pay_plan) // set default to 0 if not missing
replace pay_plan_igrants = 1 if strpos(pay_plan_str, "Grants (e.g., Pell Grant, Cal Grant)")!=0
label var pay_plan_igrants "selected 'Grants (e.g., Pell Grant, Cal Grant)'"

* savings
gen pay_plan_isavings = 0 if !mi(pay_plan) // set default to 0 if not missing
replace pay_plan_isavings = 1 if strpos(pay_plan_str, "My own savings")!=0
label var pay_plan_isavings "selected 'My own savings'"

* working
gen pay_plan_iworking = 0 if !mi(pay_plan) // set default to 0 if not missing
replace pay_plan_iworking = 1 if strpos(pay_plan_str, "Working while enrolled")!=0
label var pay_plan_iworking "selected 'Working while enrolled'"

* people
gen pay_plan_ipeople = 0 if !mi(pay_plan) // set default to 0 if not missing
replace pay_plan_ipeople = 1 if strpos(pay_plan_str, "Money from other people")!=0
label var pay_plan_ipeople "selected 'Money from other people'"

* loans
gen pay_plan_iloans = 0 if !mi(pay_plan) // set default to 0 if not missing
replace pay_plan_iloans = 1 if strpos(pay_plan_str, "Student loans")!=0
label var pay_plan_iloans "selected 'Student loans'"

* military
gen pay_plan_imilitary = 0 if !mi(pay_plan) // set default to 0 if not missing
replace pay_plan_imilitary = 1 if strpos(pay_plan_str, "Military/VA benefits")!=0
label var pay_plan_imilitary "selected 'Military/VA benefits'"

* credit
gen pay_plan_icredit = 0 if !mi(pay_plan) // set default to 0 if not missing
replace pay_plan_icredit = 1 if strpos(pay_plan_str, "Credit card(s)")!=0
label var pay_plan_icredit "selected 'Credit card(s)'"


/* Q20: reasons_bullied */
* race
gen reasons_bullied_irace = 0 if !mi(reasons_bullied) // set default to 0 if not missing
replace reasons_bullied_irace = 1 if strpos(reasons_bullied_str, "race or ethnicity")
label var reasons_bullied_irace "being bullied because of race/ethnicity"

* religion
gen reasons_bullied_ireligion = 0 if !mi(reasons_bullied) // set default to 0 if not missing
replace reasons_bullied_ireligion = 1 if strpos(reasons_bullied_str, "religion")
label var reasons_bullied_ireligion "being bullied because of religion"

* gender identity
gen reasons_bullied_igender = 0 if !mi(reasons_bullied) // set default to 0 if not missing
replace reasons_bullied_igender = 1 if strpos(reasons_bullied_str, "gender identity")
label var reasons_bullied_igender "being bullied because of gender identity"

* sexual orientation
gen reasons_bullied_iso = 0 if !mi(reasons_bullied) // set default to 0 if not missing
replace reasons_bullied_iso = 1 if strpos(reasons_bullied_str, "sexual orientation")
label var reasons_bullied_iso "being bullied because of sexual orientation"

*===================*
* Race/Ethnicity
*===================*
* Survey design: 8 options. Check all apply.

* Non-response
gen race_missing = .
label var race_missing "respondent skipped race/ethinicity questions"
replace race_missing = 0 if inrange(race,1,91)
replace race_missing = 1 if race == .
//validate
assert race_missing == 1 if !inrange(race,1,91)


*----------------------------------------------------------------------------*
* All-inclusive: 1 if a race/ethinicity was selected. Not mutually exclusive 
*----------------------------------------------------------------------------*

* Generate a string version of race to do text search
decode race, gen(race_str) 

* Selected Black/African American
gen race_black = 0 if !race_missing // set default to 0 if not missing
replace race_black = 1 if strpos(race_str, "Black/African American")!=0
label var race_black "selected 'Black/African American'"

* Selected American Indian/Alaskan Native
gen race_native= 0 if race_missing == 0 // set default to 0
replace race_native = 1 if strpos(race_str, "American Indian/Alaskan Native")!=0
label var race_native "selected 'American Indian/Alaskan Native'"

* Selected Asian
gen race_asian = 0 if race_missing == 0 // set default to 0
replace race_asian= 1 if strpos(race_str, "Asian")!=0
label var race_asian "selected 'Asian'"

* Selected Filipino 
gen race_flip = 0 if race_missing == 0 // set default to 0
replace race_flip = 1 if strpos(race_str, "Filipino")!=0
label var race_flip "selected 'Filipino'"

* Selected Hispanic/Latinx
gen race_hisp= 0 if race_missing == 0 // set default to 0
replace race_hisp = 1 if strpos(race_str, "Hispanic/Latinx")!=0
label var race_hisp "selected 'Hispanic/Latinx'"

* Selected Pacific Islander
gen race_pi= 0 if race_missing == 0 // set default to 0
replace race_pi = 1 if strpos(race_str, "Pacific Islander")!=0
label var race_pi "selected 'Pacific Islander'"

* Selected White/Non-Hispanic
gen race_white= 0 if race_missing == 0 // set default to 0
replace race_white = 1 if strpos(race_str, "White/Non-Hispanic")!=0
label var race_white "selected 'White/Non-Hispanic'"

* Selected Other
gen race_other= 0 if race_missing == 0 // set default to 0
replace race_other = 1 if strpos(race_str, "Other")!=0
label var race_other "selected 'Other'"


*---------------------------------------*
* Check number of race/ethnic groups
*---------------------------------------*

/* # of race/ethnic groups  */
egen race_num = rowtotal(race_black race_native race_asian race_flip race_hisp race_pi race_white race_other)
replace race_num = . if race == .
label var race_num "number of race/ethnicity selected" 

* Validate if generated correctly
assert race_num == 1 if inrange(race, 1, 8)


*------------------------------------------------*
* FOR MAIN BRIEF: race_simp 
*------------------------------------------------*

/* race_simp : Mutually exclusive race using the 8 categories + 1 multi */
gen race_simp = .
label var race_simp "race/ethnicity reduced to 9 categories"
replace race_simp = race 	if race_num == 1
replace race_simp = 9 	if inrange(race_num,2,8)
label copy race race_simp_lbl //, replace
label def race_simp_lbl 9 "Two or more", modify
label val race_simp race_simp_lbl  


/* race_assn: move "two or more" into one of the eight based on URM */
* race_assn hierarchy: native > black > hispanic > PI > Filipino > Asian > Other > White
cap drop race_assn
cap label drop race_assn_lbl

gen race_assn = . // initiate variable
label var race_assn "race/ethnicity with `Two or more' assigned to single race following URM hierachy"
local j = 8 // numerical value reflects assignment hierachical rank 1 - 8
label define race_assn_lbl 0 "" // initiate value label for race_assn

* Assign race according to hierarchy
foreach cat in white other asian flip pi hisp black native{ // replacement happen in reverse order to make sure the lower-raned one is always replaced by the higher-ranked one
	replace race_assn = `j' if race_`cat' == 1
	local varlab: variable label race_`cat' // copy value label from indicator variables
	local varlab = subinstr("`varlab'", "selected '", "",1) // keep only the categories
	local varlab = subinstr("`varlab'", "'", "",1)
	label define race_assn_lbl `j' "`varlab'", add // update value label
	local j = `j'-1 // update numerical value
}
label val race_assn race_assn_lbl // label value


*===========*
* Gender
*===========*

*--------------*
* Indicators
*--------------*

/* Missing */
* Indicator for missing assigned sex at birth
gen asab_missing = 1 if asab == ""
replace asab_missing = 0 if !mi(asab)
label var asab_missing "respondent skipped assigned sex at birth"

* Indicator for missing gender identity
gen gender_missing = 1 if gender_clean == ""
replace gender_missing = 0 if gender_clean != ""
label var gender_missing "respondent skipped gender-identity question"

tab asab_missing gender_missing 

/* Categories */
* Indicator for cisgender (gender identity is the same as assigned sex as birth)
gen gender_cis = .
replace gender_cis = 0 if gender_clean!=agab & !mi(gender_clean) & !mi(asab)
replace gender_cis = 1 if gender_clean==agab & !mi(gender_clean) & !mi(asab)
assert gender_cis == . if asab == ""
assert gender_cis == . if gender_clean == ""
label var gender_cis "cisgender"

* Indicator for gender identity is woman 
gen gender_woman =.
replace gender_woman=0 if gender_clean!="WOMAN" & !mi(gender_clean)
replace gender_woman=1 if gender_clean=="WOMAN" 
label var gender_woman "woman"

* Indicator for gender identity is man
gen gender_man =.
replace gender_man=0 if gender_clean!="MAN" & !mi(gender_clean)
replace gender_man=1 if gender_clean=="MAN" & !mi(gender_clean)
label var gender_man "man"

* Indicator for non-binary/other gender identity (exclude unsure/prefer not to say)
gen gender_other = .
label var gender_other "gender nonbinary, fluid, nonconforming"
replace gender_other = 0 if gender_missing == 0
replace gender_other = 1 if gender_clean == "GENDERFLUID" | gender_clean == "NONBINARY" | gender_clean == "OTHERGNC" 
assert gender_other == . if gender_clean == ""

* Indicator for unsure 
gen gender_unsure = 0 if gender_missing == 0
label var gender_unsure "unsure/questioning"
replace gender_unsure = 1 if gender_clean == "UNSURE/QUESTIONING"
assert gender_other == . if gender_clean == ""

* Indicator for prefer not to say
gen gender_pnts = 0 if gender_missing == 0
label var gender_pnts "prefer not to say"
replace gender_pnts = 1 if gender_clean == "PREFER NOT TO SAY"
assert gender_pnts == . if gender_clean == ""


* Validate muturally exclisive & add up to one.
assert gender_man + gender_woman + gender_other + gender_unsure + gender_pnts == 1 if gender_missing == 0

*-----------------------*
* GENDER FOR MAIN BRIEF
*-----------------------*

gen gender_brief = . 
label var gender_brief "gender for main brief"

replace gender_brief = 0 if gender_cis == 1 & gender_woman == 1 // cis-woman as baseline
replace gender_brief = 1 if gender_cis == 1 & gender_man == 1 // cis-man

replace gender_brief = 2 if gender_cis == 0 & gender_woman == 1  // trans-woman
replace gender_brief = 2 if gender_cis == 0 & gender_man == 1 // + trans-man group together

replace gender_brief = 3 if gender_other == 1 // nonbinary, fluid, nonconforming
replace gender_brief = 4 if gender_unsure == 1
replace gender_brief = 5 if gender_pnts == 1

assert gender_brief == . if gender_missing == 1

label def gender_brief_lbl 0 "cis woman" 1 "cis man" 2 "binary trans" 3 "other" 4 "unsure" 5 "prefer not to say"
label val gender_brief gender_brief_lbl


*====================*
* Sexual Orientation
*====================*

*------------*
* Indicators
*------------*

* Indicator for missing
gen so_missing = 1 if so_clean == ""
replace so_missing = 0 if so_clean != ""
label var so_missing "respondent skipped sexual orientation question"

* Indicator for straight
gen so_straight =.
label var so_straight "straight"
replace so_straight=0 if so_clean!="STRAIGHT" & !mi(so_clean)
replace so_straight=1 if so_clean=="STRAIGHT"

* Indicator for non-straight
gen so_queer = 0 if so_missing == 0
label var so_queer "non-straight"
replace so_queer = 1 if so_clean == "ASEXUAL"
replace so_queer = 1 if so_clean == "BISEXUAL"
replace so_queer = 1 if so_clean == "LESBIAN OR GAY"
replace so_queer = 1 if so_clean == "PAN/QUEER"

* Indicator for unsure 
gen so_unsure = 0 if so_missing == 0
replace so_unsure = 1 if so_clean == "UNSURE/QUESTIONING"
label var so_unsure "sexual orientation unsure"

* Indicator for prefer not to say 
gen so_pnts = 0 if so_missing == 0
replace so_pnts = 1 if so_clean == "PREFER NOT TO SAY"
label var so_pnts "sexual orientation prefer not so say"

* Validate mutually exclusive & add up to one
assert so_pnts + so_unsure + so_queer + so_straight == 1 if !mi(so_clean)


*---------------------*
* SO FOR MAIN BRIEF
*---------------------*

/* Sexual Orientation */
gen so_brief = .
label var so_brief "sexual orientation for main brief"
replace so_brief = 0 if so_straight == 1 
replace so_brief = 1 if so_queer == 1
replace so_brief = 2 if so_unsure == 1
replace so_brief = 3 if so_pnts == 1
assert so_brief == . if so_missing == 1

label def so_brief_lbl 0 "straight" 1 "queer" 2 "unsure" 3 "prefer not to say"
label val so_brief so_brief_lbl




/* Umbrella LGBTQ+: only if report both gender, sex, & so  */
tab so_brief gender_brief

gen lgbtq = .
label var lgbtq "LGBTQ+"
replace lgbtq = 0 if gender_cis == 1 & so_straight == 1 // non-LGBTQ+ if cis & straight
replace lgbtq = 1 if inlist(gender_brief,2,3) // 1 if trans & nonbinary 
replace lgbtq = 1 if so_queer == 1  // 1 if so_queer 
replace lgbtq = 2 if gender_unsure == 1 & lgbtq != 1 // unsure if doesn;t belong to one of the previous lgbtq criteria & specified unsure
replace lgbtq = 2 if so_unsure == 1 & lgbtq != 1
replace lgbtq = 3 if gender_pnts == 1 & lgbtq != 1
replace lgbtq = 3 if so_pnts == 1 & lgbtq != 1
replace lgbtq = . if mi(gender_brief)==1 | mi(so_brief)==1 // force missing if not reporting both.

label def lgbtq_lbl 0 "non-LGBTQ" 1 "LGBTQ+" 2 "unsure" 3 "prefer not to say"
label val lgbtq lgbtq_lbl



*=========*
* Export  *
*=========+
drop *_str

compress
save "$csacprojdir/dta/cln/csac_hs_senior_2023_brief.dta", replace



********************************* End Main ************************************

log close

