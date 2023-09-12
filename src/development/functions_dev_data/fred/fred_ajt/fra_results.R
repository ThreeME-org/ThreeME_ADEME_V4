source("threeme_results.R")

results <- loadResults('oilprice')

selection <- results %>% 
             filter(variable %in% c("GDP")) %>%
             mutate(variable, rel_diff = (oilprice/baseline-1),
                                  diff = (oilprice - baseline))

ggplot(selection) + geom_line(aes(x=year, y=rel_diff, color="GDP"))  + scale_color_discrete(name="Legend")


selection <- results %>% 
  filter(variable %in% c("GDP", "CH")) %>%
  mutate(variable, rel_diff = (oilprice/baseline-1),
         diff = (oilprice - baseline))


ggplot(selection) + geom_line(aes(x=year, y=rel_diff, color=variable)) + labs(title="GDP and CH")


data(economics, package="ggplot2")  # init data
economics <- data.frame(economics)  # convert to dataframe
ggplot(economics) + geom_line(aes(x=date, y=pce, color="pcs")) + geom_line(aes(x=date, y=unemploy, col="unemploy")) + scale_color_discrete(name="Legend") + labs(title="Economics") # pl


ggplot(economics) + geom_line(aes(x=date, y=pce, color="pcs"))  + scale_color_discrete(name="Legend")


### http://r-statistics.co/ggplot2-Tutorial-With-R.html#6.1%20Make%20a%20time%20series%20plot%20(using%20ggfortify)
library(reshape2)
df <- melt(economics[, c("date", "pce", "unemploy")], id="date")
ggplot(df) + geom_line(aes(x=date, y=value, color=variable)) + labs(title="Economics")