#### UI ####

suppressPackageStartupMessages({
  library(shiny)
  library(shinydashboard)
  library(shinyWidgets)
  library(MASS)
  library(dplyr)
  library(tidyr)
  library(forcats)
  library(ggplot2)
  library(sf)
  library(raster)
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
      })
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

      
      , tabItem(tabName = "situation", fluidRow(
        column(
          width = 7,
          box(
            status = "success", width = 12, solidHeader = FALSE, title = strong(em(textesUI[[lang]][textesUI$id == "situation_box_map"])),
            leafletOutput("situation_map"))
        ),
        
        column(
          width = 5,
          box(
            status = "success", width = 12, solidHeader = FALSE, title = strong(em(textesUI[[lang]][textesUI$id == "situation_box_explore"])),
            
            # cocher si on veut voir la surface en ha ou en %
            materialSwitch(
              "agrumes_hlb",
              label = strong(textesUI[[lang]][textesUI$id == "situation_agrumes_hlb"])
            ),
            
            br(),
            
            ## time ####
            sliderInput(
              "periode",
              label = strong(textesUI[[lang]][textesUI$id == "situation_periode"]),
              min = min(prelev$Date),
              max = max(prelev$Date),
              value = range(prelev$Date),
              timeFormat = textesUI[[lang]][textesUI$id == "time_format"],  #"%m/%Y", # lang "%Y-%m"
              width = "80%",
              ticks = FALSE
            ),
            
            
            includeMarkdown(sprintf("locale/explication-interpolation_%s.md", lang)), # EN
            
            
            # cocher si on veut voir la surface en ha ou en %
            materialSwitch(
              "stack_fill",
              label = strong(textesUI[[lang]][textesUI$id == "situation_stackfill"])
            ),

            ## temporal evolution ####
            p(strong(textesUI[[lang]][textesUI$id == "situation_plot"])),
            plotOutput("surf_commune")
            
          ) # end of box
        )
      ))
      
      # onglet Modéliser une épidémie ####
      
      , tabItem(tabName = "modele", fluidRow(
        column(
          width = 7,
          box(
            status = "success", width = 12, solidHeader = FALSE, title = strong(em(textesUI[[lang]][textesUI$id == "modele_box_desc"])),
            
            includeMarkdown(sprintf("locale/explication-modele_%s.md", lang)), # EN
            
            # inputs
            
            column(
              width = 6,
              radioButtons("r0", label = textesUI[[lang]][textesUI$id == "modele_r0"], choices = c(1, 5), inline = TRUE),
              radioButtons("seuil", label = textesUI[[lang]][textesUI$id == "modele_seuil"], choiceValues = c(0, 5000), choiceNames = c(textesUI[[lang]][textesUI$id == "modele_seuil0"], textesUI[[lang]][textesUI$id == "modele_seuil5"])),
              ),
            
            column(
              width = 6,
              radioButtons("effort", label = textesUI[[lang]][textesUI$id == "modele_effort"], choices = c(30, 365), inline = TRUE),
              radioButtons("duree", label = textesUI[[lang]][textesUI$id == "modele_duree"], choices = c(100, 365), inline = TRUE)
            )

            
          )
        ),
        
        column(
          width = 5,
          box(
            status = "success", width = 12, solidHeader = FALSE, title = strong(em(textesUI[[lang]][textesUI$id == "modele_box_evolution"])),
            
            imageOutput("simu_graph"),
            imageOutput("simu_gif", height = "700px")
            
            
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
