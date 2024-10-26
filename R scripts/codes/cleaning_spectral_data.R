################################################################################
#
#                     CLEANING AND FORMATING SPECTRAL DATA
#
################################################################################

# last update: OCt 25, 2024

## This script is format and clean NIRS spectral data 

## Full description of the methods can be read in :
# Capturing seasonal variations in faecal nutrient content from tundra 
# herbivores using Near Infrared Reflectance Spectroscopy 
# here the DOI of the publication
# 2024

## The spectral data are from fresh faecal samples from herbivores in 
# Iceland 

## Samples are presented as tablets, dried at 40°C for 3 hours 
# and cooled down in a desiccator
## Thereafter samples are scanned with NIRS 

#A FieldSpec 4 was used to scan the samples, with a spectral range of 350-2500nm, 
# with a sampling interval of 1.4 nm in the 350-1000 nm range 
# and 2 nm in the 1000-2500 nm range

# contact Mathilde Defourneaux (mathilde@lbhi.is) for more information

####------------------------------------------------------------------------####
#### SETUP
####------------------------------------------------------------------------####

set.seed(132)

## ---- library
source("./code/setup.R")

# not in
`%notin%` <- Negate(`%in%`)

# load data
data_spectra <- fread("./data/24-10-2024_dataset_dung_spectra_2022_log1R_final.txt", sep = ";", header = T)

# define wavelength --> NIR
start_wave <- 1100
end_wave <- 2450

####------------------------------------------------------------------------####
#### CLEANING THE DATA
####------------------------------------------------------------------------####

# structure of the dataset
colnames(data_spectra)
dim(data_spectra)
head(data_spectra[,1:10])
head(data_spectra[,2145:2152])

####------------------------------------------------------------------------####
#### TO BACK TRANSFORM THE SPECTRAL DATA
####------------------------------------------------------------------------####

## Back transfrom log10(1/R) to R
# nirs$Spectra <- 1/10^nirs$Spectra

####------------------------------------------------------------------------####
#### AVERAGING
####------------------------------------------------------------------------####

# averaging the spectra per sample

spectre_mean <- data_spectra %>% 
  group_by(id) %>% 
  summarise_all(mean)

dim(spectre_mean)

# check errors in observation id, duplicates

duplicates <- spectre_mean[duplicated(spectre_mean$id) | duplicated(
  spectre_mean$id, fromLast = TRUE), ]
# Print the duplicate IDs
print(duplicates) # no duplicates

#### -----------------------------------------------------------------------####
#### FORMATING AND CORRECTION
#### -----------------------------------------------------------------------####

dim(spectre_mean) #there is 2152 columns in the data set
head(spectre_mean[,1:10])
head(spectre_mean[,1349:1359])

## format data (Spectra as matrix in the dataframe)

nirs <- data.frame(id = spectre_mean$id)
nirs$Spectra <- as.matrix(spectre_mean[2:2152])
glimpse(nirs)

## apply Splice correction

# The splice correction eliminates the gaps in the signal between the
# domains of the different detector arrays. Critical transitions are located at 
# λ=1000nm and λ=1800nm. The objective of the splice correction is to compensate
# the difference between the reflectance R1000nm and R1001nm by adapting all values 
# from 1001nm upwards to the level of those to 1000nm.

nirs$Spectra <- spliceCorrection(nirs$Spectra, c(350:2500), splice = c(1000,1830), interpol.bands = 5)

## Cut off wavelength that shouldn't be included in the calibration (= out the NIR range)
nirs$Spectra <- nirs$Spectra[,grep(start_wave, colnames(nirs$Spectra))[1]:grep(end_wave, colnames(nirs$Spectra))[1]]
dim(nirs$Spectra)

## logtransform N
#nirs$N <- log(nirs$N)

#### -------------------------------------------------------------------------------------- ####
#### EVALUATING OUTLIERS 
#### -------------------------------------------------------------------------------------- ####

## plot all spectra

#plot_spectra(data = nirs$Spectra, xmin = start_wave, xmax = end_wave)

## Mahalanobis distance
mah_var<-mahalanobis(nirs$Spectra, 
                     center = colMeans(nirs$Spectra), 
                     cov = cov(nirs$Spectra), 
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

nirs$id[mah_var<(-10000)]
nirs$id[mah_var>(10000)]

# removing 4 samples; all goosling
nirs <- nirs[!(mah_var < (- 10000) | mah_var > 10000), ]  #take out outliers

dim(nirs) # 309 samples left

## PCA

pca <- prcomp(nirs$Spectra)  # outliers in all samples
plot(pca$x[,1:2], pch = 21)

plot(pca$x[,1:2], col = "white")
text(pca$x[,1:2], labels = nirs$id, cex = 0.7)

# remove duplicate id and error

duplicates <- nirs[duplicated(nirs$id) | duplicated(
  nirs$id, fromLast = TRUE), ]
# Print the duplicate IDs
print(duplicates$id)
nirs <- filter(nirs, !id %in% duplicates$id)
dim(nirs)

####------------------------------------------------------------------------####
#### REMOVE TEMPORARY OBJECTS
####------------------------------------------------------------------------####

rm(data_spectra,
   duplicates, 
   spectre_mean,
   pca
   )

####------------------------------------------------------------------------####
#### TO SAVE THE CLEANED AND FORMATED DATA
####------------------------------------------------------------------------####

#fwrite(nirs, 
#      file = "./data/cleaned_nirs_data.txt", 
#     col.names = TRUE, sep =";")

### THE END