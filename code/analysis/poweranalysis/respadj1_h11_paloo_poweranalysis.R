

# =========================================================================
#
# Power analysis for Hypothesis H1.1 - trial level (not PLI on condition level)
# project         rsAirflow/Study 1 - respirationAdj1
# author          Lioba Enk (enk@cbs.mpg.de)
# last updated    27 April 2026
#
#
# Reference Formula (hypothesis 1.1 - trial level):
# Phase Deviation from Target Onset ^1 ~ ITIcondition + (1 + ITIcondition | ID)
#
# ^1 : PA LOO (Phase Alignment Leave-One-Out) = linear alternative to the 
# Phase Locking Index (PLI) for use in Linear Mixed-Effects Models (LMMs), i.e.
# on trial-level. 
# - has random baseline at 0: By excluding the current trial from the calculation
# of the mean (Leave-One-Out), it prevents "double-dipping". In a perfectly
# random distribution, the expected value of PA LOO is exactly 0.
# - Linearized Scale: It transforms circular data (0–360°) into a linear continuum 
# ranging from -1 to 1.
#   1: The trial is perfectly aligned with the ID's mean phase.
#   0: The trial is perpendicular (random) to the preferred phase.
#  -1: The trial is perfectly opposite to the mean phase.
# Formula:
# PAi = cos(ϕi − mean_ϕ(−i)), with i = trial
# ϕi = phase of the current trial
# mean_ϕ(−i) = circular mean phase of all other trials
# calculated by taking the cosine of the difference between that trial’s 
# respiratory phase in trial i and the average (circular mean) phase of all 
# the other trials within that same experimental condition.
#
# set.seed(924) was used
#
#
# =========================================================================



rm(list = ls())


# -------------------------------------------------------------------------


packageVersion("lme4")
packageVersion("simr")


library(lme4)
library(simr)


# -------------------------------------------------------------------------


outpath <- "/data/pt_02745/respirationAdj1/code/analysis/poweranalysis/results/hypo1/"


# -------------------------------------------------------------------------



n_subj <- 50
conds <- c("RanS", "RhyS", "RhyF")
total_trials_per_cond <- 320
n_present <- total_trials_per_cond * 0.75 # 240 trials
n_absent <- total_trials_per_cond * 0.25  # 80 trials


# for powercurve up to N=80
n_subj_pc <- 80




# -------------------------------------------------------------------------


powersim_nsim =  500
powercurve_nsim = 500


# -------------------------------------------------------------------------


