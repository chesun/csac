/*******************************************************************************
PROGRAM: csac_survey_finaid_analysis_bf.do

DESCRIPTION:  
This .do file identifies the FAFSA and financial aid questions from the Spring 2023
high school seniors survey, with the subgroups to look at for the analysis. 

AUTHOR: Betsey Friedmann

DATE: August 2023
*******************************************************************************/

use "/home/research/ca_ed_lab/projects/csac_survey2023/dta/cln/csac_hs_senior_2023_brief.dta",  clear

*Drop unnecessary variables
drop startdate enddate recordeddate progress duration_sec device_browser device_version device_os device_res t_conset t_senior t_hear_import_aid t_hs_req_fafsa t_*

*August 2 update: Baiyu created new variables for "check all that apply" questions


/*************************************************************************************
	Subgroups for Cross-Tabs
		Race: race_simp
		Gender: gender_brief
		High school type: hs_type
		Segment: where_college
		EFC (once Betsey matches to CSAC admin data)
*************************************************************************************/

/*************************************************************************************
	Financial Aid/FAFSA Questions
*************************************************************************************/

*************************************************************************************
*Q2. How did you hear about the importance of submitting a financial aid application? 
*************************************************************************************
tab hear_import_aid, m

	*Individual variables for each response (hear_import_aid_)
	tab hear_import_aid_ihsstaff, m

	*(Fill in responses for "other")   
	tab hear_import_aid_other, m   

	*Example Cross-tab: Hearing of importance of financial aid from counselors by race. 
	tab race_simp hear_import_aid_ihsstaff, r 
		/*
					      | selected 'High school
		       race/ethnicity |   staff (counselor,
			 reduced to 9 |    teacher, etc.)'
			   categories |         0          1 |     Total
		----------------------+----------------------+----------
		Black/African America |        50        270 |       320 
				      |     15.62      84.38 |    100.00 
		----------------------+----------------------+----------
		American Indian/Alask |         5         13 |        18 
				      |     27.78      72.22 |    100.00 
		----------------------+----------------------+----------
				Asian |       142        809 |       951 
				      |     14.93      85.07 |    100.00 
		----------------------+----------------------+----------
			     Filipino |        16        103 |       119 
				      |     13.45      86.55 |    100.00 
		----------------------+----------------------+----------
		      Hispanic/Latinx |       486      3,075 |     3,561 
				      |     13.65      86.35 |    100.00 
		----------------------+----------------------+----------
		     Pacific Islander |         3         23 |        26 
				      |     11.54      88.46 |    100.00 
		----------------------+----------------------+----------
		   White/Non-Hispanic |       297      1,254 |     1,551 
				      |     19.15      80.85 |    100.00 
		----------------------+----------------------+----------
				Other |        47        104 |       151 
				      |     31.13      68.87 |    100.00 
		----------------------+----------------------+----------
			  Two or more |       232      1,093 |     1,325 
				      |     17.51      82.49 |    100.00 
		----------------------+----------------------+----------
				Total |     1,278      6,744 |     8,022 
				      |     15.93      84.07 |    100.00 
		The row option (,r) shows within race, what % of students heard from their counselor?
		
		Pretty stable across race- 81-86% of Black, Asian, Hispanic and White students
		were advised by their counselor 
		*/
	
	
*************************************************************************************	
*Q3. Were you required by your high school to fill out the FAFSA/CADAA?
*************************************************************************************
tab hs_req_fafsa, m

	*Example cross-tab: by high school type
	tab hs_type hs_req_fafsa, r
	/*
			  type of high school |  did your hs require
		   you are graduating |      FAFSA/CADAA
				 from |        No        Yes |     Total
		----------------------+----------------------+----------
		Public high school (i |     1,374      6,294 |     7,668 
				      |     17.92      82.08 |    100.00 
		----------------------+----------------------+----------
		Private/Parochial hig |       171        127 |       298 
				      |     57.38      42.62 |    100.00 
		----------------------+----------------------+----------
			  Home school |        34         99 |       133 
				      |     25.56      74.44 |    100.00 
		----------------------+----------------------+----------
				Total |     1,579      6,520 |     8,099 
				      |     19.50      80.50 |    100.00 
	
	82% of students attending a public high school said they were required to submit the FAFSA. 
	compared to 43% of private/parochial schools */
	
*****************************************************************************************************
*Q6. Please tell us which of the following helped you complete the FAFSA/CADAA. Check all that apply:
*****************************************************************************************************
tab fafsa_support,m 

	*Individual variables for each response (fafsa_support_)
	tab fafsa_support_icounselor, m
	
	
*************************************************************************************	
*Q6. Do you plan to attend college in the fall? 
*************************************************************************************	
tab college_fall,m 
	
	*************************************************************************************
	*if No: Q7a. What do you think you'll be doing this coming Fall? (Check all that apply) 
	*************************************************************************************
	tab fall_plan, m

		*Individual responses (fall_plan_)
		tab fall_plan_iworkpt, m
	
	*************************************************************************************
	*if I don't know: which of these might influence your decision not to attend college?
	*************************************************************************************
	tab inf_no_college, m
	
		*Individual responses (inf_no_college_)
		tab inf_no_college_ifinancial, m



	*************************************************************************************		
	*If yes, Q6. Where do you plan to attend college this fall?
	*************************************************************************************	
	tab where_college, m


*All of these following questions were only asked for the "Yes" college respondents
	
*************************************************************************************************	
*Q7. Has your college contacted you (e.g. email, letter, phone call) about your financial aid?
*************************************************************************************************	
tab college_contact,m 

***********************************************************************************************************************	
*If Yes: Q7b. Has your college contacted you about the following regarding your financial aid? (Check all that apply) 
***********************************************************************************************************************		
tab college_contact_item, m 

	*Individual variables for each item (college_contact_)
	tab college_contact_iverification, m 

*************************************************************************************	
*Q10. How do you plan to pay college tuition and fees? (Check all that apply) 
*************************************************************************************	
tab pay_plan, m

	*Individual variables for each item (pay_plan_)
	tab pay_plan_ischolarships,m 
	
	

/**************************************************************************************	
			LOAN QUESTIONS
*************************************************************************************
Jaime to see what results look like 

	1. What do they think of loan repayment?

	2. How much they plan to take out in loans? And how is that related to expectations of loan repayment?

Q11. The next questions ask about your beliefs about student loan repayment. We are interested in your beliefs even if you do not plan to take out any loans.
 
Imagine that you borrowed $10,000 in student loans to pay for college. How much do you think you would actually be required to pay back? In other words, how much of these loans do you think would not be forgiven?  [Slider from 0 to 10k-  No default value]

Now imagine that you borrowed $50,000 in student loans to pay for college. How much do you think you would actually be required to pay back? In other words, how much of these loans do you think would not be forgiven?  [Slider from 0 to $50k -  No default value] 

Q11b. IF LOAN : You indicated you plan to take out student loans. How much do you plan to borrow?
*/
codebook loan_pay_10k loan_pay_50k
tab loan_borrow_amount, m


/*************************************************************************************
Q13.  When you think about college, how worried are you about the following? (not at all worried to very worried)
	Being able to afford college tuition, fees, books, and equipment
	Being able to afford living expenses (rent, food, transportation, etc.)
	Balancing work obligations
*/
codebook worry_tuition worry_living worry_work


*************************************************************************************
*Q21. Tell us what type of high school you are graduating from: 
*************************************************************************************
tab hs_type, m

*************************************************************************************
*Q24. Do you currently have a job? 
*Q24b.  How many hours a week do you work at your job? (if Yes)
*************************************************************************************
tab hours_job has_job, m


