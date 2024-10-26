################################################################################
#                     FUNCTION TO CALIBRATE NIRS MODELS
#                           Mathilde Defourneaux
#                               Mar 30, 2024
################################################################################

# this function combine all the steps to calibrate NIRS model
# as input is required a df with a proper structure for pls analysis 
# the spectral data should be stored in a matrix together in a data frame with 
# the other descriptors, including the variable to predict. 
# the variable to predict "inVar" correspond to the nutrient to predict using 
# this function

# iterations correspond to how many permutation iterations to run for the boostrapping 
# and uncertainety analysis and prop is fraction of training data to keep for each iteration

# output includes model performance evaluators:  
# R2, RMSE based on the calibration data and the validation data
# it also provide the calibration data with the prediction and residuals from the model
# and the validation data`

# library
library("pls")       # partial least regression square analysis`

# SCRIPTS OPTIONS --------------------------------------------------------------
# not in
pls::pls.options(plsralg = "oscorespls")
pls::pls.options("plsralg")

calibration_nirs <- function(cal_data, val_data, inVar, iterations, prop) {

  # Plot calibration and validation histograms
  cal_hist_plot <- ggplot(cal_data, aes(x = .data[[inVar]])) +
    geom_histogram(fill = "grey50", color = "black", alpha = 0.7) +
    labs(title = paste("Calibration Histogram for", inVar),
         x = inVar, y = "Count") +
    theme_minimal()
  
  val_hist_plot <- ggplot(val_data, aes(x = .data[[inVar]])) +
    geom_histogram(fill = "grey50", color = "black", alpha = 0.7) +
    labs(title = paste("Validation Histogram for", inVar),
         x = inVar, y = "Count") +
    theme_minimal()
  
  (histograms <- grid.arrange(cal_hist_plot, val_hist_plot, ncol = 2))
  
  # Plot calibration and validation spectra
  cal_spec_plot <- f.plot.spec(Z = cal_data$Spectra, 
                               wv = seq(start_wave, end_wave, 1), 
                               plot_label = "Calibration")
  
  val_spec_plot <- f.plot.spec(Z = val_data$Spectra, 
                               wv = seq(start_wave, end_wave, 1), 
                               plot_label = "Validation")
  
  # evaluate the nb of components to include in the model
  n_comp <- find_optimal_components(dataset = cal_data,
                                    targetVariable = inVar, 
                                    method = "firstMin",
                                    maxComps = 20, 
                                    iterations = 20)
  
  plsr_out <- plsr(as.formula(paste(inVar,"~","Spectra")), 
                   scale = FALSE, 
                   ncomp = n_comp, 
                   validation = "CV", 
                   trace = FALSE, 
                   data = cal_data)   
  
  fit <- plsr_out$fitted.values[, 1, n_comp]
  
  ## make a dataframe with predicted and observed values and residuals of cross validation
  cal_plsr_output <- data.frame(cal_data[, which(names(cal_data) %notin% "Spectra")], 
                                PLSR_Predicted = fit,
                                PLSR_CV_Predicted = as.vector(plsr_out$validation$pred[, , n_comp])) %>% 
    mutate(PLSR_CV_Residuals = PLSR_CV_Predicted - get(inVar))
  
  cal_R2 <- round(pls::R2(plsr_out, intercept = FALSE)[[1]][n_comp], 2)
  cal_RMSEP <- round(sqrt(mean((cal_data[[inVar]] - fit)^2)), 2)

  ## make a dataframe with predicted and observed values and residuals 
  val_plsr_output <- data.frame(val_data[, which(names(val_data) %notin% "Spectra")],
                                PLSR_Predicted = as.vector(predict(plsr_out, 
                                                                   newdata = val_data, 
                                                                   ncomp = n_comp, 
                                                                   type = "response")[,,1])) %>% 
    mutate(PLSR_Residuals = PLSR_Predicted - get(inVar))
  
  
  val_R2 <- round(pls::R2(plsr_out, newdata = val_data, intercept = FALSE)[[1]][n_comp], 2)
  val_RMSEP <- round(sqrt(mean(val_plsr_output$PLSR_Residuals^2)),2)
  val_bias <- round(mean(val_data[[inVar]]- val_plsr_output$PLSR_Predicted), 2)
  
  val_lm <- lm(data = val_plsr_output, PLSR_Predicted ~ val_data[[inVar]])
  
  model_perf <- data.frame(
    n_cal = nrow(cal_data),
    n_comp = n_comp,
    cal_R2 = cal_R2,
    cal_RMSEP = cal_RMSEP,
    n_val = nrow(val_data),
    val_R2 = val_R2,
    val_RMSEP = val_RMSEP,
    val_bias = val_bias,
    val_intercept = round(unname(val_lm$coefficients[1]), 2),
    val_slope = round(unname(val_lm$coefficients[2]), 2)
  )
  
#----------------------------------------------------------------------------###
### Generate Coefficient and VIP plots
#----------------------------------------------------------------------------###
  
  vips <- VIP(plsr_out)[n_comp, ]
  
  # Convert vips to a data frame
  vips_df <- data.frame(wavelength = seq(start_wave, end_wave, 1),
                        vip = vips)
  
  # Plot using ggplot2
  vips_plot <- ggplot(vips_df, aes(x = wavelength, y = vip)) +
    geom_line(size = 1, color = "#287271") +
    labs(x = "Wavelength (nm)", y = "VIP") +
    geom_hline(yintercept = 0.8, linetype = "dashed", color = "dark grey") +
    theme_perso()
  
#----------------------------------------------------------------------------###
### PLSR bootstrap permutation uncertainty analysis
#----------------------------------------------------------------------------###
  
# computing the permutation test for partial least squares regression
  plsr_permutation <- pls_permutation(dataset = cal_data, 
                                      targetVariable = inVar,
                                      maxComps = n_comp, 
                                      iterations = iterations, 
                                      prop = prop, 
                                      verbose = TRUE)
  
# Extracts the bootstrap intercept from the permutation results.
  bootstrap_intercept <- plsr_permutation$coef_array[1, ,n_comp]
  
# Extracts the bootstrap coefficients from the permutation results.
  bootstrap_coef <- plsr_permutation$coef_array[2:length(plsr_permutation$coef_array[, 1, n_comp]),
                                                , n_comp]
  rm(plsr_permutation)
  
  # apply coefficients to left-out validation data
  interval <- c(0.025,0.975)
  
  # Computes the predictions on validation data using the bootstrap coefficients.
  
  Bootstrap_Pred <- val_data$Spectra %*% bootstrap_coef + 
    matrix(rep(bootstrap_intercept, length(val_data[,inVar])), byrow = TRUE, 
           ncol = length(bootstrap_intercept))
  
  # Computes confidence intervals for the predictions.
  
  Interval_Conf <- apply(X = Bootstrap_Pred, 
                         MARGIN = 1, 
                         FUN = quantile, 
                         probs = c(interval[1], 
                                 interval[2]))
  
  # Calculates standard deviations for the predictions and residuals.
  
  sd_mean <- apply(X = Bootstrap_Pred, MARGIN = 1, FUN = sd)
  sd_res <- sd(val_plsr_output$PLSR_Residuals)
  sd_tot <- sqrt(sd_mean^2 + sd_res^2)

  # adding interval of confidence for each estimates from the model
  val_plsr_output$LCI <- Interval_Conf[1,]
  val_plsr_output$UCI <- Interval_Conf[2,]
  val_plsr_output$LPI <- val_plsr_output$PLSR_Predicted - 1.96 * sd_tot
  val_plsr_output$UPI <- val_plsr_output$PLSR_Predicted + 1.96 * sd_tot
  head(val_plsr_output)
  
  return(list(model = plsr_out,
              model_perf = model_perf,
              cal_plsr_output = cal_plsr_output, 
              val_plsr_output = val_plsr_output,
              vips = vips_plot))
}
