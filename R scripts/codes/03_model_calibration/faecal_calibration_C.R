################################################################################
#
#                NIRS MODEL CALIBRATION FOR FAECAL C CONTENT
#
################################################################################

# last update: Oct 25, 2024

# This script calibrates monospecific and multispecies NIRS models to predict 
# the faecal carbon (C) content of herbivores in the Icelandic tundra. The models 
# are developed using spectral data collected from faecal samples and lab-measured 
# nutrient concentrations.

## Data Source:
# - Samples were collected from herbivores (sheep, reindeer, pink-footed goose) 
#   in the Eastern Highlands of Iceland, during multiple time points in the growing season.

## Sample Preparation:
# - Faecal samples were dried at 40°C for 3 hours, then cooled in a desiccator.
# - Samples were then compressed into Ø15mm tablets under 4 tons of pressure before scanning.

## lab measurement:
# - N and C concentrations were measured using a Flash 2000 CN analyzer.
# - P concentration was determined via acid digestion and colorimetric 
#   methods.

## Spectral measurement:
# - A FieldSpec 4 spectrometer was used, covering a spectral range of 350-2500 nm.
# - The sampling interval was 1.4 nm in the 350-1000 nm range and 2 nm in the 1000-2500 nm range.

## Model Development:
# - The calibration model uses Log 1/R spectra, with nutrient content expressed as % dry weight.
# - Detailed steps for calibration and validation are contained in the function "calibration_nirs.R".
# - The final multispecies model is saved as "nirs_faecal_C_model2024.rda".

## Contact:
# Mathilde Defourneaux (mathilde@lbhi.is)

#### -----------------------------------------------------------------------####
#### SETUP
#### -----------------------------------------------------------------------####

## library

source("./R scripts/codes/setup.R")

## LOAD DATA -------------------------------------------------------------------

# data set
source("./R scripts/codes/02_data_preprocessing/cleaning_nirs_calibration_data.R")

## MODEL PARAMETERS ------------------------------------------------------------

# define the input variable to model
inVar <- "C"

## FUNCTIONS -------------------------------------------------------------------

source("./R scripts/functions/calibration_nirs.R") # function to calibrate the model
se <- function(x) sd(x)/sqrt(length(x))  # function for standard error

## PLOTS AESTHETICS ------------------------------------------------------------

source("./R scripts/functions/theme_perso.R") # function for personal plot theme

palette_herbivore <- c("#E57F84", "#5F9EA0", "#EBB261")
palette_session <- c("#d4e09b", "#797d62","#d08c60")

#### ---------------------------------------------------------------------- ####
#### INSPECT DATASET 
#### ---------------------------------------------------------------------- ####

## REFERENCE VALUES ------------------------------------------------------------

# removing NA in the input variable

contains_na <- any(is.na(data_model[,inVar]))
if (contains_na) {
  data_model <- drop_na(data_model[, inVar])
}
dim(data_model)

# statistics inVar

summary_inVar <- dplyr::summarise(data_model,
                                  min = min (data_model[, inVar]), 
                                  max = max(data_model[, inVar]),
                                  mean = mean(data_model[, inVar]),
                                  median = median(data_model[, inVar]),
                                  sd = sd(data_model[, inVar]),
                                  se = se(data_model[, inVar])) %>% 
  mutate(nutrient = paste0(inVar)) %>% 
  relocate(nutrient, .before = min)

summary_inVar

# plot inVar

qplot(data_model[,inVar],geom = "histogram",
      main = paste0("Histogram for ",inVar),
      xlab = paste0(inVar), ylab = "Count", fill = I("grey50"), col = I("black"),
      alpha = I(.7))

qplot(log(data_model[,inVar]),geom="histogram",
      main = paste0("Histogram for ",inVar),
      xlab = paste0(inVar), ylab = "Count", fill = I("grey50"), col = I("black"),
      alpha = I(.7))

#### -------------------------------------------------------------------------------------- ####
#### CREATE CALIBRATION AND VALIDATION DATASET
#### -------------------------------------------------------------------------------------- ####

# List of herbivores
herbivores <- unique(data_model$herbivore)

# Filter data_model for each herbivore and create a named list
nirs_herbivores <- map(setNames(herbivores, herbivores), ~ filter(data_model, herbivore == .x))

# Assign new names to the list
names(nirs_herbivores) <- c("geese", "sheep", "reindeer") 

# look into y outliers
boxplot(nirs_herbivores$geese[,inVar])
boxplot(nirs_herbivores$sheep[,inVar])
boxplot(nirs_herbivores$reindeer[,inVar])
#Remove 3 samples due to high influence in the model (Y-Outliers)
nirs_herbivores$reindeer <- filter(nirs_herbivores$reindeer, 
                                   !nirs_herbivores$reindeer[,inVar] < 35) 

