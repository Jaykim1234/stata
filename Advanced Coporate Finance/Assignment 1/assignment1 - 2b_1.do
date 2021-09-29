clear all
cls

use "C:\Users\user\Desktop\master\Semester 1\ACF\Assignments\case1_dataset.dta" 


// br
// describe

//Of relevance cash, short_term_debt, long_term_debt, cashflows, cashflow_volatility, used_credit_line, industry, total_liabilities, r_and_d_investment, PPandE, acquisitions, datadate, year, gvkey. Not dropping anything but keeping in mind.

//Only Pharma relevant, so keep pharma only
keep if industry == "Pharmaceuticals"
tsset gvkey year

//Check if data skewed, found mode of year frequency using ssc hsmode option, so I capture all firms

// hist firm_age if year==2005, freq
// hist market_capitalization if year==2005, freq
// hist year, freq

//Use median to separate because of how skewed data is

//Separate by age using dummy variable old
egen median_age = median(firm_age) if year==2005
replace median_age = 14 if median_age==.
gen old = 1 if firm_age > median_age
replace old = 0 if old==. 

tsset gvkey year

//generate total debt
gen total_debt = short_term_debt + long_term_debt


//creating mean values of different variables by age and year
sort old year

by old year: egen avg_cash = mean(cash)
by old year: egen avg_cashflow = mean(cashflows)
by old year: egen avg_rd = mean(r_and_d_investment)
by old year: egen avg_capex = mean(capital_expenditures)
by old year: egen avg_total_debt = mean(total_debt)
label var avg_cash "Average Cash Holdings"
label var avg_cashflow "Average Cashflow"
label var avg_rd "Average R&D Expense"
label var avg_capex "Average Capital Expenditure"
label var avg_total_debt "Average Total Debt"

label var year "Year"
//blank for new vars -> remember to put them in the next two loops if need be
// by old year: egen avg_x = mean(x)
// by old year: egen avg_x = mean(x)
// by old year: egen avg_x = mean(x)

//separating for graph
global list1 avg_cash avg_cashflow avg_capex avg_rd avg_total_debt
foreach var of global list1 {
    gen `var'_old = `var'*old 
	replace `var'_old=. if `var'_old==0
	gen `var'_new = `var' if `var'_old==.
}

//graphs
// preserve
// foreach var of global list1 {
//     graph twoway line `var'_old `var'_new year, legend(label(1 "Old Firms") label(2 "Young Firms")) title(`: variable label `var'' by Firm Age) name(`var'_graph)
// 	graph export `var'_old.png
//	
// }

foreach var of global list1 {
	graph twoway line `var'_old year, lpattern(solid) lw(vtick) title(`: variable label `var'' for Old Firms ) name(`var'_graph_old)
	graph twoway line `var'_new year, lpattern(shortdash) lw(vtick) title(`: variable label `var'' for Young Firms ) name(`var'_graph_new)
	graph combine `var'_graph_old `var'_graph_new, name(`var'_graph)
	}


-----------------------------------------------------------------------------------------------------------------
//same process with market cap
//easier than working around previous code

// clear all
// cls
// use "C:\Users\user\Desktop\master\Semester 1\ACF\Assignments\case1_dataset.dta" 
// keep if industry == "Pharmaceuticals"
// tsset gvkey year
// egen median_size = median(market_capitalization) if year==2005
// replace median_size = 195.0373 if median_size==.
// gen big = 1 if market_capitalization > median_size
// replace big = 0 if big==. 
//
// tsset gvkey year
// gen total_debt = short_term_debt + long_term_debt
//
//
// //creating mean values of different variables by age and year
// sort big year
//
// by big year: egen avg_cash = mean(cash)
// by big year: egen avg_cashflow = mean(cashflows)
// by big year: egen avg_rd = mean(r_and_d_investment)
// by big year: egen avg_capex = mean(capital_expenditures)
// by big year: egen avg_total_debt = mean(total_debt)
//
// label var avg_cash "Average Cash Holdings"
// label var avg_cashflow "Average Cashflow"
// label var avg_rd "Average R&D Expense"
// label var avg_capex "Average Capital Expenditure"
// label var avg_total_debt "Average Total Debt"
//
// label var year "Year"
// //blank for new vars -> remember to put them in the next two loops if need be
// // by big year: egen avg_x = mean(x)
// // by big year: egen avg_x = mean(x)
// // by big year: egen avg_x = mean(x)
//
// //separating for graph
// global list1 avg_cash avg_cashflow avg_capex avg_rd avg_total_debt
// foreach var of global list1 {
//     gen `var'_big = `var'*big 
// 	replace `var'_big=. if `var'_big==0
// 	gen `var'_small = `var' if `var'_big==.
// }
//
// //graphs
// // preserve
// // foreach var of global list1 {
// //     graph twoway line `var'_big `var'_new year, legend(label(1 "Large Firms") label(2 "Small Firms")) title(`: variable label `var'' by Firm Size) name(`var'_graph)
// // 	graph export `var'_big.png
// //	
// // }
// // lpattern(solid longdash shortdash dash )  lw(tick middle middle middle)
//
//
//
// foreach var of global list1 {
// 	graph twoway line `var'_big year, lpattern(solid) lw(vtick) title(`: variable label `var'' for Large Firms ) name(`var'_graph_big)
// 	graph twoway line `var'_small year, lpattern(shortdash) lw(vtick) title(`: variable label `var'' for Small Firms ) name(`var'_graph_small)
// 	graph combine `var'_graph_big `var'_graph_small, name(`var'_graph)
// 	}
//
//
// // foreach var of global list1 {
// // 	graph twoway line `var'_big year, lpattern(solid) lw(vtick) title(`: variable label `var'' for Large Firms ) name(`var'_graph_big)
// // 	graph twoway line `var'_small year, lpattern(shortdash) lw(tick) title(`: variable label `var'' for Small Firms ) name(`var'_graph_small)
// // 	graph combine `var'_graph_big `var'_graph_small, name(`var'_graph)
// // 	}