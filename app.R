options(shiny.port = 8050, shiny.autoreload = TRUE)

library(shiny)
library(tidyverse)

# Load data
pokemon <- read.delim("data/raw/pokemon.csv", sep=";")

# Layout
poke_list <- pokemon |>
    select(name, id) |>
    distinct(name, .keep_all = TRUE) |>
    mutate(name = str_to_sentence(name))

ui <- fluidPage(
    selectInput(
        "poke_name",
        "Select a Pokemon",
        choices = poke_list,
        selected = poke_list[1],
    ),
    checkboxInput("poke_shiny", "Shiny", FALSE),
    br(),
    uiOutput("poke_sprite"),
    uiOutput("poke_classification"),
    uiOutput("poke_desc")
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
    
    img(src = sprite_file, height="200px")
  })
  output$poke_classification <- renderUI({
    poke_index <- which(poke_list == input$poke_name)
    classification <- pokemon |> 
      filter(id == poke_index)
    h3(classification$classification[1])
  })
  output$poke_desc <- renderUI({
    poke_index <- which(poke_list == input$poke_name)
    desc <- pokemon |> 
      filter(id == poke_index)
    p(desc$desc[1])
  })
}

# Run the app/dashboard
shinyApp(ui, server)