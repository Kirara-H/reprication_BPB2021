*===================================================================================
* Replication project

* Summarize reproduction results by the new estimator in repframe format
* (did_multiplegt_dyn results)
* 09.2026
* Author: Kirara Homma
*===================================================================================

*-----------------------------------------------------------*
* Step 1: Run regressions and store estimates
*-----------------------------------------------------------*
// run in 03_reproduction_new_est do-file

*-----------------------------------------------------------*
* Step 2: Clean the results
*-----------------------------------------------------------*
global dt_output "D:\Shared Data\homma\PhD_2025\Replication_game\output"

use "$dt_output\repframe_multiverse_dCH_out1.dta", clear
append using "$dt_output\repframe_multiverse_dCH_out2.dta"
append using "$dt_output\repframe_multiverse_dCH_out3.dta"
append using "$dt_output\repframe_multiverse_dCH_out4.dta"

keep if origpath == 1
replace origpath = 2

* use the original TWFE estimates as baseline
append using "$dt_output\repframe_multiverse_twfe_out1.dta"
append using "$dt_output\repframe_multiverse_twfe_out2.dta"
append using "$dt_output\repframe_multiverse_twfe_out3.dta"
append using "$dt_output\repframe_multiverse_twfe_out4.dta"

drop if origpath == 0
replace origpath = 0 if origpath == 2 // all estimates with new estimator

* clean data
label define loutcome 1 "ndvi, road" 2 "ndvi, irri" 3 "tree cover, road" 4 "tree cover, irri"
label val outcome loutcome 

label define ltreat 1 "road" 2 "irrigation"
label val treatment ltreat 

sort outcome

*-----------------------------------------------------------*
* Step 3: Create result table (Table 3)
*-----------------------------------------------------------*
decode treatment, gen(treatment_st)

*---------------- 1. column order and header text ----------------
gen byte col  = origpath + 1               // 1..2

*---------------- 2. formatted cells ----------------
local fmt "%9.6f"
gen str4  stars = cond(p<.01,"***", cond(p<.05,"**", cond(p<.10,"*","")))
gen str40 cell  = strtrim(string(b, "`fmt'")) + stars + ///
                  " (" + strtrim(string(se,"`fmt'")) + ")"

keep origpath outcome cell
reshape wide cell, i(origpath) j(outcome) 
gsort -origpath


************ output ************ 
export excel "$dt_output\tab3.xlsx", replace


