library(ggplot2)
library(tidyverse)
library(lubridate)
library(SPEI)

teema <- function() {
  theme_minimal() +
    theme(
      axis.text = element_text(color="gray40"),
      axis.text.x = element_blank(),
      
      axis.title.y = element_text(vjust = -15, color="gray40"),
      axis.title.x = element_blank(),
      
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      
      legend.position = "none",
      
      plot.margin = margin(.5, .5, .5, .5, "cm"),
    )
}

ilm <- read_csv("app/data/ilm-voru-pikk.csv")
puistud <- read_csv("app/data/hukkunud-puistud.csv")

puistud[puistud == '..'] <- NA
puistud_p <- puistud %>%
  pivot_longer(cols = -c(Maakond, Aasta),
               names_to = "Kahjustus",
               values_to = "Hektar") %>%
  mutate(Hektar = as.numeric(Hektar)) %>%
  filter(Kahjustus %in% c("Putukakahjustused", "Tuuleheide ja -murd")) %>%
  mutate(varv = if_else(Kahjustus == "Putukakahjustused", "#1a9641", "#a6d96a"))

paevad <- ilm %>%
  group_by(day = floor_date(time, "day")) %>%
  summarise_all(mean) %>%
  select(-time)

iilid <- paevad %>%  
  group_by(month = floor_date(day, "month")) %>%
  summarise(iilid = sum(wind_gusts_10m > 40))

kuud <- paevad %>%  
  group_by(month = floor_date(day, "month")) %>%
  summarise_all(mean) %>%
  select(-day)

kuud$spi <- spi(kuud$precipitation, scale=12)$fitted
kuud$spei <- spei(kuud$precipitation - kuud$et, scale=12)$fitted

puistud_p %>%
  filter(Aasta >= 2019) %>%
  filter(Maakond == "Kogu Eesti") %>%
  # filter(Maakond == "Põlva maakond") %>%
  filter(Kahjustus != 'Kokku') %>%
  mutate(Hektar = as.numeric(Hektar)) %>%
  ggplot() +
  aes(Aasta, Hektar, color=varv) +
  geom_line() +
  geom_point() +
  ylab("Hukkunud puistud (ha)") +
  scale_color_identity() +
  teema() + theme(axis.text.x = element_text())

ggsave("kahjud.png", width = 210, height = 100, units = "mm")

iilid %>%
  filter(make_date(2019) <= month & month <= make_date(2024)) %>%
  ggplot() +
  aes(month, iilid, fill=iilid) +
  geom_bar(stat="identity") +
  ylab("Tuuleiilid >40 m/s") +
  scale_fill_gradientn(colors=c("#fee08b", "#fc8d59", "#d7191c")) +
  teema() + theme(axis.text.x = element_text())

ggsave("iilid.png", width = 210, height = 50, units = "mm")

c("#1a9641", "#a6d96a", "#fee08b", "#fdae61", "#fc8d59", "#d7191c")
c("#d7191c", "#fc8d59", "#fdae61", "#fee08b", "#a6d96a", "#1a9641")

kuud %>%
  filter(make_date(2019) <= month & month <= make_date(2024)) %>%
  ggplot() +
  aes(month, spi, fill=spi) +
  geom_bar(stat="identity") +
  ylab("Sademeindeks") +
  ylim(-2.5, 2.5) +
  scale_fill_gradientn(colors=c("#d7191c", "#fc8d59", "#fdae61", "#f8f8f8", "#fdae61", "#fc8d59", "#d7191c")) +
  teema() + theme(axis.text.x = element_text())

ggsave("spi.png", width = 210, height = 50, units = "mm")
