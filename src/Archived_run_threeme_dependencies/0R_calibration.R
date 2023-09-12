## script to prepare the scenarii.xls file

##launch calibration scripts
source(calib_baseline)
source(calib_scenario)

xlsx.file="configuration/scenarii_calib/summary_of_scenarii.xlsx"
wb <- createWorkbook()
addWorksheet(wb, "Sheet 1")
saveWorkbook(wb, xlsx.file,overwrite = TRUE)

wb <- loadWorkbook(xlsx.file)

if (!"baseline" %in% sheets(wb)){ 
  addWorksheet(wb,sheetName = "baseline") 
}else{
  removeWorksheet(wb,"baseline")
  addWorksheet(wb,sheetName = "baseline")
}

if (!scenario_name %in% sheets(wb)){ 
  addWorksheet(wb,sheetName = scenario_name) 
}else{
  removeWorksheet(wb,scenario_name)
  addWorksheet(wb,sheetName = scenario_name) 
}

n_b <- ncol(baseline_ch) - 1
n_s <- ncol(shock_ch) - 1

### Writing baseline sheet
writeData(wb , t(baseline_ch),sheet = "baseline",startCol = "B",startRow = 1,colNames = FALSE,rowNames = TRUE)
writeData(wb , "" , sheet = "baseline",startCol = "B",startRow = 1,colNames = FALSE,rowNames = FALSE)
writeData(wb , n_b ,sheet = "baseline",startCol = "A",startRow = 1,colNames = FALSE,rowNames = FALSE)
writeData(wb , rep(1,n_b) ,sheet = "baseline",startCol = "A",startRow = 2,colNames = FALSE,rowNames = FALSE)

### Writing scenario_name sheet
writeData(wb , t(shock_ch),sheet = scenario_name,startCol = "B",startRow = 1,colNames = FALSE,rowNames = TRUE)
writeData(wb , "" , sheet = scenario_name , startCol = "B",startRow = 1,colNames = FALSE,rowNames = FALSE)
writeData(wb , n_s ,sheet = scenario_name , startCol = "A",startRow = 1,colNames = FALSE,rowNames = FALSE)
writeData(wb , rep(1,n_s) ,sheet = scenario_name , startCol = "A",startRow = 2,colNames = FALSE,rowNames = FALSE)

### saving 
saveWorkbook(wb,xlsx.file,overwrite = TRUE)
# browseURL("configuration/scenarii_calib/scenarii.xlsx")

baseline_ch_vars <- setdiff(names(baseline_ch),"year")
shock_ch_vars <- setdiff(names(shock_ch),"year")

data_3me_past <- data_3me %>% filter(year < baseyear)

## creating the databases for simulation
### baseline
data_3me_baseline <-  data_3me %>% filter(year >= baseyear) %>% 
  select(-all_of(baseline_ch_vars)) %>%
  left_join(baseline_ch, by="year") %>%
  rbind(data_3me_past) %>% arrange(year)

### shock
data_3me_shock <- data_3me_baseline %>% filter(year >= baseyear) %>% 
  select(-all_of(shock_ch_vars)) %>% 
  left_join(shock_ch, by = "year")  %>%
  rbind(data_3me_past) %>% arrange(year)




rm(baseline_ch,shock_ch,data_3me_past,baseline_ch_vars,shock_ch_vars)