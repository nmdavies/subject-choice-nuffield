//Neil Davies 29/10/14
//This runs the permutation analysis to extract the critical values for the main results in the infomation RCT paper

cd "H:\CMPO\Income expectations RCT\"

use  "working data/imputed_dataset_labour_market_knowledge2_actual_choices",clear


//Generate the permuation dataset
keep student_id *_act_choice study* intervgp ks3_mattalev ks3_scitalev ks3_engtalev maths_exp_GCSE_pts eng_exp_GCSE_pts male fsmeligible_spr12 schoolno _mi_m  _mi_id _mi_miss
drop if inlist(_mi_id,1374,1837,2288,2327)

save "working data/temp",replace

keep student_id *_act_choice _mi_m

save "working data/temp_choices",replace

keep student_id
duplicates drop
gen n=_n
save "working data/temp_studentids",replace

//seed can be 1-2147483647
//If you want to generate integer random numbers between a and b, use
//generate ui = floor((b-a+1)*runiform() + a)

forvalues i=1(1)1000{
	use "working data/temp_studentids",clear
	generate seed = floor((2147483647-1+1)*runiform() + 1)
	format seed %10.0f
	local seed=seed[1]
	set seed `seed'
	di "`seed'"
	replace seed=seed[1]
	gen u=uniform()
	sort u
	drop n
	gen n=_n
	rename student_id student_id_rand
	joinby n using "working data/temp_studentids",
	
	keep student_id* seed
	save "working data/temp_studentids_rand_`i'",replace
	}
	
use "working data/temp_choices",clear
forvalues i=1(1)1000{	
	preserve
	joinby 	student_id using "working data/temp_studentids_rand_`i'",
	drop student_id 
	rename student_id_rand student_id
	joinby student_id _mi_m using "working data/temp",
	//save "working data/permutation_`i'",replace
	rename Xart art_act_choice
	rename Xma maths_act_choice

	foreach j in  art biology  business chemistry computing economics english geography history languages maths physics psychology{
		mi est:logistic `j'_act_choice study`j' intervgp ks3_mattalev ks3_scitalev ks3_engtalev maths_exp_GCSE_pts eng_exp_GCSE_pts male fsmeligible_spr12,ro cluster(schoolno) or
		regsave intervgp using "results/graduate_exp/intervention_effect_act_choice_`j'_adj_`i'",replace pval detail(all) ci coefmat(e(b_mi)) varmat(e(V_mi))
		}

	restore
	}

use 	"results/graduate_exp/intervention_effect_act_choice_art_adj_1",clear
gen perm=1
forvalues i=1(1)1000{
	foreach j in  art biology  business chemistry computing economics english geography history languages maths physics psychology{
		append using  "results/graduate_exp/intervention_effect_act_choice_`j'_adj_`i'",
		}
	replace perm=`i' if perm==.
	}
drop if substr(var,1,3)=="art"

bys perm:egen min_pval=min(pval)
bys perm (pval):gen min_2nd_pval=pval[2]
bys perm (pval):gen min_3rd_pval=pval[3]
bys perm (pval):gen min_4th_pval=pval[4]
bys perm (pval):gen min_5th_pval=pval[5]	
bys perm (pval):gen min_6th_pval=pval[6]	
bys perm (pval):gen min_7th_pval=pval[7]					
bys perm (pval):gen min_8th_pval=pval[8]					
bys perm (pval):gen min_9th_pval=pval[9]					
bys perm (pval):gen min_10th_pval=pval[10]					
bys perm (pval):gen min_11th_pval=pval[11]		
bys perm (pval):gen min_12th_pval=pval[12]								
							
count if min_pval<0.016047
di r(N)/12000
count if min_2nd_pval<0.044623
di r(N)/12000
count if min_3rd_pval<0.048038
di r(N)/12000
count if min_4th_pval<0.154107
di r(N)/12000
count if min_5th_pval<0.418714
di r(N)/12000
count if min_6th_pval<0.539958
di r(N)/12000
count if min_7th_pval<0.567532
di r(N)/12000
count if min_8th_pval<0.774379
di r(N)/12000
count if min_9th_pval<0.785370
di r(N)/12000
count if min_10th_pval<0.828300
di r(N)/12000
count if min_11th_pval<0.883716
di r(N)/12000
count if min_12th_pval<0.990496
di r(N)/12000


append using  "results/graduate_exp/intervention_effect_act_choice_biology_adj_1",
