source(stringr::str_c("plot_main.R"), local = TRUE)
source("threeme_results.R")



rep.data <- list()



plot.dir <- "plot_GDP"

for (sc in scenario){
  rep.data[[str_c("df_",sc)]] <-  loadResults(sc)  %>% filter( year %in% c(year_min:year_max))
}

### Data manipulation integration of the different scenarios into one dataframe
dat <- rep.data[[str_c("df_",sc)]][,c("variable","year")] %>%
  filter(str_detect(variable,"^GDP$"))

for (sc in scenario){
  data <- rep.data[[str_c("df_",sc)]] %>%
    filter(str_detect(variable,"^GDP$")) %>% 
    mutate(value = get(sc)/baseline-1)  %>% 
  
    select(value) %>%
    `colnames<-`(sc)
  dat <- cbind(dat, data) 
}

# Dataframe for the plot
data_plot <- dat %>% 
  pivot_longer(names_to ="scenario", -c(variable, year)) 


### Plot creation 
plot.1 <- ggplot(data =  data_plot, aes(x = year, y = value)) +
  geom_line(aes(linetype = scenario)) +
  #scale_linetype_manual(values = line_scenario) +
  scale_y_continuous(labels = label_percent(accuracy = 0.1)) + 
  theme_classic() + 
  theme(
    plot.title = element_text(size = 12, family = police, hjust = 0.5),
    plot.subtitle = element_text(size = 8, family = police),
    legend.text= element_text(size = 14, family = police),
    #axis.line = element_line(colour = "gray", 
    #                         size = 0.3, linetype = "solid"),
    axis.title.x = element_text(size = 16 ,family = police),
    axis.title.y = element_text(size = 12,family = police), 
    axis.text.x =  element_text( size = 14,family = police),
    axis.text.y = element_text( size = 14, family = police, hjust = 0.5),
    panel.grid  = element_blank(), 
    legend.title = element_blank()
  ) +
  labs(
    title= str_c("Gross domestic Product"), 
    subtitle =  "Scenario Oil price shocks" ,
    caption="",
    x= "",
    y=""
  )  


## Creation of the different folders for the results
for (frmt in c(format_img, "data")){
  dir.create(str_c(user_path,path_res.plot,frmt,"/", plot.dir,"/"), recursive = TRUE)
}  
## Export of the results / dataset for the plot and the images in different formats
write.csv(data,str_c(user_path,path_res.plot,"/data/", plot.dir,"/",plot.dir,".data.csv"))

for (frmt in c(format_img)){
  ggsave(str_c(plot.dir,".",frmt), plot.1, device = frmt, path = str_c(user_path, path_res.plot,frmt,"/", plot.dir), width = 300 , height = 300 , units = "mm", dpi = 600)
}
