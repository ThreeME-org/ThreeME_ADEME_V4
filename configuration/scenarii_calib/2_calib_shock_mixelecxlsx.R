shock_ch <- load_excel_calibration(excel_sheet = "data/input/France/scenarii_inputs_ademe.xlsx",
                                   sheet_to_load = "mix_elec",
                                   stop_if_calib_fail = FALSE,
                                   check_tol = 10e-8,
                                   keep_baseyear_calib_data = TRUE) %>% 
  filter(year %in% c(baseyear:lastyear)) 
