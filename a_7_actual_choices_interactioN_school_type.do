//Neil Davies 10/06/14
//This estimates the change in students actually taking subjects

use  "working data/imputed_dataset_labour_market_knowledge2_actual_choices",clear
//Next need to run the logistic regressions:

rename Xart_act_choice art_act_choice
rename Xmaths_act_choice maths_act_choice

mi passive: gen stapri_int=stapri*intervgp

foreach i in ks3_mattalev ks3_scitalev ks3_engtalev maths_exp_GCSE_pts eng_exp_GCSE_pts male fsmeligible_spr12{
	mi passive: gen `i'_int=stapri*intervgp
	}

drop if inlist(_mi_id,1374,1837,2288,2327)

//imputed

foreach i in   art biology  business chemistry computing design economics english geography history languages maths media /* music physics psychology*/{
	mi est:logistic `i'_act_choice intervgp stapri_int stapri,ro cluster(schoolno) or
	//regsave intervgp stapri_int using "results/graduate_exp/STAPRI_INT_intervention_effect_act_choice_`i'",replace pval detail(all) ci coefmat(e(b_mi)) varmat(e(V_mi))
	}
	
foreach i in  art biology  business chemistry computing design economics english geography history languages maths media music physics psychology{	
	mi est:logistic `i'_act_choice study`i' intervgp stapri stapri_int ks3_mattalev ks3_scitalev ks3_engtalev maths_exp_GCSE_pts eng_exp_GCSE_pts male fsmeligible_spr12,ro cluster(schoolno) or
	regsave intervgp stapri_int using "results/graduate_exp/STAPRI_INT_intervention_effect_act_choice_`i'_adj",replace pval detail(all) ci coefmat(e(b_mi)) varmat(e(V_mi))
	}
	

	
//Clean the results:

use "results/graduate_exp/STAPRI_INT_intervention_effect_act_choice_art",clear
foreach i in biology  business chemistry computing design economics english geography history languages maths media music physics psychology{
	append using "results/graduate_exp/STAPRI_INT_intervention_effect_act_choice_`i'",
	}
	
gen or=exp(coef)
gen or_ul=exp(ci_upper)
gen or_ll=exp(ci_lower)
		
order depvar N or  or_ll or_ul pval
sort depvar	


use "results/graduate_exp/STAPRI_INT_intervention_effect_act_choice_art_adj",clear
foreach i in biology  business chemistry computing design economics english geography history languages maths media music physics psychology{
	append using "results/graduate_exp/STAPRI_INT_intervention_effect_act_choice_`i'_adj",
	}
	
gen or=exp(coef)
gen or_ul=exp(ci_upper)
gen or_ll=exp(ci_lower)
		
order depvar N or  or_ll or_ul pval
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
