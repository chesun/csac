
/*******************************************************************************
PROGRAM: DataCleaning.do

DESCRIPTION: This do-file cleans the California Community College Chancellor's 
Office through 2023-24. The CCCCO data are sent to John Daniels through FTP ast
.txt files. I import them from his jedaniels_upload folder and save as .dta files.

NOTES: "term_id" denotes period beginning in preceeding summer. E.g. 200 is for 
July 1, 2019 through June 30, 2020. "year" denotes the fall of an academic year. 
E.g. 2019 denotes the 2019-2020 academic year. 

OUTPUT: Year_CollapsedStudent.dta, Year_Cleaneda.dta, Year_Cleanedb.dta, 
Year_Cleanedc.dta, Year_Cleaned.dta, SXST_merged.dta, 
SXSFAST_merged.dta, SXSFASTSP_merged.dta, Year_mergedBOG.dta, SFA_Collapsed_year, 
ST_CollapsedYear.dta, SP_collapsed.dta, SX_termcollapsed.dta, 
SX_yearcollapsed.dta, SP_collapsedstudent, Year_Cleaned.dta, 
Year_CollapsedStudent.dta. 


DATE: April 2023
*******************************************************************************/

/*******************************************************************************
	     	        Sample code for Importing and converting
*******************************************************************************/
/* 
clear all
set more off
import delimited using "/home/research/ca_ed_lab/jedaniel_uploads/STTERM_2021-11-01_0810 .txt"
compress
save raw/ccc/STTERM_test_1104.dta
*/

/*******************************************************************************
	     	        Set Directories, Log, Install Packages
*******************************************************************************/

*Set working directory

*Clean Raw files to create Intermediate files by Year*
global raw "/home/research/ca_ed_lab/data/restricted_access/raw/ccc/"
global clean "/home/research/ca_ed_lab/data/restricted_access/clean/ccc"

/*******************************************************************************
   Merge SXENRLM and CBCRSINV Raw Files, Generate Variables for Enrollment Type

*******************************************************************************/

*Load SXENRLM
clear all
set more off
use "$raw/SXENRLM.dta"

*Merge on CBCRINV for transfer-level math and English indicator 
merge m:1 college term course control using "$raw/CBCRSINV.dta"

/*
 Result                           # of obs.
    -----------------------------------------
    not matched                     6,877,470
        from master                    48,005  (_merge==1)
        from using                  6,829,465  (_merge==2)

    matched                       301,919,146  (_merge==3)
    -----------------------------------------
*/
drop if _merge==2
drop _merge 

*Drop
drop course_id section_id attend_hours total_hours apportionment ///
basic_skills_status sam_code noncredit_category title ///
coop_ed_status classification_code special_class_status funding_category ///
program_status 

*Replace units as 0 if they exceed maximum of 75
replace units_a=0 if units_a>75
replace units=0 if units>75

/*Generate units earned and attempted for Transfer (T), Non-Transferable (D), 
and Basic Skills (B/S) enrollment*/
gen unita_deg=units_att if (credit_flag=="T"|credit_flag=="D")
gen unit_deg=units if (credit_flag=="T"|credit_flag=="D")
gen unita_bs=units_att if (credit_flag=="S"|credit_flag=="B")
gen unit_bs=units if (credit_flag=="S"|credit_flag=="B")

*Generate indicators for transfer in math and english
gen transfer_math=.
replace transfer_math=1 if top_code==170100 & transfer_status=="A"
replace transfer_math=1 if top_code==170100 & transfer_status=="B"

gen transfer_eng=.
replace transfer_eng=1 if top_code==150100 & transfer_status=="A"
replace transfer_eng=1 if top_code==150100 & transfer_status=="B"
replace transfer_eng=1 if top_code==152000 & transfer_status=="A"
replace transfer_eng=1 if top_code==152000 & transfer_status=="B"

tab transfer_math transfer_eng, m

gen deg_math=1 if top_code==170100 & credit_flag=="D"
gen deg_eng=.
replace deg_eng=1 if top_code==150100 & credit_flag=="D"
replace deg_eng=1 if top_code==152000 & credit_flag=="D"

/*******************************************************************************
              Calculate GPA for Each Course in SXENRLM-CBCRSINV Merge
					   
Notes: To identify GPA use (1) units attempted & (2) numeric grade in each 
course. 

* Recode letter grades to numeric grades using the numeric variables listed 
here: http://www.sbcc.edu/boardoftrustees/files/bot2012agendas/10-25-12%20Attachments.pdf
* Data dictionary on all of the possible grade values in CCC data: 
http://extranet.cccco.edu/Portals/1/TRIS/MIS/Left_Nav/DED/Data_Elements/SX/SX04.pdf

* Things to note:
* Pass/No Pass classes are not included in GPA calculation
* Classes that are withdrawn after the last day to drop are included in GPA 
*and have the same value as an F (i.e. numeric grade value of 0)
* Courses with a  Military Withdrawal are not included in GPA calculation
*******************************************************************************/

*Replace grade
replace grade=upper(grade)
*egen aux=sieve(SX_GRADE), char(ABCDEFGHIJKLMNOPQRSTUVWXYZ+-)
*replace SX_GRADE=aux
*drop aux

*Generate numeric value for grades
gen grade_numeric_value=.
replace grade_numeric_value=4 if grade=="A+ "
replace grade_numeric_value=4 if grade=="A  "
replace grade_numeric_value=3.7 if grade=="A- "
replace grade_numeric_value=3.3 if grade=="B+ "
replace grade_numeric_value=3 if grade=="B  "  
replace grade_numeric_value=2.7 if grade=="B- "
replace grade_numeric_value=2.3 if grade=="C+ "
replace grade_numeric_value=2 if grade=="C  "
replace grade_numeric_value=1 if grade=="D  "
replace grade_numeric_value=1.3 if grade=="D+ "
replace grade_numeric_value=.7 if grade=="D- "
replace grade_numeric_value=0 if grade=="F  "
replace grade_numeric_value=0 if grade=="F+ "
replace grade_numeric_value=0 if grade=="FW "

*Create units attempted that should be included in the GPA calculation
gen units_attempted_gpa= units_att
replace units_attempted_gpa=. if grade=="P  " | grade=="NP " |grade=="DR "| ///
grade=="I  " | grade=="IA " | grade=="IA-" |grade=="IB " |grade=="IB+" | ///
grade=="IB-" | grade=="IC " | grade=="IC+" | grade=="ID " | grade=="ID+" | ///
grade=="ID-" | grade=="IF " | grade=="IPP" | grade=="INP" | grade=="IP " | ///
grade=="IPP" | grade=="IX " | grade=="MW " | grade=="RD " | grade=="RD0" | ///
grade=="RD1" |grade=="RD2" | grade=="RD3" |grade=="RD4" |grade=="RD5" | ///
grade=="RD6" |grade=="RD7" |grade=="RD8" |grade=="SP " | grade=="UD " | ///
grade=="UG " | grade=="XX " | grade=="W  "

*Calculate grade points for each course
gen grade_points=grade_numeric_value*units_attempted_gpa

/*******************************************************************************
          Collapse SXENRLM-CBCRSINV Merge to Student-College-Term Level
					   
Output: SX_termcollapsed.dta
*******************************************************************************/

/*Collapse sum will treat missing values as 0 - here is some code to correct for 
that*/
bysort student_id college_id term_id: gegen seq = seq()
foreach v in units_attempted units unit_deg unita_deg grade_points ///
grade_numeric_value units_attempted units_attempted_gpa units unita_deg unit_deg {

    bysort student_id college_id term_id: gegen sum`v' = sum(`v')
    bysort student_id college_id term_id: gegen mn`v' = mean(`v')
    replace sum`v' = -99 if(mn`v' == .)
    replace sum`v' = . if(seq > 1)
    drop mn`v' `v'
    rename sum`v' `v'
}

*Drop
drop seq

*Collapse data to student-college-term level
gcollapse (max) transfer_math transfer_eng deg_math deg_eng ///
(sum) units_attempted units unit_deg unita_deg ///
sum_grade_points=grade_points sum_grade_numeric_value=grade_numeric_value ///
sum_units_attempted=units_attempted sum_units_attempted_gpa=units_attempted_gpa  ///
sum_units_completed=units sum_units_deg_attempted=unita_deg ///
sum_units_deg_completed=unit_deg, by(student_id college_id term_id)

*Replace negative sums (inputted above) with missings
foreach v in units_attempted units unit_deg unita_deg sum_grade_points ///
sum_grade_numeric_value sum_units_attempted_gpa ///
sum_units_attempted sum_units_completed sum_units_deg_completed ///
sum_units_deg_attempted {

replace `v'=. if (`v'<0)
}

*Compute semester GPA
gen sem_GPA=sum_grade_points/sum_units_attempted_gpa

/*Compute sem % of credits completed in the sem (this is not excluding remedial 
courses)*/
gen sem_pct_credits_completed=sum_units_completed/sum_units_attempted 

*Generate year (moved from following section) 
gen year=.
replace year=1992 if term_id==925|term_id==926|term_id==927|term_id==928|term_id==931|term_id==932|term_id==933|term_id==934
replace year=1993 if term_id==935|term_id==936|term_id==937|term_id==938|term_id==941|term_id==942|term_id==943|term_id==944
replace year=1994 if term_id==945|term_id==946|term_id==947|term_id==948|term_id==951|term_id==952|term_id==953|term_id==954
replace year=1995 if term_id==955|term_id==956|term_id==957|term_id==958|term_id==961|term_id==962|term_id==963|term_id==964
replace year=1996 if term_id==965|term_id==966|term_id==967|term_id==968|term_id==971|term_id==972|term_id==973|term_id==974
replace year=1997 if term_id==975|term_id==976|term_id==977|term_id==978|term_id==981|term_id==982|term_id==983|term_id==984
replace year=1998 if term_id==985|term_id==986|term_id==987|term_id==988|term_id==991|term_id==992|term_id==993|term_id==994
replace year=1999 if term_id==995|term_id==996|term_id==997|term_id==998|term_id==001|term_id==002|term_id==003|term_id==004
replace year=2000 if term_id==005|term_id==006|term_id==007|term_id==008|term_id==011|term_id==012|term_id==013|term_id==014
replace year=2001 if term_id==015|term_id==016|term_id==017|term_id==018|term_id==021|term_id==022|term_id==023|term_id==024
replace year=2002 if term_id==025|term_id==026|term_id==027|term_id==028|term_id==031|term_id==032|term_id==033|term_id==034
replace year=2003 if term_id==035|term_id==036|term_id==037|term_id==038|term_id==041|term_id==042|term_id==043|term_id==044
replace year=2004 if term_id==045|term_id==046|term_id==047|term_id==048|term_id==051|term_id==052|term_id==053|term_id==054
replace year=2005 if term_id==055|term_id==056|term_id==057|term_id==058|term_id==061|term_id==062|term_id==063|term_id==064
replace year=2006 if term_id==065|term_id==066|term_id==067|term_id==068|term_id==071|term_id==072|term_id==073|term_id==074
replace year=2007 if term_id==075|term_id==076|term_id==077|term_id==078|term_id==081|term_id==082|term_id==083|term_id==084
replace year=2008 if term_id==085|term_id==086|term_id==087|term_id==088|term_id==091|term_id==092|term_id==093|term_id==094
replace year=2009 if term_id==095|term_id==096|term_id==097|term_id==098|term_id==101|term_id==102|term_id==103|term_id==104
replace year=2010 if term_id==105|term_id==106|term_id==107|term_id==108|term_id==111|term_id==112|term_id==113|term_id==114
replace year=2011 if term_id==115|term_id==116|term_id==117|term_id==118|term_id==121|term_id==122|term_id==123|term_id==124
replace year=2012 if term_id==125|term_id==126|term_id==127|term_id==128|term_id==131|term_id==132|term_id==133|term_id==134
replace year=2013 if term_id==135|term_id==136|term_id==137|term_id==138|term_id==141|term_id==142|term_id==143|term_id==144
replace year=2014 if term_id==145|term_id==146|term_id==147|term_id==148|term_id==151|term_id==152|term_id==153|term_id==154
replace year=2015 if term_id==155|term_id==156|term_id==157|term_id==158|term_id==161|term_id==162|term_id==163|term_id==164
replace year=2016 if term_id==165|term_id==166|term_id==167|term_id==168|term_id==171|term_id==172|term_id==173|term_id==174
replace year=2017 if term_id==175|term_id==176|term_id==177|term_id==178|term_id==181|term_id==182|term_id==183|term_id==184
replace year=2018 if term_id==185|term_id==186|term_id==187|term_id==188|term_id==191|term_id==192|term_id==193|term_id==194
replace year=2019 if term_id==195|term_id==196|term_id==197|term_id==198|term_id==201|term_id==202|term_id==203|term_id==204
replace year=2020 if term_id==205|term_id==206|term_id==207|term_id==208|term_id==211|term_id==212|term_id==213|term_id==214
replace year=2021 if term_id==215|term_id==216|term_id==217|term_id==218|term_id==221|term_id==222|term_id==223|term_id==224
replace year=2022 if term_id==225|term_id==226|term_id==227|term_id==228|term_id==231|term_id==232|term_id==233|term_id==234

replace year=2023 if term_id==235|term_id==236|term_id==237|term_id==238|term_id==241|term_id==242|term_id==243|term_id==244
replace year=2024 if term_id==245|term_id==246|term_id==247|term_id==248|term_id==251|term_id==252|term_id==253|term_id==254
replace year=2025 if term_id==255|term_id==256|term_id==257|term_id==258|term_id==261|term_id==262|term_id==263|term_id==264

drop if missing(year)

*Save
compress
save "$clean/SX_termcollapsed.dta", replace


/*******************************************************************************
             Collapse SXENRLM-CBCRSINV to Student-College-Year Level
					   
Output: SX_yearcollapsed.dta
*******************************************************************************/
use "$clean/SX_termcollapsed.dta", clear
*Generate Fall-level variables
foreach var in units_attempted units unit_deg unita_deg sem_GPA sem_pct_credits_completed  {
gen `var'_f=`var' if term_id==927|term_id==937|term_id==947|term_id==957|term_id==967|term_id==977|term_id==987|term_id==997|term_id==007|term_id==017|term_id==027|term_id==037|term_id==047|term_id==057|term_id==067|term_id==077|term_id==087|term_id==097|term_id==107|term_id==117|term_id==127|term_id==137|term_id==147|term_id==157|term_id==167|term_id==177|term_id==187|term_id==197|term_id==207|term_id==217|term_id==227|term_id==237|term_id==247 ///
|term_id==928|term_id==938|term_id==948|term_id==958|term_id==968|term_id==978|term_id==008|term_id==018|term_id==028|term_id==038|term_id==048|term_id==058|term_id==068|term_id==078|term_id==088|term_id==098|term_id==108|term_id==118|term_id==128|term_id==138|term_id==148|term_id==158|term_id==168|term_id==178|term_id==188|term_id==198|term_id==208|term_id==218|term_id==228|term_id==238|term_id==248
}

*Generate Winter-level variables
foreach var in units_attempted units unit_deg unita_deg sem_GPA sem_pct_credits_completed  {
gen `var'_w=`var' if term_id==921|term_id==931|term_id==941|term_id==951|term_id==961|term_id==971|term_id==981|term_id==991|term_id==001|term_id==011|term_id==021|term_id==031|term_id==041|term_id==051|term_id==061|term_id==071|term_id==081|term_id==091|term_id==101|term_id==111|term_id==121|term_id==131|term_id==141|term_id==151|term_id==161|term_id==171|term_id==181|term_id==191 |term_id==201|term_id==211|term_id==221|term_id==231|term_id==241|term_id==251 ///
|term_id==922|term_id==932|term_id==942|term_id==952|term_id==962|term_id==972|term_id==982|term_id==992|term_id==002|term_id==012|term_id==022|term_id==032|term_id==042|term_id==052|term_id==062|term_id==072|term_id==082|term_id==092|term_id==102|term_id==112|term_id==122|term_id==132|term_id==142|term_id==152|term_id==162|term_id==172|term_id==182|term_id==192|term_id==202|term_id==212|term_id==222|term_id==232|term_id==242|term_id==252
}

*Generate Spring-level variables
foreach var in units_attempted units unit_deg unita_deg sem_GPA sem_pct_credits_completed  {
gen `var'_sp=`var' if term_id==923|term_id==933|term_id==943|term_id==953|term_id==963|term_id==973|term_id==983|term_id==993|term_id==003|term_id==013|term_id==023|term_id==033|term_id==043|term_id==053|term_id==063|term_id==073|term_id==083|term_id==093|term_id==103|term_id==113|term_id==123|term_id==133|term_id==143|term_id==153|term_id==163|term_id==173|term_id==183|term_id==193|term_id==203|term_id==213|term_id==223|term_id==233|term_id==243|term_id==253 ///
|term_id==924|term_id==934|term_id==944|term_id==954|term_id==964|term_id==974|term_id==984|term_id==994|term_id==004|term_id==014|term_id==024|term_id==034|term_id==044|term_id==054|term_id==064|term_id==074|term_id==084|term_id==094|term_id==104|term_id==114|term_id==124|term_id==134|term_id==144|term_id==154|term_id==164|term_id==174|term_id==184|term_id==194|term_id==204|term_id==214|term_id==224|term_id==234|term_id==244|term_id==254
}

*Generate Summer-level variables
foreach var in units_attempted units unit_deg unita_deg sem_GPA sem_pct_credits_completed  {
gen `var'_su=`var' if term_id==935|term_id==945|term_id==955|term_id==965|term_id==975|term_id==985|term_id==995|term_id==005|term_id==015|term_id==025|term_id==035|term_id==045|term_id==055|term_id==065|term_id==075|term_id==085|term_id==095|term_id==105|term_id==115|term_id==125|term_id==135|term_id==145|term_id==155|term_id==165|term_id==175|term_id==185|term_id==195|term_id==205|term_id==215|term_id==225|term_id==235|term_id==245|term_id==255 ///
|term_id==936|term_id==946|term_id==956|term_id==966|term_id==976|term_id==986|term_id==996|term_id==006|term_id==016|term_id==026|term_id==036|term_id==046|term_id==056|term_id==066|term_id==076|term_id==086|term_id==096|term_id==106|term_id==116|term_id==126|term_id==136|term_id==146|term_id==156|term_id==166|term_id==176|term_id==186|term_id==196|term_id==206|term_id==216|term_id==226|term_id==236|term_id==246|term_id==256
}


/*Collapse sum will treat missing values as 0 - here is some code to correct for 
that*/
bysort student_id college_id year: gegen seq = seq()
foreach v in units_attempted units unit_deg unita_deg {

    bysort student_id college_id year: gegen sum`v' = sum(`v')
    bysort student_id college_id year: gegen mn`v' = mean(`v')
    replace sum`v' = -99 if (mn`v' == .)
    replace sum`v' = . if (seq > 1)
    drop mn`v' `v'
    rename sum`v' `v'
}

*Collapse to student-college-year level  
gcollapse (max) transfer_math transfer_eng deg_math deg_eng ///
units_attempted_f units_attempted_w units_attempted_sp units_attempted_su ///
units_f units_sp units_su units_w sem_GPA unit_deg_f unit_deg_w unit_deg_sp ///
unit_deg_su unita_deg_f unita_deg_w unita_deg_sp unita_deg_su ///
sem_pct_credits_completed sem_GPA_f sem_pct_credits_completed_f sem_GPA_w ///
sem_pct_credits_completed_w sem_GPA_sp sem_pct_credits_completed_sp sem_GPA_su ///
sem_pct_credits_completed_su (sum) units_attempted units unit_deg unita_deg, ///
by(student_id college_id year)

