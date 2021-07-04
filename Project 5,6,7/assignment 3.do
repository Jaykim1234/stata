/* DO FILE ASSIGNMENT 3  GROUP 9  11996277 Songhee Kim  12317594 Mai Phan 11968850 Jinhyun Kim 12014621 Rajeev Pandit 11996161 Dayeon Park */ 
cls 
clear all 
cd "/Users/" //change to own directory 
 
//QUESTION 1 
 

use "mstocks.dta", clear sort ticker browse 
 
//"Company Excess Return" gen c_excess_r = ret - rf 
 
//"Market Excess Return" g m_excess_r = mktrf - rf 
 
ssc install estout, replace 
 
//AMZN eststo: reg c_excess_r m_excess_r if permno==84788, r test m_excess_r=1 test _cons=0 
 
 
//KKD eststo: reg c_excess_r m_excess_r if permno==88172, r test m_excess_r=1 test _cons=0 
 
//NOC eststo: reg c_excess_r m_excess_r if permno==24766, r test m_excess_r=1 test _cons=0 esttab, se(%9.3f) b(%9.3f) r2 mti(AMZN KKD NOC) 
 
//1b 
keep if permno==84788 | permno==88172 | permno==24766 qui sureg c_excess_r* = m_excess_r test _cons 
 
 
//1c : add smb & hml 
 
//AMZN eststo: reg c_excess_r m_excess_r if permno==84788, r eststo: reg c_excess_r m_excess_r smb hml if permno==84788, r 
 
//KKD eststo: reg c_excess_r m_excess_r if permno==88172, r eststo: reg c_excess_r m_excess_r smb hml if permno==88172, r 
 
//NOC eststo: reg c_excess_r m_excess_r  if permno==24766 eststo: reg c_excess_r m_excess_r smb hml if permno==24766, r 
 
esttab, se(%9.3f) b(%9.3f) r2 mti(AMZN AMZN KKD KKD NOC NOC) esttab, p(%9.3f) b(%9.3f) r2 mti(AMZN AMZN KKD KKD NOC NOC) 
 
est clear 
 
//joint test smg hml qui sureg c_excess_r*  = m_excess_r smb hml test smb hml 
 
//Question 2 use "dstocks.dta" 
 
*a) g estwindow = date>=mdy(5,4,2009) & date<=mdy(4,29,2010) *b)  gen fininst=1 if siccd>6000 &  siccd<6500 replace fininst=0 if fininst==. gen bank=1 if siccd>6000 & siccd<6100 replace bank=0 if bank==. gen credit=1 if siccd>6100 & siccd<6200 replace credit=0 if credit==. 
 
*c) bysort permno (date): gen lret = log(prc) - log(prc[_n-1]) drop if lret==. 
 
*d) *The mean of alphas: .0000311  *The standard deviation of alphas:  .0014162    *The mean of betas:  .9700105  *The standard deviation of betas:  .6547095  
 
gen lmkt= log(mktrf+1) bys permno: asreg lret lmkt bys permno: egen beta = max(_b_lmkt) 
 
bys permno: egen alpha = max(_b_cons) sum beta sum alpha drop _Nobs-_b_cons 
 
*e)  gen eventwin = date>=mdy(4,29,2010) & date<=mdy(5,26,2010) gen AR = lret - alpha - beta*mktrf if eventwin==1 bys permno (date): g CAR = sum(AR*eventwin) 
 
*f) Market capitalization g eventwin2 = date>=mdy(06,25,2010) & date<=mdy(07,20,2010) bys permno: asreg lret lmkt if eventwin2==1 bys permno: egen beta1 = max(_b_lmkt) bys permno: egen alpha1 = max(_b_cons) g AR1 = lret - alpha1 - beta1*lmkt bys permno (date): g CAR1 = sum(AR1*eventwin2) 
 
*average CAR reg CAR1 if eventwin2 ==1,r *market portfolio CAR gen marcap0721=shrout*prc if date==mdy(7,21,2010) gen weight = marcap0721 bys permno (weight): replace weight=weight[1] reg CAR1 weight if eventwin2 ==1, r 
 
 
*g) reg CAR1 fininst [aw=weight], r  reg CAR1 bank [aw=weight], r  reg CAR1 credit [aw=weight], r  
 
*h) 
 
drop _Nobs-_b_cons gen eventwin3 = date>=mdy(04,30,2010) & date<=mdy(06,24,2010) bys permno: asreg lret lmkt if eventwin3==1 bys permno: egen beta2 = max(_b_lmkt) bys permno: egen alpha2 = max(_b_cons) gen CAR2 = lret - alpha2 - beta2*lmkt bys permno (date): g CAR2 = sum(AR2*eventwin3) gen weight1 = marcap if eventwin3 ==1 bys permno (weight1): replace weight1=weight1[1] reg CAR2 fininst [aw=weight1] , r  reg CAR2 bank [aw=weight1] , r  reg CAR2 credit [aw=weight1], r  
 
//QUESTION 3 use "compustat.dta", clear 
 
gen treat=. replace treat=1 if marcap07<25 replace treat=0 if marcap07>25 & marcap07<100 
 
drop if treat==. 
 
gen post = fyear>2008 
 
gen post_treat=post*treat 
 
//3a xtset gvkey fyear 
 
reg invest post treat post_treat if inrange(fyear,2006,2009), cluster(gvkey) 
 
//QUESTION 4 //4a 
 
qui reg invest post treat post_treat if inrange(fyear,2005,2017), cluster(gvkey) est store A  
 
//4b qui xtreg invest post_treat i.fyear if inrange(fyear,2005,2017), fe i(sic) r est store B  
 
//4c qui xtreg invest post_treat i.fyear if inrange(fyear,2005,2017), cluster(gvkey) fe i(gvkey) est store C  
 
//4d tsset gvkey fyear 
 
qui xtreg invest post_treat i.fyear l.leverage l.cfta if inrange(fyear,2005,2017), cluster(gvkey) fe i(gvkey) est store D 
 
est table A B C D, keep(post_treat post treat l.leverage l.cfta) b(%9.3f) t(%9.2f) 
 
//QUESTION 5 gen post0 = fyear>=2008 gen post_treat0 = treat*post0 
 
xtreg invest post_treat i.fyear if inrange(fyear,2005,2017), fe i(sic) r est store T xtreg invest post_treat0 i.fyear if inrange(fyear,2005,2017), fe i(sic) r est store UT 
 
est table T UT, keep(post_treat post_treat0) b(%9.3f) t(%9.2f) 
 
//5a/b preserve 
 
 
collapse invest post_treat post_treat0, by(treat fyear) 
 
 
g c = .33 if fyear==2008  tw area c fyear if inrange(fyear,2005,2017), bcolor(gs13) || /// line invest fyear if treat==1 & inrange(fyear,2005,2017), sort lw(1.5) col("red") || /// line invest fyear if treat==0 & inrange(fyear,2005,2017), sort lw(1.5) col("blue")          yaxis(2) || /// , leg(order(2 3) label(2 treated) label(3 untreated) /// ring(0) pos(1) c(1)) xlab(2005(1)2017, angle(vertical)) /// xtitle("") yti("investment") ylab(.15(.03).33) 
 
 
restore 
 
 
 
 
 
 
 