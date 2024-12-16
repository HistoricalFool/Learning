rm(list=ls())
library(haven)
library(tidyverse)
library(ggplot2)
library(car)

df <- read_dta("pwt1001.dta")

primary_countries <- subset(df, countrycode==c("ITA", "USA", "JPN", "GBR", "CAN", "FRA","SPN"))

alpha <- 1/3
primary_countries$y <- primary_countries$
