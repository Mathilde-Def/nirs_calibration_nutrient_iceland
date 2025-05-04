################################################################################
#
#            PREDICTING FAECAL NUTRIENT CONTENT MODEL USING NIRS MODELS
#
################################################################################

# Last update: October 25, 2024

# This script is designed to predict the nutrient content (Nitrogen, Phosphorus, 
# and Carbon) of herbivore faeces based on Near-Infrared Reflectance Spectroscopy 
# (NIRS) models developed using samples from Iceland. The models predict nutrient 
# content based on spectral data scanned from dried faecal tablets. The predictions 
# are made for three nutrients: nitrogen (N), phosphorus (P), and carbon (C), and 
# are expressed as percentages of dry weight.

# Key Information:
# - Calibration Model: Developed from herbivore faecal samples collected from Iceland, 
#   scanned with a FieldSpec 4 spectrometer.
# - Spectral Range: 350–2500 nm, with a sampling interval of:
#     - 1.4 nm (350-1000 nm)
#     - 2 nm (1000-2500 nm)
# - Sample Preparation:
#     - Samples were presented as tablets, dried at 40°C for 3 hours, and then cooled 
#       down in a desiccator.
#
## Model specifications
# nutrient    R2cal   RMSECV  R2val   RMSEP   Bias   Intercept  Slope
#       N     0.83     0.25    0.88    0.21   -0.03    -0.36     1.15
#       P     0.63     0.13    0.76    0.12    0.02     0.14     0.71    
#       C     0.92     0.91    0.90    0.55   -0.15     6.53     0.85     

# Models and Files:
# - The models developed for predicting nutrient content are saved as:
#     - `nirs_faecal_N_model2024.rda` (Nitrogen model)
#     - `nirs_faecal_C_model2024.rda` (Carbon model)
#     - `nirs_faecal_P_model2024.rda` (Phosphorus model)

# Contact:
# For more details on the dataset and models, contact Mathilde Defourneaux at mathilde@lbhi.is.

# Reference:
# Defourneaux, M., Barbero-Palacios, L., Schoelynck, J., Boulanger-Lapointe, N., 
# Speed, J.D.M., Barrio, I.C., 2025. "Capturing seasonal variations in faecal nutrient 
# content from tundra herbivores using Near Infrared Reflectance Spectroscopy." 
# *Science of the Total Environment* (in press).

#### -----------------------------------------------------------------------####
#### SETUP
#### -----------------------------------------------------------------------####

## load libraries
source("./R scripts/codes/setup.R")

# SCRIPTS OPTIONS --------------------------------------------------------------
# not in
`%notin%` <- Negate(`%in%`)

## LOAD DATA -------------------------------------------------------------------

# data set
source("./R scripts/codes/02_data_preprocessing/cleaning_spectral_data.R") # NIRS spectral data

# models

load("./R scripts/codes/01_prediction_model/nirs_faecal_N_model2024.rda")
load("./R scripts/codes/01_prediction_model/nirs_faecal_C_model2024.rda")
load("./R scripts/codes/01_prediction_model/nirs_faecal_P_model2024.rda")

####------------------------------------------------------------------------####
#### FORMATTING DATA
####------------------------------------------------------------------------####

# NOTE:
# The script `cleaning_spectral_data.R` (located in "./R scripts/codes/02_data_preprocessing/")
# automates all pre-processing steps: formatting, outline detection, and cleaning.
# Use the manual code below only if you wish to directly apply the models

## Load your raw spectral data
# Replace `"your_data.txt"` with the path to your file
# nirs <- fread("your_data.txt", sep = ";", header = TRUE)

## Format the spectral data
# Convert the reflectance data into a matrix and store it in a new dataframe
# nirs <- data.frame(id = spectre_mean$id)
# nirs$Spectra <- as.matrix(spectre_mean[2:2152])  # assumes spectral data starts at column 2
# glimpse(nirs)  # optional: inspect the structure

## Apply splice correction (optional but recommended)
# This corrects discontinuities between detector ranges (typically at 1000 nm and 1800 nm)
# nirs$Spectra <- spliceCorrection(
#   nirs$Spectra,
#   wavelengths = 350:2500,
#   splice = c(1000, 1830),
#   interpol.bands = 5
# )

## Trim spectral range to selected NIR window
# Keep only wavelengths between `start_wave` and `end_wave`
# start_wave <- 1100
# end_wave <- 2450
# nirs$Spectra <- nirs$Spectra[, grep(start_wave, colnames(nirs$Spectra))[1] :
#                                  grep(end_wave, colnames(nirs$Spectra))[1]]

# dim(nirs$Spectra)  # optional: check dimensions of the trimmed matrix


####------------------------------------------------------------------------####
#### PREDICT NUTRIENT CONCENTATIONS USING THE MODELS
####------------------------------------------------------------------------####

# change potential matrix shape data to vectors
flatten_array <- function(x) {
  if (is.array(x)) {
    return(as.vector(x))
  } else {
    return(x)
  }
}

# predict nutrient content from input spectral data
predicted_nutrients <- as.data.frame(nirs$id) %>% 
  mutate("N" =  unlist(predict(nirs_faecal_N_model2024, 
                          newdata = nirs, 
                          ncomp = nirs_faecal_N_model2024[["ncomp"]])),
         "P" = unlist(predict(nirs_faecal_P_model2024, 
                           newdata = nirs, 
                           ncomp = nirs_faecal_P_model2024[["ncomp"]])),
         "C" = unlist(predict(nirs_faecal_C_model2024, 
                           newdata = nirs, 
                           ncomp = nirs_faecal_C_model2024[["ncomp"]]))
         ) %>%
  rename(id = "nirs$id")

# Flatten nested arrays
predicted_nutrients <- predicted_nutrients %>%
  mutate(across(everything(), flatten_array))

#colnames(predicted_nutrients) <- c("id", "N", "P", "C")

## Finally we write the file as txt into your working directory (WD)
# If you are uncertain about which your WD is, type getwd() in the console
# Add the file path to the "file=" argument if you want to save in a folder that is not the WD (e.g. file="C:/Users/User1/Desktop/Predicted N (%DW).txt")

####------------------------------------------------------------------------####
#### REMOVE TEMPORARY OBJECTS
####------------------------------------------------------------------------####

rm(nirs_faecal_C_model2024, nirs_faecal_N_model2024,
   nirs_faecal_P_model2024, nirs)
