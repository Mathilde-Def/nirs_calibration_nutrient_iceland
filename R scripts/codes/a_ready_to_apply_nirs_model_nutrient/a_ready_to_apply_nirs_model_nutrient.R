################################################################################
#
#            PREDICTING FAECAL NUTRIENT CONTENT MODEL USING NIRS MODELS
#
################################################################################

# last update: Oct 25, 2024

## This script is used to predict nitrogen concentration in faecal material
## scanned with NIRS. 

## Full description of the calibration can be read in :
# Capturing seasonal variations in faecal nutrient content from tundra 
# herbivores using Near Infrared Reflectance Spectroscopy 
# here the DOI of the publication
# 2024

## The model is developed  with samples from Iceland.

## Samples are presented as tablets, dried at 40°C for 3 hours 
# and cooled down in a desiccator
## Thereafter samples are scanned with NIRS 

# A FieldSpec 4 was used to scan the samples, with a spectral range of 350-2500nm, 
# with a sampling interval of 1.4 nm in the 350-1000 nm range 
# and 2 nm in the 1000-2500 nm range

## Model developed with Log 1/R spectra, values measured in % Dry Weight

## The models are saved in a file "nirs_faecal_N_model2024.rda", 
# nirs_faecal_C_model2024.rda" and "nirs_faecal_P_model2024.rda"

## Model specifications
# nutrient    R2cal   RMSECV  R2val   RMSEP   Bias   Intercept  Slope
#       N     0.83     0.25    0.88    0.21   -0.03    -0.36     1.15
#       P     0.63     0.13    0.76    0.12    0.02     0.14     0.71    
#       C     0.92     0.91    0.90    0.55   -0.15     6.53     0.85     

# Contact person: 
# Mathilde Defourneaux(mathilde@lbhi.is) 

#### -----------------------------------------------------------------------####
#### SETUP
#### -----------------------------------------------------------------------####

## load libraries
source("./code/setup.R")

# SCRIPTS OPTIONS --------------------------------------------------------------
# not in
`%notin%` <- Negate(`%in%`)

## LOAD DATA -------------------------------------------------------------------

# data set
source("./code/data_formating/cleaning_spectral_data.R") #spectral data

# models

load("./code/a_ready_to_apply_nirs_model_nutrient/nirs_faecal_N_model2024.rda")
load("./code/a_ready_to_apply_nirs_model_nutrient/nirs_faecal_C_model2024.rda")
load("./code/a_ready_to_apply_nirs_model_nutrient/nirs_faecal_P_model2024.rda")

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
