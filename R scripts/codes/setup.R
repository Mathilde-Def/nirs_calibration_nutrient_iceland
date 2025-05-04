################################################################################
#                ATTACH LIBRARY; CREATE DIRRECTORY, SET PATHS 
#                           Mathilde Defourneaux
#                               Fev 07, 2024
################################################################################

# Chapter 2 - Assessing Icelandic tundra herbivore faecal nutrient faecal 
# nutrient contribution accross the growing season  
# contact Mathilde Defourneaux (mathilde@lbhi.is) for more information

# for libraries that are not installed, run install.packages("[packagename]")

# Function to install and load libraries
install_load_library <- function(libs) {
  for (lib in libs) {
    if (!requireNamespace(lib, quietly = TRUE)) {
      install.packages(lib, dependencies = TRUE)
    }
    library(lib, character.only = TRUE)
  }
}

# List of libraries

# to install the master branch version of spectratrait 
# make sure that all packages are up to date at this stage
# devtools::install_github(repo = "TESTgroup-BNL/spectratrait", dependencies=TRUE)

libs <- c("tidyverse", # data wrangling, manipulation
          "data.table", # saving and loading data
          "broom", # summarise models
          "lubridate", # handle dates
          "spectratrait", # spectral data manipulation -derivatives, smoothing,...-
          "prospectr", 
          "ggplot2", # data plotting and visualization
          "ggimage", # support library for plotting
          "gridExtra", # support library for plotting
          "ggpubr", # support library for plotting
          "ggrepel", # support library for plotting
          "png", # support library for plotting
          "grid", # support library for plotting
          "plotrix", # Specialized plots and plotting accessories
          "pls", # partial least regression square analysis
          "mgcv", # NMDS
          "vegan", # NMDS
          "MASS", #NMDS
          "emmeans", # multiple pairwise comparison
          "multcomp",
          "lme4") # ANOVA

# Install and load libraries
install_load_library(libs)

# to install the master branch version of spectratrait 
# make sure that all packages are up to date at this stage
# devtools::install_github(repo = "TESTgroup-BNL/spectratrait", dependencies=TRUE)

# Script options
pls::pls.options(plsralg = "oscorespls")
pls::pls.options("plsralg")

# Create a 'figures' folder if it doesn't exist
figures_path <- file.path(getwd(), "figures")
if (!dir.exists(figures_path)) {
  dir.create(figures_path)
}

# Create subfolders inside 'figures'
subfolders <- c("nirs_data", "pls_model", "tables")

# Loop through the subfolder names and create them
for (folder in subfolders) {
  folder_path <- file.path(figures_path, folder)
  if (!dir.exists(folder_path)) {
    dir.create(folder_path)
  }
}
