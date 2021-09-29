cls //this clears the screen
clear all //this clears the memory
// set project folder
cd "C:\Users\user\Desktop\master\Semester 1\ACF\Assignments"

use case1_dataset

//Describe the dataset
desc

// Show the summary of the dataset
sum

// Q2
// The intention of this code is to find the foundation year of a firms
// Grouped data by the id of the firm and get the minimum value which is the foundation year.
egen starting_year = min(datadate) , by(gvkey)  

// Make quartile of datadate(founding of companyies)
xtile q_starting_year =  starting_year, nq(3)
tabstat datadate, stat(n min max) by(q_starting_year)
// Generate variable for categorising firms as 'Young' 'Middle' 'Mature' before drop datadate

gen age_firm = 2 if q_starting_year == 1 // Mature
replace age_firm = 1 if q_starting_year == 2 // Middle
replace age_firm = 0 if q_starting_year == 3 // Young

// Drop data before year 2000
drop if year<2000


// Q2 - a

// Generate variable that contains cash data categorised by industries

// Make a variable showing yearly sum values of cash "Pharmaceuticals"

egen sum_phr_cash_holding_yearly = sum(cash)   if industry == "Pharmaceuticals", by(year) 
egen sum_health_cash_holding_yearly = sum(cash)   if industry == "Healthcare", by(year)  
egen sum_Ch_cash_holding_yearly = sum(cash)   if industry == "Chemicals", by(year) 
egen sum_d_soft_cash_holding_yearly = sum(cash)   if industry == "Digital Software", by(year) 

// Make combined graphs
twoway line sum_phr_cash_holding_yearly sum_health_cash_holding_yearly sum_d_soft_cash_holding_yearly sum_Ch_cash_holding_yearly  year , sort lpattern(solid longdash shortdash dash )  lw(tick middle middle middle) lc(red green blue black)  legend(order( 1 "Pharmaceuticals" 2 "Healthcare"  3 "Digital Software" 4 "Chemicals")) title("Cash holding trends")  ytitle("Sum of Cash holdings") xtitle("year") 


// Q2 b

//General

egen sum_phr_cash_yearly    = sum(cash)   if industry == "Pharmaceuticals", by(year) 
egen sum_phr_shortdebt_yearly    = sum(short_term_debt)   if industry == "Pharmaceuticals", by(year)
egen sum_phr_longdebt_yearly    = sum(long_term_debt)   if industry == "Pharmaceuticals", by(year) 
egen sum_phr_inv_yearly    = sum(r_and_d_investment)   if industry == "Pharmaceuticals", by(year)
egen sum_phr_cashflows_yearly    = sum(cashflows)   if industry == "Pharmaceuticals", by(year) 

twoway scatter sum_phr_cash_yearly year if sum_phr_cash_yearly !=. , name(cash) ytitle("Cash") 
twoway scatter sum_phr_shortdebt_yearly year if sum_phr_shortdebt_yearly !=. , name(shortdebt) ytitle("Short term debt")
twoway scatter sum_phr_longdebt_yearly year if sum_phr_longdebt_yearly !=. , name(longdebt) ytitle("Long term debt")
twoway scatter sum_phr_inv_yearly year if sum_phr_inv_yearly !=. , name(investment) ytitle("Investment")
twoway scatter sum_phr_cashflows_yearly year if sum_phr_cashflows_yearly !=. , name(cashflow) ytitle("Cashflows")

graph combine cash shortdebt longdebt investment cashflow, name(General_firms)


// Small vs Large
// We have categorised the firm size with market capitalization
// Categories of firm are small, middle, and large

egen year_latest = max(year) , by(gvkey) // Generate variable that shows the lastest year 
gen market_cap  = market_capitalization if year == year_latest // Select market capitalization of the lastest year of companyies in the datadate.

// Make quartile of market capitalization
xtile market_cap_q =  market_cap, nq(3)

// Describe data statistics of market_cap variable
tabstat market_cap, stat(n mean min max sd p50) by(market_cap_q)

