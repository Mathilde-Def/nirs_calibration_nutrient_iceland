################################################################################
#                      BASE THEME FOR PLOT VISUALISATION
#                           Mathilde Defourneaux
#                               fev 05, 2023
################################################################################

library("ggplot2")

theme_perso <- function(){
  theme_bw() +
    theme(axis.text = element_text(size = 20),
          axis.title = element_text(size = 25),
          axis.line.x = element_line(color="black"),
          axis.line.y = element_line(color="black"),
          panel.grid.major.x = element_blank(),
          panel.grid.minor.x = element_blank(),
          panel.grid.minor.y = element_blank(),
          panel.grid.major.y = element_blank(),
          panel.background = element_blank(),
          panel.border = element_rect(linetype = "solid", fill = NA, size = 1),
          plot.margin = unit(c(1, 1, 1, 1), units = , "cm"),
          plot.title = element_text(size = 25),
          legend.text = element_text(size = 20),
          legend.title = element_text(size = 25),
          #legend.title = element_blank(),
          legend.key = element_blank(),
          legend.background = element_rect(color = "black",
                                           fill = "transparent",
                                           size = 2, linetype="blank"))
}
