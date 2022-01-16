
cd "\\storage2016.windows.dauphine.fr\home\b\boucim19\My_Work\M1 QE\Database and Stata\m1_final_project\dataandcode"

use "orm_working_dataset.dta", clear /// Data collected using python

global tables "H:\M1 QE\Database and Stata\m1_final_project\dataandcode\"

********************************************************************************
* Data LABELING 
********************************************************************************
**questions of the index
*FAM_ATTITUDES___A_WOMAN_S_PLACE_  "a woman's place is in the home, not the office or shop"
*FAM_ATT___WIFE_CARR_OUT_FAM_RESP  "a wife who carries out her full family responsabilities doesn't have time for outside employment"
*FAM_ATT___WORK_WIFE_FL_MORE_USEF   ??
*FAM_ATT___EMP_OF_WIVES_LEADS_TO_  "Employment of wives leads to more juvenile delinquency"
*FAM_ATT___EMP_BOTH_PAR_NEC_TO_KE   ??
*FAM_ATT___MCH_BTTR_IF_MAN_ACHIEV  "It is much better for everyone concerned if the man is the achiver utside the home and the woman takes care of the home and family"
*FAM_ATT___MEN_SHOULD_SHARE_HOUSE  "Men chould share the work around the house, such a doing dish, cleaning and so forth"
*FAM_ATT___WOMEN_HAPPIER_IF_STAY_  "Women are much happier if they stay at home and take care of their children"


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
* missing Mother's education (still unsure)

* other controls
la var religion_1979 "mother's religious affiliation"
la var age_mombirth "mother's age a time of birth"
la var age_1979 "mother's age in 1979"

*questions of the index
label variable FAM_ATTITUDES___A_WOMAN_S_PLACE_  "a woman's place is in the home ..."
label variable FAM_ATT___WIFE_CARR_OUT_FAM_RESP  "a wife with her full family responsabilities [...] no outside employment"
label variable FAM_ATT___EMP_OF_WIVES_LEADS_TO_  "Employment of wives leads to more juvenile delinquency"
label variable FAM_ATT___MCH_BTTR_IF_MAN_ACHIEV  "the man should be the achiver outside the home ..."
label variable FAM_ATT___MEN_SHOULD_SHARE_HOUSE  "Men chould share the work around the house ..."
label variable FAM_ATT___WOMEN_HAPPIER_IF_STAY_  "Women are much happier at home with their children ..."


save "orm_working_dataset.dta", replace

********************************************************************************
* EMPIRICAL ANALYSIS - ORDERED RESPONSE MODELS
********************************************************************************

global other_controls "ch_white ch_black expo15_dregion1 expo15_dregion2 expo15_dregion3 i.religion_1979 age_1979 city_1979 mother_home_1979 father_home_1979 mother_work_1979 mother_educ_1979 "
* some controls are no longer interesting
* - meanagech_Family_attit_ meanyearch_Family_attit
global regressors515 "expo515_marriedworking  expo515_marriedbread expo515_notm"

*******************************************************************************
* main regressors for age 6 to 15 exposure - gender heterogeneity - complete set of controls (except 2 irrelavant ones)
* ******************************************************************************

* outcome variable: a woman's place is in the home, not the office or shop
* ordered probit model
oprobit FAM_ATTITUDES___A_WOMAN_S_PLACE_ expo15_lnfaminc expo15_sd_faminc $regressors515 ROSENBERG_SCORE_1980_1979 Att_Index_1979 expo15_hgc $other_controls if ch_female == 1 [aw=ch_SAMPWT_1979]

* marginal effects 
margins, dydx("expo515_marriedbread") predict(outcome(4))
margins, dydx("expo515_marriedbread") predict(outcome(3))
margins, dydx("expo515_marriedbread") predict(outcome(2))
margins, dydx("expo515_marriedbread") predict(outcome(1))

* male
oprobit FAM_ATTITUDES___A_WOMAN_S_PLACE_ expo15_lnfaminc expo15_sd_faminc $regressors515 ROSENBERG_SCORE_1980_1979 Att_Index_1979 expo15_hgc $other_controls if ch_female == 0 [aw=ch_SAMPWT_1979]
* marginal effects 
margins, dydx("expo515_marriedbread") predict(outcome(4))
margins, dydx("expo515_marriedbread") predict(outcome(3))
margins, dydx("expo515_marriedbread") predict(outcome(2))
margins, dydx("expo515_marriedbread") predict(outcome(1))

