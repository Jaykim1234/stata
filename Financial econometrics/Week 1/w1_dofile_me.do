cls //this clears the screen
clear all //this clears the memory
cd "C:\Users\user\Desktop\master\Semester 1\Applied financial econometrics\Tutorial\w1"

// Part 1 - The effect of information about student loans on loan take-up
// In the first part of this computer exercise we will replicate part of the results in Booij et al. 
// (2012) that were also discussed in the lecture. The authors present the results of a field 
// experiment where 'students in higher education' are given 'information about student 
// loans'.
// Figure 1 in the paper (see attachment to the lecture notes) reveals that students know 
// relatively little about the loans that are available to them. Also, students that know more 
// seem to borrow more often compared to students that are uninformed about the loans. If 
// this is a true causal relationship, providing students with information about loans should 
// lead them to borrow more often - an objective of the government. We could test this by 
// randomly giving students information about loans (treatment group) and others not 
// (control group), and see whether loan take-up indeed increases. This is exactly what is 
// done in the Booij et al. (2012) paper.
// The data provided contains information on treatment status (reception of information), a 
// binary variable on subsequent borrowing (xborrow) and some background variables. 
// You will use this data to replicate1 some of the results in the paper and investigate whether 
// giving students information has increased their borrowing

use w1_data_experiment1.dta
ssc install estout, replace //to install an auxiliary package for obtaining nicely formatted tables
desc

//2.Is it clear to you which variables are outcomes  

// Contains data from w1_data_experiment1.dta
//  Observations:         2,188                  
//     Variables:            11                  26 Sep 2014 11:20
// --------------------------------------------------------------------------------------------------
// Variable      Storage   Display    Value
//     name         type    format    label      Variable label
// --------------------------------------------------------------------------------------------------
// treatment       byte    %8.0g      groep      info treatment
// age             float   %9.0g                 Age
// ethnminor       byte    %10.0g     allochtoon
//                                               Ethnic Minority
// ses             byte    %9.0g      socmil     Social Economic Status variable measured on 1 - 5
//                                                 scale
// studydur        byte    %8.0g                 Study duration (months)
// ra              byte    %8.0g                 Subjective risk attitude measured on 1 - 10 scale
// female          byte    %9.0g      female     Female
// actrack         byte    %11.0g     wo         Academic HE
// dr              float   %9.0g                 Subjective discount rate per year on [0,1] range
// loanexp         byte    %9.0g      loanexp    Has prior loan experience dummy
// xborrow         byte    %9.0g                 Has borrowed after the treatment dummy
// --------------------------------------------------------------------------------------------------

// Outcomes (Y) :Xborrow
// Treatment status (X):treatment
// control variables (W) :rest of others

// 3. Investigate the data by typing sum. Do you spot outliers? 
sum

// . sum
//
//     Variable |        Obs        Mean    Std. dev.       Min        Max
// -------------+---------------------------------------------------------
//    treatment |      2,188    .5018282     .500111          0          1
//          age |      2,188    21.05757    1.767352   11.47397   34.39178
//    ethnminor |      2,188    .0447898    .2068893          0          1
//          ses |      2,188    2.522395    1.384793          1          5
//     studydur |      2,188    33.01508    13.44552          1         99
// -------------+---------------------------------------------------------
//           ra |      2,188    5.659049    2.073154          1         10
//       female |      2,188    .6572212    .4747468          0          1
//      actrack |      2,188    .6096892    .4879314          0          1
//           dr |      2,188    .2100777    .1857156        .05         .6
//      loanexp |      2,188     .297989    .4574792          0          1
// -------------+---------------------------------------------------------
//      xborrow |      2,188    .2627971    .4402537          0          1

drop if age<17

//4. The virtue of an experiment is that we can be certain that the variable of interest is 
// not related to other factors. The experimenter should still, however, try to convince 
// other scientists that the treatment was indeed randomized. One way to do so is to 
// check whether background variables 

// help test
// reg xborrow treatment age ethnminor ses studydur ra female actrack dr loanexp, robust

test (age=ethnminor=ses=studydur=ra=female=actrack=dr=loanexp=0)


// . test (age=ethnminor=ses=studydur=ra=female=actrack=dr=loanexp=0)
//
//  ( 1)  age - ethnminor = 0
//  ( 2)  age - ses = 0
//  ( 3)  age - studydur = 0
//  ( 4)  age - ra = 0
//  ( 5)  age - female = 0
//  ( 6)  age - actrack = 0
//  ( 7)  age - dr = 0
//  ( 8)  age - loanexp = 0
//  ( 9)  age = 0
//
//        F(  9,  2175) =   62.69
//             Prob > F =    0.0000


// 5.When we are convinced that the treatment is truly random, we can estimate the causal 
// effect by a simple regression of the outcome variable on the treatment. Type reg 
// xborrow treat and interpret the result. Should the government start an 
// information campaign to stimulate borrowing?

// To check treatments are truly random 

reg xborrow treat


