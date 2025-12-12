*===================================================================================
* Set up
*===================================================================================
* set your working directory
cd "D:\homma\PhD_2025\Replication_game"

* check that required datasets are in working directory
local files "main_panel pid commune_panel"
foreach i in `files' {
	confirm file "`i'.dta"
}

********** Load and Process Data **********

* load the panel dataset
use main_panel, clear

* set up the panel with "cell_id" as the panel variable and "year" as the time variable
xtset cell_id year

* aggregate the road project count. The aggregated measure will give the total number of completed road projects within 5km of grid cell x
egen trt_overall_road = rowtotal(trt_road_?kmband)
egen max_trt_overall_road = max(trt_overall_road), by(cell_id)

* aggregate the irrigation project count
egen trt_overall_irrigation = rowtotal(trt_irrigation_?kmband)
egen max_trt_overall_irrigation = max(trt_overall_irrigation), by(cell_id)
* aggregate the total project count (all project types)
egen trt_overall = rowtotal(trt_?kmband)

* create an "other" project count. This is just the total project count minus the number of road and irrigation projects
gen trt_overall_else = trt_overall - (trt_overall_road + trt_overall_irrigation)

* generate a variable with the maximum number of projects a cell is treated by
egen max_trt_overall = max(trt_overall), by(cell_id)
* drop cells which are never treated
drop if max_trt_overall==0
* generate a new categorical variable for max_treatment. Values above 20 are topcoded
egen cut_max_trt_overall = cut(max_trt_overall), at(0(1)20 1000) label

* generate a variable indicating whether a cell has received any treatments yet
gen trt_overall_pos = (trt_overall>0)
* identify the year of first treatment
gen yr_tmp = year if trt_overall_pos==1 & l1.trt_overall_pos==0
* populate all obs of each cell with the year of first treatment
egen year_first_pos = max(yr_tmp), by(cell_id)
* drop temp variable
drop yr_tmp

* generate a high population dummy
gen high_pop = (pop_density_2000>=1000)

* generate a variable indicating whether a cell has received any road-related treatments yet
gen trt_overall_road_pos = (trt_overall_road>0)
* identify the year of first road treatment
gen yr_tmp = year if trt_overall_road_pos==1 & l1.trt_overall_road_pos==0
* populate all obs of each cell with the year of first road-related treatment
egen year_first_road_pos = max(yr_tmp), by(cell_id)
* generate a "years to first road project variable". This idenfities the temporal distance of an observation from initial treatment
gen years_to_first_road = year - year_first_road_pos
* generate years since first treatment. All pre-treatment observations are zero
gen years_since_first_road = max(0, years_to_first_road) 
* drop temp variable
drop yr_tmp
* generate a new categorical variable for road treatment count. Values above 20 are topcoded
egen cut_trt_overall_road = cut(trt_overall_road), at(0(1)20 1000) label

* generate a variable indicating whether a cell has received any irrigation-related treatments yet
gen trt_overall_irrigation_pos = (trt_overall_irrigation>0)
* identify the year of first irrigation treatment
gen yr_tmp = year if trt_overall_irrigation_pos==1 & l1.trt_overall_irrigation_pos==0
* populate all obs of each cell with the year of first irrigation-related treatment
egen year_first_irrigation_pos = max(yr_tmp), by(cell_id)
* generate a "years to first irrigation project variable". This idenfities the temporal distance of an observation from initial irrigation treatment
gen years_to_first_irrigation = year - year_first_irrigation_pos
* generate years since first irrigation treatment. All pre-treatment observations are zero
gen years_since_first_irrigation = max(0, years_to_first_irrigation)
* drop temp variable
drop yr_tmp
* generate a new categorical variable for irrigation treatment count. Values above 20 are topcoded
egen cut_trt_overall_irrigation = cut(trt_overall_irrigation), at(0(1)20 1000) label

* generate indicator of whether a cell has received any non road or irrigation related treatments by year t
gen trt_overall_else_pos = (trt_overall_else>0)
* identify the year of first non road or irrigation treatment
gen yr_tmp = year if trt_overall_else_pos==1 & l1.trt_overall_else_pos==0
* populate all obs of each cell with the year of first non road or irrigation-related treatment
egen year_first_else_pos = max(yr_tmp), by(cell_id)
* generate a "years to first non road or irrigation project variable". This idenfities the temporal distance of an observation from initial non road or irrigation treatment
gen years_to_first_else = year - year_first_else_pos
* generate years since first non road or irrigation treatment. All pre-treatment observations are zero
gen years_since_first_else = max(0, years_to_first_else)

