
# =========================================================================
#
# Power analysis for Hypothesis H4.1
# project         rsAirflow/Study 1 - respirationAdj1
# author          Lioba Enk (enk@cbs.mpg.de)
# last updated    10 April 2026
#
#
# Reference Formula (hypothesis 4.1): 
# DetectResp ~ Signal * ITIcondition + (1 + Signal | ID)
#
# Description:
# This script performs a simulation-based power analysis for Hypothesis H4.1,
# investigating how rhythmic temporal contexts modulate behavioral detection.
# We utilize a GLMM framework with a probit link to model performance
# within a Signal Detection Theory (SDT) perspective.
#
# Key Features:
# 1. Parameterization: Models rhythmic effects on Sensitivity (d') using
#    sum-coding and Hit Rate shifts via reference-level re-parameterization.
# 2. Empirical Grounding: Estimates for baseline d', criterion, and random-
#    effect variances are informed by Forster et al. (2025).
# 3. Strategy:
#    - Step A: Planned Wald z-test contrasts for specific conditions (N=50).
#    - Step B: Omnibus Likelihood Ratio Tests (LRT) for total rhythmic impact.
#    - Sensitivity Analysis: Power curves simulated for N=50 to N=75.
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


outpath <- "/data/pt_02745/respirationAdj1/code/analysis/poweranalysis/results/"


# -------------------------------------------------------------------------


# inspired by Forster et al. (2025)
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


# -------------------------------------------------------------------------


powersim_nsim = 500
powercurve_nsim = 500 # 500




# -------------------------------------------------------------------------




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



# convert to factors
data_beh_80$ITIcondition <- as.factor(data_beh_80$ITIcondition)
data_beh_80$Signal <- factor(data_beh_80$Signal,
                          levels = c("Present", "Absent"))




# -------------------------------------------------------------------------


sds <- c(emp_sd_intercept,
         emp_sd_signal
         )
V_matrix <- makeVC(sds, correlations)



# Minimal (weak binding) scenario -----------------------------------------



fixed_weak <- c(
  "(Intercept)" = emp_intercept,
  "Signal_numeric" = emp_dprime,
  "ITIconditionRhyF" = 0.1,
  "ITIconditionRhyS" = 0.06,
  "Signal_numeric:ITIconditionRhyF" = 0.16,
  "Signal_numeric:ITIconditionRhyS" = 0.1
)


fixed_weak_factored <- c(
  "(Intercept)" = emp_intercept,
  "SignalAbsent" = emp_dprime,
  "ITIconditionRhyF" = 0.16,   # for our means here (non-sumcoded Signal factor & SignalAbsent as reference), this corresponds to hitrate
  "ITIconditionRhyS" = 0.1,   # for our means here (non-sumcoded Signal factor & SignalAbsent as reference), this corresponds to hitrate
  "SignalAbsent:ITIconditionRhyF" = -0.16, # these will not be analysed*
  "SignalAbsent:ITIconditionRhyS" = -0.1   # these will not be analysed*
)


# * we check the power for the hit rate. To implement our expectation (hit 
#   rate changes, but false alarm rate not really), we negate the effect size
#   (to arrive at a contribution of 0 units).


# -------------------------------------------------------------------------



model_beh_weak_full_factored <- makeGlmer(
  DetectResp ~ Signal * ITIcondition + (1 + Signal | ID), 
  family = binomial(link = "probit"), 
  fixef = fixed_weak_factored,
  VarCorr = V_matrix,
  data = data_beh
)
formula_full_factored <- paste0("DetectResp ~ Signal_factor * ITIcondition + (1 + Signal_factor | ID),",
                                "\nwith reference levels (SignalPresent, ITIconditRanS) to investigate hitrate effects")



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


model_beh_weak_reduced2 <- makeGlmer(
  DetectResp ~ Signal_numeric + (1 + Signal_numeric | ID), 
  family = binomial(link = "probit"), 
  fixef = fixed_weak[1:2], 
  VarCorr = V_matrix,
  data = data_beh
)
formula_reduced2 <- "DetectResp ~ Signal + (1 + Signal | ID),\nwith Signal sum-coded (-0.5,0.5)"




# -------------------------------------------------------------------------


# larger dataset for
# powercurve extending up to N=80


model_beh_weak_full_factored_80 <- makeGlmer(
  DetectResp ~ Signal * ITIcondition + (1 + Signal | ID), 
  family = binomial(link = "probit"), 
  fixef = fixed_weak_factored,
  VarCorr = V_matrix,
  data = data_beh_80
)



model_beh_weak_full_80 <- makeGlmer(
  DetectResp ~ Signal_numeric * ITIcondition + (1 + Signal_numeric | ID), 
  family = binomial(link = "probit"), 
  fixef = fixed_weak, 
  VarCorr = V_matrix,
  data = data_beh_80
)



