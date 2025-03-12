options(shiny.port = 8050, shiny.autoreload = TRUE)

library(shiny)
library(tidyverse)
library(ggplot2)

# Load data
pokemon <- read.delim("data/raw/pokemon.csv",
                      sep="\t",
                    fileEncoding = "UTF-16LE",
                    encoding = "UTF-8")

# Create supplementary list for colors
poke_type_colors <- list(
  "Normal" = "#A8A77A",
  "Fire" = "#EE8130",
  "Water" = "#6390F0",
  "Electric" = "#F7D02C",
  "Grass" = "#7AC74C",
  "Ice" = "#96D9D6",
  "Fighting" = "#C22E28",
  "Poison" = "#A33EA1",
  "Ground" = "#E2BF65",
  "Flying" = "#A98FF3",
  "Psychic" = "#F95587",
  "Bug" = "#A6B91A",
  "Rock" = "#B6A136",
  "Ghost" = "#735797",
  "Dragon" = "#6F35FC",
  "Dark" = "#705746",
  "Steel" = "#B7B7CE",
  "Fairy" = "#D685AD"
)

# Layout
poke_list <- pokemon |>
    select(english_name)

ui <- fluidPage(
  navbarPage(
    title = "Poké-DashBoard",
    theme = bslib::bs_theme(bootswatch = "journal"),  # Apply the Journal theme
    header = tags$style(HTML("
            .navbar { background-color: red; }
            .navbar .navbar-brand { color: black !important; font-size: 24px; }
            .navbar-nav { display: TRUE; }
        "))
  ),
  fluidRow(
    column(6,
      div(
        selectInput(
            inputId = "poke_name",
            label = "Select a Pokemon",
            choices = poke_list,
            selected = poke_list[1]
        )),
      div(
        checkboxInput("poke_shiny", "Shiny", FALSE),
        br(),
        uiOutput("poke_sprite"),
        br(),
        uiOutput("poke_classification"),
        uiOutput("poke_desc")
      ),
      div(
        id = "poke_types",
        style = "display: flex; align-items: center;",
        uiOutput("poke_type_1"),
        uiOutput("poke_type_2"),
      )
    ),
    column(6,
     div(
       plotOutput("poke_bs_chart")
     )
    )
  )
)
# Server side callbacks/reactivity
server <- function(input, output, session) {
  output$poke_sprite <- renderUI({
    poke_index <- which(poke_list == input$poke_name)
  
    if (input$poke_shiny == TRUE){
        sprite_file <- paste0("sprites/shiny/", poke_index, ".gif")
    }
    else{
        sprite_file <- paste0("sprites/", poke_index, ".gif")
    }
    
    img(src = sprite_file, height="100%")
  })
  
  output$poke_classification <- renderUI({
    poke_index <- which(poke_list == input$poke_name)
    classification <- pokemon |> 
      filter(national_number == poke_index)
    h3(classification$classification)
  })
  
  output$poke_desc <- renderUI({
    poke_index <- which(poke_list == input$poke_name)
    desc <- pokemon |> 
      filter(national_number == poke_index)
    p(desc$description)
  })
  
  output$poke_type_1 <- renderUI({
    poke_index <- which(poke_list == input$poke_name)
    poke_type_1 <- pokemon |> 
      filter(national_number == poke_index) |> 
      select(primary_type)
    span(
      style = paste("border: 2px solid black;",
                    "background-color:", poke_type_colors[str_to_sentence(poke_type_1)],
                    "; padding: 10px;",
                    "margin-right: 10px;",
                    "color: #fcfcfc;",
                    "font-weight: bold;"),
      str_to_sentence(poke_type_1))
  })
  
  output$poke_type_2 <- renderUI({
    poke_index <- which(poke_list == input$poke_name)
    poke_type_2 <- pokemon |> 
      filter(national_number == poke_index) |> 
      select(secondary_type)
    
    if (poke_type_2 != ""){
      span(
        style = paste("border: 2px solid black;",
                      "background-color:", poke_type_colors[str_to_sentence(poke_type_2)],
                      "; padding: 10px;",
                      "margin-right: 10px;",
                      "color: #fcfcfc;",
                      "font-weight: bold;"),
        str_to_sentence(poke_type_2))
    }
  })
  
  output$poke_bs_chart <- renderPlot({
    poke_index <- which(poke_list == input$poke_name)
    base_stats <- pokemon |>
      filter(national_number == poke_index) |> 
      select(hp, attack, defense, sp_attack, sp_defense, speed) |> 
      rename(HP = hp,
             Attack = attack,
             Defense = defense,
             `Special Attack` = sp_attack, 
             `Special Defense` = sp_defense,
             Speed = speed) |> 
      pivot_longer(cols = everything(), names_to = "stat", values_to = "value") |> 
      mutate(stat = factor(stat, levels=c("HP", 
                                          "Attack", 
                                          "Defense", 
                                          "Special Attack",
                                          "Special Defense",
                                          "Speed")))
      
    
    base_stats_chart <- base_stats |>
      ggplot(aes(x = "", y = value, fill = stat)) +
      geom_col(width = 0.5, color = "black") +
      geom_text(aes(label = value),
                position = position_stack(vjust = 0.5)) +
      coord_polar(theta = "y") +
      guides(fill = guide_legend(title = "stats")) +
      ggtitle("Base Stats Distribution") +
      theme(axis.ticks = element_blank(),
            axis.text.y = element_blank(),
            axis.text.x = element_blank(),
            axis.title = element_blank(),
            axis.text = element_text(size = 15),
            plot.title = element_text(size = 20,
                                      family = "Helvetica",
                                      face="bold", 
                                      hjust = 0.5),
            panel.border = element_rect(color = "grey", linewidth = 2, fill=NA),
            panel.background = element_rect(fill = NA),) +
      scale_fill_brewer(palette="Set2")
    
    base_stats_chart
  })
}

# Run the app/dashboard
shinyApp(ui, server)