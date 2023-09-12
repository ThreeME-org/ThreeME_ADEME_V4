## script to calibrate scenario for Eviews solver and prepare the scenarii.xls file 

## Launch calibration scripts and save to csv (for further process in EViews;
# Launch baseline calibration scripts only at the first scenario simulation (if loop)


if(exists("shock_nb")==FALSE){shock_nb <- 1}

if(shock_nb<2){
  cat("\n  Save baseline scenario for Eviews: calib_baseline.csv (in configuration/scenarii_calib/)\n")  
  source(calib_baseline)
  write.csv(baseline_ch,file = paste0("configuration/scenarii_calib/calib_","baseline",".csv"),row.names = FALSE)
}

# Run and save shock scenario to cvs 
cat(paste0("\n  Save shock scenario  for Eviews: calib_",scenario_name,".csv (in configuration/scenarii_calib/) \n\n"))
source(calib_scenario)
write.csv(shock_ch,file = paste0("configuration/scenarii_calib/calib_",scenario_name,".csv"), row.names = FALSE)

# Save a summary of all scenarii to Excel
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
# browseURL(xlsx.file)

# Clean up scenario data
# rm(baseline_ch,shock_ch,wb)