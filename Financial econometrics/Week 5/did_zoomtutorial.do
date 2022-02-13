cls						//this clears the screen
clear all				//this clears the memory
cd "C:\Users\Jinhyun\Documents\GitHub\stata\Financial econometrics\Week 4"

use did.dta, clear

// Part 1:
generate emptot1=emppt*0.5+empft+nmgrs
generate emptot2=emppt2*0.5+empft2+nmgrs2
regress emptot1 state, robust

//state 1 nj 0 pa


// Part 2:
generate statealt=1-state
regress emptot1 statealt, robust



// Part 3:
regress emptot2 state, robust

regress emptot2 statealt, robust



// Part 4:
generate emptotd=emptot2-emptot1
regress emptotd state, robust


// Part 5
keep if emptot1!=. & emptot2!=.
keep restaurant_id state emptot1 emptot2
reshape long emptot, i( restaurant_id) j(time)


//Part 6

xtset restaurant_id
gen treated=0
replace treated=1 if state==1 & time==2
xi: xtreg emptot treated i.time, fe robust


//Part 7

xi: regress emptot treated i.state i.time, robust


// Part 8:
use did.dta, clear
generate emptot1=emppt*0.5+empft+nmgrs
generate emptot2=emppt2*0.5+empft2+nmgrs2
generate emptotd=emptot2-emptot1

// Part 9: 
generate low=0
generate mid=0
generate high=0
generate dna=0
replace low=1 if wage_st==4.25
replace mid=1 if wage_st>4.25 & wage_st<5.00
replace high=1 if wage_st>=5.00
replace dna=1 if wage_st==.

// Part 10:
regress emptot1 low mid high if state==1 & dna==0, noconstant robust


// Part 12:
regress emptot2 low mid high if state==1 & dna==0, noconstant robust

regress emptotd low mid high if state==1 & dna==0, noconstant robust


//Part 13:
tabulate wage_st wage_st2 if state==1 & dna==0 & high==1


