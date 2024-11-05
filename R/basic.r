rm(list = ls())

library(mFilter)
library(fredr)
library(zoo)
library(dplyr)
library(lubridate)
library(tidyverse)

fredr_set_key("897e13982b27e738be3b0d782178320f")
RGDPPC <- fredr(series_id = "A939RX0Q048SBEA")

str(RGDPPC)
RGDPPC <- subset(RGDPPC, select = -series_id)
head(RGDPPC)

RGDPPC$year <- year(RGDPPC$date)
RGDPPC$quarter <- quarter(RGDPPC$date)
RGDPPC$time <- as.yearqtr(RGDPPC$date)

RGDPPC$loggdp <- log(RGDPPC$value)

hp_filter <- hpfilter(RGDPPC$loggdp, freq = 1600)
RGDPPC$gdpc_hp <- hp_filter$trend
RGDPPC$gdpc_trend <- hp_filter$trend

ggplot(RGDPPC, aes(x=time, y=gdpc_trend)) +
  geom_line() +
  geom_vline(xintercept = as.yearqtr("2009 Q1"), color = "red") +
  geom_vline(xintercept = as.yearqtr("2020 Q4"), color = "red") +
  xlab("Time") +
  ylab("Deviations of GDP from Trend") +
  ggtitle("GDP per Capita Over Time")
ggsave("~/learning/r/Q3graph.pdf", width=8,height=6)
