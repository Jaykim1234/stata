//Answers to the Computer Exercises in week 1: Experiments


//1

//change to YOUR  project folder
clear all
cls
cap cd "C:\Users\Jinhyun\Documents\GitHub\stata\Financial econometrics\Week 1"





//open data & install auxiliary package for making tables
use w1_data_experiment1.dta, clear
//ssc install estout




//2
desc
// xborrow is the outcome variable
// treat is 0,1 treatment indicator
// other variables are background characteristics



//3
sum
drop if age <17
// we see that there are some 11 year olds in our data (must be measurement error)
// assuming they are random coding errors we may drop these observations without
// introducing a bias.






//4
reg treat  age ethnminor ses studydur ra female actrack dr loanexp
test age=ethnminor=ses=studydur=ra=female=actrack=dr=loanexp=0
// F-test is not rejected; we have no statistical indication that assignment is 
// conditional on any of these background characteristics, which supports - but 
// does not prove - the claim that assignment was random (p478[526])




//4
reg xborrow treat
// the point estimate is near 0 and not significant which mean that the treatment 
// does not significantly increase borrowing. Hence, no indication that a campaign
// would be usefull.


//5
reg xborrow treat, robust
est store ols1
// the standard error decreases a tiny bit. Otherwise nothing is affected;
// In general standard errors under homoscedasticity will be biased (can be positive 
// or negative) if in fact the variance of the outcome y is related to X, which 
// will be the case in most empirical settings. Therefore we always use 
// heteroscedasticity robust standard errors (see section 5.4 in S&W). This is
// also the reason that we never calculate the homoscedasticity only F -statistic
// from p.256[267], but use Stata to compute the appropriate statistic under
// heteroscedasticity that is given in section 18.3 (this section is not part of the course)

//6
reg xborrow treat  age ethnminor ses studydur ra female actrack dr loanexp, robust
est store ols2
// the estimated treatment effect increases somewhat, but is still very close to 0.
// the standard error on the estimated treatment effect is a little smaller 
// (0.019->0.016) due to the inclusion of the control variables that absorb part
// of the unexplained variance. This can also be seen by looking at the R-squared 
// that increases from 0 to 0.23. Hence, including control variables increases
// precision somewhat, as expected. The included control variables do not have a
// causal interpretation even though some are significant (see p.233[514])



//7
esttab ols1 ols2, keep(treatment) se b(a2)
// The confidence interval of ols1 is  [-.0351922, .0386678], which includes 
// .00375847 similarly the confidence interval of ols2 is [-.0285787, .0360957],
// which includes .0017378



//8
gen begin=(studydur<=24)
reg xborrow treat c.begin#c.treat begin  age ethnminor ses studydur ra female actrack dr loanexp, robust
// The coefficient on the interaction term, with a p-value =0.456 , is not significant
// hence, there is no indication that students at the beginning of their study 
// react more to the treatment than more senior students do.
//     The baseline begin should also be included because it is likely that the 
// begin=0 and begin=1 groups differ in their loan take-up. Not controlling for 
// this will lead to OVB because while treat is randomly assigned, the variable 
// begin*treat is not. Conditional on begin begin*treat is randomly assigned, so 
// when we include begin we can also give the coefficient on the interaction 
// begin*treat a causal interpretation. Of course we can not give the variable begin
// a causal interpretation because it is not randomly assigned.
//     The c. operator is to tell stata to interpret the variable as continuous. 
// If you were to specify begin#treat stata would automatically interpret the 
// variables as catecorical and include all their interactions. 


//PIC
bys begin treat: egen  mborrow = mean(xborrow)
twoway (scatter xborrow treatment) ///
    (scatter mborrow treatment if begin==0, ms(O) msize(large) mc(green)) ///
	(scatter mborrow treatment if begin==1, ms(x) msize(huge) mc(blue)) ///
	(lfit xborrow treatment if begin==0, lc(green)) ///
	(lfit xborrow treatment if begin==1, lc(blue)), ///
	legend(label(1 "raw data") label(4 "begin==0") ///
	label(5 "begin==1") order(1 4 5) col(3)) ytitle(xborrow) name(loaninfo, replace)

	

	

