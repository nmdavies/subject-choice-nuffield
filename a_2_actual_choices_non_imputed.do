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

destring id, replace force
drop if id==.
duplicates drop id, force
mi merge 1:1 id using "working data/actual_choices", gen(XX)

//Need to drop schools with no actual A-level choices:

egen N_choice=rowtotal(*choice*)
bys schoolno:egen total_choice=total(N_choice)

tab schoolno if total_choice==0
drop if total_choice==0

//We drop seven schools in total with no A-level results.

//drop students with no gender data
drop if male==.

//Need to rename actual choices to fit with the priors

rename bio_act_choice biology_act_choice
rename bs_act_choice business_act_choice
rename chem_act_choice chemistry_act_choice
rename comp_act_choice computing_act_choice
rename dt_act_choice design_act_choice
rename econ_act_choice economics_act_choice
rename eng_act_choice english_act_choice
rename geog_act_choice geography_act_choice
rename hist_act_choice history_act_choice
rename mfl_act_choice languages_act_choice
rename med_stud_act_choice media_act_choice
rename mus_act_choice music_act_choice
rename phys_act_choice physics_act_choice

compress
save "working data/imputed_dataset_labour_market_knowledge2_actual_choices",replace

//Next need to run the logistic regressions:
 gen stay_on=(N_choice !=0)
foreach i in  art biology  business chemistry computing design economics  english geography history languages maths media music physics{
	logistic `i'_act_choice intervgp ,ro cluster(schoolno) or
	regsave intervgp using "results/graduate_exp/Non_impute_intervention_effect_act_choice_`i'",replace pval detail(all) ci 
	logistic `i'_act_choice study`i' intervgp ks3_mattalev ks3_scitalev ks3_engtalev maths_exp_GCSE_pts eng_exp_GCSE_pts male,ro cluster(schoolno) or
	regsave intervgp using "results/graduate_exp/Non_impute_intervention_effect_act_choice_`i'_adj",replace pval detail(all) ci 
	}

//restricted to individuals who chose any subjects:

foreach i in  art biology  business chemistry computing design economics english geography history languages maths media music physics{
	logistic `i'_act_choice intervgp if stay_on==1,ro cluster(schoolno) or
	regsave intervgp using "results/graduate_exp/Non_impute_intervention_effect_STAY_ON_act_choice_`i'",replace pval detail(all) ci 
	logistic `i'_act_choice study`i' intervgp ks3_mattalev ks3_scitalev ks3_engtalev maths_exp_GCSE_pts eng_exp_GCSE_pts male  if stay_on==1,ro cluster(schoolno) or
	regsave intervgp using "results/graduate_exp/Non_impute_intervention_effect_STAY_ON_act_choice_`i'_adj",replace pval detail(all) ci 
	}

//Cleaning the results:

use "results/graduate_exp/Non_impute_intervention_effect_act_choice_art",clear
foreach i in biology  business chemistry computing design economics english geography history language maths media music physics{
	append using "results/graduate_exp/Non_impute_intervention_effect_act_choice_`i'",
	}
	
gen or=exp(coef)
gen or_ul=exp(ci_upper)
gen or_ll=exp(ci_lower)
		
order depvar N or  or_ll or_ul pval
sort depvar	

use "results/graduate_exp/Non_impute_intervention_effect_act_choice_art_adj",clear
foreach i in biology  business chemistry computing design economics english geography history languages maths media music physics{
	append using "results/graduate_exp/Non_impute_intervention_effect_act_choice_`i'_adj",
	}
	
gen or=exp(coef)
gen or_ul=exp(ci_upper)
gen or_ll=exp(ci_lower)
		
order depvar N or  or_ll or_ul pval
sort depvar	

use "results/graduate_exp/Non_impute_intervention_effect_STAY_ON_act_choice_art",clear
foreach i in biology  business chemistry computing design economics english geography history languages maths media music physics{
	append using "results/graduate_exp/Non_impute_intervention_effect_STAY_ON_act_choice_`i'",
	}
	
gen or=exp(coef)
gen or_ul=exp(ci_upper)
gen or_ll=exp(ci_lower)
		
order depvar N or  or_ll or_ul pval
sort depvar	

use "results/graduate_exp/Non_impute_intervention_effect_STAY_ON_act_choice_art_adj",clear
foreach i in biology  business chemistry computing design economics english geography history languages maths media music physics{
	append using "results/graduate_exp/Non_impute_intervention_effect_STAY_ON_act_choice_`i'_adj",
	}
	
gen or=exp(coef)
gen or_ul=exp(ci_upper)
gen or_ll=exp(ci_lower)
		
order depvar N or  or_ll or_ul pval
sort depvar	

//Finally generate figure 2

use "working data/imputed_dataset_labour_market_knowledge2_actual_choices",clear

tabstat  *choice* if intervgp==1,c(s) stats(N mean sum)
tabstat  *choice* if intervgp==0,c(s) stats(N mean sum)

