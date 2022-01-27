cls
clear all

cd "C:\Users\Jinhyun\Desktop\Empirical Methods in Finance\Tutorial\w2"


****************************************************************
* Merge IBES forecasts and actuals
****************************************************************
	clear
	use "C:\Users\yanni\Desktop\Universiteit van Amsterdam\Empirical Methods in Finance\IBES-Actuals.dta"
	drop if pdicity=="ANN"
	duplicates report ticker pends
	duplicates drop ticker pends, force
	rename pends fpe
	save IBES-Actuals-Final, replace

	
	clear
	use "C:\Users\yanni\Desktop\Universiteit van Amsterdam\Empirical Methods in Finance\IBES-Forecasts.dta"
	rename fpedats fpe
	drop if fiscalp=="ANN"
	duplicates report ticker fpe
	save IBES-Forecasts-Final, replace
	
	
	clear
	use "C:\Users\yanni\Desktop\Universiteit van Amsterdam\Empirical Methods in Finance\IBES-Forecasts-Final.dta"
	count
	joinby ticker fpe using "C:\Users\yanni\Desktop\Universiteit van Amsterdam\Empirical Methods in Finance\IBES-Actuals-Final.dta", unmatched(master)
	tab _merge
	keep if _merge==3
	drop _merge
	rename anndats ead
	label variable ead "Earnings Annoucement Date"
	count	
	* keep only forecasts issued before the announcement of the actual:
	keep if statpers<ead
	* keep only forecast that is closest to announcement date of the actual:
	gen diff_date = ead - statpers
	gen quarter = quofd(fpe)
	format quarter %tq
	egen min_diff_date = min(diff), by (ticker quarter)
	keep if diff_date == min_diff_date
	duplicates report ticker fpe

save dataset-1, replace


*************************************************************************************************************
* Merge in the price (prc) on day t-5 or t-6 or t-7 relative to annoucement date, depending on availability, 
* ie if there is no price available for t-5, try t-6, then t-7
*************************************************************************************************************
	* Note: the file CRSP-Stocks contains the daily stock returns and prices from CRSP for share codes 10 and 11, 
	* ie go to WRDS --> CRSP --> Stock / Security Files --> Daily stock file, and download ncusip, permno, ret, prc, shrcd, shrout
	* for the relevant sample period and shares codes 10 and 11

	
	* merge in the IBES-CRSP linking table available at WRDS-->Linking Suite by WRDS--> IBES CRSP Link
	use (--> Downloaded WRDS Linking tables)
	save Linktable_IBES_CRSP, replace
	
	clear
	use dataset-1
	joinby ticker using Linktable_IBES_CRSP, unmatched(master)  
	tab _merge
	drop if merge_!=3
	drop_merge
	save dataset-1_Linked, replace
	
		
	* merge in stock price one week prior to announcement date
	clear
	use (--> dowloaded crsp stocks data?)
	save CRSP-stocks, replace
	
	//5 trading days prior (-7 days)
	g date = ead-7 
	duplicates report permno date
	duplicates drop permno date, force
	joinby permno date using CRSP-Stocks1, unmatched(master) update 
	tab _merge
	drop _merge
	count if PRC!=.
	
	//6 trading days prior
	replace date=date-1 if PRC == .
	duplicates report permno date
	duplicates drop permno date, force
	joinby permno date using CRSP-Stocks1, unmatched(master) update 
	tab _merge
	drop _merge
	count if PRC!=.
	
	//7 trading days prior
	replace date=date-1 if PRC ==.
	duplicates report permno date
	duplicates drop permno date, force
	joinby permno date using CRSP-Stocks1, unmatched(master) update 
	tab _merge
	drop _merge
	rename PRC prc
	count if prc!=.
	
	* check variable prc:
	count id prc!=.
	drop if prc==.

	
* apply filters according to DellaVigna/Pollet,
*  Hirshleifer et al. and Livnat/Mendenhall
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

save dataset-2, replace

	
* calculate earnings surprise
	clear
	use dataset-2
	g Sur=(value-medest)/prc
	drop if Sur==.
	drop prc


* define 11 quantiles of earnings surprises separately by quarter
	* install xtileJ from Judson Caskey's web page
	g quarter = qofd(ead)
	xtileJ SurQ7to11 = Sur if Sur>0, nquantiles(5) by(quarter)
	xtileJ SurQ1to5 = Sur if Sur<0, nquantiles(5) by(quarter)
	//Get the quantile for the whole data instead of separate data(<0 or >0)
	gen SurQ = SurQ7to11 + 6 
	replace SurQ = SurQ1to5 if SurQ ==.
	replace SurQ = 6 if SurQ ==.
	drop SurQ1to5 SurQ7to11
	