* outcome variable: FAM_ATT___MEN_SHOULD_SHARE_HOUSE
* ordered probit model
* female
oprobit FAM_ATT___MEN_SHOULD_SHARE_HOUSE expo15_lnfaminc expo15_sd_faminc $regressors515 ROSENBERG_SCORE_1980_1979 Att_Index_1979 expo15_hgc $other_controls if ch_female == 1 [aw=ch_SAMPWT_1979]

* marginal effects 
margins, dydx("expo515_marriedbread") predict(outcome(4))
margins, dydx("expo515_marriedbread") predict(outcome(3))
margins, dydx("expo515_marriedbread") predict(outcome(2))
margins, dydx("expo515_marriedbread") predict(outcome(1))

* male
oprobit FAM_ATT___MEN_SHOULD_SHARE_HOUSE expo15_lnfaminc expo15_sd_faminc $regressors515 ROSENBERG_SCORE_1980_1979 Att_Index_1979 expo15_hgc $other_controls if ch_female == 0 [aw=ch_SAMPWT_1979]
* marginal effects 
margins, dydx("expo515_marriedbread") predict(outcome(4))
margins, dydx("expo515_marriedbread") predict(outcome(3))
margins, dydx("expo515_marriedbread") predict(outcome(2))
margins, dydx("expo515_marriedbread") predict(outcome(1))

* outcome variable: FAM_ATT___WOMEN_HAPPIER_IF_STAY_ (ambiguous statement) - Women are much happier if they stay at home and take care of their children
* ordered probit model
* female
oprobit FAM_ATT___WOMEN_HAPPIER_IF_STAY_ expo15_lnfaminc expo15_sd_faminc $regressors515 ROSENBERG_SCORE_1980_1979 Att_Index_1979 expo15_hgc $other_controls if ch_female == 1 [aw=ch_SAMPWT_1979]

* marginal effects 
margins, dydx("expo515_marriedbread") predict(outcome(4))
margins, dydx("expo515_marriedbread") predict(outcome(3))
margins, dydx("expo515_marriedbread") predict(outcome(2))
margins, dydx("expo515_marriedbread") predict(outcome(1))

* male
oprobit FAM_ATT___WOMEN_HAPPIER_IF_STAY_ expo15_lnfaminc expo15_sd_faminc $regressors515 ROSENBERG_SCORE_1980_1979 Att_Index_1979 expo15_hgc $other_controls if ch_female == 0 [aw=ch_SAMPWT_1979]
* marginal effects 
margins, dydx("expo515_marriedbread") predict(outcome(4))
margins, dydx("expo515_marriedbread") predict(outcome(3))
margins, dydx("expo515_marriedbread") predict(outcome(2))
margins, dydx("expo515_marriedbread") predict(outcome(1))

* ORM output table
eststo clear
sort ch_female
by ch_female: eststo: oprobit FAM_ATT___MEN_SHOULD_SHARE_HOUSE expo15_lnfaminc expo15_sd_faminc $regressors515 ROSENBERG_SCORE_1980_1979 Att_Index_1979 expo15_hgc $other_controls  [aw=ch_SAMPWT_1979]
by ch_female: eststo: oprobit FAM_ATT___WOMEN_HAPPIER_IF_STAY_ expo15_lnfaminc expo15_sd_faminc $regressors515 ROSENBERG_SCORE_1980_1979 Att_Index_1979 expo15_hgc $other_controls  [aw=ch_SAMPWT_1979]
* 
esttab using "${tables}table_orm_output_modif.rtf", se label ///
mlabels("Men" "Women" "Men" "Women") mgroups("Statement: Men should share the work around the house ..." "Statement: Women are much happier at home with their children ...", pattern(1 0 1 0)) ///
title("Table 2 - Ordered Response Model and impact of non Tradtional Families") nonumbers ///
keep(expo515_marriedworking  expo515_marriedbread expo515_notm Att_Index_1979 expo15_lnfaminc) ///
order(expo515_marriedworking  expo515_marriedbread expo515_notm expo15_lnfaminc Att_Index_1979) ///
refcat(expo515_marriedworking "Exposure from age 6 to 15" expo15_lnfaminc "Main controls" , nolabel) ///
varwidth(21) compress replace

