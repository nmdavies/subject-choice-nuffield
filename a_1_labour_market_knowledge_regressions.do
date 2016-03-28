//Neil Davies 27/08/13
//This does the imputation for the intervention paper (labour market knowledge).

cd "H:\CMPO\Income expectations RCT\"

use  "working data/imputed_dataset_labour_market_knowledge2",clear

//Regenerate salary important variable
mi passive: gen salforuni2=(importantc<3) if importantc!=.

mi passive:gen uni_1=(university==1|university==1.5) if university!=.
mi passive:gen uni_2=(university==2|university==2.5) if university!=.
mi passive:gen uni_3=(university==3) if university!=.
mi passive:gen uni_4=(university==4) if university!=.

mi passive:gen def_poss_intend_uni=(university==1|university==2) if university!=.
mi passive:gen def_intend_uni=(university==1) if university!=.

mi passive:gen sal_import=(importantc==1|importantc==2) if importantc!=.

mi passive:gen high_brow2=29-highbrow
mi passive:gen parent_sch_int2=16-parent_sch_int 
mi passive:gen current_affairs2=16-current_affairs 


mi estimate, cmdok   : mean male maths_exp_GCSE_pts eng_exp_GCSE_pts stapri white if male!=.
mi estimate, cmdok   : mean profdad profmum profyou fatheruni1 motheruni1 fsmeligible_spr12 salforuni2 uni_1 uni_2 uni_3 uni_4 if male!=.

sum male maths_exp_GCSE_pts eng_exp_GCSE_pts stapri white if male!=.
sum profdad profmum profyou fatheruni1 motheruni1 fsmeligible_spr12 salforuni2 uni_1 uni_2 uni_3 uni_4 if male!=.

tab ethnicity if male!=.,gen(eth_) sort

//Repeat but split by allocation to treatment:

preserve
keep if intervgp==1
mi estimate, cmdok   : mean male maths_exp_GCSE_pts eng_exp_GCSE_pts stapri white if male!=.
mi estimate, cmdok   : mean profdad profmum profyou fatheruni1 motheruni1 fsmeligible_spr12 salforuni2 uni_1 uni_2 uni_3 uni_4 if male!=.

sum male maths_exp_GCSE_pts eng_exp_GCSE_pts stapri white if male!=.
sum profdad profmum profyou fatheruni1 motheruni1 fsmeligible_spr12 salforuni2 uni_1 uni_2 uni_3 uni_4 if male!=.

tab ethnicity if male!=., sort

restore 
preserve
keep if intervgp==0

mi estimate, cmdok   : mean male maths_exp_GCSE_pts eng_exp_GCSE_pts stapri white if male!=.
mi estimate, cmdok   : mean profdad profmum profyou fatheruni1 motheruni1 fsmeligible_spr12 salforuni2 uni_1 uni_2 uni_3 uni_4 if male!=.

sum male maths_exp_GCSE_pts eng_exp_GCSE_pts stapri white if male!=.
sum profdad profmum profyou fatheruni1 motheruni1 fsmeligible_spr12 salforuni2 uni_1 uni_2 uni_3 uni_4 if male!=.

tab ethnicity if male!=.,sort

restore

//Finally test whether there are any differences between treatment and control

foreach i in male maths_exp_GCSE_pts eng_exp_GCSE_pts stapri white profdad profmum profyou fatheruni1 motheruni1 fsmeligible_spr12 salforuni2 uni_1 uni_2 uni_3 uni_4 {
	mi est:reg `i' intervgp if male!=.,cluster(schoolno)
	regsave intervgp using "results/graduate_exp/balance_test_av_`i'",replace pval detail(all) ci coefmat(e(b_mi)) varmat(e(V_mi))
	}

foreach i in male maths_exp_GCSE_pts eng_exp_GCSE_pts stapri white profdad profmum profyou fatheruni1 motheruni1 fsmeligible_spr12 salforuni2 uni_1 uni_2 uni_3 uni_4 {
	reg `i' intervgp if male!=.,cluster(schoolno)
	regsave intervgp using "results/graduate_exp/balance_test_av_`i'_no_MI",replace pval detail(all) ci 
	}	

