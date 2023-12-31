##################################################################################
####### THREEME USER CONFIGURATION
##################################################################################
## Please check sections 1 to 5 before running ThreeME

#########################################
# 1. Basic Parameters
#########################################

automated_shocks <- FALSE # Set to TRUE if you want to use automated shocks, that will read one unique shock scenario file that can run different calibrations according to the scenario name


iso3 <- "MEX"                   %>% tolower()
scenario <- c("ct1","expg1")    %>% tolower()
classification <- "c4_s4"       %>% tolower()
model_folder <- "threeme"
project_name <- "multi_shock"

if (automated_shocks){
  ## if automated shocks, generate range list using 
  source(file.path("configuration","scenarii_calib",str_c("3_automated_parameters_generator_",project_name,".R")))
  scenario <- parameters_range$name   ## if automated shocks , the names will be defined in 3_Automated_parameters_generator.R
}

## Input the base year used for the calibration
baseyear <- 2015
## Set the end of the sample
lastyear <- 2030
## Set the year of the shock
shockyear <- 2021
## Set the higher lag of the equation
max_lags <- 3
## Calculate first year of simulation 
firstyear <- baseyear - max_lags


#########################################
# 2. Files lists for the model
#########################################
skip_compiler <- FALSE # Set to TRUE to skip the compiler part. However, you'll need to ensure to have the correct model.prg and calib.csv files in the src/compiler folder 

## Lists files (warning: if more than one, place "lists.mdl" last)
lists_files <- c(
    str_c("R_lists_", iso3,"_",classification, ".mdl"),             # ALL VERSIONS
    "lists.mdl"                                                     # ALL VERSIONS
  )

## Calibration files (used to initialize variables)
calib_files <- c(lists_files,
  str_c("data/R_Calibration_", iso3,"_",classification,"_",baseyear, ".mdl"),   # ALL VERSIONS
  "data/parameters.mdl",                     # ALL VERSIONS
     
  ## Calibration of elasticity of substitutions (Producer)
  "data/elasticities.mdl",                   # ALL VERSIONS
  # "data/Exception_NestedCES_data.mdl",     # NESTED CES (PRODUCER) VERSION
  "data/round0.mdl",                         # ALL VERSIONS
  "data/Prices_data.mdl",                    # ALL VERSIONS
  "data/SU_data.mdl",                        # ALL VERSIONS
  "data/Special_data.mdl",                   # ALL VERSIONS
  "data/Other_data.mdl",                     # ALL VERSIONS
  "data/Exception_taxes_prices_data.mdl",    # ALL VERSIONS (when commodity tax rate per user)

  ## Optional Consumer blocks
  #  "data/Exception_ConsumerNested_data.mdl",  # NESTED CES (CONSUMER) VERSION

  "data/Exception_Other_data.mdl",           # ALL VERSIONS
  # "data/Exception_energybalance_simple.mdl",  # ALL VERSIONS: Only net energy production (Y_TOE). Gross primary energy production (YG_TOE) 
  
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

  ## Exception files ALWAYS at the end because of the @overs
  "Exception_taxes_prices.mdl",           # ALL VERSIONS
  # "Exception_NestedCES.mdl",            # NESTED CES (PRODUCER) VERSION
  # "Exception_ConsumerNested.mdl",       # NESTED CES (CONSUMER) VERSION

  "Exception_BugSolverR.mdl",      # TEMPORARY : Overwrite equations creating Bugs with R solver
  "Exception_Other.mdl",                   # ALL VERSIONS
  
  "ENDOFLINE.mdl"                          # ALL VERSIONS
)

#########################################
# 2. Calibration scripts to be used
#########################################

## Default Parameters:
calib_baseline <- file.path("configuration","scenarii_calib","1_calib_baseline-steady.R")
calib_scenario <- file.path("configuration","scenarii_calib",paste0("2_calib_shock_",scenario,".R"))

# calib_baseline <- file.path("configuration","scenarii_calib","1_calib_baseline_ademe.R") ## Maybe modified if the baseline needs to integrate some user-specified shocks.
if(automated_shocks){
  calib_scenario <- file.path("configuration","scenarii_calib",paste0("2_calib_shock_",project_name,".R")) ## One unique scenario file will be run  
}

 
#########################################
# 3. Solver configuration
#########################################

Rsolver = FALSE    # If TRUE, will try to Use R solver if possible; If FALSE EViews will be used
warning = TRUE     # If TRUE, will provide solver warning messages
tolerance_calib_check = 10^-4

recompile_model = TRUE # If FALSE, the model will be sourced from its last saved version. In the case of multiple scenarii, the model is never recompiled between shocks  

#################
## 3.A R solver
#################

rcpp_option = FALSE 

### If superlu is installed, switch to TRUE, otherwise FALSE
use.superlu = TRUE 

### Specify here if there is special configuration necessary to  use superlu
if(use.superlu == TRUE){ 
  Sys.setenv("CPATH"="/opt/homebrew/include")
  Sys.setenv("LIBRARY_PATH"="/opt/homebrew/lib")
  Sys.setenv("PKG_LIBS"="-lsuperlu")
  }

#################
## 3.B EViews
#################
## Set manually the default location of EViews.exe
path_eviews_exe <- "C:/Program Files/EViews 10/EViews10_x64.exe"

compil =  "dynamo"       # Options: "dynamo" or "python"#

eviews_timeout = 0       # Define the maximum number of second R waits for the E-views simulation # (0 = no time out)



#########################################
# 4. Output specification
#########################################

## When running more than one shock scenario, set to TRUE to save the full dataset on top of the combined results
save_data_full = FALSE

## Specify here the variables to keep when multiple shock scenarii are ran, keep empty to export all variables.
## If there is only one scenario, all variables will be exported anyways.
#variables_to_keep <- c("RCO2TAX_VOL","GDP","LF", "CH", "I", "X", "M", "PVA", "PCH", "PY", "PX", "PM", "DISPINC_AT_VAL", "W", "RSAV_H_VAL","F_L", "RBAL_TRADE_VAL", "RBAL_G_TOT_VAL", "MARKUP", "UNR","EMS","RSAV_G_VAL","RBAL_G_PRIM_VAL","BAL_TRADE","C_L","VA")
variables_to_keep <- c() # Keep empty to keep all variables. 

# If TRUE, save all files results (take more time and space ; with eviews solver a workfile is saved for each scenario results in \results\eviews;
# If FALSE some results files are not saved
save_files_res = TRUE       


#########################################
# 5. Markdown configuration
#########################################

## Config related to output files and Markdown
language <- "en"
time = format(Sys.time(), "%Y-%m-%d_%H-%M-%S")  # Define time (used in output files)
color_theme = "SAND" #Choose color theme between SAND and ROSE (you can also add a new one by modifing shock_simulation.Rmd)

## Run annexes if annexes is equal to TRUE
annexes = TRUE





##################################################################################
####### END OF USER CONFIGURATION
##################################################################################


#### Relevant Checks
source(file.path("src","00b_ParametersandChecks.R"))
####
