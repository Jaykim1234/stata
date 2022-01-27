cls //this clears the screen
clear all //this clears the memory
cd "C:\Users\Jinhyun\Documents\GitHub\stata\Financial econometrics\Week 6"
use USMacro_Quarterly.dta
tsset time
gen infl = 400*(ln(PCECTPI)- ln(L1.PCECTPI))
gen c_infl = 400*(ln(infl)- ln(L1.infl))
// What are the units of infl? Is infl measured in dollars, percentage points, percentage per quarter, percentage per year, 
// or something else? Explain.
// >> Qarterly percentage change in PI, measured in annual terms

// 4) Plot the value of infl from 1963:Q1 through 2012:Q4. Based on the plot, do you think that infl has 
// a stochastic trend? Explain. 

scatter infl time if tin(1963:Q1,2012:Q4)
line infl time if tin(1963:Q1,2012:Q4)
line c_infl time if tin(1963:Q1,2012:Q4)
twoway (line infl time if tin(1963q1, 2012q4), sort), ytitle(Inflation) ytitle(, size(large)) xtitle(, size(large)) ylabel(, angle(horizontal) scheme(s2mono) graphregion(fcolor(white) 
lcolor(white) ifcolor(white) ilcolor(white)) 


// Answer: yes it is stochastic
// 5) Compute the first four autocorrelations of infl. 
// Wat does it mean that the first four autocorrelations are all positive?

corrgram infl if tin(1960q1, 2012q4), lags(4)
corrgram c_infl if tin(1960q1, 2012q4), lags(4)
corrgram D.infl if tin(1960q1, 2012q4), noplot lags(4)
// Inflations influence the future inflation positively

regress infl L1.infl L2.infl L3.infl L4.infl if tin(1963q1, 2012q4),r


// 
//  8) Run an OLS regression of Δinflt on Δinflt-1. 
// Does knowing the change in inflation over the current quarter help predict the change in inflation 
// over the next quarter? Explain.

 regress c_infl L1.c_infl if tin(1963q1, 2012q4),r
 
 // Yes, the coefficient is -.2965516  and the p-value is 0.006 which is less than 0.01. 
 // This means the previous 1% inflation changes decrease the next inflation change by 0.2965516%-point on average which is significant at 1% level.
 
gen BIC_1 = ln(e(rss)/e(N)) + e(rank)*(ln(e(N))/e(N)) if tin(1962q1,2004q4)

gen BIC_1 = ln(e(rss)/e(N)) + e(rank)*2/e(N)) if tin(1962q1,2004q4)

 
 
 
 