# # loadResults
# scenarios <- "oilprice_eu28"
# classification <- "c28_s32"
# 
# source(paste0("src/bridges/bridge_",classification,".R"))
# source(paste0("src/bridges/codenames_",classification,".R"))
# 
# by_commodity = TRUE
# by_sector = FALSE
# 
# bridge_c = bridge_commodities
# bridge_s = bridge_sectors
# names_s = names_sectors
# names_c = names_commodities
# 
# rm(list=c("bridge_commodities","bridge_sectors","names_commodities","names_sectors"))

# Load ThreeME Results

#' Load ThreeME results from a csv exported by EViews
#' Note that the csv files must be located in the csv/ directory,
#' baseline results should be indexed by '_0' and scenario results by '_2',
#' and that all scenarios must share the same baseline
#'
#' @param scenarios Name of the scenario csv files (with or without a csv extension)
#' @return A tibble (dataframe) with the following columns:
#'  - variable: name of the ThreeME variable for which the result is reported in a given row
#'  - year: year for which the result is reported in a given row
#'  - one column per scenario, named after the scenario (e.g. "baseline") containing
#'  the values of the results themselves

loadResults <- function(scenarios, 
                        by_commodity = FALSE, 
                        by_sector = FALSE, 
                        bridge_c = NULL,
                        bridge_s = NULL,
                        names_s = NULL,
                        names_c = NULL) {
  # To debug the function step by step, activate line below
  
  # browser()
  
  if(by_commodity == TRUE & is.null(bridge_c)){
    cat("No bridge for commodities specified, results will not be aggregated by commodity.\n")
    by_commodity <- FALSE
  }
  
  if(by_sector == TRUE & is.null(bridge_s)){
    cat("No bridge for sectors specified, results will not be aggregated by sectors.\n")
    by_sector <- FALSE
  }
  
  # Ensure that there's no csv extension
  scenarios %<>% str_replace("\\.csv$", "")
  
  
  data_1 <-1:length(scenarios) %>%
    
    lapply(function(i) {
      res <- fread(paste0("csv/",scenarios[i],".csv"),data.table = FALSE) %>%
        na.omit %>%
        tidyr::pivot_longer(cols = !V1  ) %>% as.data.frame() %>%
        rename(year = V1, variable = name) %>%
        mutate(scenario = ifelse(str_sub(variable, -1, -1) == '0','baseline',scenarios[i])           ,
               variable = str_sub(variable, 1, -3))
      
      if (i > 1) {
        res %>% filter(scenario != 'baseline')
      } else {
        res
      }
    }) %>%
    rbindlist %>%
    
    dcast(variable + year ~ scenario) %>% as.data.frame()
  
  scenarios_var <- names(data_1 %>% select(-variable,-year))
  
  data_1 <- data_1 %>% mutate(subsector = ifelse(grepl("_S[A-Z]{3}$",variable),
                                                 str_replace(variable,"^.+_(S[A-Z]{3})$","\\1"),
                                                 NA) ,
                              subcommodity = ifelse(grepl("_C[A-Z]{3}(_S[A-Z]{3})?$",variable),
                                                    str_replace(variable,"^.+_(C[A-Z]{3})(_S[A-Z]{3})?$","\\1"),
                                                    NA),
                              subcommodity = ifelse(subcommodity =="CONS",NA,subcommodity),
                              subcommodity2 = ifelse(grepl("_C[A-Z]{3}_C[A-Z]{3}(_S[A-Z]{3})?$",variable),
                                                     str_replace(variable,"^.+_(C[A-Z]{3})_C[A-Z]{3}(_S[A-Z]{3})?$","\\1"),
                                                     NA),
                              subcommodity3 = ifelse(grepl("_C[A-Z]{3}_C[A-Z]{3}_C[A-Z]{3}(_S[A-Z]{3})?$",variable),
                                                     str_replace(variable,"^.+_(C[A-Z]{3})_C[A-Z]{3}_C[A-Z]{3}(_S[A-Z]{3})?$","\\1"),
                                                     NA),
                              sector = subsector,
                              commodity = subcommodity, 
                              commodity2 = subcommodity2, 
                              commodity3 = subcommodity3 )
  
  data_1$variable_root <- data_1$variable %>% str_remove("(_C\\w{3})?(_S\\w{3})?$")
  data_1 <-data_1 %>% mutate(
    variable_root = ifelse(grepl("^.*_C\\w{3}_C\\w{3}_S\\w{3}$",variable),
                           str_remove(variable,"_S\\w{3}$"),
                           variable_root),
    variable_root = ifelse(grepl("^.*(_C[A-Z]{3})+$",variable),
                           str_remove(variable,"(_C[A-Z]{3})+"),
                           variable_root),
  )
  
  if(by_sector==TRUE){
    n_sectors <- length(bridge_s)
    ##Create table with sub sector, sector name and sector id
    
    bridge_sector_table <- data.frame(sector_id = paste0("S", 
                                                         formatC(1:n_sectors, width = 3, format = "d", flag = "0") ) ,
                                      sector = names(bridge_s)) %>%
      full_join(bridge_s 
                %>% imap(~data.frame(sector = .y,subsector =.x)) %>%
                  reduce(rbind), by ="sector" ) %>% 
      mutate(subsector = toupper(subsector))
    
    ## replace for all variables sub sector instead of sector id ,
    data_1$variable <- str_replace_all(data_1$variable,
                                       purrr::set_names(bridge_sector_table$sector_id,
                                                        paste0(bridge_sector_table$subsector,"$")
                                       ) )
    
    ## in data frame add sector name and variable root
    sectoral_data <- data_1 %>% select(-sector) %>%
      
      mutate(sector_id = str_extract(variable,"S\\d{3}$")) %>%
      left_join(bridge_sector_table %>% select(sector_id,sector) %>% unique(),
                by = "sector_id") %>%
      
      select(-sector_id) %>% as.data.frame()
    
    data_1 <- sectoral_data
    
    ####### WHERE DATA AGGREGATION BY SECTOR STARTS
    data_full <-data_1
    
    data_sector <- data_full %>% 
      filter(grepl("_S\\w{3}$",variable) == TRUE) 
    
    data_non_sector <-data_full %>% 
      filter(grepl("_S\\w{3}$",variable) == FALSE) %>% 
      select(-subsector)
    
    
    ## Load aggregation rules
    ag_rule_sector <- read_excel("src/bridges/aggregation_rules.xlsx",sheet = "sectors") %>% 
      mutate(check1 = sum + mean + weighted_mean)
    
    # Checks
    # View(ag_rule_sector %>% filter(is.na(weight_var) & weighted_mean == 1) )
    # View(ag_rule_sector %>% filter(check1 != 1) )
    
    
    ## Aggregate by sum and mean
    var_sum <- ag_rule_sector %>%  filter(sum == 1) %>% select(var_root) %>% as_vector()
    var_mean <- ag_rule_sector %>%  filter(mean == 1) %>% select(var_root) %>% as_vector()
    var_w_mean <- ag_rule_sector %>%  filter(weighted_mean == 1) %>% select(var_root) %>% as_vector()
    var_weight <- ag_rule_sector %>%  filter(!is.na(weight_var)) %>% select(weight_var) %>% as_vector()
    ### Petite correction sur var_mean : il y a des variables produits croisés types ES_TRSP_C001_C001_S001
    var_mean_croisees <- data_1 %>% filter(grepl("^ES_[A-Z]+_C\\w{3}_C\\w{3}_S\\w{3}$",variable))%>% 
      select(variable,variable_root) %>% unique() %>% 
      mutate(variable_root =str_remove(variable,"_S\\w{3}$")) 
    
    var_mean <- c(var_mean,unique(var_mean_croisees$variable_root))
    # We add to var mean all var roots that follow same pattern
    
    
    data_sector_sum <- data_sector %>% select(-subsector,-subcommodity,-commodity,-subcommodity2,-commodity2,-subcommodity3,-commodity3 ) %>%
      filter(variable_root %in% var_sum) %>% 
      select(variable, year, all_of(scenarios_var)) %>% 
      group_by(variable,year)  %>% 
      summarise_at(scenarios_var,~sum(.x)) %>% arrange(variable) %>% ungroup()
    
    data_sector_mean <- data_sector %>% select(-subsector,-subcommodity,-commodity,-subcommodity2,-commodity2,-subcommodity3,-commodity3  ) %>%
      filter(variable_root %in% var_mean) %>% 
      select(variable, year, all_of(scenarios_var)) %>% 
      group_by(variable,year)  %>% 
      summarise_at(scenarios_var,~mean(.x)) %>% arrange(variable) %>% ungroup()
    
    var_sector2 <- c(data_sector_mean$variable,data_sector_sum$variable) %>% unique()
    
    data_sector2 <- data_sector %>% 
      filter(variable %in% var_sector2) %>% 
      select(-all_of(scenarios_var),-subsector) %>% unique() %>% 
      left_join(rbind(data_sector_sum,data_sector_mean) , by=c("variable", "year")) %>% 
      arrange(variable, year) 
    
    new_data_sector <- rbind(data_non_sector,data_sector2)  %>% 
      arrange(variable, year) 
    
    rm(data_sector_mean,data_sector_sum,data_sector2)
    
    
    data_sector_w_mean <- data_sector %>% select(-subcommodity,-commodity,-subcommodity2,-commodity2,-subcommodity3,-commodity3 ) %>% 
      filter(variable_root %in% c(var_w_mean)) %>% 
      left_join(ag_rule_sector %>% select(var_root,weight_var ) %>% rename(variable_root = var_root), by = "variable_root")
    
    ag_variables <- data_sector_w_mean %>% select(variable,weight_var) %>% 
      unique() %>%  
      mutate(weight_var = ifelse(grepl("_C\\w{3}_S\\d{3}$",variable)== TRUE,
                                 str_replace_all(variable,
                                                 pattern = "^.*(_C\\w{3})_S\\d{3}$", 
                                                 replacement = paste0(weight_var,"\\1")),
                                 weight_var),
             weight_var = ifelse(grepl("_S\\d{3}$",variable)== TRUE,
                                 str_replace_all(variable,
                                                 pattern = "^.*(_S\\d{3})$", 
                                                 replacement = paste0(weight_var,"\\1")),
                                 weight_var))
    
    
    ## Check that all variables are indeed present
    # var_ag <- ag_variables$weight_var %>% unique()
    # var_not_available  <- setdiff(var_ag,new_data_sector$variable)
    # var_not_available2 <- setdiff(var_ag,data_full$variable)
    
    
    data_sector_w_mean <- data_sector_w_mean %>% 
      select(-weight_var) %>% left_join(ag_variables, by = "variable") 
    
    
    ## add value of weight var for subsector  
    data_sector_w_mean <- data_sector_w_mean %>% 
      left_join(
        data_full %>% 
          filter(variable %in% data_sector_w_mean$weight_var) %>% 
          select(variable, year, all_of(scenarios_var),subsector) %>% 
          rename(weight_var = variable),
        by= c("weight_var","year","subsector")
      ) %>%  
      rename_at(paste0(scenarios_var,".x"),~str_remove(.x,"\\.x$")) %>% 
      rename_at(paste0(scenarios_var,".y"),~str_replace(.x,"\\.y$",".subw")) %>% 
      left_join(
        new_data_sector %>% 
          filter(variable %in% data_sector_w_mean$weight_var) %>% 
          select(variable, year, all_of(scenarios_var),sector) %>% 
          rename(weight_var = variable),
        by= c("weight_var","year","sector")
      ) %>%  
      rename_at(paste0(scenarios_var,".x"),~str_remove(.x,"\\.x$")) %>%
      rename_at(paste0(scenarios_var,".y"),~str_replace(.x,"\\.y$",".totw")) 
    
    data_sector_w_mean <- cbind(data_sector_w_mean,
                                map_df(set_names(scenarios_var,paste0(scenarios_var,".weight")) ,
                                       ~data_sector_w_mean[,paste0(.x,".subw")]/data_sector_w_mean[,paste0(.x,".totw")])) %>% 
      select(-ends_with(".totw"),-ends_with(".subw"),-variable_root,-subsector,-sector,-weight_var)
    
    
    data_sector_w_mean <- cbind(data_sector_w_mean,
                                map_df(set_names(scenarios_var,paste0(scenarios_var,".weighted")) ,
                                       ~data_sector_w_mean[,.x]*data_sector_w_mean[,paste0(.x,".weight")])) %>% select(-all_of(scenarios_var),-ends_with(".weight")) %>% 
      rename_at(paste0(scenarios_var,".weighted"),~str_remove(.x,"\\.weighted$"))
    
    data_sector_weighted <-data_sector_w_mean %>% group_by(variable,year) %>% summarise_at(scenarios_var,sum)
    
    ## verif que toutes les variables à regrouper sont traitées
    # data_sector_var_w <- setdiff(data_sector$variable,new_data_sector$variable)
    # setdiff(unique(data_sector_weighted$variable),data_sector_var_w) 
    
    new_data_sector2 <- data_sector %>% filter(variable %in% data_sector_weighted$variable) %>% 
      select(-all_of(scenarios_var),-subsector) %>% unique() %>% 
      left_join(data_sector_weighted, by=c("variable", "year")) %>% 
      rbind(new_data_sector,.) %>% 
      arrange(variable, year) 
    
    rm(new_data_sector)
    data_1<- new_data_sector2
    rm(data_non_sector,data_sector,data_full,data_sector_w_mean,data_sector_weighted,new_data_sector2,sectoral_data)
    ####### WHERE DATA AGGREGATION BY SECTOR ENDS
    
  }else{
    data_1 <- data_1 %>% select(-subsector)}
  
  
  
  if(by_commodity==TRUE){
    n_commodities <- length(bridge_c)
    
    ##Create table with sub commodity, commodity name and commodity id
    
    bridge_commodity_table <- data.frame(commodity_id = paste0("C", formatC(1:n_commodities, width = 3, format = "d", flag = "0") ) ,
                                         commodity = names(bridge_c)) %>%
      full_join(bridge_c %>% 
                  imap(~data.frame(commodity = .y,subcommodity =.x)) %>% reduce(rbind),
                by ="commodity" ) %>% 
      mutate(subcommodity = toupper(subcommodity))
    
    ## replace for all variables sub commodity instead of commodity id ,
    data_1$variable <- str_replace_all(data_1$variable,
                                       purrr::set_names(paste0("_",bridge_commodity_table$commodity_id),
                                                        paste0("_",bridge_commodity_table$subcommodity)
                                       ) )
    
    ## in data frame add commodity name and variable root
    commodity_data <- data_1 %>% 
      mutate(commodity = str_replace_all(subcommodity, 
                                         purrr::set_names(bridge_commodity_table$commodity,
                                                          bridge_commodity_table$subcommodity )),
             commodity2 = str_replace_all(subcommodity2, 
                                          purrr::set_names(bridge_commodity_table$commodity,
                                                           bridge_commodity_table$subcommodity )),
             commodity3 = str_replace_all(subcommodity3, 
                                          purrr::set_names(bridge_commodity_table$commodity,
                                                           bridge_commodity_table$subcommodity )),
      ) %>% as.data.frame()
    
    ### In commodity variables, it is possible to have up to 3 commodities in the variable name 
    var_data_full<- data_1$variable %>% unique()
    
    ### AGGREGATIoN STARTS HERE
    ## breaking apart commodity data
    data_non_commodity <- commodity_data %>% filter(is.na(subcommodity)) %>% select(-starts_with("subcomm"),-variable_root)
    data_commodity <- commodity_data %>% filter(!is.na(subcommodity))
    
    
    data_commodity_skeleton<-data_commodity %>% select(variable ,sector,
                                                       commodity, commodity2 ,commodity3) %>% unique()
    
    ## The easy cases : if only one commodity or if three commodities
    
    data_commodity_three<- commodity_data %>% filter(!is.na(subcommodity3)) %>%
      group_by(variable,year) %>% 
      summarise_at(scenarios_var,mean) %>% ungroup() %>% as.data.frame()
    
    data_commodity_two <- commodity_data %>% filter(is.na(subcommodity3) & !is.na(subcommodity2)) 
    
    ## Multiple cases :  1- if starts with ADJUST or ES average
    data_commodity_two_mean <- data_commodity_two %>% filter(grepl("^(ADJUST|ES_)",variable)) %>% 
      group_by(variable,year) %>% 
      summarise_at(scenarios_var,mean) %>% ungroup() %>% as.data.frame()
    
    data_commodity_two_sum <- data_commodity_two %>% filter(grepl("^(MGP)",variable)) %>% 
      group_by(variable,year) %>% 
      summarise_at(scenarios_var,sum) %>% ungroup() %>% as.data.frame()
    
    
    data_commodity_two_w_mean <-  data_commodity_two %>% filter(grepl("^(PHI|PMGP|SUBST)",variable)) %>% 
      mutate(var_weight=str_remove(variable,"^(PHI_|P|SUBST_)"))
    
    data_commodity_two_weights <- data_commodity_two %>% filter(grepl("^(MGP)",variable)) %>% 
      select(variable,all_of(scenarios_var),year,subcommodity,subcommodity2) %>% rename(var_weight = variable)
    
    data_commodity_two_w_mean <-  data_commodity_two_w_mean %>% 
      left_join(data_commodity_two_weights,by=c("var_weight","year","subcommodity","subcommodity2")) %>% 
      
      rename_at(paste0(scenarios_var,".x"),~str_remove(.x,"\\.x$")) %>% 
      rename_at(paste0(scenarios_var,".y"),~str_replace(.x,"\\.y$",".subw")) %>% 
      
      left_join(data_commodity_two_sum %>% rename(var_weight = variable) %>% select(var_weight,all_of(scenarios_var),year),
                by=c("var_weight","year")) %>% 
      rename_at(paste0(scenarios_var,".x"),~str_remove(.x,"\\.x$")) %>% 
      rename_at(paste0(scenarios_var,".y"),~str_replace(.x,"\\.y$",".totw")) 
    
    data_commodity_two_w_mean <- cbind(data_commodity_two_w_mean,
                                       map_df(set_names(scenarios_var,paste0(scenarios_var,".weight")) ,
                                              ~(data_commodity_two_w_mean[,paste0(.x,".subw")]) / data_commodity_two_w_mean[,paste0(.x,".totw")]))
    
    data_commodity_two_w_mean <- cbind(data_commodity_two_w_mean,
                                       map_df(set_names(scenarios_var,paste0(scenarios_var,".weighted")) ,
                                              ~data_commodity_two_w_mean[,.x]*data_commodity_two_w_mean[,paste0(.x,".weight")]))  %>%
      select(-all_of(scenarios_var),-ends_with(".weight"),-ends_with(".totw"),-ends_with(".subw"),-var_weight) %>% 
      rename_at(paste0(scenarios_var,".weighted"),~str_remove(.x,"\\.weighted$")) %>% 
      group_by(variable,year) %>% 
      summarise_at(scenarios_var,mean) %>% ungroup() %>% as.data.frame() %>% 
      select(variable,year,all_of(scenarios_var))
    
    p1_data_commodity<- rbind(data_commodity_two_sum,data_commodity_two_mean,data_commodity_two_w_mean,data_commodity_three) %>% 
      left_join(data_commodity_skeleton, by="variable") %>%
      as.data.frame() 
    
    rm(data_commodity_two_sum,data_commodity_two_mean,data_commodity_two_w_mean,data_commodity_two_weights ,data_commodity_three,data_commodity_two)
    ##data_commodity one commodity
    data_commodity_one <- data_commodity %>% filter(is.na(subcommodity2)) 
    
    ag_rule_commodity <- read_excel("src/bridges/aggregation_rules.xlsx",sheet = "commodities") %>% 
      mutate(mean = as.numeric(gsub("\\s+","",mean)),
             check1 = sum + mean + weighted_mean)
    
    # Checks
    # View(ag_rule_commodity %>% filter(is.na(weight_var) & weighted_mean == 1) )
    # View(ag_rule_commodity %>% filter(check1 != 1) )
    
    var_sum    <- ag_rule_commodity %>%  filter(sum == 1) %>% select(var_root) %>% as_vector()
    var_mean   <- ag_rule_commodity %>%  filter(mean == 1) %>% select(var_root) %>% as_vector()
    var_w_mean <- ag_rule_commodity %>%  filter(weighted_mean == 1) %>% select(var_root) %>% as_vector()
    var_weight <- ag_rule_commodity %>%  filter(!is.na(weight_var)) %>% select(weight_var) %>% as_vector()
    
    data_commodity_sum <- data_commodity_one %>% 
      select(variable, year , all_of(scenarios_var),variable_root) %>%
      filter(variable_root %in% var_sum) %>% 
      select(variable, year, all_of(scenarios_var)) %>% 
      group_by(variable,year)  %>% 
      summarise_at(scenarios_var,~sum(.x)) %>% arrange(variable) %>% ungroup()
    
    data_commodity_mean <- data_commodity_one %>% 
      select(variable, year , all_of(scenarios_var),variable_root) %>%
      filter(variable_root %in% var_mean) %>% 
      select(variable, year, all_of(scenarios_var)) %>% 
      group_by(variable,year)  %>% 
      summarise_at(scenarios_var,~mean(.x)) %>% arrange(variable) %>% ungroup()
    
    var_commodity2 <- c(data_commodity_mean$variable,data_commodity_sum$variable) %>% unique()
    
    data_commodity2 <- data_commodity_skeleton %>% 
      filter(variable %in% var_commodity2) %>% unique() %>% 
      left_join(rbind(data_commodity_sum,data_commodity_mean) , by=c("variable")) %>% 
      arrange(variable, year)
    
    new_data_commodity <- rbind(data_non_commodity,data_commodity2)  %>% 
      arrange(variable, year) 
    
    
    rm(data_commodity_mean,data_commodity_sum,data_commodity2)
    
    data_commodity_w_mean <- data_commodity_one %>% select(-sector) %>% 
      filter(variable_root %in% c(var_w_mean)) %>% 
      left_join(ag_rule_commodity %>% select(var_root,weight_var ) %>% rename(variable_root = var_root))
    
    
    ag_variables <- data_commodity_w_mean %>% select(variable,weight_var) %>% 
      unique() %>%  
      mutate(weight_var = ifelse(grepl("_C\\w{3}(_S\\w{3})?$",variable)== TRUE,
                                 str_replace_all(variable,
                                                 pattern = "^.*(_C\\w{3}(_S\\w{3})?)$", 
                                                 replacement = paste0(weight_var,"\\1")),
                                 weight_var) ) 
    ## Check that all variables are indeed present
    # var_ag <- ag_variables$weight_var %>% unique()
    # var_not_available  <- setdiff(var_ag,new_data_commodity$variable)
    #  var_not_available2 <- setdiff(var_ag,data_full$variable)
    
    
    data_commodity_w_mean <- data_commodity_w_mean %>% 
      select(-weight_var) %>% left_join(ag_variables, by = "variable") 
    
    
    data_commodity_w_mean <- data_commodity_w_mean %>% 
      left_join(
        data_commodity %>% 
          filter(variable %in% data_commodity_w_mean$weight_var) %>% 
          select(variable, year, all_of(scenarios_var),subcommodity) %>% 
          rename(weight_var = variable),
        by= c("weight_var","year","subcommodity")
      ) %>%  
      rename_at(paste0(scenarios_var,".x"),~str_remove(.x,"\\.x$")) %>% 
      rename_at(paste0(scenarios_var,".y"),~str_replace(.x,"\\.y$",".subw")) %>% 
      left_join(
        new_data_commodity %>% 
          filter(variable %in% data_commodity_w_mean$weight_var) %>% 
          select(variable, year, all_of(scenarios_var),commodity) %>% 
          rename(weight_var = variable),
        by= c("weight_var","year","commodity")
      ) %>%  
      rename_at(paste0(scenarios_var,".x"),~str_remove(.x,"\\.x$")) %>%
      rename_at(paste0(scenarios_var,".y"),~str_replace(.x,"\\.y$",".totw")) 
    
    
    data_commodity_w_mean <- cbind(data_commodity_w_mean,
                                   map_df(set_names(scenarios_var,paste0(scenarios_var,".weight")) ,
                                          ~data_commodity_w_mean[,paste0(.x,".subw")]/data_commodity_w_mean[,paste0(.x,".totw")])) %>% 
      select(-ends_with(".totw"),-ends_with(".subw"),-variable_root,-subcommodity,-commodity,-weight_var)
    
    # test<- data_commodity_w_mean %>% select(variable,year,ends_with("weight")) %>%
    #   group_by(variable,year) %>% 
    #   summarise_at(paste0(scenarios_var,".weight"), sum)
    
    data_commodity_w_mean <- cbind(data_commodity_w_mean,
                                   map_df(set_names(scenarios_var,paste0(scenarios_var,".weighted")) ,
                                          ~data_commodity_w_mean[,.x]*data_commodity_w_mean[,paste0(.x,".weight")])) %>% select(-all_of(scenarios_var),-ends_with(".weight")) %>% 
      rename_at(paste0(scenarios_var,".weighted"),~str_remove(.x,"\\.weighted$"))
    
    data_commodity_weighted <-data_commodity_w_mean %>% group_by(variable,year) %>% summarise_at(scenarios_var,sum)
    
    # View(data_commodity_weighted %>% group_by(variable) %>% summarise(n=n()))
    
    new_data_commodity2 <- data_commodity_skeleton %>% 
      filter(variable %in% data_commodity_weighted$variable) %>% unique() %>% 
      left_join(data_commodity_weighted, by=c("variable")) %>% 
      rbind(new_data_commodity,p1_data_commodity,.) %>% 
      arrange(variable, year) 
    
    rm(new_data_commodity)
    
    data_1 <- new_data_commodity2 %>% select(-commodity2,-commodity3)
    # setdiff(var_data_full,new_data_commodity2$variable)
    # setdiff(new_data_commodity2$variable,var_data_full)
  }else{
    data_1 <- data_1 %>% select(-variable_root,-subcommodity,-subcommodity2,-subcommodity3,-commodity2,-commodity3)
  }
  
  
  
  ## Give subsector/subcommodity name in sector column if no aggregation is calculated
  if(by_sector == FALSE){
    names_s$code <- toupper(names_s$code)
    data_1$code <- data_1$sector
    data_1 <- left_join(data_1,names_s,by = "code" )  %>% 
      mutate(sector = name) %>% 
      select(-code,-name)
    
  }
  
  if(by_commodity == FALSE){
    names_c$code <- toupper(names_c$code)
    data_1$code <- data_1$commodity
    data_1 <- left_join(data_1,names_c,by = "code" )  %>% 
      mutate(commodity = name) %>% 
      select(-code,-name)
    
  }
  
  
  
  return <- data_1 
}

