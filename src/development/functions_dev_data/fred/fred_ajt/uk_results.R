source("threeme_results.R")

tableResults <- function(results, variables, scenarios, variants) {
  results %<>% filter(variable %in% names(variables))
  
  for (s in names(scenarios)) {
    results %<>% mutate(!!s := ifelse(variable %in% c("UNR", "RDEBT_G_VAL"), 
                                      .data[[s]] - baseline, 
                                      .data[[s]] / baseline - 1))
  }
  
  results %>%  
    mutate(variable = variables[variable],
           variant  = ifelse(variant == '', ' ', variant),
           variant  = variants[variant]) %>%
    select(-baseline) %>%
    pivot_longer(-c(year,variable,variant), names_to = "scenario", values_to = "value") %>%
    mutate(scenario = scenarios[scenario],
           scenario = factor(scenario, scenarios),
           variable = factor(variable, variables),
           variant  = factor(variant,  variants))
}

plotResults <- function(results, variables, scenarios, variants, 
                        years = c(2030, 2050), 
                        scenarios_name = "Carbon tax trajectory", 
                        scenarios_palette = c("#fee08b", "#d9ef8b", "#91cf60")) {
  
  tableResults(results, variables, scenarios, variants) %>%
    filter(year %in% years) %>%
    ggplot(aes(factor(year), value, fill = scenario)) +
    geom_bar(stat = "identity", position = position_dodge2()) +
    #facet_rep_wrap("variable", nrow = 3, scales = "free_y", repeat.tick.labels = TRUE) +
    facet_grid(variable ~ variant, scales = "free_y",
                   switch = 'y') + #,
                   #repeat.tick.labels = TRUE) +
    xlab("") + ylab("Relative difference with baseline") +
    scale_y_continuous(labels = percent_format(0.1)) +
    scale_fill_manual(name = scenarios_name, values = scenarios_palette) +
    theme_minimal() +
    theme(legend.position = "bottom",
          panel.grid.major.x = element_blank(),
          panel.grid.minor = element_blank(),
          strip.placement = "outside",
          strip.text.y = element_text(angle = 0),
          text = element_text(size = 12))
}


results <- expand_grid(base = 'carbontax', level = c('low','mid', 'high'), 
                       variant = c('', 'all_hh', 'all_firms', 'export_exposure')) %>%
  mutate(scenario = str_c(base, '_', level, '_', variant)) %$% scenario %>%
  str_replace('_$', '') %>%
  loadResults %>% 
  pivot_longer(starts_with('carbon'), names_to = c('scenario', 'variant'), 
               names_pattern = 'carbontax_(low|mid|high)_?(.*)', values_to = 'values') %>% 
  pivot_wider(names_from = 'scenario', values_from = 'values')

#results <- loadResults(str_c('carbontax_', c('low','mid', 'high'))) #, c('_export_exposure', '_export_exposure', '_export_exposure')))

plotResults(results,
            variables = c(
              "GDP" = "GDP",
              "EMS" = "Emissions",
              "F_L" = "Employment",
              "RDEBT_G_VAL" = "Debt to GDP",
              "W" = "Wages",
              "PCH" = "Consumer\nprice level",
              "UNR" = "Unemployment\nrate"
            ),
            scenarios = c(
              "low" = "Low", "mid" = "Medium", "high" = "High"
            ),
            variants = c(
              " " = "No cross-transfers",
              "export_exposure" = "Increased transfers to\nexports-exposed sectors",
              "all_hh" = "Full transfer to households",
              "all_firms" = "Full transfer to firms"
            ))


