###Basics  
scenario_name <- str_c(str_to_lower(scenario), "_", str_to_lower(iso3))
# Define the path of Eviews default directory
eviews_default_path <- str_c(getwd(), "/src/EViews/")

###############################
## RunThreeME steps
###############################  

### 0 CHECKS

# Checking for tresthor
if(Rsolver){
  if( !"tresthor" %in% installed.packages()){
    cat("tresthor not found. EViews will be used.\n")
    Rsolver <- FALSE
  }
}

if (compil == "python") {
  ## if python compiler is used, then solver must be EViews solver
  compil = "dynamo"
  cat("\n Multiple simulations runs must use Dynamo compiler. \n")
  Rsolver <- FALSE
  
}

if (warning) {
  ##  
  warnings = "warnings"
}else{
  warnings = "nowarnings"}

# Add complete path for compiler
lists_files <- file.path("model", model_folder, lists_files)
calib_files <- file.path("model", model_folder, calib_files)
model_files <- file.path("model", model_folder, model_files)

### 1.a Modify mdl lists
readLines(file.path("src",last(lists_files))) %>%
  str_replace_all("(^\\s*%baseyear\\s*:=\\s*).*$", str_c("\\1", baseyear)) %>%
  # str_replace_all("(^include\\s+\\.\\\\R_lists).*$", str_c("\\1_", iso3)) %>%
  writeLines(file.path("src",last(lists_files)))


#3.2.0 Dynamo
  cat("Running DynaMo compiler \n")
  # Run the DynaMo compiler
  
  ### supprimer les output dynamo
  ermeeth::runDynaMo(iso3, baseyear, lastyear, calib_files, model_files, max_lags)
  
  
  #### bug correction if dynamo doesn't put the files in the right place #### 
  dynamo_files_out <- c("calib.csv","model.prg") 
  
  quietly(map)(dynamo_files_out , 
               function(file = .x){ 
                 
                 if( file.exists(file) ){
                   
                   file.copy(from=file , 
                             to = file.path("src","compiler",file),
                             overwrite = TRUE) 
                   file.remove(file)
                   
                 }
               })$result
  #### ####  ####  ####  ####  ####  ####  ####  ####  ####  ####  ####  ####
  
  
  if(file.size("src/compiler/model.prg") > max_tresthor_capability *1000  ){
    Rsolver <- FALSE
    cat("Model is too large for current R solver capabilities, will use Eviews instead.\n")
  }
  
  #3.2.1 Solving with Eviews 
  if(Rsolver == FALSE ){
    ### 1.b Write eviews runfile 
    source(file.path("src","01_write_eviews_run.R"))
  }else{
    
    #3.2.2 Solving with R 
    ## Step 1 build the model
    source(file.path("src","0R_model_maker.R"))
    
    
  }
  
  
  