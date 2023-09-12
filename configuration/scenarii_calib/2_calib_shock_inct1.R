##  Decrease of income tax by 1% of ex ante GDP
## For France, this corresponds to 10% because of the Euro 

# Define the series necessary to calibrate the scenario  
series_1 <- c("RINC_SOC_TAX") %>% tolower
series_2 <- c("GDP", "DISPINC_BT_VAL") %>% tolower
series <- c(series_1,series_2)
# Load the selected series for the range baseyear:lastyear

if(calib_baseline=="configuration/scenarii_calib/1_calib_baseline_statec.R"){
  selection_1 <- baseline_ch %>% select(year,all_of(series_1))
  selection_2 <- calib %>% select(all_of(series_2))
  selection   <- merge(selection_1, selection_2)
}else{
  selection <- calib %>% select(year,all_of(series))
}



## Change in exogenous variables
#(1) Using formulas
shock_ch <- mutate(selection,
                   rinc_soc_tax = ifelse(year >= shockyear, 
                        rinc_soc_tax - 0.01*gdp[which(year == shockyear)]/dispinc_bt_val[which(year== shockyear)], rinc_soc_tax)
                        ) %>% 
            select(-gdp,-dispinc_bt_val) 