map_dbl(nirs_herbivores, nrow) # nb of samples per species

# split the dataset into calibration (80%) and validation data (20%)
split_data <- function(data) {
  create_data_split(dataset = data,
                    approach = "base",
                    split_seed = 1234,
                    prop = 0.8,
                    group_variables = c("session"))
}

# Apply the function to each element of the list
nirs_herbivores_split <- map(nirs_herbivores, split_data)

# summarise the calibration and validation data
compute_summary <- function(df) {
  summarize(df,
            n = n(),
            min = round(min(df[, inVar]), 2),
            max = round(max(df[, inVar]), 2),
            mean = round(mean(df[, inVar]), 2),
            median = round(median(df[, inVar]), 2),
            sd = round(sd(df[, inVar]), 2),
            se = round(se(df[, inVar]), 2),
            cv = round(sd(df[, inVar]) / mean(df[, inVar]), 2))
}

summary_statistics <- map_dfr(nirs_herbivores_split, ~ map(.x, compute_summary), .id = "herbivore") %>% 
  mutate(nutrient = paste0(inVar)) %>% 
  relocate(nutrient, .before = herbivore)

summary_statistics_cal <- cbind(summary_statistics[1:2], summary_statistics$cal_data)
summary_statistics_val <- cbind(summary_statistics[1:2], summary_statistics$val_data)

### ----------------------------------------------------------------------------
### GEESE MODEL 
###-----------------------------------------------------------------------------

# apply calibration_nirs custom function
# iteration is the number of iteration to implement in the 
# boostraping during the validation process
geese_results <- calibration_nirs(nirs_herbivores_split$geese$cal_data, 
                                  nirs_herbivores_split$geese$val_data,inVar,
                                  iterations = 500, prop = 0.70)

# access results
geese_results$model_perf # model performance
geese_results$vips # variable of importance

## make residual plots
g_cal_resid_histogram <- 
  ggplot(geese_results$cal_plsr_output, aes(x = PLSR_CV_Residuals)) +
  geom_histogram(alpha = .5, position = "identity") + 
  geom_vline(xintercept = 0, color = "black", 
             linetype = "dashed", size = 1) + 
  theme_perso()

g_val_resid_histogram <- 
  ggplot(geese_results$val_plsr_output, aes(x = PLSR_Residuals)) +
  geom_histogram(alpha = .5, position = "identity") + 
  geom_vline(xintercept = 0, color = "black", 
             linetype = "dashed", size = 1) + 
  theme_perso()

(g_plot_nirs <- 
    ggarrange(g_cal_resid_histogram, g_val_resid_histogram,
              ncol = 2,
              common.legend = TRUE, 
              legend = "right"))

ggsave(paste0("./figures/pls_model/g_plot_nirs_results_", paste(inVar), ".svg"), 
       g_plot_nirs, 
       width = 12, height = 10)

### ----------------------------------------------------------------------------
#### SHEEP 
### ----------------------------------------------------------------------------

# apply calibration_nirs custom function
# iteration is the number of iteration to implement in the 
# boostraping during the validation process
sheep_results <- calibration_nirs(nirs_herbivores_split$sheep$cal_data, 
                                  nirs_herbivores_split$sheep$val_data, inVar,
                                  iterations = 500, prop = 0.70)

#access results
sheep_results$model_perf # model performance
sheep_results$vips # variable of importance

## make residual plots
s_cal_resid_histogram <- 
  ggplot(sheep_results$cal_plsr_output, aes(x = PLSR_CV_Residuals)) +
  geom_histogram(alpha = .5, position = "identity") + 
  geom_vline(xintercept = 0, color = "black", 
             linetype = "dashed", size = 1) + 
  theme_perso()

s_val_resid_histogram <- 
  ggplot(sheep_results$val_plsr_output, aes(x = PLSR_Residuals)) +
  geom_histogram(alpha = .5, position = "identity") + 
  geom_vline(xintercept = 0, color = "black", 
             linetype = "dashed", size = 1) + 
  theme_perso()

(s_plot_nirs <- 
    ggarrange(s_cal_resid_histogram,s_val_resid_histogram,
              ncol = 2,
              common.legend = TRUE, 
              legend = "right"))

ggsave(paste0("./figures/pls_model/s_plot_nirs_results_", paste(inVar), ".svg"),
       s_plot_nirs, 
       width = 12, height = 10)

