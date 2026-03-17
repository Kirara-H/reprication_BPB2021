*===================================================================================
* Combine all reproduction results in repframe format
* 11.2025
* Author: Kirara Homma
*===================================================================================

*-----------------------------------------------------------*
* Step 1: Run regressions and store estimates
*-----------------------------------------------------------*
// run in 02_reproduction do-file

*-----------------------------------------------------------*
* Step 2: Create an empty dataset for the table
*-----------------------------------------------------------*
clear

set obs 52

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
	
* new did estimator
est restore out1_road
replace b = e(Av_tot_effect) in 2
replace se     = e(se_avg_total_effect) in 2
replace p      = 2*(1 - normal(abs(b/se))) in 2
replace outcome = 1 in 2
replace treatment = 1 in 2
replace analysis = "out1_1" in 2
replace origpath = 0 in 2

* other replications
forvalues i = 2/3 {
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

* binned analysis
forvalues i = 1/4 {
    local v = `i' + 4
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
    local v = `i' + 2
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

* 9: log, 10: asinh
forvalues i = 9/10 {
    local v = `i' + 2
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
replace b = _b["trt_overall_irrigation"] in 13
replace se     = _se["trt_overall_irrigation"] in 13
replace p      = 2 * ttail(e(df_r), abs( b/se))  in 13
replace outcome = 2 in 13
replace treatment = 2 in 13
replace analysis = "out1_0" in 13
replace origpath = 1 in 13
	
* new did estimator: .0044542   .0009988
est restore out1_irri
replace b = e(Av_tot_effect) in 14
replace se     = e(se_avg_total_effect) in 14
replace p      = 2*(1 - normal(abs(b/se))) in 14
replace outcome = 2 in 14
replace treatment = 2 in 14
replace analysis = "out1_1" in 14
replace origpath = 0 in 14


* other replications
forvalues i = 2/3 {
    local v = `i' + 13
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
forvalues i = 1/4 {
    local v = `i' + 16
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
    local v = `i' + 14
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
    local v = `i' + 14
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
replace b = _b["trt_overall_road"] in 25
replace se     = _se["trt_overall_road"] in 25
replace p      = 2 * ttail(e(df_r), abs( b/se)) in 25
replace outcome = 3 in 25
replace treatment = 1 in 25
replace analysis = "out2_0" in 25
replace origpath = 1 in 25
	
* new did estimator:  -.0065476   .0019217
est restore out2_road
replace b = e(Av_tot_effect) in 26
replace se     = e(se_avg_total_effect) in 26
replace p      = 2*(1 - normal(abs(b/se))) in 26
replace outcome = 3 in 26
replace treatment = 1 in 26
replace analysis = "out2_1" in 26
replace origpath = 0 in 26


* other replications
forvalues i = 2/3 {
    local v = `i' + 25
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

foreach i in 5 {
    local v = `i' + 24
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
forvalues i = 1/4 {
    local v = `i' + 29
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
    local v = `i' + 27
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
    local v = `i' + 27
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
replace b = _b["trt_overall_irrigation"] in 39
replace se     = _se["trt_overall_irrigation"] in 39
replace p      = 2 * ttail(e(df_r), abs( b/se))  in 39
replace outcome = 4 in 39
replace treatment = 2 in 39
replace analysis = "out2_0" in 39
replace origpath = 1 in 39
	
* new did estimator: 
est restore out2_irri
replace b = e(Av_tot_effect) in 40
replace se     = e(se_avg_total_effect) in 40
replace p      = 2*(1 - normal(abs(b/se))) in 40
replace outcome = 4 in 40
replace treatment = 2 in 40
replace analysis = "out2_1" in 40
replace origpath = 0 in 40

* other replications
forvalues i = 2/3 {
    local v = `i' + 39
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
foreach i in 5 {
    local v = `i' + 38
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
forvalues i = 1/4 {
    local v = `i' + 43
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
    local v = `i' + 41
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
    local v = `i' + 41
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

save "D:\homma\PhD_2025\Replication_game\output\repframe_v3.dta", replace

repframe outcome, beta(b) se(se) pval(p) origpath(origpath) siglevel_orig(10) siglevel(5) shortref("KH")

* output
** figure
graph export "D:\homma\PhD_2025\Replication_game\output\dashboard_main_v2.jpg", as(jpg) name("dashboard_main") quality(90) replace

** table
preserve
drop if analysis == "out2_5" // TMF results
export delimited "D:\homma\PhD_2025\Replication_game\output\repframe.csv", replace // grid cell-level analyses
restore