preserve

use 	"results/graduate_exp/balance_test_av_male",clear
foreach i in  maths_exp_GCSE_pts eng_exp_GCSE_pts stapri white profdad profmum profyou fatheruni1 motheruni1 fsmeligible_spr12 salforuni2 uni_1 uni_2 uni_3 uni_4 {
	append using "results/graduate_exp/balance_test_av_`i'"
	}
order depvar
//Estimate the students priors

mi estimate, cmdok   : mean *av if male!=.
mi estimate, cmdok   : mean arth businessh educationh engineeringh historyh languagesh lawh mathsh physicsh medicineh politicsh if male!=.
mi estimate, cmdok   : mean artl businessl educationl engineeringl historyl languagesl lawl mathsl physicsl medicinel politicsl if male!=.
order *me
mi estimate, cmdok   : mean artme- medicineme if male!=.

sum *av if male!=.
sum arth businessh educationh engineeringh historyh languagesh lawh mathsh physicsh medicineh politicsh if male!=.
sum *l if male!=.
sum *me if male!=.

//Estimate the students posterior

mi estimate, cmdok   : mean artav2 businessav2 educationav2 engineeringav2 historyav2 languagesav2 lawav2 mathsav2 physicsav2 medicineav2 politicsav2 if male!=.
mi estimate, cmdok   : mean arth2 businessh2 educationh2 engineeringh2 historyh2 languagesh2 lawh2 mathsh2  physicsh2 medicineh2 politicsh2 if male!=.
mi estimate, cmdok   : mean artl2 businessl2 educationl2 engineeringl2 historyl2 languagesl2 lawl2 mathsl2  physicsl2 medicinel2 politicsl2 if male!=.
mi estimate, cmdok   : mean artme2 businessme2 educationme2 engineeringme2 historyme2 languagesme2 lawme2 mathsme2 physicsme2 medicineme2 politicsme2 if male!=.

sum *av2 if male!=.
sum arth2 businessh2 educationh2 engineeringh2 historyh2 languagesh2 lawh2 mathsh2 physicsh2 medicineh2 politicsh2 if male!=.
sum *l2 if male!=.
sum *me2 if male!=.

//imputed
foreach i in art business education engineering history languages law maths politics physics medicine {
	mi estimate, cmdok   : reg  `i'me2 `i'me intervgp if male!=.,cluster(schoolno) 
	regsave intervgp using "results/graduate_exp/intervention_effect_`i'",replace pval detail(all) ci coefmat(e(b_mi)) varmat(e(V_mi))
	mi estimate, cmdok   : reg  `i'av2 `i'av intervgp if male!=.,cluster(schoolno) 
	regsave intervgp using "results/graduate_exp/intervention_effect_av_`i'",replace pval detail(all) ci coefmat(e(b_mi)) varmat(e(V_mi))
	}
	
//complete case
foreach i in art business education engineering history languages law maths politics physics medicine {	
	reg  `i'me2 `i'me intervgp if male!=.,cluster(schoolno) 
	regsave intervgp using "results/graduate_exp/CC_intervention_effect_`i'",replace pval detail(all) ci 
	reg  `i'av2 `i'av intervgp if male!=.,cluster(schoolno) 
	regsave intervgp using "results/graduate_exp/CC_intervention_effect_av_`i'",replace pval detail(all) ci 
	}
	
//Interaction with wanting to take the subject
//imputed
foreach i in  art business history languages maths physics  {
	mi passive:gen intend_`i'=(study`i'>3) if study`i'!=.
	mi passive:gen Interact_int_`i'=intend_`i'*intervgp if study`i'!=.
	
	mi estimate, cmdok   : reg  `i'me2 `i'me intervgp Interact_int_`i' intend_`i' if male!=.,cluster(schoolno) 
	regsave `i'me intervgp Interact_int_`i' using "results/graduate_exp/INTERACTION_intervention_effect_`i'",replace pval detail(all) ci coefmat(e(b_mi)) varmat(e(V_mi))

	}
	
