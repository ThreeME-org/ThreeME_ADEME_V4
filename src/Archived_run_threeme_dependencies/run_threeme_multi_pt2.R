##Solve ThreeME

if(Rsolver == FALSE ){
  ### 1.b Write eviews runfile 
  source(file.path('src','01_Eviews_solver_with_Dynamo.R'))
  }else{
  
  #3.2.2 Solving with R 
    ## Step 2 loading calibrations
    source(file.path("src","0R_calibration.R"))
    
    source(file.path("src","01R_calibration_check.R"))
    # Step 3 solving the model
    source(file.path("src","0R_solver.R"))
  cat("\n Solved !\n")
  
}
