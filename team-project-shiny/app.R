library(tidyverse)
library(DT)
library(shinyjs)
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
                                  h2("Welcome to our Shiny Application"),
                                  p("Within this application you will find 6 tabs using a dataset found on Kaggle containing sales information on video games 
                                  going back to 1980. The variables in this dataset are as follows:"),
                                  br(),
                                  p("- Name : Name of the video game"),
                                  p("- Platform : Platform the game was released on"),
                                  p("- Year_of_Release : Year the game was released"),
                                  p("- Genre : Genre of the video game"),
                                  p("- Publisher : Publisher of the video game"),
                                  p("- NA_Sales : North American Sales (Millions USD)"),
                                  p("- EU_Sales : European Sales (Millions USD)"),
                                  p("- JP_Sales : Sales in Japan (Millions USD)"),
                                  p("- Other_Sales : Sales in other countries (Millions USD)"),
                                  p("- Global_Sales : Global Sales (USD)"),
                                  p("- Critic_Score : Average critic score out of 100"),
                                  p("- Critic_Count : Number of critic reviews"),
                                  p("- User_Score : Average user score out of 10"),
                                  p("- User_Count : Number of user reviews"),
                                  p("- Developer : Developer of the video game"),
                                  p("- Rating : The video games censorship rating"),
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
                                  br(),
                                  h4("Assumptions"),
                                  p("Due to our dataset containing the sales data for all games released on Xbox and Playstation our sample is practically the"),
                                  p("populations of Xbox and Playstation games. Our test will continue as planned."),
                                  br(),
                                  h4("The T-test"),
                                  verbatimTextOutput("ttest"),
                                  br(),
                                  h4("Conclusion"),
                                  p("A p-value of 0.03956 indicates there is strong evidence to reject the null hypothesis."),
                                  p("There is a difference in true mean global sales of games released on Xbox and Playstation consoles. Based on the sample"),
                                  p("means, Xbox has had higher mean global sales compared to Playstation for games which have been released on both consoles.")
                         ),
                         
                         #T Test Distributions
                         tabPanel("T-Test Distributions",
                                  plotOutput(outputId = "bothplot"),
                                  plotOutput(outputId = "xboxplot"),
                                  plotOutput(outputId = "playplot")
                        ), #Closing T Test Distributions
                        
                        #Regression Tab
                        tabPanel("Regression",
                                 h3("Creating a Regression Model to Predict Global Sales"),
                                 h4("Analysis plan"),
                                 p("To accomplish our goal, first we decided to trim `Publisher` and `Genre` down to the top five in each category. 
                                   We did this because of the large number of Publishers and Genres.
                                 We also trimmed `Rating` down to be either E, E10+, M or T for the same reasoning. 
                                   The possible values for each variable are listed below:"),
                                 p("- `Publisher` : Electronic Arts, Activision, Namco Bandai Games, Ubisoft, Konami Digital Entertainment"),
                                 p("- `Genre` : Sports, Action, Misc, Shooter, Simulation"),
                                 p("- `Rating` : E, E10+, M, T"),
                                 br(),
                                 h4("Model Selection"),
                                 p("We decided to use backwards model selection for our analysis. In other words, we started with all four 
                                    explanatory variables in our model, and removed insignificant variables at the `alpha = 0.05` level. 
                                    `Year of Release` was the only variable found to be insignificant with a p-value of `0.3079`. 
                                    The other variables had at least one category with a significant p-value and were kept in the model. The log of Global sales
                                   was used because of the values of some of the game sales."),
                                 br(),
                                 h4("Final Model"),
                                 p("Our final model and corresponding output are listed below. Reference categories are Activision for `Publisher`,
                                   Action for `Genre`, and E for `Rating`."),
                                 br(),
                                 verbatimTextOutput("regress"),
                                 br(),
                                 h4("Conclusion"),
                                 p("While our variables in our model were significant, an adjusted r-squared value of `0.09161` is not good. 
                                   This tells us our model only explains `9.16%` of the variation in `Global Sales`. 
                                   While this is not surprising considering there are many potential factors which affect `Global Sales`; 
                                   our model cannot reliably predict `Global Sales`.")
                                 
                        )#Close Regression Tab
                         
#Closing shinyUI
))


server <- function(input, output) {
    
    #SEARCH TABLE SECTION
    videogames <- video_game_sales %>% 
        dplyr::select(Name, Year_of_Release, Platform, Publisher, Global_Sales)
    
    #Creating the search table
    output$table <- renderDataTable({
        videogames <- DT::datatable(rownames = FALSE, videogames,
                                    options = list(columnDefs = list(list(width = '150px'))))
        videogames
    })
    
    #INTERACTIVE PLOTS SECTION
    
    #Create a new dataset containing all the variables we want.
    cleangames <- video_game_sales %>% 
        na.omit()
    
    output$gameplot <- renderPlot({
        
        # Render a scatterplot
        ggplot(cleangames, mapping = aes(x = !!as.name(input$xvariable), y = !!as.name(input$yvariable))) +
            geom_jitter()
    })
    
    #TIME PLOTS SECTION
    
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
    
    #T-TEST SECTION
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
    
    
    #Render Both System Boxplot
    output$bothplot <- renderPlot({
        boxplot(log(Global_Sales) ~ System, data = testing_data, ylab = "Log of Global Sales", main = "Boxplot of Global Sales By System")
    })
    
    #Render PLaystation Histogram
    output$playplot <- renderPlot({
        hist(log(playstation$Global_Sales), xlab = "Log of Global Sales", main = "Histogram of Playstation Global Sales")
    })
    
    #Render Xbox Histogram
    output$xboxplot <- renderPlot({
        hist(log(xbox$Global_Sales), xlab = "Log of Global Sales", main = "Histogram of Xbox Global Sales")
    })
    
    #REGRESSION SECTION
    regressiondata <- video_game_sales %>% 
        filter(Genre %in% c("Sports", "Action", "Misc", "Shooter", "Simulation") & 
                   Publisher %in% c("Electronic Arts", 
                                    "Activision", 
                                    "Namco Bandai Games",
                                    "Ubisoft",
                                    "Konami Digital Entertainment") &
                   Rating %in% c("E", "E10+", "M", "T")) %>% 
        mutate(Year_of_Release = as.numeric(Year_of_Release)) %>% 
        select(Genre, Publisher, Global_Sales, Rating, Year_of_Release)
    
    #Render output for Regression
    output$regress <- renderPrint({
        Model <- lm(log(Global_Sales) ~ Genre + Publisher + Rating, data = regressiondata)
        
        Model %>% 
            summary()

    })

}
shinyApp(ui = ui, server = server)