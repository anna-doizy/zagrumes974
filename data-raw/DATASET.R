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

communes <- read_sf("data-raw/communes.shp") %>% 
  st_set_precision(1e6) %>% 
  st_make_valid() # probleme au PORT (st_is_valid)

pluvio <- read_sf("data-raw/pluvio.shp")


set.seed(562)

prelev <- readr::read_csv2("data-raw/data_agrumile.csv") %>% 
  filter(!is.na(Date)) %>% 
  select(-Type) %>% 
  st_as_sf(coords=c('X', 'Y'), crs = st_crs(communes), remove = FALSE) %>% 
  st_intersection(communes) %>%
  as_tibble() %>% 
  mutate(
    Date = lubridate::dmy(Date),
    Maladie = factor(Maladie, labels = c("Sain", "Malade")),
    X = X + rnorm(n(), sd = 0.01),
    Y = Y + rnorm(n(), sd = 0.01)
  )


usethis::use_data(prelev, communes, pluvio, overwrite = TRUE)
devtools::document() # modifier R/data.R

