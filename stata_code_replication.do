
global dta "H:\M1 QE\Database and Stata\m1_final_project\dataandcode\"

global tables "H:\M1 QE\Database and Stata\m1_final_project\dataandcode\tables\"

********************************************************************************
* DATA LABELING 
********************************************************************************

use "${dta}master_dataset.dta", clear /// original replication data

* -------------------------------------
* baseline analysis from age 0 to 15

* outcome variable : ch_Family_attit_mean
* regressors of interest:  
* - (exposure to mother married and working) expo15_marriedworking
* - (exposure to a not married mother) expo15_notm
* - (exposure to mother married and primary breadwinner) expo15_marriedbread

* main controls:
* - SD family income (from age 0 to age 15) - expo15_sd_faminc
* - Mean log family income (from age 0 to age 15) - expo15_lnfaminc
* - Mother's gender-norm index (1979)- Att_Index_1979
* - Mother's self-esteem index (1980) - ROSENBERG_SCORE_1980_1979
* - Mother's education -  expo_15_hgc

* other controls:
* - mother's religious affiliation - religion_1979
* - mother's race - ???
* - mother's age at time of birth - age_mombirth
* - mother's mother's education - ???
* - whether the mother's mother/father was present, when the mother was 14 - mother_home_1979 - father_home_1979
* - whether the mother was living in a city at 14 - city_1979
* - mother's age in 1979 - age_1979
* - fraction of years from age 0 to age 15 the child lived in
* Northeast/North Central/South/West - expo15_dregion1{2,3}
* - average age the young adult completed the survey used to measure gender-role attitudes - meanagech_Family_attit_
* - average year the young aldut completed the survey - meanyearch_Family_attit_

* each observation is weighthed by the mother's weight in the NLSY 1979 - ch_SAMPWT_1979

*------------------------------
* labeling variables - to gain in clarity (especially the ones which will be displayed
* in the regression table)

la var ch_Family_attit_mean "Children Gender-norm index"
* exposure from age 0 to 15
label variable expo15_marriedworking "Mother married and working"
la var expo15_notm "Mother not married"
la var expo15_marriedbread "Mother married and primary breadwinner"
* exposure from age 6 to 15
label variable expo515_marriedworking "Mother married and working"
la var expo515_notm "Mother not married"
la var expo515_marriedbread "Mother married and primary breadwinner"
* exposure from age 0 to 5
label variable expo5_marriedworking "Mother married and working"
la var expo5_notm "Mother not married"
la var expo5_marriedbread "Mother married and primary breadwinner"

* main controls
la var expo15_sd_faminc "SD family income"
la var expo15_lnfaminc "Mean log family income"
la var ROSENBERG_SCORE_1980_1979 "Mother's self-esteem index (1980)"
la var Att_Index_1979 "Mother's gender-norm index (1979)"
la var expo15_hgc "Mother's educatation"

* other controls
la var religion_1979 "mother's religious affiliation"
la var age_mombirth "mother's age a time of birth"
la var age_1979 "mother's age in 1979"

save "${dta}repl_master_dataset.dta", replace

use "${dta}repl_master_dataset.dta", clear /// re-labeled replication data set

