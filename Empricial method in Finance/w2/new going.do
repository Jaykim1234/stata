cls
clear all

/* set the directory of the folder where you store all data 
   pertaining to this exercise in your local machine */
   cd "C:\Users\Jinhyun\Desktop\Empirical Methods in Finance\Tutorial\w2"

****************************************************************
* Merge IBES forecasts and actuals
****************************************************************
//
// 	clear
// 	use IBES-Actuals
// 	drop if pdicity=="ANN"
// 	duplicates report ticker pends
// 	duplicates drop ticker pends, force
// 	rename pends fpe
// 	save IBES-Actuals-Final, replace
//
//	
// 	clear
// 	use IBES-Forecasts
// 	rename fpedats fpe
// 	drop if fiscalp=="ANN"
// 	duplicates report ticker fpe
// 	save IBES-Forecasts-Final, replace

 	clear
 	use IBES-Forecasts-Final
 	count
 	joinby ticker fpe using IBES-Actuals-Final, unmatched(master)
 	tab _merge
 	keep if _merge==3
 	drop _merge
 	rename anndats ead
 	label variable ead "Earnings annoucement date"
 	count	
 	* keep only forecasts issued before the announcement of the actual:
 	keep if statpers<ead
 	* keep only forecast that is closest to announcement date of the actual:
 	gen fore_dif = ead - statpers // Here I have made a new variable that shows the difference between annoucement day and the forcasts(statpers)
 	sort ticker fore_dif // I have sorted data by company(ticker) and by the new variabe fore_dif (day difference)
 	by ticker: keep if _n == 1 // This codes keep only the first data at each company(ticker). So I have only kept the data with smallest day difference.
 	drop fore_dif
	
 save dataset-t, replace

*************************************************************************************************************
* Merge in the price (prc) on day t-5 or t-6 or t-7 relative to annoucement date, depending on availability, 
* ie if there is no price available for t-5, try t-6, then t-7
*************************************************************************************************************
	* Note: the file CRSP-Stocks contains the daily stock returns and prices from CRSP for share codes 10 and 11, 
	* ie go to WRDS --> CRSP --> Stock / Security Files --> Daily stock file, and download ncusip, permno, ret, prc, shrcd, shrout
	* for the relevant sample period and shares codes 10 and 11

	* merge in the IBES-CRSP linking table available at WRDS-->Linking Suite by WRDS--> IBES CRSP Link	
	clear
	use dataset-t
	rename ticker TICKER
	joinby TICKER using IBES-CRSB-linking-table, unmatched(master)
	rename TICKER ticker
	tab _merge
	drop _merge
	
	* merge in stock price one week prior to announcement date
	g date = ead-7
	format %td date
	duplicates report PERMNO date
	duplicates drop PERMNO date, force
	joinby PERMNO date using CRSP-Stocks, unmatched(master) update
	tab _merge
	drop _merge
	count if PRC!=.
	replace date=date-1 // Replace data to t-6. Now we can use t-6 data to get PRC from CRSP-Stocks table
	format %td date
	joinby PERMNO date using CRSP-Stocks, unmatched(master) update
	tab _merge
	drop _merge
	count if PRC!=.
	replace date=date-1 // Replace data to t-5. Now we can use t-6 data to get PRC from CRSP-Stocks table
	format %td date
	joinby PERMNO date using CRSP-Stocks, unmatched(master) update
	tab _merge
	drop _merge
	count if PRC!=.
	rename PRC prc
	rename SHROUT shrout
	rename ret RET
	
// 	* check variable prc:
// 	...
save dataset-t1, replace

 
 * apply filters according to DellaVigna/Pollet, Hirshleifer et al. and Livnat/Mendenhall
	drop if prc<5
	drop if value>prc
	drop if medest>prc
	drop if prc*shrout<5000
	drop date
	drop ret	
	drop shrcd
	drop permco
	drop shrout
	drop if prc==.

save dataset-t2, replace

* calculate earnings surprise
	clear
	use dataset-t2
	g Sur=(value-medest)/prc
	drop if Sur==.
	drop prc

* define 11 quantiles of earnings surprises separately by quarter
	* install xtileJ from Judson Caskey's web page
	g quarter = qofd(ead)
	xtileJ SurQ7to11 = Sur if Sur>0, nquantiles(5) by(quarter)	
	
// install xtileJ from Judson Caskey's web page	
 