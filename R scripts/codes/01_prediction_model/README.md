# 01_prediction_model

This folder contains a ready-to-use prediction model for estimating C, N, and P in herbivore faecal samples using NIRS spectral data.

## Overview

- `a_ready_to_apply_nirs_model_nutrient.R`: Main script to apply the prediction models to new spectral data.
- `nirs_faecal_C_model2024.rda`: Final multispecies model to predict carbon (% dry weight).
- `nirs_faecal_N_model2024.rda`: Final multispecies model to predict nitrogen (% dry weight).
- `nirs_faecal_P_model2024.rda`: Final multispecies model to predict phosphorus (% dry weight).

## Sample Collection & Spectral Data
Prediction models trained on samples collected from pink-footed goose, reindeer, and sheep during the 2022 growing season in the Eastern Highlands of Iceland (65.3234°N, 15.3062°E), across three seasonal periods: early, peak, and late.

Sample preparation and scanning details:
- Faeces were dried at 40°C, milled, and pressed into 15 mm tablets under 4 tons of pressure.
- Tablets were re-dried and stored in a desiccator before scanning.
- Spectral data were recorded using a **FieldSpec 4** spectrometer, with:
  - 1.4 nm resolution between 350–1000 nm  
  - 2 nm resolution between 1000–2500 nm

## Usage Notes
- Scripts require input data pre-processed via `02_data_preprocessing/cleaning_spectral_data.R`.
- The **input data** must be structured as follows:
  - **Rows**: Each row corresponds to a single faecal sample.
  - **Columns**:
    - `id`: A unique identifier for each sample (e.g., "22-083-A-G1", "22-106-A-G1").
    - `Spectra`: A matrix containing spectral data with 2151 columns representing the spectral wavelengths from 1100-2450 nm, in **log(1/R)**.
  - Example input format:
    ```
    id             Spectra
    22-083-A-G1    <matrix[30 x 2151]>
    22-106-A-G1    <matrix[30 x 2151]>
    ...
    ```
- predicted nutrient concentrations are presented in % dry weight.
- The R script `a_ready_to_apply_nirs_model_nutrient.R` loads the R object, and contains instructions on how to proceed with the prediction. 
- These models are calibrated under specific ecological and biological conditions. Extrapolation beyond the original dataset should be approached with caution.

## Contact
Specific questions about the dataset and models can be addressed to
**Mathilde Defourneaux** – mathilde@lbhi.is  
**Isabel C. Barrio** – isabel@lbhi.is

## Reference
Defourneaux, M., Barbero-Palacios, L., Schoelynck, J., Boulanger-Lapointe, N., Speed, J.D.M., Barrio, I.C. (2025). *Capturing seasonal variations in faecal nutrient content from tundra herbivores using Near Infrared Reflectance Spectroscopy*. *Science of the Total Environment* (in press).  

