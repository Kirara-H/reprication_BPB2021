*===================================================================================
* Replication project

* Summarize reproduction results by the new estimator in repframe format
* (did_multiplegt_dyn results)
* 06.2026
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

set obs 8

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
	
* new did estimator
est restore out1_road
replace b = e(Av_tot_effect) in 2
replace se     = e(se_avg_total_effect) in 2
replace p      = 2*(1 - normal(abs(b/se))) in 2
replace outcome = 1 in 2
replace treatment = 1 in 2
replace analysis = "out1_1" in 2
replace origpath = 0 in 2


************ outcome (2)************ 
* the original
est restore out1_0
matrix b = e(b)
matrix V = e(V)
replace b = _b["trt_overall_irrigation"] in 3
replace se     = _se["trt_overall_irrigation"] in 3
replace p      = 2 * ttail(e(df_r), abs( b/se))  in 3
replace outcome = 2 in 3
replace treatment = 2 in 3
replace analysis = "out1_0" in 3
replace origpath = 1 in 3
	
* new did estimator: .0044542   .0009988
est restore out1_irri
replace b = e(Av_tot_effect) in 4
replace se     = e(se_avg_total_effect) in 4
replace p      = 2*(1 - normal(abs(b/se))) in 4
replace outcome = 2 in 4
replace treatment = 2 in 4
replace analysis = "out1_1" in 4
replace origpath = 0 in 4


************ outcome (3)************ 
* the original
est restore out2_0
matrix b = e(b)
matrix V = e(V)
replace b = _b["trt_overall_road"] in 5
replace se     = _se["trt_overall_road"] in 5
replace p      = 2 * ttail(e(df_r), abs( b/se)) in 5
replace outcome = 3 in 5
replace treatment = 1 in 5
replace analysis = "out2_0" in 5
replace origpath = 1 in 5
	
* new did estimator:  -.0065476   .0019217
est restore out2_road
replace b = e(Av_tot_effect) in 6
replace se     = e(se_avg_total_effect) in 6
replace p      = 2*(1 - normal(abs(b/se))) in 6
replace outcome = 3 in 6
replace treatment = 1 in 6
replace analysis = "out2_1" in 6
replace origpath = 0 in 6


************ outcome (4)************ 
* the original
est restore out2_0
matrix b = e(b)
matrix V = e(V)
replace b = _b["trt_overall_irrigation"] in 7
replace se     = _se["trt_overall_irrigation"] in 7
replace p      = 2 * ttail(e(df_r), abs( b/se))  in 7
replace outcome = 4 in 7
replace treatment = 2 in 7
replace analysis = "out2_0" in 7
replace origpath = 1 in 7
	
* new did estimator: 
est restore out2_irri
replace b = e(Av_tot_effect) in 8
replace se     = e(se_avg_total_effect) in 8
replace p      = 2*(1 - normal(abs(b/se))) in 8
replace outcome = 4 in 8
replace treatment = 2 in 8
replace analysis = "out2_1" in 8
replace origpath = 0 in 8


*-----------------------------------------------------------*
* Step 4: Display the result
*-----------------------------------------------------------*
*gen origpath = cond(analysis == "spec1", 1, 0)

label define loutcome 1 "ndvi, road" 2 "ndvi, irri" 3 "tree cover, road" 4 "tree cover, irri"
label val outcome loutcome 

label define ltreat 1 "road" 2 "irrigation"
label val treatment ltreat 

save "D:\Shared Data\homma\PhD_2025\Replication_game\output\repframe_new_est.dta", replace

* output
** table
export delimited "D:\Shared Data\homma\PhD_2025\Replication_game\output\repframe_new_est.csv", replace // grid cell-level analyses