* ORM marginal effects table
eststo clear
* outcome variable: FAM_ATT___MEN_SHOULD_SHARE_HOUSE
* ordered probit model
* female marginal effects 
oprobit FAM_ATT___MEN_SHOULD_SHARE_HOUSE expo15_lnfaminc expo15_sd_faminc $regressors515 ROSENBERG_SCORE_1980_1979 Att_Index_1979 expo15_hgc $other_controls if ch_female == 1 [aw=ch_SAMPWT_1979]
eststo m4f: margins, dydx("expo515_marriedbread") predict(outcome(4)) post 

oprobit FAM_ATT___MEN_SHOULD_SHARE_HOUSE expo15_lnfaminc expo15_sd_faminc $regressors515 ROSENBERG_SCORE_1980_1979 Att_Index_1979 expo15_hgc $other_controls if ch_female == 1 [aw=ch_SAMPWT_1979]
eststo m3f: margins, dydx("expo515_marriedbread") predict(outcome(3)) post

oprobit FAM_ATT___MEN_SHOULD_SHARE_HOUSE expo15_lnfaminc expo15_sd_faminc $regressors515 ROSENBERG_SCORE_1980_1979 Att_Index_1979 expo15_hgc $other_controls if ch_female == 1 [aw=ch_SAMPWT_1979]
eststo m2f: margins, dydx("expo515_marriedbread") predict(outcome(2)) post

oprobit FAM_ATT___MEN_SHOULD_SHARE_HOUSE expo15_lnfaminc expo15_sd_faminc $regressors515 ROSENBERG_SCORE_1980_1979 Att_Index_1979 expo15_hgc $other_controls if ch_female == 1 [aw=ch_SAMPWT_1979]
eststo m1f: margins, dydx("expo515_marriedbread") predict(outcome(1)) post


* male marginal effects
oprobit FAM_ATT___MEN_SHOULD_SHARE_HOUSE expo15_lnfaminc expo15_sd_faminc $regressors515 ROSENBERG_SCORE_1980_1979 Att_Index_1979 expo15_hgc $other_controls if ch_female == 0 [aw=ch_SAMPWT_1979]
eststo m4m: margins, dydx("expo515_marriedbread") predict(outcome(4)) post 

oprobit FAM_ATT___MEN_SHOULD_SHARE_HOUSE expo15_lnfaminc expo15_sd_faminc $regressors515 ROSENBERG_SCORE_1980_1979 Att_Index_1979 expo15_hgc $other_controls if ch_female == 0 [aw=ch_SAMPWT_1979]
eststo m3m: margins, dydx("expo515_marriedbread") predict(outcome(3)) post

oprobit FAM_ATT___MEN_SHOULD_SHARE_HOUSE expo15_lnfaminc expo15_sd_faminc $regressors515 ROSENBERG_SCORE_1980_1979 Att_Index_1979 expo15_hgc $other_controls if ch_female == 0 [aw=ch_SAMPWT_1979]
eststo m2m: margins, dydx("expo515_marriedbread") predict(outcome(2)) post

oprobit FAM_ATT___MEN_SHOULD_SHARE_HOUSE expo15_lnfaminc expo15_sd_faminc $regressors515 ROSENBERG_SCORE_1980_1979 Att_Index_1979 expo15_hgc $other_controls if ch_female == 0 [aw=ch_SAMPWT_1979]

eststo m1m: margins, dydx("expo515_marriedbread") predict(outcome(1)) post

* construction of marginal effects table
esttab m1f m2f m3f m4f m1m m2m m3m m4m using "${tables}table_orm_mfx_modif.rtf", ///
mgroups("Mfx Gender-role Atttiudes women" "Mfx Gender-role Attitudes Men", pattern(1 0 0 0 1 0 0 0)) ///
mlabels("strongly disagree" "disagree" "agree" "strongly agree" "strongly disagree" "disagree" "agree" "strongly agree") ///
noobs nonumber se label compress varwidth(10) replace




 