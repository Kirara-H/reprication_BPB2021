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
foreach i in 7 {
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
replace b = _b["trt_overall_irrigation"] in 10
replace se     = _se["trt_overall_irrigation"] in 10
replace p      = 2 * ttail(e(df_r), abs( b/se))  in 10
replace outcome = 2 in 10
replace treatment = 2 in 10
replace analysis = "out1_0" in 10
replace origpath = 1 in 10
	
* new did estimator: .0044542   .0009988
est restore out1_irri
replace b = e(Av_tot_effect) in 11
replace se     = e(se_avg_total_effect) in 11
replace p      = 2*(1 - normal(abs(b/se))) in 11
replace outcome = 2 in 11
replace treatment = 2 in 11
replace analysis = "out1_1" in 11
replace origpath = 0 in 11


* other replications
forvalues i = 2/3 {
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

* binned analysis
forvalues i = 1/4 {
    local v = `i' + 13
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
foreach i in 7 {
    local v = `i' + 11
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
	
* new did estimator:  -.0065476   .0019217
est restore out2_road
replace b = e(Av_tot_effect) in 20
replace se     = e(se_avg_total_effect) in 20
replace p      = 2*(1 - normal(abs(b/se))) in 20
replace outcome = 3 in 20
replace treatment = 1 in 20
replace analysis = "out2_1" in 20
replace origpath = 0 in 20


* other replications
forvalues i = 2/3 {
    local v = `i' + 19
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

* binned analysis
forvalues i = 1/4 {
    local v = `i' + 23
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
foreach i in 7 {
    local v = `i' + 21
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
	
* new did estimator: 
est restore out2_irri
replace b = e(Av_tot_effect) in 30
replace se     = e(se_avg_total_effect) in 30
replace p      = 2*(1 - normal(abs(b/se))) in 30
replace outcome = 4 in 30
replace treatment = 2 in 30
replace analysis = "out2_1" in 30
replace origpath = 0 in 30


* other replications
forvalues i = 2/3 {
    local v = `i' + 29
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

* binned analysis
forvalues i = 1/4 {
    local v = `i' + 33
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
foreach i in 7 {
    local v = `i' + 31
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
* Step 4: Display the table
*-----------------------------------------------------------*
*gen origpath = cond(analysis == "spec1", 1, 0)

label define loutcome 1 "ndvi, road" 2 "ndvi, irri" 3 "tree cover, road" 4 "tree cover, irri"
label val outcome loutcome 

label define ltreat 1 "road" 2 "irrigation"
label val treatment ltreat 

save "D:\homma\PhD_2025\Replication_game\output\repframe_v3.dta", replace
*export delimited "D:\homma\PhD_2025\Replication_game\output\repframe.csv", replace
repframe outcome, beta(b) se(se) pval(p) origpath(origpath) siglevel_orig(10) siglevel(5) shortref("KH")

