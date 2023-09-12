## Aggregation by commodity
# loadResults
scenarios <- "oilprice_eu28"
classification <- "c28_s32"

source(paste0("src/bridges/bridge_",classification,".R"))
source(paste0("src/bridges/codenames_",classification,".R"))

by_sector = FALSE
by_commodity = TRUE

bridge_s = bridge_sectors
bridge_c = bridge_commodities
names_c = names_commodities
names_s = names_sectors

rm(list=c("bridge_sectors","bridge_commodities","names_sectors","names_commodities"))

data_full <- readRDS("src/functions_dev_data/test_data.rds")


##Aggregation by commodity
scenarios_var <- c("baseline",scenarios)
# # Step 1 : figure out which data needs to be aggregated



data_commodity <- data_full %>% 
  filter(grepl("_C\\w{3}(_S\\w{3})?$",variable) == TRUE) # remove variables that are sector dependent only 

data_non_commodity <-data_full %>% 
  filter(grepl("_C\\w{3}(_S\\w{3})?$",variable) == FALSE) %>% # remove variables that are sector dependent only 
  select(-subcommodity)


## Load aggregation rules
ag_rule_commodity <- read_excel("src/bridges/aggregation_rules.xlsx",sheet = "commodities") %>% 
  mutate(check1 = sum + mean + weighted_mean)

# Checks
# View(ag_rule_commodity %>% filter(is.na(weight_var) & weighted_mean == 1) )
# View(ag_rule_commodity %>% filter(check1 != 1) )


## Aggregate by sum and mean
var_sum <- ag_rule_commodity %>%  filter(sum == 1) %>% select(var_root) %>% as_vector()
var_mean <- ag_rule_commodity %>%  filter(mean == 1) %>% select(var_root) %>% as_vector()
var_w_mean <- ag_rule_commodity %>%  filter(weighted_mean == 1) %>% select(var_root) %>% as_vector()
var_weight <- ag_rule_commodity %>%  filter(!is.na(weight_var)) %>% select(weight_var) %>% as_vector()

data_commodity_sum <- data_commodity %>% select(-subcommodity,-subsector,-sector ) %>%
  filter(variable_root %in% var_sum) %>% 
  select(variable, year, all_of(scenarios_var)) %>% 
  group_by(variable,year)  %>% 
  summarise_at(scenarios_var,~sum(.x)) %>% arrange(variable) %>% ungroup()

data_commodity_mean <- data_commodity %>% select(-subcommodity,-subsector,-sector ) %>%
  filter(variable_root %in% var_mean) %>% 
  select(variable, year, all_of(scenarios_var)) %>% 
  group_by(variable,year)  %>% 
  summarise_at(scenarios_var,~mean(.x)) %>% arrange(variable) %>% ungroup()

var_commodity2 <- c(data_commodity_mean$variable,data_commodity_sum$variable) %>% unique()

data_commodity2 <- data_commodity %>% 
  filter(variable %in% var_commodity2) %>% 
  select(-all_of(scenarios_var),-subcommodity) %>% unique() %>% 
  left_join(rbind(data_commodity_sum,data_commodity_mean) , by=c("variable", "year")) %>% 
  arrange(variable, year) 

new_data_commodity <- rbind(data_non_commodity,data_commodity2)  %>% 
  arrange(variable, year) 

rm(data_commodity_mean,data_commodity_sum,data_commodity2)

####### For the weights
## step 1 : get the list of variables from which weight is computed

data_commodity_w_mean <- data_commodity %>% select(-subsector,-sector) %>% 
  filter(variable_root %in% c(var_w_mean)) %>% 
  left_join(ag_rule_commodity %>% select(var_root,weight_var ) %>% rename(variable_root = var_root))

ag_variables <- data_commodity_w_mean %>% select(variable,weight_var) %>% 
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
# var_not_available  <- setdiff(var_ag,new_data_commodity$variable)
# var_not_available2 <- setdiff(var_ag,data_full$variable)


data_commodity_w_mean <- data_commodity_w_mean %>% 
  select(-weight_var) %>% left_join(ag_variables, by = "variable") 


## add value of weight var for subcommodity  
data_commodity_w_mean <- data_commodity_w_mean %>% 
  left_join(
    data_full %>% 
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


data_commodity_w_mean <- cbind(data_commodity_w_mean,
                            map_df(set_names(scenarios_var,paste0(scenarios_var,".weighted")) ,
                                   ~data_commodity_w_mean[,.x]*data_commodity_w_mean[,paste0(.x,".weight")])) %>% select(-all_of(scenarios_var),-ends_with(".weight")) %>% 
  rename_at(paste0(scenarios_var,".weighted"),~str_remove(.x,"\\.weighted$"))

data_commodity_weighted <-data_commodity_w_mean %>% group_by(variable,year) %>% summarise_at(scenarios_var,sum)

## verif que toutes les variables à regrouper sont traitées
# data_commodity_var_w <- setdiff(data_commodity$variable,new_data_commodity$variable)
# setdiff(unique(data_commodity_weighted$variable),data_commodity_var_w) 

new_data_commodity2 <- data_commodity %>% filter(variable %in% data_commodity_weighted$variable) %>% 
  select(-all_of(scenarios_var),-subcommodity) %>% unique() %>% 
  left_join(data_commodity_weighted, by=c("variable", "year")) %>% 
  rbind(new_data_commodity,.) %>% 
  arrange(variable, year) 

rm(new_data_commodity)