makeVC <- function(sd, rho) {
  n <- length(sd)
  R <- matrix(rho, n, n)
  diag(R) <- 1
  V <- diag(sd) %*% R %*% diag(sd)
  return(V)
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
data_paloo <- do.call(rbind, lapply(1:n_subj, function(i) {
  df <- one_subj_data
  df$ID <- factor(i)
  return(df)
}))

rm(one_subj_data)




# larger dataset for
# powercurve extending up to N=80


one_subj_data <- data.frame(
  ITIcondition = rep(conds, each = total_trials_per_cond),
  Signal = rep(rep(c("Present", "Absent"), c(n_present, n_absent)), times = 3)
)

# replicate for all 50 participants
data_paloo_80 <- do.call(rbind, lapply(1:n_subj_pc, function(i) {
  df <- one_subj_data
  df$ID <- factor(i)
  return(df)
}))

rm(one_subj_data)



data_paloo$ITIcondition <- factor(data_paloo$ITIcondition, levels = c("RanS", "RhyS", "RhyF"))
data_paloo_80$ITIcondition <- factor(data_paloo_80$ITIcondition, levels = c("RanS", "RhyS", "RhyF"))


# -------------------------------------------------------------------------


correlations = 0.2
sds_between <- c(0.1, 0.1, 0.1) 

V_matrix <- makeVC(sds_between, correlations)
res_var <- 0.707


fixed_weak <- c(
  "(Intercept)" = 0, # RanS perfectly random
  "ITIconditionRhyS" = 0.06,
  "ITIconditionRhyF" = 0.1
)


# -------------------------------------------------------------------------


model_paloo <- makeLmer(
  PA_LOO ~ ITIcondition + (1 + ITIcondition | ID),
  fixef = fixed_weak,
  VarCorr = V_matrix,
  sigma = res_var,
  data = data_paloo
)

formula_full <- paste0("H1.1, trial level: PA_LOO ~ ITIcondition + (1 + ITIcondition | ID)")



# larger dataset for
# powercurve extending up to N=80


model_paloo_80 <- makeLmer(
  PA_LOO ~ ITIcondition + (1 + ITIcondition | ID),
  fixef = fixed_weak,
  VarCorr = V_matrix,
  sigma = res_var,
  data = data_paloo_80
)



# Planned contrasts (Power simulation, N = 50) --------------------


options(lme4.lmerControl = lmerControl(optimizer = "bobyqa", 
                                       optCtrl = list(maxfun = 2e+05)))

set.seed(924)


# (1.1) Contrast RanS vs RhyF
power_h11_paloo_RhyF <- powerSim(model_paloo, 
                           test = fixed("ITIconditionRhyF", "z"), 
                           nsim = powersim_nsim
                           )

saveRDS(power_h11_paloo_RhyF,
        paste0(outpath,"power_h11_paloo_contrast_RanS_RhyF.rds"))



# (1.2) Contrast RanS vs RhyS
power_h11_paloo_RhyS <- powerSim(model_paloo, 
                           test = fixed("ITIconditionRhyS", "z"), 
                           nsim = powersim_nsim
                           )

saveRDS(power_h11_paloo_RhyS,
        paste0(outpath,"power_h11_paloo_contrast_RanS_RhyS.rds"))




# TEST SCENARIO 1 ---------------------------------------------------------


# weaker phase alignment effects: c(0.1,0.06) --> c(0.05,0.03)

fixed_weak <- c(
  "(Intercept)" = 0, 
  "ITIconditionRhyS" = 0.03,
  "ITIconditionRhyF" = 0.05
)


model_paloo <- makeLmer(
  PA_LOO ~ ITIcondition + (1 + ITIcondition | ID),
  fixef = fixed_weak,
  VarCorr = V_matrix,
  sigma = res_var,
  data = data_paloo
)
formula_full <- paste0("H1.1, trial level: PA_LOO ~ ITIcondition + (1 + ITIcondition | ID)")



model_paloo_80 <- makeLmer(
  PA_LOO ~ ITIcondition + (1 + ITIcondition | ID),
  fixef = fixed_weak,
  VarCorr = V_matrix,
  sigma = res_var,
  data = data_paloo_80
)




options(lme4.lmerControl = lmerControl(optimizer = "bobyqa", 
                                       optCtrl = list(maxfun = 2e+05)))

set.seed(924)


# (1.1) Contrast RanS vs RhyF
power_h11_paloo_RhyF <- powerSim(model_paloo, 
                                 test = fixed("ITIconditionRhyF", "z"), 
                                 nsim = powersim_nsim
)
stats <- get_sim_stats(power_h11_paloo_RhyF)
print(stats)

saveRDS(power_h11_paloo_RhyF,
        paste0(outpath,"power_h11_paloo_contrast_RanS_RhyF_test1.rds"))


# (1.2) Contrast RanS vs RhyS
power_h11_paloo_RhyS <- powerSim(model_paloo, 
                                 test = fixed("ITIconditionRhyS", "z"), 
                                 nsim = powersim_nsim
)
stats <- get_sim_stats(power_h11_paloo_RhyS)
print(stats)

saveRDS(power_h11_paloo_RhyS,
        paste0(outpath,"power_h11_paloo_contrast_RanS_RhyS_test1.rds"))




# (1.1)
pc_h11_paloo_RhyF <- powerCurve(model_paloo_80, 
                                test = fixed("ITIconditionRhyF", "z"), 
                                along = "ID", 
                                breaks = c(50, 55, 60, 65, 70, 75, 80),
                                nsim = powercurve_nsim
)

saveRDS(pc_h11_paloo_RhyF,
        paste0(outpath,"pc_h11_paloo_contrast_RanS_RhyF_test1.rds"))


# (1.2)
pc_h11_paloo_RhyS <- powerCurve(model_paloo_80, 
                                test = fixed("ITIconditionRhyS", "z"), 
                                along = "ID", 
                                breaks = c(50, 55, 60, 65, 70, 75, 80),
                                nsim = powercurve_nsim
)

saveRDS(pc_h11_paloo_RhyS,
        paste0(outpath,"pc_h11_paloo_contrast_RanS_RhyS_test1.rds"))




# TEST SCENARIO 2 ---------------------------------------------------------


# weaker phase alignment effects: c(0.1,0.06) --> c(0.06,0.04)


fixed_weak <- c(
  "(Intercept)" = 0, 
  "ITIconditionRhyS" = 0.04,
  "ITIconditionRhyF" = 0.06
)


model_paloo <- makeLmer(
  PA_LOO ~ ITIcondition + (1 + ITIcondition | ID),
  fixef = fixed_weak,
  VarCorr = V_matrix,
  sigma = res_var,
  data = data_paloo
)
formula_full <- paste0("H1.1, trial level: PA_LOO ~ ITIcondition + (1 + ITIcondition | ID)")



model_paloo_80 <- makeLmer(
  PA_LOO ~ ITIcondition + (1 + ITIcondition | ID),
  fixef = fixed_weak,
  VarCorr = V_matrix,
  sigma = res_var,
  data = data_paloo_80
)




options(lme4.lmerControl = lmerControl(optimizer = "bobyqa", 
                                       optCtrl = list(maxfun = 2e+05)))

set.seed(924)


# (1.1) Contrast RanS vs RhyF
power_h11_paloo_RhyF <- powerSim(model_paloo, 
                                 test = fixed("ITIconditionRhyF", "z"), 
                                 nsim = powersim_nsim
)
stats <- get_sim_stats(power_h11_paloo_RhyF)
print(stats)

saveRDS(power_h11_paloo_RhyF,
        paste0(outpath,"power_h11_paloo_contrast_RanS_RhyF_test2.rds"))


# (1.2) Contrast RanS vs RhyS
power_h11_paloo_RhyS <- powerSim(model_paloo, 
                                 test = fixed("ITIconditionRhyS", "z"), 
                                 nsim = powersim_nsim
)
stats <- get_sim_stats(power_h11_paloo_RhyS)
print(stats)

saveRDS(power_h11_paloo_RhyS,
        paste0(outpath,"power_h11_paloo_contrast_RanS_RhyS_test2.rds"))




# (1.1)
pc_h11_paloo_RhyF <- powerCurve(model_paloo_80, 
                                test = fixed("ITIconditionRhyF", "z"), 
                                along = "ID", 
                                breaks = c(50, 55, 60, 65, 70, 75, 80),
                                nsim = powercurve_nsim
)

saveRDS(pc_h11_paloo_RhyF,
        paste0(outpath,"pc_h11_paloo_contrast_RanS_RhyF_test2.rds"))


# (1.2)

pc_h11_paloo_RhyS <- powerCurve(model_paloo_80, 
                                test = fixed("ITIconditionRhyS", "z"), 
                                along = "ID", 
                                breaks = c(50, 55, 60, 65, 70, 75, 80),
                                nsim = powercurve_nsim
)

saveRDS(pc_h11_paloo_RhyS,
        paste0(outpath,"pc_h11_paloo_contrast_RanS_RhyS_test2.rds"))



# TEST SCENARIO 3 ---------------------------------------------------------


# stronger inter-individual variance: 0.1 --> 0.15


fixed_weak <- c(
  "(Intercept)" = 0, # RanS perfectly random
  "ITIconditionRhyS" = 0.06,
  "ITIconditionRhyF" = 0.1
)

correlations = 0.2
sds_between <- c(0.15, 0.15, 0.15) 

V_matrix <- makeVC(sds_between, correlations)



model_paloo <- makeLmer(
  PA_LOO ~ ITIcondition + (1 + ITIcondition | ID),
  fixef = fixed_weak,
  VarCorr = V_matrix,
  sigma = res_var,
  data = data_paloo
)
formula_full <- paste0("H1.1, trial level: PA_LOO ~ ITIcondition + (1 + ITIcondition | ID)")



model_paloo_80 <- makeLmer(
  PA_LOO ~ ITIcondition + (1 + ITIcondition | ID),
  fixef = fixed_weak,
  VarCorr = V_matrix,
  sigma = res_var,
  data = data_paloo_80
)


options(lme4.lmerControl = lmerControl(optimizer = "bobyqa", 
                                       optCtrl = list(maxfun = 2e+05)))

set.seed(924)


# (1.1) Contrast RanS vs RhyF
power_h11_paloo_RhyF <- powerSim(model_paloo, 
                                 test = fixed("ITIconditionRhyF", "z"), 
                                 nsim = powersim_nsim
)
stats <- get_sim_stats(power_h11_paloo_RhyF)
print(stats)

saveRDS(power_h11_paloo_RhyF,
        paste0(outpath,"power_h11_paloo_contrast_RanS_RhyF_test3.rds"))


# (1.2) Contrast RanS vs RhyS
power_h11_paloo_RhyS <- powerSim(model_paloo, 
                                 test = fixed("ITIconditionRhyS", "z"), 
                                 nsim = powersim_nsim
)
stats <- get_sim_stats(power_h11_paloo_RhyS)
print(stats)

saveRDS(power_h11_paloo_RhyS,
        paste0(outpath,"power_h11_paloo_contrast_RanS_RhyS_test3.rds"))




# (1.1)
pc_h11_paloo_RhyF <- powerCurve(model_paloo_80, 
                                test = fixed("ITIconditionRhyF", "z"), 
                                along = "ID", 
                                breaks = c(50, 55, 60, 65, 70, 75, 80),
                                nsim = powercurve_nsim
)

saveRDS(pc_h11_paloo_RhyF,
        paste0(outpath,"pc_h11_paloo_contrast_RanS_RhyF_test3.rds"))


# (1.2)

pc_h11_paloo_RhyS <- powerCurve(model_paloo_80, 
                                test = fixed("ITIconditionRhyS", "z"), 
                                along = "ID", 
                                breaks = c(50, 55, 60, 65, 70, 75, 80),
                                nsim = powercurve_nsim
)

saveRDS(pc_h11_paloo_RhyS,
        paste0(outpath,"pc_h11_paloo_contrast_RanS_RhyS_test3.rds"))





# TEST SCENARIO 4 ---------------------------------------------------------


# weaker phase alignment effects: c(0.1,0.06) --> c(0.06,0.045)


fixed_weak <- c(
  "(Intercept)" = 0, 
  "ITIconditionRhyS" = 0.045,
  "ITIconditionRhyF" = 0.06
)



correlations = 0.2
sds_between <- c(0.1, 0.1, 0.1) 

V_matrix <- makeVC(sds_between, correlations)
res_var <- 0.707



model_paloo <- makeLmer(
  PA_LOO ~ ITIcondition + (1 + ITIcondition | ID),
  fixef = fixed_weak,
  VarCorr = V_matrix,
  sigma = res_var,
  data = data_paloo
)
formula_full <- paste0("H1.1, trial level: PA_LOO ~ ITIcondition + (1 + ITIcondition | ID)")



model_paloo_80 <- makeLmer(
  PA_LOO ~ ITIcondition + (1 + ITIcondition | ID),
  fixef = fixed_weak,
  VarCorr = V_matrix,
  sigma = res_var,
  data = data_paloo_80
)




options(lme4.lmerControl = lmerControl(optimizer = "bobyqa", 
                                       optCtrl = list(maxfun = 2e+05)))

set.seed(924)


# (1.2) Contrast RanS vs RhyS
power_h11_paloo_RhyS <- powerSim(model_paloo, 
                                 test = fixed("ITIconditionRhyS", "z"), 
                                 nsim = powersim_nsim
)
stats <- get_sim_stats(power_h11_paloo_RhyS)
print(stats)

saveRDS(power_h11_paloo_RhyS,
        paste0(outpath,"power_h11_paloo_contrast_RanS_RhyS_test4.rds"))



# (1.2)

pc_h11_paloo_RhyS <- powerCurve(model_paloo_80, 
                                test = fixed("ITIconditionRhyS", "z"), 
                                along = "ID", 
                                breaks = c(50, 55, 60, 65, 70, 75, 80),
                                nsim = powercurve_nsim
)

saveRDS(pc_h11_paloo_RhyS,
        paste0(outpath,"pc_h11_paloo_contrast_RanS_RhyS_test4.rds"))




###########################################################################

