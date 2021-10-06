#### SERVER ####

server <- function(input, output, session) {
  
  # for local use : stop the server when the session ends
  is_local <- Sys.getenv('SHINY_PORT') == ""
  if(is_local) session$onSessionEnded(function() stopApp())


  # Observe -----------------------------------------------------------------
  
  observe_helpers()

  ## Get language in the url ####
  lang <- dyn <- NULL

  observe(priority = 1000, {
    lang <<- isolate(getQueryString()$lang)

    if (is.null(lang) || !(lang %in% c("fr", "en"))) {
      lang <<- "fr"
    }

  })
  
  
  output$situation_map <- renderLeaflet({
    leaflet(options = leafletOptions(maxZoom = 14, zoomControl = FALSE)) %>% # maxzoom anonymises data
      addProviderTiles("Stamen.Terrain") %>%
      setView(55.5, -21.15, zoom = 11) %>%
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
        color = "red",
        fill = TRUE,
        opacity = 0.5,
        fillOpacity = 0.5,
        radius = ~ Surface/1000
      )
  })
  
  
  

 
  
} # end of server