*Replace negative sums (inputted above) with missings
foreach v in units_attempted units unit_deg unita_deg {

replace `v'=. if (`v'<0)
}

*Save
compress
save "$clean/SX_yearcollapsed.dta", replace 



/*******************************************************************************
		    Clean SPAWARDS Raw Data, Collapse to Student-College Level 
*******************************************************************************/


clear all
set more off
use "$raw/SPAWARDS.dta"
tab college_id
*No degrees from LAITV (74A)

tab term_id
gen year=.
replace year=1992 if term==930
replace year=1993 if term==940
replace year=1994 if term==950
replace year=1995 if term==960
replace year=1996 if term==970
replace year=1997 if term==980
replace year=1998 if term==990
replace year=1999 if term==000
replace year=2000 if term==010
replace year=2001 if term==020
replace year=2002 if term==030
replace year=2003 if term==040
replace year=2004 if term==050
replace year=2005 if term==060
replace year=2006 if term==070
replace year=2007 if term==080
replace year=2008 if term==090
replace year=2009 if term==100
replace year=2010 if term==110
replace year=2011 if term==120
replace year=2012 if term==130
replace year=2013 if term==140
replace year=2014 if term==150
replace year=2015 if term==160
replace year=2016 if term==170
replace year=2017 if term==180
replace year=2018 if term==190
replace year=2019 if term==200
replace year=2020 if term==210
replace year=2021 if term==220
replace year=2022 if term==230
replace year=2023 if term==240
replace year=2024 if term==250
replace year=2025 if term==260

tab year term, m

tab award, m
gen associate=award=="A"|award=="S"
gen ba=award=="Y"|award=="Z"
gen credit_cert=award=="E"|award=="B"|award=="L"|award=="T"|award=="O"|award=="F"
gen creditcert_30plus=award=="T"|award=="F"
gen creditcert_30less=award=="E"|award=="B"|award=="L"|award=="O"

gen aaas_topcode=top_code if award=="A"|award=="S"
gen ba_topcode=top_code if award=="Y"|award=="Z"

*Collapse by Degree-Year
collapse (max) associate credit* ba (firstnm) aaas_topcode ba_topcode, by (student_id college_id year)
compress
save "$clean/SP_collapsed.dta", replace

*Collapse by student 
clear all
use "$clean/SP_collapsed.dta"
collapse (max) associate ba credit_cert creditcert_30plus creditcert_30less, by (student college)
compress
save "$clean/SP_collapsedstudent.dta", replace


/*******************************************************************************
	      Clean STTERM Raw Data, Collapse to Student-College-Year Level
				  
Output: Intermediate data file ST_CollapsedYear.dta

Note: I add a student's fall age variable here in addition to their minimum age
in a year. 
*******************************************************************************/

/*Make small ST file for student demographics
clear all
set more off
use raw/ccc/STTERM.dta
keep student_id college_id term_id gender age race name*  goal
save raw/ccc/STTERM_small.dta, replace
*/


clear all
set more off
use "$raw/STTERM.dta"

drop multi_race ipeds_race gpa_tot gpa_loc jtpa_status gain_status transfer_ctr apprentice census_crload deg_appl_units_earned day_evening_code2 day_evening_code u_earned_loc u_earned_trn u_attmpt_loc u_attmpt_trn g_points_loc g_points_trn citizenship academic_level
 
destring term, replace
gen year=.
replace year=1992 if term_id==925|term_id==926|term_id==927|term_id==928|term_id==931|term_id==932|term_id==933|term_id==934
replace year=1993 if term_id==935|term_id==936|term_id==937|term_id==938|term_id==941|term_id==942|term_id==943|term_id==944
replace year=1994 if term_id==945|term_id==946|term_id==947|term_id==948|term_id==951|term_id==952|term_id==953|term_id==954
replace year=1995 if term_id==955|term_id==956|term_id==957|term_id==958|term_id==961|term_id==962|term_id==963|term_id==964
replace year=1996 if term_id==965|term_id==966|term_id==967|term_id==968|term_id==971|term_id==972|term_id==973|term_id==974
replace year=1997 if term_id==975|term_id==976|term_id==977|term_id==978|term_id==981|term_id==982|term_id==983|term_id==984
replace year=1998 if term_id==985|term_id==986|term_id==987|term_id==988|term_id==991|term_id==992|term_id==993|term_id==994
replace year=1999 if term_id==995|term_id==996|term_id==997|term_id==998|term_id==001|term_id==002|term_id==003|term_id==004
replace year=2000 if term_id==005|term_id==006|term_id==007|term_id==008|term_id==011|term_id==012|term_id==013|term_id==014
replace year=2001 if term_id==015|term_id==016|term_id==017|term_id==018|term_id==021|term_id==022|term_id==023|term_id==024
replace year=2002 if term_id==025|term_id==026|term_id==027|term_id==028|term_id==031|term_id==032|term_id==033|term_id==034
replace year=2003 if term_id==035|term_id==036|term_id==037|term_id==038|term_id==041|term_id==042|term_id==043|term_id==044
replace year=2004 if term_id==045|term_id==046|term_id==047|term_id==048|term_id==051|term_id==052|term_id==053|term_id==054
replace year=2005 if term_id==055|term_id==056|term_id==057|term_id==058|term_id==061|term_id==062|term_id==063|term_id==064
replace year=2006 if term_id==065|term_id==066|term_id==067|term_id==068|term_id==071|term_id==072|term_id==073|term_id==074
replace year=2007 if term_id==075|term_id==076|term_id==077|term_id==078|term_id==081|term_id==082|term_id==083|term_id==084
replace year=2008 if term_id==085|term_id==086|term_id==087|term_id==088|term_id==091|term_id==092|term_id==093|term_id==094
replace year=2009 if term_id==095|term_id==096|term_id==097|term_id==098|term_id==101|term_id==102|term_id==103|term_id==104
replace year=2010 if term_id==105|term_id==106|term_id==107|term_id==108|term_id==111|term_id==112|term_id==113|term_id==114
replace year=2011 if term_id==115|term_id==116|term_id==117|term_id==118|term_id==121|term_id==122|term_id==123|term_id==124
replace year=2012 if term_id==125|term_id==126|term_id==127|term_id==128|term_id==131|term_id==132|term_id==133|term_id==134
replace year=2013 if term_id==135|term_id==136|term_id==137|term_id==138|term_id==141|term_id==142|term_id==143|term_id==144
replace year=2014 if term_id==145|term_id==146|term_id==147|term_id==148|term_id==151|term_id==152|term_id==153|term_id==154
replace year=2015 if term_id==155|term_id==156|term_id==157|term_id==158|term_id==161|term_id==162|term_id==163|term_id==164
replace year=2016 if term_id==165|term_id==166|term_id==167|term_id==168|term_id==171|term_id==172|term_id==173|term_id==174
replace year=2017 if term_id==175|term_id==176|term_id==177|term_id==178|term_id==181|term_id==182|term_id==183|term_id==184
replace year=2018 if term_id==185|term_id==186|term_id==187|term_id==188|term_id==191|term_id==192|term_id==193|term_id==194
replace year=2019 if term_id==195|term_id==196|term_id==197|term_id==198|term_id==201|term_id==202|term_id==203|term_id==204
replace year=2020 if term_id==205|term_id==206|term_id==207|term_id==208|term_id==211|term_id==212|term_id==213|term_id==214
replace year=2021 if term_id==215|term_id==216|term_id==217|term_id==218|term_id==221|term_id==222|term_id==223|term_id==224
replace year=2022 if term_id==225|term_id==226|term_id==227|term_id==228|term_id==231|term_id==232|term_id==233|term_id==234
replace year=2023 if term_id==235|term_id==236|term_id==237|term_id==238|term_id==241|term_id==242|term_id==243|term_id==244
replace year=2024 if term_id==245|term_id==246|term_id==247|term_id==248|term_id==251|term_id==252|term_id==253|term_id==254
replace year=2025 if term_id==255|term_id==256|term_id==257|term_id==258|term_id==261|term_id==262|term_id==263|term_id==264

tab term_id year, m 

replace age_at_term=. if age_at_term==99
replace gender="" if gender=="X"
replace race="" if race=="X."
replace goal="" if goal=="X"

*Generate fall age
gen age_f=.
replace age_f=age_at_term if term_id==927|term_id==937|term_id==947|term_id==957| ///
term_id==967|term_id==977|term_id==987|term_id==997|term_id==007|term_id==017| ///
term_id==027|term_id==037|term_id==047|term_id==057|term_id==067|term_id==077| ///
term_id==087|term_id==097|term_id==107|term_id==117|term_id==127|term_id==137| ///
term_id==147|term_id==157|term_id==167|term_id==177|term_id==187|term_id==197| ///
term_id==207|term_id==217|term_id==227|term_id==237|term_id==247| ///
term_id==928|term_id==938|term_id==948|term_id==958|term_id==968| ///
term_id==978|term_id==008|term_id==018|term_id==028|term_id==038|term_id==048| ///
term_id==058|term_id==068|term_id==078|term_id==088|term_id==098|term_id==108| ///
term_id==118|term_id==128|term_id==138|term_id==148|term_id==158|term_id==168| ///
term_id==178|term_id==188|term_id==198|term_id==208|term_id==218|term_id==228|term_id==238|term_id==248

*Special Admit
gen specialadmit=.
replace specialadmit=1 if ed=="10000"
replace specialadmit=0 if ed!="10000"
replace specialadmit=. if ed==""
tab ed specialadmit, m

rename zip zip_code
collapse  (max) specialadmit* (min) age_at_term age_f (firstnm) headcount goal education enrollment high_school name* gender race residency zip_code parent_ed, by (student_id college_id year)
compress
save "$clean/ST_CollapsedYear.dta", replace


*Financial Aid award (SFA) and application (SFAPPL)
clear all
set more off
use "$raw/SFAPPL.dta"

merge 1:m student_id college_id term_id using "$raw/SFAWARDS.dta"

/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                     5,582,788
        from master                 5,582,733  (_merge==1)
        from using                         55  (_merge==2)

    Matched                        69,190,598  (_merge==3)
    -----------------------------------------
*/

tab term_id _merge
tab college_id _merge
tab type if _merge==2

keep if _merge==3
drop _merge

*Financial Aid Variables 
*EFC: Data Dictionary: Enter 99999 if the expected family contribution (EFC) is unknown. 
rename efc sf_efc
gen efc=sf_efc
replace efc=. if efc>=99000
codebook efc sf_efc 

gen fafsa=.
replace fafsa=1 if efc!=.
replace fafsa=0 if efc==.
tab term_id fafsa, m

tab type, m
/*Revision: Effective 9/1/22 term 220. Added GO GT GZ WL
Revision: Effective 9/1/21 term 210. Added F6 GL GM; updated GD GH edits
Revision: Effective 9/1/19 term 190. Added BP GJ GX
 Removed outdated definition of award group levels A, B, C
Revision: Effective 9/1/18 term 180. Added GH GI GQ GR
*/

*Create Aid Variables 
gen bog=type_id=="B1"|type_id=="B2"|type_id=="B3"|type_id=="B4"|type_id=="BA"| ///
type_id=="BB"|type_id=="BC"|type_id=="BD"|type_id=="BP"
gen amt_bog=amount if type_id=="B1"|type_id=="B2"|type_id=="B3"|type_id=="B4"|type_id=="BA"|type_id=="BB"|type_id=="BC"|type_id=="BD"|type_id=="BP"
gen bog_b=type_id=="BB"
gen ab19=type_id=="GX"
gen amt_ab19=amount if type_id=="GX"
gen fee_waiver=type_id=="F1"|type_id=="F2"|type_id=="F3"|type_id=="F4"| ///
type_id=="F5"
gen loan=type_id=="LD"|type_id=="LE"|type_id=="LG"|type_id=="LH"|type_id=="LI"| ///
type_id=="LN"|type_id=="LP"|type_id=="LR"|type_id=="LS"|type_id=="LL"|type_id=="LY"
gen amt_loan=amount if loan==1
gen loan_sub=type_id=="LS"|type_id=="LG"
gen amt_loansub=amount if type_id=="LS"|type_id=="LG"
gen loan_unsub=type_id=="LL"|type_id=="LH"
gen amt_loanunsub=amount if type_id=="LL"|type_id=="LH"
gen loan_fed= type_id=="LL"|type_id=="LH"|type_id=="LS"|type_id=="LG"| ///
type_id=="LD"|type_id=="LE"|type_id=="LP"
gen amt_loanfed=amount if type_id=="LL"|type_id=="LH"|type_id=="LS"| ///
type_id=="LG"|type_id=="LD"|type_id=="LE"|type_id=="LP" 
gen pell=type_id=="GP"
gen amt_pell= amount if type_id=="GP"
gen cgb=type_id=="GB"
gen amt_cgb=amount if type_id=="GB"
gen cgc=type_id=="GC"
gen amt_cgc=amount if type_id=="GC"
gen ftssg=type_id=="GD"
gen amt_ftssg=amount if type_id=="GD"
gen cccg=type_id=="GH"
gen amt_cccg=amount if type_id=="GH"	
gen cga=type_id=="GI"
gen amt_cga=amount if type_id=="GI"	
gen sscg=type_id=="GJ"
gen amt_sscg=amount if type_id=="GJ"
gen bigtype=substr(type,1,1)
gen grant=bigtype=="G"
gen amt_grant=amount if grant==1
gen ws=type_id=="WC"|type_id=="WE"|type_id=="WF"|type_id=="WU"|type_id=="WK"| ///
type_id=="WY"
gen amt_ws=amount if type_id=="WC"|type_id=="WE"|type_id=="WF"|type_id=="WU"| ///
type_id=="WK"|type_id=="WY" 
gen ca_disaster=type_id=="GL"
gen amt_ca_disaster=amount if type_id=="GL"
gen heerf=type_id=="GM"
gen amt_heerf=amount if type_id=="GM"

/*
collapse (firstnm) budget_cat dep household family_status (max) sf_efc efc fafsa bog* ab* fee* pell* ftssg* cccg* sscg* heerf* ca_disaster* ///
cg* grant* ws* loan* amt_cgb* amt_cgc* amt_ftssg* amt_cccg* amt_cga* ///
amt_sscg* amt_ab19*  amt_pell* amt_ca_disaster* amt_heerf* income* untax* , by (student college term_recd) 
rename term_recd term_id
compress
tab term_id bog, m 
rename family_status sf_family_status
save "$clean/SFA_Collapsed_term.dta", replace 


duplicates tag student_id college_id term_recd type_id, gen (dup)
tab dup
tab term_recd if dup>0
*All summer terms
drop dup
*/

destring term_id, replace
gen year=.
replace year=1992 if term_id==930
replace year=1993 if term_id==940
replace year=1994 if term_id==950
replace year=1995 if term_id==960
replace year=1996 if term_id==970
replace year=1997 if term_id==980
replace year=1998 if term_id==990
replace year=1999 if term_id==000
replace year=2000 if term_id==010
replace year=2001 if term_id==020
replace year=2002 if term_id==030
replace year=2003 if term_id==040
replace year=2004 if term_id==050
replace year=2005 if term_id==060
replace year=2006 if term_id==070
replace year=2007 if term_id==080
replace year=2008 if term_id==090
replace year=2009 if term_id==100
replace year=2010 if term_id==110
replace year=2011 if term_id==120
replace year=2012 if term_id==130
replace year=2013 if term_id==140
replace year=2014 if term_id==150
replace year=2015 if term_id==160
replace year=2016 if term_id==170
replace year=2017 if term_id==180
replace year=2018 if term_id==190
replace year=2019 if term_id==200
replace year=2020 if term_id==210
replace year=2021 if term_id==220
replace year=2022 if term_id==230
replace year=2023 if term_id==240
replace year=2024 if term_id==250
replace year=2025 if term_id==260

tab term_id year, m

rename term_id sf_term_id
rename term_recd term_id 

*Term-Level variables
foreach var in bog amt_bog ab19 amt_ab19 fee_waiver loan amt_loan loan_sub amt_loansub loan_unsub amt_loanunsub loan_fed amt_loanfed pell amt_pell cgb amt_cgb cgc amt_cgc ftssg amt_ftssg cccg amt_cccg cga amt_cga sscg amt_sscg  grant amt_grant ws amt_ws ca_disaster amt_ca_disaster heerf amt_heerf  {
gen `var'_f=`var' if term_id==927|term_id==937|term_id==947|term_id==957|term_id==967|term_id==977|term_id==987|term_id==997|term_id==007|term_id==017|term_id==027|term_id==037|term_id==047|term_id==057|term_id==067|term_id==077|term_id==087|term_id==097|term_id==107|term_id==117|term_id==127|term_id==137|term_id==147|term_id==157|term_id==167|term_id==177|term_id==187|term_id==197|term_id==207|term_id==217|term_id==227|term_id==237|term_id==247 ///
|term_id==928|term_id==938|term_id==948|term_id==958|term_id==968|term_id==978|term_id==008|term_id==018|term_id==028|term_id==038|term_id==048|term_id==058|term_id==068|term_id==078|term_id==088|term_id==098|term_id==108|term_id==118|term_id==128|term_id==138|term_id==148|term_id==158|term_id==168|term_id==178|term_id==188|term_id==198|term_id==208|term_id==218|term_id==228|term_id==238|term_id==248
}

foreach var in bog amt_bog ab19 amt_ab19 fee_waiver loan amt_loan loan_sub amt_loansub loan_unsub amt_loanunsub loan_fed amt_loanfed pell amt_pell cgb amt_cgb cgc amt_cgc ftssg amt_ftssg cccg amt_cccg cga amt_cga sscg amt_sscg  grant amt_grant ws amt_ws ca_disaster amt_ca_disaster heerf amt_heerf  {
gen `var'_w=`var' if term_id==921|term_id==931|term_id==941|term_id==951|term_id==961|term_id==971|term_id==981|term_id==991|term_id==001|term_id==011|term_id==021|term_id==031|term_id==041|term_id==051|term_id==061|term_id==071|term_id==081|term_id==091|term_id==101|term_id==111|term_id==121|term_id==131|term_id==141|term_id==151|term_id==161|term_id==171|term_id==181|term_id==191 |term_id==201|term_id==211|term_id==221|term_id==231|term_id==241|term_id==251 ///
|term_id==922|term_id==932|term_id==942|term_id==952|term_id==962|term_id==972|term_id==982|term_id==992|term_id==002|term_id==012|term_id==022|term_id==032|term_id==042|term_id==052|term_id==062|term_id==072|term_id==082|term_id==092|term_id==102|term_id==112|term_id==122|term_id==132|term_id==142|term_id==152|term_id==162|term_id==172|term_id==182|term_id==192|term_id==202|term_id==212|term_id==222|term_id==232|term_id==242|term_id==252
}

foreach var in bog amt_bog ab19 amt_ab19 fee_waiver loan amt_loan loan_sub amt_loansub loan_unsub amt_loanunsub loan_fed amt_loanfed pell amt_pell cgb amt_cgb cgc amt_cgc ftssg amt_ftssg cccg amt_cccg cga amt_cga sscg amt_sscg  grant amt_grant ws amt_ws ca_disaster amt_ca_disaster heerf amt_heerf  {
gen `var'_sp=`var' if term_id==923|term_id==933|term_id==943|term_id==953|term_id==963|term_id==973|term_id==983|term_id==993|term_id==003|term_id==013|term_id==023|term_id==033|term_id==043|term_id==053|term_id==063|term_id==073|term_id==083|term_id==093|term_id==103|term_id==113|term_id==123|term_id==133|term_id==143|term_id==153|term_id==163|term_id==173|term_id==183|term_id==193|term_id==203|term_id==213|term_id==223|term_id==233|term_id==243|term_id==253 ///
|term_id==924|term_id==934|term_id==944|term_id==954|term_id==964|term_id==974|term_id==984|term_id==994|term_id==004|term_id==014|term_id==024|term_id==034|term_id==044|term_id==054|term_id==064|term_id==074|term_id==084|term_id==094|term_id==104|term_id==114|term_id==124|term_id==134|term_id==144|term_id==154|term_id==164|term_id==174|term_id==184|term_id==194|term_id==204|term_id==214|term_id==224|term_id==234|term_id==244|term_id==254
}

