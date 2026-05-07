
# respirationAdj1 ---------------------------------------------------------


# Project       respirationAdj1
# Last updated  06 May 2026
# Author        Lioba Enk [enk@cbs.mpg.de]
# PI            Arno Villringer
# Note:         Codebook of expeco_physio can be found via:
#
# Script        check pseudorandomization file


rm(list=ls()) 


# dependencies ------------------------------------------------------------

library("tidyverse")

# settings ----------------------------------------------------------------


th_mixedmodels = theme(axis.ticks.x = element_blank(),
                       axis.title.x = element_text(size = rel(1.8)),
                       axis.text.x = element_text(size = rel(1.8)), # angle = 30), # !!!!
                       axis.title.y = element_text(size = rel(1.8)),
                       axis.text.y = element_text(size = rel(1.8)),
                       legend.title = element_blank(),
                       legend.text = element_text(size = rel(1.8)),
                       legend.position = "bottom",
                       plot.title = element_text(size=rel(1.8)),
                       plot.caption = element_text(vjust = 2, size = rel(1.2)),
                       strip.background = element_rect(fill="white", linewidth =0),
                       strip.text = element_text(size=rel(1.8), color="black"),
                       #panel.grid.major.x = element_blank(),
                       panel.grid.minor.x = element_blank())


# paths ------------------------------------------------------------------

path <- "/Users/liobaenk/Desktop/"

# Load data ---------------------------------------------------------------


pseudo_randomization_script = read.csv(file=paste(path,"respirationAdj1_blockorder_v3.csv",sep=""))
data_all <- pseudo_randomization_script


# -------------------------------------------------------------------------


pseudo_randomization_script <- pseudo_randomization_script[(pseudo_randomization_script$ID <= 51 |
                                                              pseudo_randomization_script$reason == "stoppingrule_batch1" |
                                                              pseudo_randomization_script$reason == "stoppingrule_batch2" |
                                                              pseudo_randomization_script$reason == "stoppingrule_batch3" |
                                                              pseudo_randomization_script$reason == "stoppingrule_batch4" |
                                                              pseudo_randomization_script$reason == "stoppingrule_batch5"
                                                            ),]


# notification (LE, 06 May 2026):
# noticed that it is similar to other columns (ID41 was smoker which is why session was prematurely stopped)
# --> sequence will not be repeated --> instead: new unique sequence used!
pseudo_randomization_script <- pseudo_randomization_script[pseudo_randomization_script$ID != 41,]



# -------------------------------------------------------------------------


count_summary <- pseudo_randomization_script %>%
  group_by(block_types, button_response_order) %>%
  summarise(n_blocks = n(), .groups = "drop") %>%
  pivot_wider(names_from = block_types, values_from = n_blocks, values_fill = 0)

print(count_summary)



# check number of identical columns ---------------------------------------


cols_to_check <- names(pseudo_randomization_script)[grep("block_pos", names(pseudo_randomization_script), ignore.case = TRUE)]


identical_sequences <- pseudo_randomization_script %>%
  group_by(across(all_of(cols_to_check))) %>%
  filter(n() > 1) %>%
  mutate(match_group = cur_group_id()) %>%
  ungroup() %>%
  select(ID, block_types, button_response_order, match_group, all_of(cols_to_check)) %>%
  arrange(match_group)

print(identical_sequences)



# -------------------------------------------------------------------------



# row_counts <- pseudo_randomization_script %>%
#   group_by(ID, condition) %>%
#   summarise(n = n(), .groups = "drop") %>%
#   pivot_wider(names_from = condition, values_from = n, values_fill = 0)
# 
# # Check for violations
# violations <- row_counts %>%
#   filter(RhyF != 2 | RhyS != 4 | RanS != 4)



# prepare for plotting ----------------------------------------------------



