### Sector plots


### CURVE PLOTS
####################################################################

curve_sc_plot <- function(data , variable, group_type = "sector",
                          scenario = scenario_name, 
                          diff = FALSE ,
                          title = "" , 
                          scenario.names = NULL,
                          start_year = NULL, end_year = NULL,
                          template = template_default,
                          scenario.diff.ref = "baseline", contrib = FALSE, growth.rate = FALSE,abs.diff = FALSE){
  
  #########################
  ### 0. Running Checks ###
  #########################
  # browser() 
  #### Checking group_type
  if(is.character(group_type)== FALSE){
    stop(message = " Argument group_type must be a character string starting with s for sectors or c for commodities.\n")
  }else{
    group <- toupper(str_replace(group_type,"^(.).*$","\\1" ))
  }
  
  if(!group %in% c("S", "C")){
    stop(message = " Argument group_type must be a character string starting with s for sectors or c for commodities.\n")
  }
  
  if(group == "S"){division_type = "Sector" }
  if(group == "C"){division_type = "Commodity" }

  
  #### scenario_name check
  if (is.null(scenario)){
    scenario <- "baseline"
  }
  
  if (length(scenario) == 1 & prod(scenario %in% colnames(data)) == 0 ){
    cat(paste0("Scenario '",scenario,"' was not found in the database. Will plot baseline instead. \n"   ))
    scenario <- "baseline"
  }
  
  if (length(scenario) == 1 & prod(scenario %in% colnames(data)) == 0){
    stop(message = paste0("Scenario '",scenario,"' was not found in the database. \n"   ))
  }
  
  if(length(scenario) > 1 & prod(scenario %in% colnames(data)) == 0){
    scenario <- intersect(scenario , colnames(data))
    if(is_empty(scenario)){ stop(message = paste0("The specified scenario_name were not found in the database. \n"   )) }
  }
  
  n.scen <- length(scenario)
  
  if(is.null(scenario.names)){scenario.names <- gsub("(_|\\.)"," ",scenario)}
  if(length(scenario.names) != n.scen){scenario.names <- gsub("(_|\\.)"," ",scenario)}
  
  
  #### diff checks  
  if(diff == TRUE){
    if(is.null(scenario.diff.ref)){scenario.diff.ref <- "baseline"}
    scenario.diff.ref <- scenario.diff.ref[1]
    
    if(!scenario.diff.ref %in% colnames(data)){
      stop(message = paste0("The reference scenario '",scenario.diff.ref , "' was not found in the database. \n"   ) ) 
    }
  }
  
  #### Determining years to plot
  
  
  if(is.null(start_year) ){
    start_year = min(data$year)
  }
  
  if(start_year < min(data$year)){
    start_year = min(data$year)
  }
  
  if(is.null(end_year) ){
    end_year = max(data$year)
  }
  
  if(end_year > max(data$year)){
    end_year = max(data$year)
  }
  
  
  years_to_plot <- unique(c(seq(from = start_year, to  = end_year, by  = 1))) 
  
  #############################
  ### 1. Preparing the data ###
  #############################
  
  #### Check that the variables exists
  var_vec <- unique(data$variable)
  
  liste_var <- var_vec[grep(paste0("^",variable,"_",group,"[A-Z0-9]{3}$"),var_vec)]
  
  if(length(liste_var) == 0 ){
    liste_var
    stop(message = "No variables matching the variable and the group_type were found.\n") }
  
  #### Building the data_base   
  
  ##### Calcuting growth rates
  
  if(growth.rate == TRUE){
  all.scen <- scenario
  if(diff == TRUE){all.scen <- unique(c(all.scen,scenario.diff.ref))}
    
      data <-data %>% 
      filter(variable %in% liste_var) %>% 
      group_by(variable) %>% arrange(variable, year) %>% 
      mutate_at(all.scen,~(.x/lag(.x) - 1)) %>% ungroup()
  }
  
  ##### No diffs    
  
  if(diff == FALSE){
    graph_data <- data %>% 
      
      filter(variable %in% liste_var) %>%
      filter(year %in% years_to_plot) %>%
      
      pivot_longer(cols = all_of(scenario))  %>% mutate(grouping = paste0(variable,"_",name))
  }else{
    
    ##### With diffs
    if (abs.diff== FALSE){
    graph_data <- data %>% 
      
      filter(variable %in% liste_var) %>%
      filter(year %in% years_to_plot) %>% {
        if(contrib == FALSE)
          mutate_at(.,scenario, ~((.x/get(scenario.diff.ref))-1)) else 
            . } %>% ## replace with contrib
      pivot_longer(cols = all_of(scenario))  %>% mutate(grouping = paste0(variable,"_",name))
    }else{
      graph_data <- data %>% 
        
        filter(variable %in% liste_var) %>%
        filter(year %in% years_to_plot) %>% {
          if(contrib == FALSE)
            mutate_at(.,scenario, ~(.x-get(scenario.diff.ref))) else 
              . } %>% ## replace with contrib
        pivot_longer(cols = all_of(scenario))  %>% mutate(grouping = paste0(variable,"_",name))
    }
    
    
    
    
  }
  
  graph_data <- as.data.frame(graph_data)
  graph_data$CAT <- graph_data[,tolower(division_type)]
  graph_data$name <- str_replace_all(graph_data$name,set_names(scenario.names,scenario))  
  
  
  
  
  
  
  ########################
  ### 2. Drawing Plots ###
  ########################
  color_outerlines = "gray42"
  
  color_gridlines = "gray84"
  ##Differentiate plot arguments according to number of scenario_name
  if(n.scen > 1){
    res_plot  <- ggplot(data=graph_data,
                        aes(group= c(grouping),y = value, x = year,color= CAT)) +
      geom_point(size=0)+
      geom_line(aes(linetype=name))  +
      
      labs(linetype = "Scenario" ) +
      
      scale_linetype_manual(values=c("dashed","solid")) ##order automatically later
    
  }else{
    res_plot  <- ggplot(data=graph_data,
                        aes(group= c(grouping),y = value, x = year,color= CAT)) +
      geom_point(size=0)+
      geom_line() 
  }
  
  ##Common arguments to both types
  
  res_plot <-  res_plot +
    
    labs(title = title,
         color = "" ) +
    ylab("")+xlab("") +
    scale_color_brewer(palette = "Dark2")+
    theme(legend.position = "bottom") 
    
  if(template =="ofce"){
    res_plot <- res_plot +  ofce::theme_ofce(base_family = "")
  } 
         
   ##
  if(growth.rate== TRUE & abs.diff == FALSE){
    res_plot<-res_plot +scale_y_continuous(labels = scales::percent_format())  
  }
  if(growth.rate== TRUE & abs.diff == TRUE){
    res_plot<-res_plot +scale_y_continuous(labels = scales::percent_format(suffix = ""))  
  }
  if(growth.rate== FALSE & abs.diff == FALSE & diff == TRUE ){
    res_plot<-res_plot +scale_y_continuous(labels = scales::percent_format())  
  }
  res_plot <- res_plot +
    
    
    theme(axis.title.y.right = element_blank(),                
          axis.text.y.right = element_blank(),      
          axis.ticks.y.right = element_blank(),      
          axis.title.x.top = element_blank(),                  
          axis.text.x.top = element_blank(),      
          axis.ticks.x.top = element_blank(), 
          
          axis.line.x.top = element_line(colour = color_outerlines, size = 0.5),
          axis.line.y.right = element_line(colour = color_outerlines, size = 0.5),
          axis.line.x.bottom = element_line(colour = color_outerlines, size = 0.5),
          axis.line.y.left = element_line(colour = color_outerlines, size = 0.5),
          
          panel.grid.major.x = element_blank(),
          panel.grid.minor.x = element_blank(),
          
          panel.grid.major.y = element_line(colour = color_gridlines,size = 0.5,linetype = "dashed"),
          panel.grid.minor.y = element_line(colour = color_gridlines,size = 0.5,linetype = "dashed"),
          
    )
          
  
  res_plot 
  
}



