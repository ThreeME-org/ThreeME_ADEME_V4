## Solving through R 

cat("\n Simulating baseline scenario \n")
# Run the model  baseline
baseline_scenario <- thor_solver(threeme,
                                 first_period = baseyear,last_period = lastyear,
                                 database = data_3me_baseline,
                                 index_time = "year", rcpp = rcpp_option,skip_tests = TRUE)
cat("\n Simulating shock scenario \n")
# Run the model  shock
shock_scenario  <- thor_solver(threeme,
                               first_period = baseyear,last_period = lastyear,
                               database = data_3me_shock,index_time = "year", rcpp = rcpp_option)
