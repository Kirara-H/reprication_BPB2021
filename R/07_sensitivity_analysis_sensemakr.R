

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
data_dir <- "D:/homma/PhD_2025/Replication_game/data/tmp" 
  
# analysis ----------------------------------------------------------------
# loads dataset
main_data <- read.csv(here(data_dir, "main_data.csv"))


# outcome: ndvi -----------------------------------------------------------
# runs regression model
model <- feols(
  fml = ndvi ~ trt_overall_road + trt_overall_irrigation + trt_overall_else +
    temperature + precipitation | cell_id + year,
  data = main_data,
  weights = ~ cell_count_30m,
  cluster = ~ commune_id + year
)

summary(model)

# runs sensemakr for sensitivity analysis
sensitivity <- sensemakr(model = model, 
                         treatment = "trt_overall_irrigation"
                         ) 

#sensitivity <- sensemakr(model = model, 
#                         treatment = "trt_overall_irrigation",
#                         benchmark_covariates = NULL,
#                         kd = 1:3) # 

# short description of results
sensitivity

# long description of results
summary(sensitivity)

# plot bias contour of point estimate
plot(sensitivity)

# show sensitivity table
tab_html <- ovb_minimal_reporting(sensitivity, format = "pure_html") #
html_print(HTML(tab_html))


# outcome: tree cover -----------------------------------------------------
# runs regression model
model2 <- feols(
  fml = treecover ~ trt_overall_road + trt_overall_irrigation + trt_overall_else +
    temperature + precipitation | cell_id + year,
  data = main_data,
  weights = ~ cell_count_30m,
  cluster = ~ commune_id + year
)

summary(model2)

# runs sensemakr for sensitivity analysis
sensitivity2 <- sensemakr(model = model2, 
                         treatment = "trt_overall_irrigation") 

# short description of results
sensitivity2

# long description of results
summary(sensitivity2)

# plot bias contour of point estimate
plot(sensitivity2)

# show sensitivity table
tab_html2 <- ovb_minimal_reporting(sensitivity2, format = "pure_html") #
html_print(HTML(tab_html2))

