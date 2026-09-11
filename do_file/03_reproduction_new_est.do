***************************************************
*  Replication project

*  Reproduce robustness checks in Section 3.2 
*  using the new DiD estimator (did_multiplegt_dyn)
*  Author: Kirara Homma
***************************************************

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

foreach i in bombing_dummy burial_dummy memorial_dummy prison_dummy distance_to_city distance_to_road {
	gen year_`i' = year * `i'
}

global cont1 year_bombing_dummy year_burial_dummy year_memorial_dummy year_prison_dummy year_distance_to_city year_distance_to_road

foreach i in pop_density_2000 ntl_2000 {
	gen year_`i' = year * `i'
}

global cont2 year_pop_density_2000 year_ntl_2000

*===================================================================================
* Robustness check
*===================================================================================
est clear

*-----------------------------------------------------
* Outcome 1: NDVI-road
*-----------------------------------------------------
* estimation
postutil clear
postfile myresults outcome treatment origpath str50 clustering str50 out str50 treat str50 control b se p using "$dt_output\repframe_multiverse_dCH_out1.dta", replace

foreach clustering in "commune_id" "cell_id" {
	foreach outcome in ndvi asinh_ndvi {
		foreach treat in trt_overall_road trt_overall_road_wt3km trt_overall_road_wt4km {
			foreach control in "" "$cont1" "$cont2" {
				
				if `"`control'"' == "" {
                    local ctrllab "cont0"
                }
                else if `"`control'"' == "$cont1" {
                    local ctrllab "cont1"
                }
                else {
                    local ctrllab "cont2"
                }
				
				did_multiplegt_dyn `outcome' cell_id year `treat', effects(14)  placebo(5) ///
				controls(trt_overall_irrigation trt_overall_else temperature precipitation `control') ///
				cluster(`clustering') weight(cell_count_30m)
				
				
				local bc  = e(Av_tot_effect)
                local sec = e(se_avg_total_effect)
                if `sec' == 0 | missing(`sec') {
                    local pv = .
                }
                else {
                    local pv = 2*(1 - normal(abs(`bc'/`sec')))
				}
				post myresults (1) (1) (0) ("`clustering'") ("`outcome'") ("`treat'") ("`ctrllab'") ///
				               (`bc') (`sec') (`pv')
					
			}
		}
    }
}

postclose myresults

* save as csv
preserve
use "$dt_output\repframe_multiverse_dCH_out1.dta", clear
replace origpath = 1 in 1 // the original estimation
export delimited "$dt_output\repframe_multiverse_dCH_out1.csv", replace
save "$dt_output\repframe_multiverse_dCH_out1.dta", replace
restore

*-----------------------------------------------------
* Outcome 2: NDVI-irrigation
*-----------------------------------------------------
* estimation
postutil clear
postfile myresults outcome treatment origpath str50 clustering str50 out str50 treat str50 control b se p using "$dt_output\repframe_multiverse_dCH_out2.dta", replace

foreach clustering in "commune_id" "cell_id" {
	foreach outcome in ndvi asinh_ndvi {
		foreach treat in trt_overall_irrigation trt_overall_irri_wt3km trt_overall_irri_wt4km  {
			foreach control in "" "$cont1" "$cont2" {
				
				if `"`control'"' == "" {
                    local ctrllab "cont0"
                }
                else if `"`control'"' == "$cont1" {
                    local ctrllab "cont1"
                }
                else {
                    local ctrllab "cont2"
                }
				
				did_multiplegt_dyn `outcome' cell_id year `treat', effects(14)  placebo(5) ///
				controls(trt_overall_road trt_overall_else temperature precipitation `control') ///
				cluster(`clustering') weight(cell_count_30m)
				
				
				local bc  = e(Av_tot_effect)
                local sec = e(se_avg_total_effect)
                if `sec' == 0 | missing(`sec') {
                    local pv = .
                }
                else {
                    local pv = 2*(1 - normal(abs(`bc'/`sec')))
				}
				post myresults (2) (2) (0) ("`clustering'") ("`outcome'") ("`treat'") ("`ctrllab'") ///
				               (`bc') (`sec') (`pv')
					
			}
		}
    }
}

postclose myresults

* save as csv
preserve
use "$dt_output\repframe_multiverse_dCH_out2.dta", clear
replace origpath = 1 in 1 // the original estimation
export delimited "$dt_output\repframe_multiverse_dCH_out2.csv", replace
save "$dt_output\repframe_multiverse_dCH_out2.dta", replace
restore

*-----------------------------------------------------
* Outcome 3: Tree cover-road
*-----------------------------------------------------
* estimation
postutil clear
postfile myresults outcome treatment origpath str50 clustering str50 out str50 treat str50 control b se p using "$dt_output\repframe_multiverse_dCH_out3.dta", replace

foreach clustering in "commune_id" "cell_id" {
	foreach outcome in treecover asinh_treecover {
		foreach treat in trt_overall_road trt_overall_road_wt3km trt_overall_road_wt4km {
			foreach control in "" "$cont1" "$cont2" {
				
				if `"`control'"' == "" {
                    local ctrllab "cont0"
                }
                else if `"`control'"' == "$cont1" {
                    local ctrllab "cont1"
                }
                else {
                    local ctrllab "cont2"
                }
				
				did_multiplegt_dyn `outcome' cell_id year `treat', effects(14)  placebo(5) ///
				controls(trt_overall_irrigation trt_overall_else temperature precipitation `control') ///
				cluster(`clustering') weight(cell_count_30m)
				
				
				local bc  = e(Av_tot_effect)
                local sec = e(se_avg_total_effect)
                if `sec' == 0 | missing(`sec') {
                    local pv = .
                }
                else {
                    local pv = 2*(1 - normal(abs(`bc'/`sec')))
				}
				post myresults (3) (1) (0) ("`clustering'") ("`outcome'") ("`treat'") ("`ctrllab'") ///
				               (`bc') (`sec') (`pv')
					
			}
		}
    }
}

postclose myresults

* save as csv
preserve
use "$dt_output\repframe_multiverse_dCH_out3.dta", clear
replace origpath = 1 in 1 // the original estimation
export delimited "$dt_output\repframe_multiverse_dCH_out3.csv", replace
save "$dt_output\repframe_multiverse_dCH_out3.dta", replace
restore

*-----------------------------------------------------
* Outcome 4: Tree cover-irrigation
*-----------------------------------------------------
* estimation
postutil clear
postfile myresults outcome treatment origpath str50 clustering str50 out str50 treat str50 control b se p using "$dt_output\repframe_multiverse_dCH_out4.dta", replace

foreach clustering in "commune_id" "cell_id" {
	foreach outcome in treecover asinh_treecover {
		foreach treat in trt_overall_irrigation trt_overall_irri_wt3km trt_overall_irri_wt4km  {
			foreach control in "" "$cont1" "$cont2" {
				
				if `"`control'"' == "" {
                    local ctrllab "cont0"
                }
                else if `"`control'"' == "$cont1" {
                    local ctrllab "cont1"
                }
                else {
                    local ctrllab "cont2"
                }
				
				did_multiplegt_dyn `outcome' cell_id year `treat', effects(14)  placebo(5) ///
				controls(trt_overall_road trt_overall_else temperature precipitation `control') ///
				cluster(`clustering') weight(cell_count_30m)
				
				
				local bc  = e(Av_tot_effect)
                local sec = e(se_avg_total_effect)
                if `sec' == 0 | missing(`sec') {
                    local pv = .
                }
                else {
                    local pv = 2*(1 - normal(abs(`bc'/`sec')))
				}
				post myresults (4) (2) (0) ("`clustering'") ("`outcome'") ("`treat'") ("`ctrllab'") ///
				               (`bc') (`sec') (`pv')
					
			}
		}
    }
}

postclose myresults

* save as csv
preserve
use "$dt_output\repframe_multiverse_dCH_out4.dta", clear
replace origpath = 1 in 1 // the original estimation
export delimited "$dt_output\repframe_multiverse_dCH_out4.csv", replace
save "$dt_output\repframe_multiverse_dCH_out4.dta", replace
restore
