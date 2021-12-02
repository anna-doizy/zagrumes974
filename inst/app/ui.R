#### UI ####

suppressPackageStartupMessages({
  library(shiny)
  library(shinydashboard)
  library(shinyhelper) # ???
  library(shinyWidgets)
  library(dplyr)
  library(tidyr)
  library(forcats)
  library(ggplot2)
  library(sf)
  library(leaflet)
  library(zagrumes974)
})



function(req) {
  
  # Get language
  lang <- try(parseQueryString(req$QUERY_STRING)$lang)

  if (is.null(lang) || !(lang %in% c("fr", "en"))) {
    lang <- "fr"
  }


  # TITLE -------------------------------------------------------------------

  # header <- dashboardHeader(title = HTML(textesUI[[lang]][textesUI$id == "titre"])) # mettre une image ?
  header <- dashboardHeader(title = a(href = paste0("./?lang=", lang), img(src="title-zagrumes974.png", width = 190)))

  # SIDEBAR -----------------------------------------------------------------



  sidebar <- dashboardSidebar(
    sidebarMenu(
      id = "tabs",
      br(),
      if(shiny:::inShinyServer()) { # show langage icons if in server
        tagList(
          lapply(c("fr", "en"), 
          function(l) {
            a(img(src = paste0("flag_", l, ".png"), height = 30), 
              href = paste0("./?lang=", l), 
              style = "padding:40px") # 20 pour 3 langues
          }),
          hr()
        )
      }

      # Tabs
      , lapply(seq(along.with = onglets$id), function(tab) {
        menuItem(
          text = strong(onglets[[lang]][tab]),
          tabName = onglets$id[tab],
          icon = icon(onglets$icon[tab])
        )
      })#,
      # menuItem(
      #   text = strong(textesUI[[lang]][textesUI$id == "contact"]),
      #   href = "mailto:zagrumes974@cirad.fr",
      #   icon = icon("at")
      # )
    )
  )





  # BODY --------------------------------------------------------------------




  body <- dashboardBody(
    tags$head(
      tags$link(rel = "shortcut icon", href = "favicon.png"),
      tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
      ),
    
    tabItems(

      # Onglet Accueil ####
      
      tabItem(tabName = "accueil", fluidRow(
        div(includeMarkdown(sprintf("locale/accueil_%s.md", lang)), class = "markdown-tab")
      ))

      
      # Onglet le HLB à la RUN ####
      # , tabItem(tabName = "situation", fluidRow(
      #   leafletOutput("situation_map"),
      #   
      #   absolutePanel( # peut-être faire deux boîtes pour le responsiveness ???
      #     id = "controls", class = "panel panel-default", fixed = FALSE,
      #     draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
      #     width = 400, height = "auto",
      #     
      #     p(),
      #     
      #     ## time
      #     sliderInput(
      #       "periode",
      #       label = strong("Choix de la période"), # textui
      #       min = min(prelev$Date),
      #       max = max(prelev$Date),
      #       value = range(prelev$Date),
      #       timeFormat = "%m/%Y", # lang "%Y-%m"
      #       ticks = FALSE
      #     ),
      #     
      #     # elevation
      #     sliderInput(
      #       "altitude",
      #       label = strong("Choix de l'altitude"), # textui
      #       min = 0,
      #       max = 3000,
      #       value = c(0, 3000),
      #       ticks = FALSE
      #     ),
      #     
      #     ## temporal evolution
      #     p(strong("Surface échantillonnée par commune")), # textui
      #     echarts4rOutput("surf_commune", height = "auto"),
      #     
      #     br(),
      #     ## pluviométrie
      #     p(strong("Pluviométrie médiane de 1986 à 2016")), # textui
      #     checkboxInput("pluvio_check", label = "Afficher la pluviométrie annuelle", value = FALSE)
      #   ), # end of absolute panel
      # 
      # ))
      
      , tabItem(tabName = "situation", fluidRow(
        column(
          width = 7,
          box(
            status = "success", width = 12, solidHeader = FALSE, title = strong(em("Carte présentant la situation connue actuelle du HLB à la Réunion")), # tesxtui
            leafletOutput("situation_map"))
            # icon("question-circle"),
            # "Les prélèvements géolocalisés étant des données personnelles, ici nous extrapolons de ces données les zones de présence du HLB à la Réunion." # textui
        ),
        
        column(
          width = 5,
          box(
            status = "success", width = 12, solidHeader = FALSE, title = strong(em("A vous d'explorer !")), # textui
            
            ## time ####
            sliderInput(
              "periode",
              label = strong("Choix de la période"), # textui
              min = min(prelev$Date),
              max = max(prelev$Date),
              value = range(prelev$Date),
              timeFormat = "%m/%Y", # lang "%Y-%m"
              width = "80%",
              ticks = FALSE
            ),
            
            includeMarkdown(sprintf("locale/explication-interpolation_%s.md", lang)), # EN
            
            
            # cocher si on veut voir la surface en ha ou en %
            materialSwitch(
              "stack_fill",
              label = strong("Surface en hectare / pourcentage") # textui
            ),
            
            # # elevation
            # sliderInput(
            #   "altitude",
            #   label = strong("Choix de l'altitude"), # textui
            #   min = 0,
            #   max = 3000,
            #   value = c(0, 3000),
            #   width = "80%",
            #   ticks = FALSE
            # ),
            
            
            ## temporal evolution ####
            p(strong("Surface échantillonnée par commune")), # textui
            plotOutput("surf_commune")
            
          ) # end of box
        )
      ))
      
      # onglet Modéliser une épidémie ####
      
      , tabItem(tabName = "modele", fluidRow(
        column(
          width = 7,
          box(
            status = "success", width = 12, solidHeader = FALSE, title = strong(em("Modéliser une épidémie")), # textui
            
            includeMarkdown(sprintf("locale/explication-modele_%s.md", lang)), # EN
            
            # ici les inputs
            # ATTENTION textui
            
            column(
              width = 6,
              radioButtons("r0", label = "R0 (taux de reproduction de la maladie)", choices = c(1, 5), inline = TRUE),
              radioButtons("seuil", label = "Seuil de transmission", choiceValues = c(0, 5000), choiceNames = c("transmission non limitée par la distance", "pas de transmission au delà de 5 kilomètres")),
              ),
            
            column(
              width = 6,
              radioButtons("effort", label = "Fréquence d'arrachage des arbres malades (en jours)", choices = c(30, 365), inline = TRUE),
              radioButtons("duree", label = "Durée de la simulation (en jours)", choices = c(100, 365), inline = TRUE)
            )

            
          )
        ),
        
        column(
          width = 5,
          box(
            status = "success", width = 12, solidHeader = FALSE, title = strong(em("Evolution de l'épidémie sur un parcellaire fictif")), # textui
            
            imageOutput("simu_graph"), # A FAIRE rendre responsive
            imageOutput("simu_gif", height = "700px") # A FAIRE rendre responsive
            
            
          ) # end of box
        )
      ))
      
      # Onglet en savoir plus ####
      , tabItem(tabName = "savoirplus", fluidRow(
        div(includeMarkdown(sprintf("locale/savoirplus_%s.md", lang)), class = "markdown-tab")
      ))

    ) # end of tabItems
  ) # end of Dashboardbody



# PAGE --------------------------------------------------------------------

  dashboardPage(header, sidebar, body, title = "zagrumes974", skin = "green")
} # end of req
