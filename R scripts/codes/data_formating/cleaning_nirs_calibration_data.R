################################################################################
#                       FAECAL DATA NIRS CALIBRATION
#                           Mathilde Defourneaux
#                               Jan 23, 2023
################################################################################

# Chapter 2 - Assessing herbivore faecal nutrient content using NIRS 
# contact Mathilde Defourneaux (mathilde@lbhi.is) for more information

# Combined spectral data and wet laboratory nutrient analasis for NIRS model calibration
# here protocole description
# data formating, and cleaning

####------------------------------------------------------------------------####
#### SETUP
####------------------------------------------------------------------------####

set.seed(132)

## ---- library

source("./code/setup.R")

# load data
faecal_nut_lab <- fread(file = "./data/24-10-2024_faecal_nutrient_wet_lab.txt", sep = ";", header = T) # nutrient estimates from wet laboratory analysis
source("./code/data_formating/cleaning_spectral_data.R") # NIRS spectral data

####------------------------------------------------------------------------####
#### ERRORS AND CLEANING
####------------------------------------------------------------------------####

# check errors in observation id, duplicates

duplicates <- faecal_nut_lab[duplicated(faecal_nut_lab$id) | duplicated(
  faecal_nut_lab$id, fromLast = TRUE), ]
print(duplicates) # Print the duplicate IDs
faecal_nut_lab <- filter(faecal_nut_lab, !id %in% duplicates) # and remove them

# see how many common observations --> there should be 194
length(intersect(faecal_nut_lab$id, nirs$id))  # 187 observations in common

# What are the observation in faecal_nut_lab that spectre_mean doesn't have?

missing <- setdiff(faecal_nut_lab$id, nirs$id)
filter(faecal_nut_lab, id %in% missing)

####------------------------------------------------------------------------####
#### FULL DATASET
####------------------------------------------------------------------------####

data_model <- nirs %>% 
  left_join(faecal_nut_lab, by = "id") %>% # merging spectral data and wet laboratory data
  relocate(any_of(c("herbivore", "age", "session", "N", "P", "C", "comment")), .after = id) %>% 
  drop_na(herbivore)
  #drop_na(C)

dim(data_model)
head(data_model[, 1:8])
tail(data_model[, 1:8])

#### -------------------------------------------------------------------------------------- ####
#### INSPECT DATASET AND EVALUATE OUTLIERS
#### -------------------------------------------------------------------------------------- ####

## Mahalanobis distance
mah_var <- mahalanobis(data_model$Spectra, 
                     center = colMeans(data_model$Spectra), 
                     cov = cov(data_model$Spectra), 
                     tol = 1e-55)

cutoff <- qchisq(0.975, 2151)
plot(mah_var)
abline(h = cutoff)

plot(density(mah_var, bw = 0.5),
     main="Squared Mahalanobis distances") ; rug(mah_var)

qqplot(qchisq(ppoints(100), df = 3), mah_var,
       main = expression("Q-Q plot of Mahalanobis" * ~D^2 *
                           " vs. quantiles of" * ~ chi[3]^2))
abline(0, 1, col = 'gray')

data_model$id[mah_var<(-1000)]
data_model$id[mah_var>(2000)]
# removing 12 samples

data_model <- data_model[!(mah_var < (- 1000) | mah_var > 2000), ]  #take out outliers
dim(data_model) #189 samples left

## PCA

pca <- prcomp(data_model$Spectra)  #outliers in all samples
plot(pca$x[,1:2], pch = 21, bg = as.factor(data_model$herbivore))
legend("topright", legend = levels(as.factor(data_model$herbivore)), pch = 21, pt.bg = c(1, 2, 3, 4, 5, 6), bt = "n")

plot(pca$x[,1:2], col = "white")
text(pca$x[,1:2], labels = data_model$id, cex = 0.7)

data_model <- filter(data_model, !id %in% c("22-201-A-R23", "22-201-A-R7", 
                                "22-198-B-Sl1"))  # remove outlier
dim(data_model) # 187 samples left

# remove duplicate id and error

duplicates <- data_model[duplicated(data_model$id) | duplicated(
  data_model$id, fromLast = TRUE), ]
# Print the duplicate IDs
print(duplicates$id)
data_model <- filter(data_model, !id %in% duplicates$id)
dim(data_model) # 181 samples left

####------------------------------------------------------------------------####
#### REMOVE TEMPORARY OBJECTS
####------------------------------------------------------------------------####

rm(faecal_nut_lab,
   duplicates, nirs, pca)

####------------------------------------------------------------------------####
#### TO SAVE THE CLEANED AND FORMATED DATA
####------------------------------------------------------------------------####

#fwrite(data_model, 
#      file="./data/2-labdata/data_model.txt", 
#     col.names = TRUE, sep =";")

### THE END