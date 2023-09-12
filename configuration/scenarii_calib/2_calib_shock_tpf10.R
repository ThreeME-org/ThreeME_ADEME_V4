# Load the selected series for the range baseyear:lastyear
selection <- calib %>% select(year,starts_with("gr_prog_exo_k_s"),starts_with("gr_prog_exo_l_s"),starts_with("gr_prog_exo_e_s"))


#Load sector and commodities list
lists_sec_com <- get_sec_com()
list_sec <- lists_sec_com[[1]]
list_com <- lists_sec_com[[2]]

for (i in list_sec){
  
  selection <- mutate(selection,
                      
                      !!paste0("gr_prog_exo_k_",i) := ifelse(year == shockyear, get(paste0("gr_prog_exo_k_",i))+0.1, get(paste0("gr_prog_exo_k_",i))),
                      !!paste0("gr_prog_exo_l_",i) := ifelse(year == shockyear, get(paste0("gr_prog_exo_l_",i))+0.1, get(paste0("gr_prog_exo_l_",i))),
                      !!paste0("gr_prog_exo_e_",i) := ifelse(year == shockyear, get(paste0("gr_prog_exo_e_",i))+0.1, get(paste0("gr_prog_exo_e_",i)))
  ) 
}

shock_ch <- selection  %>% select(year,starts_with("gr_prog_exo_k_s"),starts_with("gr_prog_exo_l_s"),starts_with("gr_prog_exo_e_s"))