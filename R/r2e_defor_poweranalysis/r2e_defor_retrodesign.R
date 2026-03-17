############################################################
## Title: Retrospective power curve and exaggeration ratio using retrodesign
## Project: R2E Defor (RWI & I4R)
## Author: Martin Buchner 
##
## User inputs:
## - All user-specified inputs (outcomes, estimates, and
##   plotting options) are defined in the section
##   "---- User inputs ----" below.
##
## Approach:
## - Gelman & Carlin (2014) retrospective design analysis
## - Closed-form implementation following Lu, Qiu & Deng (2019)
## - Implemented via the retrodesign R package (Timm et al. 2025)
##
## What it does:
## 1) Varies assumed TRUE effect size as a percentage of the observed estimate
## 2) Computes statistical power and exaggeration ratios (Type M)
##    under normal approximation (based on the retrodesign framework)
## 3) Visualizes power and exaggeration curves by outcome
## 4) Assesses whether power reaches 80% at half of the observed estimate
##
## Outputs:
## - Power curves and exaggeration (Type M) curves by outcome
## - Summary of power at 50% of observed estimate by outcome
############################################################


## Clear environment 
rm(list = ls())


## ---- User inputs -----------------------------------------------------------

## >>> EDIT THIS SECTION ONLY <<<
## Replace the example values in outcome, obs_est, and se_est below with your own.

specs <- data.frame(
  outcome = c("Outcome 1", "Outcome 2", "Outcome 3", "Outcome 4"),
  # One label per outcome/specification. E.g., if there is only one outcome,
  # include a single label. The number of labels must match obs_est and se_est.
  # The i-th element corresponds to the i-th elements of obs_est and se_est.
  
  obs_est = c(-0.0002174, 0.0025194, 0.0005718, 0.0084448),
  # Observed estimates (one per outcome), e.g. regression coefficients.
  # The order must match `outcome`.
  
  se_est  = c(0.0002182, 0.0011071, 0.0005722, 0.0020093)
  # Standard errors corresponding to obs_es.
  # The order must match `outcome`.
)


alpha <- 0.05 # significance level (two-sided)

## Optional: save figure
save_plot <- TRUE
plot_file_combined <- "retro_curve.png"





## ---- Packages --------------------------------------------------------------

# retrodesign
if (!requireNamespace("retrodesign", quietly = TRUE)) {
  install.packages("retrodesign")
}
library(retrodesign) # Preferred Version: 0.2.2

# ggplot2
if (!requireNamespace("ggplot2", quietly = TRUE)) {
  install.packages("ggplot2")
}
library(ggplot2) # Preferred Version: 4.0.1

# patchwork
if (!requireNamespace("patchwork", quietly = TRUE)) {
  install.packages("patchwork")
}
library(patchwork) # Preferred Version: 1.3.2

# ggrepel
if (!requireNamespace("ggrepel", quietly = TRUE)) {
  install.packages("ggrepel")
}
library(ggrepel) # Preferred Version: 0.9.6




## ---- Core computation: power ------------------------------------------------------

## Grid of assumed TRUE effects as % of observed estimate
pct_grid <- seq(1, 100, by = 1)


# Build a long results data.frame: outcome x pct_grid
results <- do.call(rbind, lapply(seq_len(nrow(specs)), function(i) {
  outcome_i <- specs$outcome[i]
  obs_i <- specs$obs_est[i]
  se_i  <- specs$se_est[i]
  
  true_eff_grid <- (pct_grid / 100) * obs_i
  
  power_grid <- vapply(
    true_eff_grid,
    function(A) retro_design_closed_form(A = A, s = se_i, alpha = alpha)$power,
    numeric(1)
  )
  
  type_m_grid <- vapply(
    true_eff_grid,
    function(A) retro_design_closed_form(A = A, s = se_i, alpha = alpha)$type_m,
    numeric(1)
  )
  
  data.frame(
    outcome = outcome_i,
    pct_of_observed = pct_grid,
    assumed_true_effect = true_eff_grid,
    power = power_grid,
    type_m = type_m_grid
  )
}))
results$outcome <- factor(results$outcome, levels = specs$outcome)



## ---- Generate figures ------------------------------------------------------

