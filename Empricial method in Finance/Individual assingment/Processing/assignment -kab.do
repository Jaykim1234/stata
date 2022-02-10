clear
use "C:\Users\kaabm\Desktop\EMF\final_dataset.dta" 
cd "C:\Users\kaabm\Desktop\EMF"
xtset gvkey year
//
// gen BC_first = 1 if BC[_n] != BC[_n-1] & gvkey[_n]==gvkey[_n-1]

// gen BC_three_years = 1 if gvkey[_n]==gvkey[_n-1] & (BC_first!=BC_first[_n+3] | BC_first!=BC_first[_n+2] | BC_first!=BC_first[_n+1])
// replace BC_three_years = 0 if BC_three_years!=1
//
// replace BC_three_years = 0 if BC_three_years == BC_first
// drop BC_first
//
// by gvkey: egen sum_BC = total(BC) 
// by gvkey: gen no_BC = 1 if sum_BC==0
// replace no_BC=0 if no_BC==.
//
//
// xtset gvkey year
//
// keep if BC_three_years==1 | no_BC==1
//
// reg lnassets if no_BC==0, cluster(incorpn)
//
// eststo BC: quietly estpost sum lnassets roi lev cagr cfvol vol delist lncash if BC_three_years==1
// eststo no_BC_: quietly estpost sum lnassets roi lev cagr cfvol vol delist lncash if no_BC == 1
// eststo diff: quietly estpost ttest lnassets roi lev cagr cfvol vol delist lncash, by(no_BC)
// esttab BC no_BC_ diff using random.doc, cells("mean(pattern(1 1 0) fmt(3)) p(pattern(0 0 1) fmt(3))" sd(pattern(1 1 0) par fmt(3))) label

// egen state_year = group(staten year)
// egen industry_year = group(sic year)
//Table 2
// quietly asdoc reghdfe vol BC, absorb(state_year industry_year gvkey) vce(cluster incorp) save(new.doc) nest replace
// quietly asdoc reghdfe delist BC, absorb(state_year industry_year gvkey) vce(cluster incorp) save(new.doc) nest
// quietly asdoc reghdfe assetvol BC, absorb(state_year industry_year gvkey) vce(cluster incorp) save(new.doc) nest
// quietly asdoc reghdfe cfvol BC, absorb(state_year industry_year gvkey) vce(cluster incorp) save(new.doc) nest
// quietly asdoc reghdfe lncash BC, absorb(state_year industry_year gvkey) vce(cluster incorp) save(new.doc) nest

//Table 2 alternative
// quietly asdoc reghdfe lev BC, absorb(state_year industry_year gvkey) vce(cluster incorp) save(new1.doc) nest replace
// quietly asdoc reghdfe mktlev BC, absorb(state_year industry_year gvkey) vce(cluster incorp) save(new1.doc) nest
// quietly asdoc reghdfe lev_st BC, absorb(state_year industry_year gvkey) vce(cluster incorp) save(new1.doc) nest
// quietly asdoc reghdfe netlev BC, absorb(state_year industry_year gvkey) vce(cluster incorp) save(new1.doc) nest

//Table 2 robustness
// drop  if inrange(sic, 6000, 6799)
// drop if inrange(sic, 4000, 4999)
// quietly asdoc reghdfe vol BC, absorb(state_year industry_year gvkey) vce(cluster incorp) save(new2.doc) nest replace
// quietly asdoc reghdfe delist BC, absorb(state_year industry_year gvkey) vce(cluster incorp) save(new2.doc) nest
// quietly asdoc reghdfe assetvol BC, absorb(state_year industry_year gvkey) vce(cluster incorp) save(new2.doc) nest
// quietly asdoc reghdfe cfvol BC, absorb(state_year industry_year gvkey) vce(cluster incorp) save(new2.doc) nest
// quietly asdoc reghdfe lncash BC, absorb(state_year industry_year gvkey) vce(cluster incorp) save(new2.doc) nest


//Question 3

gen BC_first = 1 if BC[_n] != BC[_n-1] & gvkey[_n]==gvkey[_n-1]

foreach `var' of varlist -5-8{
	
}
gen BC_three_years = 1 if gvkey[_n]==gvkey[_n-1] & BC_first!=BC_first[_n+1]
replace BC_three_years = 0 if BC_three_years!=1