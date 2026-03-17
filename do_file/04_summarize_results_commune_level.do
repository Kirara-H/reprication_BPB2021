*===================================================================================
* Summarize commune-level analyses in repframe format
* 05.03.2026
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

set obs 4

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
************ outcome (3)************ 
	est restore out2_0_original
	matrix b = e(b)
	matrix V = e(V)
	replace b = _b["trt_overall_road"] in 1
	replace se     = _se["trt_overall_road"] in 1
	replace p      = 2 * ttail(e(df_r), abs( b/se))  in 1
	replace outcome = 2 in 1
	replace treatment = 1 in 1
	replace analysis = "out2_0_original" in 1
	replace origpath = 1 in 1

    est restore out2_5
	matrix b = e(b)
	matrix V = e(V)
	replace b = _b["trt_overall_road"] in 2
	replace se     = _se["trt_overall_road"] in 2
	replace p      = 2 * ttail(e(df_r), abs( b/se)) in 2
	replace outcome = 2 in 2
	replace treatment = 1 in 2
	replace analysis = "out2_5" in 2
	replace origpath = 0 in 2
	
************ outcome (4)************ 
	est restore out2_0_original
	matrix b = e(b)
	matrix V = e(V)
	replace b = _b["trt_overall_irrigation"] in 3
	replace se     = _se["trt_overall_irrigation"] in 3
	replace p      = 2 * ttail(e(df_r), abs( b/se))  in 3
	replace outcome = 2 in 3
	replace treatment = 2 in 3
	replace analysis = "out2_0_original" in 3
	replace origpath = 1 in 3

	est restore out2_5
	matrix b = e(b)
	matrix V = e(V)
	replace b = _b["trt_overall_irrigation"] in 4
	replace se     = _se["trt_overall_irrigation"] in 4
	replace p      = 2 * ttail(e(df_r), abs( b/se))  in 4
	replace outcome = 2 in 4
	replace treatment = 2 in 4
	replace analysis = "out2_5" in 4
	replace origpath = 0 in 4
	
	

*-----------------------------------------------------------*
* Step 4: Display the result
*-----------------------------------------------------------*
*gen origpath = cond(analysis == "spec1", 1, 0)

label define loutcome 1 "ndvi, road" 2 "ndvi, irri" 3 "tree cover, road" 4 "tree cover, irri"
label val outcome loutcome 

label define ltreat 1 "road" 2 "irrigation"
label val treatment ltreat 

* output
** table
export delimited "D:\homma\PhD_2025\Replication_game\output\repframe_commune.csv", replace