## 1.) Statistical Power


p50 <- subset(results, pct_of_observed == 50)

# label in percent units (0–100) with no % on axis, but % in the annotation
p50$label <- sprintf("%.1f%%", 100 * p50$power)


p_power <- ggplot(results, aes(x = pct_of_observed, y = power, linetype = outcome)) +
  geom_line(linewidth = 0.7) +
  geom_hline(yintercept = 0.80, linetype = "dashed") +
  
  # dots at 50%
  geom_point(
    data = p50,
    aes(x = pct_of_observed, y = power),
    size = 2
  ) +
  
  # repelled labels
  ggrepel::geom_text_repel(
    data = p50,
    aes(x = pct_of_observed, y = power, label = label),
    direction = "y",        
    nudge_x = 2,            
    hjust = 0,
    vjust = 2,
    size = 3,
    segment.size = 0.3,     
    segment.alpha = 0.6,
    min.segment.length = 0,
    box.padding = 0.25,
    point.padding = 0.15,
    seed = 123              
  ) +
  
  scale_x_continuous(labels = function(x) paste0(x, "%")) +
  scale_y_continuous(
    limits = c(0, 1),
    breaks = seq(0, 1, by = 0.2),
    labels = function(x) x * 100
  ) +
  labs(
    title = "Statistical Power",
    y = "Statistical power (%)",
    x = NULL,
    linetype = NULL
  ) +
  theme_minimal()

p_power


## 2.) Exaggeration Ratio 

# Exaggeration plot
p_exag <- ggplot(results, aes(x = pct_of_observed, y = type_m, linetype = outcome)) +
  geom_line(linewidth = 0.7) +
  scale_x_continuous(labels = function(x) paste0(x, "%")) +
  scale_y_continuous(breaks = seq(1, 10, by = 0.5)) +
  coord_cartesian(ylim = c(1, 4)) +
  labs(
    title = "Exaggeration Ratio",
    y = "Exaggeration ratio (Type M)",
    x = "Assumed true effect size (% of observed estimate)",
    linetype = NULL
  ) +
  theme_minimal()

p_exag


## 3.) Combined Figure

p_power_pw <- p_power +
  labs(x = NULL)
p_exag_pw <- p_exag

caption_txt <- paste(
  strwrap(
    "Notes: Statistical power and exaggeration ratio (Type M) are computed using the closed-form retrospective design of Gelman and Carlin (2014) as implemented in the retrodesign package. The x-axis reports assumed true effect sizes as percentages of the observed estimate. For visual clarity, the y-axis in the exaggeration panel is truncated at an exaggeration ratio of 4.0.",
    width = 190
  ),
  collapse = "\n"
)

p_combined <- (
  (p_power_pw + p_exag_pw) +
    plot_layout(ncol = 2, guides = "collect") +
    plot_annotation(caption = caption_txt)
) &
  theme(
    legend.position = "bottom",
    legend.key.width = unit(1.4, "cm"),
    plot.caption.position = "plot",
    plot.caption = element_text(
      hjust = 0,                          
      size = 8
    ),
    axis.title.x = element_text(hjust = 1)
  )

p_combined


# Save figure 
if (save_plot) {
  ggsave(
    filename = plot_file_combined,
    plot = p_combined,
    width = 10,
    height = 6,
    dpi = 600
  )
  message(sprintf("Saved plot to: %s", plot_file_combined))
} else {
  print(p_combined)
}




## ---- Power at true effect half the observed estimate ------------------------------------------------
p50 <- subset(results, pct_of_observed == 50)

cat("\nPower at 50% of observed estimate (by outcome):\n")

for (o in unique(p50$outcome)) {
  row <- p50[p50$outcome == o, ][1, ]
  
  half_eff_o <- 0.5 * specs$obs_est[match(o, specs$outcome)]
  
  meets_80_o <- row$power >= 0.80
  
  cat(sprintf("\n%s:\n", as.character(o)))
  cat(sprintf("  assumed true effect (50%%) = %g\n", half_eff_o))
  cat(sprintf("  power = %.4f\n", row$power))
  cat(sprintf("  meets 80%% threshold? %s\n", ifelse(meets_80_o, "YES", "NO")))
}