* compute the rowwise mean of yearly percent Seila funding variable across all years (1996-2003)
egen seila_total = rowmean(seila_pct_*)


*===================================================================================
* Robustness check
*===================================================================================
est clear

*-----------------------------------------------------
* 0. the original
*-----------------------------------------------------
*** Table 2
* (1)
reghdfe ndvi trt_overall_road trt_overall_irrigation trt_overall_else temperature precipitation [aw=cell_count_30m], absorb(cell_id year) cluster(commune_id year)
estimates store out1_0

* (2)
reghdfe treecover trt_overall_road trt_overall_irrigation trt_overall_else temperature precipitation [aw=cell_count_30m], absorb(cell_id year) cluster(commune_id year)
estimates store out2_0

*-----------------------------------------------------
* 1. did_multiplegt_dyn
*-----------------------------------------------------
* (1): NDVI-road
did_multiplegt_dyn ndvi cell_id year trt_overall_road, effects(14)  placebo(5) controls(trt_overall_irrigation trt_overall_else temperature precipitation) cluster(commune_id) weight(cell_count_30m)
estimates store out1_road

* (2): NDVI-irrigation
did_multiplegt_dyn ndvi cell_id year trt_overall_irrigation, effects(14)  placebo(5) controls(trt_overall_road trt_overall_else temperature precipitation) cluster(commune_id) weight(cell_count_30m)
estimates store out1_irri

* (3): Tree cover-road
did_multiplegt_dyn treecover cell_id year trt_overall_road, effects(14)  placebo(5) controls(trt_overall_irrigation trt_overall_else temperature precipitation) cluster(commune_id) weight(cell_count_30m)
estimates store out2_road

* (4): Tree cover-irrigation
did_multiplegt_dyn treecover cell_id year trt_overall_irrigation, effects(14)  placebo(5) controls(trt_overall_road trt_overall_else temperature precipitation) cluster(commune_id) weight(cell_count_30m)
estimates store out2_irri

*-----------------------------------------------------
* 2. clustering at grid cell level
*-----------------------------------------------------
* (1), (2)
reghdfe ndvi trt_overall_road trt_overall_irrigation trt_overall_else temperature precipitation [aw=cell_count_30m], absorb(cell_id year) cluster(cell_id) // road & irrigation significant
estimates store out1_2

* (3), (4)
reghdfe treecover trt_overall_road trt_overall_irrigation trt_overall_else temperature precipitation [aw=cell_count_30m], absorb(cell_id year) cluster(cell_id) // all significant
estimates store out2_2

*-----------------------------------------------------
* 3. clustering at commune level
*-----------------------------------------------------
* (1), (2)
reghdfe ndvi trt_overall_road trt_overall_irrigation trt_overall_else temperature precipitation [aw=cell_count_30m], absorb(cell_id year) cluster(commune_id) // exact
estimates store out1_3

* (3), (4)
reghdfe treecover trt_overall_road trt_overall_irrigation trt_overall_else temperature precipitation [aw=cell_count_30m], absorb(cell_id year) cluster(commune_id) // exact
estimates store out2_3

*-----------------------------------------------------
* 4. Conley SEs
*-----------------------------------------------------
// reg2hdfespatial
/*
* (1), (2)
reghdfe ndvi trt_overall_road trt_overall_irrigation trt_overall_else temperature precipitation [aw=cell_count_30m], absorb(cell_id year) cluster(commune_id)
estimates store out1_4

* (3), (4)
reghdfe treecover trt_overall_road trt_overall_irrigation trt_overall_else temperature precipitation [aw=cell_count_30m], absorb(cell_id year) cluster(commune_id)
estimates store out2_4
*/

*-----------------------------------------------------
* 5. TMF deforestation data
*-----------------------------------------------------
* (3), (4)
preserve
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

merge 1:1 commune_id year using "D:\homma\PhD_2025\Replication_game\data\tmp\tmf_deforestation.dta"
drop _merge

* analysis 
reghdfe tmf_tree_cover trt_overall_road trt_overall_irrigation trt_overall_else temperature precipitation [aw=cell_count_30m], absorb(commune_id year) cluster(district_id year)
estimates store out2_5
restore 