foreach var in bog amt_bog ab19 amt_ab19 fee_waiver loan amt_loan loan_sub amt_loansub loan_unsub amt_loanunsub loan_fed amt_loanfed pell amt_pell cgb amt_cgb cgc amt_cgc ftssg amt_ftssg cccg amt_cccg cga amt_cga sscg amt_sscg  grant amt_grant ws amt_ws ca_disaster amt_ca_disaster heerf amt_heerf  {
gen `var'_su=`var' if term_id==935|term_id==945|term_id==955|term_id==965|term_id==975|term_id==985|term_id==995|term_id==005|term_id==015|term_id==025|term_id==035|term_id==045|term_id==055|term_id==065|term_id==075|term_id==085|term_id==095|term_id==105|term_id==115|term_id==125|term_id==135|term_id==145|term_id==155|term_id==165|term_id==175|term_id==185|term_id==195|term_id==205|term_id==215|term_id==225|term_id==235|term_id==245|term_id==255 ///
|term_id==936|term_id==946|term_id==956|term_id==966|term_id==976|term_id==986|term_id==996|term_id==006|term_id==016|term_id==026|term_id==036|term_id==046|term_id==056|term_id==066|term_id==076|term_id==086|term_id==096|term_id==106|term_id==116|term_id==126|term_id==136|term_id==146|term_id==156|term_id==166|term_id==176|term_id==186|term_id==196|term_id==206|term_id==216|term_id==226|term_id==236|term_id==246|term_id==256
}


collapse (firstnm) budget_cat dep household family (sum) amt_bog amt_ab19 ///
amt_loan amt_loansub amt_loanunsub amt_loanfed amt_pell amt_cgb amt_cgc amt_ftssg ///
amt_cccg amt_sscg amt_cga amt_ca_disaster amt_heerf amt_grant amt_ws (max) efc fafsa bog* ab* fee* pell* ftssg* cccg* sscg* heerf* ca_disaster* ///
cg* grant* ws* loan* amt_cgb_* amt_cgc_* amt_ftssg_* amt_cccg_* amt_cga_* ///
amt_sscg_* amt_ab19_*  amt_pell_* amt_ca_disaster_* amt_heerf_* income* untax* sf_efc, ///
by(student college year) 
compress
save "$clean/SFA_Collapsed_year.dta", replace

*Indicator for if a student ever received a CCPG (formerly BOG) fee waiver
clear all
set more off
use "$clean/SFA_Collapsed_year.dta"
collapse (max) bog, by (student_id college_id)
compress
save "$clean/BOG.dta", replace



/*******************************************************************************
              Merge Collapsed Data Files Generated Above and HFFIRST
			  				  
Output: Intermediate data files SXST_merged.dta, SXSFAST_merged.dta, 
SXSFASTSP_merged.dta, Year_merged.dta
*******************************************************************************/

*Merge SX to ST 
clear all
set more off
use "$clean/SX_yearcollapsed.dta"
merge 1:1 student_id college_id year using "$clean/ST_CollapsedYear.dta"
/*
   Result                      Number of obs
    -----------------------------------------
    Not matched                    45,163,737
        from master                        70  (_merge==1)
        from using                 45,163,667  (_merge==2)

    Matched                        79,563,156  (_merge==3)
    -----------------------------------------
*Some students in ST file but not don't actually take courses. Drop these.
*/
drop if _merge==2
drop _merge
compress
save "$clean/SXST_merged.dta", replace


*Merge Financial Aid
clear all
set more off
use "$clean/SXST_merged.dta" 

merge 1:1 student_id college_id year using "$clean/SFA_Collapsed_year.dta"
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                    58,935,958
        from master                57,315,549  (_merge==1)
        from using                  1,620,409  (_merge==2)

    Matched                        22,247,677  (_merge==3)
    -----------------------------------------
 */

drop if _merge==2
drop _merge
compress
save "$clean/SXSFAST_merged.dta", replace


***Now Merge Degrees***
clear all
set more off
use "$clean/SXSFAST_merged.dta"
replace coll="799" if coll=="74A"
destring coll, replace

merge 1:1 student college year using "$clean/SP_collapsed.dta"
/*
     Result                      Number of obs
    -----------------------------------------
    Not matched                    76,779,764
        from master                76,418,964  (_merge==1)
        from using                    360,800  (_merge==2)

    Matched                         3,144,262  (_merge==3)
    -----------------------------------------
 */
drop if _merge==2
drop _merge
tab year,  m
compress
save "$clean/SXSFASTSP_merged.dta", replace 


clear all
set more off
use "$raw/HF_FIRST.dta"
replace coll="799" if coll=="74A"
destring college_id, replace
merge 1:m student_id college using "$clean/SXSFASTSP_merged.dta"
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                     7,497,884
        from master                 7,315,939  (_merge==1)
        from using                    181,945  (_merge==2)

    Matched                        79,381,281  (_merge==3)
    -----------------------------------------
*/
keep if _merge==3
drop _merge

drop ccc_first_term_loc ccc_first_term_nsa ccc_first_term_nsa_value ccc_first_term_nsa_loc ccc_first_term_cr ccc_first_term_cr_value ccc_first_term_cr_loc ccc_first_term_cr_nsa_loc ccc_first_term_ncr ccc_first_term_ncr_value ccc_first_term_ncr_loc ccc_first_term_ncr_nsa ccc_first_term_ncr_nsa_value ccc_first_term_ncr_nsa_loc first_term first_term_value first_term_loc first_term_nsa first_term_nsa_value first_term_nsa_loc first_term_cr first_term_cr_value first_term_cr_loc first_term_cr_nsa first_term_cr_nsa_value first_term_cr_nsa_loc v42

tab year, m 
compress
save "$clean/Year_merged.dta", replace 

*/
*/

*****CLEANING*****
clear all
set more off

*Load data
use "$clean/Year_merged.dta"

*String college and district ID variables

	*String
	tostring college_id, replace
	tostring district_id, replace

	*Add leading zero for two-digit IDs
	replace college_id = "0" + college_id if length(college_id)==2
	replace district_id = "0" + district_id if length(district_id)==2
	
	*Check that all college IDs are 3 digits
	assert length(college_id)==3 if !missing(college_id) 
	assert length(district_id)==3 if !missing(district_id) 

/*Use ccc_first_term_cr_nsa variable for a student's first term that they 
enrolled in credit units (cr) not as a special admit (nsa)

Note: ccc_first_term was generated here as ccc_first_term_cr_nsa, but 
ccc_first_term already exists as a variable in HFFIRST. I adjust this by only 
using the ccc_first_term_cr_nsa variable for clarity. I leave the "raw" 
ccc_first_term variable in the dataset as is. */

replace ccc_first_term_cr_nsa="" if ccc_first_term_cr_nsa=="X"
	
*Destring 
destring ccc_first_term_cr_nsa, replace

gen firstyear=.
replace firstyear=1992 if ccc_first_term_cr_nsa>=925 & ccc_first_term_cr_nsa<934
replace firstyear=1993 if ccc_first_term_cr_nsa>=935 & ccc_first_term_cr_nsa<944
replace firstyear=1994 if ccc_first_term_cr_nsa>=945 & ccc_first_term_cr_nsa<954
replace firstyear=1995 if ccc_first_term_cr_nsa>=955 & ccc_first_term_cr_nsa<964
replace firstyear=1996 if ccc_first_term_cr_nsa>=965 & ccc_first_term_cr_nsa<974
replace firstyear=1997 if ccc_first_term_cr_nsa>=975 & ccc_first_term_cr_nsa<984
replace firstyear=1998 if ccc_first_term_cr_nsa>=985 & ccc_first_term_cr_nsa<994

replace firstyear=1999 if ccc_first_term_cr_nsa==995|ccc_first_term_cr_nsa==996|ccc_first_term_cr_nsa==997|ccc_first_term_cr_nsa==998| ///
ccc_first_term_cr_nsa==001|ccc_first_term_cr_nsa==002|ccc_first_term_cr_nsa==003|ccc_first_term_cr_nsa==004

replace firstyear=2000 if ccc_first_term_cr_nsa>=005 & ccc_first_term_cr_nsa<=014
replace firstyear=2001 if ccc_first_term_cr_nsa>=015 & ccc_first_term_cr_nsa<=024
replace firstyear=2002 if ccc_first_term_cr_nsa>=025 & ccc_first_term_cr_nsa<=034
replace firstyear=2003 if ccc_first_term_cr_nsa>=035 & ccc_first_term_cr_nsa<=044
replace firstyear=2004 if ccc_first_term_cr_nsa>=045 & ccc_first_term_cr_nsa<=054
replace firstyear=2005 if ccc_first_term_cr_nsa>=055 & ccc_first_term_cr_nsa<=064
replace firstyear=2006 if ccc_first_term_cr_nsa>=065 & ccc_first_term_cr_nsa<=074
replace firstyear=2007 if ccc_first_term_cr_nsa>=075 & ccc_first_term_cr_nsa<=084
replace firstyear=2008 if ccc_first_term_cr_nsa>=085 & ccc_first_term_cr_nsa<=094
replace firstyear=2009 if ccc_first_term_cr_nsa>=095 & ccc_first_term_cr_nsa<=104
replace firstyear=2010 if ccc_first_term_cr_nsa>=105 & ccc_first_term_cr_nsa<=114
replace firstyear=2011 if ccc_first_term_cr_nsa>=115 & ccc_first_term_cr_nsa<=124
replace firstyear=2012 if ccc_first_term_cr_nsa>=125 & ccc_first_term_cr_nsa<=134
replace firstyear=2013 if ccc_first_term_cr_nsa>=135 & ccc_first_term_cr_nsa<=144
replace firstyear=2014 if ccc_first_term_cr_nsa>=145 & ccc_first_term_cr_nsa<=154
replace firstyear=2015 if ccc_first_term_cr_nsa>=155 & ccc_first_term_cr_nsa<=164
replace firstyear=2016 if ccc_first_term_cr_nsa>=165 & ccc_first_term_cr_nsa<=174
replace firstyear=2017 if ccc_first_term_cr_nsa>=175 & ccc_first_term_cr_nsa<=184
replace firstyear=2018 if ccc_first_term_cr_nsa>=185 & ccc_first_term_cr_nsa<=194
replace firstyear=2019 if ccc_first_term_cr_nsa>=195 & ccc_first_term_cr_nsa<=204
replace firstyear=2020 if ccc_first_term_cr_nsa>=205 & ccc_first_term_cr_nsa<=214
replace firstyear=2021 if ccc_first_term_cr_nsa>=215 & ccc_first_term_cr_nsa<=224
replace firstyear=2022 if ccc_first_term_cr_nsa>=225 & ccc_first_term_cr_nsa<=234
replace firstyear=2023 if ccc_first_term_cr_nsa>=235 & ccc_first_term_cr_nsa<=244

replace firstyear=2024 if ccc_first_term_cr_nsa>=245 & ccc_first_term_cr_nsa<=254
replace firstyear=2025 if ccc_first_term_cr_nsa>=255 & ccc_first_term_cr_nsa<=264

tab ccc_first_term_cr_nsa firstyear, m

*Generate race and gender variables
gen hispanic=.
replace hispanic=1 if race=="H."
replace hispanic=0 if race!="H."
gen asian=.
replace asian=1 if race=="A."
replace asian=0 if race!="A."
gen white=.
replace white=1 if race=="W."
replace white=0 if race!="W."
gen black=.
replace black=1 if race=="B."
replace black=0 if race!="B."
gen other_race=.
replace other_race=1 if race=="F."|race=="N."|race=="P."|race=="T."
replace other_race=0 if race=="H."|race=="A."|race=="W."|race=="B."|race=="X."
gen race_unknown=.
replace race_unknown=1 if race=="X."
replace race_unknown=0 if race!="X."
gen female=.
replace female=1 if gender=="F"|gender=="f"
replace female=0 if gender=="M"|gender=="m"

*Generate CA residence flag
gen residence=substr(res,1,1)
gen ca_resident=.
replace ca_resident=1 if residence=="5"
replace ca_resident=0 if residence=="6"|residence=="8"
drop residence

/*FirstGen: use CCCCO definition "First-Generation status is defined as a student for whom 
no parent or guardian has earned morethan a high school diploma nor has any college experience." 
https://datamart.cccco.edu/App_Doc/Scorecard_Data_Mart_Specs.pdf 
Position 1 – Parent/Guardian 1:
Coding Meaning
1 Grade 9 or less
2 Grade 10, 11, or 12 but did not graduate
3 High school graduate
4 Some college but no degree
5 AA/AS degree
6 BA/BS degree
7 Graduate or professional degree beyond a BA/BS
Y Not applicable, no first parent/guardian
X Unknown / Unreported 

*/
tab parent_ed, m 
gen par1=substr(parent_ed,1,1)
gen par2=substr(parent_ed,2,1)

gen firstgen=.
replace firstgen=1 if (par1>="1" & par1<"4") & (par1>="1" & par2<"4")
replace firstgen=1 if parent_ed=="1Y"|parent_ed=="2Y"|parent_ed=="3Y"
replace firstgen=1 if parent_ed=="1X"|parent_ed=="2X"|parent_ed=="3X"
replace firstgen=1 if parent_ed=="Y1"|parent_ed=="Y2"|parent_ed=="Y3"
replace firstgen=1 if parent_ed=="X1"|parent_ed=="X2"|parent_ed=="X3"
replace firstgen=0 if par1>="4" & par1<="7"
replace firstgen=0 if par2>="4" & par2<="7"
tab parent_ed firstgen, m 
drop par1 par2 

*Generate educational attainment variables
gen ed=substr(education,1,1)
gen hs_grad=.
replace hs_grad=1 if ed=="3"|ed=="4"|ed=="5"|ed=="6"|ed=="7"|ed=="8"
replace hs_grad=0 if ed=="0"|ed=="1"|ed=="2"
gen aa_deg=.
replace aa_deg=1 if ed=="7"
replace aa_deg=0 if ed=="0"|ed=="1"|ed=="2"|ed=="3"|ed=="4"|ed=="5"|ed=="6"
gen ba_deg=.
replace ba_deg=1 if ed=="8"
replace ba_deg=0 if ed=="0"|ed=="1"|ed=="2"|ed=="3"|ed=="4"|ed=="5"|ed=="6"| ///
ed=="7"

*Financial Aid Variables (e.g. where 2012 denotes 2012-2013)
gen efc_max=.
replace efc_max=2100 if year==1993
replace efc_max=2140 if year==1994
replace efc_max=2240 if year==1995
replace efc_max=2270 if year==1996
replace efc_max=2500 if year==1997
replace efc_max=2500 if year==1998
replace efc_max=2925 if year==1999
replace efc_max=3100 if year==2000
replace efc_max=3550 if year==2001
replace efc_max=3800 if year==2002
replace efc_max=3850 if year==2003
replace efc_max=3850 if year==2004
replace efc_max=3850 if year==2005
replace efc_max=3850 if year==2006
replace efc_max=4110 if year==2007
replace efc_max=4041 if year==2008
replace efc_max=4617 if year==2009
replace efc_max=5273 if year==2010
replace efc_max=5273 if year==2011
replace efc_max=4995 if year==2012
replace efc_max=5081 if year==2013
replace efc_max=5157 if year==2014
replace efc_max=5198 if year==2015
replace efc_max=5234 if year==2016
replace efc_max=5328 if year==2017
replace efc_max=5486 if year==2018
replace efc_max=5576 if year==2019
replace efc_max=5711 if year==2020 
replace efc_max=5846 if year==2021
replace efc_max=6206 if year==2022
replace efc_max=6656 if year==2023
*Replaced by SAI for 2024-on

*Generate dependent variables
gen dependent=.
replace dependent=1 if dependency_status=="D"
replace dependent=0 if dependency_status=="I"|dependency_status=="O"|dependency_status=="i"
gen marital_status=substr(fam,1,1)
gen married=.
replace married=1 if marital_status=="M"
replace married=0 if marital_status=="S"|marital_status=="U"
drop marital_status 
gen number_dependents=substr(fam,2,1)
gen has_dependents=.
replace has_dependents=1 if number_dependents=="D"
replace has_dependents=0 if number_dependents=="N"
drop number_dependents

*Generate housing variables
gen housing_campus=.
replace housing_campus=1 if budget_cat=="C"
replace housing_campus=0 if budget_cat!="C"
gen housing_offcampus=.
replace housing_offcampus=1 if budget_cat=="O"
replace housing_offcampus=0 if budget_cat!="O"
gen housing_withparents=.
replace housing_withparents=1 if budget_cat=="H"
replace housing_withparents=0 if budget_cat!="H"
rename household_size sf_household
gen household_size=sf_household if sf_household<99
gen parent_incomeagi= income_agi_parent if income_agi_parent<888888
gen student_incomeagi=income_agi_student if income_agi_student<888888

*Household Size
gen hh_1=.
replace hh_1=1 if household_size==1
replace hh_1=0 if household_size>1
tab hh_1, m
gen hh_2=.
replace hh_2=1 if household_size==2
replace hh_2=0 if household_size<2
replace hh_2=0 if household_size>2
gen hh_3=.
replace hh_3=1 if household_size==3
replace hh_3=0 if household_size<3
replace hh_3=0 if household_size>3
gen hh_4=.
replace hh_4=1 if household_size==4
replace hh_4=0 if household_size<4
replace hh_4=0 if household_size>4
gen hh_5=.
replace hh_5=1 if household_size==5
replace hh_5=0 if household_size<5
replace hh_5=0 if household_size>5
gen hh_6=.
replace hh_6=1 if household_size>=6
replace hh_6=0 if household_size<6

drop budget_cat dependency_status sf_house fam income_agi_student untax*

*Generate Pell eligibility 
gen pell_eligible=.
replace pell_eligible=1 if efc<=efc_max
replace pell_eligible=0 if efc>efc_max
tab year pell_eligible, r
la var pell_eligible "Pell Eligible-Year" 
*Check pell_eligible for 1992
*codebook efc_max if year==1992

*Replace missings variable entries with zeros. But not for units  (missings are different than 0s)
*units_attempted_f units_attempted_w units_attempted_sp units_attempted_su units_f units_sp units_su units_w ///

