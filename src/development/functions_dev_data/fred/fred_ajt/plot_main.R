# PACKAGES
library(data.table)
library(lemon)
library(tidyverse)
library(extrafont)
library(scales)
library(readxl)
library(colorspace)
library(ggpubr)
library(svglite)
library(magrittr)

## Format of the output plot
format_img <- c( "png", "svg")

# pour trouver son user_path getwd()
user_path <- str_c("C:/Users/81655/Documents/GitHub/")
user_path <- str_c("C:/Users/reynesfgd/GitHub/")
path_plot <- str_c("ThreeME_V3/results/R/")
path_res.plot <- str_c("ThreeME_V3/results/plot.results/")

## labels for scenarios
line_scenario <- c( "dotted",  "twodash", "longdash", "solid")

scenario <- c("oilprice", "oilprice_low", "oilprice_mid", "oilprice_high")

police <- 'Nunito'

year_min <- 2020
year_max <- 2050
