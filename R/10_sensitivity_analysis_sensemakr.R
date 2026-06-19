

# set up ------------------------------------------------------------------

#install.packages("sensemakr")
#install.packages("devtools") 
#devtools::install_github("carloscinelli/sensemakr")
#install.packages("htmltools")  

# set library
library(fixest)
library(sensemakr)
library(here())
library(htmltools)

# set directory
data_dir <- "D:/Shared Data/homma/PhD_2025/Replication_game/data/tmp" 
out_dir <- "D:/Shared Data/homma/PhD_2025/Replication_game/output"

# analysis ----------------------------------------------------------------
# loads dataset
main_data <- read.csv(here(data_dir, "main_data.csv"))


# outcome: ndvi -----------------------------------------------------------

## runs regression model ---------------------------------------------------
model <- feols(
  fml = ndvi ~ trt_overall_road + trt_overall_irrigation + trt_overall_else +
    temperature + precipitation | cell_id + year,
  data = main_data,
  weights = ~ cell_count_30m,
  cluster = ~ commune_id + year
)

summary(model)


## runs sensemakr for sensitivity analysis ---------------------------------
sensitivity <- sensemakr(model = model, 
                         treatment = "trt_overall_irrigation"
                         ) 
sensitivity_cov <- sensemakr(model = model, 
                         treatment = "trt_overall_irrigation",
                         benchmark_covariates = "precipitation",
                         kd = 1:3
) 

sensitivity_cov2 <- sensemakr(model = model, 
                             treatment = "trt_overall_irrigation",
                             benchmark_covariates = "temperature",
                             kd = 1:3
) 

#sensitivity <- sensemakr(model = model, 
#                         treatment = "trt_overall_irrigation",
#                         benchmark_covariates = NULL,
#                         kd = 1:3) # 

# short description of results
sensitivity

# long description of results
summary(sensitivity)


## result plot -------------------------------------------------------------

# plot bias contour of point estimate
plot(sensitivity)
plot(sensitivity, sensitivity.of = "t-value")

plot(sensitivity_cov)

# plot bias contour of t-value: precipitation
png(file=here(out_dir, "sensitivity_ndvi_cov_prec.png"), width = 1200, height = 1200, res = 300)
plot(sensitivity_cov, sensitivity.of = "t-value")
dev.off()

# plot extreme scenario: precipitation
png(file=here(out_dir, "extreme_ndvi_cov_prec.png"), width = 1000, height = 800, res = 200)
plot(sensitivity_cov, type = "extreme")
dev.off()

# plot bias contour of t-value: temperature
png(file=here(out_dir, "sensitivity_ndvi_cov_temp.png"), width = 1200, height = 1200, res = 300)
plot(sensitivity_cov2, sensitivity.of = "t-value")
dev.off()

# plot extreme scenario: temperature
png(file=here(out_dir, "extreme_ndvi_cov_temp.png"), width = 1000, height = 800, res = 200)
plot(sensitivity_cov2, type = "extreme")
dev.off()

# show sensitivity table
tab_html <- ovb_minimal_reporting(sensitivity, format = "pure_html") #
html_print(HTML(tab_html))


# outcome: tree cover -----------------------------------------------------

## runs regression model ---------------------------------------------------
model2 <- feols(
  fml = treecover ~ trt_overall_road + trt_overall_irrigation + trt_overall_else +
    temperature + precipitation | cell_id + year,
  data = main_data,
  weights = ~ cell_count_30m,
  cluster = ~ commune_id + year
)

summary(model2)


## runs sensemakr for sensitivity analysis ---------------------------------

sensitivity2 <- sensemakr(model = model2, 
                         treatment = "trt_overall_irrigation",
                         benchmark_covariates = "precipitation",
                         kd = 1:3) 

sensitivity2_cov2 <- sensemakr(model = model2, 
                          treatment = "trt_overall_irrigation",
                          benchmark_covariates = "temperature",
                          kd = 1:3) 

# short description of results
sensitivity2

# long description of results
summary(sensitivity2)


## result plot -------------------------------------------------------------

# plot bias contour of point estimate: precipitation
plot(sensitivity2)

# plot bias contour of t-value: precipitation
png(file=here(out_dir, "sensitivity_treecover_cov_prec.png"), width = 1200, height = 1200, res = 300)
plot(sensitivity2, sensitivity.of = "t-value")
dev.off()

# plot extreme scenario: precipitation
png(file=here(out_dir, "extreme_treecover_cov_prec.png"), width = 1000, height = 800, res = 200)
plot(sensitivity2, type = "extreme")
dev.off()

# show sensitivity table: precipitation
tab_html2 <- ovb_minimal_reporting(sensitivity2, format = "pure_html") #
html_print(HTML(tab_html2))

# plot bias contour of t-value: temeprature
png(file=here(out_dir, "sensitivity_treecover_cov_temp.png"), width = 1200, height = 1200, res = 300)
plot(sensitivity2_cov2, sensitivity.of = "t-value")
dev.off()

# plot extreme scenario: temeprature
png(file=here(out_dir, "extreme_treecover_cov_temp.png"), width = 1000, height = 800, res = 200)
plot(sensitivity2_cov2, type = "extreme")
dev.off()


