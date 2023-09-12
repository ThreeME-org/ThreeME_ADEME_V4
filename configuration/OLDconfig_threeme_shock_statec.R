# Parameters
model_folder <- "threeme"
iso3 <- "LUX"                                    %>% tolower()
scenario <- "stand"                          %>% tolower()   # "stand" for standard shock simulations (!!! works with main_shock.R)
classification <- "c23_s26"                      %>% tolower()
scenario_name <- paste(scenario,iso3, sep = "_") %>% tolower()
# Input the base year used for the calibration
baseyear <- 2019
# Set the end of the sample
lastyear <- 2060              # At least 2050 for standard shock simulations
# Set the year of the shock
shockyear <- 2021
# Set the higher lag of the equation
max_lags <- 3
# Calculate first year of simulation
firstyear <- baseyear - max_lags

# Lists files (warning: if more than one, place "lists.mdl" last)
lists_files <- c(
    str_c("R_lists_", iso3,"_",classification, ".mdl"),             # ALL VERSIONS
    "lists.mdl"                                                     # ALL VERSIONS
  )

# Calibration files (used to initialize variables)
calib_files <- c(lists_files,
  str_c("data/R_Calibration_", iso3,"_",classification, ".mdl"),                # ALL VERSIONS
  "data/parameters.mdl",                                                        # ALL VERSIONS
     
  # Calibration of elasticity of substitutions (Producer)
  "data/elasticities.mdl",                                                      # ALL VERSIONS
  "data/Exception_NestedCES_data.mdl",                                        # NESTED CES (PRODUCER) VERSION

  "data/round0.mdl",                         # ALL VERSIONS
  "data/Prices_data.mdl",                    # ALL VERSIONS
  "data/SU_data.mdl",                        # ALL VERSIONS
  "data/Special_data.mdl",                   # ALL VERSIONS
  "data/Other_data.mdl",                     # ALL VERSIONS
  
  "data/Exception_taxes_prices_data.mdl",    # ALL VERSIONS (when commodity tax rate per user)

  # Option Consumer blocks
  "data/Exception_ConsumerNested_data.mdl",          # NESTED CES (CONSUMER) VERSION

  "data/Exception_Other_data.mdl",                       # ALL VERSIONS
  str_c("data/Exception_", iso3,"_",classification, "_data.mdl"), # ALL VERSIONS
  "data/Exception_energybalance_simple.mdl",  # ALL VERSIONS: Only net energy production (Y_TOE). Gross primary energy production (YG_TOE) 
  
  "ENDOFLINE.mdl"                          # ALL VERSIONS
)

# Model files 
model_files = c(lists_files,
  "SU.mdl",                     # ALL VERSIONS 
  "Prices.mdl",                 # ALL VERSIONS
  "Producer.mdl",               # ALL VERSIONS
  "Consumer.mdl",               # ALL VERSIONS
  "Government.mdl",             # ALL VERSIONS
  "Trade_inter.mdl",            # ALL VERSIONS
  "Demography.mdl",             # ALL VERSIONS
  "Adjustments.mdl",            # ALL VERSIONS
  "Verif.mdl",                  # ALL VERSIONS
  "ghg_emissions.mdl",          # ALL VERSIONS
  
  # Option energy balance blocks
  "energybalance.mdl",          # ALL VERSIONS

  ## Exception files ALWAYS at the end because of the @over's
  "Exception_taxes_prices.mdl",           # ALL VERSIONS
  "Exception_NestedCES.mdl",            # NESTED CES (PRODUCER) VERSION
  "Exception_ConsumerNested.mdl",       # NESTED CES (CONSUMER) VERSION
  "Exception_Other.mdl",                   # ALL VERSIONS
  str_c("Exception_", iso3,"_",classification, ".mdl"), # ALL VERSIONS
  "ENDOFLINE.mdl"                          # ALL VERSIONS
)

# Calibration scripts to use
calib_baseline <- file.path("configuration","scenarii_calib","1_calib_baseline_statec.R")
#calib_baseline <- file.path("configuration","scenarii_calib","1_calib_baseline-steady.R")
calib_scenario <- file.path("configuration","scenarii_calib",paste0("2_calib_shock_",scenario,".R"))

# Config related to output files and Markdown
language <- "en"
time = format(Sys.time(), "%Y-%m-%d_%H-%M-%S")  # Define time (used in output files)
color_theme = "SAND" #Choose color theme between SAND and ROSE (you can also add a new one by modifing shock_simulation.Rmd)

# Save 
save_files_res = FALSE

# Config related to R solver
Rsolver = FALSE          # If TRUE, will try to Use R solver if possible; If FALSE, use Eviews 
rcpp_option = FALSE # ANISSA : FIND A WAY TO DISABLE IF NOT COMPATIBLE 

max_tresthor_capability <- 300 # Max size in kb for a model that tresthor can handle

tolerance_calib_check = 10^-3

warning = FALSE     # If TRUE, will provide solver warning messages

if(rcpp_option == TRUE){ ## need to check superlu intstallation
  Sys.setenv("CPATH"="/opt/homebrew/include")
  Sys.setenv("LIBRARY_PATH"="/opt/homebrew/lib")
  Sys.setenv("PKG_LIBS"="-lsuperlu")}

# Config related to Eviews solver 

# Set manually the default location of EViews.exe
path_eviews_exe <- "C:/Program Files/EViews 13/EViews13.exe"

compil =  "dynamo"       # Options: "dynamo" or "python"#

load = "new"              # Options for old Python compiler: "new"      or "workfile" 

eviews_timeout = 0       # Define the maximum number of second R waits for the E-views simulation # (0 = no time out)

# Run script providing messages over the consistency of the config file
source("src/0_message_config.R")
