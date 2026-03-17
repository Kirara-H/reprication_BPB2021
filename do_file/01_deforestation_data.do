*================================================================
* Clean TMF deforestation data at commune level
*================================================================

* set your working directory
cd "D:\homma\PhD_2025\Replication_game"

global dt_data "D:\homma\PhD_2025\Replication_game\data"

* check that required datasets are in working directory
local files "main_panel commune_panel"
foreach i in `files' {
	confirm file "`i'.dta"
}
confirm file "data\deforestation\Annual_Forest_Share_Commune_1999_2018.csv"


*-----------------------------------------------------
* get internal commune id info
*-----------------------------------------------------
* load the panel dataset
use main_panel, clear

* get commune name variable
keep commune_id commune_name
duplicates drop commune_id commune_name, force

* clean data and save
sort commune_id
drop if commune_id == .

** drop duplicated obs without commune name info
drop if commune_name == ""
duplicates report commune_id

save "D:\homma\PhD_2025\Replication_game\data\tmp\commune_name.dta", replace


*-----------------------------------------------------
* add commune id info to the forest share data
*-----------------------------------------------------
* load the commune-level average forest share data from GEE
import delimited "$dt_data\deforestation\Annual_Forest_Share_Commune_1999_2018.csv", clear
keep name_3 forestshare year
duplicates drop name_3 year, force
ren name_3 commune_name

* add commune id info
merge m:m commune_name using "D:\homma\PhD_2025\Replication_game\data\tmp\commune_name.dta"
keep if _merge == 3
drop _merge

ren forestshare tmf_tree_cover

* save
sort commune_id year
save "D:\homma\PhD_2025\Replication_game\data\tmp\tmf_deforestation.dta", replace


