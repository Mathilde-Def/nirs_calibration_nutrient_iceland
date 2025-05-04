################################################################################
#   ASSESSING DIFFENCES IN FAECAL NUTRIENT CONTENT BETWEEN HERBIVORES - MODEL
#                           Mathilde Defourneaux
#                               Apr 01, 2024
################################################################################

# last update: Oct 25, 2024

## This script are the models to see the differences in faecal content of each 
# nutrient per herbivore species along the season 

## Full description of the calibration can be read in : Defourneaux et al. 2025 (in press)

## The analysis are based on samples from Iceland.

# herbivore nutrient content were evaluated using nirs calibration model 
# on dried faecal samples

## Samples were presented as tablets, dried at 40°C for 3 hours 
# and cooled down in a desiccator
## Thereafter samples were scanned with NIRS 

#A FieldSpec 4 was used to scan the samples, with a spectral range of 350-2500nm, 
# interpolated at 1nm intervals

# Dataset
# "id"                   - Faecal sample ID
# "herbivore"            - Herbivore species (pink footed goose, sheep and reindeer)
# "year"                 - Year where the samples were collected (2022)
# "session"              - time of the growing season the samples was collected: 
#                           A = beginning - mid-June to mid-July, 
#                           B = peak - mid July to mid August,
#                           C = end - mid August to mid-September
# "date"                 - date when the faecal material was collected                
# "C"                    - Carbon (% DM)
# "N"                    - Nitrogen (% DM)
# "P"                    - Phosphorus (% DM)
# "CN"                   - Carbon to nitrogen ratio
# "CP"                   - Carbon to phosphorus ratio
# "NP"                   - nitrogen to phosphorus ratio

####------------------------------------------------------------------------####
#### SETUP
####------------------------------------------------------------------------####

set.seed(132)

## ---- library
source("./R scripts/codes/setup.R")

# data set

data_nutrient <- fread(file = "./R scripts/data/24-10-25_data_nutrient_prediction.txt", sep = ";", header = T)

## FUNCTIONS ------------------------------------------------------_------------
se <- function(x) sd(x)/sqrt(length(x))  # function for standard error

## PLOTS AESTHETICS ------------------------------------------------------------

source("./R scripts/functions/theme_perso.R") # function for personal plot theme
palette_herbivore <- c("#E57F84", "#5F9EA0", "#EBB261")

####------------------------------------------------------------------------####
#### CLEANING AND FORMATING DATA
####------------------------------------------------------------------------####

data_nutrient <- data_nutrient %>% 
  drop_na(herbivore) %>% 
  mutate(
    session = as.factor(session),
    herbivore = factor(herbivore, levels = c("geese", "sheep", "reindeer")),
    age = factor(age, levels = c("adult", "young"))) 

nrow(data_nutrient)
glimpse(data_nutrient)

# summary of the data
summary_full_data <- data_nutrient %>%
  group_by(herbivore, session, age) %>%
  summarise(
    # Count of observations within each group
    n = n(),  
    # Calculate mean and CV, then concatenate for each variable
    N = paste0(round(mean(N), 2), " ± cv ", round(sd(N) / mean(N), 2)),
    P = paste0(round(mean(P), 2), " ± cv ", round(sd(P) / mean(P), 2)),
    C = paste0(round(mean(C), 2), " ± cv ", round(sd(C) / mean(C), 2)),
    CN = paste0(round(mean(CN), 2), " ± cv ", round(sd(CN) / mean(CN), 2)),
    CP = paste0(round(mean(CP), 2), " ± cv ", round(sd(CP) / mean(CP), 2)),
    NP = paste0(round(mean(NP), 2), " ± cv ", round(sd(NP) / mean(NP), 2))
  )

summary_full_data_nb <- data_nutrient %>%
  group_by(herbivore, session, age) %>%
  summarise(
    n = n()) %>% 
  pivot_wider(names_from = session, values_from = n) %>% 
  rename("beginning" = "A", "peak" = "B", "end" = "C") %>% 
  rename_with(~ str_to_title(.)) %>% 
  mutate(Age = case_when(
    Age == "young" ~ "juvenile",
    TRUE ~ Age  # Default case to keep other age values
  ))

unique(data_nutrient$session)
glimpse(data_nutrient)

data_nutrient %>% summarise(
  n = n())

# fwrite(summary_full_data_nb, file = "./figures/tables/summary_all/summary_full_data_count.csv", sep = ";")

####------------------------------------------------------------------------####
#### SPECIES X SEASONALITY COMPARISON MODEL
####------------------------------------------------------------------------####

