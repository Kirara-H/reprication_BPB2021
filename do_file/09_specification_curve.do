*===================================================================================
* Replication project

* Specification curve
* 03.2026
* Author: Kirara Homma
*===================================================================================


*-----------------------------------------------------------*
* Step 1: Run regressions and store estimates
*-----------------------------------------------------------*
// run in 02_reproduction_v2 do-file

*-----------------------------------------------------------*
* Step 2: Rerun Binned distance analysis 
*-----------------------------------------------------------*
// To change treatment variable name 

* additional variable
gen trt_overall_road_wt1km = trt_road_1kmband
gen trt_overall_road_wt2km = trt_road_1kmband + trt_road_2kmband
gen trt_overall_road_wt3km = trt_road_1kmband + trt_road_2kmband + trt_road_3kmband
gen trt_overall_road_wt4km = trt_road_1kmband + trt_road_2kmband + trt_road_3kmband + trt_road_4kmband

gen trt_overall_irri_wt1km = trt_irrigation_1kmband
gen trt_overall_irri_wt2km = trt_irrigation_1kmband + trt_irrigation_2kmband
gen trt_overall_irri_wt3km = trt_irrigation_1kmband + trt_irrigation_2kmband + trt_irrigation_3kmband
gen trt_overall_irri_wt4km = trt_irrigation_1kmband + trt_irrigation_2kmband + trt_irrigation_3kmband + trt_irrigation_4kmband

* (1): NDVI-road
preserve
drop trt_overall_road
forvalues i = 1/4 {
	ren trt_overall_road_wt`i'km trt_overall_road
	reghdfe ndvi trt_overall_road trt_overall_irrigation trt_overall_else temperature precipitation [aw=cell_count_30m], absorb(cell_id year) cluster(cell_id)
	estimates store out1_6_road_`i'
	ren trt_overall_road trt_overall_road_wt`i'km
}
restore

* (2): NDVI-irrigation
preserve
drop trt_overall_irrigation
forvalues i = 1/4 {
	ren trt_overall_irri_wt`i'km trt_overall_irrigation
	reghdfe ndvi trt_overall_irrigation trt_overall_road trt_overall_else temperature precipitation [aw=cell_count_30m], absorb(cell_id year) cluster(cell_id)
	estimates store out1_6_irri_`i'
	ren trt_overall_irrigation trt_overall_irri_wt`i'km
}
restore

* (3): Tree cover-road
preserve
drop trt_overall_road
forvalues i = 1/4 {
	ren trt_overall_road_wt`i'km trt_overall_road
	reghdfe treecover trt_overall_road trt_overall_irrigation trt_overall_else temperature precipitation [aw=cell_count_30m], absorb(cell_id year) cluster(cell_id)
	estimates store out2_6_road_`i'
	ren trt_overall_road trt_overall_road_wt`i'km
}
restore

* (4): Tree cover-irrigation
preserve
drop trt_overall_irrigation
forvalues i = 1/4 {
	ren trt_overall_irri_wt`i'km trt_overall_irrigation
	reghdfe treecover trt_overall_irrigation trt_overall_road trt_overall_else temperature precipitation [aw=cell_count_30m], absorb(cell_id year) cluster(cell_id)
	estimates store out2_6_irri_`i'
	ren trt_overall_irrigation trt_overall_irri_wt`i'km
}
restore

*-----------------------------------------------------------*
* Step 3: Plot specification curve (all robustness by TWFE)
*-----------------------------------------------------------*
estimates dir

cd "D:\Shared Data\homma\PhD_2025\Replication_game\output"

* NDVI, irrigation
speccurve out1_0 out1_2 out1_3 out1_6_irri_3 out1_6_irri_4 out1_7 out1_8 out1_10, ///
          param(trt_overall_irrigation) controls main(out1_0) panel(countryfe) level(95) ytitle((2) NDVI, irri)
graph save "ndvi_irri.gph", replace

* NDVI, road
speccurve out1_0 out1_2 out1_3 out1_6_road_3 out1_6_road_4 out1_7 out1_8 out1_10, ///
          param(trt_overall_road) controls main(out1_0) panel(countryfe) level(95) ytitle((1) NDVI, road)
graph save "ndvi_road.gph", replace

* tree cover, irrigation
speccurve out2_0 out2_2 out2_3 out2_6_irri_3 out2_6_irri_4 out2_7 out2_8 out2_11, ///
          param(trt_overall_irrigation) controls main(out2_0) panel(countryfe) level(95) ytitle((4) Tree cover, irri)
graph save "tc_irri.gph", replace

* treee cover, road
speccurve out2_0 out2_2 out2_3 out2_6_road_3 out2_6_road_4 out2_7 out2_8 out2_11, ///
          param(trt_overall_road) controls main(out2_0) panel(countryfe) level(95) ytitle((3) Tree cover, road)		  
graph save "tc_road.gph", replace

* Combine all
graph combine ndvi_road.gph ndvi_irri.gph tc_road.gph tc_irri.gph, xsize(25) ysize(30)
graph export "spe_curve_2.png", as(png) replace width(4000)




** with did_multiple_dyn	
/*	  
* NDVI, irrigation
speccurve out1_0 out1_irri out1_2 out1_3 out1_6_irri_1 out1_6_irri_2 out1_6_irri_3 out1_6_irri_4 out1_7 out1_8 out1_9 out1_10, ///
          param(trt_overall_irrigation) controls main(out1_0) panel(countryfe) level(95) ytitle((2) NDVI, irri)
*graph export "D:\homma\PhD_2025\Replication_game\output\spe_curve_ndvi_irri.jpg", replace as(jpg)
graph save "ndvi_irri2.gph", replace

* NDVI, road
speccurve out1_0 out1_road out1_2 out1_3 out1_6_road_1 out1_6_road_2 out1_6_road_3 out1_6_road_4 out1_7 out1_8 out1_9 out1_10, ///
          param(trt_overall_road) controls main(out1_0) panel(countryfe) level(95) ytitle((1) NDVI, road)
*graph export "D:\homma\PhD_2025\Replication_game\output\spe_curve_ndvi_road.jpg", replace as(jpg)
graph save "ndvi_road2.gph", replace
		  
* tree cover, irrigation
speccurve out2_0 out2_irri out2_2 out2_3 out2_5 out2_6_irri_1 out2_6_irri_2 out2_6_irri_3 out2_6_irri_4 out2_7 out2_8 out2_9 out2_10 out2_11, ///
          param(trt_overall_irrigation) controls main(out2_0) panel(countryfe) level(95) ytitle((4) Tree cover, irri)
*graph export "D:\homma\PhD_2025\Replication_game\output\spe_curve_tc_irri.jpg", replace as(jpg)
graph save "tc_irri2.gph", replace

* treee cover, road
speccurve out2_0 out2_road out2_2 out2_3 out2_5 out2_6_road_1 out2_6_road_2 out2_6_road_3 out2_6_road_4 out2_7 out2_8 out2_9 out2_10 out2_11, ///
          param(trt_overall_road) controls main(out2_0) panel(countryfe) level(95) ytitle((3) Tree cover, road)	  
*graph export "D:\homma\PhD_2025\Replication_game\output\spe_curve_tc_road.jpg", replace as(jpg)
graph save "tc_road2.gph", replace


* Combine all
graph combine ndvi_road2.gph ndvi_irri2.gph tc_road2.gph tc_irri2.gph, xsize(15) ysize(20)
graph export "spe_curve2.png", as(png) replace width(4000)
*/
		  