// . tabstat market_cap, stat(n mean min max sd p50) by(market_cap_q)
//
// Summary for variables: market_cap
// Group variable: market_cap_q (3 quantiles of market_cap)
//
// market_cap_q |         N      Mean       Min       Max        SD       p50
// -------------+------------------------------------------------------------
//            1 |      2696  11.40949         0   32.0796  8.965972  9.210753
//            2 |      2696  136.1913  32.08863  385.9566  95.51707  106.2667
//            3 |      2695  7620.391   386.285  615336.4  28538.69  1594.567
// -------------+------------------------------------------------------------
//        Total |      8087  2588.708         0  615336.4  16852.68  106.2646
// --------------------------------------------------------------------------

gen     firm_size = 0 if market_cap < 32.0796 // Small size
replace firm_size = 1 if market_cap >= 32.08863 & market_cap <= 385.9566 // Middle size
replace firm_size = 2 if market_cap > 386.285 //  Large size

tabstat firm_size, stat(n mean min max sd p50) by(market_cap_q)

// Summary for variables: firm_size
// Group variable: market_cap_q (3 quantiles of market_cap)
//
// market_cap_q |         N      Mean       Min       Max        SD       p50
// -------------+------------------------------------------------------------
//            1 |     22378         0         0         0         0         0
//            2 |     22392  1.000402         0         2  .0320474         1
//            3 |     22364         2         2         2         0         2
// -------------+------------------------------------------------------------
//        Total |     67134  .9999255         0         2  .8165847         1
// --------------------------------------------------------------------------
// twoway scatter small_sum_phr_cash_yearly year if sum_phr_cash_yearly !=. & firm_size = 0 , name(s_cash) ytitle("Small firms Cash") 

tabstat sum_phr_cash_yearly, stat(n mean min max sd p50) by(market_cap_q)

gen S_sum_phr_cash_yearly = sum_phr_cash_yearly if firm_size == 0
gen L_sum_phr_cash_yearly = sum_phr_cash_yearly if firm_size == 2

gen S_sum_phr_shortdebt_yearly = sum_phr_shortdebt_yearly if firm_size == 0
gen L_sum_phr_shortdebt_yearly = sum_phr_shortdebt_yearly if firm_size == 2

gen S_sum_phr_longdebt_yearly = sum_phr_longdebt_yearly if firm_size == 0
gen L_sum_phr_longdebt_yearly = sum_phr_longdebt_yearly if firm_size == 2

gen S_sum_phr_inv_yearly = sum_phr_inv_yearly if firm_size == 0
gen L_sum_phr_inv_yearly = sum_phr_inv_yearly if firm_size == 2

gen S_sum_phr_cashflows_yearly = sum_phr_cashflows_yearly if firm_size == 0
gen L_sum_phr_cashflows_yearly = sum_phr_cashflows_yearly if firm_size == 2

// Make graph of small firms 

twoway scatter S_sum_phr_cash_yearly year if S_sum_phr_cash_yearly !=. , name(s_cash) ytitle("Cash ") title("Cash (Small firms)")
twoway scatter S_sum_phr_shortdebt_yearly year if S_sum_phr_shortdebt_yearly !=. & firm_size == 0, name(s_shortdebt) ytitle("Short term debt") title("Short term debt (Small firms)")
twoway scatter S_sum_phr_longdebt_yearly year if S_sum_phr_longdebt_yearly !=. & firm_size == 0, name(s_longdebt) ytitle("Long term debt") title("Long term debt (Small firms)")
twoway scatter S_sum_phr_inv_yearly year if S_sum_phr_inv_yearly !=. & firm_size == 0, name(s_investment) ytitle("Investment") title("Investment (Small firms)")
twoway scatter S_sum_phr_cashflows_yearly year if S_sum_phr_cashflows_yearly !=. & firm_size == 0, name(s_cashflow) ytitle("Cashflows") title("Cashflows (Small firms)")

graph combine s_cash s_shortdebt s_longdebt s_investment s_cashflow, name(Small_firms)
 
// Make graph of Large firms 

twoway scatter L_sum_phr_cash_yearly year if L_sum_phr_cash_yearly !=. & firm_size == 2, name(L_cash) ytitle("Cash") title("Cash (Large firms)")
twoway scatter  L_sum_phr_shortdebt_yearly year if L_sum_phr_shortdebt_yearly !=. & firm_size == 2, name(L_shortdebt) ytitle("Short term debt") title("Short term debt (Large firms)")
twoway scatter L_sum_phr_longdebt_yearly year if L_sum_phr_longdebt_yearly !=. & firm_size == 2, name(L_longdebt) ytitle("Long term debt")  title("Long term debt (Large firms)")
twoway scatter L_sum_phr_inv_yearly year if L_sum_phr_inv_yearly !=. & firm_size == 2, name(L_investment) ytitle("Investment")  title("Investment (Large firms)")
twoway scatter L_sum_phr_cashflows_yearly year if L_sum_phr_cashflows_yearly !=. & firm_size == 2, name(L_cashflow) ytitle("Cashflows")  title("Cashflows (Large firms)")