model_beh_weak_reduced1_80 <- makeGlmer(
  DetectResp ~ Signal_numeric + ITIcondition + (1 + Signal_numeric | ID), 
  family = binomial(link = "probit"), 
  fixef = fixed_weak[1:4], 
  VarCorr = V_matrix,
  data = data_beh_80
)

model_beh_weak_reduced2_80 <- makeGlmer(
  DetectResp ~ Signal_numeric + (1 + Signal_numeric | ID), 
  family = binomial(link = "probit"), 
  fixef = fixed_weak[1:2], 
  VarCorr = V_matrix,
  data = data_beh_80
)


# -------------------------------------------------------------------------



options(lme4.glmerControl = glmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 2e+05)))



# Step A, Planned contrasts (Power simulation, N = 50) --------------------



# (1) Hit rate - run on model with Signal as factor 
#     & SignalPresent set as reference level


# (1.1) RanS vs RhyS


power_h41_behav_contrast_RhyS_hitrate <- powerSim(
  model_beh_weak_full_factored,
  fixed("ITIconditionRhyS", "z"),
  nsim = powersim_nsim
)

saveRDS(power_h41_behav_contrast_RhyS_hitrate, 
        paste0(outpath,"power_h41_detectbehav_contrast_RanS_RhyS_hitrate.rds"))

# (1.2) RanS vs RhyF

# power_h41_behav_contrast_RhyF_hitrate <- powerSim(
#   model_beh_weak_full_factored,
#   fixed("ITIconditionRhyF", "z"),
#   nsim = powersim_nsim
# )
# 
# saveRDS(power_h41_behav_contrast_RhyF_hitrate, 
#         paste0(outpath,"power_h41_detectbehav_contrast_RanS_RhyF_hitrate.rds"))


# (2) Dprime - run on model with Signal as numeric (-0.5,0.5)


# (2.1)  RanS vs RhyS

power_h41_behav_contrast_RhyS_dprime <- powerSim(
  model_beh_weak_full,
  fixed("Signal_numeric:ITIconditionRhyS", "z"),
  nsim = powersim_nsim
)

saveRDS(power_h41_behav_contrast_RhyS_dprime, 
        paste0(outpath,"power_h41_detectbehav_contrast_RanS_RhyS_dprime.rds"))

# (2.2) RanS vs RhyF

power_h41_behav_contrast_RhyF_dprime <- powerSim(
  model_beh_weak_full,
  fixed("Signal_numeric:ITIconditionRhyF", "z"),
  nsim = powersim_nsim
)

saveRDS(power_h41_behav_contrast_RhyF_dprime, 
        paste0(outpath,"power_h41_detectbehav_contrast_RanS_RhyF_dprime.rds"))



# (3) Criterion - run on model with Signal as numeric (-0.5,0.5)

# (3.2) RanS vs RhyF

power_h41_behav_contrast_RhyF_criterion <- powerSim(
  model_beh_weak_full,
  fixed("ITIconditionRhyF", "z"),
  nsim = powersim_nsim
)

saveRDS(power_h41_behav_contrast_RhyF_criterion, 
        paste0(outpath,"power_h41_detectbehav_contrast_RanS_RhyF_criterion.rds"))




#  Step A, Power curves for contrasts (N: 50 to 80) -----------------------


# (2.1)

pc_h41_behav_contrast_RhyS_dprime <- powerCurve(
  model_beh_weak_full_80, 
  along = "ID", 
  breaks = c(50, 55, 60, 65, 70, 75, 80),
  fixed("Signal_numeric:ITIconditionRhyS", "z"),
  nsim = powercurve_nsim
)

saveRDS(pc_h41_behav_contrast_RhyS_dprime, 
        paste0(outpath,"pc_h41_detectbehav_contrast_RanS_RhyS_dprime.rds"))



# Step B, omnibus testing (relevance of ITIcondition) ---------------------



# (1)

power_interaction_lrt <- powerSim(
  model_beh_weak_full,
  compare(model_beh_weak_reduced2, "lr"),
  nsim = powersim_nsim
)

saveRDS(power_interaction_lrt, 
        paste0(outpath,"power_lrt_h41_detectbehav_full_null.rds"))


# (2)


power_interaction_lrt <- powerSim(
  model_beh_weak_full,
  compare(model_beh_weak_reduced1, "lr"),
  nsim = powersim_nsim
)

saveRDS(power_interaction_lrt, 
        paste0(outpath,"power_lrt_h41_detectbehav_full_main.rds"))


pc_interaction_lrt <- powerCurve(
  model_beh_weak_full_80,
  along = "ID",
  breaks = c(50, 55, 60, 65, 70, 75, 80),
  compare(model_beh_weak_reduced1_80, "lr"),
  nsim = powercurve_nsim
)

saveRDS(pc_interaction_lrt, 
        paste0(outpath,"pc_lrt_h41_detectbehav_full_main.rds"))




###########################################################################







