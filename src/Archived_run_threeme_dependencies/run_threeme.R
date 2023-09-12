###Basics  
if(exists("i_multi")){
  scenario_name <- str_c(scenario,"_", iso3,"_",i_multi) %>% str_to_lower
}else{
  scenario_name <- str_c(scenario,"_", iso3) %>% str_to_lower
}

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

 
  #3.1 Eviews solver with python
  if (compil == "python") {
    
    # Modify list of data files for Python old compiler 
    calib_files %>% str_c("include ..\\",.) %>%  str_replace_all("/","\\\\") %>% writeLines("src/model/data_files.mdl")

    model_files %>% str_c("include ..\\",.) %>%  str_replace_all("/","\\\\") %>% writeLines("src/model/model_files.mdl")

    ### 1.b Write eviews runfile 
    source(file.path("src","01_write_eviews_run.R"))
    cat("Running Eviews with old Python compiler.\n")
    sys::exec_wait(path_eviews_exe,c(paste0(path_eviews_default,"run_main_from_R.prg")), timeout = eviews_timeout)
    
    }else{
    
      
    #3.2.0 DYNAMO
    
    cat("Running DynaMo compiler \n")
    dynamo_files_out <- c("calib.csv","model.prg") 
    
    #### ####  ####  ####  ####  ####  ####  ####  ####  ####  ####  ####  #### 
   
    ### A. Remove existing dynamo output

    if(sum(file.exists(file.path("src","compiler",dynamo_files_out)) ) >0 ){
      cat("\n\n  Found pre-existing dynamo output files, deleting them ... \n\n")}
    
    
    
    quietly(map)(dynamo_files_out , 
                 function(file = .x){ 
                   if(file.exists(file.path("src","compiler",file) ) ){
                     file.remove(file.path("src","compiler",file))
                   }
                 })$result
    
    #### ####  ####  ####  ####  ####  ####  ####  ####  ####  ####  ####  #### 
    
    ### B. Run the DynaMo compiler
    ermeeth::runDynaMo(iso3, baseyear, lastyear, calib_files, model_files, max_lags)
    
    #### ####  ####  ####  ####  ####  ####  ####  ####  ####  ####  ####  #### 
    
    ### C. Bug correction if dynamo doesn't put the files in the right place #### 
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

    ### D. STOP IF DYNAMO FAILED
    missing_files <- file.path("src","compiler",dynamo_files_out)[file.exists(file.path("src","compiler",dynamo_files_out)) == FALSE ] %>% basename()
    
    if(length(missing_files) == 0  ){
      cat("\n\n  DYNAMO SUCCEEDED , continuing ... \n\n")
    }else{
      cat("\n\n \U1F4A3 \U1F4A3 DYNAMO couldn't write the following files : \n\n")
      cat(missing_files, sep = "\n")
      
    cat(red("\n\n \U1F4A3 \U1F4A3 Aborting the process \U1F4A3 \U1F4A3 \n\n") %>% bgWhite() )
    stop(error ="Dynamo Error")
    
      
      }
    
   
    
    #### Check that endogenous variables have all been calibrated
    source("src/02_calibrated_variables_check.R")
    

    
    
    ## include temporary check for model size 
    if(file.size("src/compiler/model.prg") > max_tresthor_capability *1000  ){
      Rsolver <- FALSE
      cat("Model is too large for current R solver capabilities, will use Eviews instead.\n")
    }
    
    #### ####  ####  ####  ####  ####  ####  ####  ####  ####  ####  ####  ####   
    
    #3.2.1 Solving with Eviews 
    if(Rsolver == FALSE ){
      ### 1.b Write eviews runfile 
      source(file.path("src","01_write_eviews_run.R"))
      source(file.path('src','01_Eviews_solver_with_Dynamo.R'))
    }else{
      
      #3.2.2 Solving with R 
      ## Step 1 build the model
      source(file.path("src","0R_model_maker.R")) 
      
      ## Step 2 loading calibrations
      source(file.path("src","0R_calibration.R"))
      
      source(file.path("src","01R_calibration_check.R"))
      # Step 3 solving the model
      source(file.path("src","0R_solver.R"))
      
    }


  }  
