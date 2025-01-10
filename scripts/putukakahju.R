library(sf)
library(ggplot2)
library(tidyverse)

puistud <- read_csv("app/data/hukkunud-puistud.csv")

puistud[puistud == '..'] <- NA
puistud_pikk <- puistud %>%
  pivot_longer(cols = -c(Maakond, Aasta), names_to = "Kahjustus", values_to = "Hektar") %>%
  mutate(Hektar = as.numeric(Hektar))

maakonnad <- st_read("app/data/maakonnad/maakond.shp") %>%
  st_simplify(dTolerance = 50) %>%
  left_join(puistud_pikk, by = c("MNIMI" = "Maakond"))

maakonnad %>%
  # filter(Aasta %in% c(2020, 2021, 2022, 2023)) %>%
  filter(Aasta > 1993) %>%
  filter(Kahjustus == "Putukakahjustused") %>%
  ggplot() +
  geom_sf(aes(fill=Hektar), color=NA) +
  # facet_grid(~ Aasta) +
  facet_wrap(~ Aasta) +
  scale_fill_gradientn(colors=c("#1a9641", "#a6d96a", "#fee08b", "#fdae61", "#fc8d59", "#d7191c"),
                       na.value="#1a9641") +
  theme_minimal() +
  theme(
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    
    axis.text = element_blank(),
    
    legend.position = "none",
    legend.ticks = element_blank(),
    legend.title = element_blank(),
    legend.text = element_text(color = "gray40"),
    
    # strip.text = element_blank(),
    strip.text = element_text(face = "bold", color = "gray40"),
    
    plot.margin = margin(.5, .5, .5, .5, "cm"),
  )

ggsave("putukakahju.png", width = 420, units = "mm")
