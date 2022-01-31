cls
clear all

cd "C:\Users\Jinhyun\Desktop\Empirical Methods in Finance\Tutorial\Individual assingment\From final data"

use "final_dataset.dta"

describe
sort gvkey
by gvkey: egen check_BC = mean(BC) 
gen No_BC = 0
replace No_BC = 1 if check == 0
gen BC_first = 1 if BC[_n] != BC[_n-1] & gvkey[_n] ==gvkey[_n-1]
gen BC_three_years = 1 if BC_first != BC_first[_n+3] | BC_first != BC_first[_n-2] | BC_first != BC_first[_n+1]
replace BC_three_years = 0 if BC_first != 1
drop if BC_three_years == BC_first
drop BC_first

// gen BC_first_year = year if BC[_n] != BC[_n-1] & BC[_n] == 1
// gen BC_three_years = 1 if BC_first != BC_first[_n+3] | BC_first != BC_first[_n-2] | BC_first != BC_first[_n+1]
// replace BC_three_years = 0 if BC_first != 1
// drop if BC_three_years == BC_first
// drop BC_first


//Question 1: GM`s Table 1 with replacing 2 acquisition rows into ln(cash) and Performance-related Exit//
summarize lnassets roi lev cagr vol cfvol lncash delist if BC==1 & No_BC == 1
summarize lnassets roi lev cagr vol cfvol lncash delist if BC==0 & No_BC == 1

ttest lnassets, by(No_BC)
ttest roi, by(No_BC)
ttest lev, by(No_BC)
ttest cagr, by(No_BC)
ttest vol, by(No_BC)
ttest cfvol, by(No_BC)
ttest lncash, by(No_BC)
ttest lncash, by(No_BC)
ttest delist, by(No_BC)
ttest delist, by(No_BC)


//Question 2: Replicate GM`s Table 2//
decode staten, gen(state)
egen state_y = group(state year)
egen industry_y = group(sic year)

reghdfe vol BC, absorb(gvkey state_y industry_y) vce(cluster incorp) noconstant // Stock Volatility
outreg2 using reg1, word append 
reghdfe delist BC, absorb(gvkey state_y industry_y) vce(cluster incorp) noconstant //Performance-related Exit
reghdfe assetvol BC, absorb(gvkey state_y industry_y) vce(cluster incorp) noconstant //Operating Asset Volatility
reghdfe cfvol BC, absorb(gvkey state_y industry_y) vce(cluster incorp) noconstant // Cash Flow Volatility
reghdfe lncash BC, absorb(gvkey state_y industry_y) vce(cluster incorp) noconstant // ln(cash) 

//Question 3: 14 new dummy variables as independent variables//
gen BC_first_year = 0 
replace BC_first_year = 1 if BC[_n] != BC[_n-1] & BC[_n] == 1

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

replace one_dummy_m5 = 1 if BC_first_year[_n+5] == 1
replace one_dummy_m4 = 1 if BC_first_year[_n+4] == 1
replace one_dummy_m3 = 1 if BC_first_year[_n+3] == 1
replace one_dummy_m2 = 1 if BC_first_year[_n+2] == 1
replace one_dummy_m1 = 1 if BC_first_year[_n+1] == 1
replace one_dummy_0 =  1 if BC_first_year == 1
replace one_dummy_p1 = 1 if BC_first_year[_n-1] == 1
replace one_dummy_p2 = 1 if BC_first_year[_n-2] == 1
replace one_dummy_p3 = 1 if BC_first_year[_n-3] == 1
replace one_dummy_p4 = 1 if BC_first_year[_n-4] == 1
replace one_dummy_p5 = 1 if BC_first_year[_n-5] == 1
replace one_dummy_p6 = 1 if BC_first_year[_n-6] == 1
replace one_dummy_p7 = 1 if BC_first_year[_n-7] == 1
replace one_dummy_p8 = 1 if BC_first_year[_n-8] == 1


reghdfe delist one_dummy_m5 one_dummy_m4 one_dummy_m3 one_dummy_m2  one_dummy_m1  one_dummy_0  one_dummy_p1 one_dummy_p2 one_dummy_p3 one_dummy_p4 one_dummy_p5 one_dummy_p6 one_dummy_p7 one_dummy_p8 , absorb(gvkey sta)

// xtset gvkey year
// xtreg delist one_dummy_m5 one_dummy_m4 one_dummy_m3 one_dummy_m2  one_dummy_m1  one_dummy_0     one_dummy_p1 one_dummy_p2 one_dummy_p3 one_dummy_p4 one_dummy_p5 one_dummy_p6 one_dummy_p7 one_dummy_p8 , fe robust
//
// xtreg vol one_dummy_m5 one_dummy_m4 one_dummy_m3 one_dummy_m2  one_dummy_m1  one_dummy_0     one_dummy_p1 one_dummy_p2 one_dummy_p3 one_dummy_p4 one_dummy_p5 one_dummy_p6 one_dummy_p7 one_dummy_p8, fe robust // How do we do the state by year fixed effect?  Adding i.gvkey#i.year is not working 



// i.gvkey#i.year

//Question 4: GM`s Table 2 with replacing the dependent variable with 4 leverage measures//
reghdfe lev BC, absorb(gvkey statey industry_y) vce(cluster incorp) noconstant // Book Leverage
reghdfe mktlev BC, absorb(gvkey statey industry_y) vce(cluster incorp) noconstant // Market Leverage
reghdfe lev_st BC, absorb(gvkey statey industry_y) vce(cluster incorp) noconstant // Short-term Leverage
reghdfe netlev BC, absorb(gvkey statey industry_y) vce(cluster incorp) noconstant // Net Leverage


//Question 5.1: The sample period from 1976 to 1995//
reghdfe vol BC if inrange(year, 1976, 1995), absorb(gvkey statey industry_y) vce(cluster incorp) noconstant
reghdfe delist BC if inrange(year, 1976, 1995), absorb(gvkey statey industry_y) vce(cluster incorp) noconstant
reghdfe assetvol BC if inrange(year, 1976, 1995), absorb(gvkey statey industry_y) vce(cluster incorp) noconstant
reghdfe cfvol BC if inrange(year, 1976, 1995), absorb(gvkey statey industry_y) vce(cluster incorp) noconstant
reghdfe lncash BC if inrange(year, 1976, 1995), absorb(gvkey statey industry_y) vce(cluster incorp) noconstant


//Question 5.2: The full sample period excluding financial firms//
drop if sic>3999 & sic<5000 // exclude utility firms
drop if sic>5999 & sic<6800 // exclude financial firms

reghdfe vol BC, absorb(gvkey statey industry_y) vce(cluster incorp) noconstant
reghdfe delist BC, absorb(gvkey statey industry_y) vce(cluster incorp) noconstant
reghdfe assetvol BC, absorb(gvkey statey industry_y) vce(cluster incorp) noconstant
reghdfe cfvol BC, absorb(gvkey statey industry_y) vce(cluster incorp) noconstant
reghdfe lncash BC, absorb(gvkey statey industry_y) vce(cluster incorp) noconstant


