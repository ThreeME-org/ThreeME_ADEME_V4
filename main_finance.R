## MAIN TO RUN THE MODEL

rm(list = ls())
options(scipen = 14)


## 1. Load all Packages and Functions
source(file.path("src","functions.R"))

## 2. Load Configuration File 
source(file.path("configuration","config_finance.R"))
#file.edit(file.path("configuration","config_finance.R"))

## 3. Run ThreeME 
source(file.path("src","00_Run_ThreeME.R"))

## 4. Treating output databases
source(file.path("src","05_buidling_databases.R"))

## 5. Saving files

## 6. Generating markdowns 
if(annexes==TRUE){
  for (scen in scenario){
    
    output_file = paste0("Results_",project_name,"_",scen,"_",format(Sys.time(), "%Y-%m-%d_%H-%M-%S"))
    
    rmarkdown::render(input = file.path("results","report","markdown","finance","FinancialMarkets_Results.qmd"),

                      output_dir = file.path("results","report","render"),
                      output_file = output_file,
                      output_format = "slidy_presentation",
    
                      params = list(scenario_to_analyse = scen,
                                    project_name = project_name,
                                    classification = classification,
                                    startyear = 2020,
                                    endyear = 2030,
                                    compil = compil,
                                    Rsolver = Rsolver
                                    
                                    
                      ))
    browseURL(file.path("results","report","render",paste0(output_file,".html") ))
    
  }
} 
