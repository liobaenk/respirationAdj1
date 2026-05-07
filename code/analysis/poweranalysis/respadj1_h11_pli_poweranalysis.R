

# Power analysis code : Hypothesis H1.1
# project         rsAirflow/Study 1 - respirationAdj1
# author          Lioba Enk (enk@cbs.mpg.de)
# last updated    22 April 2026


# Formula (H1.1)
# LMM : PLI ~ ITIcondition + (1 | ID)
# (1) assuming a PLI shift of delta 0.3 (RanS baseline vs RhyF shift), simulating change with increasing N
# (2) taking N=50, and simulating an increase in minimal detectable effect (MDE) by power




rm(list = ls())



# -------------------------------------------------------------------------


library(simr)
library(lme4)

library(ggplot2)


# -------------------------------------------------------------------------


outpath = "/data/pt_02745/respirationAdj1/code/analysis/poweranalysis/results/hypo1/"


# functions ---------------------------------------------------------------


makeVC <- function(sd, rho) {
  n <- length(sd)
  R <- matrix(rho, n, n)
  diag(R) <- 1
  V <- diag(sd) %*% R %*% diag(sd)
  return(V)
}

extract_pc_data <- function(pc) {
  dat <- summary(pc)
  # dat usually has columns: nlevels, successes, trials, mean, lower, upper
  return(dat)
}


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
                    #panel.grid.major.x = element_blank(),
                    panel.grid.minor.x = element_blank(),
                    panel.border = element_rect(color = "darkgrey", fill = NA, linewidth = 1)
)



# -------------------------------------------------------------------------


formula_model1 <- "H1.1 (1) : (Aggregated) PLI ~ ITIcondition + (1 | ID), assuming a PLI shift of Δ0.30"
formula_model2 <- "H1.1 (2) : (Aggregated) PLI ~ ITIcondition + (1 | ID), minimum detectable effects (MDE) for N=50"
formula_model2_55 <- "H1.1 (2) : (Aggregated) PLI ~ ITIcondition + (1 | ID), minimum detectable effects (MDE) for N=55"
formula_model2_60 <- "H1.1 (2) : (Aggregated) PLI ~ ITIcondition + (1 | ID), minimum detectable effects (MDE) for N=60"


conds <- c("RanS", "RhyS", "RhyF")
total_trials_per_cond <- 320


n_subj <- 50
n_subj_for_sensanalysis <- 100


data_h11 <- expand.grid(
  ITIcondition = factor(conds, levels = c("RanS", "RhyS", "RhyF")),
  ID = factor(1:n_subj)
)

data_h11_55 <- expand.grid(
  ITIcondition = factor(conds, levels = c("RanS", "RhyS", "RhyF")),
  ID = factor(1:(n_subj+5))
)

data_h11_60 <- expand.grid(
  ITIcondition = factor(conds, levels = c("RanS", "RhyS", "RhyF")),
  ID = factor(1:(n_subj+10))
)

data_h11_100 <- expand.grid(
  ITIcondition = factor(conds, levels = c("RanS", "RhyS", "RhyF")),
  ID = factor(1:n_subj_for_sensanalysis)
)



# -------------------------------------------------------------------------


powersim_nsim = 1000
powercurve_nsim = 1000


# (1) ---------------------------------------------------------------------


# Standardized variance structure
rand_int_var <- 0.3
resid_sd     <- sqrt(0.7)



# Notification:
# (Intercept) == 0.056
# For circular data (like respiratory phase), the expected PLI (vector length R)
# for a perfectly random distribution is approximately:
# E[PLI] = sqrt(1/320) = 0.056



fixed_eff_pli <- c(
  "(Intercept)"        = 0.056, # RanS (baseline)
  "ITIconditionRhyS"   = 0.256,
  "ITIconditionRhyF"   = 0.356
)

model_h11 <- makeLmer(
  PLI ~ ITIcondition + (1 | ID), 
  fixef = fixed_eff_pli, 
  VarCorr = rand_int_var,
  sigma = resid_sd,
  data = data_h11
)

model_h11_55 <- makeLmer(
  PLI ~ ITIcondition + (1 | ID), 
  fixef = fixed_eff_pli, 
  VarCorr = rand_int_var,
  sigma = resid_sd,
  data = data_h11_55
)

model_h11_60 <- makeLmer(
  PLI ~ ITIcondition + (1 | ID), 
  fixef = fixed_eff_pli, 
  VarCorr = rand_int_var,
  sigma = resid_sd,
  data = data_h11_60
)


model_h11_100 <- makeLmer(
  PLI ~ ITIcondition + (1 | ID), 
  fixef = fixed_eff_pli, 
  VarCorr = rand_int_var,
  sigma = resid_sd,
  data = data_h11_100
)



# simulations -------------------------------------------------------------



power_h11 <- powerSim(model_h11, 
                      fixed("ITIcondition", "f"), 
                      nsim = powersim_nsim
)
saveRDS(power_h11,
        paste0(outpath,"power_h11_pli_contrast_RanS_RhyF.rds"))




pc_h11 <- powerCurve(model_h11_100, 
                     along="ID", 
                     breaks=c(seq(50, 100, 5)),
                     fixed("ITIcondition", "f"), 
                     nsim = powercurve_nsim)
