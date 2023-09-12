##  1% GDP point decrease of the employer social security rate

# Define the series necessary to calibrate the scenario  
series <- c("RSC", "GDP") %>% tolower

# Load the selected series for the range baseyear:lastyear
selection <- calib %>% select(year,all_of(series),starts_with("rrsc_s"))

#Load sector and commodities list
lists_sec_com <- get_sec_com()
list_sec <- lists_sec_com[[1]]
list_com <- lists_sec_com[[2]]

## Change in exogenous variables
#(1) Using formulas
for (i in list_sec){
  
  selection <- mutate(selection,
                      
    !!paste0("rrsc_",i) := ifelse(year >= shockyear, 
              
              get(paste0("rrsc_",i))*(1-0.01*gdp[which(year == shockyear)]/rsc[which(year== shockyear)])
                                        , get(paste0("rrsc_",i))
                                  )
                      ) 
}

shock_ch <- selection  %>% select(-series) 
