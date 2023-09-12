library(data.table)
library(dplyr)
library(stringr)
library(tidyr)

library(ggplot2)
library(scales)
library(lemon)
library(magrittr)
gg <- glue::glue

source("bridge_results_uk.R")

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


# Sectoral results table

sectoralResults <- function(results, vars, bridge) {
  results %<>% 
    filter(str_starts(variable, str_c(names(vars), '_S', collapse = '|'))) %>%
    mutate(sec = str_to_lower(str_sub(variable, -4, -1)))
  
  for (i in 1:length(vars)) {
    results %<>% mutate(variable = ifelse(str_detect(variable, names(vars)[i]), 
                                          vars[i], variable))
  }
  
  results %>%
    left_join(bridge, by = "sec") %>%
    select(-sec) %>%
    group_by(across(all_of(intersect(c(names(results), 'agg_sec'), 
                       c('variable', 'year', 'variant', 'agg_sec'))))) %>%
    summarise(across(everything(), ~ sum(.))) %>%
    ungroup
}
