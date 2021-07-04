/* DO FILE ASSIGNMENT 2
 GROUP 9 
11996277 Songhee Kim 
12317594 Mai Phan
11968850 Jinhyun Kim
12014621 Rajeev Pandit
11996161 Dayeon Park
*/

//QUESTION 2
//2a

cls
clear all
cd "/Users/" //change to own directory
use "shockdata.dta", clear
tab country if regulation==1

//2b
reg profit regulation, cluster(companysizegroup)
/* clustering automatically implies the robust option */ 

//2c
//generate two variables for the mean profitability of both groups, sorted by year
egen m_profit_no = mean(profit) if regulation==0, by(year) 
egen m_profit_reg = mean(profit) if regulation==1, by(year) 

//set the time variable to year
tsset companyid year

//create graph of the two mean profits
twoway (tsline m_profit_no) ///
(tsline m_profit_reg ), ///
name(ave_profit) xtitle("Year") ytitle("Profitability") ///
legend(order(1 "No regulation" 2 "Regulation")) 
 
//2d
gen post=(year>=2010) & !missing(year)

egen ave_profit_no_pre = mean(profit) if regulation==0 & post==0
egen ave_profit_no_post = mean(profit) if regulation==0 & post==1

egen ave_profit_reg_pre = mean(profit) if regulation==1 & post==0
egen ave_profit_reg_post = mean(profit) if regulation==1 & post==1

sum ave_profit_no_pre ave_profit_no_post ave_profit_reg_pre ave_profit_reg_post

//QUESTION 3

use "big4.dta", clear

use "announcements.dta", clear 
sort symbol crspcode cyear cquarter periodenddate
rename   periodenddate datadate
save "newannouncements.dta", replace

use "analysts.dta", clear
sort symbol datadate
save "newanalysts.dta", replace

use "newannouncements.dta", clear 
joinby symbol datadate using "newanalysts.dta"
rename rdq anndate
save "newstockreturns.dta", replace

use "stockreturns.dta", clear
sort crspcode anndate

joinby crspcode anndate using "newstockreturns.dta"
rename cyear year
save "newstockreturns.dta",replace

joinby compustatcode year using "big4.dta"
browse

drop if earnings == .
drop if prccq<2.5

gen surprise = (earnings - forecast)/prccq
drop if surprise> abs(0.05) 

sum bhar01, d
replace bhar01=r(p1) if bhar01<r(p1)
replace bhar01=r(p99) if bhar01>r(p99)

//3a
reg bhar01 surprise, robust cluster(compustatcode)

//3b
gen surprise_big4auditor = bhar01*surprise
reg bhar01 surprise big4auditor surprise_big4auditor, robust cluster(compustatcode)

//3c
sort surprise
browse
xtile Surprise_5 = surprise ,nq(5)

tabstat surprise, stat(n mean min max sd p50) by (Surprise_5)

sqreg bhar01 surprise if Surprise_5==1
estimates store Surprise_1
sqreg bhar01 surprise if Surprise_5==2
estimates store Surprise_2
sqreg bhar01 surprise if Surprise_5==3
estimates store Surprise_3
sqreg bhar01 surprise if Surprise_5==4
estimates store Surprise_4
sqreg bhar01 surprise if Surprise_5==5
estimates store Surprise_5

ssc install coefplot
coefplot (Surprise_1, label(surprise(0-20%))) (Surprise_2, label(surprise(20-40%))) (Surprise_3, label(surprise(40-60%))) (Surprise_4, label(surprise(60-80%))) (Surprise_5, label(surprise_(80-100%))), drop(_cons) xline(0) recast(bar) barwidth(0.25) format(%9.0f) title("Coefficent value of surprise by quantile")
