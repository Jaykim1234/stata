// Ans delft

use crsp_dta.dta, clear
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
winsor SD, p(.01) generate(stock_vol)
keep gvkey year stock_vol
destring gvkey
save volatility, replace


// q2

duplicates drop PERMCO date, force
xtset PERMCO date
gen delist = 1 if inrange(DLSTCD, 400, 500)| DLSTCD == 550 | DLSTCD == 552 | DLSTCD == 560 | DLSTCD == 561 | DLSTCD == 572 | DLSTCD == 574 | DLSTCD == 580 | DLSTCD == 584
replace delist = 0 if delist ==.
joinby PERMCO PERMNO using linking_tab.dta
gen year = yofd(date)
duplicates drop gvkey year
keep delist gvkey year
save Delisting, replace


use CompustatQuarterly, clear
* define quarterly time variable

gen quarter_date = quarterly(datafqtr, "YQ")
format quarter_date %tq
xtset gvkey quarter_date

gen year = yofd(dofq(quarter_date))

*generate cash flow variable:
gen accruals = (actq-L.actq)-(cheq-L.cheq)-(lctq-L.lctq)+(dlcq-L.dlcq)-dpq
gen cf_ratio = (oiadpq-accruals)/L.atq

winsor cf_ratio, p(0.01) cf_ratio_new

* compute cash flow volatility
bys gvkey year: egen cf_vol_quart = sd(cf_ratio_new)



* annualize cash flow volatility

gen cf_vol= cf_vol_quart * sqrt(4)

* save final file (check for duplicates)

duplicates drop gvkey year, force

save quart_data.dta, replace
[오전 10:26, 2022. 1. 31.] Kab: question 4

drop indfmt consol popsrc datafmt costat

keep if curcd=="USD"

drop if at==. | at<0
drop if ni==.


gen ln_cash = ln(ch)
gen ret_assets = ni/at
gen debt_ratio_at = (dltt+dlc)/at
gen ln_assets = ln(at)


gen year = yofd(datadate)
joinby gvkey year using CRSPDaily
joinby gvkey year using Delisting
joinby gvkey year using quart_data
//This works because in the previous answers I have kept yearly frequencies only by deleting duplicates of year and gvkey
//The more precise version is merging by datadate for CRSP. Year still works find for quart_data


g BC=0 if state!="" & incorp!=""
replace BC=1 if incorp=="AZ" & year>=1987
replace BC=1 if incorp=="CT" & year>=1989