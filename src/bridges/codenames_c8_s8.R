### Commodities: c8
names_commodities <- rbind(
c('Industry','cind'),
c('Vehicles','cveh'),
c('Construction','ccon'),
c('Transport clean','ctrc'),
c('Transport dirty','ctrd'),
c('Services','cser'),
c('Energy clean','cenc'),
c('Energy dirty','cend'),
c('Industry','C001'),
c('Vehicles','C002'),
c('Construction','C003'),
c('Transport clean','C004'),
c('Transport dirty','C005'),
c('Services','C006'),
c('Energy clean','C007'),
c('Energy dirty','C008')
# c('Energy','C007')
) %>%
  as.data.frame() %>% rename(name = V1,code = V2)

### Sectors: s8
names_sectors <- rbind(
c('Industry','sind'),
c('Vehicles','sveh'),
c('Construction','scon'),
c('Transport clean','strc'),
c('Transport dirty','strd'),
c('Services','sser'),
c('Energy clean','senc'),
c('Energy dirty','send'),
c('Industry','s001'),
c('Vehicles','s002'),
c('Construction','s003'),
c('Transport clean','s004'),
c('Transport dirty','s005'),
c('Services','s006'),
c('Energy clean','s007'),
c('Energy dirty','s008')  
#  c('Energy','s007')    
) %>%
  as.data.frame() %>% rename(name = V1,code = V2)
