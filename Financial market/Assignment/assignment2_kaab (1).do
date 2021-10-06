cls
clear all

cd "C:\Users\kaabm\Desktop\FM2\"
import excel "C:\Users\kaabm\Desktop\FM2\assignment2_data_2021.xls", sheet("Sheet1") firstrow
//ssc install asdoc

//Q a

asdoc corr p vp mktcap bas100 ret vola, replace save(Correlation)
//Positive between volatility and bid ask
//Negative between other variables
//Highest cor between volume and market cap, volume and price (more than 0.5)

//Q b 
encode ticker, generate(ticker_n)
xtset ticker_n month
gen lmktcap = log(mktcap)
gen lvp = log(vp)
gen tover = vo/ibnosh
gen lclose = log(p)
//First 
asdoc reg bas100 vola mktcap, cluster(ticker) replace nest rep(t)
//Second
asdoc reg bas100 vola vp, cluster(ticker) nest rep(t)
//Third
asdoc reg bas100 vola lmktcap, cluster(ticker) nest rep(t)
//Fourth
asdoc reg bas100 vola lvp, cluster(ticker) nest rep(t)
//Fifth
asdoc reg bas100 vola tover lmktcap lvp, cluster(ticker) nest rep(t)
//Sixth
asdoc reg bas100 vola tover lmktcap lvp lclose, cluster(ticker) nest rep(t) save(Table I)

//Q c

asdoc reg bas100 vola lmktcap month, cluster(ticker) nest rep(t) replace

asdoc reg bas100 vola lvp month, cluster(ticker) nest rep(t)

asdoc reg bas100 vola tover lmktcap lvp month, cluster(ticker) nest rep(t) save(Table II)

//Q d
gen fin = 1 if gics == 40
replace fin = 0 if gics != 40

asdoc reg bas100 vola lmktcap if fin == 1, cluster(ticker) nest rep(t) replace

asdoc reg bas100 vola lvp if fin == 1, cluster(ticker) nest rep(t)

asdoc reg bas100 vola tover lmktcap lvp if fin == 1, cluster(ticker) nest rep(t) save(Table III)

//Q e 

asdoc reg bas100 vola lmktcap fin month i.fin##c.vola i.fin##c.lmktcap, cluster(ticker) nest rep(t) replace

asdoc reg bas100 vola lvp fin i.fin##c.vola i.fin##c.lvp, cluster(ticker) nest rep(t)

asdoc reg bas100 vola tover lmktcap lvp fin i.fin##c.vola i.fin##c.tover i.fin##c.lmktcap i.fin##c.lvp, cluster(ticker) nest rep(t) save(Table IV)

//Q f

asdoc reg bas100 vola lmktcap c.vola##c.lmktcap, cluster(ticker) nest rep(t) replace 

asdoc reg bas100 vola lmktcap c.vola##c.lmktcap lvp tover, cluster(ticker) nest rep(t)

asdoc reg bas100 vola lmktcap c.vola##c.lmktcap tover lvp lclose, cluster(ticker) nest rep(t) save(Table V)