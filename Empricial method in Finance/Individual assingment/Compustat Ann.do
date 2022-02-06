//prepare compustat annual data 
use "C:\Users\stank\OneDrive\Documenten\Master-Finance\Empirical Methods Finance\Main Assignment\Compustat-Annual.dta" 
suduplicates report gvkey fyear
duplicates drop fyear gvkey, force
duplicates report cusip fyear //check for duplicates 
//drop data if negative or missing sales and assets
destring sic, replace
drop if inrange(sic, 4900, 4999)
replace cfvol=. if cfvol==0
drop if fic != "USA"
drop if at<=0
drop if at==.
drop if revt<=0
drop if revt==.
// generate financial variables and winsorize ratios at 1% tails like paper
gen lnassets=ln(at)
label variable lnassets "Ln(Assets)"
gen roa=ni/at
label variable roa "Return on assets"
gen oav=(csho*prcc_f)/(lt+(csho*prcc_f)-ch)
label variable oav "Operating asset volatility"
g lncash = ln(ch)
label variable lncash "Ln(Cash)"
g debtasset=(dltt+dlc)/at
label variable debtasset "Debt/Assets"
winsor2 roa oav debtasset, suffix(_win) cuts(1 99)
g booklev=(dlc+dltt)/at
label var booklev "Book leverage"
g mvequity=csho*prcc_f
label var mvequity "Market value of equity"
g mvassets=at-seq+mvequity
label var mvassets "Market value of assets"
g marketlev=(dlt+dltt)/mvassets
label var marketlev "Market leverage"
winsor2 booklev marketlev, suffix(_win) cuts(1 99)
g shortlev= dlc/at
winsor2 shortlev, suffix(_win) cuts(1 99)
label var shortlev "Short term leverage"
g netlev=(dlc+dltt-che)/at
label var netlev "Net leverage"
winsor2 netlev, suffix(_win) cuts(1 99)
//generate CAGR
tsset gvkey1 fyearq
gen CAGR = ((at / at[_n-3])^(1/3)-1)*100
//save as new file compustat annual1
//merge quarterly cash flow volatility variable
use Compustat-Annual1
rename fyear fyearq
joinby gvkey fyearq using CompustatQuarterly2, unmatched(master)
tab _merge
drop _merge
//merge stockvol and delisting code
joinby byear cusip using CRSPcollapse1, unmatched(master)
tab _merge 
drop _merge 
//code BC variable
gen BC=0 if state!="" & incorp!=""
replace BC=1 if fyear>=1987 & incorp=="AZ"
replace BC=1 if fyear>=1989 & incorp=="CT"
gen BC=0
replace BC=1 if fyearq>=1987 & state=="AZ"
replace BC=1 if fyearq>=1989 & state=="CT"
replace BC=1 if fyearq>=1988 & state=="DE"
replace BC=1 if fyearq>=1988 & state=="GA"
replace BC=1 if fyearq>=1988 & state=="ID"
replace BC=1 if fyearq>=1989 & state=="IL"
replace BC=1 if fyearq>=1986 & state=="IN"
replace BC=1 if fyearq>=1997 & state=="IA"
replace BC=1 if fyearq>=1989 & state=="KS"
replace BC=1 if fyearq>=1987 & state=="KY"
replace BC=1 if fyearq>=1988 & state=="ME"
replace BC=1 if fyearq>=1989 & state=="MD"
replace BC=1 if fyearq>=1989 & state=="MA"
replace BC=1 if fyearq>=1989 & state=="MI"
replace BC=1 if fyearq>=1987 & state=="MN"
replace BC=1 if fyearq>=1989 & state=="WY"
replace BC=1 if fyearq>=1987 & state=="WI"
replace BC=1 if fyearq>=1987 & state=="WA"
replace BC=1 if fyearq>=1988 & state=="VA"
replace BC=1 if fyearq>=1997 & state=="TX"
replace BC=1 if fyearq>=1988 & state=="TN"
replace BC=1 if fyearq>=1990 & state=="SD"
replace BC=1 if fyearq>=1988 & state=="SC"
replace BC=1 if fyearq>=1990 & state=="RI"
replace BC=1 if fyearq>=1986 & state=="MO"
replace BC=1 if fyearq>=1988 & state=="NE"
replace BC=1 if fyearq>=1991 & state=="NV"
replace BC=1 if fyearq>=1986 & state=="NJ"
replace BC=1 if fyearq>=1985 & state=="NY"
replace BC=1 if fyearq>=1991 & state=="OK"
replace BC=1 if fyearq>=1990 & state=="OH"
replace BC=1 if fyearq>=1991 & state=="OR"
replace BC=1 if fyearq>=1989 & state=="PA"
label var BC "Business combination dummy"
//save as new dataset compustat-annual2

//gen dummy for 3 year prior
tsset gvkey year
g BCprior=0
replace BCprior=1 if BC==0 & F1.BC==1
replace BCprior=1 if BC==0 & F3.BC==1
replace BCprior=1 if BC==0 & F2.BC==1


