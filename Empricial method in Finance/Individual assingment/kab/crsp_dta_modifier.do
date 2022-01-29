clear
cd "C:\Users\kaabm\Desktop\Assignment EMF"
use crsp_dta.dta

//Drop date duplicates by observation

duplicates drop PERMCO date, force

xtset PERMCO date

//Get year of date for later
gen year = yofd(date)

//Negative values are just the midpoint/bid-ask average so include them when calculating returns
replace PRC = abs(PRC) if PRC<0

//Use linking table for later. Only include data that is also included in computstat, otherwise won't be able to match with other financial data
joinby PERMCO PERMNO using linking_tab.dta

drop LINKTYPE LINKDT LINKENDDT

//Remove empty price values
drop if PRC==.

//Create returns
bys PERMCO (date): gen ret = ln(PRC / PRC[_n-1])
drop if ret==.

//Square observations then sum like in the article
gen ret2 = ret*ret 
duplicates drop PERMCO date, force
bys PERMCO year: egen sum_ret2 = total(ret2)
bys PERMCO year: gen SD = sqrt(sum_ret2)

//fill delist code 
gsort PERMCO -date
by PERMCO: replace DLSTCD = DLSTCD[_n-1] if DLSTCD[_n-1] !=.

//fix and keep only yearly frequency
tsset PERMCO date
duplicates drop PERMCO year, force