//       Source |       SS           df       MS      Number of obs   =     2,186
// -------------+----------------------------------   F(1, 2184)      =      0.01
//        Model |  .001650327         1  .001650327   Prob > F        =    0.9265
//     Residual |  423.277398     2,184  .193808332   R-squared       =    0.0000
// -------------+----------------------------------   Adj R-squared   =   -0.0005
//        Total |  423.279048     2,185  .193720388   Root MSE        =    .44024
//
// ------------------------------------------------------------------------------
//      xborrow | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
// -------------+----------------------------------------------------------------
//    treatment |   .0017378   .0188319     0.09   0.926    -.0351925    .0386681
//        _cons |    .261708   .0133405    19.62   0.000     .2355466    .2878694
// ------------------------------------------------------------------------------

// The significance level of treatment is higher than 0.05. So, no

// 6. To obtain correct standard errors we should add the robust option. Do so and 
// discuss the difference with the previous answer. Store the equation by typing est 
// store ols1.

reg xborrow treat, robust
est store ols1

// Linear regression                               Number of obs     =      2,186
//                                                 F(1, 2184)        =       0.01
//                                                 Prob > F          =     0.9265
//                                                 R-squared         =     0.0000
//                                                 Root MSE          =     .44024
//
// ------------------------------------------------------------------------------
//              |               Robust
//      xborrow | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
// -------------+----------------------------------------------------------------
//    treatment |   .0017378   .0188317     0.09   0.926    -.0351922    .0386678
//        _cons |    .261708   .0133262    19.64   0.000     .2355746    .2878414
// ------------------------------------------------------------------------------
//
// . 

// 7.We can include other background variables in the regression by adding them after 
// the variable treatment in the regression command. Discuss the main differences 
// with the first regression that did not include covariates. Some variables appear very 
// significant. Do they have a causal interpretation? Store the equation by typing est 
// store ols2

reg xborrow treatment age ethnminor ses studydur ra female actrack dr loanexp, robust
est store ols2


// Linear regression                               Number of obs     =      2,186
//                                                 F(10, 2175)       =      56.43
//                                                 Prob > F          =     0.0000
//                                                 R-squared         =     0.2360
//                                                 Root MSE          =      .3856
//
// ------------------------------------------------------------------------------
//              |               Robust
//      xborrow | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
// -------------+----------------------------------------------------------------
//    treatment |   .0037585   .0164897     0.23   0.820    -.0285787    .0360957
//          age |   .0280326   .0069509     4.03   0.000     .0144015    .0416637
//    ethnminor |   .0920709   .0468404     1.97   0.049     .0002144    .1839275
//          ses |   .0024424   .0061818     0.40   0.693    -.0096805    .0145653
//     studydur |    .000286   .0008221     0.35   0.728    -.0013262    .0018982
//           ra |   .0222552   .0039767     5.60   0.000     .0144567    .0300537
//       female |   .0187284   .0174034     1.08   0.282    -.0154005    .0528574
//      actrack |   .0770486   .0178987     4.30   0.000     .0419483    .1121488
//           dr |   .1959725    .048486     4.04   0.000     .1008888    .2910562
//      loanexp |   .3854039   .0215002    17.93   0.000     .3432409     .427567
//        _cons |  -.6907789   .1360178    -5.08   0.000    -.9575173   -.4240405
// ------------------------------------------------------------------------------
//
// . est store ols2

// coefficient of xborrow increased twice


// 8.The point estimate on the treatment variable changes from .0017378 to .0037585 when 
// including background variables. You can show this comparison in one table by typing 
// esttab ols1 ols2, se b(a2) keep(treatment). The difference will not be 
// significant in most cases because the control variables are not related to the treatment. 
// Verify that both point estimates lie within the range of the 95% confidence interval of 
// the other variable (use q. 6 and 7). This is not an appropriate test, but if both estimates 
// do not lie in each other's range, it is an indication that they may differ significantly.
//?????

esttab ols1 ols2, se b (a2) keep (treatment)



// --------------------------------------------
//                       (1)             (2)   
//                   xborrow         xborrow   
// --------------------------------------------
// treatment          0.0017          0.0038   
//                   (0.019)         (0.016)   
// --------------------------------------------
// N                    2186            2186   
// --------------------------------------------
// Standard errors in parentheses
// * p<0.05, ** p<0.01, *** p<0.001


// 9. Finally we are interested in whether students that are at the beginning of their study 
// (first two years) respond more to the treatment than older students that are likely to 
// have already formed financial habits. First gen begin=(studydur<=24). Then 
// perform a regression where you interact the treatment with this variable by typing 
// reg xborrow treat c.begin#c.treat begin age ethnminor ses 
// studydur ra female actrack dr loanexp, robust. Is there a significant 
// difference in treatment response for student at the beginning or the end of their 
// study? You also see that the main effect of begin is included, is this necessary?

gen begin=(studydur<=24)
reg xborrow treat c.begin#c.treat begin age ethnminor ses studydur ra female actrack dr loanexp, robust


