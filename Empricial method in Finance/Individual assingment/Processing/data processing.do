// Ans delft

use crsp_dta.dta, clear 
duplicates drop PERMCO date, force //Drop date duplicates.
xtset PERMCO date
gen year = yofd(date) // Extract year from date.

replace PRC = abs(PRC) if PRC<0 // Include negative PRC values because they are the midpoint/bid-ask average.

joinby PERMCO PERMNO using linking_tab.dta // Use linking table for later. Data her are also included in computstat.

drop LINKTYPE LINKDT LINKENDDT
drop if PRC==. //Remove empty price values.

bys PERMCO (date): gen ret = ln(PRC / PRC[_n-1]) //Create returns.
drop if ret==. //Remove empty return values.

gen ret2 = ret*ret //Square observations.
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
// Generate a delist dummy variable that becomes 1 when DLSTCD are in one of below arrange.
gen delist = 1 if inrange(DLSTCD, 400, 500)| DLSTCD == 550 | DLSTCD == 552 | DLSTCD == 560 | DLSTCD == 561 | DLSTCD == 572 | DLSTCD == 574 | DLSTCD == 580 | DLSTCD == 584
replace delist = 0 if delist ==. // Make 'delist' dummy variable to 0 when delist is missing.
joinby PERMCO PERMNO using linking_tab.dta 
gen year = yofd(date) // Extract year from date.
duplicates drop gvkey year 
keep delist gvkey year
save Delisting, replace



// q3

use CompustatQuarterly, clear


gen quarter_date = quarterly(datafqtr, "YQ") // Extract quarter date. 
format quarter_date %tq
xtset gvkey quarter_date

gen year = yofd(dofq(quarter_date)) // Extract year date. 

gen accruals = (actq-L.actq)-(cheq-L.cheq)-(lctq-L.lctq)+(dlcq-L.dlcq)-dpq // Generate accruals

gen cf_ratio = (oiadpq-accruals)/L.atq // Generate cash flow ratio variable.
winsor cf_ratio, p(0.01) cf_ratio_new

bys gvkey year: egen cf_vol_quart = sd(cf_ratio_new) // Compute cash flow volatility.

gen cf_vol= cf_vol_quart * sqrt(4) // Annualize cash flow volatility by multiply 4.

duplicates drop gvkey year, force // Check for duplicates.

save quart_data.dta, replace // Save final file.


// q4
* drop utilities
drop indfmt consol popsrc datafmt costat

* drop non-US companies
keep if curcd=="USD"

* drop observations with negative or missing total assets or sales:
drop if at==. | at<0
drop if ni==.


// q5
gen ret_assets = ni/at
gen ln_assets = ln(at)
gen ln_cash = ln(ch)
gen debt_ratio_at = (dltt+dlc)/at


//q6

// The intuition behind this merging is that the yearly frequencies data are kept only by deleting duplicates of year and gvkey. Therefore the merging works
 //The more precise version can be merging by datadate for CRSP. 
gen year = yofd(datadate)
joinby gvkey year using CRSPDaily
joinby gvkey year using Delisting
joinby gvkey year using quart_data


//q7

g BC=0 if state!="" & incorp!="" 
replace BC=1 if incorp=="CT" & year>=1989
replace BC=1 if incorp=="AZ" & year>=1987
