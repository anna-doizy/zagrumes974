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
 
  
  
  
  output$surf_commune <- renderPlot(res = 100, {
    
    couleurs_barplot <- c(Sain = "#16771f", Malade = "#eb8200", Non_ech = "#c6baa0")
    labels_barplot <- c(
      Sain = textesUI[[lang]][textesUI$id == "situation_plot_sain"], 
      Malade = textesUI[[lang]][textesUI$id == "situation_plot_malade"],  
      Non_ech = textesUI[[lang]][textesUI$id == "situation_plot_nonech"]
      )
    
    
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
        labs(
          y = ifelse(input$stack_fill, textesUI[[lang]][textesUI$id == "situation_plot_ystack"], textesUI[[lang]][textesUI$id == "situation_plot_yfill"]), 
          x = "", 
          fill = textesUI[[lang]][textesUI$id == "situation_plot_legend"]
          ) +
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