foreach var in transfer_math transfer_eng deg_math deg_eng specialadmit ///
associate credit_cert creditcert_30plus creditcert_30less hispanic asian white ///
black other_race race_unknown female hs_grad aa_deg ba_deg dependent ///
married has_dependents housing_campus housing_offcampus housing_withparents ///
hh_1 hh_2 hh_3 hh_4 hh_5 hh_6 pell_eligible ///
amt_bog amt_ab19 amt_loan amt_loansub amt_loanunsub amt_loanfed amt_pell amt_cgb amt_cgc amt_ftssg ///
amt_cccg amt_sscg amt_cga amt_ca_disaster amt_heerf amt_grant amt_ws ///
fafsa bog bog_f bog_w bog_sp bog_su ab19 ab19_f ab19_w ab19_sp ab19_su fee_waiver fee_waiver_f fee_waiver_w fee_waiver_sp fee_waiver_su pell pell_f pell_w pell_sp pell_su ftssg ftssg_f ftssg_w ftssg_sp ftssg_su cccg cccg_f cccg_w cccg_sp cccg_su sscg sscg_f sscg_w sscg_sp sscg_su cgb cgc cga cgb_f cgc_f cga_f cgb_w cga_w cgb_sp cgc_sp cgb_su cgc_su cga_su grant grant_f grant_w grant_sp grant_su ws ws_f ws_w ws_sp ws_su loan loan_sub loan_unsub loan_fed loan_f loan_sub_f loan_unsub_f loan_fed_f loan_w loan_sub_w loan_unsub_w loan_fed_w loan_sp loan_sub_sp loan_unsub_sp loan_fed_sp loan_su loan_sub_su loan_unsub_su loan_fed_su amt_cgb_f amt_cgb_w amt_cgb_sp amt_cgb_su amt_cgc_f amt_cgc_w amt_cgc_sp amt_cgc_su amt_ftssg_f amt_ftssg_w amt_ftssg_sp amt_ftssg_su amt_cccg_f amt_cccg_w amt_cccg_sp amt_cccg_su amt_cga_f amt_cga_w amt_cga_sp amt_cga_su amt_sscg_f amt_sscg_w amt_sscg_sp amt_sscg_su amt_ab19_f amt_ab19_w amt_ab19_sp amt_ab19_su amt_pell_f amt_pell_w amt_pell_sp amt_pell_su amt_ca_disaster_f amt_ca_disaster_w amt_ca_disaster_sp amt_ca_disaster_su amt_heerf_f amt_heerf_w amt_heerf_sp amt_heerf_su {
replace `var'=0 if `var'==.	
}

*Label
la var bog_f "BOG Waiver-Fall"
la var married "Married"
la var household_size "Household Size"
la var housing_campus "Lives On Campus" 
la var housing_offcampus "Lives OffCampus No Parents"
la var housing_withparents  "Lives With Parents"
la var hispanic "Hispanic" 
la var asian "Asian" 
la var white "White" 
la var black "Black" 
la var female "Female"
la var age_at_term "Min Age-Year" 
la var efc "EFC" 
la var fafsa "Submitted FAFSA"
la var dependent "Dependent"
la var has_dependents "Has Dependents" 
la var parent_incomeagi "Parent Income"
la var student_incomeagi "Student Income" 
la var units_attempted "Units Enroll-Year"
la var units "Units Earned-Year"
la var units_attempted_f "Units Enroll-Fall" 
la var units_f "Units Earned-Fall"  
la var units_attempted_w "Units Enroll-Winter" 
la var units_w "Units Earned-Winter"
la var units_attempted_sp "Units Enroll-Spring"  
la var units_attempted_sp "Units Enrolled-Spring"   
la var units_attempted_su "Units Enrolled-Summer"  
la var units_sp "Units Earned-Spring"   
la var units_su "Units Earned-Summer"   
/*la var unit_deg "Degree Units Earned-Year"
*la var unit_deg_f "Degree Units Earned-Fall"
*la var unit_deg_w "Degree Units Earned-Winter"
*la var unit_deg_sp "Degree Units Earned-Spring"
*la var unit_deg_su "Degree Units Earned-Summer"
la var unita_deg "Degree Units Attempted-Year"
la var unita_deg_f "Degree Units Attempted-Fall"
la var unita_deg_w "Degree Units Attempted-Winter"
la var unita_deg_sp "Degree Units Attempted-Spring"
la var unita_deg_su "Degree Units Attempted-Summer" */
la var student_ssn "Scrambled SSN" 
la var firstgen "First Generation"
la var ccc_first_term_cr_nsa_value "First Term" 
la var other_race "Other Race" 
la var race_unknown "Race Unknown" 
la var pell_f "Recd Pell-Fall"
la var pell_w "Recd Pell-Winter"
la var pell_sp "Recd Pell-Spring"
la var pell_su "Recd Pell-Summer" 
la var bog_w "Recd BOG-Winter" 
la var bog_sp "Recd BOG-Spring" 
la var bog_su "Recd BOG-Summer"
la var bog  "Recd BOG"
la var pell "Recd Pell"
la var cgb "Recd CalGrantB"
la var cgc "Recd CalGrantC" 
la var ftssg "Recd FTSSG"
la var cccg "Recd CCG"
la var cga "Recd Cal Grant A"
la var sscg "Recd SSCG"
la var ab19 "Rec AB19 Waiver" 
la var cgb_f "Recd CalGrantB-Fall" 
la var cgc_f "Recd CalGrantC-Fall" 
la var ftssg_f "FTSSG-Fall" 
la var cccg_f "CCCG-Fall"
la var sscg_f "SSCG-Fall"
la var cgb_w "CalGrantB-Winter" 
la var cgc_w "CalGrantC-Winter" 
la var ftssg_w "FTSSG-Winter" 
la var cccg_w "CCCG-Winter" 
la var sscg_w "SSCG-Winter" 
la var cgb_sp "CalGrantB-Spring" 
la var cgc_sp "CalGrantC-Spring" 
la var cgb_su "CalGrantB-Summer"
la var cgc_su "CalGrantC-Summer"
la var ftssg_sp "FTSSG-Spring" 
la var ftssg_su "FTSSG-Summer" 
la var cccg_sp "CCCG-Spring" 
la var cccg_su "CCCG-Summer" 
la var sscg_sp "SSCG-Spring"  
la var sscg_su "SSCG-Summer" 
la var ca_disaster "CADisaster"
la var ca_disaster_f  "CADisaster-Fall"
la var ca_disaster_sp "CADisaster$-Spring"
la var ca_disaster_w "CADisaster$-Winter"
la var ca_disaster_su "CADisaster$-Summer"
la var heerf "Recd HEERF"
la var heerf_f "HEERF-Fall"
la var heerf_w "HEERF-Winter" 
la var heerf_sp "HEERF-Spring" 
la var heerf_su "HEERF-Summer"
la var fee_waiver "Recd Fee Waiver"
la var fee_waiver_f "Fee Waiver-Fal"
la var fee_waiver_w "Fee Waiver-Winter"
la var fee_waiver_sp "Fee Waiver-Spring"
la var fee_waiver_su "Fee Waiver-Summer"
la var ab19 "Recd AB19-Year"
la var ab19_f "AB19-Fall"
la var ab19_w "AB19-Winter"
la var ab19_sp "AB19-Spring"
la var ab19_su "AB19-Summer"
la var cga_f "CalGrantA"
la var cga_w "CalGrantA-Winter"
la var cga_sp "CalGrantA-Spring"
la var cga_su "CalGrantA-Summer"
la var grant "Recd Grant-Year" 
la var ws "Recd Work Study-Year" 
la var loan "Recd Loan-Year"  
la var loan_sub "Subsidized Loan-Year"  
la var loan_unsub "Unubsidized Loan-Year"   
la var loan_fed "Federal Loan-Year"   
la var efc_max "Max EFC for Pell-Eligibility" 
la var education "Education Level at Entry"
la var hs_grad "HS Grad at Entry"
la var aa_deg "AA Degree at Entry" 
la var ba_deg "BA Degree at Entry" 
la var amt_bog "BOG$-Year"
la var amt_loan "Loan$-Year"
la var amt_loansub "SubLoan$-Year"
la var amt_loanunsub "UnsubLoan$-Year" 
la var amt_loanfed "FedLoan$-Year"  
la var amt_pell "Pell$-Year" 
la var amt_cgb "CalGrantB$-Year"
la var amt_cgc "CalGrantB$-Year" 
la var amt_grant "Grant$-Year" 
la var amt_ws "WorkStudy$-Year" 
la var amt_cgb_f "CalGrantB$-Fall" 
la var amt_cgc_f "CalGrantC$-Fall" 
la var amt_ftssg_f "FTSSG-Fall" 
la var amt_cccg_f "CCCG-Fall"
la var amt_sscg_f "SSCG-Fall"
la var amt_cgb_w "CalGrantB-Winter" 
la var amt_cgc_w "CalGrantC-Winter" 
la var amt_ftssg_w "FTSSG-Winter" 
la var amt_cccg_w "CCCG-Winter" 
la var amt_sscg_w "SSCG-Winter" 
la var amt_cgb_sp "CalGrantB-Spring" 
la var amt_cgc_sp "CalGrantC-Spring" 
la var amt_ftssg_sp "FTSSG-Spring" 
la var amt_ftssg_su "FTSSG-Summer" 
la var amt_cccg_sp "CCCG-Spring" 
la var amt_cccg_su "CCCG-Summer" 
la var amt_sscg_sp "SSCG-Spring"  
la var amt_sscg_su "SSCG-Summer" 
la var amt_ftssg "FTSSG$-Year"
la var amt_cccg "CCCG$-Year"
la var amt_sscg "SSCG$-Year"
la var amt_cga "CGA$-Year"
la var amt_ab19 "AB19$-Year"
la var amt_ca_disaster "CADisaster$-Year"
la var amt_ca_disaster_f  "CADisaster$-Fall"
la var amt_ca_disaster_sp "CADisaster$-Spring"
la var amt_ca_disaster_w "CADisaster$-Winter"
la var amt_ca_disaster_su "CADisaster$-Summer"
la var amt_heerf "Recd HEERF-Year"
la var amt_heerf_f "HEERF-Year"
la var amt_heerf_w "HEERF-Winter" 
la var amt_heerf_sp "HEERF-Spring" 
la var amt_heerf_su "HEERF-Summer"
la var sf_efc "EFC"
la var name_first "First Name" 
la var name_last "Last Name" 
la var zip_code "Zip Code"
la var high_school "Last High School"
la var associate "Earned AA/AS"
la var credit_cert "Earned Credit Certificate"
la var creditcert_30plus "Earned 30+ Unit Credit Certificate" 
la var creditcert_30less "Earned <30 Unit Credit Certificate" 
la var firstyear "First Year"
la var transfer_math "Took Transfer-Level Math"
la var transfer_eng "Took Transfer-Level English" 
la var deg_math "Took Degree-Level Math" 
la var deg_eng "Took Degree-Level English"
la var hh_1 "Household Size-1"
la var hh_2 "Household Size-2" 
la var hh_3 "Household Size-3"  
la var hh_4 "Household Size-4" 
la var hh_5 "Household Size-5"  
la var hh_6 "Household Size-6" 
la var year "Academic Year"
la var student_id "Student Identifier"
la var college_id "Campus Identifier" 

tab year pell,m 
tab year pell if units_attempted_f>=12 & units_attempted_sp>=12 & units_attempted_f!=. & units_attempted_sp!=., m
compress

save "$clean/Year_Cleaned.dta", replace

