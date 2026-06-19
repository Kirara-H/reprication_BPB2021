# Reprication for Baehr, C. et al. (2021)
## TMF deforestation data
TMF deforestation data is processed in GEE, using commune shape file (gadm41_KHM_3).
The link to GEE code is available in "GEE_deforestation_data_extraction" text file.
The extracted data is cleaned and saved as dta format (see "01_deforestation_data.do").

## Reproduction
All robustness checks by TMFE are conducted in 02_reproduction_v2.do. All robustness checks by the new DiD estimator are conducted in 03_reproduction_rc_by_new_est.do. 
The reproduced results are summarized and the reproducibility dashboard is created in 03-07 do files.
The specofication curve is plotted in 09_specification_curve.do,
The sensitivity analysis is conduceted in R (10_sensitivity_analysis_sensemakr.R).
