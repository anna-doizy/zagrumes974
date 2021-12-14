#### SERVER ####

server <- function(input, output, session) {
  
  # for local use : stop the server when the session ends
  is_local <- Sys.getenv('SHINY_PORT') == ""
  if(is_local) session$onSessionEnded(function() stopApp())


  # Observe -----------------------------------------------------------------

  ## Get language in the url ####
  lang <- dyn <- NULL

  observe(priority = 1000, {
    lang <<- isolate(getQueryString()$lang)

    if (is.null(lang) || !(lang %in% c("fr", "en"))) {
      lang <<- "fr"
    }

  })
  
  
  ## Filter the data ####
  
  prelev_sel <- reactive({
    prelev %>% 
      filter(
        between(Date, input$periode[1], input$periode[2])
        # between(Altitude, input$altitude[1], input$altitude[2])
      )
  })  
  
  ## Plot the map ####
  
  output$situation_map <- renderLeaflet({
    
    limites <- c(55.2, 55.85, -21.45, -20.85)
    kernel_par <- kde2d(par$longitude, par$latitude, n = 200, lims = limites)
    raster_agrumes <- raster(kernel_par) %>% crop(communes) %>% mask(communes)
    
    
    leaflet(options = leafletOptions(maxZoom = 13, zoomControl = FALSE)) %>% # maxzoom anonymises data
      addProviderTiles("Stamen.Terrain") %>%
      setView(55.5, -21.12, zoom = 10) %>% 
      addRasterImage(
        raster_agrumes,
        colors = "YlGn",
        opacity = 0.7
      ) %>%
      addPolygons(
        data = communes,
        color = "#000",
        fillOpacity = 0,
        popup =  ~ COMMUNE,
        weight = 2
      ) %>% 
      suppressWarnings()
  })
  
  
  ## Update the map ####
  
  observe({
    
    limites <- c(55.2, 55.85, -21.45, -20.85)
    kernel_par <- kde2d(par$longitude, par$latitude, n = 200, lims = limites)
    raster_agrumes <- raster(kernel_par) %>% crop(communes) %>% mask(communes)
    
    if(! input$agrumes_hlb) { # carte agrumes
      leafletProxy("situation_map") %>%
        clearImages() %>% 
        clearShapes() %>% 
        addRasterImage(
          raster_agrumes,
          colors = "YlGn",
          # colors = colorNumeric("magma", reverse = TRUE, domain = raster_agrumes@data@values, na.color = "transparent"),
          opacity = 0.7
        ) %>%
        addPolygons(
          data = communes,
          color = "#000",
          fillOpacity = 0,
          popup =  ~ COMMUNE,
          weight = 2
        ) %>% 
        suppressWarnings()
    } else { # carte hlb
      hlu_sel <- hlu %>% filter(between(date, input$periode[1], input$periode[2]))
    
      if(nrow(hlu_sel) > 0 & class(try(kde2d(hlu_sel$longitude, hlu_sel$latitude, n = 200, lims = limites), silent = TRUE)) != "try-error") {
  
        kernel_hlu <- kde2d(hlu_sel$longitude, hlu_sel$latitude, n = 200, lims = limites)
        raster_hlb <- raster(list(x = kernel_hlu$x , y = kernel_hlu$y, z = kernel_hlu$z / (kernel_par$z + 50))) %>% 
          crop(communes) %>% mask(communes)
        
        leafletProxy("situation_map") %>%
          clearImages() %>% 
          clearShapes() %>% 
          addRasterImage(
            raster_hlb,
            colors = "Reds",
            opacity = 0.7
          ) %>%
          addPolygons(
            data = communes,
            color = "#000",
            fillOpacity = 0,
            popup =  ~ COMMUNE,
            weight = 2
          ) %>% 
          suppressWarnings()
  
      } else {
        leafletProxy("situation_map") %>%
          clearImages() %>% 
          clearShapes()
      }
      
    }
    
    

      
    
  })
  
  # ## Plot the map ####
  # 
  # output$situation_map <- renderLeaflet({
  #   leaflet(options = leafletOptions(maxZoom = 13, zoomControl = FALSE)) %>% # maxzoom anonymises data
  #     addProviderTiles("Stamen.Terrain") %>%
  #     setView(55.5, -21.12, zoom = 10) %>%
  #     addPolygons(
  #       data = communes, 
  #       color = "#000", 
  #       fillOpacity = 0, 
  #       popup =  ~ COMMUNE, 
  #       weight = 2
  #     ) %>% 
  #     addMarkers(
  #       ~X, ~Y, data = prelev %>% filter(Maladie == "Sain"), 
  #       popup = "Présence de HLB non observée dans ce verger", # textui
  #       icon = list(iconUrl = "orchard-healthy.svg", iconSize = c(50,50))
  #     ) %>%
  #     addMarkers(
  #       ~X, ~Y, data = prelev %>% filter(Maladie == "Malade"), 
  #       popup = "Présence de HLB observée dans ce verger", # textui
  #       icon = list(iconUrl = "orchard-unhealthy.svg", iconSize = c(50,50))
  #     )
  # })
  # 
  # 
  # ## Update the map ####
  # 
  # observe({
  # 
  #   leafletProxy("situation_map") %>%
  #     clearMarkers() %>% 
  #     addMarkers(
  #       ~X, ~Y, data = prelev_sel() %>% filter(Maladie == "Sain"), 
  #       popup = "Présence de HLB non observée dans ce verger", # textui
  #       icon = list(iconUrl = "orchard-healthy.svg", iconSize = c(50,50))
  #     ) %>%
  #     addMarkers(
  #       ~X, ~Y, data = prelev_sel() %>% filter(Maladie == "Malade"), 
  #       popup = "Présence de HLB observée dans ce verger", # textui
  #       icon = list(iconUrl = "orchard-unhealthy.svg", iconSize = c(50,50))
  #     )
  # 
  # })
  
  ## Plot the barplot for displaying healphy and unhealphy areas ####
  
  # output$surf_commune <- renderEcharts4r({
  #   if(nrow(prelev_sel()) > 0) # in the case where nothing is selected: don't plot the graph
  #   
  #     prelev_sel() %>%
  #       group_by(COMMUNE, Maladie) %>%
  #       summarise(Surface = sum(Surface)) %>%
  #       pivot_wider(names_from = Maladie, values_from = Surface, values_fill = 0) %>%
  #       ungroup() %>%
  #       arrange(COMMUNE) %>% # A FAIRE : par surface totale en agrume
  #       e_chart(COMMUNE) %>%
  #       e_bar(Malade, stack = "maladie") %>%
  #       e_bar(Sain, stack = "maladie") %>%
  #       e_tooltip(trigger = "axis") %>%
  #       e_grid(left = "20%") %>% 
  #       e_y_axis(formatter = e_axis_formatter(locale = lang)) %>%
  #       e_tooltip(trigger = "axis", formatter = e_tooltip_pointer_formatter(locale = lang, digits = 0)) %>%
  #       e_theme_custom('{"color":["#eb8200","#16771f"]}') %>%
  #       suppressMessages() %>% suppressWarnings()
  #   # y ajouter la surface agricole totale par commune
  #   # theme ?
  #   # ordre des communes
  #   # prevenir de quand on sélectionne un jeu de 0 lignes ?
  # })
  
  
  output$surf_commune <- renderPlot(res = 100, {
    
    couleurs_barplot <- c(Sain = "#16771f", Malade = "#eb8200", Non_ech = "#c6baa0")
    labels_barplot <- c(Sain = "Saine", Malade = "Malade",  Non_ech = "Non échantillonnée") # textui
    
    
    surface_nonech <- prelev_sel() %>%
      group_by(COMMUNE) %>% 
      summarise(Surface_ech = sum(Surface)) %>% # calcul de la surface échantillonnée par commune
      ungroup() %>% 
      inner_join(surface_agrume) %>% # surface totale en agrume par commune
      mutate(
        Surface = Surface_tot - Surface_ech, # surface non échantilonnée par commune
        Maladie = "Non_ech"
      ) %>% 
      dplyr::select(COMMUNE, Maladie, Surface) %>% 
      suppressMessages() # join() message
    
    if(nrow(prelev_sel()) > 0) # in the case where nothing is selected: don't plot the graph
      
      prelev_sel() %>%
        group_by(COMMUNE, Maladie) %>%
        summarise(Surface = sum(Surface)) %>%  
        ungroup() %>% 
        suppressMessages() %>%  # summarise() message
        bind_rows(surface_nonech) %>%
        ggplot() +
        aes(x = COMMUNE %>% fct_reorder(Surface, .fun = sum), y = Surface, fill = Maladie %>% fct_relevel("Non_ech")) +
        geom_col(position = ifelse(input$stack_fill, "fill", "stack"), width = 0.7) +
        coord_flip() +
        scale_fill_manual(values = couleurs_barplot, labels = labels_barplot) + 
        labs(y = ifelse(input$stack_fill, "Surface en agrumes (%)", "Surface en agrumes (hectares)"), x = "", fill = "Etat de la parcelle") + # textui
        theme_minimal() +
        theme(legend.position = "top")
    
    
  })
  
  
  
  
  
  ## Display the model results ####
  
  output$simu_graph <- renderImage({
    list(src = paste0("./www/simulations/duree", input$duree, "seuil", input$seuil, "effort", input$effort, "R0", input$r0,".png"))
  }, deleteFile = FALSE)
  
  output$simu_gif <- renderImage({
    list(src = paste0("./www/simulations/duree", input$duree, "seuil", input$seuil, "effort", input$effort, "R0", input$r0,".gif"))
  }, deleteFile = FALSE)

 
  
} # end of server