/*
*Now Add Pell Max for each EFC-Year
clear all
set more off
use "$clean/Year_Cleaneda.dta"
*Pell Max (need to update for 21-22)
gen pell_max=.

*2020-21
replace pell_max=6345	if efc==0	& year==2020
replace pell_max=6295	if efc>	0	& efc<=	100	& year==2020
replace pell_max=6195	if efc>	100	& efc<=	200	& year==2020
replace pell_max=6095	if efc>	200	& efc<=	300	& year==2020
replace pell_max=5995	if efc>	300	& efc<=	400	& year==2020
replace pell_max=5895	if efc>	400	& efc<=	500	& year==2020
replace pell_max=5795	if efc>	500	& efc<=	600	& year==2020
replace pell_max=5695	if efc>	600	& efc<=	700	& year==2020
replace pell_max=5595	if efc>	700	& efc<=	800	& year==2020
replace pell_max=5495	if efc>	800	& efc<=	900	& year==2020
replace pell_max=5395	if efc>	900	& efc<=	1000	& year==2020
replace pell_max=5295	if efc>	1000	& efc<=	1100	& year==2020
replace pell_max=5195	if efc>	1100	& efc<=	1200	& year==2020
replace pell_max=5095	if efc>	1200	& efc<=	1300	& year==2020
replace pell_max=4995	if efc>	1300	& efc<=	1400	& year==2020
replace pell_max=4895	if efc>	1400	& efc<=	1500	& year==2020
replace pell_max=4795	if efc>	1500	& efc<=	1600	& year==2020
replace pell_max=4695	if efc>	1600	& efc<=	1700	& year==2020
replace pell_max=4595	if efc>	1700	& efc<=	1800	& year==2020
replace pell_max=4495	if efc>	1800	& efc<=	1900	& year==2020
replace pell_max=4395	if efc>	1900	& efc<=	2000	& year==2020
replace pell_max=4295	if efc>	2000	& efc<=	2100	& year==2020
replace pell_max=4195	if efc>	2100	& efc<=	2200	& year==2020
replace pell_max=4095	if efc>	2200	& efc<=	2300	& year==2020
replace pell_max=3995	if efc>	2300	& efc<=	2400	& year==2020
replace pell_max=3895	if efc>	2400	& efc<=	2500	& year==2020
replace pell_max=3795	if efc>	2500	& efc<=	2600	& year==2020
replace pell_max=3695	if efc>	2600	& efc<=	2700	& year==2020
replace pell_max=3595	if efc>	2700	& efc<=	2800	& year==2020
replace pell_max=3495	if efc>	2800	& efc<=	2900	& year==2020
replace pell_max=3395	if efc>	2900	& efc<=	3000	& year==2020
replace pell_max=3295	if efc>	3000	& efc<=	3100	& year==2020
replace pell_max=3195	if efc>	3100	& efc<=	3200	& year==2020
replace pell_max=3095	if efc>	3200	& efc<=	3300	& year==2020
replace pell_max=2995	if efc>	3300	& efc<=	3400	& year==2020
replace pell_max=2895	if efc>	3400	& efc<=	3500	& year==2020
replace pell_max=2795	if efc>	3500	& efc<=	3600	& year==2020
replace pell_max=2695	if efc>	3600	& efc<=	3700	& year==2020
replace pell_max=2595	if efc>	3700	& efc<=	3800	& year==2020
replace pell_max=2495	if efc>	3800	& efc<=	3900	& year==2020
replace pell_max=2395	if efc>	3900	& efc<=	4000	& year==2020
replace pell_max=2295	if efc>	4000	& efc<=	4100	& year==2020
replace pell_max=2195	if efc>	4100	& efc<=	4200	& year==2020
replace pell_max=2095	if efc>	4200	& efc<=	4300	& year==2020
replace pell_max=1955	if efc>	4300	& efc<=	4400	& year==2020
replace pell_max=1895	if efc>	4400	& efc<=	4500	& year==2020
replace pell_max=1795	if efc>	4500	& efc<=	4600	& year==2020
replace pell_max=1695	if efc>	4600	& efc<=	4700	& year==2020
replace pell_max=1595	if efc>	4700	& efc<=	4800	& year==2020
replace pell_max=1495	if efc>	4800	& efc<=	4900	& year==2020
replace pell_max=1395   if efc>	4900	& efc<=	5000	& year==2020
replace pell_max=1295	if efc>	5000	& efc<=	5100	& year==2020
replace pell_max=1195	if efc>	5100	& efc<=	5200	& year==2020
replace pell_max=1095	if efc>	5200	& efc<=	5300	& year==2020
replace pell_max=995	if efc>	5300	& efc<=	5328	& year==2020
replace pell_max=895	if efc>	5400	& efc<=	5500	& year==2020
replace pell_max=795	if efc>	5500	& efc<=	5600	& year==2020
replace pell_max=695	if efc>	5600	& efc<=	5700	& year==2020
replace pell_max=639	if efc>	5700	& efc<=	5711	& year==2020
replace pell_max=0		if efc>	5712	& year==2020

*2019-20
replace pell_max=6195	if efc==0	& year==2019
replace pell_max=6145	if efc>	0	& efc<=	100	& year==2019
replace pell_max=6045	if efc>	100	& efc<=	200	& year==2019
replace pell_max=5945	if efc>	200	& efc<=	300	& year==2019
replace pell_max=5845	if efc>	300	& efc<=	400	& year==2019
replace pell_max=5745	if efc>	400	& efc<=	500	& year==2019
replace pell_max=5645	if efc>	500	& efc<=	600	& year==2019
replace pell_max=5545	if efc>	600	& efc<=	700	& year==2019
replace pell_max=5445	if efc>	700	& efc<=	800	& year==2019
replace pell_max=5345	if efc>	800	& efc<=	900	& year==2019
replace pell_max=5245	if efc>	900	& efc<=	1000	& year==2019
replace pell_max=5145	if efc>	1000	& efc<=	1100	& year==2019
replace pell_max=5045	if efc>	1100	& efc<=	1200	& year==2019
replace pell_max=4945	if efc>	1200	& efc<=	1300	& year==2019
replace pell_max=4845	if efc>	1300	& efc<=	1400	& year==2019
replace pell_max=4745	if efc>	1400	& efc<=	1500	& year==2019
replace pell_max=4645	if efc>	1500	& efc<=	1600	& year==2019
replace pell_max=4545	if efc>	1600	& efc<=	1700	& year==2019
replace pell_max=4445	if efc>	1700	& efc<=	1800	& year==2019
replace pell_max=4345	if efc>	1800	& efc<=	1900	& year==2019
replace pell_max=4245	if efc>	1900	& efc<=	2000	& year==2019
replace pell_max=4145	if efc>	2000	& efc<=	2100	& year==2019
replace pell_max=4045	if efc>	2100	& efc<=	2200	& year==2019
replace pell_max=3945	if efc>	2200	& efc<=	2300	& year==2019
replace pell_max=3845	if efc>	2300	& efc<=	2400	& year==2019
replace pell_max=3745	if efc>	2400	& efc<=	2500	& year==2019
replace pell_max=3645	if efc>	2500	& efc<=	2600	& year==2019
replace pell_max=3545	if efc>	2600	& efc<=	2700	& year==2019
replace pell_max=3445	if efc>	2700	& efc<=	2800	& year==2019
replace pell_max=3345	if efc>	2800	& efc<=	2900	& year==2019
replace pell_max=3245	if efc>	2900	& efc<=	3000	& year==2019
replace pell_max=3145	if efc>	3000	& efc<=	3100	& year==2019
replace pell_max=3045	if efc>	3100	& efc<=	3200	& year==2019
replace pell_max=2945	if efc>	3200	& efc<=	3300	& year==2019
replace pell_max=2845	if efc>	3300	& efc<=	3400	& year==2019
replace pell_max=2745	if efc>	3400	& efc<=	3500	& year==2019
replace pell_max=2645	if efc>	3500	& efc<=	3600	& year==2019
replace pell_max=2545	if efc>	3600	& efc<=	3700	& year==2019
replace pell_max=2445	if efc>	3700	& efc<=	3800	& year==2019
replace pell_max=2345	if efc>	3800	& efc<=	3900	& year==2019
replace pell_max=2245	if efc>	3900	& efc<=	4000	& year==2019
replace pell_max=2145	if efc>	4000	& efc<=	4100	& year==2019
replace pell_max=2045	if efc>	4100	& efc<=	4200	& year==2019
replace pell_max=1945	if efc>	4200	& efc<=	4300	& year==2019
replace pell_max=1845	if efc>	4300	& efc<=	4400	& year==2019
replace pell_max=1745	if efc>	4400	& efc<=	4500	& year==2019
replace pell_max=1645	if efc>	4500	& efc<=	4600	& year==2019
replace pell_max=1545	if efc>	4600	& efc<=	4700	& year==2019
replace pell_max=1445	if efc>	4700	& efc<=	4800	& year==2019
replace pell_max=1345	if efc>	4800	& efc<=	4900	& year==2019
replace pell_max=1245   if efc>	4900	& efc<=	5000	& year==2019
replace pell_max=1145	if efc>	5000	& efc<=	5100	& year==2019
replace pell_max=1045	if efc>	5100	& efc<=	5200	& year==2019
replace pell_max=945	if efc>	5200	& efc<=	5300	& year==2019
replace pell_max=845	if efc>	5300	& efc<=	5328	& year==2019
replace pell_max=745	if efc>	5400	& efc<=	5500	& year==2019
replace pell_max=657	if efc>	5500	& efc<=	5576	& year==2019
replace pell_max=0		if efc>	5576	& year==2019

*2018
replace pell_max=	6095	if efc==0			& year==	2018
replace pell_max=	6045	if efc>	0	& efc<=	100	& year==	2018
replace pell_max=	5945	if efc>	100	& efc<=	200	& year==	2018
replace pell_max=	5845	if efc>	200	& efc<=	300	& year==	2018
replace pell_max=	5745	if efc>	300	& efc<=	400	& year==	2018
replace pell_max=	5645	if efc>	400	& efc<=	500	& year==	2018
replace pell_max=	5545	if efc>	500	& efc<=	600	& year==	2018
replace pell_max=	5445	if efc>	600	& efc<=	700	& year==	2018
replace pell_max=	5345	if efc>	700	& efc<=	800	& year==	2018
replace pell_max=	5245	if efc>	800	& efc<=	900	& year==	2018
replace pell_max=	5145	if efc>	900	& efc<=	1000	& year==	2018
replace pell_max=	5045	if efc>	1000	& efc<=	1100	& year==	2018
replace pell_max=	4945	if efc>	1100	& efc<=	1200	& year==	2018
replace pell_max=	4845	if efc>	1200	& efc<=	1300	& year==	2018
replace pell_max=	4745	if efc>	1300	& efc<=	1400	& year==	2018
replace pell_max=	4645	if efc>	1400	& efc<=	1500	& year==	2018
replace pell_max=	4545	if efc>	1500	& efc<=	1600	& year==	2018
replace pell_max=	4445	if efc>	1600	& efc<=	1700	& year==	2018
replace pell_max=	4345	if efc>	1700	& efc<=	1800	& year==	2018
replace pell_max=	4245	if efc>	1800	& efc<=	1900	& year==	2018
replace pell_max=	4145	if efc>	1900	& efc<=	2000	& year==	2018
replace pell_max=	4045	if efc>	2000	& efc<=	2100	& year==	2018
replace pell_max=	3945	if efc>	2100	& efc<=	2200	& year==	2018
replace pell_max=	3845	if efc>	2200	& efc<=	2300	& year==	2018
replace pell_max=	3745	if efc>	2300	& efc<=	2400	& year==	2018
replace pell_max=	3645	if efc>	2400	& efc<=	2500	& year==	2018
replace pell_max=	3545	if efc>	2500	& efc<=	2600	& year==	2018
replace pell_max=	3445	if efc>	2600	& efc<=	2700	& year==	2018
replace pell_max=	3345	if efc>	2700	& efc<=	2800	& year==	2018
replace pell_max=	3245	if efc>	2800	& efc<=	2900	& year==	2018
replace pell_max=	3145	if efc>	2900	& efc<=	3000	& year==	2018
replace pell_max=	3045	if efc>	3000	& efc<=	3100	& year==	2018
replace pell_max=	2945	if efc>	3100	& efc<=	3200	& year==	2018
replace pell_max=	2845	if efc>	3200	& efc<=	3300	& year==	2018
replace pell_max=	2745	if efc>	3300	& efc<=	3400	& year==	2018
replace pell_max=	2645	if efc>	3400	& efc<=	3500	& year==	2018
replace pell_max=	2545	if efc>	3500	& efc<=	3600	& year==	2018
replace pell_max=	2445	if efc>	3600	& efc<=	3700	& year==	2018
replace pell_max=	2345	if efc>	3700	& efc<=	3800	& year==	2018
replace pell_max=	2245	if efc>	3800	& efc<=	3900	& year==	2018
replace pell_max=	2145	if efc>	3900	& efc<=	4000	& year==	2018
replace pell_max=	2045	if efc>	4000	& efc<=	4100	& year==	2018
replace pell_max=	1945	if efc>	4100	& efc<=	4200	& year==	2018
replace pell_max=	1845	if efc>	4200	& efc<=	4300	& year==	2018
replace pell_max=	1745	if efc>	4300	& efc<=	4400	& year==	2018
replace pell_max=	1645	if efc>	4400	& efc<=	4500	& year==	2018
replace pell_max=	1545	if efc>	4500	& efc<=	4600	& year==	2018
replace pell_max=	1445	if efc>	4600	& efc<=	4700	& year==	2018
replace pell_max=	1345	if efc>	4700	& efc<=	4800	& year==	2018
replace pell_max=	1245	if efc>	4800	& efc<=	4900	& year==	2018
replace pell_max=	1145	if efc>	4900	& efc<=	5000	& year==	2018
replace pell_max=	1045	if efc>	5000	& efc<=	5100	& year==	2018
replace pell_max=	945	if efc>	5100	& efc<=	5200	& year==	2018
replace pell_max=	845	if efc>	5200	& efc<=	5300	& year==	2018
replace pell_max=	745	if efc>	5300	& efc<=	5329	& year==	2018
replace pell_max=	652	if efc>	5400	& efc<=	5486	& year==	2018
replace pell_max=	0	if efc>	5486			& year==	2018
replace pell_max=	5920	if efc==0			& year==	2017
replace pell_max=	5870	if efc>	0	& efc<=	100	& year==	2017
replace pell_max=	5770	if efc>	100	& efc<=	200	& year==	2017
replace pell_max=	5670	if efc>	200	& efc<=	300	& year==	2017
replace pell_max=	5570	if efc>	300	& efc<=	400	& year==	2017
replace pell_max=	5470	if efc>	400	& efc<=	500	& year==	2017
replace pell_max=	5370	if efc>	500	& efc<=	600	& year==	2017
replace pell_max=	5270	if efc>	600	& efc<=	700	& year==	2017
replace pell_max=	5170	if efc>	700	& efc<=	800	& year==	2017
replace pell_max=	5070	if efc>	800	& efc<=	900	& year==	2017
replace pell_max=	4970	if efc>	900	& efc<=	1000	& year==	2017
replace pell_max=	4870	if efc>	1000	& efc<=	1100	& year==	2017
replace pell_max=	4770	if efc>	1100	& efc<=	1200	& year==	2017
replace pell_max=	4670	if efc>	1200	& efc<=	1300	& year==	2017
replace pell_max=	4570	if efc>	1300	& efc<=	1400	& year==	2017
replace pell_max=	4470	if efc>	1400	& efc<=	1500	& year==	2017
replace pell_max=	4370	if efc>	1500	& efc<=	1600	& year==	2017
replace pell_max=	4270	if efc>	1600	& efc<=	1700	& year==	2017
replace pell_max=	4170	if efc>	1700	& efc<=	1800	& year==	2017
replace pell_max=	4070	if efc>	1800	& efc<=	1900	& year==	2017
replace pell_max=	3970	if efc>	1900	& efc<=	2000	& year==	2017
replace pell_max=	3870	if efc>	2000	& efc<=	2100	& year==	2017
replace pell_max=	3770	if efc>	2100	& efc<=	2200	& year==	2017
replace pell_max=	3670	if efc>	2200	& efc<=	2300	& year==	2017
replace pell_max=	3570	if efc>	2300	& efc<=	2400	& year==	2017
replace pell_max=	3470	if efc>	2400	& efc<=	2500	& year==	2017
replace pell_max=	3370	if efc>	2500	& efc<=	2600	& year==	2017
replace pell_max=	3270	if efc>	2600	& efc<=	2700	& year==	2017
replace pell_max=	3170	if efc>	2700	& efc<=	2800	& year==	2017
replace pell_max=	3070	if efc>	2800	& efc<=	2900	& year==	2017
replace pell_max=	2970	if efc>	2900	& efc<=	3000	& year==	2017
replace pell_max=	2870	if efc>	3000	& efc<=	3100	& year==	2017
replace pell_max=	2770	if efc>	3100	& efc<=	3200	& year==	2017
replace pell_max=	2670	if efc>	3200	& efc<=	3300	& year==	2017
replace pell_max=	2570	if efc>	3300	& efc<=	3400	& year==	2017
replace pell_max=	2470	if efc>	3400	& efc<=	3500	& year==	2017
replace pell_max=	2370	if efc>	3500	& efc<=	3600	& year==	2017
replace pell_max=	2270	if efc>	3600	& efc<=	3700	& year==	2017
replace pell_max=	2170	if efc>	3700	& efc<=	3800	& year==	2017
replace pell_max=	2070	if efc>	3800	& efc<=	3900	& year==	2017
replace pell_max=	1970	if efc>	3900	& efc<=	4000	& year==	2017
replace pell_max=	1870	if efc>	4000	& efc<=	4100	& year==	2017
replace pell_max=	1770	if efc>	4100	& efc<=	4200	& year==	2017
replace pell_max=	1670	if efc>	4200	& efc<=	4300	& year==	2017
replace pell_max=	1570	if efc>	4300	& efc<=	4400	& year==	2017
replace pell_max=	1470	if efc>	4400	& efc<=	4500	& year==	2017
replace pell_max=	1370	if efc>	4500	& efc<=	4600	& year==	2017
replace pell_max=	1270	if efc>	4600	& efc<=	4700	& year==	2017
replace pell_max=	1170	if efc>	4700	& efc<=	4800	& year==	2017
replace pell_max=	1070	if efc>	4800	& efc<=	4900	& year==	2017
replace pell_max=	970	if efc>	4900	& efc<=	5000	& year==	2017
replace pell_max=	870	if efc>	5000	& efc<=	5100	& year==	2017
replace pell_max=	770	if efc>	5100	& efc<=	5200	& year==	2017
replace pell_max=	670	if efc>	5200	& efc<=	5300	& year==	2017
replace pell_max=	606	if efc>	5300	& efc<=	5329	& year==	2017
replace pell_max=	0	if efc>	5329			& year==	2017
replace pell_max=	5815	if efc==0			& year==	2016
replace pell_max=	5765	if efc>	0	& efc<=	100	& year==	2016
replace pell_max=	5665	if efc>	100	& efc<=	200	& year==	2016
replace pell_max=	5565	if efc>	200	& efc<=	300	& year==	2016
replace pell_max=	5465	if efc>	300	& efc<=	400	& year==	2016
replace pell_max=	5365	if efc>	400	& efc<=	500	& year==	2016
replace pell_max=	5265	if efc>	500	& efc<=	600	& year==	2016
replace pell_max=	5165	if efc>	600	& efc<=	700	& year==	2016
replace pell_max=	5065	if efc>	700	& efc<=	800	& year==	2016
replace pell_max=	4965	if efc>	800	& efc<=	900	& year==	2016
replace pell_max=	4865	if efc>	900	& efc<=	1000	& year==	2016
replace pell_max=	4765	if efc>	1000	& efc<=	1100	& year==	2016
replace pell_max=	4665	if efc>	1100	& efc<=	1200	& year==	2016
replace pell_max=	4565	if efc>	1200	& efc<=	1300	& year==	2016
replace pell_max=	4465	if efc>	1300	& efc<=	1400	& year==	2016
replace pell_max=	4365	if efc>	1400	& efc<=	1500	& year==	2016
replace pell_max=	4265	if efc>	1500	& efc<=	1600	& year==	2016
replace pell_max=	4165	if efc>	1600	& efc<=	1700	& year==	2016
replace pell_max=	4065	if efc>	1700	& efc<=	1800	& year==	2016
replace pell_max=	3965	if efc>	1800	& efc<=	1900	& year==	2016
replace pell_max=	3865	if efc>	1900	& efc<=	2000	& year==	2016
replace pell_max=	3765	if efc>	2000	& efc<=	2100	& year==	2016
replace pell_max=	3665	if efc>	2100	& efc<=	2200	& year==	2016
replace pell_max=	3565	if efc>	2200	& efc<=	2300	& year==	2016
replace pell_max=	3465	if efc>	2300	& efc<=	2400	& year==	2016
replace pell_max=	3365	if efc>	2400	& efc<=	2500	& year==	2016
replace pell_max=	3265	if efc>	2500	& efc<=	2600	& year==	2016
replace pell_max=	3165	if efc>	2600	& efc<=	2700	& year==	2016
replace pell_max=	3065	if efc>	2700	& efc<=	2800	& year==	2016
replace pell_max=	2965	if efc>	2800	& efc<=	2900	& year==	2016
replace pell_max=	2865	if efc>	2900	& efc<=	3000	& year==	2016
replace pell_max=	2765	if efc>	3000	& efc<=	3100	& year==	2016
replace pell_max=	2665	if efc>	3100	& efc<=	3200	& year==	2016
replace pell_max=	2565	if efc>	3200	& efc<=	3300	& year==	2016
replace pell_max=	2465	if efc>	3300	& efc<=	3400	& year==	2016
replace pell_max=	2365	if efc>	3400	& efc<=	3500	& year==	2016
replace pell_max=	2265	if efc>	3500	& efc<=	3600	& year==	2016
replace pell_max=	2165	if efc>	3600	& efc<=	3700	& year==	2016
replace pell_max=	2065	if efc>	3700	& efc<=	3800	& year==	2016
replace pell_max=	1965	if efc>	3800	& efc<=	3900	& year==	2016
replace pell_max=	1865	if efc>	3900	& efc<=	4000	& year==	2016
replace pell_max=	1765	if efc>	4000	& efc<=	4100	& year==	2016
replace pell_max=	1665	if efc>	4100	& efc<=	4200	& year==	2016
replace pell_max=	1565	if efc>	4200	& efc<=	4300	& year==	2016
replace pell_max=	1465	if efc>	4300	& efc<=	4400	& year==	2016
replace pell_max=	1365	if efc>	4400	& efc<=	4500	& year==	2016
replace pell_max=	1265	if efc>	4500	& efc<=	4600	& year==	2016
replace pell_max=	1165	if efc>	4600	& efc<=	4700	& year==	2016
replace pell_max=	1065	if efc>	4700	& efc<=	4800	& year==	2016
replace pell_max=	965	if efc>	4800	& efc<=	4900	& year==	2016
replace pell_max=	865	if efc>	4900	& efc<=	5000	& year==	2016
replace pell_max=	765	if efc>	5000	& efc<=	5100	& year==	2016
replace pell_max=	665	if efc>	5100	& efc<=	5200	& year==	2016
replace pell_max=	598	if efc>	5200	& efc<=	5234	& year==	2016
replace pell_max=	0	if efc>	5234			& year==	2016
replace pell_max=	5775	if efc==0			& year==	2015
replace pell_max=	5725	if efc>	0	& efc<=	100	& year==	2015
replace pell_max=	5625	if efc>	100	& efc<=	200	& year==	2015
replace pell_max=	5525	if efc>	200	& efc<=	300	& year==	2015
replace pell_max=	5425	if efc>	300	& efc<=	400	& year==	2015
replace pell_max=	5325	if efc>	400	& efc<=	500	& year==	2015
replace pell_max=	5225	if efc>	500	& efc<=	600	& year==	2015
replace pell_max=	5125	if efc>	600	& efc<=	700	& year==	2015
replace pell_max=	5025	if efc>	700	& efc<=	800	& year==	2015
replace pell_max=	4925	if efc>	800	& efc<=	900	& year==	2015
replace pell_max=	4825	if efc>	900	& efc<=	1000	& year==	2015
replace pell_max=	4725	if efc>	1000	& efc<=	1100	& year==	2015
replace pell_max=	4625	if efc>	1100	& efc<=	1200	& year==	2015
replace pell_max=	4525	if efc>	1200	& efc<=	1300	& year==	2015
replace pell_max=	4425	if efc>	1300	& efc<=	1400	& year==	2015
replace pell_max=	4325	if efc>	1400	& efc<=	1500	& year==	2015
replace pell_max=	4225	if efc>	1500	& efc<=	1600	& year==	2015
replace pell_max=	4125	if efc>	1600	& efc<=	1700	& year==	2015
replace pell_max=	4025	if efc>	1700	& efc<=	1800	& year==	2015
replace pell_max=	3925	if efc>	1800	& efc<=	1900	& year==	2015
replace pell_max=	3825	if efc>	1900	& efc<=	2000	& year==	2015
replace pell_max=	3725	if efc>	2000	& efc<=	2100	& year==	2015
replace pell_max=	3625	if efc>	2100	& efc<=	2200	& year==	2015
replace pell_max=	3525	if efc>	2200	& efc<=	2300	& year==	2015
replace pell_max=	3425	if efc>	2300	& efc<=	2400	& year==	2015
replace pell_max=	3325	if efc>	2400	& efc<=	2500	& year==	2015
replace pell_max=	3225	if efc>	2500	& efc<=	2600	& year==	2015
replace pell_max=	3125	if efc>	2600	& efc<=	2700	& year==	2015
replace pell_max=	3025	if efc>	2700	& efc<=	2800	& year==	2015
replace pell_max=	2925	if efc>	2800	& efc<=	2900	& year==	2015
replace pell_max=	2825	if efc>	2900	& efc<=	3000	& year==	2015
replace pell_max=	2725	if efc>	3000	& efc<=	3100	& year==	2015
replace pell_max=	2625	if efc>	3100	& efc<=	3200	& year==	2015
replace pell_max=	2525	if efc>	3200	& efc<=	3300	& year==	2015
replace pell_max=	2425	if efc>	3300	& efc<=	3400	& year==	2015
replace pell_max=	2325	if efc>	3400	& efc<=	3500	& year==	2015
replace pell_max=	2225	if efc>	3500	& efc<=	3600	& year==	2015
replace pell_max=	2125	if efc>	3600	& efc<=	3700	& year==	2015
replace pell_max=	2025	if efc>	3700	& efc<=	3800	& year==	2015
replace pell_max=	1925	if efc>	3800	& efc<=	3900	& year==	2015
replace pell_max=	1825	if efc>	3900	& efc<=	4000	& year==	2015
replace pell_max=	1725	if efc>	4000	& efc<=	4100	& year==	2015
replace pell_max=	1625	if efc>	4100	& efc<=	4200	& year==	2015
replace pell_max=	1525	if efc>	4200	& efc<=	4300	& year==	2015
replace pell_max=	1425	if efc>	4300	& efc<=	4400	& year==	2015
replace pell_max=	1325	if efc>	4400	& efc<=	4500	& year==	2015
replace pell_max=	1225	if efc>	4500	& efc<=	4600	& year==	2015
replace pell_max=	1125	if efc>	4600	& efc<=	4700	& year==	2015
replace pell_max=	1025	if efc>	4700	& efc<=	4800	& year==	2015
replace pell_max=	925	if efc>	4800	& efc<=	4900	& year==	2015
replace pell_max=	825	if efc>	4900	& efc<=	5000	& year==	2015
replace pell_max=	725	if efc>	5000	& efc<=	5100	& year==	2015
replace pell_max=	626	if efc>	5100	& efc<=	5198	& year==	2015
replace pell_max=	0	if efc>	5198			& year==	2015
replace pell_max=	5730	if efc==0			& year==	2014
replace pell_max=	5680	if efc>	0	& efc<=	100	& year==	2014
replace pell_max=	5580	if efc>	100	& efc<=	200	& year==	2014
replace pell_max=	5480	if efc>	200	& efc<=	300	& year==	2014
replace pell_max=	5380	if efc>	300	& efc<=	400	& year==	2014
replace pell_max=	5280	if efc>	400	& efc<=	500	& year==	2014
replace pell_max=	5180	if efc>	500	& efc<=	600	& year==	2014
replace pell_max=	5080	if efc>	600	& efc<=	700	& year==	2014
replace pell_max=	4980	if efc>	700	& efc<=	800	& year==	2014
replace pell_max=	4880	if efc>	800	& efc<=	900	& year==	2014
replace pell_max=	4780	if efc>	900	& efc<=	1000	& year==	2014
replace pell_max=	4680	if efc>	1000	& efc<=	1100	& year==	2014
replace pell_max=	4580	if efc>	1100	& efc<=	1200	& year==	2014
replace pell_max=	4480	if efc>	1200	& efc<=	1300	& year==	2014
replace pell_max=	4380	if efc>	1300	& efc<=	1400	& year==	2014
replace pell_max=	4280	if efc>	1400	& efc<=	1500	& year==	2014
replace pell_max=	4180	if efc>	1500	& efc<=	1600	& year==	2014
replace pell_max=	4080	if efc>	1600	& efc<=	1700	& year==	2014
replace pell_max=	3980	if efc>	1700	& efc<=	1800	& year==	2014
replace pell_max=	3880	if efc>	1800	& efc<=	1900	& year==	2014
replace pell_max=	3780	if efc>	1900	& efc<=	2000	& year==	2014
replace pell_max=	3680	if efc>	2000	& efc<=	2100	& year==	2014
replace pell_max=	3580	if efc>	2100	& efc<=	2200	& year==	2014
replace pell_max=	3480	if efc>	2200	& efc<=	2300	& year==	2014
replace pell_max=	3380	if efc>	2300	& efc<=	2400	& year==	2014
replace pell_max=	3280	if efc>	2400	& efc<=	2500	& year==	2014
replace pell_max=	3180	if efc>	2500	& efc<=	2600	& year==	2014
replace pell_max=	3080	if efc>	2600	& efc<=	2700	& year==	2014
replace pell_max=	2980	if efc>	2700	& efc<=	2800	& year==	2014
replace pell_max=	2880	if efc>	2800	& efc<=	2900	& year==	2014
replace pell_max=	2780	if efc>	2900	& efc<=	3000	& year==	2014
replace pell_max=	2680	if efc>	3000	& efc<=	3100	& year==	2014
replace pell_max=	2580	if efc>	3100	& efc<=	3200	& year==	2014
replace pell_max=	2480	if efc>	3200	& efc<=	3300	& year==	2014
replace pell_max=	2380	if efc>	3300	& efc<=	3400	& year==	2014
replace pell_max=	2280	if efc>	3400	& efc<=	3500	& year==	2014
replace pell_max=	2180	if efc>	3500	& efc<=	3600	& year==	2014
replace pell_max=	2080	if efc>	3600	& efc<=	3700	& year==	2014
replace pell_max=	1980	if efc>	3700	& efc<=	3800	& year==	2014
replace pell_max=	1880	if efc>	3800	& efc<=	3900	& year==	2014
replace pell_max=	1780	if efc>	3900	& efc<=	4000	& year==	2014
replace pell_max=	1680	if efc>	4000	& efc<=	4100	& year==	2014
replace pell_max=	1580	if efc>	4100	& efc<=	4200	& year==	2014
replace pell_max=	1480	if efc>	4200	& efc<=	4300	& year==	2014
replace pell_max=	1380	if efc>	4300	& efc<=	4400	& year==	2014
replace pell_max=	1280	if efc>	4400	& efc<=	4500	& year==	2014
replace pell_max=	1180	if efc>	4500	& efc<=	4600	& year==	2014
replace pell_max=	1080	if efc>	4600	& efc<=	4700	& year==	2014
replace pell_max=	980	if efc>	4700	& efc<=	4800	& year==	2014
replace pell_max=	880	if efc>	4800	& efc<=	4900	& year==	2014
replace pell_max=	780	if efc>	4900	& efc<=	5000	& year==	2014
replace pell_max=	680	if efc>	5000	& efc<=	5100	& year==	2014
replace pell_max=	602	if efc>	5100	& efc<=	5157	& year==	2014
replace pell_max=	0	if efc>	5157			& year==	2014
replace pell_max=	5645	if efc==0			& year==	2013
replace pell_max=	5595	if efc>	0	& efc<=	100	& year==	2013
replace pell_max=	5495	if efc>	100	& efc<=	200	& year==	2013
replace pell_max=	5395	if efc>	200	& efc<=	300	& year==	2013
replace pell_max=	5295	if efc>	300	& efc<=	400	& year==	2013
replace pell_max=	5195	if efc>	400	& efc<=	500	& year==	2013
replace pell_max=	5095	if efc>	500	& efc<=	600	& year==	2013
replace pell_max=	4995	if efc>	600	& efc<=	700	& year==	2013
replace pell_max=	4895	if efc>	700	& efc<=	800	& year==	2013
replace pell_max=	4795	if efc>	800	& efc<=	900	& year==	2013
replace pell_max=	4695	if efc>	900	& efc<=	1000	& year==	2013
replace pell_max=	4595	if efc>	1000	& efc<=	1100	& year==	2013
replace pell_max=	4495	if efc>	1100	& efc<=	1200	& year==	2013
replace pell_max=	4395	if efc>	1200	& efc<=	1300	& year==	2013
replace pell_max=	4295	if efc>	1300	& efc<=	1400	& year==	2013
replace pell_max=	4195	if efc>	1400	& efc<=	1500	& year==	2013
replace pell_max=	4095	if efc>	1500	& efc<=	1600	& year==	2013
replace pell_max=	3995	if efc>	1600	& efc<=	1700	& year==	2013
replace pell_max=	3895	if efc>	1700	& efc<=	1800	& year==	2013
replace pell_max=	3795	if efc>	1800	& efc<=	1900	& year==	2013
replace pell_max=	3695	if efc>	1900	& efc<=	2000	& year==	2013
replace pell_max=	3595	if efc>	2000	& efc<=	2100	& year==	2013
replace pell_max=	3495	if efc>	2100	& efc<=	2200	& year==	2013
replace pell_max=	3395	if efc>	2200	& efc<=	2300	& year==	2013
replace pell_max=	3295	if efc>	2300	& efc<=	2400	& year==	2013
replace pell_max=	3195	if efc>	2400	& efc<=	2500	& year==	2013
replace pell_max=	3095	if efc>	2500	& efc<=	2600	& year==	2013
replace pell_max=	2995	if efc>	2600	& efc<=	2700	& year==	2013
replace pell_max=	2895	if efc>	2700	& efc<=	2800	& year==	2013
replace pell_max=	2795	if efc>	2800	& efc<=	2900	& year==	2013
replace pell_max=	2695	if efc>	2900	& efc<=	3000	& year==	2013
replace pell_max=	2595	if efc>	3000	& efc<=	3100	& year==	2013
replace pell_max=	2495	if efc>	3100	& efc<=	3200	& year==	2013
replace pell_max=	2395	if efc>	3200	& efc<=	3300	& year==	2013
replace pell_max=	2295	if efc>	3300	& efc<=	3400	& year==	2013
replace pell_max=	2195	if efc>	3400	& efc<=	3500	& year==	2013
replace pell_max=	2095	if efc>	3500	& efc<=	3600	& year==	2013
replace pell_max=	1995	if efc>	3600	& efc<=	3700	& year==	2013
replace pell_max=	1895	if efc>	3700	& efc<=	3800	& year==	2013
replace pell_max=	1795	if efc>	3800	& efc<=	3900	& year==	2013
replace pell_max=	1695	if efc>	3900	& efc<=	4000	& year==	2013
replace pell_max=	1595	if efc>	4000	& efc<=	4100	& year==	2013
replace pell_max=	1495	if efc>	4100	& efc<=	4200	& year==	2013
replace pell_max=	1395	if efc>	4200	& efc<=	4300	& year==	2013
replace pell_max=	1295	if efc>	4300	& efc<=	4400	& year==	2013
replace pell_max=	1195	if efc>	4400	& efc<=	4500	& year==	2013
replace pell_max=	1095	if efc>	4500	& efc<=	4600	& year==	2013
replace pell_max=	995	if efc>	4600	& efc<=	4700	& year==	2013
replace pell_max=	895	if efc>	4700	& efc<=	4800	& year==	2013
replace pell_max=	795	if efc>	4800	& efc<=	4900	& year==	2013
replace pell_max=	695	if efc>	4900	& efc<=	5000	& year==	2013
replace pell_max=	605	if efc>	5000	& efc<=	5081	& year==	2013
replace pell_max=	0	if efc>	5081			& year==	2013
replace pell_max=	5550	if efc==0			& year==	2012
replace pell_max=	5500	if efc>	0	& efc<=	100	& year==	2012
replace pell_max=	5400	if efc>	100	& efc<=	200	& year==	2012
replace pell_max=	5300	if efc>	200	& efc<=	300	& year==	2012
replace pell_max=	5200	if efc>	300	& efc<=	400	& year==	2012
replace pell_max=	5100	if efc>	400	& efc<=	500	& year==	2012
replace pell_max=	5000	if efc>	500	& efc<=	600	& year==	2012
replace pell_max=	4900	if efc>	600	& efc<=	700	& year==	2012
replace pell_max=	4800	if efc>	700	& efc<=	800	& year==	2012
replace pell_max=	4700	if efc>	800	& efc<=	900	& year==	2012
replace pell_max=	4600	if efc>	900	& efc<=	1000	& year==	2012
replace pell_max=	4500	if efc>	1000	& efc<=	1100	& year==	2012
replace pell_max=	4400	if efc>	1100	& efc<=	1200	& year==	2012
replace pell_max=	4300	if efc>	1200	& efc<=	1300	& year==	2012
replace pell_max=	4200	if efc>	1300	& efc<=	1400	& year==	2012
replace pell_max=	4100	if efc>	1400	& efc<=	1500	& year==	2012
replace pell_max=	4000	if efc>	1500	& efc<=	1600	& year==	2012
replace pell_max=	3900	if efc>	1600	& efc<=	1700	& year==	2012
replace pell_max=	3800	if efc>	1700	& efc<=	1800	& year==	2012
replace pell_max=	3700	if efc>	1800	& efc<=	1900	& year==	2012
replace pell_max=	3600	if efc>	1900	& efc<=	2000	& year==	2012
replace pell_max=	3500	if efc>	2000	& efc<=	2100	& year==	2012
replace pell_max=	3400	if efc>	2100	& efc<=	2200	& year==	2012
replace pell_max=	3300	if efc>	2200	& efc<=	2300	& year==	2012
replace pell_max=	3200	if efc>	2300	& efc<=	2400	& year==	2012
replace pell_max=	3100	if efc>	2400	& efc<=	2500	& year==	2012
replace pell_max=	3000	if efc>	2500	& efc<=	2600	& year==	2012
replace pell_max=	2900	if efc>	2600	& efc<=	2700	& year==	2012
replace pell_max=	2800	if efc>	2700	& efc<=	2800	& year==	2012
replace pell_max=	2700	if efc>	2800	& efc<=	2900	& year==	2012
replace pell_max=	2600	if efc>	2900	& efc<=	3000	& year==	2012
replace pell_max=	2500	if efc>	3000	& efc<=	3100	& year==	2012
replace pell_max=	2400	if efc>	3100	& efc<=	3200	& year==	2012
replace pell_max=	2300	if efc>	3200	& efc<=	3300	& year==	2012
replace pell_max=	2200	if efc>	3300	& efc<=	3400	& year==	2012
replace pell_max=	2100	if efc>	3400	& efc<=	3500	& year==	2012
replace pell_max=	2000	if efc>	3500	& efc<=	3600	& year==	2012
replace pell_max=	1900	if efc>	3600	& efc<=	3700	& year==	2012
replace pell_max=	1800	if efc>	3700	& efc<=	3800	& year==	2012
replace pell_max=	1700	if efc>	3800	& efc<=	3900	& year==	2012
replace pell_max=	1600	if efc>	3900	& efc<=	4000	& year==	2012
replace pell_max=	1500	if efc>	4000	& efc<=	4100	& year==	2012
replace pell_max=	1400	if efc>	4100	& efc<=	4200	& year==	2012
replace pell_max=	1300	if efc>	4200	& efc<=	4300	& year==	2012
replace pell_max=	1200	if efc>	4300	& efc<=	4400	& year==	2012
replace pell_max=	1100	if efc>	4400	& efc<=	4500	& year==	2012
replace pell_max=	1000	if efc>	4500	& efc<=	4600	& year==	2012
replace pell_max=	900	if efc>	4600	& efc<=	4700	& year==	2012
replace pell_max=	800	if efc>	4700	& efc<=	4800	& year==	2012
replace pell_max=	700	if efc>	4800	& efc<=	4900	& year==	2012
replace pell_max=	602	if efc>	4900	& efc<=	4995	& year==	2012
replace pell_max=	0	if efc>	4995			& year==	2012
replace pell_max=	5550	if efc==0			& year==	2011
replace pell_max=	5500	if efc>	0	& efc<=	100	& year==	2011
replace pell_max=	5400	if efc>	100	& efc<=	200	& year==	2011
replace pell_max=	5300	if efc>	200	& efc<=	300	& year==	2011
replace pell_max=	5200	if efc>	300	& efc<=	400	& year==	2011
replace pell_max=	5100	if efc>	400	& efc<=	500	& year==	2011
replace pell_max=	5000	if efc>	500	& efc<=	600	& year==	2011
replace pell_max=	4900	if efc>	600	& efc<=	700	& year==	2011
replace pell_max=	4800	if efc>	700	& efc<=	800	& year==	2011
replace pell_max=	4700	if efc>	800	& efc<=	900	& year==	2011
replace pell_max=	4600	if efc>	900	& efc<=	1000	& year==	2011
replace pell_max=	4500	if efc>	1000	& efc<=	1100	& year==	2011
replace pell_max=	4400	if efc>	1100	& efc<=	1200	& year==	2011
replace pell_max=	4300	if efc>	1200	& efc<=	1300	& year==	2011
replace pell_max=	4200	if efc>	1300	& efc<=	1400	& year==	2011
replace pell_max=	4100	if efc>	1400	& efc<=	1500	& year==	2011
replace pell_max=	4000	if efc>	1500	& efc<=	1600	& year==	2011
replace pell_max=	3900	if efc>	1600	& efc<=	1700	& year==	2011
replace pell_max=	3800	if efc>	1700	& efc<=	1800	& year==	2011
replace pell_max=	3700	if efc>	1800	& efc<=	1900	& year==	2011
replace pell_max=	3600	if efc>	1900	& efc<=	2000	& year==	2011
replace pell_max=	3500	if efc>	2000	& efc<=	2100	& year==	2011
replace pell_max=	3400	if efc>	2100	& efc<=	2200	& year==	2011
replace pell_max=	3300	if efc>	2200	& efc<=	2300	& year==	2011
replace pell_max=	3200	if efc>	2300	& efc<=	2400	& year==	2011
replace pell_max=	3100	if efc>	2400	& efc<=	2500	& year==	2011
replace pell_max=	3000	if efc>	2500	& efc<=	2600	& year==	2011
replace pell_max=	2900	if efc>	2600	& efc<=	2700	& year==	2011
replace pell_max=	2800	if efc>	2700	& efc<=	2800	& year==	2011
replace pell_max=	2700	if efc>	2800	& efc<=	2900	& year==	2011
replace pell_max=	2600	if efc>	2900	& efc<=	3000	& year==	2011
replace pell_max=	2500	if efc>	3000	& efc<=	3100	& year==	2011
replace pell_max=	2400	if efc>	3100	& efc<=	3200	& year==	2011
replace pell_max=	2300	if efc>	3200	& efc<=	3300	& year==	2011
replace pell_max=	2200	if efc>	3300	& efc<=	3400	& year==	2011
replace pell_max=	2100	if efc>	3400	& efc<=	3500	& year==	2011
replace pell_max=	2000	if efc>	3500	& efc<=	3600	& year==	2011
replace pell_max=	1900	if efc>	3600	& efc<=	3700	& year==	2011
replace pell_max=	1800	if efc>	3700	& efc<=	3800	& year==	2011
replace pell_max=	1700	if efc>	3800	& efc<=	3900	& year==	2011
replace pell_max=	1600	if efc>	3900	& efc<=	4000	& year==	2011
replace pell_max=	1500	if efc>	4000	& efc<=	4100	& year==	2011
replace pell_max=	1400	if efc>	4100	& efc<=	4200	& year==	2011
replace pell_max=	1300	if efc>	4200	& efc<=	4300	& year==	2011
replace pell_max=	1200	if efc>	4300	& efc<=	4400	& year==	2011
replace pell_max=	1100	if efc>	4400	& efc<=	4500	& year==	2011
replace pell_max=	1000	if efc>	4500	& efc<=	4600	& year==	2011
replace pell_max=	900	if efc>	4600	& efc<=	4700	& year==	2011
replace pell_max=	800	if efc>	4700	& efc<=	4800	& year==	2011
replace pell_max=	700	if efc>	4800	& efc<=	4900	& year==	2011
replace pell_max=	600	if efc>	4900	& efc<=	5000	& year==	2011
replace pell_max=	555	if efc>	5000	& efc<=	5100	& year==	2011
replace pell_max=	555	if efc>	5100	& efc<=	5200	& year==	2011
replace pell_max=	555	if efc>	5200	& efc<=	5273	& year==	2011
replace pell_max=	0	if efc>	5273			& year==	2011

compress
save "$clean/Year_Cleanedb.dta", replace


/*
clear all
set more off
use "$clean/Year_Cleanedb.dta" 
*/