save dataset3, replace


****************************************************************
* expand dataset to [-35/+35] days
****************************************************************
	clear
	use dataset-3
	duplicates report ticker fpe
	expand 71
	sort ticker fpe
	by ticker fpe: g period = [_n]
	replace period=36-period if period>=36
	sort ticker fpe period

* fill in calendar dates
	g date = ead+period
	format date %td
	

* merge in crsp market return
	joinby date using (--> downloaded return crsp data?)
	tab _merge
	drop if _merge!= 3
	drop_merge
// 	you just created 35 days before and after, but in calender dates (7 days), so on saturday and sunday there will not be a return so approx 5/7 days can be successfully merged.

*****************************************************************************************
* define event time such that date zero is the day of the announcement day
*****************************************************************************************
	drop if vwretd==.
	g period=0 if date==ead
	forvalues i=-35/35 {
		replace period= `i' id date==anndats+`i'
		}
	sort ticker fpe ead date


* drop observations outside of tradingdays [-20,+20]
	drop if !inrange(period,-20,+20)
	tab period
	bysort ticker fpe: egen numperiods=count(period)
	tab numperiods
	drop if numperiods<21
	drop numperiods
	sort ticker fpe date
	tab period

	
* merge in stock returns
	joinby permno date using (downloaded crsp_stocks data)
	tab _merge
	drop _merge


* drop forcasts observations with incomplete return data on [-20,+20]
	bysort ticker fpe: egen numobs=count(ret)
	drop if numobs<41
	drop numobs
	drop shrcd permco prc shrout
		
save dataset-4, replace



* code market-adusted CARs around t=0
	clear
	use dataset-4
	sort ticker fpe period
	g AR  = ret-vwretd
	* normalize CAR to zero in t=-1:
	g CAR = 0 if period==-1
	* cumulate forward:
	replace CAR = CAR[_n-1]+AR[_n-1] if CAR==. & period>-1 & CAR[_n-1]!=. & ticker==ticker[_n-1] & fpe==fpe[_n-1]
	* cumulate backward:
	forvalue n=1/19{
		replace CAR = CAR[_n+1]-AR[_n+1] if CAR==. & period<-1 & CAR[_n+1]!=. & ticker==ticker[_n+1] & fpe==fpe[_n+1]
	}
	
	sort ticker fpe period

	
* express CAR in percent
	replace CAR  = CAR*100


* define CAR[-1,+1] for each forecast. This should be the same number for each ticker-fpe combination
	gen CAR3 = AR[_n-1]*100 + AR[_n]*100 + AR[_n+1]*100 if period==0
	by ticker fpe: egen CAR2=max(CAR3)
	gen cart = AR[_n-2]*100 + AR[_n-1]*100 + AR[_n+1]*100 + AR[_n+2]*100 if period==0
	drop AR CAR3 cart
	
	
save dataset-5, replace




* Q2: Descriptive statistics

	* Panel A
	clear
	use dataset-5
	rename anndats ead
	duplicates drop permno fpe ead, force
	g dow=dow(ead)
	tab dow
	
	* Panel C
	g obs = "Other Days"
	replace obs="Friday" if dow == 5
	tab obs SurQ11 , sum(Sur) mean obs
	
* Q3: Illustration of the market reaction to surprises
	clear
	use dataset-5
	by period SurQ11, sort: egen CAR_mean = mean(CAR)
	duplicates drop period SurQ11, force
	xtset period
	xtline CAR_mean, overlay t(period) i(SurQ11)
	
* Q4: Illustration of immediate response (3-day announcement return), Fridays vs non-Fridays
	clear
	use dataset-5
 	duplicates drop ticker fpe, force // I don't know why this commnad is at the given do file.
	rename anndats ead
	g Fri = dow(ead)==5
	* generate average 3-day CAR for each surprise quantile and separately for Fri and non-Fri:
	by SurQ11 Fri, sort : egen CAR3day_avg = mean(CAR3day)
	duplicates drop SurQ11 Fri, force
	g CAR3day_avg_f = CAR3day_avg if Fri == 1
	g CAR3day_avg_nf = CAR3day_avg if Fri == 0
	line CAR3day_avg_f CAR3day_avg_nf SurQ11
	
* Q5: Regression 

	ssc install estout
	ssc install outreg2

