cls //this clears the screen
clear all //this clears the memory

// set project folder
cd "C:\Users\Jinhyun\Desktop\Empirical Methods in Finance\Tutorial\w1"
use "combined dataset week1"

// Inflation-adjust total compensation (tdc1) to constant 1993-dollars using the time
// series of the US consumer price index.
gen TDC1_adinf = TDC1/CPI_norm
//ssc install winsor2


// Compute winsorized total compensation, winsorize by year symmetrically at the
// 0.5% level.
//Winsorize variables
winsor2 TDC1, suffix(_win) by(YEAR) cuts(0.5 99.5)
winsor2 TDC1_adinf, suffix(_win) by(YEAR) cuts(0.5 99.5)
winsor2 OPTION_AWARDS, suffix(_win) by(YEAR) cuts(0.5 99.5)
winsor2 STOCK_AWARDS, suffix(_win) by(YEAR) cuts(0.5 99.5)
winsor2 SALARY, suffix(_win) by(YEAR) cuts(0.5 99.5)
winsor2 BONUS, suffix(_win) by(YEAR) cuts(0.5 99.5)


// Plot two histograms of inflation-adjusted total compensation: raw and winsorized
// compensation. Do the most extreme outliers (left and right) represent data entry
// errors or correct entries in your opinion?
histogram TDC1_adinf, frequency
histogram TDC1_adinf_win, frequency
histogram TDC1_adinf, fraction
histogram TDC1_adinf_win, fraction


// Plot the mean and median (per year) of winsorized total compensation against time
// (y-axis: yearly mean/median; x-axis: year)
by YEAR, sort: egen TDC1_adinf_win_a = mean(TDC1_adinf_win)
by YEAR, sort: egen TDC1_adinf_win_h = median(TDC1_adinf_win)

// line TDC1_adinf_win_a TDC1_adinf_win_h YEAR, connect(line) scheme(s1mono) msize(small) xlabel(1992(2)2020) 
line TDC1_adinf_win_a TDC1_adinf_win_h YEAR, connect(line) lpattern(solid dash) lwidth(*1.5 *1.5) lcolor(blue red) scheme(s1mono) msize(small) xlabel(1992(2)2020)  ytitle("Mean fraction of options/stock compensation") title("The mean fractions of options and stock compensation")

// Compute the fraction of options, stock, bonus and salary in total pay. Is there a
// complication regarding this data? Are these data available for the entire time
// period 1993-2020? Why (not)?
gen frac_option =  OPTION_AWARDS_win/TDC1_win
gen frac_STOCK  =  STOCK_AWARDS_win/TDC1_win
gen frac_SALARY =  SALARY_win/TDC1_win
gen frac_BONUS  =  BONUS_win/TDC1_win
by YEAR, sort: egen frac_OPTION_mean =  mean(OPTION_AWARDS_win/TDC1_win)
by YEAR, sort: egen frac_STOCK_mean  =  mean(STOCK_AWARDS_win/TDC1_win)

// Plot the mean fractions of options and stock compensation per year (two lines in
// the same graph with y-axis: yearly mean fraction of options / stock compensation,
// x-axis: year).
graph twoway line frac_OPTION_mean frac_STOCK_mean YEAR, connect(line) lpattern(solid dash) lwidth(*1.5 *1.5) lcolor(blue red) scheme(s1mono) msize(small) xlabel(1992(2)2020)  ytitle("Mean fraction of options/stock compensation") title("The mean fractions of options and stock compensation")
