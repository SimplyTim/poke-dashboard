options(shiny.port = 8050, shiny.autoreload = TRUE)

library(shiny)
library(bslib)
library(tidyverse)
library(plotly)

# Load data
pokemon <- read.delim("../data/processed/pokemon_cleaned.csv",
                      sep="\t")
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

ui <- page_fillable(
  id="layout",
  style = " background: url('background.png');
          background-position: center;
          background-size: contain;
          background-repeat: no-repeat;
          background-color:rgba(255, 255, 255, 0.9);
          background-blend-mode: saturation;",
  navbarPage(
    title = "Poké-DashBoard",
    theme = bs_theme(version = 5, bootswatch = "journal"),
    bg = "#e64343",
    position = "fixed-top"
  ),
  fluidRow(
    style="margin-top: 10px; overflow: visible;",
    layout_columns(
      div(
        id = "poke_filters",
        selectInput(
            inputId = "poke_name",
            label = "Select a Pokemon",
            choices = poke_list,
            selected = poke_list[1]),
        input_switch("poke_shiny", "Shiny"),
        br(),
        div(
          id = "poke_sprite_type",
          imageOutput("poke_sprite", height="100%"),
          style = "text-align: center;",
        br(),
        div(
          id = "poke_types",
          style = "display: flex; 
          align-items: center; 
          text-align: center;
          justify-content: center;",
          uiOutput("poke_type_1"),
          uiOutput("poke_type_2")
        ),
        br(),
        div(
          uiOutput("poke_classification"),
          uiOutput("poke_desc"))
        )
      ),
      card(
        style = "height: 350px;
        align-items: middle; 
        justify-content: center;",
        id = "base_stat_card",
        plotlyOutput("poke_bs_chart", height = "25%")
      )
    )
  ),
  fluidRow(
    layout_columns(
      card(
        style = "height: 250px;",
        uiOutput("poke_gender_distr"),
        uiOutput("poke_height"),
        uiOutput("poke_weight"),
        uiOutput("poke_capture_rate"),
        uiOutput("poke_gen")
      ),
      card(
        style = "height: 250px;",
        id = "type_card",
        tableOutput("poke_type_table")
      )
    )
  )
)
# Server side callbacks/reactivity
server <- function(input, output, session) {
  # Pokemon Sprite
  output$poke_sprite <- renderImage({
    poke_index <- which(poke_list == input$poke_name)
  
    if (input$poke_shiny == TRUE){
        sprite_file <- paste0("../data/img/sprites/shiny/", poke_index, ".gif")
    }
    else{
        sprite_file <- paste0("../data/img/sprites/", poke_index, ".gif")
    }
    list(src = sprite_file) 
  }, deleteFile = FALSE )
  
  # Pokemon Classification
  output$poke_classification <- renderUI({
    poke_index <- which(poke_list == input$poke_name)
    classification <- pokemon |> 
      filter(national_number == poke_index)
    h3(classification$classification)
  })
  
  # Pokemon Description
  output$poke_desc <- renderUI({
    poke_index <- which(poke_list == input$poke_name)
    desc <- pokemon |> 
      filter(national_number == poke_index)
    p(desc$description)
  })
  
  # Type 1
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
                    "font-weight: bold;",
                    "text-align: center;",
                    "width: 90px;"),
      str_to_sentence(poke_type_1))
  })
  
  # Type 2
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
                      "font-weight: bold;",
                      "text-align: center;",
                      "width: 90px;"),
        str_to_sentence(poke_type_2))
    }
  })
  
  # Base Stats Chart
  output$poke_bs_chart <- renderPlotly({
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
      pivot_longer(cols = everything(), names_to = "stats", values_to = "value") |> 
      mutate(stats = factor(stats, levels=c("HP", 
                                          "Attack", 
                                          "Defense", 
                                          "Special Attack",
                                          "Special Defense",
                                          "Speed"))) 
    base_stats_chart <- base_stats |> 
      ggplot(aes(x = value, y = fct_rev(stats), fill = stats)) + 
      geom_col(width = 0.5) +
      theme(
        legend.position = "none",
        plot.background = element_rect(fill = "transparent", color = NA),
        legend.background = element_rect(fill = "transparent", color = NA)
      ) +
      xlab("") + 
      ylab("") + 
      ggtitle(paste0(input$poke_name, " Base Stats")) +
      scale_fill_brewer(palette="Dark2")
      
    ggplotly(base_stats_chart, tooltip = "value") 
  })
  
  # Pokemon Gender Distribution
  output$poke_gender_distr <- renderUI({
    poke_index <- which(poke_list == input$poke_name)
    gender_distr <- pokemon |> 
      filter(national_number == poke_index) |> 
      select(percent_male, percent_female)
   
    if (gender_distr$percent_male == ""){
      div(
        span("Gender Distribution:",
             style="font-weight: bold;"),
        span("N/A"))
    }
    else{
    div(
      span("Gender Distribution:",
           style="font-weight: bold;"),
      span(paste0("Males: ",
                  gender_distr$percent_male,
                  "%, Females: ",
                  gender_distr$percent_female,
                  "%")))
    }
  })
  
  # Pokemon Height
  output$poke_height <- renderUI({
    poke_index <- which(poke_list == input$poke_name)
    height <- pokemon |> 
      filter(national_number == poke_index) |> 
      select(height_m)
    
    div(
      span("Height:",
           style="font-weight: bold;"),
      span(paste0(height$height_m,
                  " m"))
    )
  })
  
  # Pokemon Weight
  output$poke_weight <- renderUI({
    poke_index <- which(poke_list == input$poke_name)
    weight <- pokemon |> 
      filter(national_number == poke_index) |> 
      select(weight_kg)
    
    div(
      span("Weight:",
           style="font-weight: bold;"),
      span(paste0(weight$weight_kg,
                  " kg"))
    )
  })
  
  # Pokemon Capture Rate
  output$poke_capture_rate <- renderUI({
    poke_index <- which(poke_list == input$poke_name)
    cap_rate <- pokemon |> 
      filter(national_number == poke_index) |> 
      select(capture_rate_perc)
    
    div(
      span("Capture Rate:",
           style="font-weight: bold;"),
      span(paste0(cap_rate$capture_rate_perc,
           "%"))
    )
  })
  
  # Pokemon Generation
  output$poke_gen <- renderUI({
    poke_index <- which(poke_list == input$poke_name)
    gen <- pokemon |> 
      filter(national_number == poke_index) |> 
      select(gen)
    
    div(
      span(paste0("Introduced in Generation ", gen$gen))
    )
  })
  
  # Type Effectiveness Table
  output$poke_type_table <- renderTable(
    vs_types <- pokemon |>
      filter(national_number == which(poke_list == input$poke_name)) |> 
      select(against_normal, against_fire, against_water, against_electric, 
             against_grass, against_ice, against_fighting, against_poison, 
             against_ground, against_flying, against_psychic, against_bug, 
             against_rock, against_ghost, against_dragon, against_dark, 
             against_steel, against_fairy) |> 
      rename(
        Normal = against_normal,
        Fire = against_fire,
        Water = against_water,
        Electric = against_electric,
        Grass = against_grass,
        Ice = against_ice,
        Fighting = against_fighting,
        Poison = against_poison,
        Ground = against_ground,
        Flying = against_flying,
        Psychic = against_psychic,
        Bug = against_bug,
        Rock = against_rock,
        Ghost = against_ghost,
        Dragon = against_dragon,
        Dark = against_dark,
        Steel = against_steel,
        Fairy = against_fairy
      ) |> 
      pivot_longer(cols = everything(), 
                   names_to = "Type", 
                   values_to = paste0("Effectiveness against ", input$poke_name)
                   ), 
    striped = TRUE)
  
}

# Run the app/dashboard
shinyApp(ui, server)