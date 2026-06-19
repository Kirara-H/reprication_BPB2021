*===================================================================================
* Replication project

* Combine all reproduction results by the new estimator in repframe format
* (did_multiplegt_dyn results)
* 06.2026
* Author: Kirara Homma
*===================================================================================

*-----------------------------------------------------------*
* Step 1: Run regressions and store estimates
*-----------------------------------------------------------*
// run in 03_reproduction_rc_by_new_est do-file

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

* other tests
forvalues i = 1/8 {
	local v = `i' + 1
	
	est restore out1_road_`i'
	replace b = e(Av_tot_effect) in `v'
	replace se     = e(se_avg_total_effect) in `v'
	replace p      = 2*(1 - normal(abs(b/se))) in `v'
	replace outcome = 1 in `v'
	replace treatment = 1 in `v'
	replace analysis = "out1_road_`i'" in `v'
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

* other tests
forvalues i = 1/8 {
	local v = `i' + 10
	
	est restore out1_irri_`i'
	replace b = e(Av_tot_effect) in `v'
	replace se     = e(se_avg_total_effect) in `v'
	replace p      = 2*(1 - normal(abs(b/se))) in `v'
	replace outcome = 2 in `v'
	replace treatment = 2 in `v'
	replace analysis = "out1_irri_`i'" in `v'
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
	
* other tests
forvalues i = 1/9 {
	local v = `i' + 19
	
	est restore out2_road_`i'
	replace b = e(Av_tot_effect) in `v'
	replace se     = e(se_avg_total_effect) in `v'
	replace p      = 2*(1 - normal(abs(b/se))) in `v'
	replace outcome = 3 in `v'
	replace treatment = 1 in `v'
	replace analysis = "out2_road_`i'" in `v'
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

* other tests
forvalues i = 1/9 {
	local v = `i' + 29
	
	est restore out2_irri_`i'
	replace b = e(Av_tot_effect) in `v'
	replace se     = e(se_avg_total_effect) in `v'
	replace p      = 2*(1 - normal(abs(b/se))) in `v'
	replace outcome = 4 in `v'
	replace treatment = 2 in `v'
	replace analysis = "out2_irri_`i'" in `v'
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

save "D:\Shared Data\homma\PhD_2025\Replication_game\output\repframe_other_rc_by_new_est.dta", replace


use "D:\Shared Data\homma\PhD_2025\Replication_game\output\repframe_other_rc_by_new_est.dta", clear
* drop log transformation
drop if analysis == "out1_road_3"
drop if analysis == "out1_irri_3"
drop if analysis == "out2_road_3"
drop if analysis == "out2_irri_3"
drop if analysis == "out2_road_5"
drop if analysis == "out2_irri_5"

repframe outcome, beta(b) se(se) pval(p) origpath(origpath) siglevel_orig(10) siglevel(5) shortref("KH")


************ output ************ 
** figure
graph export "D:\Shared Data\homma\PhD_2025\Replication_game\output\dashboard_other_rc_by_new_est.jpg", as(jpg) name("dashboard_main") quality(90) replace

** table
export delimited "D:\Shared Data\homma\PhD_2025\Replication_game\output\repframe_other_rc_by_new_est.csv", replace
