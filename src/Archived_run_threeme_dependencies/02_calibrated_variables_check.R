## Automated endogenous calibration maker

library(tidyverse)
# step 1 get all equations from the equation list 
mod_from_dynamo<- readLines("src/compiler/model.prg") %>%   str_remove_all("^a_3ME\\.append\\s") 
list_endo <- mod_from_dynamo %>% 
  ## Remove basic common things and keep LHS of equations
  str_remove_all("\\s+") %>% 
  str_remove_all("=.*$") %>% 
  
  ## remove funcions
  str_remove_all("\\w+\\(") %>% 
  
  str_replace_all("^|$","@") %>% 
  str_replace_all("(\\+|-|\\*|/|\\(|\\)|\\^)","@") %>% 

  ##remove numbers
  str_replace_all("@\\d+(\\.\\d+)?@","@") %>% 
  
  ##clean up
  str_replace_all("@+","@") %>% 
  
  ##remove extra variables
  str_replace_all("^(@\\w+\\@).*$","\\1") %>%
  str_remove_all("@")


# head(mod_from_dynamo)


equation_table <- data.frame(endogenous = list_endo, equation = mod_from_dynamo)



calib_vars <- data.table::fread("src/compiler/calib.csv",data.table = FALSE ) %>% names()

missing_calibs <- setdiff(list_endo,calib_vars )

if(length(missing_calibs) > 0 ){
  cat("\nThe following endogenous variables have not been calibrated: \\n")
  equation_table %>% filter( endogenous %in% missing_calibs)
}else{
  cat("All endogenous variables have been calibrated. \n")
}


rm(mod_from_dynamo, calib_vars)