//gen dummy for no BC law states
gen noBCstate=0
replace noBCstate=1 if state=="AK" | state=="AL"| state== "AR"| state=="BC" | state=="CA"| state== "CO" | state=="DC" | state=="FL" | state=="HI" | state=="LA" | state=="MB" | state=="MS" | state=="MT" | state=="NC" | state=="ND" | state=="NH" | state=="NM" | state=="NS" | state=="ON" | state=="PR" | state=="QC" | state=="UT" | state=="VI" | state=="VT" | state=="WV"
//gen indicator for ttest table1
gen ttest=.
replace ttest=1 if BCprior==1
replace ttest=0 if noBCstate==1
*generate dummy for 3 years prior to BC law
tsset gvkey year
g BCprior=0
replace BCprior=1 if BC==0 & F1.BC==1
replace BCprior=1 if BC==0 & F3.BC==1
replace BCprior=1 if BC==0 & F2.BC==1
*generate dummy for states of incorporation without BC law
gen noBCstate=0
replace noBCstate=1 if incorp=="AK" | incorp=="AL"| incorp== "AR"| incorp=="BC" | incorp=="CA"| incorp== "CO" | incorp=="DC" | incorp=="FL" | incorp=="HI" | incorp=="LA" | incorp=="MB" | incorp=="MS" | incorp=="MT" | incorp=="NC" | incorp=="ND" | incorp=="NH" | incorp=="NM" | incorp=="NS" | incorp=="ON" | incorp=="PR" | incorp=="QC" | incorp=="UT" | incorp=="VI" | incorp=="VT" | incorp=="WV"
*generate indicator for ttest table1
gen BCtest=.
replace BCtest=1 if BCprior==1
replace BCtest=0 if noBCstate==1
*generate summary statistics for both dummies
estpost tabstat lnassets roa_win debtasset_win CAGR_win stockvol cfvol lncash delist , by(BCtest) stat(mean sd) columns(statistics) listwise
esttab . , main(mean) aux(sd) nostar unstack noobs nonote nomtitle label
// regression code table 2
eststo t21: reghdfe stockvol BC, absorb(i.staten#i.year gvkey i.sic#i.year) cluster(incorpn)
*generate indicator for ttest table1
gen BCtest=.
replace BCtest=1 if BCprior==1
replace BCtest=0 if noBCstate==1
*run ttest 
ssc install cltest
clttest lnassets, cluster(incorpn) by(BCtest)
clttest roa_win, cluster(incorpn) by(BCtest)
clttest debtasset_win, cluster(incorpn) by(BCtest)
clttest CAGR_win, cluster(incorpn) by(BCtest)
clttest stockvol, cluster(incorpn) by(BCtest)
clttest cfvol, cluster(incorpn) by(BCtest)
clttest lncash, cluster(incorpn) by(BCtest)
//code to create 14 dummy vards
tsset gvkey year
﻿gen BCadopt=0
﻿replace BCadopt=1 if BC=1 & L.BC=0
bysort gvkey: egen BCyear = min(cond(BCadopt == 1, year, .))
gen BC_dum_0 = BCyear == year
*loop that generates dummies for 5 years prior
forvalues i = 1/5 { gen BC_dum_minus`i' = year == (BCyear - `i') }
*loop that generates dummies for 8 years after
forvalues i = 1/8 { gen BC_dum_plus`i' = year == (BCyear + `i')}

//code for robustness
use compustat-annual, clear
*restrict sample by excluding financial firms and using period from 1976 to 1995
drop if inrange(sic, 6000, 6999)
drop if inrange(year, 1996, 2006)
*produce regression output
eststo t21: reghdfe stockvol BC, absorb(i.staten#i.year gvkey i.sic#i.year) cluster(incorp)
outreg2 [t21 t22 t23 t24 t25] using table5.xls, adjr2 bdec(3) tdec(3) addtext(Firm FE, Yes, State-year FE, Yes, Industry-Year FE, Yes) label

//code stockvol
Use CRSP-daily
gen year=year(date)
bysort PERMNO year: egen ntradingd=count(year)
bysort PERMNO year: egen sumret=sum((RET)^2)
bysort PERMNO year: gen semretsq=(sumret*252)/ntradingd
bysort PERMNO year: gen stockvol=sqrt(semretsq)
duplicates report date PERMNO
duplicates drop date PERMNO, force
encode TICKER, replace
collapse stockvol, by(CUSIP year)
Save stockvol, replace

//code delist
Use CRSP-daily
*generate dummies based on delisting code
g delistd = 0
replace delistd = 1 if inrange(DLSTCD, 400, 500)
replace delistd = 1 if DLSTCD == 552
replace delistd= 1 if DLSTCD == 560
replace delistd = 1 if DLSTCD == 561
replace delistd = 1 if DLSTCD == 572
replace delistd= 1 if DLSTCD == 574
replace delistd= 1 if DLSTCD == 580
replace delistd= 1 if DLSTCD == 584
*generalize dummy for specific firm-year
bysort PERMNO year: egen delist=sum(delistd)
*collapse to yearly data
collapse delisty, by(CUSIP year)
save delist, replace

*create annual CRSP file
collapse delisty, by(CUSIP year)
save delist, replace
clear
Use Compustat-annual
*adjust cusip to enable merge
gen CUSIP=substr(cusip, 1, 8)
*merge
joinby CUSIP year using delist, unmatched master
tab _merge 
drop _merge

//code cashflowvol
Use CompustatQuarterly
*define quarterly time variable
gen qdate = qofd(datadate)
format qdate %tq
destring gvkey, gen(gvkey1)
tsset gvkey1 qdate
*generate cashflow variable
gen accrualsq=(actq-L.actq)-(cheq-L.cheq)-(lct-L.lctq)+(dlcq-L.dlcq)-dpq
gen cfassetsq=(oiadpq-accrualsq)/L.at
label var cfassetsq "Cash flow to assets quarterly"
winsor2 cfassets, suffix(_win) cuts(1 99)
*compute annualized volatility
bysort gvkey fyear: egen cfvol=sd(cfassetsq_win)

*save final file
duplicates report qdate gvkey
duplicates drop qdate gvkey, force
rename fyearq year
collapse cfvol, by(gvkey year)
Save cfvol, replace

