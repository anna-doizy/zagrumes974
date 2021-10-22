


# A FAIRE -----------------------------------------------------------------

# - Ajouter la couche pluvio (pluvio annuelle médiane de 1986 à 2016)
# - case taille parcelle à cocher pour changer la taille des cercles ?
# - quelle est l'unité de surface ?
# - SAU par commune ou surface totale ? pour améliorer le graphique
# - demande de mail pour Henri en passant par Isma
# - intégrer les simulations (novembre)
# - Il me faut la source des images
# - héberger les images ailleurs ?
# - Erreur connue : s'il n'y a pas de Sain ou de Malade dans la table, le graphe est cassé

# - Ajouter une légende à la carte OK ?
# - Faire en sorte que les points s'affichent directement sur la carte OK
# - Ajouter les graphiques,type de ce que Nathan a fait ok
# - ajouter des moyens d'interagir avec la carte OK
# - logo en haut à gauche : dessin / cliquable ? OK
# - mettre de l'aléatoire autour des coordonnées OK
# - icone des parcelles pour suggérer un verger OK
# - pour en savoir plus redirige vers le site plateforme-esv.fr/huanlongbing (attendre confirmation et changer icone) OK
# - remerciement icone coeur ? OK
# - intégrer texte + photos (jeudi) OK





library(zagrumes974)

lang <- "fr"



# Prélèvement HLB ---------------------------------------------------------

library(tidyverse)
library(leaflet)
library(sf)
library(echarts4r)



skimr::skim(prelev)

table(prelev$Id)
hist(prelev$Surface)
hist(prelev$Altitude)

ggplot(prelev) +
  aes(x = Date, y = Altitude, color = Maladie) + 
  geom_point()



# Faut-il pondérer par la surface ? Comment la prendre en compte ?
# prelev %>% # ici filter avec les input DATE & ALTITUDE
#   as_tibble() %>% # facultatif
#   group_by(COMMUNE) %>%
#   summarise(
#     Sain = sum(Maladie == 0),
#     Malade = sum(Maladie == 1) # calcul du nb de parcelles saine et malades par commune
#    )%>% 
#   e_chart(COMMUNE) %>% 
#   e_bar(Sain, stack = "maladie") %>% 
#   e_bar(Malade, stack = "maladie") %>%
#   e_tooltip(trigger = "axis") %>% 
#   e_flip_coords() %>% 
#   e_theme_custom('{"color":["#16771f","#eb8200"]}')




prelev %>% # ici filter avec les input DATE & ALTITUDE
  as_tibble() %>%
  group_by(COMMUNE, Maladie) %>%
  summarise(Surface = sum(Surface)) %>% 
  pivot_wider(names_from = Maladie, values_from = Surface, values_fill = 0) %>% 
  ungroup() %>% 
  arrange(Sain, Malade) %>% # par taille totale de la commune ou de la SAU
  e_chart(COMMUNE) %>% 
  {if("Malade" %in% names(.$x$data[[1]])) e_bar(Malade, stack = "maladie") else . }%>%
  {if("Sain" %in% names(.$x$data[[1]])) e_bar(Sain, stack = "maladie") else . }%>%
  e_tooltip(trigger = "axis") %>% 
  # e_flip_coords() %>%  # marche pas avec le tooltip formatter...
  # e_grid(left = "30%") %>% 
  e_y_axis(formatter = e_axis_formatter(locale = lang)) %>% 
  e_tooltip(trigger = "axis", formatter = e_tooltip_pointer_formatter(locale = lang, digits = 0)) %>% 
  e_theme_custom('{"color":["#eb8200","#16771f"]}')
# y ajouter la surface agricole totale par commune




leaflet(options = leafletOptions(maxZoom = 14, zoomControl = FALSE)) %>% # maxzoom anonymises data
  addProviderTiles("Stamen.Terrain") %>%
  setView(55.5, -21.15, zoom = 10) %>%
  addPolygons(data = communes, color = "#000", fillOpacity = 0, popup =  ~ COMMUNE, weight = 2) %>%
  addMarkers(
    ~X, ~Y, data = prelev %>% filter(Maladie == "Sain"),
    icon = list(iconUrl = "inst/app/www/orchard-healthy.svg", iconSize = c(50,50)),
    # radius = ~ Surface/1000
  ) %>%
  addMarkers(
    ~X, ~Y, data = prelev %>% filter(Maladie == "Malade"),
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


leaflet(options = leafletOptions(maxZoom = 14, zoomControl = FALSE)) %>% # maxzoom anonymises data
  addProviderTiles("Stamen.Terrain") %>%
  setView(55.7, -21.12, zoom = 11)%>% 
  addPolylines(
    data = pluvio,
    color = ~ colorNumeric("Blues", r_median)(r_median),
    fillColor = "transparent",
    noClip = TRUE
  )



hist(pluvio$r_median, breaks = 40)










