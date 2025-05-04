# 02_data Preprocessing

This folder contains R scripts used for preprocessing spectral and calibration data in preparation for model calibration and prediction. 

## Overview
This folder includes the following scripts:

- `cleaning_nirs_calibration_data.R`: This script combines spectral data with wet lab data used in the model calibration contained in `03_model_calibration' folder
- `cleaning_spectral_data.R`: This script pre-processes the spectral data, apply transformation (i.e. splice correction), select the proper wavelenght and detects outliers.
- `function_convert_asd_to_txt.R`: This function converts spectral data from ASD to a usable single `.txt` format and applies a log transformation (log(1/R)) to the spectral data.

## Contact
For questions about the preprocessing scripts or data handling, please contact:

**Mathilde Defourneaux** – mathilde@lbhi.is  
**Isabel C. Barrio** – isabel@lbhi.is

## Reference
Defourneaux, M., Barbero-Palacios, L., Schoelynck, J., Boulanger-Lapointe, N., Speed, J.D.M., Barrio, I.C. (2025). *Capturing seasonal variations in faecal nutrient content from tundra herbivores using Near Infrared Reflectance Spectroscopy*. *Science of the Total Environment* (in press).
