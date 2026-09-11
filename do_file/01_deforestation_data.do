***************************************************
*  Replication project

*  Prepare for tree cover variable using TMF data
*  Author: Kirara Homma
***************************************************

*================================================================
* Clean TMF deforestation data at commune level
*================================================================

* set your working directory
cd "D:\Shared Data\homma\PhD_2025\Replication_game"
global dt_data "D:\Shared Data\homma\PhD_2025\Replication_game\data"
global dt_tmp "D:\Shared Data\homma\PhD_2025\Replication_game\data\tmp"

* check that required datasets are in working directory
local files "main_panel commune_panel"
foreach i in `files' {
	confirm file "`i'.dta"
}
confirm file "data\deforestation\Annual_Forest_Share_Commune_2000_2018.csv"

                                 
*-----------------------------------------------------
* get internal commune id info
*-----------------------------------------------------
* load the panel dataset
use main_panel, clear

* get commune name variable
keep commune_id commune_name
duplicates drop commune_id, force

* clean data and save
drop if commune_id == . // N = 1
sort commune_id

** drop duplicated obs without commune name info
drop if commune_name == "" // N = 0
duplicates report commune_id

* create commune-year panel for 2000-2018
expand 19

** Create year within each commune
bysort commune_id: gen year = 2000 + _n - 1

* save
sort commune_id year
save "$dt_tmp\commune_name_v3.dta", replace

*-----------------------------------------------------
* add commune id info to the forest share data
*-----------------------------------------------------
* clean data from GEE
import delimited "$dt_data\deforestation\Annual_Forest_Share_Commune_2000_2018.csv", clear
keep name_3 forestshare year
duplicates drop name_3 year, force
ren name_3 commune_name

save "$dt_tmp\Annual_Forest_Share_Commune_2000_2018.dta", replace

* add commune id info (commune name in commune_name_v3.dta is manually checked)
use "$dt_data\RA_task\output\RA_task_commune_name.dta", clear
drop if _merge == 2

replace matched_commune_name = commune_name if _merge == 3
  // for _merge == 1: corrected name is stored
replace matched_commune_name = commune_name if matched_commune_name == ""
  // still unmatched after validation (N=54, of which 35 are NA names)
  
keep commune_id commune_name year matched_commune_name 
sort commune_id year

* conservative version
preserve
merge m:1 commune_name year using "$dt_tmp\Annual_Forest_Share_Commune_2000_2018.dta"
tab _merge if year == 2010 // matched: N = 1,291
drop if _merge == 2
drop _merge

ren forestshare tmf_tree_cover

** save
drop matched_commune_name
sort commune_id year
save "$dt_tmp\tmf_deforestation_cons.dta", replace
restore

* manually checked version
preserve
drop commune_name
ren matched_commune_name commune_name

merge m:1 commune_name year using "$dt_tmp\Annual_Forest_Share_Commune_2000_2018.dta"
tab _merge if year == 2010 // matched: N = 1,458
drop if _merge == 2
drop _merge

ren commune_name matched_commune_name
ren forestshare tmf_tree_cover

** save
sort commune_id year
save "$dt_tmp\tmf_deforestation_man.dta", replace
restore

*-----------------------------------------------------
* construct final data for forest outcome replication analysis
*-----------------------------------------------------
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

* conservative version
preserve
merge 1:1 commune_id year using "$dt_tmp\tmf_deforestation_cons.dta"
drop _merge
save "$dt_data\commune_tmf_deforestation_cons.dta", replace
restore

* manually checked version
preserve
merge 1:1 commune_id year using "$dt_tmp\tmf_deforestation_man.dta"
drop _merge
save "$dt_data\commune_tmf_deforestation_man.dta", replace
restore

