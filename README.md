# NIRS calibration

This repository contains R scripts and resources used to analyse and predict faecal nutrient content from Icelandic tundra herbivores using near-infrared spectroscopy (NIRS). The workflow includes data preprocessing, model calibration, prediction, and statistical analysis of nutrient deposition across herbivore species and the growing season.

## Overview

This reference repository contains all necessary code and data to estimate carbon (C), nitrogen (N), and phosphorus (P) content (expressed as % dry weight) in faecal samples using near-infrared reflectance spectroscopy (NIRS).

### Sample Collection & Preparation

Faecal samples were collected in the Eastern Highlands of Iceland across three time points during the growing season (early, peak, and late). Samples were obtained from three tundra herbivore species: **sheep**, **reindeer**, and **pink-footed goose**.

Sample preparation steps:
- Fresh faeces were dried at 40ºC, milled and pressed into Ø15 mm tablets under 4 tons of pressure.
- Tablets were dried at 40ºC and stored in a desiccator before scanning.
- Spectral data were collected and paired with laboratory-measured nutrient concentrations for model calibration.

## Folder Structure

### `R script/`
Contains all relevant code, raw data, and custom functions.

#### `code/`
Contains a setup file to load require libraries used throughout the calibration, predictions and analysis
Organised into subfolders by step in the analysis pipeline:

- **`01_prediction_model/`**  
  Ready-to-use NIRS model for nutrient prediction. See folder-specific README for usage instructions.

- **`02_data_preprocessing/`**  
  Scripts for formatting and pre-processing spectral data, identifying outliers, and merging wet lab data for calibration.

- **`03_model_calibration/`**  
  Model calibration scripts for predicting C, N, and P using NIRS.

- **`04_faecal_analysis/`**  
  Statistical analysis scripts to assess nutrient variation by species and season, and estimate total deposition.

#### `functions/`
Reusable custom R functions used throughout the analysis.

#### `data/`
Original data files, including spectral measurements and wet lab data.

## Disclaimer

The end user of this dataset is expected to have basic knowledge of:
- R programming
- Near-infrared spectroscopy (NIRS)
- Data preprocessing
- Prediction model robustness and limitations
- Statistical interpretation of model outputs

Incorrect use of models or misinterpretation of results due to lack of expertise is the user’s responsibility.

## Contact

For questions about the dataset or models, please contact:

- **Mathilde Defourneaux** – mathilde@lbhi.is  
- **Isabel C. Barrio** – isabel@lbhi.is

## References

Defourneaux, M., Barbero-Palacios, L., Schoelynck, J., Boulanger-Lapointe, N., Speed, J.D.M., Barrio, I.C., 2025. Capturing seasonal variations in faecal nutrient content from tundra herbivores using Near Infrared Reflectance Spectroscopy. Science of the Total Environment. (in press)

