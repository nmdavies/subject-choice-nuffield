//Neil Davies 11/03/14
//This extracts the student's actual A-level choices:

use  "Raw Data\complete_data_set_with_subject_choices.dta", clear

keep id *_choice

ds *_choice
foreach i in `r(varlist)'{
	replace `i'=(`i'!=.)
	}
compress
duplicates drop id,force
save "working data/actual_choices",replace

