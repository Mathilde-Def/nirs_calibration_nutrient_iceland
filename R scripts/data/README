# Data Folder

This folder contains all datasets used for calibration, prediction, and analysis of faecal nutrient content in herbivores during the 2022 growing season in the Eastern Highlands of Iceland.

---

## Overview of Datasets

| Filename                                        | Description                                                                 |
|------------------------------------------------|-----------------------------------------------------------------------------|
| `24-10-25_dataset_dung_spectra_2022_log1R_final.txt` | Raw NIRS spectral data (log(1/R)); used for model calibration and prediction |
| `24-10-25_faecal_nutrient_wet_lab.txt`         | Wet lab measurements of N, P, and C in faeces; used in model calibration    |
| `24-10-25_data_nutrient_prediction.txt`        | Output of nutrient prediction models based on spectral data                 |
| `24-10-25_faecal_deposition.txt`               | Data used to estimate herbivore nutrient deposition                         |
| `24-10-25_pellet_weight.txt`                   | Dry weight of faecal pellets by species                                     |

---

## Metadata – Dataset Descriptions and Variables

### `24-10-25_dataset_dung_spectra_2022_log1R_final.txt`

**Description**: Raw spectral data in log(1/R) format. Includes all faecal samples used in model calibration and seasonal nutrient prediction.

| Column       | Description                             | Units     |
|--------------|-----------------------------------------|-----------|
| `id`         | Unique sample identifier                | –         |
| `350`–`2500` | Spectral reflectance at each wavelength | log(1/R)  |

---

### `24-10-25_faecal_nutrient_wet_lab.txt`

**Description**: Laboratory-derived concentrations of nitrogen (N), phosphorus (P), and carbon (C) in faecal samples, used for NIRS model calibration and validation. Includes metadata related to sample origin.

| Column      | Description                                                                 | Units          |
|-------------|-----------------------------------------------------------------------------|----------------|
| `id`        | Unique identifier assigned to each faecal sample                            | –              |
| `herbivore` | Herbivore species (Latin name): *Anser brachyrhynchus*, *Ovis aries*, *Rangifer tarandus* | –              |
| `age`       | Age class of the individual (e.g., adult, juvenile)                         | –              |
| `session`   | Seasonal sampling period: A = beginning, B = peak, C = end                  | –              |
| `N`         | Measured nitrogen concentration                                             | % dry weight   |
| `P`         | Measured phosphorus concentration                                           | % dry weight   |
| `C`         | Measured carbon concentration                                               | % dry weight   |

---

### `24-10-25_data_nutrient_prediction.txt`

**Description**: Predicted faecal nutrient concentrations (N, P, C) from the NIRS models, applied to the full dataset of faecal spectral samples. Includes stoichiometric ratios and spatial-temporal metadata.

| Column     | Description                                                                 | Units               |
|------------|-----------------------------------------------------------------------------|---------------------|
| `id`       | Unique sample identifier                                                    | –                   |
| `N`        | Predicted nitrogen concentration                                            | % dry weight        |
| `P`        | Predicted phosphorus concentration                                          | % dry weight        |
| `C`        | Predicted carbon concentration                                              | % dry weight        |
| `session`  | Seasonal sampling period: A = beginning, B = peak, C = end                  | –                   |
| `herbivore`| Common name of herbivore species (e.g., geese, sheep, reindeer)             | –                   |
| `geometry` | Geographic coordinates (longitude\|latitude) of sample collection           | decimal degrees     |
| `age`      | Age class of the animal                                                     | –                   |
| `date`     | Date and time of sample collection                                          | YYYY-MM-DD HH:MM:SS |
| `method`   | Sample collection method (e.g., defecation observation, opportunistic)      | –                   |
| `CN`       | Carbon to nitrogen ratio (C:N)                                              | –                   |
| `CP`       | Carbon to phosphorus ratio (C:P)                                            | –                   |
| `NP`       | Nitrogen to phosphorus ratio (N:P)                                          | –                   |

---

### `24-10-25_faecal_deposition.txt`

**Description**: Species-specific data used to estimate total seasonal nutrient deposition (N, P, C) by herbivores, based on faecal output, population metrics, and grazing duration.

| Column            | Description                                                              | Units               |
|-------------------|--------------------------------------------------------------------------|---------------------|
| `herbivore`       | Herbivore species (common name)                                          | –                   |
| `deposition_rate` | Estimated daily faecal nutrient deposition per individual                | mg/day              |
| `grazing_time`    | Duration of grazing within the study area                                | days                |
| `density_km`      | Estimated population density                                              | individuals/km²     |
| `population`      | Estimated number of individuals                                           | individuals         |
| `weight_g`        | Average individual body weight                                            | grams               |
| `growing_season`  | Duration of the growing season                                            | days                |
| `weight_kg`       | Average body weight (converted)                                           | kilograms           |
| `mb`              | Estimated metabolic biomass (total for population)                       | kg·km⁻¹·year⁻¹      |

---

### `24-10-25_pellet_weight.txt`

**Description**: Subsampled faecal pile measurements used to estimate average dry weight (DW) per pile. Includes fresh and dry weights to assess moisture content and extrapolate total dry mass.

| Column      | Description                                              | Units      |
|-------------|----------------------------------------------------------|------------|
| `id`        | Unique identifier for each faecal pile sample            | –          |
| `herbivore` | Herbivore species (common name)                          | –          |
| `pile_ww`   | Total fresh weight of the faecal pile                    | grams (g)  |
| `sample_ww` | Fresh weight of the subsample used for drying            | grams (g)  |
| `sample_dw` | Dry weight of the subsample after oven-drying at 40°C    | grams (g)  |

---

## Contact

For questions about the datasets, please contact:  
**Mathilde Defourneaux** – [mathilde@lbhi.is](mailto:mathilde@lbhi.is)  
**Isabel C. Barrio** – [isabel@lbhi.is](mailto:isabel@lbhi.is)

---

## Reference

Defourneaux, M., Barbero-Palacios, L., Schoelynck, J., Boulanger-Lapointe, N., Speed, J.D.M., Barrio, I.C. (2025). Capturing seasonal variations in faecal nutrient content from tundra herbivores using Near Infrared Reflectance Spectroscopy. Science of the Total Environment (in press).