//complete case
foreach i in art business history languages maths physics {	
	reg  `i'me2 `i'me intervgp  Interact_int_`i' intend_`i' if male!=.,cluster(schoolno) 
	regsave intervgp using "results/graduate_exp/CC_INTERACTION_intervention_effect_`i'",replace pval detail(all) ci 
	reg  `i'av2 `i'av intervgp  Interact_int_`i' intend_`i' if male!=.,cluster(schoolno) 
	regsave intervgp using "results/graduate_exp/CC_INTERACTION_intervention_effect_av_`i'",replace pval detail(all) ci 
	}
	
	
	

//Change in intention to study subject:
//Binary
foreach i in art biology business chemistry computing design economics english geography history languages  maths media music pe physics psychology travel{
	cap:mi passive:gen intend_`i'=(study`i'>3) if study`i'!=.
	cap:mi passive:gen intend2_`i'=(study`i'2>3) if study`i'!=.
	
	mi estimate, cmdok   : logistic  intend2_`i' intend_`i' intervgp if male!=.,cluster(schoolno) or
	regsave intervgp using "results/graduate_exp/Intend_study_`i'",replace pval detail(all) ci coefmat(e(b_mi)) varmat(e(V_mi))
	mi estimate, cmdok   : logistic  intend2_`i' intend_`i' intervgp male maths_exp_GCSE_pts eng_exp_GCSE_pts stapri white profdad profmum profyou ///
	   fatheruni1 motheruni1 fsmeligible_spr12 salforuni2 uni_1 uni_2 uni_3 uni_4  if male!=.,cluster(schoolno)  or
	regsave  using "results/graduate_exp/Intend_study_`i'_adj",replace pval detail(all) ci coefmat(e(b_mi)) varmat(e(V_mi))
	
	logistic  intend2_`i' intend_`i' intervgp if male!=.,cluster(schoolno)  or
	regsave intervgp using "results/graduate_exp/CC_Intend_study_`i'",replace pval detail(all) ci 
	logistic  intend2_`i' intend_`i' intervgp male maths_exp_GCSE_pts eng_exp_GCSE_pts stapri white profdad profmum profyou ///
	   fatheruni1 motheruni1 fsmeligible_spr12 salforuni2 uni_1 uni_2 uni_3 uni_4  if male!=.,cluster(schoolno)  or
	regsave  using "results/graduate_exp/CC_Intend_study_`i'_adj",replace pval detail(all) ci 
	}
	
foreach i in  art biology business chemistry computing design economics english geography history languages  maths media music pe physics psychology travel{
	forvalues j=1(1)20{
		replace _`j'_study`i'2=2 if _`j'_study`i'2==1.5
		replace _`j'_study`i'2=3 if _`j'_study`i'2==2.5
		replace _`j'_study`i'2=4 if _`j'_study`i'2==3.5
		replace _`j'_study`i'2=5 if _`j'_study`i'2==4.5

		replace study`i'2=2 if study`i'2==1.5
		replace study`i'2=3 if study`i'2==2.5
		replace study`i'2=4 if study`i'2==3.5
		replace study`i'2=5 if study`i'2==4.5
		
		}
	}
