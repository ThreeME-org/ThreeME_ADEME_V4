# Load the selected series for the range baseyear:lastyear
selection <- calib %>% select(year,starts_with("gr_prog_exo_k_s"))


#Load sector and commodities list
lists_sec_com <- get_sec_com()
list_sec <- lists_sec_com[[1]]
list_com <- lists_sec_com[[2]]

for (i in list_sec){
  
  selection <- mutate(selection,
                      !!paste0("gr_prog_exo_k_",i) := ifelse(year == shockyear, get(paste0("gr_prog_exo_k_",i))+0.1, get(paste0("gr_prog_exo_k_",i)))  ) 
}

shock_ch <- selection  %>% select(year,starts_with("gr_prog_exo_k_s"))