# Note, only the post-hoc tukey test is reported in the paper 
# Variables for analysis
variables <- c("C", "N", "P", "CN", "CP", "NP")
# Empty list to store the results
speciesxsession_results <- list()

# (Intercept): The baseline value of nutrient when session is 'A' and herbivore is 'geese'.
# sessionB: The change in B when moving from session 'A' to 'B'.
# sessionC: The change in C when moving from session 'A' to 'C'.

# Loop through each nutrient
for (variable in variables) {
  
  # Fit ANOVA model
  aov_model <- aov(formula(paste(variable, "~ session * herbivore + Error(factor(id))")), 
                   data = data_nutrient)
  anova_summary <- tidy(aov_model)
  
 # Conduct pairwise Tukey's test for all possible combination using emmeans
  emms <- emmeans(aov_model, ~ session * herbivore)
  pairwise_comparisons <- pairs(emms, adjust = "tukey")
  pairwise_df <- as.data.frame(pairwise_comparisons)
  
  # Generate the compact letter display to denote subgroups
  cld_results <- cld(emms, adjust = "tukey", Letters = letters)
  cld_df <- as.data.frame(cld_results)

  # Store results in the speciesxsession_results
  speciesxsession_results[[variable]] <- list(
    anova_summary = anova_summary,
    emms_summary = pairwise_df,
    cld_results = cld_df
  )
}

# Access the results for each variable
for (variable in variables) {
  print(paste("Summary for", variable))
  print(speciesxsession_results[[variable]]$anova_summary)
  print(paste("Post-hoc for", variable))
  print(speciesxsession_results[[variable]]$anova_summary)
  print(paste("Pairwise comparison for", variable))
  print(speciesxsession_results[[variable]]$emms_summary)
  print(speciesxsession_results[[variable]]$cld_results)
}

print(speciesxsession_results[["C"]])

####------------------------------------------------------------------------####
#### FORMATING RESULTS FROM THE ANALYSIS
####------------------------------------------------------------------------####

## Two-ways ANOVA

# Initialize an empty dataframe to store the combined results
combined_results_anova <- data.frame()

# Iterate over the result list
for (variable in variables) {
  
  # Extract the tidied ANOVA summary for the current variable
  anova_summary_all <- speciesxsession_results[[variable]]$anova_summary
  # Add a 'variable' column to track which variable the results correspond to
  anova_summary_all <- anova_summary_all %>%
    mutate(variable = variable)
  # Combine with the previous results
  combined_results_anova <- bind_rows(combined_results_anova, anova_summary_all)
  
}

combined_results_anova <- combined_results_anova %>% 
  drop_na() %>% 
  dplyr::select(variable, everything()) %>% 
  mutate(across(c("sumsq", "meansq", "statistic"), ~ round(., 2))) %>% 
  mutate(significance = case_when(
    p.value == 0 ~ "****",
    p.value > 0 & p.value < 0.001 ~ "***",
    p.value >= 0.001 & p.value < 0.01 ~ "**",
    p.value >= 0.01 & p.value < 0.05 ~ "*",
    TRUE ~ "ns"  # Default case for anything else
  )) %>% 
  mutate("p.value_round" = ifelse(p.value < 0.001, "< 0.001", round(p.value, 3))) %>%
  mutate(p_value_significance = paste0(p.value_round, " ", significance)) %>% 
  dplyr::select(- stratum) 

#fwrite(combined_results_anova, file = "./figures/nutrient_content/combined_results_anova.csv", sep = ";") 

## Pairwise comparison

# Initialize an empty dataframe to store the combined results
combined_results_pairwise <- data.frame()

# Iterate over the species_results list
for (variable in variables) {
  # Extract the posthoc summary for the current variable
  emms_summary <- speciesxsession_results[[variable]]$emms_summary
  # Add a 'variable' column to track which variable the results correspond to
  emms_summary <- emms_summary %>%
    mutate(variable = variable)
  # Combine with the previous results
  combined_results_pairwise <- bind_rows(combined_results_pairwise, emms_summary)
}

combined_results_pairwise_clean <- combined_results_pairwise %>% 
  drop_na() %>% 
  dplyr::select(variable, everything()) %>% 
  mutate(across(c("estimate", "SE", "t.ratio"), ~ round(., 3))) %>% 
  mutate(significance = case_when(
    p.value == 0 ~ "****",
    p.value > 0 & p.value < 0.001 ~ "***",
    p.value >= 0.001 & p.value < 0.01 ~ "**",
    p.value >= 0.01 & p.value < 0.05 ~ "*",
    TRUE ~ "ns"  # Default case for anything else
  )) %>% 
  mutate("p.value_round" = ifelse(p.value < 0.001, "< 0.001", round(p.value, 3))) 

