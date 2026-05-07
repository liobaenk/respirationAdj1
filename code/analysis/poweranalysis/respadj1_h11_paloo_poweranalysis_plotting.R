

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
#
# =========================================================================



rm(list = ls())


# -------------------------------------------------------------------------


library(ggplot2)

# -------------------------------------------------------------------------


path <- "/data/pt_02745/respirationAdj1/code/analysis/poweranalysis/results/hypo1"


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


formula <- paste0("H1.1, trial level: PA_LOO ~ ITIcondition + (1 + ITIcondition | ID)")


# -------------------------------------------------------------------------


# contrast RanS vs RhyF : Original

results <- readRDS(file.path(path,"power_h11_paloo_contrast_RanS_RhyF.rds"))
results
get_sim_stats(results)
results$messages

results <- readRDS(file.path(path,"power_h11_paloo_contrast_RanS_RhyF_test1.rds"))
results
get_sim_stats(results)
results$messages

results <- readRDS(file.path(path,"power_h11_paloo_contrast_RanS_RhyF_test2.rds"))
results
get_sim_stats(results)
results$messages

results <- readRDS(file.path(path,"power_h11_paloo_contrast_RanS_RhyF_test3.rds"))
results
get_sim_stats(results)
results$messages




# contrast RanS vs RhyS

results <- readRDS(file.path(path,"power_h11_paloo_contrast_RanS_RhyS.rds"))
results
get_sim_stats(results)
results$messages

results <- readRDS(file.path(path,"power_h11_paloo_contrast_RanS_RhyS_test1.rds"))
results
get_sim_stats(results)
results$messages

results <- readRDS(file.path(path,"power_h11_paloo_contrast_RanS_RhyS_test2.rds"))
results
get_sim_stats(results)
results$messages

results <- readRDS(file.path(path,"power_h11_paloo_contrast_RanS_RhyS_test3.rds"))
results
get_sim_stats(results)
results$messages





# power curves


titlename <- paste0("H1.1: Sensitivity analysis for contrast (RanS vs ",
                    "RhyS)")


pc_results <- readRDS(file.path(path,"pc_h11_paloo_contrast_RanS_RhyS_test1.rds"))
pc_results
filename <- "powercurve_h11_paloo_contrast_RanS_RhyS_test1.svg"
formula_new <- paste0(formula, ". Simulation 1: effect size (beta) = 0.03, SD_ID = 0.1")

pc_results <- readRDS(file.path(path,"pc_h11_paloo_contrast_RanS_RhyS_test2.rds"))
pc_results
filename <- "powercurve_h11_paloo_contrast_RanS_RhyS_test2.svg"
formula_new <- paste0(formula, ". Simulation 2: effect size (beta) = 0.04,  SD_ID = 0.1")


pc_results <- readRDS(file.path(path,"pc_h11_paloo_contrast_RanS_RhyS_test3.rds"))
pc_results
filename <- "powercurve_h11_paloo_contrast_RanS_RhyS_test3.svg"
formula_new <- paste0(formula, ". Simulation 3: effect size (beta) = 0.06, SD_ID = 0.15")




pc_data <- extract_pc_data(pc_results)
p <- ggplot(pc_data, aes(x=nlevels, y=mean)) +
  
  geom_hline(yintercept=0.80, linetype="dashed", color="red") +
  
  scale_y_continuous(limits = c(0,1), breaks = c(seq(0,1,0.1)))+
  scale_x_continuous(limits = c(49,81), breaks = c(seq(50,80,5)))+
  geom_line(size=1, color="steelblue") +
  geom_errorbar(aes(ymin=lower, ymax=upper), width=2) +
  geom_point(size=3, color="steelblue") +
  
  labs(title = titlename,
       subtitle = formula_new,
       x="Sample size",
       y="Power (1 - Beta)") +
  theme_minimal() +
  th_settings +
  theme(axis.title.x = element_text(size = rel(1.8)),
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




##############################################################################

