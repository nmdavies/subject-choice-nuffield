//Neil Davies 27/08/13
//This does the imputation for the intervention paper (labour market knowledge).

cd "H:\CMPO\Income expectations RCT\"

use "working data/imputed_dataset_labour_market_knowledge_MI_format",clear

//Need to identify schools with no actual A-level choices:

egen N_choice=rowtotal(X*)
bys schoolno _mi_m:egen total_choice=total(N_choice)

tab schoolno if total_choice==0 & _mi_m==0

//There are four schools in total with no A-level results IDs 3 ,8, 24 and 42.

//Need to rename actual choices to fit with the priors

rename Xart_act_choice art_act_choice
rename Xbio_act_choice biology_act_choice
rename Xbs_act_choice business_act_choice
rename Xchem_act_choice chemistry_act_choice
rename Xcomp_act_choice computing_act_choice
rename Xdt_act_choice design_act_choice
rename Xecon_act_choice economics_act_choice
rename Xeng_act_choice english_act_choice
rename Xgeog_act_choice geography_act_choice
rename Xhist_act_choice history_act_choice
rename Xmfl_act_choice languages_act_choice
rename Xmaths_act_choice maths_act_choice
rename Xmed_stud_act_choice media_act_choice
rename Xmus_act_choice music_act_choice
rename Xphys_act_choice physics_act_choice
rename Xpsycho_actual_choice psychology_act_choice

compress
save "working data/imputed_dataset_labour_market_knowledge2_actual_choices",replace
use  "working data/imputed_dataset_labour_market_knowledge2_actual_choices",clear
//Next need to run the logistic regressions:
drop if inlist(_mi_id,1374,1837,2288,2327)
foreach i in  art biology  business chemistry computing design economics english geography history languages maths media music physics psychology{
	mi est:logistic `i'_act_choice intervgp ,ro cluster(schoolno) or
	regsave intervgp using "results/graduate_exp/intervention_effect_act_choice_`i'",replace pval detail(all) ci coefmat(e(b_mi)) varmat(e(V_mi))
	mi est:logistic `i'_act_choice study`i' intervgp ks3_mattalev ks3_scitalev ks3_engtalev maths_exp_GCSE_pts eng_exp_GCSE_pts male fsmeligible_spr12,ro cluster(schoolno) or
	regsave intervgp using "results/graduate_exp/intervention_effect_act_choice_`i'_adj",replace pval detail(all) ci coefmat(e(b_mi)) varmat(e(V_mi))
	}

//restricted to individuals who chose any subjects:

//Need to identify individuals who had no choices in the original data

gen stay_on=(N_choice!=0) if _mi_m==0
bys student_id:egen STAY_ON=max(stay_on)

foreach i in /* art biology  business chemistry computing design economics english geography history languages  maths media music physics */ psychology{
	mi est:logistic `i'_act_choice intervgp if STAY_ON==1,ro cluster(schoolno) or
	regsave intervgp using "results/graduate_exp/intervention_effect_STAY_ON_act_choice_`i'",replace pval detail(all) ci coefmat(e(b_mi)) varmat(e(V_mi))
	mi est:logistic `i'_act_choice study`i' intervgp ks3_mattalev ks3_scitalev ks3_engtalev maths_exp_GCSE_pts eng_exp_GCSE_pts male fsmeligible_spr12 if STAY_ON==1,ro cluster(schoolno) or
	regsave intervgp using "results/graduate_exp/intervention_effect_STAY_ON_act_choice_`i'_adj",replace pval detail(all) ci coefmat(e(b_mi)) varmat(e(V_mi))
	}

//Cleaning the results:

use "results/graduate_exp/intervention_effect_act_choice_art",clear
foreach i in biology  business chemistry computing design economics english geography history languages maths media music physics psychology{
	append using "results/graduate_exp/intervention_effect_act_choice_`i'",
	}
	
gen or=exp(coef)
gen or_ul=exp(ci_upper)
gen or_ll=exp(ci_lower)
		
order depvar N or  or_ll or_ul pval
sort depvar	

use "results/graduate_exp/intervention_effect_act_choice_art_adj",clear
foreach i in biology  business chemistry computing design economics english geography history languages maths media music physics psychology{
	append using "results/graduate_exp/intervention_effect_act_choice_`i'_adj",
	}
	
gen or=exp(coef)
gen or_ul=exp(ci_upper)
gen or_ll=exp(ci_lower)
		
order depvar N or or_ll or_ul pval
sort depvar	

use "results/graduate_exp/intervention_effect_STAY_ON_act_choice_art",clear
foreach i in biology  business chemistry computing design economics english geography history languages maths media music physics psychology{
	append using "results/graduate_exp/intervention_effect_STAY_ON_act_choice_`i'",
	}
	
gen or=exp(coef)
gen or_ul=exp(ci_upper)
gen or_ll=exp(ci_lower)
		
order depvar N or or_ll or_ul pval
sort depvar	

use "results/graduate_exp/intervention_effect_STAY_ON_act_choice_art_adj",clear
foreach i in biology  business chemistry computing design economics english geography history languages maths media music physics psychology{
	append using "results/graduate_exp/intervention_effect_STAY_ON_act_choice_`i'_adj",
	}
	
gen or=exp(coef)
gen or_ul=exp(ci_upper)
gen or_ll=exp(ci_lower)
		
order depvar N or or_ll or_ul pval
sort depvar	
