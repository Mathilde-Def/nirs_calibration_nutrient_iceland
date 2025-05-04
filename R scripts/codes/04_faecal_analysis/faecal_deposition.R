################################################################################
#
#                   HERBIVORE NUTRIENT FAECAL DEPOSITION
#
################################################################################

# this script aims to estimate the total amount of N, P and C (in T) deposited by
# pink footed goose, reindeer and sheep in the Eastern Highland rangelands 
# (Iceland, study area 65.3234 °N, 15.3062 °E) 

# We combined local herbivore densities, defecation rates, grazing time, and 
# averaged pellet dry weight throughout the growing season

## Full description of the calibration can be read in : Defourneaux et al. 2025 (in press)

# sheep population estimate was obtained from Ministry of Food, Agriculture and Fisheries
# reindeer and geese population estimate was obtained from the East institute of natural studies
# defecation rate (in defecation event/day) was obtained from literature
# grazing day (day) relate to the time spent in the study area for each herbivore species
# pellet weight (in g DM) was evaluate after sub-sampling approx. 10g of fresh 
  # sheep and reindeer faeces, and 4g of fresh goose dropping, 
  # from 5 randomly selected samples for each species. 
  # Each sub-sample was oven dried at 40°C  for 2 days, 
  # We then compared the wet and dry weight and extrapolated to the whole pile.

# Faecal nutrient content (N, P and C) was obtained from the NIRS calibrated model,

# Overall, geese contributed more to the total N, P and C deposition, consistently across the growing season
# most nutrient deposition happen at the start of the growing season

####------------------------------------------------------------------------####
#### SETUP
####------------------------------------------------------------------------####

set.seed(132)

## ---- library
source("./R scripts/codes/setup.R")

## ---- data

faecal_deposition <- fread("./R scripts/data/24-10-25_faecal_deposition.txt", sep = ";", header = T) # daily faecal deposition rate, grazing time and geese and reindeer population data
pellet_weight <- fread("./R scripts/data/24-10-25_pellet_weight.txt", sep = ";", header = T) # pellet weight
data_nutrient <- fread("./R scripts/data/24-10-25_data_nutrient_prediction.txt", sep = ";", header = T) # faecal nutrient content

## PLOTS AESTHETICS ------------------------------------------------------------

source("./R scripts/functions/theme_perso.R") # function for personal plot theme

palette_session <- c("#d4e09b", "#797d62","#d08c60")

####------------------------------------------------------------------------####
#### CLEANING AND FORMATING DATA
####------------------------------------------------------------------------####

# nutrient data

summary_nutrient <- data_nutrient %>% 
  drop_na(herbivore) %>% 
  mutate(
    session = as.factor(session),
    herbivore = factor(herbivore, levels = c("geese", "sheep", "reindeer")),
    age = factor(age, levels = c("adult", "young"))) %>% 
  group_by(herbivore, session) %>% 
  summarise(mean_N = mean(N), 
            mean_P = mean(P),
            mean_C = mean(C),
            mean_CN = mean(CN),
            mean_CP = mean(CP),
            mean_NP = mean(NP)) %>% 
  mutate(herbivore = gsub("geese", "pink footed goose", herbivore))

# faecal deposition and population data

colnames(faecal_deposition)

####------------------------------------------------------------------------####
#### COMPUTING NUTRIENT DEPOSITION ACCROSS SEASONS AND HERBIVORE SPECIES
####------------------------------------------------------------------------####

summary_pellet_weight <- pellet_weight %>% 
  mutate(sample_wc = (sample_ww - sample_dw)/ sample_ww,
         faecal_dw_g = pile_ww - pile_ww * sample_wc) %>%  # compute faecal DW in g
  group_by(herbivore) %>% 
  #summarise(mean_faecal_dw_g = mean(faecal_dw_g, na.rm = TRUE)) %>% 
  left_join(faecal_deposition, by = c("herbivore"), relationship = "many-to-many") %>% 
  left_join(summary_nutrient, by = c("herbivore"), relationship = "many-to-many") %>% 
  mutate(total_faecal_deposition_km = faecal_dw_g * deposition_rate * grazing_time * density_km, # faecal deposition in g DW/year
         seasonnal_faecal_deposition_km = faecal_dw_g * deposition_rate * density_km * growing_season/3,
         total_N_km = seasonnal_faecal_deposition_km * mean_N/1000, # in kg
         total_P_km = seasonnal_faecal_deposition_km * mean_P/1000,
         total_C_km = seasonnal_faecal_deposition_km * mean_C/1000
  ) %>% 
  dplyr::select(- pile_ww, - sample_ww, - sample_dw, - sample_wc)

