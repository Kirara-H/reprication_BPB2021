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

label define loutcome 1 "ndvi, road" 2 "ndvi, irri" 3 "tree cover, road" 4 "tree cover, irri"
label val outcome loutcome 

label define ltreat 1 "road" 2 "irrigation"
label val treatment ltreat 

* use the original TWFE estimates as baseline
replace origpath = 2
append using "$dt_output\repframe_multiverse_twfe_out1.dta"
append using "$dt_output\repframe_multiverse_twfe_out2.dta"
append using "$dt_output\repframe_multiverse_twfe_out3.dta"
append using "$dt_output\repframe_multiverse_twfe_out4.dta"

drop if origpath == 0
replace origpath = 0 if origpath == 2 // all estimates with new estimator

sort outcome

*-----------------------------------------------------------*
* Step 3: Display the result
*-----------------------------------------------------------*

repframe outcome, beta(b) se(se) pval(p) origpath(origpath) siglevel_orig(5) siglevel(5) shortref("KH")

************ output ************ 
** figure
graph export "D:\Shared Data\homma\PhD_2025\Replication_game\output\dashboard_new_est.jpg", as(jpg) name("dashboard_main") width(3000) quality(100) replace

** table
export delimited "D:\Shared Data\homma\PhD_2025\Replication_game\output\repframe_new_est.csv", replace


