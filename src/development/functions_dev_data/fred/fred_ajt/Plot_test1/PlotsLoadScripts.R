# Clean up Global Environment
  rm(list = ls())
  
# Clean plots: Add a condition to ignore when no Graph (because bug at start of R)
  # dev.off()

# Load packages by apply "require"
lapply(c("data.table", "lemon", "tidyverse", "extrafont", "scales", "readxl",
         "colorspace", "ggpubr", "svglite", "magrittr", "png"),
       require, character.only = TRUE)

# Create glue function : str_c(“csv/carbontax_“,scenario[i],“.csv”) == glue(“csv/carbontax_{scenarios[i]}.csv”)
gg <- glue::glue

# Load ThreeME Results

#' Load ThreeME results from a csv exported by EViews
#' Note that the csv files must be located in the csv/ directory,
#' baseline results should be indexed by '_0' and scenario results by '_2',
#' and that all scenarios must share the same baseline
#' 
#' @param scenarios Name of the scenario csv files (with or without a csv extension)
#' @return A tibble (dataframe) with the following columns:
#'  - variable: name of the ThreeME variable for which the result is reported in a given row
#'  - year: year for which the result is reported in a given row
#'  - one column per scenario, named after the scenario (e.g. "baseline") containing
#'  the values of the results themselves

loadResults <- function(scenarios) {
  # To debug the function step by step, activate line below
  # browser()
  
    # Ensure that there's no csv extension
  scenarios %<>% str_replace("\\.csv$", "")
  
  1:length(scenarios) %>%
    lapply(function(i) {
      res <- fread(gg("csv/{scenarios[i]}.csv")) %>% na.omit %>% 
        melt(id.vars = "V1") %>% rename(year = V1) %>% 
        mutate(scenario = ifelse(str_sub(variable, -1, -1) == '0', 
                                 'baseline', scenarios[i]), 
               variable = str_sub(variable, 1, -3))
      
      if (i > 1) {
        res %>% filter(scenario != 'baseline')
      } else {
        res
      }
    }) %>% 
    rbindlist %>%
    dcast(variable + year ~ scenario)
  
}


simpleplot <- function(scenarios, series, transformation="reldiffx100") {

  # To debug the function step by step, activate line below
  # browser()
  
  ## Format of the output plot
  format_img <- c("png")  # Choose format: "png", "svg"
  
  results <- loadResults(scenarios)
  
  selection <- results %>% 
    filter(variable %in% series) %>%
    mutate(variable, reldiffx100 = 100*(get(scenarios)/baseline-1),
           diffx100 = 100*(get(scenarios) - baseline),
           diff = (get(scenarios) - baseline)) %>% as.data.frame()

    selection$transfo = selection[, transformation]

  
  plotseries <- ggplot(selection) + geom_line(aes(x=year, y=transfo, color=series, size=2))  + 
                scale_color_discrete(name="Legend") + theme(text = element_text(size = 20)) 
  
  ggsave(str_c(series,"_",transformation,".", format_img), plotseries, device = format_img, width = 300 , height = 300 , units = "mm", dpi = 100)
  
  plotseries
  
}

# transfo= ifelse(transformation == "diff",diff,)


combineplots <- function(listplots, outputpdf = "Plots.pdf") {
  
  # To debug the function step by step, activate line below
  # browser()
  
  
  # setup plot
  par(mar=rep(0,4)) # no margins
  
  # layout the plots into a matrix w/ 12 columns, by row
  layout(matrix(1:9, ncol=3, byrow=TRUE))
  
  # do the plotting
  for(i in listplots) {
    img <- readPNG(i)
    plot(NA,xlim=0:1,ylim=0:1,xaxt="n",yaxt="n",bty="n")
    rasterImage(img,0,0,1,1)
  }
  
  # write to PDF
  dev.print(pdf, outputpdf)
}
