cls
clear all

cd "C:\Users\Jinhyun\Desktop\Empirical Methods in Finance\Tutorial\Individual assingment\From final data"

use "final_dataset.dta"

//Question 1: GM`s Table 1 with replacing 2 acquisition rows into ln(cash) and Performance-related Exit//
//
// sort gvkey year
sort incorp year
xtset gvkey year
gen BC_first = 1 if BC[_n] != BC[_n-1] & gvkey[_n]==gvkey[_n-1]
gen BC_three_years = 1 if gvkey[_n] == gvkey[_n-1] & (BC_first!=BC_first[_n+3] | BC_first!=BC_first[_n+2] | BC_first!=BC_first[_n+1])
replace BC_three_years = 0 if BC_three_years!= 1
replace BC_three_years = 0 if BC_three_years == BC_first
drop BC_first

by gvkey: egen sum_BC = total(BC) 
by gvkey: gen No_BC = 1 if sum_BC==0
replace No_BC = 0 if No_BC==.

xtset gvkey year

keep if BC_three_years==1 | No_BC==1

reg lnassets if No_BC==0, cluster(incorpn)

eststo BC:estpost sum lnassets roi lev cagr cfvol vol delist lncash if BC_three_years==1
eststo No_BC_:estpost sum lnassets roi lev cagr cfvol vol delist lncash if No_BC == 1
eststo diff:estpost ttest lnassets roi lev cagr cfvol vol delist lncash, by(No_BC)
esttab BC No_BC_ diff using q1.doc, cells("mean(pattern(1 1 0) fmt(3)) p(pattern(0 0 1) fmt(3))" sd(pattern(1 1 0) par fmt(3))) label replace

//Question 2: Replicate GM`s Table 2//

// Version 1

decode staten, gen(state)
egen state_y = group(state year)
egen industry_y = group(sic year)

// Stock Volatility
reghdfe vol BC, absorb(gvkey state_y industry_y) vce(cluster incorp) noconstant 
outreg2 using q2_v1, word replace 

//Performance-related Exit
reghdfe delist BC, absorb(gvkey state_y industry_y) vce(cluster incorp) noconstant 
outreg2 using q2_v1, word append 
//Operating Asset Volatility
reghdfe assetvol BC, absorb(gvkey state_y industry_y) vce(cluster incorp) noconstant 
outreg2 using q2_v1, word append 

// Cash Flow Volatility
reghdfe cfvol BC, absorb(gvkey state_y industry_y) vce(cluster incorp) noconstant
outreg2 using q2_v1, word append 

// ln(cash)
reghdfe lncash BC, absorb(gvkey state_y industry_y) vce(cluster incorp) noconstant  
outreg2 using q2_v1, word append 

//Version 2

egen state_year = group(staten year)
egen industry_year = group(sic year)

//Table 2
quietly asdoc reghdfe vol BC, absorb(state_year industry_year gvkey) vce(cluster incorp) save(q2_v2.doc) nest replace
quietly asdoc reghdfe delist BC, absorb(state_year industry_year gvkey) vce(cluster incorp) save(q2_v2.doc) nest
quietly asdoc reghdfe assetvol BC, absorb(state_year industry_year gvkey) vce(cluster incorp) save(q2_v2.doc) nest
quietly asdoc reghdfe cfvol BC, absorb(state_year industry_year gvkey) vce(cluster incorp) save(q2_v2.doc) nest
quietly asdoc reghdfe lncash BC, absorb(state_year industry_year gvkey) vce(cluster incorp) save(q2_v2.doc) nest


//Question 3: 14 new dummy variables as independent variables//
sort incorp year
gen BC_first_year = 0 
replace BC_first_year = year if BC[_n] != BC[_n-1] & BC[_n] == 1 & incorp[_n] == incorp[_n-1]
by incorp: egen max_BC_first_year = max(BC_first_year)
replace BC_first_year = max_BC_first_year if BC_first_year == 0
drop max_BC_first_year

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

reghdfe vol one_dummy_m5 one_dummy_m4 one_dummy_m3 one_dummy_m2  one_dummy_m1  one_dummy_0  one_dummy_p1 one_dummy_p2 one_dummy_p3 one_dummy_p4 one_dummy_p5 one_dummy_p6 one_dummy_p7 one_dummy_p8 , absorb(gvkey state_y) vce(cluster incorp) noconstant
outreg2 using q3_v1, word replace

ssc install coefplot, replace
coefplot, vertical drop(_cons) yline(0)


reghdfe delist one_dummy_m5 one_dummy_m4 one_dummy_m3 one_dummy_m2  one_dummy_m1  one_dummy_0  one_dummy_p1 one_dummy_p2 one_dummy_p3 one_dummy_p4 one_dummy_p5 one_dummy_p6 one_dummy_p7 one_dummy_p8 , absorb(gvkey state_y) vce(cluster incorp) noconstant
outreg2 using q3_v1, word append
coefplot, vertical drop(_cons) yline(0)



//Question 4: GM`s Table 2 with replacing the dependent variable with 4 leverage measures//
reghdfe lev BC, absorb(gvkey state_y industry_y) vce(cluster incorp) noconstant // Book Leverage
outreg2 using q4_v1, word replace 
reghdfe mktlev BC, absorb(gvkey state_y industry_y) vce(cluster incorp) noconstant // Market Leverage
outreg2 using q4_v1, word append 
reghdfe lev_st BC, absorb(gvkey state_y industry_y) vce(cluster incorp) noconstant // Short-term Leverage
outreg2 using q4_v1, word append 
reghdfe netlev BC, absorb(gvkey state_y industry_y) vce(cluster incorp) noconstant // Net Leverage
outreg2 using q4_v1, word append 


//Question 5.1: The sample period from 1976 to 1995//
reghdfe vol BC if inrange(year, 1976, 1995), absorb(gvkey state_y industry_y) vce(cluster incorp) noconstant
outreg2 using q5_1_v1, word replace 
reghdfe delist BC if inrange(year, 1976, 1995), absorb(gvkey state_y industry_y) vce(cluster incorp) noconstant
outreg2 using q5_1_v1, word append 
reghdfe assetvol BC if inrange(year, 1976, 1995), absorb(gvkey state_y industry_y) vce(cluster incorp) noconstant
outreg2 using q5_1_v1, word append 
reghdfe cfvol BC if inrange(year, 1976, 1995), absorb(gvkey state_y industry_y) vce(cluster incorp) noconstant
outreg2 using q5_1_v1, word append 
reghdfe lncash BC if inrange(year, 1976, 1995), absorb(gvkey state_y industry_y) vce(cluster incorp) noconstant
outreg2 using q5_1_v1, word append 


//Question 5.2: The full sample period excluding financial firms//
drop if sic>3999 & sic<5000 // exclude utility firms
drop if sic>5999 & sic<6800 // exclude financial firms

reghdfe vol BC, absorb(gvkey state_y industry_y) vce(cluster incorp) noconstant
outreg2 using q5_2_v1, word replace

reghdfe delist BC, absorb(gvkey state_y industry_y) vce(cluster incorp) noconstant
outreg2 using q5_2_v1, word append 

reghdfe assetvol BC, absorb(gvkey state_y industry_y) vce(cluster incorp) noconstant
outreg2 using q5_2_v1, word append 

reghdfe cfvol BC, absorb(gvkey state_y industry_y) vce(cluster incorp) noconstant
outreg2 using q5_2_v1, word append 

reghdfe lncash BC, absorb(gvkey state_y industry_y) vce(cluster incorp) noconstant
outreg2 using q5_2_v1, word append 





