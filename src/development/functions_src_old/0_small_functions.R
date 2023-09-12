library(tidyverse)
## Small and useful functions

variables_like <- function(data,test,view = TRUE){
  VariableShow <- data %>% filter(grepl(test, variable)) %>% select(variable,sector,commodity) %>% unique()
  if(view == TRUE)
    {
      View(VariableShow)
    }else
    {
      VariableShow
    }
  
}

# variables_like(data, "^EMS_CI")
