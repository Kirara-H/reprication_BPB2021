*===================================================================================
* Replication project

* Combine all reproduction results by TWFE in Section 3.2 in repframe format
* 11.2025
* Author: Kirara Homma
*===================================================================================

*-----------------------------------------------------------*
* Step 1: Run regressions and store estimates
*-----------------------------------------------------------*
// run in 02_reproduction_v2 do-file

*-----------------------------------------------------------*
* Step 2: Create an empty dataset for the table
*-----------------------------------------------------------*
clear

set obs 38

gen str15 analysis = ""
gen float outcome = .
gen float treatment = .
gen float b = .
gen float se = .
gen float p = .
gen float origpath = .

/*
input str15 analysis float(outcome b se p)
"spec1" . . . .
"spec2" . . . .
end
*/

*-----------------------------------------------------------*
* Step 3: Fill in coefficient, SE, and p-value for each row
*-----------------------------------------------------------*

************ outcome (1)************ 
* the original
est restore out1_0
matrix b = e(b)
matrix V = e(V)
replace b = _b["trt_overall_road"] in 1
replace se     = _se["trt_overall_road"] in 1
replace p      = 2 * ttail(e(df_r), abs( b/se))  in 1
replace outcome = 1 in 1
replace treatment = 1 in 1
replace analysis = "out1_0" in 1
replace origpath = 1 in 1

* clustering
forvalues i = 2/3 {
	est restore out1_`i'
	matrix b = e(b)
	matrix V = e(V)
	replace b = _b["trt_overall_road"] in `i'
	replace se     = _se["trt_overall_road"] in `i'
	replace p      = 2 * ttail(e(df_r), abs( b/se))  in `i'
	replace outcome = 1 in `i'
	replace treatment = 1 in `i'
	replace analysis = "out1_`i'" in `i'
	replace origpath = 0 in `i'
}

* outcome transformation: 9: log, 10: asinh
forvalues i = 9/10 {
    local v = `i' - 5
	est restore out1_`i'
	matrix b = e(b)
	matrix V = e(V)
	replace b = _b["trt_overall_road"] in `v'
	replace se     = _se["trt_overall_road"] in `v'
	replace p      = 2 * ttail(e(df_r), abs( b/se))  in `v'
	replace outcome = 1 in `v'
	replace treatment = 1 in `v'
	replace analysis = "out1_`i'" in `v'
	replace origpath = 0 in `v'
}

* binned analysis
forvalues i = 3/4 {
    local v = `i' + 3
	est restore out1_6_road_`i'
	matrix b = e(b)
	matrix V = e(V)
	replace b = _b["trt_overall_road_wt`i'km"] in `v'
	replace se     = _se["trt_overall_road_wt`i'km"] in `v'
	replace p      = 2 * ttail(e(df_r), abs( b/se))  in `v'
	replace outcome = 1 in `v'
	replace treatment = 1 in `v'
	replace analysis = "out1_6_road_`i'" in `v'
	replace origpath = 0 in `v'
}

* additional control
foreach i in 7 8{
    local v = `i' + 1
	est restore out1_`i'
	matrix b = e(b)
	matrix V = e(V)
	replace b = _b["trt_overall_road"] in `v'
	replace se     = _se["trt_overall_road"] in `v'
	replace p      = 2 * ttail(e(df_r), abs( b/se))  in `v'
	replace outcome = 1 in `v'
	replace treatment = 1 in `v'
	replace analysis = "out1_`i'" in `v'
	replace origpath = 0 in `v'
}



************ outcome (2)************ 
* the original
est restore out1_0
matrix b = e(b)
matrix V = e(V)
replace b = _b["trt_overall_irrigation"] in 10
replace se     = _se["trt_overall_irrigation"] in 10
replace p      = 2 * ttail(e(df_r), abs( b/se))  in 10
replace outcome = 2 in 10
replace treatment = 2 in 10
replace analysis = "out1_0" in 10
replace origpath = 1 in 10

* clustering
forvalues i = 2/3 {
    local v = `i' + 9
	est restore out1_`i'
	matrix b = e(b)
	matrix V = e(V)
	replace b = _b["trt_overall_irrigation"] in `v'
	replace se     = _se["trt_overall_irrigation"] in `v'
	replace p      = 2 * ttail(e(df_r), abs( b/se))  in `v'
	replace outcome = 2 in `v'
	replace treatment = 2 in `v'
	replace analysis = "out1_`i'" in `v'
	replace origpath = 0 in `v'
}

