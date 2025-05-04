# 02_data Preprocessing

This folder contains R scripts used for preprocessing spectral and calibration data in preparation for model calibration and prediction. 

## Overview
This folder includes the following scripts:

- `cleaning_nirs_calibration_data.R`: This script combines spectral data with wet lab data used in the model calibration contained in `03_model_calibration' folder
- `cleaning_spectral_data.R`: This script pre-processes the spectral data, apply transformation (i.e. splice correction), select the proper wavelenght and detects outliers.
- `function_convert_asd_to_txt.R`: This function converts spectral data from ASD to a usable single `.txt` format and applies a log transformation (log(1/R)) to the spectral data.

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

## Contact
For questions about the preprocessing scripts or data handling, please contact:

**Mathilde Defourneaux** – mathilde@lbhi.is  
**Isabel C. Barrio** – isabel@lbhi.is

## Reference
Defourneaux, M., Barbero-Palacios, L., Schoelynck, J., Boulanger-Lapointe, N., Speed, J.D.M., Barrio, I.C. (2025). *Capturing seasonal variations in faecal nutrient content from tundra herbivores using Near Infrared Reflectance Spectroscopy*. *Science of the Total Environment* (in press).
