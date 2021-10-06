# deployment to shinyapps.io with rsconnect

# SETUP
# create a new repo on gitlab and github
# git remote add origin git@gitlab.com:cirad-apps/zagrumes974.git
# git remote set-url --add --push origin git@github.com:anna-doizy/zagrumes974.git
# git remote set-url --add --push origin git@gitlab.com:cirad-apps/zagrumes974.git
# git remote -v
# origin  git@gitlab.com:doana-r/ipsimcirsium.git (fetch)
# origin  git@github.com:anna-doizy/ipsimcirsium.git (push)
# origin  git@gitlab.com:doana-r/ipsimcirsium.git (push)
# git push -u origin master/main

# EACH TIME before deployment
# update all packages
# change "update date" in accueil fr ET en
# check and install this package
# check if parse("inst/app/server.R"), parse("inst/app/ui.R") work
# commit & push
# restart R session
# remotes::install_github("anna-doizy/ipsimcirsium")
# publish the app

# nécessaire car comme l'application charge le package pour démarrer (récupère le jeu suivi), il a besoin d'être installé proprement dans le serveur distant. Pour l'instant RStudio (shinyapps) ne permet de faire cela qu'avec des packages classiques (CRAN) ou github, mais pas gitlab...




# A FAIRE -----------------------------------------------------------------

# - Ajouter une légende à la carte
# - ajouter des moyens d'interagir avec la carte
# - Ajouter les autres couches
# - changer les icones des onglets
# - changer les couleurs css
# - mettre en ligne pour montrer à Isma










library(zagrumes974)

lang <- "fr"








# Prélèvement HLB ---------------------------------------------------------

library(tidyverse)
library(leaflet)
library(sf)

prelev <- read_csv2("data-raw/data_agrumile.csv") %>% 
  mutate(
    Date = lubridate::dmy(Date),
    Maladie = factor(Maladie)
  )

skimr::skim(prelev)

table(prelev$Id)
hist(prelev$Surface)
hist(prelev$Altitude)
ftable(Maladie ~ Type, data = prelev)

ggplot(prelev) +
  aes(x = Date, y = Altitude, color = Maladie) + 
  naniar::geom_miss_point()


communes <- read_sf("data-raw/COMMUNES_32740.shp")

leaflet(options = leafletOptions(maxZoom = 14, zoomControl = FALSE)) %>% # maxzoom anonymises data
  addProviderTiles("Stamen.Terrain") %>%
  setView(55.5, -21.15, zoom = 10) %>%
  addCircleMarkers(
    ~X, ~Y, data = prelev %>% filter(Maladie == 0),
    color = "darkgreen",
    fill = TRUE,
    opacity = 0.5,
    fillOpacity = 0.5,
    radius = ~ Surface/1000
  ) %>%
  addCircleMarkers(
    ~X, ~Y, data = prelev %>% filter(Maladie == 1),
    # icon = list(iconUrl = "hex_icon.svg", iconSize = c(100,100)),
    color = "red",
    # popup = ~paste(
    #   paste0("<img src = \"", htmlEscape(img_src), "\", style = \"max-width:200px;max-height:200px\">"),
    #   htmlEscape(vernaculaire),
    #   paste("<em>", htmlEscape(g_latin), htmlEscape(e_latin), "</em>"),
    #   htmlEscape(date),
    #   sep = "<br>"
    # )
    fill = TRUE,
    opacity = 0.5,
    fillOpacity = 0.5,
    radius = ~ Surface/1000
  )


# communes_wgs84 <- st_transform(communes, "+init=epsg:4326")
# leaflet(data = communes) %>% addPolygons()

plot(communes)