********************************************************************************
* DATA PREPARATION - for DESCRIPTIVE STATISTICS
********************************************************************************
* clean missing values 
global var "Att_Index_1979 mother_educ_1979 ch_female ch_black ch_white expo15_marriedworking expo15_marriedbread expo15_sd_faminc ch_Family_attit_mean expo15_lnfaminc expo15_notm"
foreach x in $var{
drop if `x' ==.
} 


* --- create some variables about the main marital/working status of the women over the first 15 years of children * ---

* generate a binary variable describing if the mother's main status has been "married & not working" ie: traditional
gen expo15_notw_m = 1 - expo15_marriedworking - expo15_notm
gen msmother_notw_m = 0 
	. replace msmother_notw_m = 1 if (expo15_notw_m > expo15_marriedworking) & (expo15_notw_m > expo15_notm)

* generate a binary variable describing if the mother's main status has been "married & working"
gen msmother_w_m = 0
	. replace msmother_w_m = 1 if (expo15_marriedworking > expo15_notw_m) & (expo15_marriedworking > expo15_notm)

* generate a binary variable describin if the mother's main status has been "not married & working"
gen msmother_w_notm = 0
	. replace msmother_w_notm = 1 if (expo15_notm > expo15_marriedworking) & (expo15_notm > expo15_notw_m)

* create categorical variable about main status for descriptive statistics table
gen mother_ms = "Married & not working" if msmother_notw_m == 1
	. replace mother_ms = "Married & working" if msmother_w_m == 1
	. replace mother_ms = "Not married & working" if msmother_w_notm == 1

********************************************************************************
* CREATION DESCRIPTIVE STATISTICS TABLE
********************************************************************************	
	
	
* Descripitve statistics table based on the mother's working and marital status

global mother_dstat "ROSENBERG_SCORE_1980_1979 Att_Index_1979 mother_educ_1979 expo15_hgc_ ch_Family_attit_mean age_mombirth"


eststo clear
eststo married_notworking: quietly estpost summarize $mother_dstat if msmother_notw_m == 1 
eststo married_working: quietly estpost summarize $mother_dstat if msmother_w_m == 1 
eststo notmarried_working: quietly estpost summarize $mother_dstat if msmother_w_notm ==1

esttab married_notworking married_working notmarried_working using "${tables}basic_descrpitive.rtf" , ///
cells("mean(pattern(1 1 1) fmt(2)) sd(pattern(1 1 1)) ") label obs nonumbers ///
mtitles("Married & not working" "Married & working" "Not married & working") ///
title("Descriptive statistics - Mother Main Status") replace


********************************************************************************
* REPLICATION OF PAPER EMPIRICAL WORK REGRESSION + Table 1 & Table 2 in paper
********************************************************************************

** baseline regression + identification strategy
** de 0 à 15
	
	global other_controls "ch_white ch_black expo15_dregion1 expo15_dregion2 expo15_dregion3 i.religion_1979 age_1979 city_1979 mother_home_1979 father_home_1979 mother_work_1979 mother_educ_1979 meanagech_Family_attit_ meanyearch_Family_attit"

* female
xi:reg ch_Family_attit_mean expo15_lnfaminc expo15_sd_faminc expo15_marriedworking expo15_marriedbread expo15_notm Att_Index_1979 ROSENBERG_SCORE_1980_1979 expo15_hgc $other_controls if ch_female==1 [aw=ch_SAMPWT_1979]
* Male
xi:reg ch_Family_attit_mean expo15_lnfaminc expo15_sd_faminc expo15_marriedworking expo15_marriedbread expo15_notm Att_Index_1979 ROSENBERG_SCORE_1980_1979 expo15_hgc $other_controls if ch_female==0 [aw=ch_SAMPWT_1979]


**de 6 à 15 et de 0 à 5
global other_controls "ch_white ch_black expo15_dregion1 expo15_dregion2 expo15_dregion3 i.religion_1979 age_1979 city_1979 mother_home_1979 father_home_1979 mother_work_1979 mother_educ_1979 meanagech_Family_attit_ meanyearch_Family_attit"
* fille
xi:reg ch_Family_attit_mean expo15_lnfaminc expo15_sd_faminc expo515_marriedworking expo5_marriedworking expo515_marriedbread expo5_marriedbread expo515_notm expo5_notm Att_Index_1979 ROSENBERG_SCORE_1980_1979 expo15_hgc $other_controls if ch_female==1 [aw=ch_SAMPWT_1979]
* garçon
xi:reg ch_Family_attit_mean expo15_lnfaminc expo15_sd_faminc expo515_marriedworking expo5_marriedworking expo515_marriedbread expo5_marriedbread expo515_notm expo5_notm Att_Index_1979 ROSENBERG_SCORE_1980_1979 expo15_hgc $other_controls if ch_female==0 [aw=ch_SAMPWT_1979]


** second set of specifications - heterogeneity in nontradtional families

global other_controls "ch_white ch_black expo15_dregion1 expo15_dregion2 expo15_dregion3 i.religion_1979 age_1979 city_1979 mother_home_1979 father_home_1979 mother_work_1979 mother_educ_1979 meanagech_Family_attit_ meanyearch_Family_attit"

**concervativ mother
* fille
xi:reg ch_Family_attit_mean expo15_lnfaminc expo15_sd_faminc expo515_marriedworking  expo515_marriedbread expo515_notm ROSENBERG_SCORE_1980_1979 Att_Index_1979 expo15_hgc $other_controls if ch_female==1 & Att_Index_1979<=16 [aw=ch_SAMPWT_1979]
* garçon
xi:reg ch_Family_attit_mean expo15_lnfaminc expo15_sd_faminc expo515_marriedworking  expo515_marriedbread expo515_notm ROSENBERG_SCORE_1980_1979 Att_Index_1979 expo15_hgc $other_controls if ch_female==0 & Att_Index_1979<=16 [aw=ch_SAMPWT_1979]

**liberal mother
* fille
xi:reg ch_Family_attit_mean expo15_lnfaminc expo15_sd_faminc expo515_marriedworking  expo515_marriedbread expo515_notm ROSENBERG_SCORE_1980_1979 Att_Index_1979 expo15_hgc $other_controls if ch_female==1 & Att_Index_1979>=17 [aw=ch_SAMPWT_1979]
* garçon
xi:reg ch_Family_attit_mean expo15_lnfaminc expo15_sd_faminc expo515_marriedworking  expo515_marriedbread expo515_notm ROSENBERG_SCORE_1980_1979 Att_Index_1979 expo15_hgc $other_controls if ch_female==0 & Att_Index_1979>=17 [aw=ch_SAMPWT_1979]


* --- MAKE PRETTY REGRESSION TABLES ---- * 
* create gender categorical variable 
gen gender = "Men" if ch_female==0
	. replace gender = "Women" if ch_female==1
* --- 1st Table
eststo clear

* eststo: xi:reg ch_Family_attit_mean expo15_lnfaminc expo15_sd_faminc expo15_marriedworking expo15_marriedbread expo15_notm Att_Index_1979 ROSENBERG_SCORE_1980_1979 expo15_hgc $other_controls if ch_female==1 [aw=ch_SAMPWT_1979]
sort gender
by gender: eststo: xi:reg ch_Family_attit_mean expo15_lnfaminc expo15_sd_faminc expo15_marriedworking expo15_marriedbread expo15_notm Att_Index_1979 ROSENBERG_SCORE_1980_1979 expo15_hgc $other_controls  [aw=ch_SAMPWT_1979]
by gender: eststo: xi:reg ch_Family_attit_mean expo15_lnfaminc expo15_sd_faminc expo5_marriedworking expo5_marriedbread expo5_notm expo515_marriedworking expo515_marriedbread expo515_notm Att_Index_1979 ROSENBERG_SCORE_1980_1979 expo15_hgc $other_controls [aw=ch_SAMPWT_1979]
* mgroups("Dependent variable: Gender norm index", pattern(1 0 0 0)) collabels("Women" "Men", pattern(1 0 1 0))
esttab using "${tables}table_regression_1_adv.rtf", se r2 label ///
mlabels("Men" "Women" "Men" "Women") mgroups("Dependent variable: Gender norm index" "Dependent variable: Gender norm index", pattern(1 0 1 0)) title("Table 1 - Gender Norms and non Traditional Families") nonumbers ///
keep(expo15_lnfaminc expo15_sd_faminc expo15_marriedworking expo15_marriedbread expo15_notm expo5_marriedworking expo5_marriedbread expo5_notm expo515_marriedworking expo515_marriedbread expo515_notm Att_Index_1979 ROSENBERG_SCORE_1980_1979 expo15_hgc_) ///
order(expo15_lnfaminc expo15_sd_faminc expo15_marriedworking expo15_marriedbread expo15_notm expo5_marriedworking expo5_marriedbread expo5_notm expo515_marriedworking expo515_marriedbread expo515_notm Att_Index_1979 ROSENBERG_SCORE_1980_1979 expo15_hgc_) ///
refcat(expo15_lnfaminc "Exposure from age 0 to 15" expo5_marriedworking "Exposure from age 0 to 5" expo515_marriedworking "Exposure from age 6 to 15" Att_Index_1979 "Main controls" , nolabel) ///
varwidth(21) compress replace

* -- 2nd table
eststo clear
* conservative
by gender: eststo: xi:reg ch_Family_attit_mean expo15_lnfaminc expo15_sd_faminc expo515_marriedworking  expo515_marriedbread expo515_notm ROSENBERG_SCORE_1980_1979 Att_Index_1979 expo15_hgc $other_controls if Att_Index_1979<=16 [aw=ch_SAMPWT_1979]
* liberal
by gender: eststo: xi:reg ch_Family_attit_mean expo15_lnfaminc expo15_sd_faminc expo515_marriedworking  expo515_marriedbread expo515_notm ROSENBERG_SCORE_1980_1979 Att_Index_1979 expo15_hgc $other_controls if Att_Index_1979>=17 [aw=ch_SAMPWT_1979]
* create table
esttab using "${tables}table_regression_2_modif.rtf", se r2 label mtitle("Dependent variable: Gender-norm index") ///
mlabels("Men" "Women" "Men" "Women") mgroups("conservative mother" "liberal mother", pattern(1 0 1 0)) title("Table 2 - Gender Norms and non Traditional Families: Heterogeneity") nonumbers ///
keep(expo15_lnfaminc expo15_sd_faminc expo515_marriedworking expo515_marriedbread expo515_notm  Att_Index_1979 ROSENBERG_SCORE_1980_1979 expo15_hgc_) ///
order(expo15_lnfaminc expo15_sd_faminc expo15_marriedworking expo15_marriedbread expo15_notm expo5_marriedworking expo5_marriedbread expo5_notm expo515_marriedworking expo515_marriedbread expo515_notm Att_Index_1979 ROSENBERG_SCORE_1980_1979 expo15_hgc_) ///
refcat(expo15_lnfaminc "Exposure from age 0 to 15" expo515_marriedworking "Exposure from age 6 to 5" expo515_marriedworking Att_Index_1979 "Main controls" , nolabel) ///
varwidth(21) compress replace
