## Shock scenario hypotheses calibrations

## Shock scenario hypotheses are calibrated starting with baseyear 


# 

# Simulate initialization (will be deleted later)
shock_ch <- data.frame(year = c(baseyear:lastyear)) %>% 
    mutate(
            GR_PRICES = 0.0200,
            P = 1*(1+GR_PRICES)^(year-baseyear)
            
            )


# Change in exogenous variables for the shock scenario
shock_ch <- mutate(shock_ch,
                   PWD_CCOI = ifelse(year >= 2022, P*1.1, P),
                   PWD_CFUT = ifelse(year >= 2022, P*1.1, P),
                   PWD_CFUH = ifelse(year >= 2022, P*1.1, P),
                   PWD_CGAS = ifelse(year >= 2022, P*1.1, P)
                   ) 





# library(ggplot2)
# ggplot(data=shock_ch, aes(x=year, y=P)) + geom_line()