replace pell_max=	5550	if efc==0			& year==	2010
replace pell_max=	5500	if efc>	0	& efc<=	100	& year==	2010
replace pell_max=	5400	if efc>	100	& efc<=	200	& year==	2010
replace pell_max=	5300	if efc>	200	& efc<=	300	& year==	2010
replace pell_max=	5200	if efc>	300	& efc<=	400	& year==	2010
replace pell_max=	5100	if efc>	400	& efc<=	500	& year==	2010
replace pell_max=	5000	if efc>	500	& efc<=	600	& year==	2010
replace pell_max=	4900	if efc>	600	& efc<=	700	& year==	2010
replace pell_max=	4800	if efc>	700	& efc<=	800	& year==	2010
replace pell_max=	4700	if efc>	800	& efc<=	900	& year==	2010
replace pell_max=	4600	if efc>	900	& efc<=	1000	& year==	2010
replace pell_max=	4500	if efc>	1000	& efc<=	1100	& year==	2010
replace pell_max=	4400	if efc>	1100	& efc<=	1200	& year==	2010
replace pell_max=	4300	if efc>	1200	& efc<=	1300	& year==	2010
replace pell_max=	4200	if efc>	1300	& efc<=	1400	& year==	2010
replace pell_max=	4100	if efc>	1400	& efc<=	1500	& year==	2010
replace pell_max=	4000	if efc>	1500	& efc<=	1600	& year==	2010
replace pell_max=	3900	if efc>	1600	& efc<=	1700	& year==	2010
replace pell_max=	3800	if efc>	1700	& efc<=	1800	& year==	2010
replace pell_max=	3700	if efc>	1800	& efc<=	1900	& year==	2010
replace pell_max=	3600	if efc>	1900	& efc<=	2000	& year==	2010
replace pell_max=	3500	if efc>	2000	& efc<=	2100	& year==	2010
replace pell_max=	3400	if efc>	2100	& efc<=	2200	& year==	2010
replace pell_max=	3300	if efc>	2200	& efc<=	2300	& year==	2010
replace pell_max=	3200	if efc>	2300	& efc<=	2400	& year==	2010
replace pell_max=	3100	if efc>	2400	& efc<=	2500	& year==	2010
replace pell_max=	3000	if efc>	2500	& efc<=	2600	& year==	2010
replace pell_max=	2900	if efc>	2600	& efc<=	2700	& year==	2010
replace pell_max=	2800	if efc>	2700	& efc<=	2800	& year==	2010
replace pell_max=	2700	if efc>	2800	& efc<=	2900	& year==	2010
replace pell_max=	2600	if efc>	2900	& efc<=	3000	& year==	2010
replace pell_max=	2500	if efc>	3000	& efc<=	3100	& year==	2010
replace pell_max=	2400	if efc>	3100	& efc<=	3200	& year==	2010
replace pell_max=	2300	if efc>	3200	& efc<=	3300	& year==	2010
replace pell_max=	2200	if efc>	3300	& efc<=	3400	& year==	2010
replace pell_max=	2100	if efc>	3400	& efc<=	3500	& year==	2010
replace pell_max=	2000	if efc>	3500	& efc<=	3600	& year==	2010
replace pell_max=	1900	if efc>	3600	& efc<=	3700	& year==	2010
replace pell_max=	1800	if efc>	3700	& efc<=	3800	& year==	2010
replace pell_max=	1700	if efc>	3800	& efc<=	3900	& year==	2010
replace pell_max=	1600	if efc>	3900	& efc<=	4000	& year==	2010
replace pell_max=	1500	if efc>	4000	& efc<=	4100	& year==	2010
replace pell_max=	1400	if efc>	4100	& efc<=	4200	& year==	2010
replace pell_max=	1300	if efc>	4200	& efc<=	4300	& year==	2010
replace pell_max=	1200	if efc>	4300	& efc<=	4400	& year==	2010
replace pell_max=	1176	if efc>	4400	& efc<=	4500	& year==	2010
replace pell_max=	1176	if efc>	4500	& efc<=	4600	& year==	2010
replace pell_max=	1176	if efc>	4600	& efc<=	4617	& year==	2010
replace pell_max=	0	if efc>	4617			& year==	2010
replace pell_max=	5350	if efc==0			& year==	2009
replace pell_max=	5300	if efc>	0	& efc<=	100	& year==	2009
replace pell_max=	5200	if efc>	100	& efc<=	200	& year==	2009
replace pell_max=	5100	if efc>	200	& efc<=	300	& year==	2009
replace pell_max=	5000	if efc>	300	& efc<=	400	& year==	2009
replace pell_max=	4900	if efc>	400	& efc<=	500	& year==	2009
replace pell_max=	4800	if efc>	500	& efc<=	600	& year==	2009
replace pell_max=	4700	if efc>	600	& efc<=	700	& year==	2009
replace pell_max=	4600	if efc>	700	& efc<=	800	& year==	2009
replace pell_max=	4500	if efc>	800	& efc<=	900	& year==	2009
replace pell_max=	4400	if efc>	900	& efc<=	1000	& year==	2009
replace pell_max=	4300	if efc>	1000	& efc<=	1100	& year==	2009
replace pell_max=	4200	if efc>	1100	& efc<=	1200	& year==	2009
replace pell_max=	4100	if efc>	1200	& efc<=	1300	& year==	2009
replace pell_max=	4000	if efc>	1300	& efc<=	1400	& year==	2009
replace pell_max=	3900	if efc>	1400	& efc<=	1500	& year==	2009
replace pell_max=	3800	if efc>	1500	& efc<=	1600	& year==	2009
replace pell_max=	3700	if efc>	1600	& efc<=	1700	& year==	2009
replace pell_max=	3600	if efc>	1700	& efc<=	1800	& year==	2009
replace pell_max=	3500	if efc>	1800	& efc<=	1900	& year==	2009
replace pell_max=	3400	if efc>	1900	& efc<=	2000	& year==	2009
replace pell_max=	3300	if efc>	2000	& efc<=	2100	& year==	2009
replace pell_max=	3200	if efc>	2100	& efc<=	2200	& year==	2009
replace pell_max=	3100	if efc>	2200	& efc<=	2300	& year==	2009
replace pell_max=	3000	if efc>	2300	& efc<=	2400	& year==	2009
replace pell_max=	2900	if efc>	2400	& efc<=	2500	& year==	2009
replace pell_max=	2800	if efc>	2500	& efc<=	2600	& year==	2009
replace pell_max=	2700	if efc>	2600	& efc<=	2700	& year==	2009
replace pell_max=	2600	if efc>	2700	& efc<=	2800	& year==	2009
replace pell_max=	2500	if efc>	2800	& efc<=	2900	& year==	2009
replace pell_max=	2400	if efc>	2900	& efc<=	3000	& year==	2009
replace pell_max=	2300	if efc>	3000	& efc<=	3100	& year==	2009
replace pell_max=	2200	if efc>	3100	& efc<=	3200	& year==	2009
replace pell_max=	2100	if efc>	3200	& efc<=	3300	& year==	2009
replace pell_max=	2000	if efc>	3300	& efc<=	3400	& year==	2009
replace pell_max=	1900	if efc>	3400	& efc<=	3500	& year==	2009
replace pell_max=	1800	if efc>	3500	& efc<=	3600	& year==	2009
replace pell_max=	1700	if efc>	3600	& efc<=	3700	& year==	2009
replace pell_max=	1600	if efc>	3700	& efc<=	3800	& year==	2009
replace pell_max=	1500	if efc>	3800	& efc<=	3900	& year==	2009
replace pell_max=	1400	if efc>	3900	& efc<=	4000	& year==	2009
replace pell_max=	1300	if efc>	4000	& efc<=	4100	& year==	2009
replace pell_max=	1200	if efc>	4100	& efc<=	4200	& year==	2009
replace pell_max=	1100	if efc>	4200	& efc<=	4300	& year==	2009
replace pell_max=	1000	if efc>	4300	& efc<=	4400	& year==	2009
replace pell_max=	976	if efc>	4400	& efc<=	4500	& year==	2009
replace pell_max=	976	if efc>	4500	& efc<=	4600	& year==	2009
replace pell_max=	976	if efc>	4600	& efc<=	4617	& year==	2009
replace pell_max=	0	if efc>	4617			& year==	2009
replace pell_max=	4731	if efc==0			& year==	2008
replace pell_max=	4681	if efc>	0	& efc<=	100	& year==	2008
replace pell_max=	4581	if efc>	100	& efc<=	200	& year==	2008
replace pell_max=	4481	if efc>	200	& efc<=	300	& year==	2008
replace pell_max=	4381	if efc>	300	& efc<=	400	& year==	2008
replace pell_max=	4281	if efc>	400	& efc<=	500	& year==	2008
replace pell_max=	4181	if efc>	500	& efc<=	600	& year==	2008
replace pell_max=	4081	if efc>	600	& efc<=	700	& year==	2008
replace pell_max=	3981	if efc>	700	& efc<=	800	& year==	2008
replace pell_max=	3881	if efc>	800	& efc<=	900	& year==	2008
replace pell_max=	3781	if efc>	900	& efc<=	1000	& year==	2008
replace pell_max=	3681	if efc>	1000	& efc<=	1100	& year==	2008
replace pell_max=	3581	if efc>	1100	& efc<=	1200	& year==	2008
replace pell_max=	3481	if efc>	1200	& efc<=	1300	& year==	2008
replace pell_max=	3381	if efc>	1300	& efc<=	1400	& year==	2008
replace pell_max=	3281	if efc>	1400	& efc<=	1500	& year==	2008
replace pell_max=	3181	if efc>	1500	& efc<=	1600	& year==	2008
replace pell_max=	3081	if efc>	1600	& efc<=	1700	& year==	2008
replace pell_max=	2981	if efc>	1700	& efc<=	1800	& year==	2008
replace pell_max=	2881	if efc>	1800	& efc<=	1900	& year==	2008
replace pell_max=	2781	if efc>	1900	& efc<=	2000	& year==	2008
replace pell_max=	2681	if efc>	2000	& efc<=	2100	& year==	2008
replace pell_max=	2581	if efc>	2100	& efc<=	2200	& year==	2008
replace pell_max=	2481	if efc>	2200	& efc<=	2300	& year==	2008
replace pell_max=	2381	if efc>	2300	& efc<=	2400	& year==	2008
replace pell_max=	2281	if efc>	2400	& efc<=	2500	& year==	2008
replace pell_max=	2181	if efc>	2500	& efc<=	2600	& year==	2008
replace pell_max=	2081	if efc>	2600	& efc<=	2700	& year==	2008
replace pell_max=	1981	if efc>	2700	& efc<=	2800	& year==	2008
replace pell_max=	1881	if efc>	2800	& efc<=	2900	& year==	2008
replace pell_max=	1781	if efc>	2900	& efc<=	3000	& year==	2008
replace pell_max=	1681	if efc>	3000	& efc<=	3100	& year==	2008
replace pell_max=	1581	if efc>	3100	& efc<=	3200	& year==	2008
replace pell_max=	1481	if efc>	3200	& efc<=	3300	& year==	2008
replace pell_max=	1381	if efc>	3300	& efc<=	3400	& year==	2008
replace pell_max=	1281	if efc>	3400	& efc<=	3500	& year==	2008
replace pell_max=	1181	if efc>	3500	& efc<=	3600	& year==	2008
replace pell_max=	1081	if efc>	3600	& efc<=	3700	& year==	2008
replace pell_max=	981	if efc>	3700	& efc<=	3800	& year==	2008
replace pell_max=	890	if efc>	3800	& efc<=	3900	& year==	2008
replace pell_max=	890	if efc>	3900	& efc<=	4000	& year==	2008
replace pell_max=	890	if efc>	4000	& efc<=	4041	& year==	2008
replace pell_max=	0	if efc>	4041			& year==	2008
replace pell_max=	4310	if efc==0			& year==	2007
replace pell_max=	4260	if efc>	0	& efc<=	100	& year==	2007
replace pell_max=	4160	if efc>	100	& efc<=	200	& year==	2007
replace pell_max=	4060	if efc>	200	& efc<=	300	& year==	2007
replace pell_max=	3960	if efc>	300	& efc<=	400	& year==	2007
replace pell_max=	3860	if efc>	400	& efc<=	500	& year==	2007
replace pell_max=	3760	if efc>	500	& efc<=	600	& year==	2007
replace pell_max=	3660	if efc>	600	& efc<=	700	& year==	2007
replace pell_max=	3560	if efc>	700	& efc<=	800	& year==	2007
replace pell_max=	3460	if efc>	800	& efc<=	900	& year==	2007
replace pell_max=	3360	if efc>	900	& efc<=	1000	& year==	2007
replace pell_max=	3260	if efc>	1000	& efc<=	1100	& year==	2007
replace pell_max=	3160	if efc>	1100	& efc<=	1200	& year==	2007
replace pell_max=	3060	if efc>	1200	& efc<=	1300	& year==	2007
replace pell_max=	2960	if efc>	1300	& efc<=	1400	& year==	2007
replace pell_max=	2860	if efc>	1400	& efc<=	1500	& year==	2007
replace pell_max=	2760	if efc>	1500	& efc<=	1600	& year==	2007
replace pell_max=	2660	if efc>	1600	& efc<=	1700	& year==	2007
replace pell_max=	2560	if efc>	1700	& efc<=	1800	& year==	2007
replace pell_max=	2460	if efc>	1800	& efc<=	1900	& year==	2007
replace pell_max=	2360	if efc>	1900	& efc<=	2000	& year==	2007
replace pell_max=	2260	if efc>	2000	& efc<=	2100	& year==	2007
replace pell_max=	2160	if efc>	2100	& efc<=	2200	& year==	2007
replace pell_max=	2060	if efc>	2200	& efc<=	2300	& year==	2007
replace pell_max=	1960	if efc>	2300	& efc<=	2400	& year==	2007
replace pell_max=	1860	if efc>	2400	& efc<=	2500	& year==	2007
replace pell_max=	1760	if efc>	2500	& efc<=	2600	& year==	2007
replace pell_max=	1660	if efc>	2600	& efc<=	2700	& year==	2007
replace pell_max=	1560	if efc>	2700	& efc<=	2800	& year==	2007
replace pell_max=	1460	if efc>	2800	& efc<=	2900	& year==	2007
replace pell_max=	1360	if efc>	2900	& efc<=	3000	& year==	2007
replace pell_max=	1260	if efc>	3000	& efc<=	3100	& year==	2007
replace pell_max=	1160	if efc>	3100	& efc<=	3200	& year==	2007
replace pell_max=	1060	if efc>	3200	& efc<=	3300	& year==	2007
replace pell_max=	960	if efc>	3300	& efc<=	3400	& year==	2007
replace pell_max=	860	if efc>	3400	& efc<=	3500	& year==	2007
replace pell_max=	760	if efc>	3500	& efc<=	3600	& year==	2007
replace pell_max=	660	if efc>	3600	& efc<=	3700	& year==	2007
replace pell_max=	560	if efc>	3700	& efc<=	3800	& year==	2007
replace pell_max=	460	if efc>	3800	& efc<=	3900	& year==	2007
replace pell_max=	400	if efc>	3900	& efc<=	4000	& year==	2007
replace pell_max=	400	if efc>	4000	& efc<=	4110	& year==	2007
replace pell_max=	0	if efc>	4110			& year==	2007
replace pell_max=	4050	if efc==0			& year==	2006
replace pell_max=	4000	if efc>	0	& efc<=	100	& year==	2006
replace pell_max=	3900	if efc>	100	& efc<=	200	& year==	2006
replace pell_max=	3800	if efc>	200	& efc<=	300	& year==	2006
replace pell_max=	3700	if efc>	300	& efc<=	400	& year==	2006
replace pell_max=	3600	if efc>	400	& efc<=	500	& year==	2006
replace pell_max=	3500	if efc>	500	& efc<=	600	& year==	2006
replace pell_max=	3400	if efc>	600	& efc<=	700	& year==	2006
replace pell_max=	3300	if efc>	700	& efc<=	800	& year==	2006
replace pell_max=	3200	if efc>	800	& efc<=	900	& year==	2006
replace pell_max=	3100	if efc>	900	& efc<=	1000	& year==	2006
replace pell_max=	3000	if efc>	1000	& efc<=	1100	& year==	2006
replace pell_max=	2900	if efc>	1100	& efc<=	1200	& year==	2006
replace pell_max=	2800	if efc>	1200	& efc<=	1300	& year==	2006
replace pell_max=	2700	if efc>	1300	& efc<=	1400	& year==	2006
replace pell_max=	2600	if efc>	1400	& efc<=	1500	& year==	2006
replace pell_max=	2500	if efc>	1500	& efc<=	1600	& year==	2006
replace pell_max=	2400	if efc>	1600	& efc<=	1700	& year==	2006
replace pell_max=	2300	if efc>	1700	& efc<=	1800	& year==	2006
replace pell_max=	2200	if efc>	1800	& efc<=	1900	& year==	2006
replace pell_max=	2100	if efc>	1900	& efc<=	2000	& year==	2006
replace pell_max=	2000	if efc>	2000	& efc<=	2100	& year==	2006
replace pell_max=	1900	if efc>	2100	& efc<=	2200	& year==	2006
replace pell_max=	1800	if efc>	2200	& efc<=	2300	& year==	2006
replace pell_max=	1700	if efc>	2300	& efc<=	2400	& year==	2006
replace pell_max=	1600	if efc>	2400	& efc<=	2500	& year==	2006
replace pell_max=	1500	if efc>	2500	& efc<=	2600	& year==	2006
replace pell_max=	1400	if efc>	2600	& efc<=	2700	& year==	2006
replace pell_max=	1300	if efc>	2700	& efc<=	2800	& year==	2006
replace pell_max=	1200	if efc>	2800	& efc<=	2900	& year==	2006
replace pell_max=	1100	if efc>	2900	& efc<=	3000	& year==	2006
replace pell_max=	1000	if efc>	3000	& efc<=	3100	& year==	2006
replace pell_max=	900	if efc>	3100	& efc<=	3200	& year==	2006
replace pell_max=	800	if efc>	3200	& efc<=	3300	& year==	2006
replace pell_max=	700	if efc>	3300	& efc<=	3400	& year==	2006
replace pell_max=	600	if efc>	3400	& efc<=	3500	& year==	2006
replace pell_max=	500	if efc>	3500	& efc<=	3600	& year==	2006
replace pell_max=	400	if efc>	3600	& efc<=	3700	& year==	2006
replace pell_max=	400	if efc>	3700	& efc<=	3800	& year==	2006
replace pell_max=	400	if efc>	3800	& efc<=	3850	& year==	2006
replace pell_max=	0	if efc>	3850			& year==	2006
replace pell_max=	4050	if efc==0			& year==	2005
replace pell_max=	4000	if efc>	0	& efc<=	100	& year==	2005
replace pell_max=	3900	if efc>	100	& efc<=	200	& year==	2005
replace pell_max=	3800	if efc>	200	& efc<=	300	& year==	2005
replace pell_max=	3700	if efc>	300	& efc<=	400	& year==	2005
replace pell_max=	3600	if efc>	400	& efc<=	500	& year==	2005
replace pell_max=	3500	if efc>	500	& efc<=	600	& year==	2005
replace pell_max=	3400	if efc>	600	& efc<=	700	& year==	2005
replace pell_max=	3300	if efc>	700	& efc<=	800	& year==	2005
replace pell_max=	3200	if efc>	800	& efc<=	900	& year==	2005
replace pell_max=	3100	if efc>	900	& efc<=	1000	& year==	2005
replace pell_max=	3000	if efc>	1000	& efc<=	1100	& year==	2005
replace pell_max=	2900	if efc>	1100	& efc<=	1200	& year==	2005
replace pell_max=	2800	if efc>	1200	& efc<=	1300	& year==	2005
replace pell_max=	2700	if efc>	1300	& efc<=	1400	& year==	2005
replace pell_max=	2600	if efc>	1400	& efc<=	1500	& year==	2005
replace pell_max=	2500	if efc>	1500	& efc<=	1600	& year==	2005
replace pell_max=	2400	if efc>	1600	& efc<=	1700	& year==	2005
replace pell_max=	2300	if efc>	1700	& efc<=	1800	& year==	2005
replace pell_max=	2200	if efc>	1800	& efc<=	1900	& year==	2005
replace pell_max=	2100	if efc>	1900	& efc<=	2000	& year==	2005
replace pell_max=	2000	if efc>	2000	& efc<=	2100	& year==	2005
replace pell_max=	1900	if efc>	2100	& efc<=	2200	& year==	2005
replace pell_max=	1800	if efc>	2200	& efc<=	2300	& year==	2005
replace pell_max=	1700	if efc>	2300	& efc<=	2400	& year==	2005
replace pell_max=	1600	if efc>	2400	& efc<=	2500	& year==	2005
replace pell_max=	1500	if efc>	2500	& efc<=	2600	& year==	2005
replace pell_max=	1400	if efc>	2600	& efc<=	2700	& year==	2005
replace pell_max=	1300	if efc>	2700	& efc<=	2800	& year==	2005
replace pell_max=	1200	if efc>	2800	& efc<=	2900	& year==	2005
replace pell_max=	1100	if efc>	2900	& efc<=	3000	& year==	2005
replace pell_max=	1000	if efc>	3000	& efc<=	3100	& year==	2005
replace pell_max=	900	if efc>	3100	& efc<=	3200	& year==	2005
replace pell_max=	800	if efc>	3200	& efc<=	3300	& year==	2005
replace pell_max=	700	if efc>	3300	& efc<=	3400	& year==	2005
replace pell_max=	600	if efc>	3400	& efc<=	3500	& year==	2005
replace pell_max=	500	if efc>	3500	& efc<=	3600	& year==	2005
replace pell_max=	400	if efc>	3600	& efc<=	3700	& year==	2005
replace pell_max=	400	if efc>	3700	& efc<=	3800	& year==	2005
replace pell_max=	400	if efc>	3800	& efc<=	3850	& year==	2005
replace pell_max=	0	if efc>	3850			& year==	2005
replace pell_max=	4050	if efc==0			& year==	2004
replace pell_max=	4000	if efc>	0	& efc<=	100	& year==	2004
replace pell_max=	3900	if efc>	100	& efc<=	200	& year==	2004
replace pell_max=	3800	if efc>	200	& efc<=	300	& year==	2004
replace pell_max=	3700	if efc>	300	& efc<=	400	& year==	2004
replace pell_max=	3600	if efc>	400	& efc<=	500	& year==	2004
replace pell_max=	3500	if efc>	500	& efc<=	600	& year==	2004
replace pell_max=	3400	if efc>	600	& efc<=	700	& year==	2004
replace pell_max=	3300	if efc>	700	& efc<=	800	& year==	2004
replace pell_max=	3200	if efc>	800	& efc<=	900	& year==	2004
replace pell_max=	3100	if efc>	900	& efc<=	1000	& year==	2004
replace pell_max=	3000	if efc>	1000	& efc<=	1100	& year==	2004
replace pell_max=	2900	if efc>	1100	& efc<=	1200	& year==	2004
replace pell_max=	2800	if efc>	1200	& efc<=	1300	& year==	2004
replace pell_max=	2700	if efc>	1300	& efc<=	1400	& year==	2004
replace pell_max=	2600	if efc>	1400	& efc<=	1500	& year==	2004
replace pell_max=	2500	if efc>	1500	& efc<=	1600	& year==	2004
replace pell_max=	2400	if efc>	1600	& efc<=	1700	& year==	2004
replace pell_max=	2300	if efc>	1700	& efc<=	1800	& year==	2004
replace pell_max=	2200	if efc>	1800	& efc<=	1900	& year==	2004
replace pell_max=	2100	if efc>	1900	& efc<=	2000	& year==	2004
replace pell_max=	2000	if efc>	2000	& efc<=	2100	& year==	2004
replace pell_max=	1900	if efc>	2100	& efc<=	2200	& year==	2004
replace pell_max=	1800	if efc>	2200	& efc<=	2300	& year==	2004
replace pell_max=	1700	if efc>	2300	& efc<=	2400	& year==	2004
replace pell_max=	1600	if efc>	2400	& efc<=	2500	& year==	2004
replace pell_max=	1500	if efc>	2500	& efc<=	2600	& year==	2004
replace pell_max=	1400	if efc>	2600	& efc<=	2700	& year==	2004
replace pell_max=	1300	if efc>	2700	& efc<=	2800	& year==	2004
replace pell_max=	1200	if efc>	2800	& efc<=	2900	& year==	2004
replace pell_max=	1100	if efc>	2900	& efc<=	3000	& year==	2004
replace pell_max=	1000	if efc>	3000	& efc<=	3100	& year==	2004
replace pell_max=	900	if efc>	3100	& efc<=	3200	& year==	2004
replace pell_max=	800	if efc>	3200	& efc<=	3300	& year==	2004
replace pell_max=	700	if efc>	3300	& efc<=	3400	& year==	2004
replace pell_max=	600	if efc>	3400	& efc<=	3500	& year==	2004
replace pell_max=	500	if efc>	3500	& efc<=	3600	& year==	2004
replace pell_max=	400	if efc>	3600	& efc<=	3700	& year==	2004
replace pell_max=	400	if efc>	3700	& efc<=	3800	& year==	2004
replace pell_max=	400	if efc>	3800	& efc<=	3850	& year==	2004
replace pell_max=	0	if efc>	3850			& year==	2004
replace pell_max=	4050	if efc==0			& year==	2003
replace pell_max=	4000	if efc>	0	& efc<=	100	& year==	2003
replace pell_max=	3900	if efc>	100	& efc<=	200	& year==	2003
replace pell_max=	3800	if efc>	200	& efc<=	300	& year==	2003
replace pell_max=	3700	if efc>	300	& efc<=	400	& year==	2003
replace pell_max=	3600	if efc>	400	& efc<=	500	& year==	2003
replace pell_max=	3500	if efc>	500	& efc<=	600	& year==	2003
replace pell_max=	3400	if efc>	600	& efc<=	700	& year==	2003
replace pell_max=	3300	if efc>	700	& efc<=	800	& year==	2003
replace pell_max=	3200	if efc>	800	& efc<=	900	& year==	2003
replace pell_max=	3100	if efc>	900	& efc<=	1000	& year==	2003
replace pell_max=	3000	if efc>	1000	& efc<=	1100	& year==	2003
replace pell_max=	2900	if efc>	1100	& efc<=	1200	& year==	2003
replace pell_max=	2800	if efc>	1200	& efc<=	1300	& year==	2003
replace pell_max=	2700	if efc>	1300	& efc<=	1400	& year==	2003
replace pell_max=	2600	if efc>	1400	& efc<=	1500	& year==	2003
replace pell_max=	2500	if efc>	1500	& efc<=	1600	& year==	2003
replace pell_max=	2400	if efc>	1600	& efc<=	1700	& year==	2003
replace pell_max=	2300	if efc>	1700	& efc<=	1800	& year==	2003
replace pell_max=	2200	if efc>	1800	& efc<=	1900	& year==	2003
replace pell_max=	2100	if efc>	1900	& efc<=	2000	& year==	2003
replace pell_max=	2000	if efc>	2000	& efc<=	2100	& year==	2003
replace pell_max=	1900	if efc>	2100	& efc<=	2200	& year==	2003
replace pell_max=	1800	if efc>	2200	& efc<=	2300	& year==	2003
replace pell_max=	1700	if efc>	2300	& efc<=	2400	& year==	2003
replace pell_max=	1600	if efc>	2400	& efc<=	2500	& year==	2003
replace pell_max=	1500	if efc>	2500	& efc<=	2600	& year==	2003
replace pell_max=	1400	if efc>	2600	& efc<=	2700	& year==	2003
replace pell_max=	1300	if efc>	2700	& efc<=	2800	& year==	2003
replace pell_max=	1200	if efc>	2800	& efc<=	2900	& year==	2003
replace pell_max=	1100	if efc>	2900	& efc<=	3000	& year==	2003
replace pell_max=	1000	if efc>	3000	& efc<=	3100	& year==	2003
replace pell_max=	900	if efc>	3100	& efc<=	3200	& year==	2003
replace pell_max=	800	if efc>	3200	& efc<=	3300	& year==	2003
replace pell_max=	700	if efc>	3300	& efc<=	3400	& year==	2003
replace pell_max=	600	if efc>	3400	& efc<=	3500	& year==	2003
replace pell_max=	500	if efc>	3500	& efc<=	3600	& year==	2003
replace pell_max=	400	if efc>	3600	& efc<=	3700	& year==	2003
replace pell_max=	400	if efc>	3700	& efc<=	3800	& year==	2003
replace pell_max=	400	if efc>	3800	& efc<=	3850	& year==	2003
replace pell_max=	0	if efc>	3850			& year==	2003

