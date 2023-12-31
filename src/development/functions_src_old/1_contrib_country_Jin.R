
# variable to decompose
#var1 <- "GDP"

# variables decomposed
#var2 <- c("CH","X","M", "I", "G")


# contrib(data %>% filter(year>2021),"GDP",c( "CH","X","M", "I", "G","DS"), scenar = c("oilprice_fra") )
# contrib(data %>% filter(year>2021),"GDP",c( "CH","X","M", "I", "G","DS"), scenar = c("baseline") )
# contrib(data %>% filter(year>2021),"GDP",c( "CH","X","M", "I", "G","DS") )
#
# contrib(data %>% filter(year>2021),"GDP",c( "CH","X","M", "I", "G","DS"), scenar = c("baseline","oilprice_fra") ) #?

# function contrib
## scenario can either be string of length one : "baseline" or a scenario in the database , OR
## two scenario in which cas the difference will be calculated

contrib_country <- function(data, var1, var2, country = NULL,
                    scenar = scenarios,
                    # contrib = TRUE, ## n'est plus nécessaire puisqu'on a renseigne cette info via scenar, remplacé par un contrib_ecart déterminé dans la fonction
                    check_digit = NULL,
                    neg.value = NULL )
{

  if (is.null(scenar)){
    scenar = "baseline"
  }

  ## further checks on scenarios
  if (length(scenar) > 2){
    stop(message = "Indicate a maximum of two scenarios.\n")
  }

  if (length(scenar) == 2 & !"baseline" %in% scenar){
    stop(message = "If two scenarios are given, one must be the ' 'baseline' scenario.\n")
  }

  if (prod(scenar %in% names(data)) == 0 ) {
    not_found <- setdiff(scenar, names(data))
    stop(message = paste0("The '",not_found,"' scenario was not found in the database.\n"))
  }

  if (is.null(check_digit)){
    check_digit = 3
  }
  
  if(is.null(country)){
    stop((message = "The country code is not found.\n"))
  }

  if (is.null(neg.value)){
    neg.value  = paste0("M_",country)
  }

  if(length(scenar)==2){
    contrib_ecart = TRUE
  }else{ contrib_ecart = FALSE}


  var1 = paste0(var1,"_",country)
  var2 = paste0(var2,"_",country)
  
  filtered.var <- c(var1,var2)

  data.contrib <- data %>% filter(variable %in% filtered.var)

  # Weigthts in the baseline scenario
  data.w_baseline <- data.contrib  %>%
    select(variable, year, baseline) %>%
    pivot_wider(names_from = variable,
                values_from = baseline) %>%
    mutate_at(.funs = list(w = ~./get(var1)), .vars = var2) %>%
    select(year, contains("w"))

  if (length(scenar) == 1) {
    data.contrib.1 <- data.contrib %>%  mutate(scenario = .[,scenar]) %>%
      select(variable, year, scenario) %>%
      pivot_wider(names_from = variable,
                  values_from = c(scenario))
  } else {
    shock_scenario <- setdiff(scenar,"baseline")
    ## Diff absolue



    data.contrib.1 <- data.contrib %>%  mutate(scenario = .[,str_c(shock_scenario)] - .[,"baseline"]) %>%
      select(variable, year, scenario) %>%
      pivot_wider(names_from = variable,
                  values_from = scenario)
    ## Diff relative
    data.contrib.2 <- data.contrib %>%  mutate(scenario = .[,str_c(shock_scenario)] / .[,"baseline"] -1) %>%
      select(variable, year, scenario) %>%
      pivot_wider(names_from = variable,
                  values_from = scenario)

  }

  # Imports en négatif
  if (neg.value %in% var2){
    data.contrib.1 <- data.contrib.1 %>% mutate_at(neg.value , ~((-1) *.x))
    data.w_baseline  <- data.w_baseline %>% mutate_at(str_c(neg.value,"_w") , ~((-1) *.x))
  }


  #Calcul des contributions a base de mutate_at
  if (contrib_ecart == FALSE){

    data.contrib <- data.contrib.1 %>%
      mutate_at(.funs = list(w = ~./get(var1)), .vars = var2) %>%
      select(year, contains("w"))

    weight_check <-  round(rowSums(data.contrib[10,]) - data.contrib[10,1], check_digit)

    data.contrib <- data.contrib %>% as.data.frame() %>% `colnames<-`(c("year",var2)) %>%
      pivot_longer(names_to = "variable", values_to = "value", - year)

  } else
  {

    # Check on the weights
    weight_check <-  round(rowSums(data.w_baseline[10,]) - data.w_baseline[10,1],check_digit)

    data.contrib.3 <- data.contrib.2 %>% select(-paste0("GDP_",country))

    data.contrib <-  (data.contrib.3[-1] * data.w_baseline[-1]) %>%
      cbind("year" = data.contrib.3[1], .) %>% as.data.frame() %>%
      pivot_longer(names_to = "variable", values_to = "value", - year)

  }


  # A complter pour calcul de contribution en diff de taux de croissance
  # data.contrib %>% mutate_at(vars(-("year")),lag) %>%
  #select(year, contains("contrib"))  %>% as.data.frame(col.names = c("year",var2)) %>% `colnames<-`(c("year",var2)) %>%
  #pivot_longer(names_to = "variable", values_to = value, - year)

  if(weight_check != 1){
    cat("Weights are not summing to one: Try again !\n")
  } else{
    cat("Weights sum to one: Good job !\n")
  }

  data.contrib
}