//Mlogit:
foreach i in  art  biology business chemistry computing design economics english geography history languages  maths  media music pe physics psychology travel{
	
	mi estimate, cmdok   : mlogit  study`i'2 study`i' intervgp ,cluster(schoolno) rrr b(1)
	regsave intervgp using "results/graduate_exp/MLOGIT_Intend_study_`i'",replace pval detail(all) ci coefmat(e(b_mi)) varmat(e(V_mi))
	mi estimate, cmdok   : mlogit  study`i'2 study`i'  intervgp male maths_exp_GCSE_pts eng_exp_GCSE_pts stapri white profdad profmum profyou ///
	   fatheruni1 motheruni1 fsmeligible_spr12 uni_mot_salary uni_1 uni_2 uni_3 uni_4  ,cluster(schoolno) rrr b(1)
	regsave  using "results/graduate_exp/MLOGIT_Intend_study_`i'_adj",replace pval detail(all) ci coefmat(e(b_mi)) varmat(e(V_mi))
	
	mlogit  study`i'2 study`i'  intervgp if _mi_m==0,cluster(schoolno)  rrr b(1)
	regsave intervgp using "results/graduate_exp/CC_MLOGIT_Intend_study_`i'",replace pval detail(all) ci 
	mlogit  study`i'2 study`i'  intervgp male maths_exp_GCSE_pts eng_exp_GCSE_pts stapri white profdad profmum profyou ///
	   fatheruni1 motheruni1 fsmeligible_spr12 salforuni2 uni_1 uni_2 uni_3 uni_4 if _mi_m==0,cluster(schoolno)  rrr b(1)
	regsave  using "results/graduate_exp/CC_MLOGIT_Intend_study_`i'_adj",replace pval detail(all) ci 
	}
	
	
//regression:
foreach i in  art biology business chemistry computing design economics english geography history languages  maths media music pe physics psychology travel{
	mi estimate, cmdok   : reg  study`i'2 study`i' intervgp if male!=.,cluster(schoolno) 
	regsave intervgp using "results/graduate_exp/REG_Intend_study_`i'",replace pval detail(all) ci coefmat(e(b_mi)) varmat(e(V_mi))
	mi estimate, cmdok   : reg  study`i'2 study`i'  intervgp male maths_exp_GCSE_pts eng_exp_GCSE_pts stapri white profdad profmum profyou ///
	  fatheruni1 motheruni1 fsmeligible_spr12 sal_import  uni_2 uni_3 uni_4  if male!=.,cluster(schoolno) 
	regsave  using "results/graduate_exp/REG_Intend_study_`i'_adj",replace pval detail(all) ci coefmat(e(b_mi)) varmat(e(V_mi))
	
	reg  study`i'2 study`i'  intervgp if male!=.,cluster(schoolno)  
	regsave intervgp using "results/graduate_exp/CC_REG_Intend_study_`i'",replace pval detail(all) ci 
	reg  study`i'2 study`i'  intervgp male maths_exp_GCSE_pts eng_exp_GCSE_pts stapri white profdad profmum profyou ///
	   fatheruni1 motheruni1 fsmeligible_spr12 sal_import  uni_2 uni_3 uni_4  if male!=.,cluster(schoolno)  
	regsave  using "results/graduate_exp/CC_REG_Intend_study_`i'_adj",replace pval detail(all) ci 
	}
		
	
//Cleaning results:

use "results/graduate_exp/intervention_effect_art",clear
foreach i in business education engineering history languages law maths politics physics medicine {
	append using "results/graduate_exp/intervention_effect_`i'",
	}
	
order depvar coef ci_lower ci_upper pval
sort depvar

use "results/graduate_exp/intervention_effect_av_art",clear
foreach i in business education engineering history languages law maths politics physics medicine {
	append using "results/graduate_exp/intervention_effect_av_`i'",
	}
	
order depvar coef ci_lower ci_upper pval
sort depvar

use "results/graduate_exp/CC_intervention_effect_av_art",clear
foreach i in business education engineering history languages law maths politics physics medicine {
	append using "results/graduate_exp/CC_intervention_effect_av_`i'",
	}
	
order depvar N coef ci_lower ci_upper pval
sort depvar

use "results/graduate_exp/CC_intervention_effect_art",clear
foreach i in business education engineering history languages law maths politics physics medicine {
	append using "results/graduate_exp/CC_intervention_effect_`i'",
	}
	
order depvar N coef ci_lower ci_upper pval
sort depvar

use "results/graduate_exp/Intend_study_art",clear
foreach i in biology business chemistry computing design economics english geography history languages  maths media music pe physics psychology travel{
	append using "results/graduate_exp/Intend_study_`i'",
	}
	
gen or=exp(coef)
gen or_ul=exp(ci_upper)
gen or_ll=exp(ci_lower)
		
order depvar N or or_ul or_ll pval
sort depvar