compress
save "$clean/Year_Cleanedc.dta", replace

replace pell_max=	4000	if efc==0			& year==	2002
replace pell_max=	3950	if efc>	0	& efc<=	100	& year==	2002
replace pell_max=	3850	if efc>	100	& efc<=	200	& year==	2002
replace pell_max=	3750	if efc>	200	& efc<=	300	& year==	2002
replace pell_max=	3650	if efc>	300	& efc<=	400	& year==	2002
replace pell_max=	3550	if efc>	400	& efc<=	500	& year==	2002
replace pell_max=	3450	if efc>	500	& efc<=	600	& year==	2002
replace pell_max=	3350	if efc>	600	& efc<=	700	& year==	2002
replace pell_max=	3250	if efc>	700	& efc<=	800	& year==	2002
replace pell_max=	3150	if efc>	800	& efc<=	900	& year==	2002
replace pell_max=	3050	if efc>	900	& efc<=	1000	& year==	2002
replace pell_max=	2950	if efc>	1000	& efc<=	1100	& year==	2002
replace pell_max=	2850	if efc>	1100	& efc<=	1200	& year==	2002
replace pell_max=	2750	if efc>	1200	& efc<=	1300	& year==	2002
replace pell_max=	2650	if efc>	1300	& efc<=	1400	& year==	2002
replace pell_max=	2550	if efc>	1400	& efc<=	1500	& year==	2002
replace pell_max=	2450	if efc>	1500	& efc<=	1600	& year==	2002
replace pell_max=	2350	if efc>	1600	& efc<=	1700	& year==	2002
replace pell_max=	2250	if efc>	1700	& efc<=	1800	& year==	2002
replace pell_max=	2150	if efc>	1800	& efc<=	1900	& year==	2002
replace pell_max=	2050	if efc>	1900	& efc<=	2000	& year==	2002
replace pell_max=	1950	if efc>	2000	& efc<=	2100	& year==	2002
replace pell_max=	1850	if efc>	2100	& efc<=	2200	& year==	2002
replace pell_max=	1750	if efc>	2200	& efc<=	2300	& year==	2002
replace pell_max=	1650	if efc>	2300	& efc<=	2400	& year==	2002
replace pell_max=	1550	if efc>	2400	& efc<=	2500	& year==	2002
replace pell_max=	1450	if efc>	2500	& efc<=	2600	& year==	2002
replace pell_max=	1350	if efc>	2600	& efc<=	2700	& year==	2002
replace pell_max=	1250	if efc>	2700	& efc<=	2800	& year==	2002
replace pell_max=	1150	if efc>	2800	& efc<=	2900	& year==	2002
replace pell_max=	1050	if efc>	2900	& efc<=	3000	& year==	2002
replace pell_max=	950	if efc>	3000	& efc<=	3100	& year==	2002
replace pell_max=	850	if efc>	3100	& efc<=	3200	& year==	2002
replace pell_max=	750	if efc>	3200	& efc<=	3300	& year==	2002
replace pell_max=	650	if efc>	3300	& efc<=	3400	& year==	2002
replace pell_max=	550	if efc>	3400	& efc<=	3500	& year==	2002
replace pell_max=	450	if efc>	3500	& efc<=	3600	& year==	2002
replace pell_max=	400	if efc>	3600	& efc<=	3700	& year==	2002
replace pell_max=	400	if efc>	3700	& efc<=	3800	& year==	2002
replace pell_max=	0	if efc>	3800			& year==	2002
replace pell_max=	3750	if efc==0			& year==	2001
replace pell_max=	3700	if efc>	0	& efc<=	100	& year==	2001
replace pell_max=	3600	if efc>	100	& efc<=	200	& year==	2001
replace pell_max=	3500	if efc>	200	& efc<=	300	& year==	2001
replace pell_max=	3400	if efc>	300	& efc<=	400	& year==	2001
replace pell_max=	3300	if efc>	400	& efc<=	500	& year==	2001
replace pell_max=	3200	if efc>	500	& efc<=	600	& year==	2001
replace pell_max=	3100	if efc>	600	& efc<=	700	& year==	2001
replace pell_max=	3000	if efc>	700	& efc<=	800	& year==	2001
replace pell_max=	2900	if efc>	800	& efc<=	900	& year==	2001
replace pell_max=	2800	if efc>	900	& efc<=	1000	& year==	2001
replace pell_max=	2700	if efc>	1000	& efc<=	1100	& year==	2001
replace pell_max=	2600	if efc>	1100	& efc<=	1200	& year==	2001
replace pell_max=	2500	if efc>	1200	& efc<=	1300	& year==	2001
replace pell_max=	2400	if efc>	1300	& efc<=	1400	& year==	2001
replace pell_max=	2300	if efc>	1400	& efc<=	1500	& year==	2001
replace pell_max=	2200	if efc>	1500	& efc<=	1600	& year==	2001
replace pell_max=	2100	if efc>	1600	& efc<=	1700	& year==	2001
replace pell_max=	2000	if efc>	1700	& efc<=	1800	& year==	2001
replace pell_max=	1900	if efc>	1800	& efc<=	1900	& year==	2001
replace pell_max=	1800	if efc>	1900	& efc<=	2000	& year==	2001
replace pell_max=	1700	if efc>	2000	& efc<=	2100	& year==	2001
replace pell_max=	1600	if efc>	2100	& efc<=	2200	& year==	2001
replace pell_max=	1500	if efc>	2200	& efc<=	2300	& year==	2001
replace pell_max=	1400	if efc>	2300	& efc<=	2400	& year==	2001
replace pell_max=	1300	if efc>	2400	& efc<=	2500	& year==	2001
replace pell_max=	1200	if efc>	2500	& efc<=	2600	& year==	2001
replace pell_max=	1100	if efc>	2600	& efc<=	2700	& year==	2001
replace pell_max=	1000	if efc>	2700	& efc<=	2800	& year==	2001
replace pell_max=	900	if efc>	2800	& efc<=	2900	& year==	2001
replace pell_max=	800	if efc>	2900	& efc<=	3000	& year==	2001
replace pell_max=	700	if efc>	3000	& efc<=	3100	& year==	2001
replace pell_max=	600	if efc>	3100	& efc<=	3200	& year==	2001
replace pell_max=	500	if efc>	3200	& efc<=	3300	& year==	2001
replace pell_max=	400	if efc>	3300	& efc<=	3400	& year==	2001
replace pell_max=	400	if efc>	3400	& efc<=	3500	& year==	2001
replace pell_max=	400	if efc>	3500	& efc<=	3550	& year==	2001
replace pell_max=	0	if efc>	3550			& year==	2001
replace pell_max=	3300	if efc==0			& year==	2000
replace pell_max=	3250	if efc>	0	& efc<=	100	& year==	2000
replace pell_max=	3150	if efc>	100	& efc<=	200	& year==	2000
replace pell_max=	3050	if efc>	200	& efc<=	300	& year==	2000
replace pell_max=	2950	if efc>	300	& efc<=	400	& year==	2000
replace pell_max=	2850	if efc>	400	& efc<=	500	& year==	2000
replace pell_max=	2750	if efc>	500	& efc<=	600	& year==	2000
replace pell_max=	2650	if efc>	600	& efc<=	700	& year==	2000
replace pell_max=	2550	if efc>	700	& efc<=	800	& year==	2000
replace pell_max=	2450	if efc>	800	& efc<=	900	& year==	2000
replace pell_max=	2350	if efc>	900	& efc<=	1000	& year==	2000
replace pell_max=	2250	if efc>	1000	& efc<=	1100	& year==	2000
replace pell_max=	2150	if efc>	1100	& efc<=	1200	& year==	2000
replace pell_max=	2050	if efc>	1200	& efc<=	1300	& year==	2000
replace pell_max=	1950	if efc>	1300	& efc<=	1400	& year==	2000
replace pell_max=	1850	if efc>	1400	& efc<=	1500	& year==	2000
replace pell_max=	1750	if efc>	1500	& efc<=	1600	& year==	2000
replace pell_max=	1650	if efc>	1600	& efc<=	1700	& year==	2000
replace pell_max=	1550	if efc>	1700	& efc<=	1800	& year==	2000
replace pell_max=	1450	if efc>	1800	& efc<=	1900	& year==	2000
replace pell_max=	1350	if efc>	1900	& efc<=	2000	& year==	2000
replace pell_max=	1250	if efc>	2000	& efc<=	2100	& year==	2000
replace pell_max=	1150	if efc>	2100	& efc<=	2200	& year==	2000
replace pell_max=	1050	if efc>	2200	& efc<=	2300	& year==	2000
replace pell_max=	950	if efc>	2300	& efc<=	2400	& year==	2000
replace pell_max=	850	if efc>	2400	& efc<=	2500	& year==	2000
replace pell_max=	750	if efc>	2500	& efc<=	2600	& year==	2000
replace pell_max=	650	if efc>	2600	& efc<=	2700	& year==	2000
replace pell_max=	550	if efc>	2700	& efc<=	2800	& year==	2000
replace pell_max=	450	if efc>	2800	& efc<=	2900	& year==	2000
replace pell_max=	400	if efc>	2900	& efc<=	3000	& year==	2000
replace pell_max=	400	if efc>	3000	& efc<=	3100	& year==	2000
replace pell_max=	0	if efc>	3100			& year==	2000
replace pell_max=	3125	if efc==0			& year==	1999
replace pell_max=	3075	if efc>	0	& efc<=	100	& year==	1999
replace pell_max=	2975	if efc>	100	& efc<=	200	& year==	1999
replace pell_max=	2875	if efc>	200	& efc<=	300	& year==	1999
replace pell_max=	2775	if efc>	300	& efc<=	400	& year==	1999
replace pell_max=	2675	if efc>	400	& efc<=	500	& year==	1999
replace pell_max=	2575	if efc>	500	& efc<=	600	& year==	1999
replace pell_max=	2475	if efc>	600	& efc<=	700	& year==	1999
replace pell_max=	2375	if efc>	700	& efc<=	800	& year==	1999
replace pell_max=	2275	if efc>	800	& efc<=	900	& year==	1999
replace pell_max=	2175	if efc>	900	& efc<=	1000	& year==	1999
replace pell_max=	2075	if efc>	1000	& efc<=	1100	& year==	1999
replace pell_max=	1975	if efc>	1100	& efc<=	1200	& year==	1999
replace pell_max=	1875	if efc>	1200	& efc<=	1300	& year==	1999
replace pell_max=	1775	if efc>	1300	& efc<=	1400	& year==	1999
replace pell_max=	1675	if efc>	1400	& efc<=	1500	& year==	1999
replace pell_max=	1575	if efc>	1500	& efc<=	1600	& year==	1999
replace pell_max=	1475	if efc>	1600	& efc<=	1700	& year==	1999
replace pell_max=	1375	if efc>	1700	& efc<=	1800	& year==	1999
replace pell_max=	1275	if efc>	1800	& efc<=	1900	& year==	1999
replace pell_max=	1175	if efc>	1900	& efc<=	2000	& year==	1999
replace pell_max=	1075	if efc>	2000	& efc<=	2100	& year==	1999
replace pell_max=	975	if efc>	2100	& efc<=	2200	& year==	1999
replace pell_max=	875	if efc>	2200	& efc<=	2300	& year==	1999
replace pell_max=	775	if efc>	2300	& efc<=	2400	& year==	1999
replace pell_max=	675	if efc>	2400	& efc<=	2500	& year==	1999
replace pell_max=	575	if efc>	2500	& efc<=	2600	& year==	1999
replace pell_max=	475	if efc>	2600	& efc<=	2700	& year==	1999
replace pell_max=	400	if efc>	2700	& efc<=	2800	& year==	1999
replace pell_max=	400	if efc>	2800	& efc<=	2900	& year==	1999
replace pell_max=	400	if efc>	2900	& efc<=	2925	& year==	1999
replace pell_max=	0	if efc>	2925			& year==	1999
replace pell_max=0 if pell_max==.
la var pell_max "Annual Pell $"

