# 04_faecal_analysis

This folder contains R scripts used to perform statistical analyses on faecal nutrient data. These analyses assess the variation in faecal nutrient content (C, N, P) and stoichiometric ratios (C:N, C:P, N:P) across herbivore species (goose, sheep, reindeer) and over the growing season (beginning, peak, end). Additionally, they estimate total nutrient deposition by each species during the growing season.

## Overview

- `faecal_nutrient_content.R`: Performs statistical analysis (two-way ANOVA and pairwise comparisons) on faecal nutrient concentrations.
- `faecal_deposition.R`: Estimates total nutrient deposition (C, N, P) by each herbivore species across the growing season.

## Sample Collection & Data Sources

Faecal samples were collected during the 2022 growing season in the Eastern Highlands of Iceland (65.3234°N, 15.3062°E), spanning three seasonal periods: beginning, peak, and end.

- **Faecal nutrient concentrations (in % DW)** and **stochiometry ratio** were predicted using the NIRS multispecies models.
- **Population estimates:**
  - Sheep population estimates: Ministry of Food, Agriculture and Fisheries
  - Reindeer and geese population estimates: East Iceland Nature Research Centre
- **Defecation rates (events/day):** Obtained from literature.
- **Grazing days (days):** Based on species-specific seasonal presence, estimated from literature.
- **Pellet weight (g dry matter):** 
  - Estimated by sub-sampling approx. 10 g (sheep and reindeer) or 4 g (goose) of fresh faeces from 5 randomly selected samples per species.
  - Sub-samples were oven-dried at 40 °C for 48 hours. Dry matter was extrapolated to full pellet mass based on wet-dry weight ratios.

## Contact

For questions about this analysis or the dataset, please contact:  
**Mathilde Defourneaux** – mathilde@lbhi.is  
**Isabel C. Barrio** – isabel@lbhi.is

## Reference

Defourneaux, M., Barbero-Palacios, L., Schoelynck, J., Boulanger-Lapointe, N., Speed, J.D.M., Barrio, I.C. (2025).  
Capturing seasonal variations in faecal nutrient content from tundra herbivores using Near Infrared Reflectance Spectroscopy. Science of the Total Environment (in press).
