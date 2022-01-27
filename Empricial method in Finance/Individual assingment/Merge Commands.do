cls
clear all

cd "C:\Users\Jinhyun\Documents\GitHub\stata\Empricial method in Finance\Individual assingment"


	use "Compustat_Annual.dta"
	joinby gvkey using "Compustat_Quarter.dta", unmatched(master)  
	tab _merge
	drop if merge_!=3
	drop_merge
	save merged_annual_quarter, replace
	
	use merged_1_an_qua
	joinby gvkey using "CRSP.dta", unmatched(master)  
	tab _merge
	drop if merge_!=3
	drop_merge
	save merged_annual_quarter_linkT, replace
	
	use merged_annual_quarter_linkT
	joinby PERMNO using "CRSP.dta", unmatched(master)  
	tab _merge
	drop if merge_!=3
	drop_merge
	save merged_annual_quarter_linkT_CRSP, replace