compress
save "$clean/Year_Cleaned.dta", replace


/*
clear all
set more off
use Year_Cleaned.dta
drop unita_f unita_deg_f unita_bs_f unit_f unit_deg_f unit_bs_f unita_w unita_deg_w unita_bs_w unit_w unit_deg_w unit_bs_w unita_sp unita_deg_sp unita_bs_sp unit_sp unit_deg_sp unit_bs_sp unita_su unita_deg_su unita_bs_su unit_su unit_deg_su unit_bs_su bog_f bog_w bog_sp bog_su pell_f pell_w pell_sp pell_su
drop bog* cg* pell* amt* ws* loan*
drop age_* specialadmit_* efc* dependent married has_dependents housing_campus housing_offcampus housing_withparents household_size parent_incomeagi student_incomeagi hh_*
drop grant SF_EFC

replace high_school="" if high_school=="YYYYYY" 
replace name_first="" if name_first=="XXX" 
replace name_last="" if name_last=="XXX" 
replace goal="" if goal=="X" 

collapse (min) firstyear (firstnm) education ccc_first_term_cr_nsa_value CCC_FIRST_TERM student_ssn (sum) unit*   (max) hispanic asian white black other_race race_unknown female uscitizen_res ca_resident  hs_grad aa_deg ba_deg trans* deg* associate credit_cert creditcert_30plus creditcert_30less, by (student college) 
compress
save Year_CollapsedStudent.dta, replace

*/
