rm(list = ls())

# Load functions
source("src/functions.R")

## Sector commodity classification used
classification <- "c28_s32"
source(paste0("src/bridges/codenames_",classification,".R"))

# Load functions creating mdl files from Excel data
source("src/functions_src/001_ExportCalibration_elas.R")
source("src/functions_src/001_ExportCalibration_elas_nrj.R")
source("src/functions_src/001_ExportCalibration_BUIL.R")
source("src/functions_src/001_ExportCalibration_TRANSPORT.R")

# Create mdl calibration files
ExportCalibration_elas("FRA", names_sectors)
ExportCalibration_elas_nrj("FRA", names_sectors)
ExportCalibration_BUIL("FRA")
ExportCalibration_TRANSPORT("FRA")
