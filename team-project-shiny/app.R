library(shiny)
library(tidyverse)
library(DT)
source("RDS-Creation-Script.R")



gamegenres <- video_game_sales %>% 
    filter(Genre %in% c("Action", "Adventure", "Fighting", "Misc", "Platform", "Puzzle", 
                        "Racing", "Role-Playing", "Shooter", "Simulation", "Sports", "Strategy"))

ui <- fluidPage(
    
    #App title
    
    titlePanel("Video Game History Application"),
    
    # Side Bar Panel
    
    sidebarLayout(
        sidebarPanel(
            selectInput("genre",
                        label = "Choose a Genre of Video Game",
                        choices = list("Action", "Adventure", "Fighting", "Misc", "Platform", "Puzzle", 
                                       "Racing", "Role-Playing", "Shooter", "Simulation", "Sports", "Strategy"),
                        selected = "Action"
                                      
                        )
                
            ),
        # Main Panel
        
        mainPanel(
            
            # Output: Tabset w/ plot, summary, and table ----
            tabsetPanel(type = "tabs",
                        tabPanel("Search Table", DT::dataTableOutput("table")),
                        tabPanel("Plot", plotOutput("plot")),
                        tabPanel("Summary", verbatimTextOutput("summary"))
            )
        )
    )
    
)
    
    
server <- function(input, output) {
    
    videogames <- video_game_sales %>% 
        dplyr::select(Name, Year_of_Release, Platform, Publisher, Global_Sales, Critic_Score, User_Score, Rating)
    
    #Creating the search table
    output$table <- renderDataTable({
        videogames <- DT::datatable(rownames = FALSE, videogames,
                                    options = list(columnDefs = list(list(width = '150px',
                                                                          targets = c(2,3,4,5)))))
        videogames
    })
}
shinyApp(ui = ui, server = server)