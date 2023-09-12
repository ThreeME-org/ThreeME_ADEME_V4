runDynaMo <- function(iso3, baseyear, lastyear, calib, model, max_lags = 3) {
  dynamo_os <- "dynamo.exe"
  if(grepl("macOS",osVersion)){dynamo_os<-"dynamo_mac"}
  
  threeme_path <- str_c(getwd(), "/../src/")
  f <- file("../src/compiler/dynamo.cfg")
  writeLines(c(
    "# CountryCalib",
    str_c(threeme_path, "data/shadowfile_readme.mdl"),
    "",
    "# ListsParameters",
    "",
    "# MaxLags",
    max_lags, "",
    "# Baseyear",
    baseyear, "",
    "# Lastyear",
    lastyear, 
    "",
    "# Calib",
    calib %>% sapply(function(s) str_c(threeme_path, s)),
    "",
    "# Model",
    model %>% sapply(function(s) str_c(threeme_path, s))), f)
  close(f)

  sys::exec_wait(paste0("../src/compiler/",dynamo_os),
                 c(
                   str_c(getwd(), "/../src/compiler/dynamo.cfg"),
                   str_c(getwd(), "/../src/compiler/calib.csv"),
                   str_c(getwd(), "/../src/compiler/model.prg")
                 ),
                 std_out = TRUE, std_err = TRUE, timeout = 0)
}
