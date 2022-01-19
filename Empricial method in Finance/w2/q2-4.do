cls
clear all

/* set the directory of the folder where you store all data 
   pertaining to this exercise in your local machine */
   cd "C:\Users\Jinhyun\Desktop\Empirical Methods in Finance\Tutorial\w2"
   
   * Q2: Descriptive statistics

	* Panel A
	clear
	use dataset-5
	rename anndats ead
	duplicates report permno fpe ead, force
	duplicates drop permno fpe ead, force
	g dow=dow(ead)
	tab dow
	
	* Panel C: Average earning surpises by quantile for announcements made on Friday and on other weeks
	bysort SurQ11 : egen Sur_avg = mean(Sur)
	tab Sur_avg
	
// Result
// . tab Sur_avg
//
//     Sur_avg |      Freq.     Percent        Cum.
// ------------+-----------------------------------
//   -.0373806 |     16,072        9.43        9.43
//   -.0079028 |     16,036        9.41       18.84
//   -.0037111 |     16,056        9.42       28.27
//   -.0017372 |     16,044        9.42       37.68
//   -.0005936 |     16,101        9.45       47.13
//           0 |     12,112        7.11       54.24
//     .000472 |     15,616        9.16       63.40
//    .0011556 |     15,588        9.15       72.55
//    .0021746 |     15,581        9.14       81.70
//    .0041623 |     15,584        9.15       90.84
//    .0166539 |     15,604        9.16      100.00
// ------------+-----------------------------------
//       Total |    170,394      100.00


	
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

* Q5: Regression (slow reaction to Friday surprises?)
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
	reg CAR Fri SurQ11 FrixSurQ11, robust
	drop FrixSurQ11
	
	
	* columns 3&4:
	g SurQTop=(SurQ11==11)
	g FrixSurQTop = Fri*SurQTop	
	reg CAR Fri SurQTop FrixSurQTop, robust
	drop SurQTop
	drop FrixSurQTop


	* columns 5&6:
	g SurQTop2=(SurQ11==10 | SurQ11==11)
	g FrixSurQTop2 = Fri*SurQTop2
	reg CAR Fri SurQTop2 FrixSurQTop2, robust
	seeout	

* Q6: Regression (timing of announcements?)
	clear
	cap erase temp.txt
	use dataset-5 
	duplicates drop ticker fpe, force
	summarize Sur, detail
	g D0 = (Sur<0)
	g D25= Sur<0
	g D10= Sur<0
	g Fri = dow(ead)==5

	reg Fri D0, cluster(...)
	outreg2 ...
	reg Fri ...
	outreg2 ...
	...
	

* Q7: Sticky earnings surprises
	clear
	cap erase temp.txt
	use dataset-5 
	duplicates drop ticker fpe, force
	* winsorize or truncate Sur:
	winsor2 Sur, suffix(_win) cuts(5 95)
	* define quarter variable and tsset data:
	g qtr = quarter(anndats)
	format %td qtr 
// 	tsset qtr
	* define lags of the earnings surprise:
	g SurL1 = Sur if qtr == 1
	g SurL2 = Sur if qtr == 2
	g SurL3 = Sur if qtr == 3
	g SurL4 = Sur if qtr == 4
	
	reg Sur SurL1, cluster(ticker)
	reg Sur SurL2, cluster(ticker)
	reg Sur SurL3, cluster(ticker)
	reg Sur SurL4, cluster(ticker)
	
	
	
	
	
	
