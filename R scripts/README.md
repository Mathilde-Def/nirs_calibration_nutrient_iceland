Disclaimer: the end user of this dataset is expected to have basic knowledge in R and the principles of NIRS, such as (but not limited to):
data pre-treatment, robustness and reliability of predictions, sample presentation and statistical background. 

Specific questions about the dataset and models can be addressed to Mathilde Defourneaux (mathilde@lbhi.is) or Isabel C. Barrio (isabel@lbhi.is)

This reference folder contains all necessary data to estimate carbon (C), nitrogen (N) and phosphorus (P) in %DW from herbivore faecal samples.

The material used to develop the prediction model was collected as fresh faecal samples, milled and pressed with 4 tons of pressure into Ø15mm tablets, 
dried at 40ºC and stored in a dessicator prior to scanning. 

Faecal samples were retrieved from Eastern Highlands, Iceland, at three times during the growing season (beginning, peak and end) and from three different herbivores species, common in tundra environements (sheep, reindeer and pink-footed goose)

Further methodological information can be found in Defourneaux al. (in press)

The folder contains an R script (Prediction_script.R), three R object (C_Prediction_model.rda; N_Prediction_model.rda; P_Prediction_model.rda), a test dataset (from the same area) to run the prediction script.
The reference dataset used to develop the model can be found in a separate folder

The R script loads the R object, and contains instructions on how to proceed with the prediction. 

Data structure in the "Test_dataset.txt" file is the following: the Wavelength column identifies each sample with the unique ID attributed under scanning, the columns named X350 to X2500
contain the spectral data (in log(1/R)) and the X column is empty and will be deleted before further processing of the data.

References:

Defourneaux, M., Barbero-Palacios, L., Schoelynck, J., Boulanger-Lapointe, N., Speed, J.D.M., Barrio, I.C., 2025. in press. Capturing seasonal variations in faecal nutrient content from tundra herbivores using Near Infrared Reflectance Spectroscopy. Science of the total environment.

