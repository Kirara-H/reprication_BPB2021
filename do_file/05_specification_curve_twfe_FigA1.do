*===================================================================================
* Replication project

* Specification curve
* 09.2026
* Author: Kirara Homma
*===================================================================================

*===================================================================================
* Set up
*===================================================================================
* set your working directory
cd "D:\Shared Data\homma\PhD_2025\Replication_game"

* check that required datasets are in working directory
local files "main_panel pid commune_panel"
foreach i in `files' {
	confirm file "`i'.dta"
}

global dt_output "D:\Shared Data\homma\PhD_2025\Replication_game\output"

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

* different outcomes
summ ndvi treecover, d

gen log_ndvi = log(ndvi)
gen log_treecover = log(treecover)
gen log_treecover_plus1 = log(treecover+1)

gen asinh_ndvi = asinh(ndvi)
gen asinh_treecover = asinh(treecover)

* different treatment
gen trt_overall_road_wt1km = trt_road_1kmband
gen trt_overall_road_wt2km = trt_road_1kmband + trt_road_2kmband
gen trt_overall_road_wt3km = trt_road_1kmband + trt_road_2kmband + trt_road_3kmband
gen trt_overall_road_wt4km = trt_road_1kmband + trt_road_2kmband + trt_road_3kmband + trt_road_4kmband

gen trt_overall_irri_wt1km = trt_irrigation_1kmband
gen trt_overall_irri_wt2km = trt_irrigation_1kmband + trt_irrigation_2kmband
gen trt_overall_irri_wt3km = trt_irrigation_1kmband + trt_irrigation_2kmband + trt_irrigation_3kmband
gen trt_overall_irri_wt4km = trt_irrigation_1kmband + trt_irrigation_2kmband + trt_irrigation_3kmband + trt_irrigation_4kmband

* different controls
gen ntl_00 = ntl if year == 2000
bys cell_id: egen ntl_2000 = max(ntl_00)
drop ntl_00

*===================================================================================
* Create specification curve for each outcome
*===================================================================================
est clear

*-----------------------------------------------------
* Outcome 1: NDVI-road
*-----------------------------------------------------
rename trt_overall_road trt_overall_road_base

local k 0
local ndvi_road_speclist ""

