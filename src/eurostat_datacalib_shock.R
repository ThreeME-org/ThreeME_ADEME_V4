library(eurostat)

iso <- "EU28"

## Data on oil nrg_ti_oil table 
data_gas <- get_eurostat("nrg_ti_gas") %>% filter(geo == iso)
#SIEC G3000: Natural Gas 
#SIEC 3200: LNG 



data_oil <- get_eurostat("nrg_ti_oil") %>% filter(geo == iso)

data_oil %>% filter(partner %in% c("RU","TOTAL"), 
                    geo == iso,
                    unit == "THS_T", 
                    siec == "O4000") %>% #Oil and petroleum products 
  select( partner,time, values) %>%
  pivot_wider( names_from = "partner", values_from = "values") %>%
  mutate(RU_share = RU/TOTAL)


data_plot <- get_eurostat("nrg_ti_gas") %>%
  filter(partner %in% c("RU","TOTAL"), 
         unit == "MIO_M3", 
         siec == "G3000", 
         time == "2020-01-01") %>% #SIEC G3000: Natural Gas 
  select(geo, partner, values) %>%
  pivot_wider( names_from = "partner", values_from = "values") %>%
  mutate(RU_share = RU/TOTAL)

data_plot.2 <- get_eurostat("nrg_ti_oil") %>%
  filter(partner %in% c("RU","TOTAL"), 
         unit == "THS_T", 
         siec == "O4000", 
         time == "2020-01-01") %>% #SIEC G3000: Natural Gas 
  select(geo, partner, values) %>%
  pivot_wider( names_from = "partner", values_from = "values") %>%
  mutate(RU_share = RU/TOTAL)

plot_calib.gas <- ggplot(data = data_plot , 
                         aes(x = geo, 
                             y = RU_share, 
                             fill= factor(ifelse(geo == "FR", "France", ifelse(geo == "EU27_2020", "EU28",  "Autres pays"))))) +
  geom_hline(aes(yintercept = 0),color = "gray", linetype= "solid", size = 0.5) +
  geom_hline(aes(yintercept = .25),color = "gray", linetype= "dashed", size = 0.3) +
  geom_hline(aes(yintercept = .50),color = "gray", linetype= "dashed", size = 0.3) +
  geom_hline(aes(yintercept = .75 ),color = "gray", linetype= "dashed", size = 0.3) +
  geom_hline(aes(yintercept = 1 ),color = "gray", linetype= "solid", size = 0.5) +
  geom_bar(stat="identity", width = 0.95, show.legend=FALSE) + 
  scale_fill_manual(name = "geo", values=c( "#9fc7da","#466963","#fb8072"))  +
  theme_minimal() +
  theme(
    plot.title = element_text(size= 8,family = "Stone Sans"),
    plot.subtitle = element_text(size= 7,family = "Stone Sans"),
    legend.text = element_text(size= 7, family = "Stone Sans"),
    axis.title.x = element_text(size = 8,family = "Stone Sans"),
    axis.title.y = element_text(size = 8,family = "Stone Sans"), 
    axis.text.x = element_text(angle=65, vjust=0.4, size = 7,family = "Stone Sans"),
    axis.text.y = element_text(size = 7,family = "Stone Sans"),                                                   
    panel.grid  = element_blank(), 
    legend.title = element_blank()
  ) +
  labs(
    title = "Part du gaz russe dans la consommation totale par pays", #Empreinte carbone de la France en 2011 par type de GES
    subtitle = str_c("En 2020"),
    caption=str_c("Source : Eurostat (nrg_ti_geo)"),#
    x= "",
    y=" en %."
  ) 



plot_calib.oil <- ggplot(data = data_plot.2 , 
                         aes(x = geo, 
                             y = RU_share, 
                             fill= factor(ifelse(geo == "FR", "France", ifelse(geo == "EU27_2020", "EU27",  "Autres pays"))))) +
  
  geom_hline(aes(yintercept = 0),color = "gray", linetype= "solid", size = 0.5) +
  geom_hline(aes(yintercept = .25),color = "gray", linetype= "dashed", size = 0.3) +
  geom_hline(aes(yintercept = .50),color = "gray", linetype= "dashed", size = 0.3) +
  geom_hline(aes(yintercept = .75 ),color = "gray", linetype= "dashed", size = 0.3) +
  geom_hline(aes(yintercept = 1 ),color = "gray", linetype= "solid", size = 0.5) +
  geom_bar(stat="identity", width = 0.95, show.legend=FALSE) + 
  scale_fill_manual(name = "geo", values=c( "#9fc7da","#466963","#fb8072"))  +
  #scale_y_continuous(labels = scales::label_number(scale = "percent")) +
  theme_minimal() +
  theme(
    plot.title = element_text(size= 8,family = "Stone Sans"),
    plot.subtitle = element_text(size= 7,family = "Stone Sans"),
    legend.text = element_text(size= 7, family = "Stone Sans"),
    axis.title.x = element_text(size = 8,family = "Stone Sans"),
    axis.title.y = element_text(size = 8,family = "Stone Sans"), 
    axis.text.x = element_text(angle=65, vjust=0.4, size = 7,family = "Stone Sans"),
    axis.text.y = element_text(size = 7,family = "Stone Sans"),                                                   
    panel.grid  = element_blank(), 
    legend.title = element_blank()
  ) +
  labs(
    title = "Part du pétrole russe dans la consommation totale par pays", #Empreinte carbone de la France en 2011 par type de GES
    subtitle=  str_c("2020"),
    caption=str_c("Source : Eurostat (nrg_ti_oil)"),#
    x= "",
    y=" en %."
  ) 

