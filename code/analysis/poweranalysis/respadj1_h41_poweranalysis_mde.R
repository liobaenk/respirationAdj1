
# =========================================================================
#
# Power analysis for Hypothesis H4.1
# project         rsAirflow/Study 1 - respirationAdj1
# author          Lioba Enk (enk@cbs.mpg.de)
# last updated    07 May 2026
#
#
# Reference Formula (hypothesis 4.1): 
# DetectResp ~ Signal * ITIcondition + (1 + Signal | ID)
#
# Description:
# This script performs a simulation-based power analysis for Hypothesis H4.1,
# investigating minimal detectable effect (MDE) sizes for edge cases
# specifically for:
# - LRT comparing full to main-factor model [1,2]
# - Dprime: smallest effects / minimum sample size [3,4]
#
# Key Features:
# 1. Parameterization: Models rhythmic effects on Sensitivity (d') using sum-coding
# 2. Empirical Grounding: Estimates for baseline d', criterion, and random-
#    effect variances are informed by Forster et al. (2025).
#
# set.seed(341234) was used
#
# =========================================================================



rm(list = ls())


# -------------------------------------------------------------------------


set.seed(341234)


# -------------------------------------------------------------------------



packageVersion("lme4")
packageVersion("simr")


library(lme4)
library(simr)
library(ggplot2)


# -------------------------------------------------------------------------



outpath <- "/data/pt_02745/respirationAdj1/code/analysis/poweranalysis/results/h41/mde/"



# settings ----------------------------------------------------------------



# informed by Forster et al. (2025)
emp_intercept <- -0.65  
emp_dprime    <- 1.65
emp_sd_intercept <- 0.3
emp_sd_signal <- 0.5 


correlations <- 0.2


n_subj <- 50
conds <- c("RanS", "RhyS", "RhyF")
total_trials_per_cond <- 320
n_present <- total_trials_per_cond * 0.75 # 240 trials
n_absent <- total_trials_per_cond * 0.25  # 80 trials


# for powercurve up to N=80
n_subj_pc <- 80



# monte carlo simulations -------------------------------------------------



powersim_nsim = 500
powercurve_nsim = 500



# func --------------------------------------------------------------------




makeVC <- function(sd, rho) {
  n <- length(sd)
  R <- matrix(rho, n, n)
  diag(R) <- 1
  V <- diag(sd) %*% R %*% diag(sd)
  return(V)
}

get_sim_stats <- function(sim_object) {
  # extract the summary with power estimates
  s <- summary(sim_object)
  # extract confidence intervals
  conf <- confint(sim_object)
  data.frame(
    Power = s$mean,      # actual power (proportion of successes)
    Lower_CI = conf[1],
    Upper_CI = conf[2],
    N_Sims = s$trials    # total number of simulations run
  )
}

extract_pc_data <- function(pc) {
  dat <- summary(pc)
  # dat usually has columns: nlevels, successes, trials, mean, lower, upper
  return(dat)
}



# create dataset ----------------------------------------------------------


one_subj_data <- data.frame(
  ITIcondition = rep(conds, each = total_trials_per_cond),
  Signal = rep(rep(c("Present", "Absent"), c(n_present, n_absent)), times = 3)
)

# replicate for all 50 participants
data_beh <- do.call(rbind, lapply(1:n_subj, function(i) {
  df <- one_subj_data
  df$ID <- factor(i)
  return(df)
}))

rm(one_subj_data)



# add Signal predictor as numeric
data_beh$Signal_numeric <- ifelse(data_beh$Signal == "Present", 0.5, -0.5)



# convert to factors
data_beh$ITIcondition <- as.factor(data_beh$ITIcondition)
data_beh$Signal <- factor(data_beh$Signal,
                          levels = c("Present", "Absent"))



# larger dataset for
# powercurve extending up to N=80


