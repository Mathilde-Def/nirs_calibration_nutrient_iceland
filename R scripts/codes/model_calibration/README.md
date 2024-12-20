# This script is calibrating monospecific and multispecies NIRS model to assess faecal carbon content from herbivores in the Icelandic tundra

# Reference:
Capturing seasonal variations in faecal nutrient content from tundra herbivores using Near Infrared Reflectance Spectroscopy 
here the DOI of the publication
2024

# Sample collection
The model is developed  with samples from Iceland. Samples were collected in 2022 from the Easter Highlands (65.3234 °N, 15.3062 °E). They includes fresh faecal material from free roaming tundra herbivores, including the pink-footed geese (Anser brachyrhynchus), the feral reindeer (Rangifer tarandus), and the domestic sheep (Ovis aries).
Samples are presented as tablets, dried at 40°C for 3 hours and cooled down in a desiccator

# Collection of the NIRS spectra 
A FieldSpec 4 was used to scan the samples, with a spectral range of 350-2500nm,  with a sampling interval of 1.4 nm in the 350-1000 nm range and 2 nm in the 1000-2500 nm range

# Estimation of N, P and C concentrations
wet laboratory analysis were conducted at the University of Antwerp
- N and C Concentration were estimated using a Flash 2000 CN analyser, 
- P concentration was determined through acid destruction and calorimetric  

# Units
Model are developed with Log 1/R spectra, values measured in % Dry Weight

# Calibration function 
the detailed steps to calibrate and validate the model are contained in ./functions/calibration_nirs.R

# Final multispecies models
The final multispecies models, including all herbivore species are saved in the folder "./a_ready_to_apply_nirs_model"
file names:  "nirs_faecal_N_model2024.rda", "nirs_faecal_P_model2024.rda", "nirs_faecal_C_model2024.rda"

# Contact person: 
Mathilde Defourneaux(mathilde@lbhi.is) 