saveRDS(pc_h11,
        paste0(outpath,"pc_h11_pli_contrast_RanS_RhyF.rds"))




pc_data <- extract_pc_data(pc_h11)
filename <- "pc_h11_pli_contrast_RanS_RhyF.svg"

p <- ggplot(pc_data, aes(x=nlevels, y=mean)) +
  
  geom_hline(yintercept=0.80, linetype="dashed", color="red") +
  
  scale_y_continuous(limits = c(0,1), breaks = c(seq(0,1,0.1)))+
  scale_x_continuous(limits = c(49,101), breaks = c(seq(50,100,5)))+
  geom_line(size=1, color="steelblue") +
  geom_errorbar(aes(ymin=lower, ymax=upper), width=2) +
  geom_point(size=3, color="steelblue") +
  
  labs(title="H1.1: Sensitivity analysis (power curve)",
       subtitle = formula_model1,
       x="Sample size",
       y="Power (1 - Beta)") +
  theme_minimal() +
  th_settings +
  theme(axis.title.x = element_text(size = rel(1.8)),
        axis.title.y = element_text(size = rel(1.8))
  )

ggsave(
  filename = file.path(outpath, filename),
  plot = p,
  device = "svg",
  width = 9,
  height = 8,
  units = "in"
)



# (2) ---------------------------------------------------------------------



effect_range <- seq(0.3, 0.6, by = 0.05)
sens_results <- data.frame()


for (eff in effect_range) {
  
  temp_fixef <- c(
    "(Intercept)"      = 0.056, 
    "ITIconditionRhyS" = eff * 0.7, # assuming RhyS is ~70% of RhyF
    "ITIconditionRhyF" = eff
  )
  
  # update fixed effects
  
  # fixef(model_h11) <- temp_fixef
  # ps_temp <- powerSim(model_h11, 
  #                     fixed("ITIcondition", "f"), 
  #                     nsim = powersim_nsim, 
  #                     progress = FALSE)
  
  # fixef(model_h11_55) <- temp_fixef
  # ps_temp <- powerSim(model_h11_55, 
  #                     fixed("ITIcondition", "f"), 
  #                     nsim = powersim_nsim, 
  #                     progress = FALSE)
  
  fixef(model_h11_60) <- temp_fixef
  ps_temp <- powerSim(model_h11_60, 
                      fixed("ITIcondition", "f"), 
                      nsim = powersim_nsim, 
                      progress = FALSE)
  
  
  # results
  res <- summary(ps_temp)
  sens_results <- rbind(sens_results, data.frame(
    Intercept_PLI_RanS = 0.056,
    Shift_PLI_RhyF = eff,
    Power = res$mean,
    Lower = res$lower,
    Upper = res$upper
  ))
  
  message(paste("Tested PLI Shift:", eff, "--> Power:", round(res$mean * 100, 1), "%"))
}

# saveRDS(sens_results, 
#         file = file.path(outpath, "power_h11_pli_contrast_RanS_RhyF_mde_n50.rds"))
# saveRDS(sens_results, 
#         file = file.path(outpath, "power_h11_pli_contrast_RanS_RhyF_mde_n55.rds"))
saveRDS(sens_results, 
        file = file.path(outpath, "power_h11_pli_contrast_RanS_RhyF_mde_n60.rds"))





p_sens <- ggplot(sens_results, aes(x = Shift_PLI_RhyF, y = Power)) +
  
  geom_hline(yintercept = 0.80, linetype = "dashed", color = "red", linewidth = 0.8) +
  
  geom_line(linewidth = 1, color = "violet") +
  geom_point(size = 3, color = "violet") +
  
  geom_errorbar(aes(ymin = Lower, ymax = Upper), width = 0.01) +
  
  scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, 0.1)) +
  scale_x_continuous(breaks = effect_range) +
  
  labs(title = "H1.1: Sensitivity analysis (power curve)",
       subtitle = formula_model2_60,
       x = "Simulated PLI shift",
       y = "Power (1 - Beta)") +
  
  theme_minimal() +
  th_settings +
  theme(axis.title.x = element_text(size = rel(1.8)),
        axis.title.y = element_text(size = rel(1.8)))


p_sens



# filename <- "pc_h11_pli_contrast_RanS_RhyF_mde_n50.svg"
# filename <- "pc_h11_pli_contrast_RanS_RhyF_mde_n55.svg"
filename <- "pc_h11_pli_contrast_RanS_RhyF_mde_n60.svg"


ggsave(
  filename = file.path(outpath, filename),
  plot = p_sens,
  device = "svg",
  width = 9,
  height = 8,
  units = "in"
)



# -------------------------------------------------------------------------



path <- "/data/pt_02745/respirationAdj1/code/analysis/poweranalysis/results/hypo1/"



results <- readRDS(file.path(path,"power_h11_pli_contrast_RanS_RhyF.rds"))
results
get_sim_stats(results)
results$messages

results <- readRDS(file.path(path,"power_h11_pli_contrast_RanS_RhyF_mde_n50.rds"))
results

results <- readRDS(file.path(path,"power_h11_pli_contrast_RanS_RhyF_mde_n55.rds"))
results

results <- readRDS(file.path(path,"power_h11_pli_contrast_RanS_RhyF_mde_n60.rds"))
results



############################################################################