clear
	cap erase temp.txt
	use dataset-5
	rename anndats ead
	g month=month(date)
	g year=year(date)
	duplicates drop ticker fpe, force

	* columns 1&2:
	g Fri = dow(ead)==5
	g FrixSurQ11 = Fri*SurQ11
	quietly: reg CAR3day Fri SurQ11 FrixSurQ11, robust
	outreg2 using q5_ols_result1.doc, adjr bdec(2) tdec(2) label
	g Frixmonth = Fri*month
	g Frixyear = Fri*year
	quietly: reg CAR3day Fri SurQ11 FrixSurQ11 Frixmonth Frixyear i.month i.year, robust
	outreg2 using q5_ols_result1.doc, adjr bdec(2) tdec(2) label append
	drop FrixSurQ11
	
	* columns 3&4:
	g SurQTop=(SurQ11==11)
	g FrixSurQTop = Fri*SurQTop	
	replace date =. if (SurQ11>=2 & SurQ11<=10)
	quietly:reg CAR3day Fri SurQTop FrixSurQTop, robust
	outreg2 using q5_ols_result1.doc, adjr bdec(2) tdec(2) label append
	g FrixSurQTopxmonth=Fri*SurQTop*month
	g FrixSurQTopxyear=Fri*SurQTop*year	
	quietly:reg CAR3day Fri SurQTop FrixSurQTop FrixSurQTopxmonth FrixSurQTopxyear i.month i.year, robust
	outreg2 using q5_ols_result1.doc, adjr bdec(2) tdec(2) label append
	drop SurQTop
	drop FrixSurQTop

	* columns 5&6:
	g SurQTop2=(SurQ11==10 | SurQ11==11)
	g FrixSurQTop2 = Fri*SurQTop2
	replace date= . if (SurQ11>=3 &SurQ11<=9)
	quietly:reg CAR3day Fri SurQTop2 Fri*SurQTop2,cluster(ead)
	outreg2 using q5_ols_result1, adjr bdec(2) tdec(2) label append
	g FrixSurQTop2xmonth=Fri*SurQTop2*month
	g FrixSurQTop2xyear=Fri*SurQTop2*year		
	quietly:reg CAR3day Fri SurQTop2 FrixSurQTop2 FrixSurQTop2xmonth FrixSurQTop2xyear i.month i.year, robust
	outreg2 using q5_ols_result1, adjr bdec(2) tdec(2) label append
	seeout
	
	
	* Q6: Regression (timing of announcements?)
	clear
	cap erase temp.txt
	use dataset-5 
	duplicates drop ticker fpe, force
	rename anndat ead
	//generate dummy variables for 25% and 10% quantile
	xtileJ Sur_4=Sur,  nquantiles(4) by(quarter)
	xtileJ Sur_10=Sur,  nquantiles(10) by(quarter)
	g D0 = (Sur<0)
	g D25=.
	replace D25=1 if Sur_4==1
	g D10=.
	replace D10=1 if Sur_10==1
	g Fri = dow(ead)==5

	//create regression output
	quietly: reg Fri D0, cluster(quarter)
	est store R1
	quietly: reg Fri D25, cluster(quarter)
	est store R2
	quietly: reg Fri D10, cluster(quarter)
	est store R3
	quietly: reg Fri D0 D25 D10, cluster(quarter)
	est store R4
	outreg2 [R1 R2 R3 R4] using Q6.doc, replace tstat bdec(3) tdec(2)

* Q7: Sticky earnings surprises

	ssc install reghdfe
	ssc install ftools
	ssc install winsor2
	
	clear
	cap erase temp.txt
	use dataset-5 
	duplicates drop ticker fpe, force
	
	* winsorize or truncate Sur:
	winsor2 Sur,suffix(_win) cuts(0.5 99.5)
	* define quarter variable and tsset data:
	g qtr = qofd(anndats)
	format qtr %tq
	egen ID =group(ticker)
	sort ID qtr
	duplicates drop  ticker qtr,force
	tsset ID qtr

	* define lags of the earnings surprise:
	g SurL1 = l.Sur
	g SurL2 = l2.Sur
	g SurL3 = l3.Sur
	g SurL4 = l4.Sur
	
	* Regress using company ID and quarterly fixed effects
	quietly: reghdfe Sur_win SurL1, absorb(ID qtr) cluster(ID qtr) 
	est store S1
	quietly: reghdfe Sur_win SurL2, absorb(ID qtr) cluster(ID qtr) 
	est store S2
	quietly: reghdfe Sur_win SurL3, absorb(ID qtr) cluster(ID qtr) 
	est store S3
	quietly: reghdfe Sur_win SurL4, absorb(ID qtr) cluster(ID qtr) 
	est store S4
	outreg2 [S1 S2 S3 S4] using Q7.doc, replace tstat bdec(3) tdec(2)



	
	
	
	
	