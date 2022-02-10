cls
clear all

cd "C:\Users\Jinhyun\Desktop\Empirical Methods in Finance\Tutorial\Individual assingment\From final data"

use "final_dataset.dta"

// drop if curcd != "USD"

//Question 1: GM`s Table 1 with replacing 2 acquisition rows into ln(cash) and Performance-related Exit//

xtset gvkey year
sort incorp year

gen BC_first_year = 0 
replace BC_first_year = year if BC[_n] != BC[_n-1] & BC[_n] == 1
by incorp: egen max_BC_first_year = max(BC_first_year)
replace BC_first_year = max_BC_first_year if BC_first_year == 0
drop max_BC_first_year

gen BC_b_three_years = 0 
replace BC_b_three_years = 1 if (year == BC_first_year -3 | year == BC_first_year -2| year == BC_first_year -1)

sort gvkey year
by gvkey: egen sum_BC = total(BC) 
by gvkey: gen No_BC = 0 
replace No_BC = 1 if sum_BC == 0

asdoc sum lnassets roi lev cagr vol cfvol lncash delist if BC_b_three_years == 1, stat(mean sd) replace
asdoc sum lnassets roi lev cagr vol cfvol lncash delist if No_BC==1, stat(mean sd) replace

ttest lnassets, by(No_BC)
ttest roi, by(No_BC)
ttest lev, by(No_BC)
ttest cagr, by(No_BC)
ttest vol,  by(No_BC)
ttest cfvol, by(No_BC)
ttest lncash, by(No_BC)
ttest lncash, by(No_BC)
ttest delist, by(No_BC)
ttest delist, by(No_BC)

//Question 2: Replicate GM`s Table 2//
decode staten, gen(state)
egen state_y = group(state year)
egen industry_y = group(sic year)

// Stock Volatility
reghdfe vol BC, absorb(gvkey state_y industry_y) vce(cluster incorp) noconstant 
outreg2 using reg1, word append 

//Performance-related Exit
reghdfe delist BC, absorb(gvkey state_y industry_y) vce(cluster incorp) noconstant 
outreg2 using reg1, word append 
//Operating Asset Volatility
reghdfe assetvol BC, absorb(gvkey state_y industry_y) vce(cluster incorp) noconstant 
outreg2 using reg1, word append 

// Cash Flow Volatility
reghdfe cfvol BC, absorb(gvkey state_y industry_y) vce(cluster incorp) noconstant
outreg2 using reg1, word append 

// ln(cash)
reghdfe lncash BC, absorb(gvkey state_y industry_y) vce(cluster incorp) noconstant  
outreg2 using reg1, word append 

//Question 3: 14 new dummy variables as independent variables//
// sort incorp year
// gen BC_first_year = 0 
// replace BC_first_year = year if BC[_n] != BC[_n-1] & BC[_n] == 1
// by incorp: egen max_BC_first_year = max(BC_first_year)
// replace BC_first_year = max_BC_first_year if BC_first_year == 0
// drop max_BC_first_year

gen one_dummy_m5 = 0
gen one_dummy_m4 = 0 
gen one_dummy_m3 = 0
gen one_dummy_m2 = 0 
gen one_dummy_m1 = 0 
gen one_dummy_0 =  0 
gen one_dummy_p1 = 0 
gen one_dummy_p2 = 0
gen one_dummy_p3 = 0 
gen one_dummy_p4 = 0 
gen one_dummy_p5 = 0 
gen one_dummy_p6 = 0
gen one_dummy_p7 = 0
gen one_dummy_p8 = 0

replace one_dummy_m5 = 1 if year == BC_first_year -5 
replace one_dummy_m4 = 1 if year == BC_first_year -4 
replace one_dummy_m3 = 1 if year == BC_first_year -3 
replace one_dummy_m2 = 1 if year == BC_first_year -2 
replace one_dummy_m1 = 1 if year == BC_first_year -1 
replace one_dummy_0 =  1 if year == BC_first_year
replace one_dummy_p1 = 1 if year == BC_first_year +1 
replace one_dummy_p2 = 1 if year == BC_first_year +2 
replace one_dummy_p3 = 1 if year == BC_first_year +3 
replace one_dummy_p4 = 1 if year == BC_first_year +4
replace one_dummy_p5 = 1 if year == BC_first_year +5 
replace one_dummy_p6 = 1 if year == BC_first_year +6 
replace one_dummy_p7 = 1 if year == BC_first_year +7 
replace one_dummy_p8 = 1 if year == BC_first_year +8 

reghdfe vol one_dummy_m5 one_dummy_m4 one_dummy_m3 one_dummy_m2  one_dummy_m1  one_dummy_0  one_dummy_p1 one_dummy_p2 one_dummy_p3 one_dummy_p4 one_dummy_p5 one_dummy_p6 one_dummy_p7 one_dummy_p8 , absorb(gvkey state_y) vce(cluster incorp) 

reghdfe delist one_dummy_m5 one_dummy_m4 one_dummy_m3 one_dummy_m2  one_dummy_m1  one_dummy_0  one_dummy_p1 one_dummy_p2 one_dummy_p3 one_dummy_p4 one_dummy_p5 one_dummy_p6 one_dummy_p7 one_dummy_p8 , absorb(gvkey state_y) vce(cluster incorp) 


//Question 4: GM`s Table 2 with replacing the dependent variable with 4 leverage measures//
reghdfe lev BC, absorb(gvkey state_y industry_y) vce(cluster incorp) noconstant // Book Leverage
reghdfe mktlev BC, absorb(gvkey state_y industry_y) vce(cluster incorp) noconstant // Market Leverage
reghdfe lev_st BC, absorb(gvkey state_y industry_y) vce(cluster incorp) noconstant // Short-term Leverage
reghdfe netlev BC, absorb(gvkey state_y industry_y) vce(cluster incorp) noconstant // Net Leverage


//Question 5.1: The sample period from 1976 to 1995//
reghdfe vol BC if inrange(year, 1976, 1995), absorb(gvkey state_y industry_y) vce(cluster incorp) noconstant
reghdfe delist BC if inrange(year, 1976, 1995), absorb(gvkey state_y industry_y) vce(cluster incorp) noconstant
reghdfe assetvol BC if inrange(year, 1976, 1995), absorb(gvkey state_y industry_y) vce(cluster incorp) noconstant
reghdfe cfvol BC if inrange(year, 1976, 1995), absorb(gvkey state_y industry_y) vce(cluster incorp) noconstant
reghdfe lncash BC if inrange(year, 1976, 1995), absorb(gvkey state_y industry_y) vce(cluster incorp) noconstant


//Question 5.2: The full sample period excluding financial firms//
drop if sic>3999 & sic<5000 // exclude utility firms
drop if sic>5999 & sic<6800 // exclude financial firms

reghdfe vol BC, absorb(gvkey state_y industry_y) vce(cluster incorp) noconstant
reghdfe delist BC, absorb(gvkey state_y industry_y) vce(cluster incorp) noconstant
reghdfe assetvol BC, absorb(gvkey state_y industry_y) vce(cluster incorp) noconstant
reghdfe cfvol BC, absorb(gvkey state_y industry_y) vce(cluster incorp) noconstant
reghdfe lncash BC, absorb(gvkey state_y industry_y) vce(cluster incorp) noconstant




