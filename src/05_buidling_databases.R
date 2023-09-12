### Prepare and store the databases in long format from EViews
if(!exists("classification")){classification <- "c28_s32"}

if(file.exists(paste0("src/bridges/bridge_",classification,".R")) & file.exists(paste0("src/bridges/codenames_",classification,".R"))){
  
  # source("src/functions_src/0_loadResults.R")
  source(paste0("src/bridges/bridge_",classification,".R"))
  source(paste0("src/bridges/codenames_",classification,".R"))
  bridge_check = TRUE
}else{
  bridge_check = FALSE
  bridge_sectors = NULL
  bridge_commodities = NULL
  
  
  ### Commodities: c4
  names_commodities <- rbind(
    c('Industry','cind'),
    c('Transport','ctrp'),
    c('Services','cser'),
    c('Energy','cenj'),
    c('Industry','C001'),
    c('Transport','C002'),
    c('Services','C003'),
    c('Energy','C004')
  ) %>%
    as.data.frame() %>% rename(name = V1,code = V2)
  
  ### Sectors: s4
  names_sectors <- rbind(
    c('Industry','sind'),
    c('Transport','strp'),
    c('Services','sser'),
    c('Energy','senj'),
    c('Industry','s001'),
    c('Transport','s002'),
    c('Services','s003'),
    c('Energy','s004')
  ) %>%
    as.data.frame() %>% rename(name = V1,code = V2)
  
} 





if(Rsolver == TRUE){
  ##turn datafull in the datafull long format
  data_list <-  data_full |>    
    aggregate_com_sec(by_com = FALSE,by_sec = FALSE) |> purrr::compact() |> 
    map(~as.data.frame(.x) |> add_com_sec_names())
  }else{

  # 

  # tic()
  # data_list <-purrr::set_names(scenario)   %>% map(~loadResults(.x,
  #                                           by_sector = FALSE, by_commodity = FALSE, 
  #                                           bridge_s = bridge_sectors, bridge_c = bridge_commodities,
  #                                           names_s = names_sectors, names_c = names_commodities,
  #                                           csv_folder = file.path("data","temp","csv")))
  # 
  # data_full <- data_list %>% reduce(full_join, by = c("year", "variable","baseline", "sector" , "commodity")) |>  as.data.frame()
  # toc()
  
  # tic()
  data_list <-purrr::set_names(scenario)  |> map(~read_3me_eviews_csv(file.path("data","temp","csv",str_c(.x,".csv"))  )) %>% 
    reduce(full_join, by = c("year", "variable","baseline")) |> 
    aggregate_com_sec(by_com = FALSE,by_sec = FALSE) |> purrr::compact() |> 
    map(~ as.data.frame(.x) |> add_com_sec_names())

  data_full <- data_list[[1]]
  
  ## to access fully reaggregated data
  # data_com_sec <- data_list[[4]]
  # toc()
  
  # 
  #### Optional : to save each scenario in an individual base 
  
  # 
  # data_list %>% imap(~saveRDS(add_com_sec_names(.x), 
  #                             file = file.path("data","output",paste0("data/output/",project_name,"_",.y,".rds")) ))
  
  
  ## Save full database

  
}
  saveRDS(data_full , file = file.path("data","output", paste0(project_name,".rds")))
  
  