one_subj_data <- data.frame(
  ITIcondition = rep(conds, each = total_trials_per_cond),
  Signal = rep(rep(c("Present", "Absent"), c(n_present, n_absent)), times = 3)
)

# replicate for all 50 participants
data_beh_80 <- do.call(rbind, lapply(1:n_subj_pc, function(i) {
  df <- one_subj_data
  df$ID <- factor(i)
  return(df)
}))

rm(one_subj_data)



# add Signal predictor as numeric
data_beh_80$Signal_numeric <- ifelse(data_beh_80$Signal == "Present", 0.5, -0.5)



# -------------------------------------------------------------------------




sds <- c(emp_sd_intercept,
         emp_sd_signal
)
V_matrix <- makeVC(sds, correlations)




# [1] LRT (full vs main-factor): power curve with original beta -----------



set.seed(341234)


fixed_weak <- c(
  "(Intercept)" = emp_intercept,
  "Signal_numeric" = emp_dprime,
  "ITIconditionRhyF" = 0.1,
  "ITIconditionRhyS" = 0.06,
  "Signal_numeric:ITIconditionRhyF" = 0.16,
  "Signal_numeric:ITIconditionRhyS" = 0.1
)


model_beh_weak_full_80 <- makeGlmer(
  DetectResp ~ Signal_numeric * ITIcondition + (1 + Signal_numeric | ID), 
  family = binomial(link = "probit"), 
  fixef = fixed_weak, 
  VarCorr = V_matrix,
  data = data_beh_80
)
formula_full <- "DetectResp ~ Signal * ITIcondition + (1 + Signal | ID),\nwith Signal sum-coded (-0.5,0.5)"


model_beh_weak_reduced1_80 <- makeGlmer(
  DetectResp ~ Signal_numeric + ITIcondition + (1 + Signal_numeric | ID), 
  family = binomial(link = "probit"), 
  fixef = fixed_weak[1:4], 
  VarCorr = V_matrix,
  data = data_beh_80
)
formula_reduced1 <- "DetectResp ~ Signal + ITIcondition + (1 + Signal | ID),\nwith Signal sum-coded (-0.5,0.5)"




options(lme4.glmerControl = glmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 2e+05)))




pc_interaction_lrt <- powerCurve(
  model_beh_weak_full_80,
  along = "ID",
  breaks = c(50, 55, 60, 65), # 70, 75, 80
  compare(model_beh_weak_reduced1_80, "lr"),
  nsim = powercurve_nsim
)

saveRDS(pc_interaction_lrt, 
        paste0(outpath,"pc_lrt_h41_detectbehav_full_main_mde_016.rds"))






# [2] LRT (full vs main-factor): mde --------------------------------------





set.seed(341234)


fixed_weak <- c(
  "(Intercept)" = emp_intercept,
  "Signal_numeric" = emp_dprime,
  "ITIconditionRhyF" = 0.1,
  "ITIconditionRhyS" = 0.06,
  "Signal_numeric:ITIconditionRhyF" = 0.17, # VERSION 3 (LE, 28.04.2026), previously: 0.16
  "Signal_numeric:ITIconditionRhyS" = 0.1
)

model_beh_weak_full <- makeGlmer(
  DetectResp ~ Signal_numeric * ITIcondition + (1 + Signal_numeric | ID), 
  family = binomial(link = "probit"), 
  fixef = fixed_weak,
  VarCorr = V_matrix,
  data = data_beh
)
formula_full <- "DetectResp ~ Signal * ITIcondition + (1 + Signal | ID),\nwith Signal sum-coded (-0.5,0.5)"


model_beh_weak_reduced1 <- makeGlmer(
  DetectResp ~ Signal_numeric + ITIcondition + (1 + Signal_numeric | ID), 
  family = binomial(link = "probit"), 
  fixef = fixed_weak[1:4], 
  VarCorr = V_matrix,
  data = data_beh
)
formula_reduced1 <- "DetectResp ~ Signal + ITIcondition + (1 + Signal | ID),\nwith Signal sum-coded (-0.5,0.5)"



