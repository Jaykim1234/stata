cls
clear all

cd "C:\Users\Jinhyun\Documents\GitHub\stata\Empricial method in Finance\Individual assingment"

use "CRSP.dta"

g per_exit = 0 
replace per_exit = 1 if inrange(DLSTCD, 400, 500) 
replace per_exit = 1 if DLSTCD == 500 
replace per_exit = 1 if DLSTCD == 552 
replace per_exit = 1 if DLSTCD == 560 
replace per_exit = 1 if DLSTCD == 561
replace per_exit = 1 if DLSTCD == 572
replace per_exit = 1 if DLSTCD == 574
replace per_exit = 1 if DLSTCD == 580
replace per_exit = 1 if DLSTCD == 584

egen vol_stock = sd(RET) // Stock volatility