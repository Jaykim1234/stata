clear all
cls

import excel "C:\Users\user\Desktop\master\Semester 1\Financial market\Assignment\assignment2_data_2021.xls", sheet("Sheet1") firstrow
save data.dta,replace
use "C:\Users\user\Desktop\master\Semester 1\Financial market\Assignment\data.dta" 

ssc install asdoc

//b

gen log_mktcap = log(mktcap)
gen log_vp = log(vp)
gen log_p  = log(p)
gen vo_ibnosh = vo/ibnosh

//1th
reg bas100 vola mktcap , cluster(ticker)
est store Model1

//2nd
reg bas100 vola vp , cluster(ticker)
est store Model2

//3th
reg bas100 vola log_mktcap , cluster(ticker)
est store Model3

//4th
reg bas100 vola log_vp , cluster(ticker)
est store Model4

//5th
reg bas100 vola vo_ibnosh log_mktcap log_vp, cluster(ticker)
est store Model5

//6th
reg bas100 vola vo_ibnosh log_mktcap log_vp log_p, cluster(ticker)
est store Model6


esttab Model1 Model2 Model3 Model4 Model5 Model6, b(%9.4f) scalars(r2) mtitles title("table1")


// table1
// ------------------------------------------------------------------------------------------------------------
//                       (1)             (2)             (3)             (4)             (5)             (6)   
//                    Model1          Model2          Model3          Model4          Model5          Model6   
// ------------------------------------------------------------------------------------------------------------
// vola              41.9669***      41.9292***      21.5427**       25.6108***      29.0804***      29.2561***
//                    (5.41)          (5.42)          (2.86)          (3.80)          (3.96)          (3.74)   
//
// mktcap            -0.0000**                                                                                 
//                   (-2.92)                                                                                   
//
// vp                                -0.0000**                                                                 
//                                   (-2.74)                                                                   
//
// log_mktcap                                        -1.1914***                       0.8504***       0.8331***
//                                                  (-13.68)                          (3.34)          (3.31)   
//
// log_vp                                                            -0.8656***      -1.4228***      -1.4209***
//                                                                  (-15.31)         (-7.65)         (-7.71)   
//
// vo_ibnosh                                                                          0.0196          0.0196   
//                                                                                    (1.86)          (1.86)   
//
// log_p                                                                                              0.0284   
//                                                                                                    (0.19)   
//
// _cons             -0.1753         -0.1614          7.2157***       6.5589***       5.4647***       5.4820***
//                   (-0.46)         (-0.42)         (10.73)         (12.57)          (8.12)          (8.43)   
// ------------------------------------------------------------------------------------------------------------
// N                    2256            2256            2256            2256            2256            2256   
// r2                 0.1179          0.1193          0.3310          0.4084          0.4263          0.4264   
// ------------------------------------------------------------------------------------------------------------
// t statistics in parentheses
// * p<0.05, ** p<0.01, *** p<0.001

//c

reg bas100 vola log_mktcap month , cluster(ticker)
est store Model3_time

reg bas100 vola log_vp month, cluster(ticker)
est store Model4_time

reg bas100 vola vo_ibnosh log_mktcap log_vp month, cluster(ticker)
est store Model5_time

esttab Model3_time Model4_time Model5_time, b(%9.4f) scalars(r2) mtitles title("table2")

//d

gen financial_sector = 1 if gic == 40 
replace financial_sector = 0 if gic != 40 

reg bas100 vola log_mktcap month financial_sector, cluster(ticker)
est store Model3_time_fin

reg bas100 vola log_vp month financial_sector, cluster(ticker)
est store Model4_time_fin

reg bas100 vola vo_ibnosh log_mktcap log_vp month financial_sector, cluster(ticker)
est store Model5_time_fin

esttab Model3_time_fin Model4_time_fin Model5_time_fin, b(%9.4f) scalars(r2) mtitles title("table3")


//e

// ssc install estout

reg bas100 vola log_vp financial_sector c.log_vp#i.financial_sector, cluster(ticker) 
est store Model4_fin_inter

eststo: reg bas100 vola vo_ibnosh log_mktcap log_vp  financial_sector c.log_vp#i.financial_sector, cluster(ticker)
est store Model5_fin_inter

eststo: reg bas100 vola vo_ibnosh log_mktcap log_vp log_p financial_sector c.log_vp#i.financial_sector , cluster(ticker) 
est store Model6_fin_inter

esttab Model4_fin_inter Model5_fin_inter Model6_fin_inter, b(%9.4f) scalars(r2) mtitles title("qe_1")

stsedatase

reg bas100 vola lg_vp fin c.lg_vp#c.fin, cluster(ticker_n)
est store Model4_fin_lvp

reg bas100 vola turnover lg_mktcap lg_vp fin c.lg_vp#c.fin, cluster(ticker_n)
est store Model5_fin_lvp

reg bas100 vola lg_mktcap lg_vp lg_p turnover fin c.lg_vp#c.fin, cluster(ticker_n)
est store Model6_fin_lvp

esttab Model4_fin_lvp Model5_fin_lvp Model6_fin_lvp, b(%9.4f) scalars(r2) mtitles title("table4") replace

esttab Model4_fin_lvp Model5_fin_lvp Model6_fin_lvp using mytable.rtf, b(4) t(4) r2(4) ar2(4) label style(fixed) nogaps star(* 0.10 * 0.05 ** 0.01) replace

/*
eststo: reg bas100 vola log_mktcap c.vola#i.financial_sector c.log_mktcap#financial_sector, cluster(ticker) 
// est store Model4_fin_inter

eststo: reg bas100 vola vo_ibnosh log_mktcap log_vp c.vola#financial_sector c.vo_ibnosh#financial_sector c.log_mktcap#financial_sector c.log_vp#financial_sector, cluster(ticker)
// est store Model5_fin_inter

eststo: reg bas100 vola vo_ibnosh log_mktcap log_vp log_p c.vola#i.financial_sector c.vo_ibnosh#i.financial_sector c.log_mktcap#financial_sector c.log_vp#financial_sector c.log_p#financial_sector, cluster(ticker) 
// est store Model6_fin_inter
*/


// esttab using qe_result_table, Model4_fin_inter Model5_fin_inter Model6_fin_inter


// , b(%9.4f) scalars(r2) mtitles title("qe_1") save(Table qe)

/*
reg bas100 vola log_mktcap c.vola##i.financial_sector c.log_mktcap##i.financial_sector, cluster(ticker) 
est store Model4_fin_inter

reg bas100 vola vo_ibnosh log_mktcap log_vp c.vola##i.financial_sector c.vo_ibnosh##i.financial_sector c.log_mktcap##i.financial_sector c.log_vp##i.financial_sector, cluster(ticker)
est store Model5_fin_inter

reg bas100 vola vo_ibnosh log_mktcap log_vp log_p c.vola##i.financial_sector c.vo_ibnosh##i.financial_sector c.log_mktcap##i.financial_sector c.log_vp##i.financial_sector c.log_p##i.financial_sector, cluster(ticker)
est store Model6_fin_inter

esttab Model4_fin_inter Model5_fin_inter Model6_fin_inter, b(%9.4f) scalars(r2) mtitles title("qe_1")

*/