## subgroup division

# Initialize an empty dataframe to store the combined results
combined_results_cld <- data.frame()

# Iterate over the species_results list
for (variable in variables) {
  # Extract the posthoc summary for the current variable
  cld_results <- speciesxsession_results[[variable]]$cld_results
  # Add a 'variable' column to track which variable the results correspond to
  cld_results <- cld_results %>%
    mutate(variable = variable)
  # Combine with the previous results
  combined_results_cld <- bind_rows(combined_results_cld, cld_results)
}

combined_results_cld_clean <- combined_results_cld %>% 
  drop_na() %>% 
  dplyr::select(variable, everything()) %>% 
  rename(nutrient = variable)#%>% 
  #mutate(key = paste(session, herbivore))

# Filter only significant comparisons between sessions A and B
significant_AB <- combined_results_pairwise[
  grepl("A .* - B .*", combined_results_pairwise$contrast) &
    combined_results_pairwise$adj.p.value < 0.05,
]

####------------------------------------------------------------------------####
#### PLOT THE RESULTS
####------------------------------------------------------------------------####

# annotations
plot_name <- c("(a)", "(b)", "(c)", "(d)", "(e)", "(f)")

combined_results_cld_clean <- combined_results_cld_clean %>% 
  # remove unwanted spaces arround letters in the ".group" variable
  mutate(.group = trimws(.group),
         plot_name = plot_name[match(nutrient, c("N", "P", "C", "CN", "CP", "NP"))]) %>% 
  mutate(nutrient = recode(nutrient,
                           "CN" = "C:N",
                           "CP" = "C:P",
                           "NP" = "N:P")) %>% 
  mutate(
    y_label = case_when(
      nutrient == "N" ~ "Mean N (% DW)",
      nutrient == "C:N" ~ "Mean C:N",
      nutrient == "P" ~ "Mean P (% DW)",
      nutrient == "C:P" ~ "Mean C:P",
      nutrient == "C" ~ "Mean C (% DW)",
      nutrient == "N:P" ~ "Mean N:P"
    )
  )


plot_nutrient_session <- combined_results_cld_clean %>% 
  mutate(nutrient = factor(nutrient, levels = c("N", "C:N", "P", "C:P", "C", "N:P"))) %>%  # Updated factor levels
  ggplot(aes(x = session, y = emmean, color = herbivore)) +
  # Lines
  geom_line(aes(group = interaction(herbivore, nutrient), color = herbivore), size = 1.5) +
  # Points without shape legend
  geom_point(aes(shape = herbivore), size = 5, alpha = 0.5, show.legend = FALSE) +
  # Error bars
  geom_errorbar(aes(ymin = emmean - SE, ymax = emmean + SE), width = 0.1, alpha = 0.7) +
  # Adjusted text to avoid overlap
  geom_text(aes(label = .group), position = position_jitter(width = 0.2, height = 0.2), size = 7, vjust = -1) +
  facet_wrap(~ nutrient, scales = "free", ncol = 2) +
  # Annotate the top-left corner with plot_name
  geom_text(data = data.frame(nutrient = factor(c("N", "C:N", "P", "C:P", "C", "N:P")),
                              plot_name = c("(a)", "(b)", "(c)", "(d)", "(e)", "(f)")),
            aes(x = -Inf, y = Inf, label = plot_name),
            hjust = -0.1, vjust = 2, size = 8, inherit.aes = FALSE) +
  # Adjust x-axis labels
  scale_x_discrete(limits = unique(combined_results_cld_clean$session),  
                   labels = c("Beginning", "Peak", "Late")) +
  # Y-axis label and color legend label
  labs(x = "", y = "Mean Nutrient (% DW)", color = "Herbivore") +
  # Customize color palette
  scale_fill_manual(values = palette_herbivore) +
  scale_colour_manual(values = palette_herbivore,
                      name = "Herbivore",
                      labels = c("Geese", "Sheep", "Reindeer")) +
  # Apply custom theme
  theme_perso() +
  # Customize facet strip text
  theme(strip.text = element_text(size = 20),
        legend.position = "bottom")

# Print the plot
print(plot_nutrient_session)
# Adjusts facet label size

ggsave("./figures/nutrients_season.png", 
       plot_nutrient_session, 
       width = 15, height = 20) #width = 140, height = 200, units = "mm", dpi = 1000

ggsave("./figures/nutrients_season.svg", 
       plot_nutrient_session, 
       width = 15, height = 20,
       device = "svg")
