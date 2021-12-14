


# A FAIRE -----------------------------------------------------------------

# - problème : pour les périodes restreintes la carte et le barplot ne correspondent pas

# autre
# - hébergement CIRAD : EN COURS
# - donner un titre aux images de l'accueil
# - traduction anglais


# FAIT 

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
# - case taille parcelle à cocher pour changer la taille des cercles ? NON
# - quelle est l'unité de surface ? OK
# - Il me faut la source des images OK
# - unité de surface m² à transformer en ha : 1 ha = 10000 m² OK
# - Supprimer toute trace de la couche pluvio OK
# - intégrer les simulations OK
# - demande de mail pour Henri en passant par Isma OK
# - curseur de tri pour la date (et plus l'altitude) OK
# - intégrer dans barplot surface totale d'agrume par commune OK
# - intégrer les cartes interpolation triable par date OK
# - gérer le proxy de telle sorte que la carte s'affiche tout de suite OK
# - quelle palette de couleurs pour la carte d'interpolation ? OK
# - Ereur : les graphiques simu sont coupés OK


# ----

library(zagrumes974)

lang <- "fr"





# Interpolation -----------------------------------------------------------


library(MASS)
library(raster)
library(leaflet)
library(ggplot2)
library(dplyr)
library(tidyr)

# hlb+ et juste agrumes
par <- read.csv2("data-raw/justagru.csv")
hlu <- read.csv2("data-raw/hlbposi.csv") %>%  
  mutate(date = lubridate::dmy(date)) %>% 
  filter(between(date, as.Date("2019-06-25"), as.Date("2020-05-29")))
# a faire : ajouter la colonne date pour pouvoir trier par date

summary(hlu)

limites <- c(55.2, 55.85, -21.45, -20.85)


kernel_hlu <- kde2d(hlu$longitude, hlu$latitude, n = 200, lims = limites)
# image(kernel_hlu)
# contour(kernel_hlu)
kernel_par <- kde2d(par$longitude, par$latitude, n = 200, lims = limites)
# image(kernel_par)

ggplot() +
  aes(y = seq_along(kernel_par$z), x = kernel_par$z) + 
  geom_point(alpha = 0.2)

# f3 <- list(x = kernel_hlu$x , y = kernel_hlu$y, z = kernel_hlu$z / (kernel_par$z + 100))
# image(f3)
image(kernel_hlu$z / (kernel_par$z + 100))
# contour(f3)
#f3 est le nombre de HLB+ en fonction du nombre de parcelles d'agrumes

tibble(
  num = seq_along(kernel_hlu$z),
  agrumes = as.numeric(kernel_par$z) %>% scale(center = FALSE),
  hlb = as.numeric(kernel_hlu$z) %>% scale(center = FALSE),
  # hlb_par_agrumes = ifelse(agrumes > 1, hlb/agrumes, NA),
  hlb_par_agrumes = scale(hlb / (agrumes + 0.1), center = FALSE) # la valeur 0.1 ; 1 ; 100 modifie le résultat !
  # hlb_par_agrumes = ifelse(agrumes > quantile(agrumes, probs = 0.9), hlb/agrumes, NA)
) %>% 
  pivot_longer(agrumes:hlb_par_agrumes, names_to = "image", values_to = "densite") %>% 
  ggplot() +
  aes(x = densite, y = num) + 
  geom_point(alpha = 0.2) +
  facet_wrap(~ image, ncol = 1)



# densité agrumes

kernel_agrumes <- raster(kernel_par) %>% crop(communes) %>% mask(communes)
# hist(kernel_agrumes@data@values, 30)
# quantile(kernel_agrumes@data@values, probs = seq(0, 1, 0.1))
# 
# ggplot() +
#   aes(y = seq_along(kernel_agrumes@data@values), x = kernel_agrumes@data@values) + 
#   geom_point(alpha = 0.2)


# enlever les valeurs faibles
# comment choisir le seuil ?
# kernel_agrumes@data@values[which(kernel_agrumes@data@values < 1)] <- NA

