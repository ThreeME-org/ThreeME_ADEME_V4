source("threeme_results.R")

xl_variants <-  c(
  " " = "Standard",
  "export_exposure" = "Exports exposure",
  "all_hh" = "All to households",
  "all_firms" = "All to firms"
)


sectoral_results <- bind_rows(
  sectoralResults(results, c("F_L_S" = "Sectoral employment", "VA_S" = "Sectoral VA"), bridgeResultsUK()) %>%
    mutate(across(c(low, mid, high), ~ . / baseline - 1)),
  
  sectoralResults(results, c("VA_S" = "Sectoral share"), bridgeResultsUK()) %>%
    group_by(variable, year, variant) %>%
    mutate(across(c(low, mid, high), ~ . / sum(.)))
) %>%
  select(-baseline) %>%
  pivot_longer(c(low, mid, high), names_to = 'scenario', values_to = 'value') %>%
  mutate(variable = str_c(variable, ' - ', agg_sec)) %>% 
  select(-agg_sec) %>%
  mutate(variant = ifelse(variant == '', ' ', variant),
         variant = xl_variants[variant])


table_results <- bind_rows(
  # Macro results
  tableResults(results, 
               variables = c(
                 "GDP" = "GDP",
                 "EMS" = "Emissions",
                 "F_L" = "Employment",
                 "RDEBT_G_VAL" = "Debt to GDP",
                 "W" = "Wages",
                 "PCH" = "Consumer price level",
                 "UNR" = "Unemployment rate"
               ),
               scenarios = c(
                 "low" = "low", "mid" = "mid", "high" = "high"
               ),
               variants = xl_variants),
  # Sectoral results
  sectoral_results
)

xl_sheets <- expand_grid(variants = xl_variants, scenarios = c('low', 'mid', 'high'))
xl_sheets %$%
  mapply(function(variant, scenario) {
    table_results %>% 
      filter(scenario == !!scenario, variant == !!variant) %>%
      select(-scenario, -variant) %>%
      pivot_wider(names_from = year, values_from = value)
  }, variants, scenarios, SIMPLIFY = FALSE) %>%
  `names<-`(xl_sheets %$% str_c(variants, ' - ', str_to_title(scenarios))) %>%
  write_xlsx("2022-03-06 - ThreeME UK - Results.xlsx")



