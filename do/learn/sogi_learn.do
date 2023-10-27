********************************************************************************
/* exploratory tabulations of raw gender and sexual orientation reports */
********************************************************************************
************************ Written by Christina Sun 09/26/2023 *******************

/* CHANGE LOG:
 */

  /* to run this do file:
 do $csacprojdir/do/learn/sogi_learn.do
 */
version 17.0
cap log close _all
log using $csacprojdir/log/learn/sogi_learn_cs.smcl, replace

graph drop _all
set more off
set varabbrev off
set graphics off
set scheme s1color
set seed 1984

local date1 = c(current_date)
local time1 = c(current_time)

/* ssc install ngram, replace 
ssc install txttool, replace  */

/* net install "http://researchbtn.com/stata/110/wordfreq.pkg"
net install "http://researchbtn.com/stata/110/wordcloud.pkg" */

* Load fully cleaned data
use $csacclndatadir/csac_hs_senior_2023_clean, clear 


/* 
// create a var that generates clean tags for the free text response for gender
gen gender_other_tag = gender_other_raw
replace gender_other_tag = "NONSERIOUS" if gender_other_clean=="CISGENDER/OTHER"
// clean the leftover nonserious responses 

#delimit ;
replace gender_other_tag = "NONSERIOUS" if strpos(gender_other_raw, "DON'T BELIEVE IN THIS")!=0 
    | strpos(gender_other_raw, "NO ONE CAN CHANGE") !=0 
    | strpos(gender_other_raw, "STRAIGHT WOMAN")!=0
    | strpos(gender_other_raw, "MENTALLY ILL")!=0
    ;
// consolidate gender fluid ;
replace gender_other_tag = "GENDERFLUID"
    if strpos(gender_other_raw, "GENDERFLUID")!=0
    | strpos(gender_other_raw, "GENDER FLUID")!=0
    ; */
// consolidate unsure ;
/* replace gender_other_tag = "UNSURE/QUESTIONING"
    if strpos(gender_other_raw, "UNSURE")!=0
    | strpos(gender_other_raw, "UNKNOWN")!=0
    | strpos(gender_other_raw, "UNCERTAIN")!=0
    | strpos(gender_other_raw, "QUESTIONING")!=0
    | strpos(gender_other_raw, "NOT SURE")!=0
    | strpos(gender_other_raw, "CONFUSED")!=0
    ; */

#delimit cr


/* gen gender_tag = gender_raw 
replace gender_tag = gender_other_tag if gender_raw=="OTHER"
// replace nonserious responses with assigned gender at birth
replace gender_tag = agab if gender_other_tag=="NONSERIOUS"
replace gender_tag = "TRANS WOMAN" if gender_trans_binary==1 & gender_woman==1
replace gender_tag = "TRANS MAN" if gender_trans_binary==1 & gender_man==1

tab gender_tag

// combined gender var 
gen gender_raw_combined = gender_raw
replace gender_raw_combined = gender_other_raw if gender_raw=="OTHER"
replace gender_raw_combined = "TRANS WOMAN" if gender_trans_binary==1 & gender_woman==1
replace gender_raw_combined = "TRANS MAN" if gender_trans_binary==1 & gender_man==1
tab gender_raw_combined 


// combined sexuality var 
gen so_raw_combined = so_raw
replace so_raw_combined = so_other_raw if so_raw =="OTHER (FEEL FREE TO SPECIFY)"
replace so_raw_combined = "QUEER" if so_raw_combined=="QUEE5" */

// convert to lower case and get rid of special characters
txttool gender_other_raw, replace subwords("$csacprojdir/do/learn/subwords.txt")
txttool so_other_raw, replace subwords("$csacprojdir/do/learn/subwords.txt")

/* cd $csacprojdir/do/learn  */

/* do $csacprojdir/do/learn/wordcloud.ado  */
local wordvar1 "gender_other_raw" 
local pathvar1 "$csacprojdir/fig/learn/genderwordcloud.png"
local freqpath1 "$csacprojdir/fig/learn/gi_freq.xlsx"
local ngram_path1 "$csacprojdir/fig/learn/gi_ngram_freq.xlsx"

local wordvar2 "so_other_raw"
local pathvar2 "$csacprojdir/fig/learn/sowordcloud.png"
local freqpath2 "$csacprojdir/fig/learn/so_freq.xlsx"
local ngram_path2 "$csacprojdir/fig/learn/so_ngram_freq.xlsx"




/* python script $csacprojdir/do/learn/test.py, args(`wordvar1' `pathvar1') */

/* preserve 

drop if gender_raw_combined=="man" | gender_raw_combined=="woman" | gender_raw_combined=="prefer not to say"
tab gender_raw_combined */
tab gender_other_raw

/* 
set python_userpath "/home/users/chesun1.AD3/conda/lib/python3.11/site-packages" 
*/
python script $csacprojdir/do/learn/gen_wordcloud.py, args(`wordvar1' `pathvar1' `freqpath1' `ngram_path1')

/* restore, preserve 

/* drop if so_raw_combined=="straight not gay or lesbian" | so_raw_combined == "prefer not to say" */
tab so_raw_combined */

tab so_other_raw

python script $csacprojdir/do/learn/gen_wordcloud.py, args(`wordvar2' `pathvar2' `freqpath2' `ngram_path2')


local date2 = c(current_date)
local time2 = c(current_time)

di "Do file start date time: `date1' `time1'"
di "End date time: `date2' `time2'"


log close

translate $csacprojdir/log/learn/sogi_learn_cs.smcl ///
    $csacprojdir/log/learn/sogi_learn_cs.log, replace 