### STACKED BAR PLOTS


stacked_sc_plot <- function(data , variable, group_type = "sector",
                            scenario = scenario_name, 
                            diff = FALSE ,
                            title = "" , 
                            scenario.names = NULL,
                            interval = 10,
                            start_year = NULL, end_year = NULL,
                            scenario.diff.ref = "baseline", contrib = FALSE,
                            template = template_default,
                            corner_text = "in Millions"){
  
  #########################
  ### 0. Running Checks ###
  #########################
  # browser()
  #### Checking group_type
  if(is.character(group_type)== FALSE){
    stop(message = " Argument group_type must be a character string starting with s for sectors or c for commodities.\n")
  }else{
    group <- toupper(str_replace(group_type,"^(.).*$","\\1" ))
  }
  
  if(!group %in% c("S", "C")){
    stop(message = " Argument group_type must be a character string starting with s for sectors or c for commodities.\n")
  }
  
  if(group == "S"){division_type = "Sector" }
  if(group == "C"){division_type = "Commodity" }
  
  
  
  #### scenarios check
  if (is.null(scenario)){
    scenario <- "baseline"
  }
  
  if (length(scenario) == 1 & prod(scenario %in% colnames(data)) == 0 ){
    cat(paste0("Scenario '",scenario,"' was not found in the database. Will plot baseline instead. \n"   ))
    scenario <- "baseline"
  }
  
  if (length(scenario) == 1 & prod(scenario %in% colnames(data)) == 0){
    stop(message = paste0("Scenario '",scenario,"' was not found in the database. \n"   ))
  }
  
  if(length(scenario) > 1 & prod(scenario %in% colnames(data)) == 0){
    scenario <- intersect(scenario , colnames(data))
    if(is_empty(scenario)){ stop(message = paste0("The specified scenarios were not found in the database. \n"   )) }
  }
  
  n.scen <- length(scenario)
  
  if(is.null(scenario.names)){scenario.names <- gsub("(_|\\.)"," ",scenario)}
  if(length(scenario.names) != n.scen){scenario.names <- gsub("(_|\\.)"," ",scenario)}
  
  
  
  #### diff checks  
  if(diff == TRUE){
    if(is.null(scenario.diff.ref)){scenario.diff.ref <- "baseline"}
    scenario.diff.ref <- scenario.diff.ref[1]
    
    if(!scenario.diff.ref %in% colnames(data)){
      stop(message = paste0("The reference scenario '",scenario.diff.ref , "' was not found in the database. \n"   ) ) 
    }
  }
  
  #### Determining years to plot
  
  if(is.null(interval) ){
    interval = 5
  }else{
    interval <- round(interval,0)
  }
  
  if(is.null(start_year) ){
    start_year = min(data$year)
  }
  
  if(start_year < min(data$year)){
    start_year = min(data$year)
  }
  
  if(is.null(end_year) ){
    end_year = max(data$year)
  }
  
  if(end_year > max(data$year)){
    end_year = max(data$year)
  }
  
  
  years_to_plot <- unique(c(seq(from = start_year, to  = end_year, by  = interval))) 
  
  #############################
  ### 1. Preparing the data ###
  #############################
  
  #### Check that the variables exists
  var_vec <- unique(data$variable)
  
  liste_var <- var_vec[grep(paste0("^",variable,"_",group,"[A-Z0-9]{3}$"),var_vec)]
  
  if(length(liste_var) == 0 ){
    liste_var
    stop(message = "No variables matching the variable and the group_type were found.\n") }
  
  #### Building the data_base   
  
  ##### No diffs    
  # browser()
  if(diff == FALSE){
    graph_data <- data %>% 
      
      filter(variable %in% liste_var) %>%
      filter(year %in% years_to_plot) %>%
      
      pivot_longer(cols = all_of(scenario))  
  }else{
    
    ##### With diffs  
    graph_data <- data %>% 
      
      filter(variable %in% liste_var) %>%
      filter(year %in% years_to_plot)%>% 
      mutate(scen.diff = get(scenario.diff.ref)) %>% 
      mutate_at(.vars =  scenario,~( .x -scen.diff )) %>% 
      select(-scen.diff) %>% 
      pivot_longer(cols = all_of(scenario))  
    
  
  }
  
  graph_data <- as.data.frame(graph_data)
  graph_data$CAT <- graph_data[,tolower(division_type)]
  graph_data$name <- str_replace_all(graph_data$name,set_names(scenario.names,scenario))  
  
  
  ########################
  ### 2. Drawing Plots ###
  ########################
  color_outerlines = "grey22"
  
  color_gridlines = "gray84"
  
  if (n.scen > 1){
    graph_data <- graph_data %>% mutate(
    scen.type = as.numeric(as.factor(name))  
    )
    
    res_plot <-  ggplot(data = graph_data ,aes(x=scen.type)) +
      geom_bar(aes(fill=factor(CAT), y=value ),
               position=position_stack(),
               stat="identity" ) +
      
      scale_x_continuous(breaks = 1:n.scen,
                         labels = scenario.names,
                        
                         sec.axis = dup_axis()) +
      
      facet_grid(~year, switch="x") +
      
      theme(panel.spacing.x=unit(0, "lines") ,
            panel.spacing = unit(0, "mm"),                       # remove spacing between facets
            
            strip.background = element_rect(size = 0.5,colour = "transparent"),
            strip.placement = "outside" ,
            strip.text.x =element_text(face = "bold")  ,
              
            panel.border = element_rect(colour = color_gridlines,fill = NA,size = 0.5),
            axis.text.x.bottom = element_text(face = 'italic'),
            
            legend.position = "bottom"
            )       
      
    if(template =="ofce"){
      res_plot <- res_plot +  ofce::theme_ofce(base_family = "")
    } 
    
  }else{
    
    res_plot  <-  ggplot(data = graph_data ,aes(x=year)) +
      geom_bar(aes(fill=factor(CAT), y=value ),
               position=position_stack(),
               stat="identity" ) +
      
      scale_x_continuous(breaks = years_to_plot,    # simulate tick marks for left axis
                         sec.axis = dup_axis()) +
      theme(panel.border = element_rect(colour = color_outerlines,fill = NA,size = 0.5),
            axis.text.x.bottom = element_text(face = 'bold'),
            legend.position = "bottom")

    if(template =="ofce"){
      res_plot <- res_plot +  ofce::theme_ofce(base_family = "")
    } 

  }
  
  res_plot <- res_plot +
    labs(title = title,
         fill = "") +
    scale_fill_brewer(palette = "Dark2")+ xlab("") +ylab("") +
    
    geom_abline(intercept = 0,slope = 0,color = color_outerlines) +
    
    scale_y_continuous(labels = function(x){paste(x)},    # simulate tick marks for left axis
                       sec.axis = dup_axis(breaks = 0)) +
    
    theme(axis.title.y.right = element_blank(),                
          axis.text.y.right = element_blank(),      
          axis.ticks.y.right = element_blank(),      
          # axis.text.y = element_text(margin = margin(l = 1)),  # move left axis labels closer to axis

          axis.title.x.top = element_blank(),                  
          axis.text.x.top = element_blank(),      
          axis.ticks.x.top = element_blank(), 
          axis.ticks.x.bottom = element_blank(), 
          
          axis.line.x.top = element_line(colour = "transparent", size = 0.5),
          axis.line.y.right = element_line(colour = "transparent", size = 0.5),
          # axis.line.x.bottom = element_line(colour = color_outerlines, size = 0.5),
          # axis.line.y.left = element_line(colour = color_outerlines, size = 0.5),
          # 
          panel.grid.major.x = element_blank(),
          panel.grid.minor.x = element_blank(),
          
          panel.grid.major.y = element_line(colour = color_gridlines ,size = 0.5,linetype = "dashed"),
          panel.grid.minor.y = element_line(colour = color_gridlines, size = 0.5,linetype = "dashed")

          ) 
    
  
  
  res_plot 
  
}
