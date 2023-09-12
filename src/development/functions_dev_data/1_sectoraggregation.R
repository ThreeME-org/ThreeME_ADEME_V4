## Aggregation by sector
# loadResults
scenarios <- "oilprice_eu28"
classification <- "c28_s32"

source(paste0("src/bridges/bridge_",classification,".R"))
source(paste0("src/bridges/codenames_",classification,".R"))

by_commodity = FALSE
by_sector = TRUE

bridge_c = bridge_commodities
bridge_s = bridge_sectors
names_s = names_sectors
names_c = names_commodities

rm(list=c("bridge_commodities","bridge_sectors","names_commodities","names_sectors"))

data_full <- readRDS("src/functions_dev_data/test_data.rds")


##Aggregation by sector
scenarios_var <- c("baseline",scenarios)
# # Step 1 : figure out which data needs to be aggregated



data_sector <- data_full %>% 
  filter(grepl("_S\\w{3}$",variable) == TRUE) # remove variables that are commodity dependent only 

data_non_sector <-data_full %>% 
  filter(grepl("_S\\w{3}$",variable) == FALSE) %>% # remove variables that are commodity dependent only 
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

data_sector_sum <- data_sector %>% select(-subsector,-subcommodity,-commodity ) %>%
  filter(variable_root %in% var_sum) %>% 
  select(variable, year, all_of(scenarios_var)) %>% 
  group_by(variable,year)  %>% 
  summarise_at(scenarios_var,~sum(.x)) %>% arrange(variable) %>% ungroup()

data_sector_mean <- data_sector %>% select(-subsector,-subcommodity,-commodity ) %>%
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

####### For the weights
## step 1 : get the list of variables from which weight is computed

data_sector_w_mean <- data_sector %>% select(-subcommodity,-commodity) %>% 
  filter(variable_root %in% c(var_w_mean)) %>% 
  left_join(ag_rule_sector %>% select(var_root,weight_var ) %>% rename(variable_root = var_root))

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
