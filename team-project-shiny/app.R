library(shiny)
library(tidyverse)
library(DT)
source("RDS-Creation-Script.R")
# https://jleach.shinyapps.io/oyster/
# https://github.com/Jim89/oyster/blob/master/R/shiny/ui.R



ui <- shinyUI(navbarPage("Video Game Sales Application",
                   
                   
# Defining tabs to be used

#Introduction
tabPanel("Introduction",
         #includeMarkdown(""))
         h4("Welcome to our Shiny application")

                   ),

#Search Table Tab
tabPanel("Search Table", 
         DT::dataTableOutput("table")
),

#Plots Tab
tabPanel("Plots", 
         fluidRow(
             sidebarPanel(
                 selectInput("xvariable",
                             label = "Choose an X Variable",
                             choices = list("Year_of_Release", "Genre", "Rating", "User_Score", "Critic_Score"),
                             selected = "Year_of_Release"
                             
                 ),
                 br(),
                 selectInput("yvariable",
                             label = "Choose a Y Variable",
                             choices = list("Global_Sales", "NA_Sales", "EU_Sales", "JP_Sales", "Other_Sales"),
                             selected = "Global_Sales"
                 )   
             ),
            mainPanel(plotOutput("gameplot"))
         )
)

#Closing shinyUI
))


    
    
server <- function(input, output) {
    
    videogames <- video_game_sales %>% 
        dplyr::select(Name, Year_of_Release, Platform, Publisher, Global_Sales)
    
    #Creating the search table
    output$table <- renderDataTable({
        videogames <- DT::datatable(rownames = FALSE, videogames,
                                    options = list(columnDefs = list(list(width = '150px'))))
        videogames
    })
    
    #Create a new dataset containing all the variables we want.
    cleangames <- video_game_sales %>% 
        na.omit()
    
    output$gameplot <- renderPlot({
        
        # Render a scatterplot
        ggplot(cleangames, mapping = aes(x = !!as.name(input$xvariable), y = !!as.name(input$yvariable))) +
                       geom_jitter()
    })
}
shinyApp(ui = ui, server = server)