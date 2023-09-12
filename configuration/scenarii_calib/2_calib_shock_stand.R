## 1 GDP point increase of carbon tax

# Load calibration for range baseyear:lastyear
calib <- fread("src/compiler/calib.csv", data.table = FALSE) %>% 
              select(-baseyear) %>% 
              mutate(year = year + baseyear) %>%
              filter(year %in% c(baseyear:lastyear)) 

source(file.path("configuration","scenarii_calib",paste0("2_calib_shock_",i_multi,".R")))
