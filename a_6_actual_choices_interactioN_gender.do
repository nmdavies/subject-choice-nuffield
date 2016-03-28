//Neil Davies 10/06/14
//This estimates the change in students actually taking subjects


use  "working data/imputed_dataset_labour_market_knowledge2_actual_choices",clear
//First produce table of actual choices

tabstat *choice if _mi_m==0 & intervgp==1 & physics_ac!=.,stats(N  mean)  c(s)
tabstat *choice if _mi_m==0 & intervgp==0& physics_ac!=.,stats(N  mean)  c(s)


mi passive:gen salforuni2=(uni_mot_salary==1|uni_mot_salary==2) if uni_mot_salary!=.

mi passive:gen uni_1=(university_plans==1|university_plans==1.5) if university_plans!=.
mi passive:gen uni_2=(university_plans==2|university_plans==2.5) if university_plans!=.
mi passive:gen uni_3=(university_plans==3) if university_plans!=.
mi passive:gen uni_4=(university_plans==4) if university_plans!=.

replace studybiology2=2 if studybiology2==1.5
replace studybusiness2=2 if studybusiness2==4.5

rename Xart_act_choice art_act_choice
rename Xmaths_act_choice maths_act_choice

mi passive: gen male_int=male*intervgp


drop if inlist(_mi_id,1374,1837,2288,2327)

//imputed

foreach i in  art biology  business chemistry computing design economics english geography history languages maths media music physics psychology{
	mi est:logistic `i'_act_choice intervgp male_int male,ro cluster(schoolno) or
	regsave intervgp male_int using "results/graduate_exp/GENDER_INT_intervention_effect_act_choice_`i'",replace pval detail(all) ci coefmat(e(b_mi)) varmat(e(V_mi))
	mi est:logistic `i'_act_choice study`i' intervgp male_int ks3_mattalev ks3_scitalev ks3_engtalev maths_exp_GCSE_pts eng_exp_GCSE_pts male fsmeligible_spr12,ro cluster(schoolno) or
	regsave intervgp male_int using "results/graduate_exp/GENDER_INT_intervention_effect_act_choice_`i'_adj",replace pval detail(all) ci coefmat(e(b_mi)) varmat(e(V_mi))
	}
	

//Clean the results:

use "results/graduate_exp/GENDER_INT_intervention_effect_act_choice_art",clear
foreach i in biology  business chemistry computing design economics english geography history languages maths media music physics psychology{
	append using "results/graduate_exp/GENDER_INT_intervention_effect_act_choice_`i'",
	}
	
gen or=exp(coef)
gen or_ul=exp(ci_upper)
gen or_ll=exp(ci_lower)
		
order depvar N or  or_ll or_ul pval
sort depvar	

use "results/graduate_exp/CC_intervention_effect_act_choice_art_adj",clear
foreach i in biology  business chemistry computing design economics english geography history languages maths media music physics psychology{
	append using "results/graduate_exp/CC_intervention_effect_act_choice_`i'_adj",
	}
	
gen or=exp(coef)
gen or_ul=exp(ci_upper)
gen or_ll=exp(ci_lower)
		
order depvar N or or_ll or_ul pval
sort depvar	

use "results/graduate_exp/CC_intervention_effect_act_choice_art",clear
foreach i in biology  business chemistry computing design economics english geography history languages maths media music physics psychology{
	append using "results/graduate_exp/CC_intervention_effect_act_choice_`i'",
	}
	
gen or=exp(coef)
gen or_ul=exp(ci_upper)
gen or_ll=exp(ci_lower)
		
order depvar N or  or_ll or_ul pval
sort depvar	

use "results/graduate_exp/CC_intervention_effect_act_choice_art_adj",clear
foreach i in biology  business chemistry computing design economics english geography history languages maths media music physics psychology{
	append using "results/graduate_exp/CC_intervention_effect_act_choice_`i'_adj",
	}
	
gen or=exp(coef)
gen or_ul=exp(ci_upper)
gen or_ll=exp(ci_lower)
		
order depvar N or or_ll or_ul pval
sort depvar	
