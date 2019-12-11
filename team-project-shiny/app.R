library(shiny)
library(shinyjs)
library(tidyverse)
library(DT)
source("RDS-Creation-Script.R")
#USEFUL LINKS FOR CREATING THE TABS AND DIFF SIDE PANELS
# https://jleach.shinyapps.io/oyster/
# https://github.com/Jim89/oyster/blob/master/R/shiny/ui.R

# SHINY THEMES PACKAGE: 
# http://rstudio.github.io/shinythemes/


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
             useShinyjs(),
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
),

# Time plots tab
tabPanel("Time plots",
         fluidRow(
             sidebarPanel(
                 selectInput("xvariable_time",
                             label = "Choose an X Variable",
                             choices = list("Year", "Month"),
                             selected = "Year"

                 ),
                 br(),
                 sliderInput("yearsRange",
                                 label = "Choose the years range",
                                 min = 1971, max = 2016, value = c(1971, 2016), sep = ""),
                 br(),
                 sliderInput("monthsRange",
                             label = "Choose the months range",
                             min = 1, max = 12, value = c(1, 12))
             ),
             mainPanel(plotOutput("timeplot"))
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
    
    x_variable <- reactive({
        ifelse (input$xvariable_time == "Year", return ("Year"), return ("Month"))
    })
    
    observeEvent(input$xvariable_time, {
        if(input$xvariable_time == "Year"){
            enable("monthsRange")
            disable("yearsRange")
        }else{
            enable("yearsRange")
            disable("monthsRange")
        }
    })
    
    months_range_1 <- reactive({
        return (input$monthsRange[1])
    })
    
    months_range_2 <- reactive({
        return (input$monthsRange[2])
    })
    
    years_range_1 <- reactive({
        return (input$yearsRange[1])
    })
    
    years_range_2 <- reactive({
        return (input$yearsRange[2])
    })
    
    output$timeplot <- renderPlot({   
        
        if (x_variable() == "Month")
            video_game_sales_release %>%
            filter(between(year(releaseDate), years_range_1(), years_range_2())) %>%
            group_by(month = month(releaseDate, label = TRUE)) %>%
            summarise(avg_sales_per_month = median(Global_Sales)) %>%
            ggplot(aes(x = month, y = avg_sales_per_month, fill = avg_sales_per_month)) +
            geom_bar(stat = "identity") +
            labs(title = "Average sales of video games per month",
                 subtitle = "restricted by year",
                 y = "Average sales (Billions)",
                 x = "Month")
            
        else 
            video_game_sales_release %>%
            filter(between(month(releaseDate), months_range_1(), months_range_2())) %>%
            group_by(year = year(releaseDate)) %>%
            summarise(avg_sales_per_year = median(Global_Sales)) %>% 
            ggplot(aes(x = year, y = avg_sales_per_year, fill = avg_sales_per_year)) +
            geom_bar(stat = "identity") +
            labs(title = "Average sales of video games per year",
                 subtitle = "restricted by month",
                 y = "Average sales (Billions)",
                 x = "Year")
        
    })
}
shinyApp(ui = ui, server = server)