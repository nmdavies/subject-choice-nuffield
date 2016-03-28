

cd "H:\CMPO\Income expectations RCT\"

use  "working data/imputed_dataset_labour_market_knowledge2",clear

//Regenerate salary important variable

mi passive:gen salforuni2=(uni_mot_salary==1|uni_mot_salary==2) if uni_mot_salary!=.

mi passive:gen uni_1=(university_plans==1|university_plans==1.5) if university_plans!=.
mi passive:gen uni_2=(university_plans==2|university_plans==2.5) if university_plans!=.
mi passive:gen uni_3=(university_plans==3) if university_plans!=.
mi passive:gen uni_4=(university_plans==4) if university_plans!=.

replace studybiology2=2 if studybiology2==1.5
replace studybusiness2=2 if studybusiness2==4.5

rename Xart_act_choice art_act_choice
rename Xmaths_act_choice maths_act_choice

duplicates tag student_id _mi_m, gen(tag)
drop if _mi_id ==1374|_mi_id ==1837|_mi_id ==2288|_mi_id ==2327


//Finally test whether there are any differences between treatment and control

foreach i in male maths_exp_GCSE_pts eng_exp_GCSE_pts stapri white profdad profmum profyou fatheruni1 motheruni1 fsmeligible_spr12 salforuni2 uni_1 uni_2 uni_3 uni_4 {
	mi est:reg `i' intervgp if male!=.,cluster(schoolno)
	regsave intervgp using "results/graduate_exp/balance_test_av_`i'",replace pval detail(all) ci coefmat(e(b_mi)) varmat(e(V_mi))
	}

foreach i in male maths_exp_GCSE_pts eng_exp_GCSE_pts stapri white profdad profmum profyou fatheruni1 motheruni1 fsmeligible_spr12 salforuni2 uni_1 uni_2 uni_3 uni_4 {
	reg `i' intervgp if male!=.,cluster(schoolno)
	regsave intervgp using "results/graduate_exp/balance_test_av_`i'_no_MI",replace pval detail(all) ci 
	}	
