##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~##
## CONVERT ASD FILES TO TEXT FILE
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~##

## this function converts asd.files from a ASD-spectormeter (eg FieldSpec) to a txt-file
## all spectra should be saved as asd.files in a single folder
## the spectra can be retured as "reflectance" (default), "raw", or "white_reference
## the spectra can be converted to LOG(1/R) if log_ref = TRUE
## a txt-file with all spectra will be saved in the specified directory if save = TRUE

## the txt-file has the same format as the txt-file produced by the 'asd to ascii' program provided by ASD; 
## with the only difference that the last empty column (X) is missing

## Run the first part (MAKE FUNCTION)
## Specify the directoris in the second part (RUN FUNCTION) and run the function


##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~##
## MAKE FUNCTION
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~##

asd_to_txt <- function (in.dir, out.dir, output.name = output.name, 
                      type = "reflectance", log_ref = TRUE, save = TRUE)
{
  ## load library
  library(asdreader)
  
  ## get filenames
  filenames <- grep(".asd", dir(in.dir), value = TRUE)
  
  ## read asd files
  myfile<-get_spectra(paste(in.dir, filenames, sep ="/"), type = type)
  
  ## convert to LOG(1/R)
  if (log_ref) {
    myfile<-log10(1/myfile)
  }
  
  ## make a data frame
  myfile <- as.data.frame(myfile)
  myfile$Wavelength<-row.names(myfile)
  myfile <- myfile[,c(2152, 1:2151)]
  
  
  ## plot spectra
  matplot(t(myfile[,2:2151]), type = "l")
  
  ## save spectra
  if (save) {
    write.table(myfile, paste(out.dir, output.name, sep = "/" ), sep = "\t", row.names = FALSE)  
  }
  
  return (myfile)
}


##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~##
## RUN FUNCTION
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~##

asd_to_txt(in.dir = "./data/2-labdata/dung_spectra",  # write here the path to the folder with all asd files
           out.dir = "./data/2-labdata",                          # write here the path to the folder where the txt file with all spectra should be saved
           output.name = "dataset_dung_spectra_2022_log1R.txt",     # write here the name of the txt file
           type = "reflectance",                                              # don't change that
           log_ref = TRUE, 						      # TRUE if spectra should be presented as log(1/R) -> required for most calibration models
           save = TRUE)                                                       # TRUE if the dataset should be saved

