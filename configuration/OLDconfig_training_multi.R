# Parameters
model_folder <- "training"
iso3 <- "TRA"                                    %>% tolower()
scenario <- "g"                          %>% tolower()
classification <- "c0_s0"                      %>% tolower()

scenario_name <- paste(scenario,iso3, sep = "_") %>% tolower()


# Input the base year used for the calibration
baseyear <- 2020
# Set the end of the sample
lastyear <- 2035
# Set the higher lag of the equation
max_lags <- 3
# Calculate first year of simulation
firstyear <- baseyear - max_lags

# Lists files (warning: if more than, place "lists.mdl" last)
lists_files <- c(
  "lists.mdl"
)

# Calibration files (used to initialize variables)
calib_files <- c(lists_files,
  "02.1-calib.mdl"
)

# Model files 
model_files = c(lists_files,
  "02.2-eq.mdl"
  )


# Calibration scripts to use 
calib_baseline <- file.path("configuration","scenarii_calib","1_calib_baseline-steady.R")
calib_scenario <- file.path("configuration","scenarii_calib",paste0("2_calib_shock_",scenario,"_multi.R"))

# Config related to R solver
Rsolver = TRUE          # If TRUE, will try to Use R solver if possible; If FALSE, use Eviews 
rcpp_option = FALSE # ANISSA : FIND A WAY TO DISABLE IF NOT COMPATIBLE 

max_tresthor_capability <- 300 # Max size in kb for a model that tresthor can handle

tolerance_calib_check = 10^-5

warning = TRUE     # If TRUE, will provide solver warning messages

# Config related to Eviews solver 

# Set manually the default location of EViews.exe
path_eviews_exe <- "C:/Program Files/EViews 13/EViews13.exe"

compil = "dynamo"       # Options: "dynamo" or "python"#

load = "new"              # Options for old Python compiler: "new"      or "workfile" 

eviews_timeout = 0       # Define the maximum number of second R waits for the E-views simulation # (0 = no time out)

# Run script providing messages over the consistency of the config file
source("src/0_message_config.R")
