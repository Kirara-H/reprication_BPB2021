

* set directory
global dt_tmp ""


* load main data (N = 1,510 * 2000-2018) 
use "$dt_tmp\commune_name_v3.dta", clear
duplicates report commune_id year

* merge with TMF data by commune name & year
merge m:1 commune_name year using "$dt_tmp\Annual_Forest_Share_Commune_2000_2018.dta"

* check unmatched obs
tab _merge if year == 2000
  // _merge == 3: matched communes (N=1,291)
  // _merge == 1: unmatched communes (N=219)
  
br if _merge == 1 & year == 2000
  // Out of _merge==1, 35 communes have commune_name = "n.a. (#)"
  // The rest of 184 communes can be merged with TMF data (those with _merge==2)-> check spells