foreach clustering in "commune_id year" "cell_id" "commune_id" {
 foreach outcome in ndvi asinh_ndvi {
  foreach tv in trt_overall_road_base trt_overall_road_wt3km trt_overall_road_wt4km {
   foreach control in "" ///
       "c.year#c.(bombing_dummy burial_dummy memorial_dummy prison_dummy distance_to_city distance_to_road)" ///
       "c.year#c.(pop_density_2000 ntl_2000)" {

      rename `tv' trt_overall_road

      reghdfe `outcome' trt_overall_road trt_overall_irrigation trt_overall_else ///
          temperature precipitation `control' ///
          [aw=cell_count_30m], absorb(cell_id year) cluster(`clustering')

      local ++k
      estimates store ndvi_road_`k'
      local ndvi_road_speclist "`ndvi_road_speclist' ndvi_road_`k'"

      rename trt_overall_road `tv'
   }
  }
 }
}

* specification curve
estimates dir
speccurve`ndvi_road_speclist' , ///
          param(trt_overall_road) controls main(ndvi_road_1) panel(countryfe) level(95) ytitle((1) NDVI, road)
graph save "$dt_output\ndvi_road.gph", replace

rename trt_overall_road_base trt_overall_road

*-----------------------------------------------------
* Outcome 2: NDVI-irrigation 
*-----------------------------------------------------
rename trt_overall_irrigation trt_overall_irrigation_base

local k 0
local ndvi_irri_speclist ""

foreach clustering in "commune_id year" "cell_id" "commune_id" {
 foreach outcome in ndvi asinh_ndvi {
  foreach tv in trt_overall_irrigation_base trt_overall_irri_wt3km trt_overall_irri_wt4km{
   foreach control in "" ///
       "c.year#c.(bombing_dummy burial_dummy memorial_dummy prison_dummy distance_to_city distance_to_road)" ///
       "c.year#c.(pop_density_2000 ntl_2000)" {

      rename `tv' trt_overall_irrigation

      reghdfe `outcome' trt_overall_road trt_overall_irrigation trt_overall_else ///
          temperature precipitation `control' ///
          [aw=cell_count_30m], absorb(cell_id year) cluster(`clustering')

      local ++k
      estimates store ndvi_irri_`k'
      local ndvi_irri_speclist "`ndvi_irri_speclist' ndvi_irri_`k'"

      rename trt_overall_irrigation `tv'
   }
  }
 }
}

* specification curve
speccurve`ndvi_irri_speclist' , ///
          param(trt_overall_irrigation) controls main(ndvi_irri_1) panel(countryfe) level(95) ytitle((2) NDVI, irri)
graph save "$dt_output\ndvi_irri.gph", replace
	  
rename trt_overall_irrigation_base trt_overall_irrigation

*-----------------------------------------------------
* Outcome 3: Tree cover-road
*-----------------------------------------------------
rename trt_overall_road trt_overall_road_base

local k 0
local tree_road_speclist ""

foreach clustering in "commune_id year" "cell_id" "commune_id" {
 foreach outcome in treecover asinh_treecover {
  foreach tv in trt_overall_road_base trt_overall_road_wt3km trt_overall_road_wt4km {
   foreach control in "" ///
       "c.year#c.(bombing_dummy burial_dummy memorial_dummy prison_dummy distance_to_city distance_to_road)" ///
       "c.year#c.(pop_density_2000 ntl_2000)" {

      rename `tv' trt_overall_road

      reghdfe `outcome' trt_overall_road trt_overall_irrigation trt_overall_else ///
          temperature precipitation `control' ///
          [aw=cell_count_30m], absorb(cell_id year) cluster(`clustering')

      local ++k
      estimates store tree_road_`k'
      local tree_road_speclist "`tree_road_speclist' tree_road_`k'"

      rename trt_overall_road `tv'
   }
  }
 }
}

* specification curve
estimates dir
speccurve`tree_road_speclist' , ///
          param(trt_overall_road) controls main(tree_road_1) panel(countryfe) level(95) ytitle((3) Tree cover, road)
graph save "$dt_output\tree_road.gph", replace

rename trt_overall_road_base trt_overall_road	  
		  
*-----------------------------------------------------
* Outcome 4: Tree cover-irrigation 
*-----------------------------------------------------
rename trt_overall_irrigation trt_overall_irrigation_base

local k 0
local tree_irri_speclist ""

foreach clustering in "commune_id year" "cell_id" "commune_id" {
 foreach outcome in treecover asinh_treecover {
  foreach tv in trt_overall_irrigation_base trt_overall_irri_wt3km trt_overall_irri_wt4km{
   foreach control in "" ///
       "c.year#c.(bombing_dummy burial_dummy memorial_dummy prison_dummy distance_to_city distance_to_road)" ///
       "c.year#c.(pop_density_2000 ntl_2000)" {

      rename `tv' trt_overall_irrigation

      reghdfe `outcome' trt_overall_road trt_overall_irrigation trt_overall_else ///
          temperature precipitation `control' ///
          [aw=cell_count_30m], absorb(cell_id year) cluster(`clustering')

      local ++k
      estimates store tree_irri_`k'
      local tree_irri_speclist "`tree_irri_speclist' tree_irri_`k'"

      rename trt_overall_irrigation `tv'
   }
  }
 }
}

* specification curve
estimates dir
speccurve`tree_irri_speclist' , ///
          param(trt_overall_irrigation) controls main(tree_irri_1) panel(countryfe) level(95) ytitle((4) Tree cover, irri)
graph save "$dt_output\tree_irri.gph", replace
	  
rename trt_overall_irrigation_base trt_overall_irrigation


*-----------------------------------------------------
* Combine all
*-----------------------------------------------------
graph combine "$dt_output\ndvi_road.gph" "$dt_output\ndvi_irri.gph" "$dt_output\tree_road.gph" "$dt_output\tree_irri.gph", xsize(15) ysize(10)
graph export "$dt_output\Fig_a1_spe_curve.jpg", as(jpg) width(3000) quality(100) replace