####------------------------------------------------------------------------####
#### PLOTING THE RESULTS
####------------------------------------------------------------------------####

# plot the annual faecal deposition from herbivores
plot_faecal_deposition <- summary_pellet_weight %>% 
  mutate(herbivore = paste0(toupper(substring(herbivore, 1, 1)), tolower(substring(herbivore, 2)))) %>% # Capitalised the first letter 
  # compute the 95 confidence interval
  group_by(herbivore) %>% 
  summarize(
    mean_value = mean(total_faecal_deposition_km, na.rm = TRUE),
    se_value = sd(total_faecal_deposition_km, na.rm = TRUE) / sqrt(n()),
    .groups = 'drop'
  ) %>%
   mutate(
    # compute the lower bound of the 95 confidence interval
    ymin = mean_value - 1.96 * se_value, 
    # compute the upper bound of the 95 confidence interval
    ymax = mean_value + 1.96 * se_value  
  ) %>% 
  ungroup() %>% 
  ggplot(aes(x = herbivore, y = mean_value)) +
  # plot using barplot
  geom_bar(stat = "identity", position = "dodge") + 
  # add the 95 confidence interval
  geom_errorbar(                                    
    aes(ymin = mean_value, 
        ymax = ymax),  
    position = position_dodge(0.9),
    width = 0.5
  ) +
  labs(title = "", # Title and Labelling
       x = "",
       y = expression("Yearly faecal excretion (in Kg.km"^-2*")") #".year"^-1*
       ) +
  guides(color = "none") +  # Remove color legend                       
  theme_perso() + # aesthetic
  # Manually insert line breaks in the x-axis labels
  scale_x_discrete(labels = function(x) str_wrap(x, width = 3)) 


nutrient_contribution <- summary_pellet_weight %>% 
  mutate(herbivore = paste0(toupper(substring(herbivore, 1, 1)), tolower(substring(herbivore, 2)))) %>% # Capitalized the first letter 
  rename("Total N" = "total_N_km", "Total P" = "total_P_km", "Total C"= "total_C_km") %>% 
  pivot_longer(cols = c("Total N", "Total P", "Total C"), names_to = "nutrient", values_to = "value") %>% # prepare the data for plotting
  # compute the 95 confidence interval
  group_by(herbivore, session, nutrient) %>% 
  summarize(
    mean_value = mean(value, na.rm = TRUE),
    se_value = sd(value, na.rm = TRUE) / sqrt(n()),
    .groups = 'drop'
  ) %>%
  mutate(
    # compute the lower bound of the 95 confidence interval
    ymin = mean_value - 1.96 * se_value, 
    # compute the upper bound of the 95 confidence interval
    ymax = mean_value + 1.96 * se_value) %>% 
  ungroup() %>% 
  group_by(herbivore, nutrient) %>% 
  summarise(sum = sum(mean_value, na.rm = TRUE))


