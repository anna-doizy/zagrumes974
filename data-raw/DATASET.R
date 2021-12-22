## code to prepare dataset goes here

# Translations ------------------------------------------------------------

onglets <- read.csv("data-raw/onglets.csv", encoding = "UTF-8")
textesUI <- read.csv("data-raw/textesUI.csv", encoding = "UTF-8")
# encoding for getting rid of the R-CMD check "found non-ASCII strings" warning


usethis::use_data(onglets, textesUI, overwrite = TRUE)
devtools::document()



# Barplot -----------------------------------------------------------------

library(dplyr)

# une ligne par parcelle échantillonnée 
# plusieurs prélèvements sur la même parcelle pouvant être possible, si un seul est positif, la parcelle entière est considérée comme positive.

prelev <- readr::read_csv2("data-raw/parcelles_prelevee.csv") %>% 
  filter(!is.na(Date)) %>% # une date manquante
  mutate(
    Date = lubridate::dmy(Date),
    Maladie = factor(Maladie, labels = c(`0` = "Sain", `1` = "Malade"))
  )


surface_agrume <- readr::read_csv2("data-raw/somme surface commune.csv") %>% 
  rename(COMMUNE = "Commune", Surface_tot = "Surface tot agrumes en m2") %>% 
  mutate(
    Surface_tot = Surface_tot / 10000, # conversion m² -> ha
  )


usethis::use_data(prelev, surface_agrume, overwrite = TRUE)
devtools::document() # modifier R/data.R



# Carte -------------------------------------------------------------------

library(dplyr)
library(sf)

communes <- read_sf("data-raw/communes.shp") %>% 
  st_set_precision(1e6) %>% 
  st_make_valid() # probleme au PORT (st_is_valid)


# parcellaire d'agrumes
par <- read.csv2("data-raw/justagru.csv")

# présence de HLB
# une ligne par analyse HLB positive avec ses coordonnées (le prélèvement s'est fait sur une parcelle ou non)

hlu <- read.csv2("data-raw/hlu.csv") %>%  
  mutate(date = lubridate::dmy(date)) %>% 
  filter(HLB == 1) %>% 
  dplyr::select(-HLB)

usethis::use_data(communes, par, hlu, overwrite = TRUE)
devtools::document() # modifier R/data.R






