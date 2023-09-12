# run ThreeME

## Step 1. Create calib.csv and model.prg

source(file.path("src","01_compiler.R"))

## Step 2. Generating calibration of baseline and shocks

source(file.path("src","02_calibrating_baseline_and_shocks.R"))

## Step 3. Building/Loading model objects (EViews or R)

source(file.path("src","03_model_builder.R"))

## Step 4. Solve ThreeME

source(file.path("src","04_solving_the_model.R"))