* 9: log, 10: asinh
forvalues i = 9/10 {
    local v = `i' + 4
	est restore out1_`i'
	matrix b = e(b)
	matrix V = e(V)
	replace b = _b["trt_overall_irrigation"] in `v'
	replace se     = _se["trt_overall_irrigation"] in `v'
	replace p      = 2 * ttail(e(df_r), abs( b/se))  in `v'
	replace outcome = 2 in `v'
	replace treatment = 2 in `v'
	replace analysis = "out1_`i'" in `v'
	replace origpath = 0 in `v'
}

* binned analysis
forvalues i = 3/4 {
    local v = `i' + 12
	est restore out1_6_irri_`i'
	matrix b = e(b)
	matrix V = e(V)
	replace b = _b["trt_overall_irri_wt`i'km"] in `v'
	replace se     = _se["trt_overall_irri_wt`i'km"] in `v'
	replace p      = 2 * ttail(e(df_r), abs( b/se))  in `v'
	replace outcome = 2 in `v'
	replace treatment = 2 in `v'
	replace analysis = "out1_6_irri_`i'" in `v'
	replace origpath = 0 in `v'
}

* additional control
foreach i in 7 8{
    local v = `i' + 10
	est restore out1_`i'
	matrix b = e(b)
	matrix V = e(V)
	replace b = _b["trt_overall_irrigation"] in `v'
	replace se     = _se["trt_overall_irrigation"] in `v'
	replace p      = 2 * ttail(e(df_r), abs( b/se))  in `v'
	replace outcome = 2 in `v'
	replace treatment = 2 in `v'
	replace analysis = "out1_`i'" in `v'
	replace origpath = 0 in `v'
}


************ outcome (3)************ 
* the original
est restore out2_0
matrix b = e(b)
matrix V = e(V)
replace b = _b["trt_overall_road"] in 19
replace se     = _se["trt_overall_road"] in 19
replace p      = 2 * ttail(e(df_r), abs( b/se)) in 19
replace outcome = 3 in 19
replace treatment = 1 in 19
replace analysis = "out2_0" in 19
replace origpath = 1 in 19
	
* clustering
forvalues i = 2/3 {
    local v = `i' + 18
	est restore out2_`i'
	matrix b = e(b)
	matrix V = e(V)
	replace b = _b["trt_overall_road"] in `v'
	replace se     = _se["trt_overall_road"] in `v'
	replace p      = 2 * ttail(e(df_r), abs( b/se))  in `v'
	replace outcome = 3 in `v'
	replace treatment = 1 in `v'
	replace analysis = "out2_`i'" in `v'
	replace origpath = 0 in `v'
}

* 9: log, 10: log(y+1), 11: asinh
forvalues i = 9/11 {
    local v = `i' + 13
	est restore out2_`i'
	matrix b = e(b)
	matrix V = e(V)
	replace b = _b["trt_overall_road"] in `v'
	replace se     = _se["trt_overall_road"] in `v'
	replace p      = 2 * ttail(e(df_r), abs( b/se))  in `v'
	replace outcome = 3 in `v'
	replace treatment = 1 in `v'
	replace analysis = "out2_`i'" in `v'
	replace origpath = 0 in `v'
}

* binned analysis
forvalues i = 3/4 {
    local v = `i' + 22
	est restore out2_6_road_`i'
	matrix b = e(b)
	matrix V = e(V)
	replace b = _b["trt_overall_road_wt`i'km"] in `v'
	replace se     = _se["trt_overall_road_wt`i'km"] in `v'
	replace p      = 2 * ttail(e(df_r), abs( b/se))  in `v'
	replace outcome = 3 in `v'
	replace treatment = 1 in `v'
	replace analysis = "out2_6_road_`i'" in `v'
	replace origpath = 0 in `v'
}

* additional control
foreach i in 7 8{
    local v = `i' + 20
	est restore out2_`i'
	matrix b = e(b)
	matrix V = e(V)
	replace b = _b["trt_overall_road"] in `v'
	replace se     = _se["trt_overall_road"] in `v'
	replace p      = 2 * ttail(e(df_r), abs( b/se))  in `v'
	replace outcome = 3 in `v'
	replace treatment = 1 in `v'
	replace analysis = "out2_`i'" in `v'
	replace origpath = 0 in `v'
}


************ outcome (4)************ 
* the original
est restore out2_0
matrix b = e(b)
matrix V = e(V)
replace b = _b["trt_overall_irrigation"] in 29
replace se     = _se["trt_overall_irrigation"] in 29
replace p      = 2 * ttail(e(df_r), abs( b/se))  in 29
replace outcome = 4 in 29
replace treatment = 2 in 29
replace analysis = "out2_0" in 29
replace origpath = 1 in 29

* clustering
forvalues i = 2/3 {
    local v = `i' + 28
	est restore out2_`i'
	matrix b = e(b)
	matrix V = e(V)
	replace b = _b["trt_overall_irrigation"] in `v'
	replace se     = _se["trt_overall_irrigation"] in `v'
	replace p      = 2 * ttail(e(df_r), abs( b/se))  in `v'
	replace outcome = 4 in `v'
	replace treatment = 2 in `v'
	replace analysis = "out2_`i'" in `v'
	replace origpath = 0 in `v'
}