### ----------------------------------------------------------------------------
### REINDEER 
### ----------------------------------------------------------------------------

# apply calibration_nirs custom function
# iteration is the number of iteration to implement in the 
# boostraping during the validation process
reindeer_results <- calibration_nirs(nirs_herbivores_split$reindeer$cal_data, 
                                     nirs_herbivores_split$reindeer$val_data, inVar,
                                     iterations = 500, prop = 0.70)

#access results
reindeer_results$model_perf # model performance
reindeer_results$vips # variable of importance

## make residual plots
r_cal_resid_histogram <- 
  ggplot(reindeer_results$cal_plsr_output, aes(x = PLSR_CV_Residuals)) +
  geom_histogram(alpha = .5, position = "identity") + 
  geom_vline(xintercept = 0, color = "black", 
             linetype = "dashed", size = 1) + 
  theme_perso()

r_val_resid_histogram <- 
  ggplot(reindeer_results$val_plsr_output, aes(x = PLSR_Residuals)) +
  geom_histogram(alpha = .5, position = "identity") + 
  geom_vline(xintercept = 0, color = "black", 
             linetype = "dashed", size = 1) + 
  theme_perso()

(r_plot_nirs <- 
    ggarrange(r_cal_resid_histogram,r_val_resid_histogram,
              ncol = 2,
              common.legend = TRUE, 
              legend = "right"))

ggsave(paste0("./figures/pls_model/r_plot_nirs_results_", paste(inVar), ".svg"),
       r_plot_nirs, 
       width = 12, height = 10)

#### ---------------------------------------------------------------------- ####
#### MAMMAL MODEL
#### ---------------------------------------------------------------------- ####

# combine the calibration data from sheep and reindeer
mammal_cal_data <- rbind(nirs_herbivores_split$sheep$cal_data, 
                         nirs_herbivores_split$reindeer$cal_data)
head(mammal_cal_data[, 1:8])
tail(mammal_cal_data[, 1:8])
dim(mammal_cal_data) # n = 100

# combine the validation data from sheep and reindeer
mammal_val_data <- rbind(nirs_herbivores_split$sheep$val_data, 
                         nirs_herbivores_split$reindeer$val_data)
head(mammal_val_data[, 1:8])
tail(mammal_val_data[, 1:8])
dim(mammal_val_data) # n = 26 

# summarise the calibration and validation data
mammal_cal_summary <- compute_summary(mammal_cal_data) %>% 
  mutate(herbivore = "reindeer + sheep", nutrient = paste0(inVar))
mammal_val_summary <- compute_summary(mammal_val_data) %>% 
  mutate(herbivore = "reindeer + sheep", nutrient = paste0(inVar)) 

# apply calibration_nirs custom function
# iteration is the number of iteration to implement in the 
# boostraping during the validation process
mammal_results <- calibration_nirs(mammal_cal_data, mammal_val_data, inVar,
                                   iterations = 500, prop = 0.70)

#access results
mammal_results$model_perf # model performance
mammal_results$vips # variable of importance

## make residual plots
m_cal_resid_histogram <- 
  ggplot(mammal_results$cal_plsr_output, aes(x = PLSR_CV_Residuals)) +
  geom_histogram(alpha = .5, position = "identity") + 
  geom_vline(xintercept = 0, color = "black", 
             linetype = "dashed", size = 1) + 
  theme_perso()

m_val_resid_histogram <- 
  ggplot(mammal_results$val_plsr_output, aes(x = PLSR_Residuals)) +
  geom_histogram(alpha = .5, position = "identity") + 
  geom_vline(xintercept = 0, color = "black", 
             linetype = "dashed", size = 1) + 
  theme_perso()

(m_plot_nirs <- 
    ggarrange(m_cal_resid_histogram, m_val_resid_histogram,
              ncol = 2,
              common.legend = TRUE, 
              legend = "right"))

ggsave(paste0("./figures/pls_model/m_plot_nirs_results_", paste(inVar), ".svg"),
       m_plot_nirs, 
       width = 12, height = 10)

#### ---------------------------------------------------------------------- ####
#### GENERAL MODEL
#### ---------------------------------------------------------------------- ####

# combine the calibration data from geese, reindeer and sheep
all_cal_data <- rbind(nirs_herbivores_split$geese$cal_data,
                      nirs_herbivores_split$sheep$cal_data,
                      nirs_herbivores_split$reindeer$cal_data)
head(all_cal_data[, 1:8])
tail(all_cal_data[, 1:8])
dim(all_cal_data) # n = 141

