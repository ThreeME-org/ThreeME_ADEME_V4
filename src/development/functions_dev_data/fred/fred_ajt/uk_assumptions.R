library(data.table)
library(dplyr)
library(stringr)
library(tidyr)

library(ggplot2)
library(scales)
library(lemon)

gg <- glue::glue


# Carbon tax trajectories

tibble(
  year = c(rep(2030, 3), rep(2050, 3)),
  scenario = rep(c("Low", "Medium", "High"), 2),
  tax = c(100, 140, 280, 189, 378, 578)
) %>%
  mutate(scenario = factor(scenario, c("Low", "Medium", "High"))) %>%
  ggplot(aes(factor(year), tax, fill = scenario)) +
  geom_bar(stat = "identity", position = position_dodge2()) +
  xlab("") + ylab("Carbon tax (£2020/tCO2)") +
  scale_fill_manual(name = "Carbon tax trajectory", values = c("#fee08b", "#d9ef8b", "#91cf60")) +
  theme_minimal() +
  theme(legend.position = "bottom",
        panel.grid.major.x = element_blank(),
        panel.grid.minor = element_blank(),
        text = element_text(size = 12))



# Electricity mix

tribble(
  ~Technology, ~`2020`, ~`2030`, ~`2050`,
  "Nuclear", 0.16, 0.15, 0.10,
  "Natural gas", 0.36, 0.09, 0.00,
  "Coal", 0.02, 0.02, 0.02,
  "Wind", 0.24, 0.50, 0.65,
  "Solar", 0.07, 0.07, 0.13,
  "Hydro", 0.03, 0.03, 0.02,
  "Others", 0.12, 0.14, 0.08
) %>%
  mutate(Technology = factor(Technology, c("Nuclear", "Natural gas", "Coal", "Wind", "Solar", "Hydro", "Others"))) %>%
  pivot_longer(-Technology, names_to = "year", values_to = "share") %>%
  ggplot(aes(factor(year), share, fill = Technology)) +
  geom_bar(stat = "identity") +
  xlab("") + ylab("") +
  scale_y_continuous(labels = percent_format(1)) +
  scale_fill_manual(values = c("#66c2a5", "#fc8d62", "#e5c494", "#a6d854", "#ffd92f", "#8da0cb", "#e78ac3"),
                    name = "Electricity from") +
  theme_minimal() +
  theme(#legend.position = "bottom",
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    text = element_text(size = 12))
