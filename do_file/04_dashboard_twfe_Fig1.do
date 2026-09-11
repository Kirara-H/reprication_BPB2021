*===================================================================================
* Replication project

* Combine all reproduction results by TWFE in Section 3.1 in repframe format
* 09.2026
* Author: Kirara Homma
*===================================================================================

*-----------------------------------------------------------*
* Step 1: Run regressions and store estimates
*-----------------------------------------------------------*
// run in 02_reproduction_twfe do-file

*-----------------------------------------------------------*
* Step 2: Clean the results
*-----------------------------------------------------------*
global dt_output "D:\Shared Data\homma\PhD_2025\Replication_game\output"

use "$dt_output\repframe_multiverse_twfe_out1.dta", clear
append using "$dt_output\repframe_multiverse_twfe_out2.dta"
append using "$dt_output\repframe_multiverse_twfe_out3.dta"
append using "$dt_output\repframe_multiverse_twfe_out4.dta"

label define loutcome 1 "ndvi, road" 2 "ndvi, irri" 3 "tree cover, road" 4 "tree cover, irri"
label val outcome loutcome 

label define ltreat 1 "road" 2 "irrigation"
label val treatment ltreat 

*-----------------------------------------------------------*
* Step 3: Display the result
*-----------------------------------------------------------*
/*
ssc uninstall palettes
ssc uninstall colrspace
ssc install palettes, replace
ssc install colrspace, replace
*/


repframe outcome, beta(b) se(se) pval(p) origpath(origpath) siglevel_orig(5) siglevel(5) shortref("KH")


************ output ************ 
** figure
graph export "D:\Shared Data\homma\PhD_2025\Replication_game\output\dashboard_other_rc.jpg", as(jpg) name("dashboard_main") width(3000) quality(100) replace

** table
export delimited "D:\Shared Data\homma\PhD_2025\Replication_game\output\repframe_other_rc.csv", replace