# summarise the calibration data
all_cal_summary <- compute_summary(all_cal_data) %>% 
  mutate(herbivore = "reindeer + sheep + geese", nutrient = paste0(inVar))

# combine the validation data from geese, reindeer and sheep
all_val_data <- rbind(nirs_herbivores_split$geese$val_data,
                      nirs_herbivores_split$sheep$val_data, 
                      nirs_herbivores_split$reindeer$val_data)
head(mammal_val_data[, 1:8])
tail(mammal_val_data[, 1:8])
dim(mammal_val_data) # n = 26 

# summarise the validation data
all_val_summary <- compute_summary(all_val_data) %>% 
  mutate(herbivore = "reindeer + sheep + geese", nutrient = paste0(inVar))

# compute model
all_results <- calibration_nirs(all_cal_data, all_val_data, inVar, 
                                iterations = 500, prop = 0.70)

#access results
all_results$model_perf # model performance
all_results$vips # variable of importance

## make residual plots
cal_resid_histogram <- 
  ggplot(all_results$cal_plsr_output, aes(x = PLSR_CV_Residuals)) +
  geom_histogram(alpha = .5, position = "identity") + 
  geom_vline(xintercept = 0, color = "black", 
             linetype = "dashed", size = 1) + 
  theme_perso()

val_resid_histogram <- 
  ggplot(all_results$val_plsr_output, aes(x = PLSR_Residuals)) +
  geom_histogram(alpha = .5, position = "identity") + 
  geom_vline(xintercept = 0, color = "black", 
             linetype = "dashed", size = 1) + 
  theme_perso()

(plot_nirs <- 
    ggarrange(cal_resid_histogram, val_resid_histogram,
              ncol = 2,
              common.legend = TRUE, 
              legend = "right"))

ggsave(paste0("./figures/pls_model/all_plot_nirs_results_", paste(inVar), ".svg"),
       plot_nirs, 
       width = 12, height = 10)

### ----------------------------------------------------------------------------
### Plot all results
### ----------------------------------------------------------------------------

# create a df which combine all model performance
perf_list <- list(
  geese_results = geese_results$model_perf,
  sheep_results = sheep_results$model_perf,
  reindeer_results = reindeer_results$model_perf,
  mammal_results = mammal_results$model_perf,
  all_results = all_results$model_perf
) %>% 
  # mapping and transforming each data frame in perf_list into one df
  # Source is a new column with the name of the model
  map_dfr(~ mutate(.x, Source = deparse(substitute(.x))), .id = "model") %>% 
  # cleaning up model names
  mutate(model = str_replace(model, "_results$", "")) 

# create a df which combine all calibration data from all models
# with the prediction from the model
results_cal <- list(
  geese_results = geese_results$cal_plsr_output,
  sheep_results = sheep_results$cal_plsr_output,
  reindeer_results = reindeer_results$cal_plsr_output,
  mammal_results = mammal_results$cal_plsr_output,
  all_results = all_results$cal_plsr_output
) %>% 
  # mapping and transforming each data frame in perf_list into one df
  # Source is a new column with the name of the model
  map_dfr(~ mutate(.x, Source = deparse(substitute(.x))), .id = "model") %>% 
  # cleaning up model names and transform into factor
  mutate(model = str_replace(model, "_results$", ""),
         model = factor(model, levels = c("geese", "sheep", "reindeer", "mammal", "all")))

levels(results_cal$model)  # should return the correct order: "geese" "sheep" "reindeer" "mammal" "all"

# scatter plot observed vs predicted data for all model
(plot_cal <- ggplot(results_cal, aes(x = C, y = PLSR_Predicted)) + 
  # custom made theme
  theme_perso() + 
  geom_point(aes(color = as.factor(session)), size = 5, alpha = 0.5) + 
  geom_smooth(size = 1, method = "lm", color = "#6A9C89") +
  # line if the correlation was perfect
  geom_abline(intercept = 0, slope = 1, color = "dark grey", linetype = "dashed", size = 1) +
  labs(y = paste0("Predicted C (%)"),
       x = paste0("Observed C (%)"),
       title = paste0("Calibration")) +
  facet_wrap(~ factor(model, levels = c("geese", "sheep", "reindeer", "mammal", "all")),
             nrow = 1) +
  scale_colour_manual(values = palette_session,
                      name = "Season",
                      labels = c("Beginning", "Peak", "End")) +
  geom_text(data = perf_list,  # use the data frame for geom_text
            aes(x = -Inf, y = Inf, 
                label = paste("R² =", cal_R2, "\nRMSEP =", cal_RMSEP)),
            hjust = -0.1, vjust = 2, size = 6, inherit.aes = FALSE) +
  theme(strip.text = element_text(size = 20),
        legend.position = "bottom"))  # Positioning the legend at the bottom