#create pal function for coloring the raster
# Sain = "#16771f", Malade = "#eb8200"
pal_agrumes <- colorQuantile(
    c("transparent", "transparent", "transparent", "grey", "#188C23", "darkgreen"),
    domain = kernel_agrumes@data@values,
    n = 20,
    alpha = TRUE
  )

median(kernel_agrumes@data@values)
# kernel_agrumes@data@values[which(kernel_agrumes@data@values < 1)] <- NA
# pal_agrumes <- colorNumeric(
#   c("grey", "#16771f", "darkgreen"),
#   domain = kernel_agrumes@data@values,
#   alpha = TRUE, na.color = "transparent"
# )

## Leaflet map with raster
leaflet(options = leafletOptions(maxZoom = 14, zoomControl = FALSE)) %>% # maxzoom anonymises data
  addProviderTiles("Stamen.Terrain") %>%
  # setView(55.5, -21.15, zoom = 10) %>%
  addRasterImage(
    kernel_agrumes,
    # colors = pal_agrumes
    # colors = "inferno",
    colors = colorNumeric("magma", reverse = TRUE, domain = kernel_agrumes@data@values, na.color = "transparent"),
    # colors = "Greens",
    opacity = .7
  ) # %>%
  # addLegend(
  #   title = "Densité de vergers en agrumes", # textui (que mettre qui ait du sens ? probabilité ?)
  #   pal = pal_agrumes,
  #   values = kernel_agrumes@data@values
  # )


# densité hlb

# pourquoi 100 ? quand je mets autre chose, ça donne des résultats différents
kernel_hlb <- raster(list(x = kernel_hlu$x , y = kernel_hlu$y, z = kernel_hlu$z / (kernel_par$z + 50))) %>% 
  crop(communes) %>% 
  mask(communes) 
# hist(kernel_hlb@data@values)
# quantile(kernel_hlb@data@values, probs = seq(0, 1, 0.1))
# 
# ggplot() +
#   aes(y = seq_along(kernel_hlb@data@values), x = kernel_hlb@data@values) + 
#   geom_point(alpha = 0.2)

# enlever les valeurs faibles
# comment choisir le seuil ?
# kernel_hlb@data@values[which(kernel_hlb@data@values < 0.05)] <- NA


#create pal function for coloring the raster
# Sain = "#16771f", Malade = "#eb8200"
# pal_hlb <- #colorQuantile(
#   colorNumeric(
#   colorRamp(c("transparent", "#eb8200")),
#   domain = kernel_hlb@data@values
#   # n = 5,
#   # na.color = "transparent"
#   )

pal_hlb <- colorQuantile(
  c("transparent", "transparent", "transparent", "transparent", "grey", "#FAB964", "#eb8200", "red"),
  domain = kernel_hlb@data@values,
  n = 50,
  alpha = TRUE
)
# transparence jusqu'à la médiane
# dégradé du gris au rouge jusqu'à la densité maximale interpolée
# une couleur = quantile à 5% NON

median(kernel_hlb@data@values)
# kernel_hlb@data@values[which(kernel_hlb@data@values < 0.01)] <- NA
# pal_hlb <- colorNumeric(
#   c("grey", "#eb8200", "red"),
#   # colorRamp(c(rgb(0,0,1,1), rgb(0,0,1,0)), alpha = "TRUE"),
#   domain = kernel_hlb@data@values,
#   # n = 50,
#   alpha = TRUE, na.color = "transparent"
# )

## Leaflet map with raster
leaflet(options = leafletOptions(maxZoom = 14, zoomControl = FALSE)) %>% # maxzoom anonymises data
  addProviderTiles("Stamen.Terrain") %>%
  # setView(55.5, -21.15, zoom = 10) %>%
  addRasterImage(
    kernel_hlb,
    # colors = pal_hlb
    # colors = "inferno",
    colors = colorNumeric("magma", reverse = TRUE, domain = kernel_hlb@data@values, na.color = "transparent"),
    # colors = "Reds",
    opacity = .7
    ) #%>%
  # addLegend(
  #   title = "Densité de HLB", # textui (que mettre qui ait du sens ? probabilité ?)
  #   pal = pal_hlb,
  #   values = kernel_hlb@data@values
  # )



