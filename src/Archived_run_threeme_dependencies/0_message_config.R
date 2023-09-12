
#######################################################
## Supplementary parameters 
#######################################################
scenario_name <- paste(scenario,iso3, sep = "_") %>% tolower()
shocks_nb <- length(scenario)
max_tresthor_capability <- 300 # Max size in kb for a model that tresthor can handle


if (warning) {
  ##  
  warnings = "warnings"
}else{
  warnings = "nowarnings"}


# DEFINE MESSAGES REGARDING CONFIG

# Define style function for ThreeME message alert
alert_red <- make_style("brown", bg = TRUE)
alert_green <- make_style("green", bg = FALSE)

#######################################################
# Set minimun period of simulation for standard shock
      # Input to test the script 
      # lastyear<-2000
      # scenario<-"stand"
if((standard_shocks) & ((lastyear-shockyear+1)<40)){
  lastyear = shockyear+40-1
  message <- paste0("\U274C Standard shock simulation:\nThe difference between lastyear and shockyear must be greater or equal than 39.\nLastyear has been modified and is now ",lastyear,".\n\n\n")
  cat(alert_red(message))
}

# pink <- make_style("pink")
# bgMaroon <- make_style(rgb(0.93, 0.19, 0.65), bg = TRUE)
# cat(bgMaroon(pink("I am pink if your terminal wants it, too.\n")))
# 
# names(styles())
# cat(styles()[["bold"]]$close)
#######################################################
# Check and detect automatically location of EViews.exe 
      # Input to test the script 
      # nb_eviews.exe <- 0
      # path_eviews_exe <- "C:/Program Files/EViews 10/EViews10_x64.exe"

# Detect location of EViews.exe  
if (grepl("win", tolower(osVersion))){
  if (file.exists(path_eviews_exe) ) {
    message <- paste0("Default EViews path: \nThe EViews path provided (",path_eviews_exe,") is correct. \n")
    cat(alert_green(message))
  } else {
    message <- paste0("Default EViews path: \nThe EViews path provided (",path_eviews_exe,") is incorrect. \n")
    cat(alert_red(message))
    
    nb_eviews.exe <- 0
    for (progfolder in c("C:/Program Files","C:/Program Files (x86)")){  
      for (i in c(8:14)){
        # assign(paste0("eviews.exe.ver",i), paste0("C:/Program Files/EViews ",i,"/EViews",i,".exe"))
        path_eviews_exe_tested <- paste0(progfolder,"/EViews ",i,"/EViews",i,".exe")
        
        if (file.exists(path_eviews_exe_tested)) {
          path_eviews_exe <- path_eviews_exe_tested
          nb_eviews.exe <- nb_eviews.exe + 1
          message <- paste0("Possible path: ", path_eviews_exe, ". \n")
          cat(alert_green(message))
          
        }  
        
        path_eviews_exe_tested <- paste0(progfolder,"/EViews ",i,"/EViews",i,"_x64.exe")
        if (file.exists(path_eviews_exe_tested)) {
          path_eviews_exe <- path_eviews_exe_tested
          nb_eviews.exe <- nb_eviews.exe + 1
          message <- paste0("Possible path: ", path_eviews_exe, ". \n")
          cat(alert_green(message))
          
        } 
      }
    }
    if (nb_eviews.exe == 0) {
      message <- "Warning: No Eviews.exe found! \nCheck if Eviews is installed if you wish to use the EViews solver. \n"
      cat(alert_red(message))
      
    } else {
      message <- paste0(nb_eviews.exe, " path(s) found. \nWe will use: ",  path_eviews_exe, 
                        ". \nChange manually in config (path_eviews_exe <- DESIRED PATH) if you wish otherwise. \n")
      cat(alert_green(message))
    }
  }
}


# Define the path of Eviews default directory
path_eviews_default <- file.path(getwd(), "/src/EViews/")
# (if issue) Define the absolute path of Eviews default directory
# path_eviews_default <- "C:/Users/reynesfgd/GitHub/ThreeME_V3/src/EViews/"
