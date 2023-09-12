
construct_ratio <- function(data,
                           numerator = NULL,
                           denominator = NULL,
                           countries = NULL,
                           rationame = NULL,
                           by_sector = FALSE,
                           scenario = NULL) {

  if (is.null(countries)){
    data <- data
  }else{
    data <- data %>% filter(country %in% countries)
  }

  if (is_null(numerator)){
    stop(message = "Please enter your numerator. \n")
  } else if (length(numerator) > 1 ){
    stop(message = "More than one numerator is selected, please choose only one numerator. \n")
  } 
  
  if (is_null(denominator)){
    stop(message = "Please enter your denominator. \n")
  } else if (length(denominator) > 1 ){
    stop(message = "More than one denominator is selected, please choose only one denominator. \n")
  } 
  
  if (is_null(rationame)){
    rationame = paste0(numerator,"/",denominator)
  }
  
  var_vec              <- unique(data$variable)
  
  if (isFALSE(by_sector)){
    liste_num          <- var_vec[grep(numerator,var_vec)]
    liste_den          <- var_vec[grep(denominator,var_vec)]
  }else{
    liste_num          <- var_vec[grep(paste0("^",numerator,"_S[A-Z0-9]{3}$"),var_vec)]
    liste_den          <- var_vec[grep(paste0("^",denominator,"_S[A-Z0-9]{3}$"),var_vec)]
  }
  
  filtered.num         <- filter(data,variable %in% liste_num)
  filtered.den         <- filter(data,variable %in% liste_den)
  
  
  data_ratio           <- filtered.num %>%
                          mutate(baseline = filtered.num[,3]/filtered.den[,3], 
                                 scenar = filtered.num[,4]/filtered.den[,4]) %>% 
                          as.data.frame() %>% 
                          select(variable, year, baseline, scenar, commodity, sector, country)
  names(data_ratio)    <- names(data)
  data_ratio$variable  <- str_replace_all(string = data_ratio$variable, pattern = numerator, replacement = rationame)

  data_ratio
}