* 9: log, 10: log(y+1), 11: asinh
forvalues i = 9/11 {
    local v = `i' + 23
	est restore out2_`i'
	matrix b = e(b)
	matrix V = e(V)
	replace b = _b["trt_overall_irrigation"] in `v'
	replace se     = _se["trt_overall_irrigation"] in `v'
	replace p      = 2 * ttail(e(df_r), abs( b/se))  in `v'
	replace outcome = 4 in `v'
	replace treatment = 2 in `v'
	replace analysis = "out2_`i'" in `v'
	replace origpath = 0 in `v'
}

* binned analysis
forvalues i = 3/4 {
    local v = `i' + 32
	est restore out2_6_irri_`i'
	matrix b = e(b)
	matrix V = e(V)
	replace b = _b["trt_overall_irri_wt`i'km"] in `v'
	replace se     = _se["trt_overall_irri_wt`i'km"] in `v'
	replace p      = 2 * ttail(e(df_r), abs( b/se))  in `v'
	replace outcome = 4 in `v'
	replace treatment = 2 in `v'
	replace analysis = "out2_6_irri_`i'" in `v'
	replace origpath = 0 in `v'
}

* additional control
foreach i in 7 8{
    local v = `i' + 30
	est restore out2_`i'
	matrix b = e(b)
	matrix V = e(V)
	replace b = _b["trt_overall_irrigation"] in `v'
	replace se     = _se["trt_overall_irrigation"] in `v'
	replace p      = 2 * ttail(e(df_r), abs( b/se))  in `v'
	replace outcome = 4 in `v'
	replace treatment = 2 in `v'
	replace analysis = "out2_`i'" in `v'
	replace origpath = 0 in `v'
}


*-----------------------------------------------------------*
* Step 4: Display the result
*-----------------------------------------------------------*
*gen origpath = cond(analysis == "spec1", 1, 0)

label define loutcome 1 "ndvi, road" 2 "ndvi, irri" 3 "tree cover, road" 4 "tree cover, irri"
label val outcome loutcome 

label define ltreat 1 "road" 2 "irrigation"
label val treatment ltreat 

save "D:\Shared Data\homma\PhD_2025\Replication_game\output\repframe_other_rc.dta", replace

/*
ssc uninstall palettes
ssc uninstall colrspace
ssc install palettes, replace
ssc install colrspace, replace
*/

use "D:\Shared Data\homma\PhD_2025\Replication_game\output\repframe_other_rc.dta"

* drop log transformation
drop if analysis == "out1_9"
drop if analysis == "out2_9"
drop if analysis == "out2_10"

repframe outcome, beta(b) se(se) pval(p) origpath(origpath) siglevel_orig(10) siglevel(5) shortref("KH")


************ output ************ 
** figure
graph export "D:\Shared Data\homma\PhD_2025\Replication_game\output\dashboard_other_rc.jpg", as(jpg) name("dashboard_main") quality(90) replace

** table
export delimited "D:\Shared Data\homma\PhD_2025\Replication_game\output\repframe_other_rc.csv", replace


************ repframe 2 ************ 
* add new estimator results
use "D:\Shared Data\homma\PhD_2025\Replication_game\output\repframe_new_est.dta", clear

* drop the original estimates
drop if origpath == 1

* add other rc results
append using "D:\Shared Data\homma\PhD_2025\Replication_game\output\repframe_other_rc.dta"
sort outcome treatment origpath

* output
repframe outcome, beta(b) se(se) pval(p) origpath(origpath) siglevel_orig(10) siglevel(5) shortref("KH")
graph export "D:\Shared Data\homma\PhD_2025\Replication_game\output\dashboard_other_rc_est.jpg", as(jpg) name("dashboard_main") quality(90) replace


************ repframe 3 ************ 
* add new estimator + TMF tree cover outcome results
use "D:\Shared Data\homma\PhD_2025\Replication_game\output\repframe_commune.dta", clear

* add new DID estimator results
append using "D:\Shared Data\homma\PhD_2025\Replication_game\output\repframe_new_est.dta"

* drop the original estimates
drop if origpath == 1

* add other rc results
append using "D:\Shared Data\homma\PhD_2025\Replication_game\output\repframe_other_rc.dta"
sort outcome treatment origpath

* output
repframe outcome, beta(b) se(se) pval(p) origpath(origpath) siglevel_orig(10) siglevel(5) shortref("KH")
graph export "D:\Shared Data\homma\PhD_2025\Replication_game\output\dashboard_other_rc_est_tmf.jpg", as(jpg) name("dashboard_main") quality(90) replace
