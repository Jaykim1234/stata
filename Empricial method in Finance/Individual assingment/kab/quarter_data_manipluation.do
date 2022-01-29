cd "C:\Users\kaabm\Desktop\Assignment EMF"
use quart_dta.dta

gen quarter_date = quarterly(datafqtr, "YQ")
format quarter_date %tq

destring gvkey, replace

duplicates drop gvkey quarter_date, force

xtset gvkey quarter_date 


gen accruals = (actq-L.actq)-(cheq-L.cheq)-(lctq-L.lctq)+(dlcq-L.dlcq)-dpq

gen cf_ratio = (oiadpq-accruals)/L.atq

bys gvkey year: egen cf_vol = sd(cf_ratio)

drop if cf_vol==.

duplicates drop gvkey year cf_vol, force

save quart_dta_new.dta