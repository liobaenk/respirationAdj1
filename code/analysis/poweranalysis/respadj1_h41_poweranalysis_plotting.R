

# =========================================================================
#
# Power analysis for Hypothesis H4.1
# project         rsAirflow/Study 1 - respirationAdj1
# author          Lioba Enk (enk@cbs.mpg.de)
# last updated    22 April 2026
#
#
# Reference Formula (hypothesis 4.1): 
# DetectResp ~ Signal * ITIcondition + (1 + Signal | ID)
#
# Description:
# plotting
#
# =========================================================================


rm(list = ls())


# -------------------------------------------------------------------------



packageVersion("lme4")
packageVersion("simr")


library(lme4)
library(simr)

library(ggplot2)

# -------------------------------------------------------------------------


# path <- "/data/pt_02745/respirationAdj1/code/analysis/poweranalysis/results/hypo41/mde"
path <- "/data/pt_02745/respirationAdj1/code/analysis/poweranalysis/results/hypo41"


# -------------------------------------------------------------------------


th_settings = theme(axis.ticks.x = element_blank(),
                    axis.title.x = element_text(size = rel(1.8)),
                    axis.text.x = element_text(size = rel(1.8)),
                    axis.title.y = element_text(size = rel(1.8)),
                    axis.text.y = element_text(size = rel(1.8)),
                    legend.title = element_text(size = rel(1.8)),
                    legend.text = element_text(size = rel(1.8)),
                    legend.position = "bottom",
                    plot.title = element_text(size=rel(1.8)),
                    plot.caption = element_text(vjust = 2, size = rel(1.2)),
                    strip.background = element_rect(fill="white", linewidth =0),
                    strip.text = element_text(size=rel(1.8), color="black"),
                    panel.grid.major.x = element_blank(),
                    panel.grid.minor.x = element_blank(),
                    panel.border = element_rect(color = "darkgrey", fill = NA, linewidth = 1)
)



extract_pc_data <- function(pc) {
  dat <- summary(pc)
  # dat columns: nlevels, successes, trials, mean, lower, upper
  return(dat)
}



get_sim_stats <- function(sim_object) {
  s <- summary(sim_object)
  conf <- confint(sim_object)
  data.frame(
    Power = s$mean,
    Lower_CI = conf[1],
    Upper_CI = conf[2],
    N_Sims = s$trials
  )
}



# -------------------------------------------------------------------------



# model_beh_weak_full_factored <- makeGlmer(
#   DetectResp ~ Signal * ITIcondition + (1 + Signal | ID), 
#   family = binomial(link = "probit"), 
#   fixef = fixed_weak_factored,
#   VarCorr = V_matrix,
#   data = data_beh
# )
# formula_full_factored <- paste0("DetectResp ~ Signal_factor * ITIcondition + (1 + Signal_factor | ID),",
#                                 "\nwith reference levels (SignalPresent, ITIconditRanS) to investigate hitrate effects")
# 
# 
# 
# model_beh_weak_full <- makeGlmer(
#   DetectResp ~ Signal_numeric * ITIcondition + (1 + Signal_numeric | ID), 
#   family = binomial(link = "probit"), 
#   fixef = fixed_weak,
#   VarCorr = V_matrix,
#   data = data_beh
# )
formula_full <- "DetectResp ~ Signal * ITIcondition + (1 + Signal | ID),\nwith Signal sum-coded (-0.5,0.5)"
# 
# 
# model_beh_weak_reduced1 <- makeGlmer(
#   DetectResp ~ Signal_numeric + ITIcondition + (1 + Signal_numeric | ID), 
#   family = binomial(link = "probit"), 
#   fixef = fixed_weak[1:4], 
#   VarCorr = V_matrix,
#   data = data_beh
# )
# formula_reduced1 <- "DetectResp ~ Signal + ITIcondition + (1 + Signal | ID),\nwith Signal sum-coded (-0.5,0.5)"
# 
# 
# model_beh_weak_reduced2 <- makeGlmer(
#   DetectResp ~ Signal_numeric + (1 + Signal_numeric | ID), 
#   family = binomial(link = "probit"), 
#   fixef = fixed_weak[1:2], 
#   VarCorr = V_matrix,
#   data = data_beh
# )
# formula_reduced2 <- "DetectResp ~ Signal + (1 + Signal | ID),\nwith Signal sum-coded (-0.5,0.5)"



# -------------------------------------------------------------------------


# re-run (now that set.seed was used!)

results <- readRDS(file.path(path,"power_h41_detectbehav_contrast_RanS_RhyF_criterion.rds"))
results
results$description
stats <- get_sim_stats(results)
print(stats)

results <- readRDS(file.path(path,"power_h41_detectbehav_contrast_RanS_RhyF_dprime.rds"))
results
results$description
stats <- get_sim_stats(results)
print(stats)

results <- readRDS(file.path(path,"power_h41_detectbehav_contrast_RanS_RhyS_dprime.rds"))
results
results$description
stats <- get_sim_stats(results)
print(stats)

