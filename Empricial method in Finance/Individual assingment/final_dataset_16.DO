cls
clear all

cd "C:\Users\Jinhyun\Desktop\Empirical Methods in Finance\Tutorial\Individual assingment\From final data"

use "final_dataset.dta"

//Question 1: GM`s Table 1 with replacing 2 acquisition rows into ln(cash) and Performance-related Exit//
//

xtset gvkey year
gen BC_first = 1 if BC[_n] != BC[_n-1] & gvkey[_n]==gvkey[_n-1]
gen BC_three_years = 1 if gvkey[_n] == gvkey[_n-1] & (BC_first!=BC_first[_n-3] | BC_first!=BC_first[_n-2] | BC_first!=BC_first[_n-1])
replace BC_three_years = 0 if BC_three_years!= 1
replace BC_three_years = 0 if BC_three_years == BC_first
drop BC_first

sort incorp year
by incorp: egen sum_BC = total(BC) // Here we calculate the sum value of BC by each Current State/Province of Incorporation Code.

gen No_BC = 0 
replace No_BC = 1 if sum_BC==0 // If the sum value(sum_BC) is zero, this means the Current State/Province of Incorporation have not adopted BC law ever. In other words, if the No_BC is 1, there was no treatment.

xtset gvkey year
keep if BC_three_years==1 | No_BC==1
reg lnassets if No_BC==0, cluster(incorpn)

// clttest lnassets roi lev cagr cfvol vol delist lncash, cluster(incorp) by (No_BC) 


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

sort incorp year // Sort data by incorp and year

// Here we create a new variable that becomes current year when BC changes from 0 to 1 and the incorp variable has not changed. 
// This way we can find the first year of adoption at individual 'incorp'.
gen BC_first_year = 0 
replace BC_first_year = year if BC[_n] != BC[_n-1] & BC[_n] == 1 & incorp[_n] == incorp[_n-1]


by incorp: egen max_BC_first_year = max(BC_first_year) // Here we generate a variable that represent the first BC law adoption year at individual incorp.

//In this way we can now create a variable that shows first adoption year only (So there is no 0 at this variable). 
replace BC_first_year = max_BC_first_year if BC_first_year == 0

drop max_BC_first_year

gen ym5 = 0
replace ym5 = 1 if year == BC_first_year -5 
gen ym4 = 0 
replace ym4 = 1 if year == BC_first_year -4 
// Generate a dummy variable that becomes 1 if current year = the first adoption year at the State/Province - 3. 
gen ym3 = 0
replace ym3 = 1 if year == BC_first_year -3 
gen ym2 = 0 
replace ym2 = 1 if year == BC_first_year -2 
gen ym1 = 0 
replace ym1 = 1 if year == BC_first_year -1 
gen ynow =0 
replace ynow =  1 if year == BC_first_year
gen yp1 = 0 
replace yp1 = 1 if year == BC_first_year +1 
gen yp2 = 0
replace yp2 = 1 if year == BC_first_year +2 
gen yp3 = 0 
replace yp3 = 1 if year == BC_first_year +3 
gen yp4 = 0 
replace yp4 = 1 if year == BC_first_year +4
gen yp5 = 0 
replace yp5 = 1 if year == BC_first_year +5 
gen yp6 = 0
replace yp6 = 1 if year == BC_first_year +6
gen yp7 = 0
replace yp7 = 1 if year == BC_first_year +7 
gen yp8 = 0
replace yp8 = 1 if year == BC_first_year +8 

reghdfe vol ym5 ym4 ym3 ym2  ym1  ynow  yp1 yp2 yp3 yp4 yp5 yp6 yp7 yp8 , absorb(gvkey state_y) vce(cluster incorp) noconstant
outreg2 using q3_v1, word replace

ssc install coefplot, replace
coefplot, vertical drop(_cons) yline(0) name(vol) xtitle("Time") ytitle("Coefficients of vol") title("Coefficients of Stock volatility and time dummy variables")

reghdfe delist ym5 ym4 ym3 ym2  ym1  ynow  yp1 yp2 yp3 yp4 yp5 yp6 yp7 yp8 , absorb(gvkey state_y) vce(cluster incorp) noconstant
outreg2 using q3_v1, word append
coefplot, vertical drop(_cons) yline(0) name(delist) xtitle("Time") ytitle("Coefficients of delist") title("Coefficients of Performance related	exit and time dummy variables")


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





