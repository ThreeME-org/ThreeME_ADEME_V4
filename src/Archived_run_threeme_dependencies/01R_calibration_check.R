options(scipen = 9)

### Calibration check
##  to test with opale
# tolerance_calib_check = 10^-5
# "/Library/Frameworks/R.framework/Versions/4.2-arm64/Resources/library/tresthor/opale/"
# 
# coeff_opale <- readRDS(system.file("opale/coefficients_opale.rds",package = "tresthor"))
# opale_data <-readRDS(system.file("opale/donnees_opale.rds",package = "tresthor") ) %>% 
#   add_coeffs(listcoeff =  coeff_opale,database = .,pos.coeff.name = 2,pos.coeff.value = 1)
# 
# create_model("opale",system.file("opale/opale.txt",package = "tresthor"),algo = FALSE )

parts <- c("prologue", "heart", "epilogue")
parts_list <- map(parts, 
                  function(part = .x){
                    list( 
                      part = part ,
                      bool = eval(parse(text = paste0("threeme@",part) )),
                      fun_check = eval(parse(text = paste0("threeme@",part,"_equations_f") )) )
                  }) %>% 
  purrr::set_names(parts)

##### BASELINE TESTS

cat("\n\nBaseline calibration check... \n")

baseyear_index <- which(data_3me_baseline$year== baseyear)

equations <- map(parts, 
           function(section = .x){
if(parts_list[[section]]$bool == TRUE){
  
  equations <- threeme@equation_list %>% 
    filter(part == section) %>% 
    select(equation =name, formula = equation) %>% 
    mutate(calib_test = parts_list[[section]]$fun_check(t = baseyear_index, t_data = data_3me_baseline)  )
  
  }else{equations<-NULL}
             }) %>% compact() %>% reduce(rbind)

equations_check <- equations %>% filter(abs(calib_test) >= tolerance_calib_check)

if(nrow(equations_check) == 0 ){
  cat("\n\nAll equations appear to well calibrated for the baseline scenario. \n")
}else{ 
  cat("\n\nThe following equations are not well calibrated for the baseline scenario: \n")
  print(equations_check)
  Sys.sleep(2)
  
  if (warning){
    if(!askYesNo("\n There are calibrations issues for the baseline scenario. Would you like to go ahead with the simulations ? \n",prompts = c("yes","NO","CANCEL")) ){
      stop(message("\nAborted simulations due to calibrations errors.\n"))
    }
  }
  }


##### Shock  TESTS
cat("\n\nShock scenario calibration check... \n")

baseyear_index <- which(data_3me_shock$year== baseyear)

equations <- map(parts, 
                 function(section = .x){
                   if(parts_list[[section]]$bool == TRUE){
                     
                     equations <- threeme@equation_list %>% 
                       filter(part == section) %>% 
                       select(equation =name, formula = equation) %>% 
                       mutate(calib_test = parts_list[[section]]$fun_check(t = baseyear_index, t_data = data_3me_shock)  )
                     
                   }else{equations<-NULL}
                 }) %>% compact() %>% reduce(rbind)

equations_check <- equations %>% filter(abs(calib_test) >= tolerance_calib_check)

if(nrow(equations_check) == 0 ){
  cat("\n\nAll equations appear to well calibrated for the shock scenario. \n")
}else{ 
  cat("\n\nThe following equations are not well calibrated for the shock scenario: \n")
  print(equations_check)
  Sys.sleep(2)
  
  if (warning){
    if(!askYesNo("\n There are calibrations issues for the shock scenario. Would you like to go ahead with the simulations ? \n",prompts = c("yes","NO","CANCEL")) ){
      stop(message("\nAborted simulations due to calibrations errors.\n"))
    }
  }
}
rm(parts_list,parts,baseyear_index)
###