results <- readRDS(file.path(path,"power_h41_detectbehav_contrast_RanS_RhyS_hitrate.rds"))
results
results$description
stats <- get_sim_stats(results)
print(stats)


# power curves

pc_results <- readRDS(file.path(path,"pc_h41_detectbehav_contrast_RanS_RhyS_dprime.rds"))
pc_results


# -------------------------------------------------------------------------


# MDEs


results <- readRDS(file.path(path,"power_h41_detectbehav_contrast_RanS_RhyS_dprime_6.rds"))
results
stats <- get_sim_stats(results)
print(stats)

fixef(results)



# -------------------------------------------------------------------------




formula_name <- formula_full



pc_results <- readRDS(file.path(path,"pc_h41_detectbehav_contrast_RanS_RhyS_dprime_2.rds"))
pc_results
filename <- "powercurve_h41_detectbehav_contrast_RanS_RhyS_dprime_2.svg"
titlename <- paste0("H4.1: Sensitivity analysis for (RanS vs ",
                    "RhyS) --> dprime (v2)")


# CONTINUE FROM HERE!

# pc_results <- readRDS(file.path(path,"pc_h41_detectbehav_contrast_RanS_RhyF_criterion.rds"))
# filename <- "powercurve_h41_detectbehav_contrast_RanS_RhyF_criterion.svg"
# titlename <- paste0("H4.1: Sensitivity analysis for contrast (RanS vs ",
#                     "RhyF) --> criterion")


pc_data <- extract_pc_data(pc_results)
p <- ggplot(pc_data, aes(x=nlevels, y=mean)) +
  
  geom_hline(yintercept=0.80, linetype="dashed", color="red") +
  
  scale_y_continuous(limits = c(0,1), breaks = c(seq(0,1,0.1)))+
  scale_x_continuous(limits = c(49,81), breaks = c(seq(50,80,5)))+
  geom_line(size=1, color="steelblue") +
  geom_errorbar(aes(ymin=lower, ymax=upper), width=2) +
  geom_point(size=3, color="steelblue") +
  
  labs(title = titlename,
       subtitle = paste0(formula_name,", ", results$description[2]),
       x="Sample size",
       y="Power (1 - Beta)") +
  theme_minimal() +
  th_settings +
  theme(axis.title.x = element_text(size = rel(1.75)),
        axis.title.y = element_text(size = rel(1.8))
  )

p

ggsave(
  filename = file.path(path, filename), 
  plot = p, 
  device = "svg", 
  width = 9, 
  height = 8, 
  units = "in"
)



#  -----------------------------------------------------------------------


power_lrt1 <- readRDS(file.path(path,"power_lrt_h41_detectbehav_full_null.rds"))
power_lrt1
filename <- "pc_lrt_h41_detectbehav_full_main.svg"
subtitlename <- paste0("Full interaction model vs ",
                       "Main rhythm model")

power_lrt1 <- readRDS(file.path(path,"power_lrt_h41_detectbehav_full_main.rds"))
power_lrt1
filename <- "pc_lrt_h41_detectbehav_full_main.svg"
subtitlename <- paste0("Full interaction model vs ",
                       "Main rhythm model")



pc_interaction_lrt <- readRDS(file.path(path,"pc_lrt_h41_detectbehav_full_main_3.rds"))
pc_interaction_lrt
filename <- "pc_lrt_h41_detectbehav_full_main.svg"
subtitlename <- paste0("Full interaction model vs ",
                       "Main rhythm model")



lrt_summary <- summary(pc_interaction_lrt)
plot_data_lrt <- data.frame(
  N = lrt_summary$nlevels,
  Power = lrt_summary$mean,
  Lower = lrt_summary$lower,
  Upper = lrt_summary$upper
)


p_lrt <- ggplot(plot_data_lrt, aes(x = N, y = Power)) +
  
  geom_hline(yintercept=0.80, linetype="dashed", color="red") +
  
  geom_line(color = "#008744", size = 1) +
  geom_point(color = "#008744", size = 3) +
  geom_errorbar(aes(ymin=Lower, ymax=Upper), width=2) +
  
  scale_y_continuous(limits = c(0,1), breaks = c(seq(0,1,0.1)))+
  scale_x_continuous(limits = c(49,81), breaks = c(seq(50,80,5)))+
  labs(
    title = "H4.1: Omnibus power (Likelihood Ratio Test)",
    subtitle = subtitlename,
    x = "Sample size",
    y = "Power (1 - Beta)"
  ) +
  theme_minimal() +
  th_settings +
  theme(axis.title.x = element_text(size = rel(1.8)),
        axis.title.y = element_text(size = rel(1.8))
  )



p_lrt



ggsave(
  filename = file.path(path, filename), 
  plot = p_lrt, 
  device = "svg", 
  width = 9, 
  height = 8, 
  units = "in"
)





###############################################################################