# ajouter couche communes par dessus le raster
# légende ou pas ?



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


# # pour essayer de corifer l'ereur de si pas de malade OU de sain dans prelev_sel, le graphe est cassé
# 
# prelev %>% # ici filter avec les input DATE & ALTITUDE
#   as_tibble() %>%
#   group_by(COMMUNE, Maladie) %>%
#   summarise(Surface = sum(Surface)) %>% 
#   pivot_wider(names_from = Maladie, values_from = Surface, values_fill = 0) %>% 
#   ungroup() %>% 
#   arange(Sain, Malade) %>% # par taille totale de la commune ou de la SAU
#   e_chart(COMMUNE) %>% 
#   {if("Malade" %in% names(.$x$data[[1]])) e_bar(Malade, stack = "maladie") else . }%>%
#   {if("Sain" %in% names(.$x$data[[1]])) e_bar(Sain, stack = "maladie") else . }%>%
#   e_tooltip(trigger = "axis") %>% 
#   # e_flip_coords() %>%  # marche pas avec le tooltip formatter...
#   # e_grid(left = "30%") %>% 
#   e_y_axis(formatter = e_axis_formatter(locale = lang)) %>% 
#   e_tooltip(trigger = "axis", formatter = e_tooltip_pointer_formatter(locale = lang, digits = 0)) %>% 
#   e_theme_custom('{"color":["#eb8200","#16771f"]}')
# # y ajouter la surface agricole totale par commune


# 2021-11-22
# passage en ggplot

couleurs_barplot <- c(Sain = "#16771f", Malade = "#eb8200", Non_ech = "#c6baa0")
labels_barplot <- c(Sain = "Saine", Malade = "Malade",  Non_ech = "Non échantillonnée") # textui / "non éch ou non selec" pour être exacte : comment l'expliquer simplement ?
input_fill <- T # cocher si on veut voir la surface en ha ou en %

prelev_sel <- prelev %>% filter(Date < as.Date("2018-06-30")) # filtre user


surface_nonech <- prelev_sel %>%
  group_by(COMMUNE) %>% 
  summarise(Surface_ech = sum(Surface)) %>% # calcul de la surface échantillonnée par commune
  ungroup() %>% 
  inner_join(surface_agrume) %>% 
  mutate(
    Surface = Surface_tot - Surface_ech, # surface non échantilonnée par commune
    Maladie = "Non_ech"
  ) %>% 
  select(COMMUNE, Maladie, Surface)

prelev_sel %>%
  group_by(COMMUNE, Maladie) %>%
  summarise(Surface = sum(Surface)) %>%  
  ungroup() %>% 
  bind_rows(surface_nonech) %>%
  ggplot() +
  aes(x = COMMUNE %>% fct_reorder(Surface, .fun = sum), y = Surface, fill = Maladie %>% fct_relevel("Non_ech")) + # A FAIrE : en sorte que le fct_reorder ne change pas l'ordre des communes à chaque fois que l'utilisateur bouge un truc
  geom_col(position = ifelse(input_fill, "fill", "stack"), width = 0.7) +
  coord_flip() +
  scale_fill_manual(values = couleurs_barplot, labels = labels_barplot) + 
  labs(y = ifelse(input_fill, "Surface en agrumes (%)", "Surface en agrumes (hectares)"), x = "", fill = "Etat de la parcelle") + # textui
  theme_minimal() +
  theme(legend.position = "top")
























# plotly::ggplotly(bar_plot) # mouais...

















leaflet(options = leafletOptions(maxZoom = 14, zoomControl = FALSE)) %>% # maxzoom anonymises data
  addProviderTiles("Stamen.Terain") %>%
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
  addProviderTiles("Stamen.Terain") %>%
  setView(55.7, -21.12, zoom = 11)%>% 
  addPolylines(
    data = pluvio,
    color = ~ colorNumeric("Blues", r_median)(r_median),
    fillColor = "transparent",
    noClip = TrUE
  )



hist(pluvio$r_median, breaks = 40)










