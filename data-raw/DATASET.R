## code to prepare dataset goes here

# Translations ------------------------------------------------------------

onglets <- read.csv("data-raw/onglets.csv", encoding = "UTF-8")
textesUI <- read.csv("data-raw/textesUI.csv", encoding = "UTF-8")
# encoding for getting rid of the R-CMD check "found non-ASCII strings" warning


usethis::use_data(onglets, textesUI, overwrite = TRUE)
devtools::document()


# Carte -------------------------------------------------------------------

library(dplyr)
library(sf)

prelev <- readr::read_csv2("data-raw/data_agrumile.csv") %>% 
  filter(!is.na(Date)) %>% 
  select(-Type) %>% 
  mutate(
    Date = lubridate::dmy(Date),
    Maladie = factor(Maladie)
  )

communes <- read_sf("data-raw/communes.shp")
pluvio <- read_sf("data-raw/pluvio.shp")

usethis::use_data(prelev, communes, pluvio, overwrite = TRUE)
devtools::document() # modifier R/data.R

