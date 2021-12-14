## code to prepare dataset goes here

# Translations ------------------------------------------------------------

onglets <- read.csv("data-raw/onglets.csv", encoding = "UTF-8")
textesUI <- read.csv("data-raw/textesUI.csv", encoding = "UTF-8")
# encoding for getting rid of the R-CMD check "found non-ASCII strings" warning


usethis::use_data(onglets, textesUI, overwrite = TRUE)
devtools::document()



# Barplot -----------------------------------------------------------------

library(dplyr)

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
    X = X + rnorm(n(), sd = 0.01), # anonymisation
    Y = Y + rnorm(n(), sd = 0.01),
    Surface = Surface / 10000 # conversion m² -> ha
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
hlu <- read.csv2("data-raw/hlbposi.csv") %>%  
  mutate(date = lubridate::dmy(date)) #%>% 
  # filter(between(date, as.Date("2019-06-25"), as.Date("2020-05-29")))
# a faire : ajouter la colonne date pour pouvoir trier par date

# limites <- c(55.2, 55.85, -21.45, -20.85)

# kernel_par <- kde2d(par$longitude, par$latitude, n = 200, lims = limites)
# kernel_hlu <- kde2d(hlu$longitude, hlu$latitude, n = 200, lims = limites)

# raster_agrumes <- raster(kernel_par)
# raster_hlb <- raster(list(x = kernel_hlu$x , y = kernel_hlu$y, z = kernel_hlu$z / (kernel_par$z + 50)))

usethis::use_data(communes, par, hlu, overwrite = TRUE)
devtools::document() # modifier R/data.R