graph combine L_cash L_shortdebt L_longdebt L_investment L_cashflow, name(Large_firms)


// Young vs Mature firms

// Create variable of "Pharmaceuticals" industries with firm age

gen Y_sum_phr_cash_yearly = sum_phr_cash_yearly if age_firm == 0 //Young
gen M_sum_phr_cash_yearly = sum_phr_cash_yearly if age_firm == 2 //Mature

gen Y_sum_phr_shortdebt_yearly = sum_phr_shortdebt_yearly if age_firm == 0 //Young
gen M_sum_phr_shortdebt_yearly = sum_phr_shortdebt_yearly if age_firm == 2 //Mature

gen Y_sum_phr_longdebt_yearly = sum_phr_longdebt_yearly if age_firm == 0 //Young
gen M_sum_phr_longdebt_yearly = sum_phr_longdebt_yearly if age_firm == 2 //Mature

gen Y_sum_phr_inv_yearly = sum_phr_inv_yearly if age_firm == 0 //Young
gen M_sum_phr_inv_yearly = sum_phr_inv_yearly if age_firm == 2 //Mature

gen Y_sum_phr_cashflows_yearly = sum_phr_cashflows_yearly if age_firm == 0 //Young
gen M_sum_phr_cashflows_yearly = sum_phr_cashflows_yearly if age_firm == 2 //Mature

// Make graph of young firms 

twoway scatter Y_sum_phr_cash_yearly year if Y_sum_phr_cash_yearly !=. , name(Y_cash) ytitle("Cash ") title("Cash (Young firms)")
twoway scatter Y_sum_phr_shortdebt_yearly year if Y_sum_phr_shortdebt_yearly !=. & firm_size == 0, name(Y_shortdebt) ytitle("Short term debt") title("Short term debt (Young firms)")
twoway scatter Y_sum_phr_longdebt_yearly year if Y_sum_phr_longdebt_yearly !=. & firm_size == 0, name(Y_longdebt) ytitle("Long term debt") title("Long term debt (Young firms)")
twoway scatter Y_sum_phr_inv_yearly year if Y_sum_phr_inv_yearly !=. & firm_size == 0, name(Y_investment) ytitle("Investment") title("Investment (Young firms)")
twoway scatter Y_sum_phr_cashflows_yearly year if Y_sum_phr_cashflows_yearly !=. & firm_size == 0, name(Y_cashflow) ytitle("Cashflows") title("Cashflows (Young firms)")

graph combine Y_cash Y_shortdebt Y_longdebt Y_investment Y_cashflow, name(Young_firms)
 
// Make graph of Mature firms 

twoway scatter M_sum_phr_cash_yearly year if M_sum_phr_cash_yearly !=. & firm_size == 2, name(M_cash) ytitle("Cash") title("Mature firms Cash")
twoway scatter  M_sum_phr_shortdebt_yearly year if M_sum_phr_shortdebt_yearly !=. & firm_size == 2, name(M_shortdebt) ytitle("Short term debt") title("Short term debt (Mature firms)")
twoway scatter M_sum_phr_longdebt_yearly year if M_sum_phr_longdebt_yearly !=. & firm_size == 2, name(M_longdebt) ytitle("Long term debt")  title("Long term debt (Mature firms)")
twoway scatter M_sum_phr_inv_yearly year if M_sum_phr_inv_yearly !=. & firm_size == 2, name(M_investment) ytitle("Investment")  title("Investment (Mature firms)")
twoway scatter M_sum_phr_cashflows_yearly year if M_sum_phr_cashflows_yearly !=. & firm_size == 2, name(M_cashflow) ytitle("Cashflows")  title("Cashflows (Mature firms)")

graph combine M_cash M_shortdebt M_longdebt M_investment M_cashflow, name(Mature_firms)



