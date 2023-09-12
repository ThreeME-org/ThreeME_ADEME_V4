###Create database full R version
cat("\n creating databases")

data_long_baseline <- baseline_scenario %>%  
  pivot_longer(cols = !year,names_to = "variable",values_to = "baseline") %>% mutate(variable = toupper(variable))

data_long_shock <- shock_scenario %>% 
  pivot_longer(cols = !year,names_to = "variable",values_to = scenario_name) %>% mutate(variable = toupper(variable))

data_full <- full_join(data_long_baseline ,data_long_shock, by= c("year","variable")) %>% 
  mutate(sector = NA,
         commodity = NA) %>% as.data.frame()


saveRDS(data_full , file = file.path("data","output", paste0(scenario_name,"_",classification,".rds")))
rm(data_3me_baseline,data_3me_shock,baseline_scenario,shock_scenario, data_long_baseline,data_long_shock,calib)

if(classification =="c4_s4"){
  source("src/bridges/bridge_c4_s4.R")
  source("src/bridges/codenames_c4_s4.R")
  
  names_sectors$code<- toupper(names_sectors$code)
  names_commodities$code<- toupper(names_commodities$code)
  names_s <- set_names(names_sectors$name,names_sectors$code)
  names_c <- set_names(names_commodities$name,names_commodities$code)
  
  data_full <- data_full %>% mutate(
    sector = str_extract(variable, "_S[A-Z]{3}$") %>% str_remove("_") %>% str_replace_all(names_s),
    commodity = str_extract(variable, "_C[A-Z]{3}(_S[A-Z]{3})?$") %>% str_remove("_S[A-Z]{3}")%>% str_remove("_") %>% str_replace_all(names_c)
    )
  
  s4 <- bridge_sectors %>%  reduce(c) %>% toupper() %>% set_names(names(bridge_sectors),.)
  c4 <- bridge_commodities %>%  reduce(c) %>% toupper() %>% set_names(names(bridge_commodities),.)
  data_ag_sector <- data_full %>% mutate(variable= str_replace_all(variable,s4))
  data_ag_commodity <- data_full %>% mutate(variable= str_replace_all(variable,c4))
  data_ag_commodity_sector <- data_ag_commodity%>% mutate(variable= str_replace_all(variable,s4))
  
  
  saveRDS(data_ag_sector,
          file = paste0("data/output/",scenario_name,"_",classification,"_sectors",".rds"))
  
  
  saveRDS(data_ag_commodity,
          file = paste0("data/output/",scenario_name,"_",classification,"_commodities",".rds"))
  
  
  saveRDS(data_ag_commodity_sector,
          file = paste0("data/output/",scenario_name,"_",classification,"_commodities_sectors",".rds"))
}