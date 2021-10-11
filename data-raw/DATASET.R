## code to prepare dataset goes here

# Translations ------------------------------------------------------------

onglets <- read.csv("data-raw/onglets.csv", encoding = "UTF-8")
textesUI <- read.csv("data-raw/textesUI.csv", encoding = "UTF-8")
# encoding for getting rid of the R-CMD check "found non-ASCII strings" warning


usethis::use_data(onglets, textesUI, overwrite = TRUE)



# Carte -------------------------------------------------------------------

library(dplyr)
library(sf)

prelev <- readr::read_csv2("data-raw/data_agrumile.csv") %>% 
  mutate(
    Date = lubridate::dmy(Date),
    Maladie = factor(Maladie)
  )

communes <- read_sf("data-raw/communes.shp")

usethis::use_data(prelev, communes, overwrite = TRUE)
devtools::document() # modifier R/data.R