ggsave(paste0("./figures/pls_model/plot_cal_", paste(inVar), ".svg"),
       plot_cal, 
       width = 20, height = 6)
ggsave(paste0("./figures/pls_model/plot_cal_", paste(inVar), ".png"),
       plot_cal, 
       width = 20, height = 8)

# create a df which combine all validation data from all models
# with the prediction from the model
results_val <- list(
  geese_results = geese_results$val_plsr_output,
  sheep_results = sheep_results$val_plsr_output,
  reindeer_results = reindeer_results$val_plsr_output,
  mammal_results = mammal_results$val_plsr_output,
  all_results = all_results$val_plsr_output ) %>% 
  # mapping and transforming each data frame in perf_list into one df
  # Source is a new column with the name of the model
  map_dfr(~ mutate(.x, Source = deparse(substitute(.x))), .id = "model") %>%
  # cleaning up model names and transform into factor
  mutate(model = str_replace(model, "_results$", "")) %>% 
  mutate(factor(model, levels = c("geese", "sheep", "reindeer", "mammal", "all"))) 

# scatter plot observed vs predicted data for all model
(plot_val <- ggplot(results_val, aes(x = C, y = PLSR_Predicted)) + 
  theme_perso() + 
  geom_point(aes(color = as.factor(session)), size = 5, alpha = 0.5) + 
  geom_smooth(size = 1, method = "lm", color = "#6A9C89") +
  # add the 95 confidence interval from the boostrapping
  geom_errorbar(aes(ymin = LCI, ymax = UCI, color = as.factor(session)), width = 0.5, alpha = 0.7) +
  geom_abline(intercept = 0, slope = 1, color = "dark grey", linetype = "dashed", size = 1) +
  labs(y = paste0("Predicted C (%)"),
       x = paste0("Observed C (%)"),
       title = paste0("Validation")) +
  facet_wrap(~  factor(model, levels = c("geese", "sheep", "reindeer", "mammal", "all")),
             nrow = 1) +
  scale_colour_manual(values = palette_session,
                      name = "Season",
                      labels = c("Beginning", "Peak", "End")) +
  geom_text(data = perf_list,  # Use the data frame for geom_text
            aes(x = -Inf, y = Inf, 
                label = paste("R² =", val_R2, "\nRMSEP =", val_RMSEP)),
            hjust = -0.1, vjust = 2, size = 6, inherit.aes = FALSE) +
  theme(strip.text = element_text(size = 20),
        legend.position = "bottom"))  # Positioning the legend at the bottom

ggsave(paste0("./figures/pls_model/plot_val_", paste(inVar), ".png"),
       plot_val, 
       width = 20, height = 8)

ggsave(paste0("./figures/pls_model/plot_val_", paste(inVar), ".svg"),
       plot_val, 
       width = 20, height = 8)

#----------------------------------------------------------------------------###
### Save statistics summary
#----------------------------------------------------------------------------###

summary_statistics_cal <- rbind(summary_statistics_cal, mammal_cal_summary, all_cal_summary)
summary_statistics_val <- rbind(summary_statistics_val, mammal_val_summary, all_val_summary)

fwrite(summary_statistics_cal, 
       file = paste("./figures/tables/summary_statistics_cal_",inVar, ".txt"), sep = ";")

fwrite(summary_statistics_val, 
       file = paste("./figures/tables/summary_statistics_val_",inVar, ".txt"), sep = ";")

#----------------------------------------------------------------------------###
### Save model perf
#----------------------------------------------------------------------------###

model_herbivores <- c("geese", "sheep", "reindeer",
                      "reindeer + sheep", 
                      "reindeer + sheep + geese")

model_perfs <- rbind(geese_results$model_perf,
                     sheep_results$model_perf,
                     reindeer_results$model_perf,
                     mammal_results$model_perf, 
                     all_results$model_perf) %>% 
  cbind(model_herbivores) %>% 
  relocate(model_herbivores, .before = n_cal) %>% 
  mutate(nutrient = paste0(inVar), .before = model_herbivores)

fwrite(model_perfs, 
       file = paste("./figures/tables/model_perfs_",inVar, ".txt"), sep = ";")

#--------------------------------------------------------------------------------------------------#
### save model
#--------------------------------------------------------------------------------------------------#

nirs_faecal_C_model2024 <- all_results$model
#save(nirs_faecal_C_model2024, 
#     file = "./R scripts/codes/01_prediction_model/nirs_faecal_C_model2024.rda")  # save the model
