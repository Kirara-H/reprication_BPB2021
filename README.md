# Reprication for Baehr, C. et al. (2021)
## TMF deforestation data
TMF deforestation data is processed in GEE, using commune shape file (gadm41_KHM_3).
The link to GEE code is available in "GEE_deforestation_data_extraction" text file.
The extracted data is cleaned and saved as dta format (see "01_deforestation_data.do").

## Reproduction
All robustness checks by TMFE are conducted in 02_reproduction_twfe.do. All robustness checks by the new DiD estimator are conducted in 03_reproduction_new_est.do. 
The reproduced results are summarized and the reproducibility dashboard is created in 04 and 08 do files.
The specification curve is plotted in 05_specification_curve_twfe_FigA1.do,
The sensitivity analysis is conducted in R (10_sensitivity_analysis_sensemakr.R).
TMF tree cover data is cleaned in 01_deforestation_data.do and analyzed in 09_TMF_tree_cover_Table4.do.