// Temporal

// Make individual graphs with selected industries

// twoway connected sum_phr_cash_holding_yearly year, sort(year) ytitle("Cash") title( "Pharmaceuticals" ) , name(cash_p)  // Sum,"Pharmaceuticals" 
// twoway connected sum_health_cash_holding_yearly year, sort(year) ytitle("Cash") title("Healthcare" ) , name(cash_h)  // Sum, "Healthcare"
// twoway connected sum_Ch_cash_holding_yearly year, sort(year) ytitle("Cash") title("Chemicals" ) , name(cash_c)  // Sum, "Chemicals"
// twoway connected sum_d_soft_cash_holding_yearly year, sort(year) ytitle("Cash")  title("Digital Software") , name(cash_d) // Sum, "Digital Software"
//
// graph combine cash0 cash1 cash2 cash3, name(Cash holdings by industries)
// egen mean_d_soft_cash_holding_yearly = mean(cash) if industry == "Digital Software", by(year) 
// twoway connected mean_phr_cash_holding_yearly year, sort(year) // Mean, "Pharmaceuticals"
// twoway connected mean_health_cash_holding_yearly year, sort(year) // Mean, "Healthcare"
// twoway connected  mean_Ch_cash_holding_yearly year, sort(year) // Mean, "Chemicals"
// twoway connected  mean_d_soft_cash_holding_yearly year, sort(year) // Mean, "Digital Software"

// twoway scatter cash short_term_debt long_term_debt r_and_d_investment cashflows year  if industry == "Pharmaceuticals", sort lpattern(solid longdash shortdash dash dot)  lw(tick middle middle middle middle) lc(red green blue black)  legend(order( 1 "cash" 2 "short_term_debt"  3 "long_term_debt" 4 "r_and_d_investment" 5 "cashflows")) title("The pharmaceutical industry ")  xtitle("year")

// gen phr_annual_cash_hol = cash if industry == "Pharmaceuticals"
// gen phr_short_debt = short_term_debt if industry == "Pharmaceuticals"
// gen phr_long_debt = long_term_debt if industry == "Pharmaceuticals"
// gen phr_investment = r_and_d_investment if industry == "Pharmaceuticals"
// gen phr_cashflows = cashflows if industry == "Pharmaceuticals"
// twoway line sum_phr_cash_holding_yearly sum_health_cash_holding_yearly sum_d_soft_cash_holding_yearly year , sort lpattern(dot  dash solid)  legend(order(3 "Pharmaceuticals" 2 "Healthcare" 1 "Digital Software")) title("Sum of cash holding")
// profileplot mean_phr_cash_holding_yearly mean_health_cash_holding_yearly mean_d_soft_cash_holding_yearly, by(year) plot1opt(lpattern(solid)) plot2opt(lpattern(dash)) plot3opt(lpattern(dot)) 
// legend(order(3 "y3 var" 2 "y2 var" 1 "y1 var"))
// gen pharmaceutical_cash_holding = cash if industry == "Pharmaceuticals"
// egen cash_holding_yearly = total(pharmaceutical_cash_holding), by(year)
// egen mean_phr_cash_holding_yearly = mean(pharmaceutical_cash_holding) if industry == "Pharmaceuticals", by(year) 
// egen sum_phr_cash_holding_yearly = sum(pharmaceutical_cash_holding)   if industry == "Pharmaceuticals", by(year) 
// egen mean_phr_cash_holding_yearly = mean(pharmaceutical_cash_holding) if pharmaceutical_cash_holding != ., by(year) 
// egen sum_phr_cash_holding_yearly = sum(pharmaceutical_cash_holding)  if pharmaceutical_cash_holding != ., by(year) 
// twoway line mean_of_int mean_of_int_sn mean_of_int_so sd_of_int sd_of_int_sn sd_of_int_so Visit, sort lpattern(solid dash dot longdash shortdash dash_dot) legend(row(2)) name(g1)
// profileplot mean_of_int mean_of_int_sn mean_of_int_so sd_of_int sd_of_int_sn sd_of_int_so, by(Visit) plot1opt(lpattern(solid)) plot2opt(lpattern(dash)) plot3opt(lpattern(longdash)) plot4opt(lpattern(shortdash)) plot5opt(lpattern(dash_dot)) legend(row(2)) name(g2)