*-----------------------------------------------------
* 6. Binned distance analysis (the original paper)
*-----------------------------------------------------
* additional variable
gen trt_overall_road_wt1km = trt_road_1kmband
gen trt_overall_road_wt2km = trt_road_1kmband + trt_road_2kmband
gen trt_overall_road_wt3km = trt_road_1kmband + trt_road_2kmband + trt_road_3kmband
gen trt_overall_road_wt4km = trt_road_1kmband + trt_road_2kmband + trt_road_3kmband + trt_road_4kmband
*gen trt_overall_road_wt5km = trt_road_1kmband + trt_road_2kmband + trt_road_3kmband + trt_road_4kmband + trt_road_5kmband

gen trt_overall_irri_wt1km = trt_irrigation_1kmband
gen trt_overall_irri_wt2km = trt_irrigation_1kmband + trt_irrigation_2kmband
gen trt_overall_irri_wt3km = trt_irrigation_1kmband + trt_irrigation_2kmband + trt_irrigation_3kmband
gen trt_overall_irri_wt4km = trt_irrigation_1kmband + trt_irrigation_2kmband + trt_irrigation_3kmband + trt_irrigation_4kmband
*gen trt_overall_irri_wt5km = trt_irrigation_1kmband + trt_irrigation_2kmband + trt_irrigation_3kmband + trt_irrigation_4kmband + trt_irrigation_5kmband

* (1): NDVI-road
forvalues i = 1/4 {
	reghdfe ndvi trt_overall_road_wt`i'km trt_overall_irrigation trt_overall_else temperature precipitation [aw=cell_count_30m], absorb(cell_id year) cluster(cell_id)
	estimates store out1_6_road_`i'
}

* (2): NDVI-irrigation
forvalues i = 1/4 {
	reghdfe ndvi trt_overall_irri_wt`i'km trt_overall_road trt_overall_else temperature precipitation [aw=cell_count_30m], absorb(cell_id year) cluster(cell_id)
	estimates store out1_6_irri_`i'
}

* (3): Tree cover-road
forvalues i = 1/4 {
	reghdfe treecover trt_overall_road_wt`i'km trt_overall_irrigation trt_overall_else temperature precipitation [aw=cell_count_30m], absorb(cell_id year) cluster(cell_id)
	estimates store out2_6_road_`i'
}

* (4): Tree cover-irrigation
forvalues i = 1/4 {
	reghdfe treecover trt_overall_irri_wt`i'km trt_overall_road trt_overall_else temperature precipitation [aw=cell_count_30m], absorb(cell_id year) cluster(cell_id)
	estimates store out2_6_irri_`i'
}

*-----------------------------------------------------
* 7. Additional control (the original paper)
*-----------------------------------------------------
* (1), (2)
reghdfe ndvi trt_overall_road trt_overall_irrigation trt_overall_else c.year#c.(bombing_dummy burial_dummy memorial_dummy prison_dummy distance_to_city distance_to_road) temperature precipitation [aw = cell_count_30m], absorb(cell_id year) cluster(commune_id year)
estimates store out1_7

* (3), (4)
reghdfe treecover trt_overall_road trt_overall_irrigation trt_overall_else c.year#c.(bombing_dummy burial_dummy memorial_dummy prison_dummy distance_to_city distance_to_road) temperature precipitation [aw = cell_count_30m], absorb(cell_id year) cluster(commune_id year)
estimates store out2_7

*-----------------------------------------------------
* 8. Additional control 2 (the original paper)
*-----------------------------------------------------
gen ntl_00 = ntl if year == 2000
bys cell_id: egen ntl_2000 = max(ntl_00)
drop ntl_00

* (1), (2)
reghdfe ndvi trt_overall_road trt_overall_irrigation trt_overall_else c.year#c.(pop_density_2000 ntl_2000) temperature precipitation [aw = cell_count_30m], absorb(cell_id year) cluster(commune_id year)
estimates store out1_8

* (3), (4)
reghdfe treecover trt_overall_road trt_overall_irrigation trt_overall_else c.year#c.(pop_density_2000 ntl_2000) temperature precipitation [aw = cell_count_30m], absorb(cell_id year) cluster(commune_id year)
estimates store out2_8




