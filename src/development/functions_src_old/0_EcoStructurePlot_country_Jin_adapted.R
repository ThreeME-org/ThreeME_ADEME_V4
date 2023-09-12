plot_struc_pays <- function(data = NULL,
                            indicator = NULL,
                            country = NULL,
                            years = NULL,
                            scenario = NULL,
                            title = NULL,
                            group_by = NULL)
{
  if(length(indicator) > 1){
    stop(message = "Please assign only one indicator. \n")
  }  
  
  if(is.null(title)){
    title <- paste0("Economy structure in terms of ",indicator)
  }
  
  
  data_fig <- data %>%
    imap(~.x %>% 
           filter(year %in% years,
                  grepl(paste(paste0("^",indicator,"_",group_by,"[A-Z0-9]{3}$"),collapse = "|"),variable)) %>%
           mutate(multiscenarii = .y,
                  variable = str_remove(variable, "_[A-Z0-9]{4}$"))) %>%
    reduce(rbind) %>% 
    as.data.frame()
  
  data_fig <- data_fig %>% filter(multiscenarii %in% country)
  
  nb <- length(unique(data_fig[,"multiscenarii"]))
  
  if(group_by == "C"){
    group <- quote(~commodity)
  }else if(group_by == "S"){
    group <- quote(~sector)
  }else if(is.null(group_by) == TRUE){
    group <- quote(~years)
  }

  fig <- ggplot(data_fig, aes(x = multiscenarii, y = data_fig[,scenario], fill = multiscenarii)) + 
    geom_bar(stat = "identity") +
    scale_fill_manual("Country",values = custom.palette(nb)) +
    scale_x_discrete(breaks = NULL) +
    ylab(scenario) +
    xlab("") +
    ggtitle(title) +
    facet_grid(group)
  fig
}
