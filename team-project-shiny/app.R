library(tidyverse)
library(DT)
library(shinyjs)
source("RDS-Creation-Script.R")
#USEFUL LINKS FOR CREATING THE TABS AND DIFF SIDE PANELS
# https://jleach.shinyapps.io/oyster/
# https://github.com/Jim89/oyster/blob/master/R/shiny/ui.R

# SHINY THEMES PACKAGE: 
# http://rstudio.github.io/shinythemes/

withConsoleRedirect <- function(containerId, expr) {
    # Change type="output" to type="message" to catch stderr
    # (messages, warnings, and errors) instead of stdout.
    txt <- capture.output(results <- expr, type = "output")
    if (length(txt) > 0) {
        insertUI(paste0("#", containerId), where = "beforeEnd",
                 ui = paste0(txt, "\n", collapse = "")
        )
    }
    results
}



ui <- shinyUI(navbarPage("Video Game Sales Application", 
                         
                         
                         # Defining tabs to be used
                         #Introduction
                         tabPanel("Introduction"
                         ),
                         
                         #Search Table Tab
                         tabPanel("Search Table", 
                                  DT::dataTableOutput("table")
                         ),
                         #Plots Tab
                         tabPanel("Plots", useShinyjs(),
                                  fluidRow(
                                      sidebarPanel(
                                          selectInput("xvariable",
                                                      label = "Choose an X Variable",
                                                      choices = list("Year_of_Release", "Genre", "Rating", "User_Score", "Critic_Score", "Platform"),
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
                                      mainPanel(plotOutput("timeplot"))),
                                  fluidRow(
                                      mainPanel(plotOutput("timeScatterPlot"))
                                  )
                         ), #Closing Time plots panel
                         
                         #T Test Tab
                         tabPanel("T-Test",
                                  h3("Do games released on both Xbox and 
                                     Playstation sell better on one console?"),
                                  p("Null Hypothesis: The true mean sales of games released on Xbox and Playstation consoles is equal."),
                                  p("Alternative Hypothesis: There is a difference in true mean sales of games released on Xbox and Playstation consoles."),
                                  h4("Assumptions"),
                                  p("Due to our dataset containing the sales data for all games released on Xbox and Playstation our sample is practically the"),
                                  p("populations of Xbox and Playstation games. Our test will continue as planned."),
                                  h4("The T-test"),
                                  verbatimTextOutput("ttest"),
                                  h4("Conclusion"),
                                  p("A p-value of 0.03956 indicates there is strong evidence to reject the null hypothesis."),
                                  p("There is a difference in true mean global sales of games released on Xbox and Playstation consoles. Based on the sample"),
                                  p("means, Xbox has had higher mean global sales compared to Playstation for games which have been released on both consoles.")
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
            filter(between(year(releaseDate), years_range_1(), years_range_2()) &
                       between(month(releaseDate), months_range_1(), months_range_2())) %>%
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
            filter(between(month(releaseDate), months_range_1(), months_range_2()) &
                       between(year(releaseDate), years_range_1(), years_range_2())) %>%
            group_by(year = year(releaseDate)) %>%
            summarise(avg_sales_per_year = median(Global_Sales)) %>% 
            ggplot(aes(x = year, y = avg_sales_per_year, fill = avg_sales_per_year)) +
            geom_bar(stat = "identity") +
            labs(title = "Average sales of video games per year",
                 subtitle = "restricted by month",
                 y = "Average sales (Billions)",
                 x = "Year")
        
    })
    
    output$timeScatterPlot <- renderPlot({
        if (x_variable() == "Year") {
            video_game_sales_release %>%
                filter(between(month(releaseDate), months_range_1(), months_range_2()) &
                           between(year(releaseDate), years_range_1(), years_range_2())) %>%
                ggplot(aes(x = year(releaseDate), y = Global_Sales)) +
                geom_jitter() +
                labs(title = "Global sales of video games",
                     x = "Year", 
                     y = "Global sales (Billions)")
        }
        
        else {
            video_game_sales_release %>%
                filter(between(year(releaseDate), years_range_1(), years_range_2()) &
                           between(month(releaseDate), months_range_1(), months_range_2())) %>%
                ggplot(aes(x = month(releaseDate, label = TRUE), y = Global_Sales)) +
                geom_jitter() +
                labs(title = "Global sales of video games",
                     x = "Month", 
                     y = "Global sales (Billions)")
        }
    })
    
    #T-Test
    xbox_playstation <- video_game_sales %>%
        filter(Platform %in% "XOne" | 
                   Platform %in% "XB" |
                   Platform %in% "X360" |
                   Platform %in% "PS" |
                   Platform %in% "PS2" |
                   Platform %in% "PS3" |
                   Platform %in% "PS4" |
                   Platform %in% "PSP" |
                   Platform %in% "PSV"
        )
    xbox_summary <- xbox %>%
        summarise(count = n(), mean = mean(Global_Sales), std = sd(Global_Sales))
    playstation_summary <- playstation %>%
        summarise(count = n(), mean = mean(Global_Sales), std = sd(Global_Sales))
    system_var <- xbox_playstation %>%
        mutate(System = case_when(
            Platform %in% c("XOne", "XB", "X360") ~ "Xbox",
            Platform %in% c("PS", "PS2", "PS3", "PS4", "PSP", "PSV") ~ "PlayStation"
        ))
    test <- system_var %>%
        select(Platform, System, Global_Sales) %>%
        arrange(System)
    testing_data <- test %>%
        select(System,Global_Sales)
    xbox <- testing_data %>%
        filter(System == "Xbox")
    playstation <- testing_data %>%
        filter(System == "PlayStation")
    xbox.test <- xbox %>%
        select(Global_Sales)
    playstation.test <- playstation %>%
        select(Global_Sales)
    data_vartest <- var.test(Global_Sales ~ System, data = testing_data)
    data_ttest <- t.test(xbox.test, playstation.test, alternative = "two.sided", var.equal = FALSE)
    
    output$ttest <- renderPrint({
        data_ttest
    })

}
shinyApp(ui = ui, server = server)