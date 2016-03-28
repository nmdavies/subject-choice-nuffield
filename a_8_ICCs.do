//Neil Davies 05/12/14
//This works out the ICC of choices in the trial:


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

duplicates tag student_id _mi_m, gen(tag)
drop if _mi_id ==1374|_mi_id ==1837|_mi_id ==2288|_mi_id ==2327

 mi extract 0,clear
foreach i in  biology  business chemistry computing design economics english geography history languages maths media music physics psychology{
	mixed `i'_act_choice || schoolno:
	estat icc
	}
