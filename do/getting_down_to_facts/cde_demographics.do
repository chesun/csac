/* summary statistics for demographics using CDE annual enrollment data 

---
Code borrowed from VA project
---
*/

/* 
do $csacprojdir/do/getting_down_to_facts/cde_demographics.do
 */
graph drop _all
set more off
set varabbrev off
set graphics off
set scheme s1color

cap log close _all
log using $csacprojdir/log/getting_down_to_facts/cde_demographics.txt, text replace


**********************************************
*----- 1. Clean annual enrollment file
**********************************************

import delimited using $csacprojdir/dta/raw/enr202022.txt, delimiter(tab) varnames(1) stringcols(1 2) clear

keep if academic_year == "2022-23"

rename cds_code cdscode
	label var cdscode "CDS Code"
	label var county "County"
	label var district "District"
	label var school "School"

	rename ethnic ethnicity
	label def ethnicity 0 "Not reported"
	label def ethnicity 1 "American Indian or Alaska Native, Not Hispanic", add
	label def ethnicity 2 "Asian, Not Hispanic", add
	label def ethnicity 3 "Pacific Islander, Not Hispanic", add
	label def ethnicity 4 "Filipino, Not Hispanic", add
	label def ethnicity 5 "Hispanic or Latino", add
	label def ethnicity 6 "African American, not Hispanic", add
	label def ethnicity 7 "White, not Hispanic", add
	label def ethnicity 9 "Two or More Races, Not Hispanic", add
	label val ethnicity ethnicity
	label var ethnicity "Racial/ethnic designation"

	label def race 1 "American Indian or Alaska Native"
	label def race 2 "Asian", add
	label def race 5 "Hispanic or Latino", add
	label def race 6 "Black or African American", add
	label def race 7 "White", add
	label def race 8 "Two or More Races", add
	//gen varname:lblname = []
	gen race:race = 1 if ethnicity==1
	replace race = 2 if inlist(ethnicity, 2, 3, 4)
	replace race = 5 if ethnicity==5
	replace race = 6 if ethnicity==6
	replace race = 7 if ethnicity==7
	replace race = 8 if ethnicity==9
	label var race "Race"

	label def male 1 "Male" 0 "Female"
	gen male:male = 1 if gender=="M"
	replace male = 0 if gender=="F"
	replace male = . if mi(gender)
	label var male "Male"
	drop gender

	label var kdgn "Students enrolled in kindergarten"

	label var gr_1 "Students enrolled in grade one"

	label var gr_2 "Students enrolled in grade two"

	label var gr_3 "Students enrolled in grade three"

	label var gr_4 "Students enrolled in grade four"

	label var gr_5 "Students enrolled in grade five"

	label var gr_6 "Students enrolled in grade six"

	label var gr_7 "Students enrolled in grade seven"

	label var gr_8 "Students enrolled in grade eight"

	label var ungr_elm "Students enrolled in ungraded elementary classes in grades kindergarten through eight"

	label var gr_9 "Students enrolled in grade nine"

	label var gr_10 "Students enrolled in grade ten"

	label var gr_11 "Students enrolled in grade eleven"

	label var gr_12 "Students enrolled in grade twelve"

	label var ungr_sec "Students enrolled in ungraded secondary classes in grades nine through twelve"

	label var enr_total "Total school enrollment for fields Kindergarten (KDGN) through grade twelve (GR_12) plus ungraded elementary (UNGR_ELM) and ungraded secondary classes (UNGR_SEC). Adults in kindergarten through grade twelve programs are not included."

	label var adult "Adults enrolled in kindergarten through grade twelve programs. This data does not include adult education students."

	gen year = `fall_year' + 1
	label var year "Year of Spring Semester"

	order cdscode year county district school ethnicity race male
	sort cdscode year county district school ethnicity race male
	compress
	label data "California Department of Education Spring `=`fall_year' + 1' School Enrollment"
	save data/public_access/clean/cde/enr/enr_`=`fall_year' + 1'_clean.dta, replace