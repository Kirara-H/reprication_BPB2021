***************************************************
*  Replication project

*  Prepare for tree cover variable using TMF data
*  Author: Kirara Homma
***************************************************

*-----------------------------------------------------
* Set up
*-----------------------------------------------------
global dt_output "D:\Shared Data\homma\PhD_2025\Replication_game\output"
global dt_data "D:\Shared Data\homma\PhD_2025\Replication_game\data"

est clear

*-----------------------------------------------------
* Baseline (original results)
*-----------------------------------------------------
* load the commune-level panel
cd "D:\Shared Data\homma\PhD_2025\Replication_game"
use commune_panel, clear

* aggregate the distance-based road treatment measures to a single count of road projects
egen trt_overall_road = rowtotal(trt_road_?kmband)
* aggregate the distance-based irrigation treatment measures to a single count of irrigation projects
egen trt_overall_irrigation = rowtotal(trt_irrigation_?kmband)
* aggregate the distance-based treatment measures to a single count of projects, summing across project types
egen trt_overall = rowtotal(trt_?kmband)

* create an "other" project count. This is just the total project count minus the number of road and irrigation projects
gen trt_overall_else = trt_overall - (trt_overall_road + trt_overall_irrigation)

* maximum number of treatments for each cell
egen max_trt_overall = max(trt_overall), by(commune_id)
* rtopcode the max treatment measure to 20
egen cut_max_trt_overall = cut(max_trt_overall), at(0(1)20 1000) label

reghdfe treecover trt_overall_road trt_overall_irrigation trt_overall_else temperature precipitation [aw=cell_count_30m], absorb(commune_id year) cluster(district_id year)
estimates store out2_0_original
        estadd local model "GFC" , replace

*-----------------------------------------------------
* TMF deforestation data
*-----------------------------------------------------
* (3), (4)

* analysis: conservative version
use "$dt_data\commune_tmf_deforestation_cons.dta", clear
xtset commune_id year

reghdfe tmf_tree_cover trt_overall_road trt_overall_irrigation trt_overall_else temperature precipitation [aw=cell_count_30m], absorb(commune_id year) cluster(district_id year)
estimates store out2_cons
        estadd local model "TMF, conservative" , replace

* analysis: manually checked version
use "$dt_data\commune_tmf_deforestation_man.dta", clear
xtset commune_id year

reghdfe tmf_tree_cover trt_overall_road trt_overall_irrigation trt_overall_else temperature precipitation [aw=cell_count_30m], absorb(commune_id year) cluster(district_id year)
estimates store out2_man
        estadd local model "TMF, full" , replace

*-----------------------------------------------------
* output
*-----------------------------------------------------
esttab out2_0_original out2_cons out2_man using "$dt_output/tab4_tmf.rtf", ///
se(5) replace nogaps starlevels(* 0.10 ** 0.05 *** 0.01)  ///
nomti ///
keep(trt_overall_road trt_overall_irrigation ) ///
o(trt_overall_road trt_overall_irrigation) ///
title("The effect of subsidies on emissions, mitigated by policies") ///
nonotes b(6) label s(model N, fmt(0 %9.0g) ///
labels( "Outcome" "N"))
