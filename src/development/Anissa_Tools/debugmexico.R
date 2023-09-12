rm(list = ls())


## debug Mexico
data <- read.csv("Anissa_Tools/baselinescen.csv")
data_growth <- data %>% 
 ### Compute growth rates 
  mutate_all(~.x/lag(.x)-1 ) %>% 
  filter(!is.na(X)) %>% 
  select(-X,-year) 

n = nrow(data) -1

#### NA COUNTS
check_list <- as.list(data_growth) %>% 
  map( ~list(data =.x, nacount = sum(is.na(.x) ), zerocount = length(.x[.x==0]) )   ) 

na_counts_data <- map_dbl( check_list , ~.x[[2]]) 
all_nas <- names(na_counts_data)[which(na_counts_data==n)]

zero_counts_data <- map_dbl( check_list , ~.x[[3]]) 
all_zeros <- names(zero_counts_data)[which(zero_counts_data==n)]


###REMOVED ALL NAS
data_treated <- data_growth %>% select(-all_of(c(all_nas,all_zeros)) )

### Constant growth rates
constants <- as.list(data_treated) %>% 
  map( ~list(data =.x, dupes = sum(duplicated(round(.x,n-1) )))   ) 

dupes_data <- map_dbl( constants , ~.x[[2]]) 
all_dupes <- names(dupes_data)[which(dupes_data==n-1)]

###REMOVED ALL dupes
data_treated <- data_treated %>% select(-all_of(all_dupes))

plop <- names(data_treated)

data %>%  select(all_of(plop)) %>% view
