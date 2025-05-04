# 03_model_calibration – Predicting Faecal Nutrient Content from NIRS Data
This folder contains R scripts used to calibrate both monospecific and multispecies near-infrared reflectance spectroscopy (NIRS) models to predict faecal carbon (C), nitrogen (N), and phosphorus (P) content (% dry weight) from herbivores in the Icelandic tundra.

## Overview
This subdirectory includes scripts to develop and evaluate calibration models using paired lab reference data and faecal spectral data:

- `calibration_C.R` – Calibration of carbon model  
- `calibration_N.R` – Calibration of nitrogen model  
- `calibration_P.R` – Calibration of phosphorus model  

Each script includes:
- **Monospecific models** (separate models for pink-footed goose, sheep, and reindeer)  
- **Mammal-only model** (combined reindeer and sheep data)  
- **General multispecies model** (all three herbivore species)

The final multispecies models for C, N, and P prediction were selected for deployment and are stored in the `01_prediction_model/` folder. These models are saved as `.rda` files:
- `nirs_faecal_C_model2024.rda`  
- `nirs_faecal_N_model2024.rda`  
- `nirs_faecal_P_model2024.rda`

These can be directly used for prediction with new spectral data.

## Sample Collection & Spectral Data
Faecal samples were collected from pink-footed goose, reindeer, and sheep during the 2022 growing season in the Eastern Highlands of Iceland (65.3234°N, 15.3062°E), across three seasonal periods: early, peak, and late.

Sample preparation and scanning details:
- Faeces were dried at 40°C, milled, and pressed into 15 mm tablets under 4 tons of pressure.
- Tablets were re-dried and stored in a desiccator before scanning.
- Spectral data were recorded using a **FieldSpec 4** spectrometer, with:
  - 1.4 nm resolution between 350–1000 nm  
  - 2 nm resolution between 1000–2500 nm

Wet chemistry methods:
- **Carbon (C)** and **Nitrogen (N)** measured using a Flash 2000 CN analyser  
- **Phosphorus (P)** determined via acid digestion and colorimetric analysis  

Models were calibrated using log(1/R) spectral values and nutrient concentrations in % dry weight.

## Usage Notes
- Scripts require input data pre-processed via `02_data_preprocessing/`.
- Model calibration and validation steps are detailed in `.R scripts/functions/calibration_nirs.R`.
- These models are calibrated under specific ecological and biological conditions. Extrapolation beyond the original dataset should be approached with caution.

## Contact

For questions about model calibration or dataset usage, please contact:
**Mathilde Defourneaux** – mathilde@lbhi.is  
**Isabel C. Barrio** – isabel@lbhi.is

## Reference
Defourneaux, M., Barbero-Palacios, L., Schoelynck, J., Boulanger-Lapointe, N., Speed, J.D.M., Barrio, I.C. (2025). *Capturing seasonal variations in faecal nutrient content from tundra herbivores using Near Infrared Reflectance Spectroscopy*. *Science of the Total Environment* (in press).  
