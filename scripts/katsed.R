library(ggplot2)
library(tidyverse)

bio <- read_csv("app/data/biomass-metsamaal.csv")
puistud_h <- read_csv("app/data/hukkunud-puistud.csv")
puistud_k <- read_csv("app/data/kahjustunud-puistud.csv")
heitvesi <- read_csv("app/data/heitvee-puhastamine.csv")
jäätmed <- read_csv("app/data/jäätmeteke.csv")
taimekaitse <- read_csv("app/data/taimekaitsevahendid.csv")
taimekaitse_kultuur <- read_csv("app/data/taimekatisevahendid-kultuur.csv")

bio %>% 
  filter(Puuliik != "Kokku") %>%
  ggplot() +
  geom_line(aes(Aasta, `Puitne biomass metsamaal`, color=Puuliik))
  # geom_line(aes(Aasta, `Seotud süsiniku kogus puitses biomassis metsamaal`, color=Puuliik))

# putukakahjustused on hüppega tõusnud
puistud_h[puistud_h == '..'] <- NA
puistud_pikkh <- puistud_h %>%
  pivot_longer(cols = -c(Maakond, Aasta), names_to = "Kahjustus", values_to = "Hektar")

puistud_pikkh %>%
  filter(Maakond == "Kogu Eesti") %>%
  filter(Kahjustus != 'Kokku') %>%
  mutate(Hektar = as.numeric(Hektar)) %>%
  ggplot() +
  geom_line(aes(Aasta, Hektar, color=Kahjustus)) # + facet_wrap(~ Maakond)

puistud_pikkh %>%
  filter(Maakond != "Kogu Eesti") %>%
  filter(Kahjustus == 'Tuuleheide ja -murd') %>%
  filter(Aasta %in% c(2020,2021,2022,2023)) %>%
  mutate(Hektar = as.numeric(Hektar)) %>%
  ggplot() +
  geom_bar(aes(factor(Aasta), Hektar, fill=Maakond), position="dodge", stat="identity")


puistud_k[puistud_k == '..'] <- NA
puistud_pikkk <- puistud_k %>%
  pivot_longer(cols = -c(Maakond, Aasta), names_to = "Kahjustus", values_to = "Hektar")

puistud_pikkk %>%
  filter(Maakond == "Kogu Eesti") %>%
  filter(Kahjustus != 'Kokku') %>%
  mutate(Hektar = as.numeric(Hektar)) %>%
  ggplot() +
  geom_line(aes(Aasta, Hektar, color=Kahjustus)) # + facet_wrap(~ Maakond)



heitvesi[heitvesi == '..'] <- NA
heitvesi %>% 
  mutate(across(-c(Maakond), ~ as.numeric(.))) %>%
  pivot_longer(cols = -c(Maakond, Aasta), names_to = "Heitvesi", values_to = "Kuupmeeter") %>%
  filter(Maakond == "Kogu Eesti") %>%
  filter(!is.na(Kuupmeeter)) %>%
  mutate(Kuupmeeter = 1000 * Kuupmeeter) %>%
  ggplot() +
  geom_line(aes(Aasta, Kuupmeeter, color=Heitvesi))

jäätmed[jäätmed == '..'] <- NA
jäätmed %>% 
  mutate(across(-c(Jäätmeliik), ~ as.numeric(.))) %>%
  pivot_longer(cols = -c(Aasta, Jäätmeliik), names_to = "Jäätmed", values_to = "Tonn") %>%
  filter(Jäätmeliik == "Jäätmed kokku") %>%
  filter(!(Jäätmed %in% c("Tegevusalad kokku"))) %>%
  ggplot() +
  geom_line(aes(Aasta, Tonn, color=Jäätmed))

taimekaitse_kultuur[taimekaitse_kultuur == '..'] <- NA
taimekaitse_kultuur %>% 
  mutate(across(-c(Maakond, Kultuur), ~ as.numeric(.))) %>%
  pivot_longer(cols = -c(Aasta, Maakond, Kultuur), names_to = "Vahend", values_to = "Unit") %>%
  filter(!(Vahend %in% c("Taimekaitsevahendid kokku Kogus", 
                         "Taimekaitsevahendid kokku Kogus töödeldud hektari kohta"))) %>%
  ggplot() +
  geom_line(aes(Aasta, Unit, color=Vahend))

library(lubridate)
ilm <- read_csv("app/data/ilm-voru.csv") %>%
  mutate(Aeg = make_datetime(year = Aasta,
                             month = Kuu,
                             day = Päev,
                             hour = as.numeric(substr(`Kell (UTC)`, 1, 2)))) %>%
  select(-c(Aasta, Kuu, Päev, `Kell (UTC)`))

ilm %>%
  ggplot() +
  geom_line(aes(Aeg, `Suhteline õhuniiskus %`))

ilm %>%
  ggplot() +
  geom_line(aes(Aeg, `Tunni maksimum õhutemperatuur °C`))

ilm %>%
  # filter(Aasta %in% c(2020, 2021, 2022, 2023)) %>%
  group_by(Aasta, Kuu, Päev) %>%
  mutate(Tuul = mean(`Tunni maksimum tuule kiirus m/s`)) %>%
  ggplot() +
  geom_line(aes(Aeg, Tuul))

library(sf)
library(osmdata)
library(tidyverse)
library(ggsflabel)
library(rnaturalearth)

maakonnad <- st_read("app/data/maakonnad/maakond.shp") %>%
  st_simplify(dTolerance = 100) %>%
  left_join(puistud_pikkh, by = c("MNIMI" = "Maakond"))

maakonnad$Hektar[maakonnad$Hektar == '..'] <- NA

maakonnad %>%
  mutate(Hektar = as.numeric(Hektar)) %>%
  filter(Aasta %in% c(2020, 2021, 2022, 2023)) %>%
  filter(Kahjustus == "Putukakahjustused") %>%
  # filter(Kahjustus == "Tuuleheide ja -murd") %>%
  ggplot() +
  geom_sf(aes(fill=Hektar)) +
  # geom_sf(data=yrask) 
  facet_wrap(~ Aasta)

yrask <- st_read("app/data/yrask/kuusekooreyrask_rmk.shp")
yrask %>% 
  ggplot() +
  geom_sf()
