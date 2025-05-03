# NIRS Prediction Model – Faecal Nutrients

This folder contains a ready-to-use prediction model for estimating C, N, and P in herbivore faecal samples using NIRS spectral data.

## Contents

- `Prediction_script.R`: Main script to apply the model to new spectral data.
- `C_Prediction_model.rda`, `N_Prediction_model.rda`, `P_Prediction_model.rda`: Pre-trained models for each nutrient.
- `Test_dataset.txt`: Example dataset with spectral data to validate the model.

## How to Use

1. Load the `Prediction_script.R` in R.
2. The script will load the `.rda` model files automatically.
3. Run the script to generate predictions on the example dataset.

### Test Dataset Structure

- Column `Wavelength`: Unique sample ID assigned during scanning.
- Columns `X350` to `X2500`: Spectral data in log(1/R) format.
- Column `X`: Empty column to be removed during preprocessing.
