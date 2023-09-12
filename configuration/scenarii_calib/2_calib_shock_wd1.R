## 1% permanent increase of the world demand

# Load the selected series for the range baseyear:lastyear
selection <- calib %>% select(year,starts_with("dwd_c"))

#Load sector and commodities list
lists_sec_com <- get_sec_com()
list_sec <- lists_sec_com[[1]]
list_com <- lists_sec_com[[2]]

## Change in exogenous variables

for (i in list_com){
  
  selection <- mutate(selection,
                      
    !!paste0("dwd_",i) := ifelse(year >= shockyear, get(paste0("dwd_",i))*1.01, get(paste0("dwd_",i)))

                      ) 
}

shock_ch <- selection
