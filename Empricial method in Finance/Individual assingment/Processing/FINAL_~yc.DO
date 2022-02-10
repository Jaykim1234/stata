cls
clear all

cd "C:\Users\Jinhyun\Desktop\Empirical Methods in Finance\Tutorial\Individual assingment\From final data"
use "final_dataset.dta"

describe
// sort gvkey
// by gvkey: egen check_BC = mean(BC) 
// g No_BC = 0
// replace No_BC = 1 if check == 0

xtset gvkey year
gen BC_first = 1 if BC[_n] != BC[_n-1] & gvkey[_n] ==gvkey[_n-1]
gen BC_three_years = 1 if BC_first != BC_first[_n+3] | BC_first != BC_first[_n-2] | BC_first != BC_first[_n+1]
replace BC_three_years = 0 if BC_first != 1
drop if BC_three_years == BC_first
drop BC_first

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
reg vol BC, robust // Stock Volatility
reg delist BC, robust //Performance-related Exit
reg assetvol BC, robust //Operating Asset Volatility
reg cfvol BC, robust // Cash Flow Volatility
reg lncash BC, robust // ln(cash) 


//Question 3: 14 new dummy variables as independent variables//
xtset gvkey 

//Question 4: GM`s Table 2 with replacing the dependent variable with 4 leverage measures//
reg lev BC, robust // Book Leverage
reg mktlev BC, robust // Market Leverage
reg lev_st BC, robust // Short-term Leverage
reg netlev BC, robust // Net Leverage


//Question 5.1: The sample period from 1976 to 1995//
reg vol BC if inrange(year, 1976, 1995), robust 
reg delist BC if inrange(year, 1976, 1995), robust 
reg assetvol BC if inrange(year, 1976, 1995), robust 
reg cfvol BC if inrange(year, 1976, 1995), robust 
reg lncash BC if inrange(year, 1976, 1995), robust 


//Question 5.2: The full sample period excluding financial firms//
drop if inrange


//reg vol BC if gvkey !=, robust 
//reg delist BC if gvkey !=, robust 
//reg assetvol BC if gvkey !=, robust 
//reg cfvol BC if gvkey !=, robust
//reg lncash BC if gvkey !=, robust 


