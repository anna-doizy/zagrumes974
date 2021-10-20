


# A FAIRE -----------------------------------------------------------------

# - Ajouter une légende à la carte
# - ajouter des moyens d'interagir avec la carte
# - case taille parcelle à cocher pour changer la taille des cercles
# - demande de mail pour Henri en passant par Isma
# - intégrer les simulation (novembre)
# - Ajouter les graphiques,type de ce que Nathan a fait
# - Il me faut la source des images

# - Ajouter la couche pluvio (pluvio annuelle médiane de 1986 à 2016) OK
# - logo en haut à gauche : dessin / cliquable ? OK
# - icone des parcelles pour suggérer un verger OK
# - pour en savoir plus redirige vers le site plateforme-esv.fr/huanlongbing (attendre confirmation et changer icone) OK
# - remerciement icone coeur ? OK
# - intégrer texte + photos (jeudi) OK
# - héberger les images ailleurs ?




library(zagrumes974)

lang <- "fr"



# Prélèvement HLB ---------------------------------------------------------

library(tidyverse)
library(leaflet)
library(sf)



skimr::skim(prelev)

table(prelev$Id)
hist(prelev$Surface)
hist(prelev$Altitude)

ggplot(prelev) +
  aes(x = Date, y = Altitude, color = Maladie) + 
  geom_point()



# nouveau prelev ? 
# nouvelle communes ?
prelev_comm <- prelev %>% 
  st_as_sf(coords=c('X', 'Y'), crs = st_crs(communes)) %>% 
  st_intersection(
    communes %>% 
      st_set_precision(1e6) %>% 
      st_make_valid() # probleme au PORT (st_is_valid)
  )

# ggplot(prelev_comm) +
#   aes(y = COMMUNE, fill = Maladie) +
#   geom_bar()

library(echarts4r)

# Faut-il pondérer par la surface ? Comment la prendre en compte ?
prelev_comm %>% # ici filter avec les input DATE & ALTITUDE
  as_tibble() %>% # facultatif
  group_by(COMMUNE) %>%
  summarise(
    Sain = sum(Maladie == 0),
    Malade = sum(Maladie == 1) # calcul du nb de parcelles saine et malades par commune
  ) %>% 
  e_chart(COMMUNE) %>% 
  e_bar(Sain, stack = "maladie") %>% 
  e_bar(Malade, stack = "maladie") %>%
  e_tooltip(trigger = "axis") %>% 
  e_flip_coords() %>% 
  e_theme_custom('{"color":["#16771f","#eb8200"]}')




leaflet(options = leafletOptions(maxZoom = 14, zoomControl = FALSE)) %>% # maxzoom anonymises data
  addProviderTiles("Stamen.Terrain") %>%
  setView(55.5, -21.15, zoom = 10) %>%
  addPolygons(data = communes, color = "#000", fillOpacity = 0, popup =  ~ COMMUNE, weight = 2) %>%
  addMarkers(
    ~X, ~Y, data = prelev %>% filter(Maladie == 0),
    icon = list(iconUrl = "inst/app/www/orchard-healthy.svg", iconSize = c(50,50)),
    # radius = ~ Surface/1000
  ) %>%
  addMarkers(
    ~X, ~Y, data = prelev %>% filter(Maladie == 1),
    icon = list(iconUrl = "inst/app/www/orchard-unhealthy.svg", iconSize = c(50,50)),
    # popup = ~paste(
    #   paste0("<img src = \"", htmlEscape(img_src), "\", style = \"max-width:200px;max-height:200px\">"),
    #   htmlEscape(vernaculaire),
    #   paste("<em>", htmlEscape(g_latin), htmlEscape(e_latin), "</em>"),
    #   htmlEscape(date),
    #   sep = "<br>"
    # )

    # radius = ~ Surface/1000
  )
  # addPolylines(data = pluvio, color = ~ r_median) # rasteriser ?


# communes_wgs84 <- st_transform(communes, "+init=epsg:4326")
leaflet(data = communes) %>% addPolygons()



leaflet(data = pluvio) %>% addPolylines(
  # stroke = TRUE, 
  color = ~ colorNumeric("Blues", r_median)(r_median),
  fillColor = "transparent",
  noClip = TRUE
)

hist(pluvio$r_median, breaks = 40)