//9
use w1_data_experiment2.dta, clear
desc
// Examscore and dropout are outcome variables that are realized after the treatment
// homework is 0,1 treatment indicator studentid id student identifier other variables
// are background characteristics


//10
sum
// All variables seem within range, no indication of outliers

//11
reg examscore homework
est store ols3
// It seems that the compulsory homework assignment increases the exam score by 
// about 0.62 on a scale from 0-10 which is quite substantial. In terms of standard
// deviations the effect is 0.62/1.16=.53, which is a verly large effect.



//12
tab homework major, col nofreq
// The table shows that non majors have about 38% change of being treated, while
// majors recieve treatment in 53% of cases; This clearly indicates that the
// homework treatment is selective with respect to major status
reg homework major male
// The F-statistic of the regression of covariates on treatment status is 9.7, with
// pvalue=0.0001; hence we reject the H0 that there is no relation between background
// covariates in favour of the alternative hypothesis that treatment status is selective
// with respect to one or more of the covariates.
//    Judging from the table it is only the variable major that is related to treatment,
// the male variable is not. Both can be included in the regression. The major variable
// HAS TO BE INCLUDED in the regression to get unbiased estimates of the causal 
// effect of homework on grades. The male variable can be included in increase
// statistical precision


//13
reg examscore homework major male
est store ols4
// The coeff on homework has dropped from .63 to .49 (i.e. by about 22%) and now 
// has a causal interpretation. Even though major status is a significant and strong
// predictor of grades, we can not give it a causal interpretation because we have
// not randomly assigned students to following the course as part of their major
// or just an elective.  The variable male also has no causal interpretion (and 
// it is actually hard to think of a situation where this could be randomized) and
// it is not significant. Therefore it will not contribute much to increasing precision
esttab ols3 ols4, se b(a2)


//14
// The confidence interval of ols3 is  [.4708768, .7821564], which includes .4937244 
// similarly the confidence interval of ols4 is [.3498209, .6376278], which 
// includes .6265166. Hence, this rough eyeballing test does not seem to indicate
// both estimates are siginficantly different


//15
qui suest ols3 ols4
lincom [ols4_mean]homework-[ols3_mean]homework
// The output shows that the coefficient has dropped with -0.13 and significantly 
// so. The reason we do reject equality of the two estimates now, is that the 
// covariance between the two estimators is positive (you can calculate that it 
// is equal .0052 using the formula), which REDUCES the standard error of the
// difference. Hence, the standard error of the difference is of the magnitude of
// 0.03, much smaller than the s.e.'s of the individual coefficients (about 0.08).
di 0.5*(0.079^2 + 0.073^2 - .0337^2)

// The implication is that the first estimate was upward biased. This can be 
// explained by the fact that majors are probably more able and motivated doing 
// this course than the electives, i.e. they would have performed better anyway.
// Because the treatment group contains more of them, we overstimate the effect
// on grades if we do not correct for this (i.e. if we do not include it as a 
// control variable)



//15
reg examscore homework major male dropout
// Including the variable dropout leads to a further drop in the coefficient. 
// This result cannot be given a causal interpretation, however, because dropout
// is also an OUTCOME variable. Inclusion of another outcome variable re-introduces
// endogeneity when (1) the other outcome is affected by the treatment (meaning 
// it is truely an outcome that is being affected) and (2) There are unobserved 
// factors that influence both outcomes.
//
// In this particular case it seems likely that unobserved ability/motivation 
// will both affect the dropout decision and the examgrade. When the dropout 
// decision is also affected by homework, inculding it into the regression on
// grades will introduce endogeneity EVEN THOUGH homework is randomly assigned.
// This is because homework and the dropout decision are related (homework -> dropout),
// and the dropout decision is related to unobserved ability (unobserved ability
// -> dropout). Hence, this will create a relation between homework and unobserved 
// ability, which is not what we want (homework -> dropout <- unobserved ability).
// [the true argumentation is more technical, see Canvas Q3, but this is the way
// you can think about it intuitively]
 