# plot the nutrient faecal deposition from herbivores throughout the growing season
plot_nutrient_contribution <- summary_pellet_weight %>% 
  mutate(herbivore = paste0(toupper(substring(herbivore, 1, 1)), tolower(substring(herbivore, 2)))) %>% # Capitalized the first letter 
  rename("Total N" = "total_N_km", "Total P" = "total_P_km", "Total C"= "total_C_km") %>% 
  pivot_longer(cols = c("Total N", "Total P", "Total C"), names_to = "nutrient", values_to = "value") %>% # prepare the data for plotting
  # compute the 95 confidence interval
  group_by(herbivore, session, nutrient) %>% 
  summarize(
    mean_value = mean(value, na.rm = TRUE),
    se_value = sd(value, na.rm = TRUE) / sqrt(n()),
    .groups = 'drop'
  ) %>%
  mutate(
    # compute the lower bound of the 95 confidence interval
    ymin = mean_value - 1.96 * se_value, 
    # compute the upper bound of the 95 confidence interval
    ymax = mean_value + 1.96 * se_value) %>% 
  ungroup() %>% 
  ggplot(aes(x = herbivore, y = mean_value, fill = session)) +
  # plot using barplot 
  geom_bar(stat = "identity", position = "dodge") + 
  # add the 95 confidence interval
  geom_errorbar(                                    
    aes(color = session,
      ymin = mean_value, 
      ymax = ymax),  
    position = position_dodge(0.9),
    width = 0.5
  ) +
  # separate by nutrient type and adjust the y-axis 
  facet_wrap(nutrient ~ ., scale = "free_y") +      
  labs(title = "", # Title and Labeling
       x = "",
       y = expression("Total excretion (in Kg.km"^-2*")"), #".year"^-1*
       fill = "Session") +
  guides(color = "none") +  # Remove color legend
  theme_perso() + # aesthetic
  # Manually insert line breaks in the x-axis labels
  scale_x_discrete(labels = function(x) str_wrap(x, width = 3)) + 
  theme(strip.background = element_blank(),   # Remove the strip background
  strip.text = element_text(size = 25)) +     # Increase the size of the facet label text
  scale_fill_manual(values = palette_session,                        
                    name = "Season",
                    label = c("Beginning", "Peak", "Late")) +
  scale_color_manual(values = palette_session,                        
                    name = "Season")

print(plot_nutrient_contribution)

####------------------------------------------------------------------------####
#### SAVING RESULTS AND FORMATING DATA
####------------------------------------------------------------------------####

# plot

ggsave("./figures/plot_nutrient_contribution.png", 
       plot_nutrient_contribution, width = 20, height = 10)

# Save the plot as an SVG file

ggsave("./figures/plot_nutrient_contribution.svg", 
       plot_nutrient_contribution, 
       width = 20, height = 12,
       device = "svg")

# data

colnames(summary_pellet_weight)

data_deposition <- summary_pellet_weight %>% 
  dplyr::select("herbivore", "faecal_dw_g", "deposition_rate", "grazing_time", "population", "density_km", "weight_kg", "mb") %>% 
  group_by(herbivore) %>% 
  summarize(mean_faecal_dw_g = round(mean(faecal_dw_g, na.rm = TRUE), 2),
    sd_faecal_dw_g = round(sd(unique(faecal_dw_g)), 2), 
    mean_deposition_rate = round(mean(deposition_rate, na.rm = TRUE), 2),
    sd_deposition_rate = round(sd(deposition_rate)),
    grazing_time = round(mean(grazing_time), 2),
    density = round(mean(density_km), 2),
    population = round(mean(population), 2),
    weight_kg = mean(weight_kg),
    mb = mean(mb)
    ) %>% 
  mutate(herbivore = paste0(toupper(substring(herbivore, 1, 1)), tolower(substring(herbivore, 2)))) %>% 
  mutate("Faeces weight (g DW)" = paste0(mean_faecal_dw_g, " ± ", sd_faecal_dw_g),
         "Deposition rate (/days)" = paste0(mean_deposition_rate, " ± ", sd_deposition_rate)) %>% 
  dplyr::select(Herbivore = herbivore, "Faeces weight (g DW)", "Deposition rate (/days)", 
                "Grazing time (days)" = grazing_time, "Population" = population, 
                "Density (ind.km-1)" = density,
                "body weight (kg)" = weight_kg,
                "Yearly metabolic biomass (kg.km-1)" = mb) %>% 
  mutate_all(as.character) %>% 
  pivot_longer(cols = - Herbivore, names_to = "Parameters", values_to = "Values") %>%  # Gather the parameters into a long format
  pivot_wider(names_from = Herbivore, values_from = Values)  # Pivot to create Herbivore columns

#fwrite(data_deposition, 
#       file = "./figures/tables/summary_all/data_deposition.csv", sep = ";")
    