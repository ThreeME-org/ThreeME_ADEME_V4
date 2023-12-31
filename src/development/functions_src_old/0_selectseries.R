
# This function select the desired series from a long data table

selectseries <- function(data,
                         scenarios,
                         series,
                         startyear = NULL,
                         endyear = NULL,
                         transformation="reldiff") {
  
  # To debug the function step by step, activate line below
  #browser()
  
  if (is.null(startyear)){startyear  =  min(data$year)}
  if (is.null(endyear)){endyear  =  max(data$year)}
  selection <- data %>%
    
    # Filter relevant data: see https://dplyr.tidyverse.org/reference/filter.html
    filter(variable %in% series) %>%
    
    
    ## Calculation per variable
    group_by(variable) %>%
    mutate(lag_baseline = lag(baseline),
           lag_scenario = lag(get(scenarios)),
           mean_baseline = mean(baseline),
           index_baseline = baseline/baseline[which(year ==  startyear)]) %>%
    ungroup() %>%
    
    ## Calculation for the all database (all variables)
    mutate(transformation = transformation,
           transfo = ifelse(transformation == "reldiff", (get(scenarios)/baseline-1),
                            ifelse(transformation == "diff", (get(scenarios) - baseline),
                                   (get(scenarios) - baseline))),
           gr_base =  (baseline/lag_baseline-1),
           gr_scen =  (get(scenarios)/lag_scenario-1),
           base =  baseline,
           scen =  get(scenarios)
    ) %>%
    
    as.data.frame() %>% select(-transformation)  %>%
    
    filter(year %in% (startyear:endyear))
  
  
  
  
}