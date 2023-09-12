## MAIN TO RUN THE MODEL

rm(list = ls())
options(scipen = 14)


## 1. Load all Packages and Functions
source(file.path("src","functions.R"))

## 2. Load Configuration File 
# source(file.path("configuration","NEW_config_threeme.R"))
source(file.path("configuration","config_threeme.R"))
#source(file.path("configuration","config_threeme_ademe.R"))


## 3. Run ThreeME 
source(file.path("src","00_Run_ThreeME.R"))

## 4. Treating output databases

source(file.path("src","05_buidling_databases.R"))

## 5. Saving files

## 6. Generating markdowns 

### 6.a All Scenarios together

render_from_template(quarto_to_use =  "basic_results.qmd" ,
                     interim_file_name = "main_results"  ,
                     output_file_name = str_c("main_results_",project_name,"_",format(Sys.time(), "%Y-%m-%d_%H-%M")),
                    
                     quarto_parameters_list = list(scenario = scenario,
                                                   startyear = 2020,
                                                   endyear = 2050,
                                                   project_name = project_name
                                                   ),
                     
                     browse = TRUE)

### 6.b Scenario specific markdown

if(annexes==TRUE){
  for (scen in scenario){
    render_from_template(quarto_to_use =  "annexes.qmd" ,
                         interim_file_name = str_c(scen,".qmd")  ,
                         output_file_name = str_c("detailed_results_",project_name,"_",scen,"_",format(Sys.time(), "%Y-%m-%d_%H-%M")),
                         
                         quarto_parameters_list = list(scenario_to_analyse = scen,
                                                       classification = classification,
                                                       startyear = 2020,
                                                       endyear = 2050,
                                                       project_name = project_name
                                                       ),
                         
                         browse = TRUE)
    
    
  }
}

### 6.c Standard shocks report for all scenarios

render_from_template(quarto_to_use =  "standard_shocks.qmd" ,
                     interim_file_name = str_c(project_name,"_",format(Sys.time(), "%Y-%m-%d_%H-%M")),
                     output_file_name = str_c(project_name,"_",format(Sys.time(), "%Y-%m-%d_%H-%M")),

                     quarto_parameters_list = list(
                                                   startyear = 2020,
                                                   endyear = 2050,
                                                   project_name = project_name,
                                                   country_name = "ADEME_full_version_1%_prod_E"
                     ),

                     browse = TRUE)
