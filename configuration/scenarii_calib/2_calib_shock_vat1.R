
if(iso3 == "lux" && classification == "c23_s26"){
  ##  1% GDP point decrease of the employer social security rate
  
  # Define the series necessary to calibrate the scenario  
  series <- c("VAT", "CH", "GDP") %>% tolower
  
  # Load the selected series for the range baseyear:lastyear
  selection <- calib %>% select(year,all_of(series),starts_with("rvatd_c"), starts_with("rvatm_c"))
  
  
  ## Change in exogenous variables
  
  selection <- mutate(selection,
                      
                      rvat_base = vat / (ch - vat),
                      rvat_shock = rvat_base  - 0.01 * gdp[which(year == shockyear)]/(ch - vat),
                      ratio_shock_base = rvat_shock/rvat_base
                      
  )
  
  #Load sector and commodities list
  lists_sec_com <- get_sec_com()
  list_sec <- lists_sec_com[[1]]
  list_com <- lists_sec_com[[2]]
  
  for (i in list_com){
    
    selection <- mutate(selection,
                        
                        !!paste0("rvatd_",i) := ifelse(year >= shockyear, get(paste0("rvatd_",i))*ratio_shock_base[which(year == shockyear)], get(paste0("rvatd_",i))),
                        !!paste0("rvatm_",i) := ifelse(year >= shockyear, get(paste0("rvatm_",i))*ratio_shock_base[which(year == shockyear)], get(paste0("rvatm_",i)))
                        
    ) 
  }
  
  shock_ch <- selection  %>% select(-series,-rvat_base,-rvat_shock,-ratio_shock_base ) 
  
}else{
  ##  1% GDP point decrease of the employer social security rate
  
  # Define the series necessary to calibrate the scenario  
  series <- c("VAT", "CH", "GDP") %>% tolower
  
  # Load the selected series for the range baseyear:lastyear
  selection <- calib %>% select(year,all_of(series),starts_with("rvat_c"))
  
  
  ## Change in exogenous variables
  
  selection <- mutate(selection,
                      
                      rvat_base = vat / (ch - vat),
                      rvat_shock = rvat_base  - 0.01 * gdp[which(year == shockyear)]/(ch - vat),
                      ratio_shock_base = rvat_shock/rvat_base
                      
  )
  
  #Load sector and commodities list
  lists_sec_com <- get_sec_com()
  list_sec <- lists_sec_com[[1]]
  list_com <- lists_sec_com[[2]]
  
  for (i in list_com){
    
    selection <- mutate(selection,
                        
                        !!paste0("rvat_",i) := ifelse(year >= shockyear, get(paste0("rvat_",i))*ratio_shock_base[which(year == shockyear)], get(paste0("rvat_",i)))
                        
    ) 
  }
  
  shock_ch <- selection  %>% select(-series,-rvat_base,-rvat_shock,-ratio_shock_base ) 
  
}


