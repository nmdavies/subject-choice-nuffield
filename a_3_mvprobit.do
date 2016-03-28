//Neil Davies 29/10/14
//This estimates the mvprobit model for the RCT results



use  "working data/imputed_dataset_labour_market_knowledge2_actual_choices",clear
//Next need to run the mvprobit regression

foreach j in biology  business chemistry computing design economics english geography history languages maths media music physics psychology {
foreach i in biology  business chemistry computing design economics english geography history languages maths media music physics psychology {
	if "`j'"!="`i'"{
	mi est,cmdok:mvprobit (`j'_act_choice=study`j' intervgp ks3_mattalev ks3_scitalev ks3_engtalev maths_exp_GCSE_pts eng_exp_GCSE_pts male fsmeligible_spr12)  (`i'_act_choice=study`i' intervgp ks3_mattalev ks3_scitalev ks3_engtalev maths_exp_GCSE_pts eng_exp_GCSE_pts male fsmeligible_spr12) ,ro cluster(schoolno) 
	regsave using "results/mvprobit_art_`i'_`j'",replace detail(all)  pval  ci coefmat(e(b_mi)) varmat(e(V_mi))
	}
	}
	}
	
foreach i in biology  business chemistry computing design economics english geography history languages maths media music physics psychology {
	use "results/mvprobit_art_`i'_business",clear
	foreach j in biology  business chemistry computing design economics english geography history languages maths media music physics psychology {
		cap:append using "results/mvprobit_art_biology_`j'",
		}
	keep if substr(var,-8,8)=="intervgp"
	duplicates drop
	gen n2=_n
	save "results/bivar_probit_`i'",replace
	}
	
foreach i in business chemistry computing design economics english geography history languages maths media music physics psychology {
	use "results/mvprobit_art_`i'_biology",clear
	foreach j in biology  business chemistry computing design economics english geography history languages maths media music physics psychology {
		cap:append using "results/mvprobit_art_`i'_`j'",
		}
	keep if substr(var,-8,8)=="intervgp"
	duplicates drop
	gen n2=_n
	save "results/bivar_probit_`i'",replace
	}
	
use n2 var pval using "results/bivar_probit_biology",clear
rename pval pval_bio
rename var var_bio
foreach i in business chemistry computing design economics english geography history languages maths media music physics psychology {
	joinby n2 using "results/bivar_probit_`i'",
	keep n2 var* pval*
	rename pval pval_`i'
	rename var var_`i'
	}
