# Define the series that should be interpolated (ONLY 1)
series <- c("rco2tax_vol")   %>% tolower

# Define the date and desired value (DO NOT PUT VALUES FOR THE BASEYEAR DATE !!!)
dates  <- c(2030, 2050)
values <- c(  50,  100)

# Load calibration file
calib <- fread("src/compiler/calib.csv", data.table = FALSE) %>% 
  select(-baseyear) %>% 
  mutate(year = year + baseyear) %>%
  filter(year %in% c(firstyear:lastyear)) 


# Load the selected series
selection <- calib %>% select(year,all_of(series))

## Apply interpolation
for (var in series) {
  shock_ch <- mutate(selection,
                       !!paste0(var) := interpolation_series(
                                                 date_vector = c(firstyear:baseyear,dates),
                                                 value_vector = c(get(paste0(var))[which(year %in% c(firstyear:baseyear))], values),
                                                 first.date = firstyear, 
                                                 last.date = lastyear),
                     redis_ct_h = 0, redis_ct_ls = 0       
  )  
}


# # To visualize result of interpolation function
# interpolation_series(date_vector  = c(2015, 2030, 2050),
#                      value_vector = c(   0,  100,  500),
#                      first.date = 2012, last.date = 2060,
#                      smoothed = TRUE,       # FALSE only linear interpolation
#                      full_results = TRUE)   # TRUE to view graph
