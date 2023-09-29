/*******************************************************************************
PROGRAM: Create coodebook for csac_hs_senior_2023_clean.dta

WRITTEN BY: Baiyu Zhou (baizhou@ucdavis.edu)

DATE CREATED: July 17, 2023

NOTE: This program creates codebook for cleaned CSAC high school senior survey. 
Data cleaning was performed by Christina Sun (ucsun@ucdavis.edu). Two forms of
codebooks were created: MS Excel compatible format (.xls) and plain text (.txt)
*******************************************************************************/

********************************* Preamble ************************************
*----------*
* Settings
*----------*

* Set default directory
cd "/home/research/ca_ed_lab/projects/csac_survey2023"

* Set directories with macro
global csacprojdir "/home/research/ca_ed_lab/projects/csac_survey2023"
global csacrawdatadir "/home/research/ca_ed_lab/data/restricted_access/raw/csac_survey/2023"
global csacclndatadir "/home/research/ca_ed_lab/data/restricted_access/clean/csac_survey/2023"

* Set settings
version 17.0


********************************* Main *****************************************

* Load fully cleaned data
use "$csacclndatadir/csac_hs_senior_2023_clean.dta", clear

* XLS: Save names, labels, storage types, values, and value labels in MS excel
ssc install codebookout
codebookout "$csacprojdir/codebook.xls"

* Plain Text: save names, labels, storage types, range, units, unique values, missing values, value labels, and frequency tabulation

cap log close
quietly {
	log using "$csacprojdir/codebook.txt", text replace
	noisily codebook, all
	log close
}