options(lme4.glmerControl = glmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 2e+05)))



power_interaction_lrt <- powerSim(
  model_beh_weak_full,
  compare(model_beh_weak_reduced1, "lr"),
  nsim = powersim_nsim
)

saveRDS(power_interaction_lrt, 
        paste0(outpath,"power_lrt_h41_detectbehav_full_main_mde_017.rds"))






# [3] Dprime effect (for less strong condition): MDE ----------------------



# (Version 6)

# Dprime - run on model with Signal as numeric (-0.5,0.5)



set.seed(341234)



fixed_weak <- c(
  "(Intercept)" = emp_intercept,
  "Signal_numeric" = emp_dprime,
  "ITIconditionRhyF" = 0.1,
  "ITIconditionRhyS" = 0.06,
  "Signal_numeric:ITIconditionRhyF" = 0.18,
  "Signal_numeric:ITIconditionRhyS" = 0.15 # (LE, 07.05.2026), here to show MDE for N=50
)



model_beh_weak_full <- makeGlmer(
  DetectResp ~ Signal_numeric * ITIcondition + (1 + Signal_numeric | ID), 
  family = binomial(link = "probit"), 
  fixef = fixed_weak,
  VarCorr = V_matrix,
  data = data_beh
)
formula_full <- "DetectResp ~ Signal * ITIcondition + (1 + Signal | ID),\nwith Signal sum-coded (-0.5,0.5)"



options(lme4.glmerControl = glmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 2e+05)))



power_h41_behav_contrast_RhyS_dprime <- powerSim(
  model_beh_weak_full,
  fixed("Signal_numeric:ITIconditionRhyS", "z"),
  nsim = powersim_nsim
)
power_h41_behav_contrast_RhyS_dprime
get_sim_stats(power_h41_behav_contrast_RhyS_dprime)



saveRDS(power_h41_behav_contrast_RhyS_dprime,
        paste0(outpath,"power_h41_detectbehav_contrast_RanS_RhyS_dprime_mde_015.rds")) # version 6






# [4] Dprime effect (for less strong condition): power curve for o --------
# original beta



# Dprime - run on model with Signal as numeric (-0.5,0.5)



set.seed(341234)


# default
fixed_weak <- c(
  "(Intercept)" = emp_intercept,
  "Signal_numeric" = emp_dprime,
  "ITIconditionRhyF" = 0.1,
  "ITIconditionRhyS" = 0.06,
  "Signal_numeric:ITIconditionRhyF" = 0.18,
  "Signal_numeric:ITIconditionRhyS" = 0.14 # (LE, 07.05.2026), here to find sample size for 0.14
)




model_beh_weak_full_80 <- makeGlmer(
  DetectResp ~ Signal_numeric * ITIcondition + (1 + Signal_numeric | ID), 
  family = binomial(link = "probit"), 
  fixef = fixed_weak, 
  VarCorr = V_matrix,
  data = data_beh_80
)
formula_full <- "DetectResp ~ Signal * ITIcondition + (1 + Signal | ID),\nwith Signal sum-coded (-0.5,0.5)"



options(lme4.glmerControl = glmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 2e+05)))




pc_h41_behav_contrast_RhyS_dprime <- powerCurve(
  model_beh_weak_full_80, 
  along = "ID", 
  breaks = c(50, 55, 60, 65, 70, 75, 80),
  fixed("Signal_numeric:ITIconditionRhyS", "z"),
  nsim = powercurve_nsim
)


pc_results <- get_sim_stats(pc_h41_behav_contrast_RhyS_dprime)
pc_results


saveRDS(pc_h41_behav_contrast_RhyS_dprime, 
        paste0(outpath,"pc_h41_detectbehav_contrast_RanS_RhyS_dprime_mde_014.rds"))




###########################################################################