use "results/graduate_exp/CC_Intend_study_art",clear
foreach i in biology business chemistry computing design economics english geography history languages  maths media music pe physics psychology travel{
	append using "results/graduate_exp/CC_Intend_study_`i'",
	}
gen or=exp(coef)
gen or_ul=exp(ci_upper)
gen or_ll=exp(ci_lower)
		
order depvar N or or_ul or_ll pval
sort depvar

//MLOGOT regressions

use "results/graduate_exp/MLOGIT_Intend_study_art",clear
local N=_N+1
set obs `N'
foreach i in biology business chemistry computing design economics english geography history languages  maths media music pe physics psychology travel{
	append using "results/graduate_exp/MLOGIT_Intend_study_`i'",
	local N=_N+1
	set obs `N'
	replace depvar="study`i'2" if depvar==""
	}
	
gen or=exp(coef)
gen or_ul=exp(ci_upper)
gen or_ll=exp(ci_lower)
	
order depvar N or or_ul or_ll pval
sort depvar

use "results/graduate_exp/CC_MLOGIT_Intend_study_art",clear
local N=_N+1
set obs `N'
replace depvar="studyart2" if depvar==""
foreach i in biology business chemistry computing design economics english geography history languages  maths media music pe physics psychology travel{
	append using "results/graduate_exp/CC_MLOGIT_Intend_study_`i'",
	local N=_N+1
	set obs `N'
	replace depvar="study`i'2" if depvar==""
	}
gen or=exp(coef)
gen or_ul=exp(ci_upper)
gen or_ll=exp(ci_lower)
	
order depvar N or or_ul or_ll pval
sort depvar	

//MLOGOT regressions - adjusted

use "results/graduate_exp/MLOGIT_Intend_study_art_adj",clear
local N=_N+1
set obs `N'
replace depvar="studyart2" if depvar==""
foreach i in biology business chemistry computing design economics english geography history languages  maths media music pe physics psychology travel{
	append using "results/graduate_exp/MLOGIT_Intend_study_`i'_adj",
	local N=_N+1
	set obs `N'
	replace depvar="study`i'2" if depvar==""
	}
	
gen or=exp(coef)
gen or_ul=exp(ci_upper)
gen or_ll=exp(ci_lower)
	
order depvar N or or_ul or_ll pval
sort depvar

keep if substr(var,-8,8)=="intervgp"|var==""

use "results/graduate_exp/CC_MLOGIT_Intend_study_art_adj",clear
local N=_N+1
set obs `N'
replace depvar="studyart2" if depvar==""
foreach i in biology business chemistry computing design economics english geography history languages  maths media music pe physics psychology travel{
	append using "results/graduate_exp/CC_MLOGIT_Intend_study_`i'_adj",
	local N=_N+1
	set obs `N'
	replace depvar="study`i'2" if depvar==""
	}
	
gen or=exp(coef)
gen or_ul=exp(ci_upper)
gen or_ll=exp(ci_lower)
	
order depvar N or or_ul or_ll pval
sort depvar

keep if substr(var,-8,8)=="intervgp"|var==""

//Regressions
use "results/graduate_exp/REG_Intend_study_art",clear
foreach i in biology business chemistry computing design economics english geography history languages  maths media music pe physics psychology travel{
	append using "results/graduate_exp/REG_Intend_study_`i'",
	}
	
order depvar N coef ci_lower ci_upper pval
sort depvar

use "results/graduate_exp/CC_REG_Intend_study_art",clear
foreach i in biology business chemistry computing design economics english geography history languages  maths media music pe physics psychology travel{
	append using "results/graduate_exp/CC_REG_Intend_study_`i'",
	}
	
order depvar N coef ci_lower ci_upper pval
sort depvar

//Regressions on interaction of effect of intervention on beliefs of those intending on taking a subject
use "results/graduate_exp/INTERACTION_intervention_effect_art",clear
foreach i in   business history languages maths physics {
	append using "results/graduate_exp/INTERACTION_intervention_effect_`i'",
	}
drop if substr(var,-2,2)=="me"
order depvar var coef ci_lower ci_upper pval 
