data_full <- loadResults("pibea19_r_ss_1a_2130_zero.csv",
                         by_sector = FALSE, by_commodity = FALSE, 
                         bridge_s = bridge_sectors, bridge_c = bridge_commodities,
                         names_s = names_sectors, names_c = names_commodities)


"pibea19_r_1_2130_zero","mw_r_1b_2130_zero","xbs_r_1c_2130_zero","pibea19_r_ss_1a_2130_zero"


data = read.csv("pibea19_r_ss_1a_2130_zero.csv",sep = ";", encoding = "UTF-8") 
colnames(data) = gsub("1A", "2", colnames(data))
write.csv(data,"pibea19_r_ss_1a_2130_zero.csv")