pseudo_randomization_script <- pseudo_randomization_script %>%
  pivot_longer(
    cols = starts_with("block_pos_"),
    names_to = "block",
    names_prefix = "block_pos_",
    values_to = "condition"
  ) %>%
  mutate(
    block = as.integer(block),
    condition = recode(condition,
                       `1` = "RhyF",
                       `2` = "RhyS",
                       `3` = "RanS")
)


pseudo_randomization_script$condition <- factor(pseudo_randomization_script$condition, c("RhyF", "RhyS", "RanS"),
                            c("RhyF", "RhyS", "RanS"))

pseudo_randomization_script$ID <- as.factor(pseudo_randomization_script$ID)




# plot 1 ------------------------------------------------------------------


ggplot(pseudo_randomization_script, aes(x = block, y = ID, fill = condition)) +
  geom_tile(color = "white", linewidth = 0.2) +
  scale_x_continuous(breaks = 1:10) +
  scale_fill_brewer(palette = "Set2") +
  theme_minimal() +
  th_mixedmodels +
  theme(
    panel.grid = element_blank(),
  )



heatmap_data <- pseudo_randomization_script %>%
  group_by(condition, block) %>%
  summarise(n = n(), .groups = "drop")

ggplot(heatmap_data, aes(x = block, y = condition, fill = n)) +
  geom_tile(color = "white") +
  scale_fill_gradient(low = "#f69697", high = "#c30010") +
  scale_x_continuous(breaks = 1:10) +
  labs(
    x = "Block",
    y = "",
    title = "Distribution of conditions across blocks"
  ) +
  theme_minimal() +
  th_mixedmodels +
  theme(panel.grid = element_blank(),
        legend.position = "right")


condition_counts_table <- pseudo_randomization_script %>%
  group_by(condition, block) %>%
  summarise(n = n(), .groups = "drop") %>%
  pivot_wider(names_from = block, values_from = n)
condition_counts_table

half_comparison <- pseudo_randomization_script %>%
  mutate(block_half = if_else(block <= 5, "First_5", "Last_5")) %>%
  group_by(condition, block_half) %>%
  summarise(total_n = n(), .groups = "drop") %>%
  pivot_wider(names_from = block_half, values_from = total_n)
half_comparison




# plot by resting state order ---------------------------------------------


heatmap_data_detailed <- pseudo_randomization_script %>%
  group_by(block_types, block, condition) %>%
  summarise(n = n(), .groups = "drop_last") %>%
  mutate(
    prop = n / sum(n) * 100 
  ) %>%
  ungroup()


ggplot(heatmap_data_detailed, aes(x = factor(block), y = condition, fill = prop)) +
  geom_tile(color = "white", linewidth = 0.5) +
  geom_text(aes(label = n), color = "black", fontface = "bold", size = 5) +
  scale_fill_gradient(
    low = "#fef0d9", 
    high = "#d7301f", 
    name = "Prop %"
  ) +
  facet_wrap(~block_types, scales = "fixed", labeller = label_both) +
  theme_minimal() +
  th_mixedmodels +
  theme(
    panel.grid = element_blank(),
    strip.text = element_text(face = "bold"),
    legend.position = "right",
    axis.text.x = element_text(angle = 0)
  )



# plot by button response order (detection) -------------------------------


heatmap_data <- pseudo_randomization_script %>%
  group_by(condition, thr1F_response_button, block) %>%
  summarise(n = n(), .groups = "drop")

ggplot(heatmap_data, aes(x = block, y = condition, fill = n)) +
  geom_tile(color = "white") +
  scale_fill_gradient(low = "#f69697", high = "#c30010") +
  scale_x_continuous(breaks = 1:10) +
  labs(
    x = "Block",
    y = "",
    title = "Distribution of conditions across blocks"
  ) +
  theme_minimal() +
  th_mixedmodels +
  theme(panel.grid = element_blank(),
        legend.position = "right")+
  facet_wrap(~thr1F_response_button, scales = "free_y", labeller = label_both)




################################################################

