---
title: "Final Report"
author: "S01-Blue"
output: 
  html_document:
      keep_md: yes
      toc: true
---



\\newpage
## Introduction

#### Our Dataset

For our final project we decided to work with a dataset found on [Kaggle](https://www.kaggle.com/). This dataset is a list of all video game sales as of December 22, 2016. Our dataset contained the following variables:

- Name : Name of the video game
- Platform : Platform the game was released on
- Year_of_Release : Year the game was released
- Genre : Genre of the video game
- Publisher : Publisher of the video game
- NA_Sales : North American Sales (Millions USD)
- EU_Sales : European Sales (Millions USD)
- JP_Sales : Sales in Japan (Millions USD)
- Other_Sales : Sales in other countries (Millions USD)
- Global_Sales : Global Sales (USD)
- Critic_Score : Average critic score out of 100
- Critic_Count : Number of critic reviews
- User_Score : Average user score out of 10
- User_Count : Number of user reviews
- Developer : Developer of the video game
- Rating : The video games censorship rating

#### General Research Questions and Ideas

Using an exploratory data analysis for [application 05](https://github.com/sta518/application05-s01-blue) we developed some ideas and questions on how we would like to analyze this dataset. The ideas were as follows:

1. Could we create a regression to predict global sales using this dataset?
2. Create an RShiny application containing a table with this dataset where you can search the global sales for any video game in the dataset.
3. Create visualizations to show the average global sales by month of release and average global sales by year of release. Are there any trends or abnormalties?

\\pagebreak

## Data Analysis Plan

#### Regression Analysis

For our regression analysis we decided to include five variables from the dataset. Our response variable is `Global_Sales`. The explanatory variables are `Genre` , `Publisher` , `Rating`, and `Year_of_Release`. Due to the large number of publishers and genres we decided to take the top 5 responses from each variable. Similar to publishers and genres, we only took the top four ratings. The reason for this was to ensure we had a manageable number of coefficients for each of these categories in our final model. Our model building philosophy will be backwards selection and we will keep any variables with at least one significant coefficient.

#### Shiny Application

What we plan to include in our shiny app is:

- Multiple tabs with different sections including each group members contributions
- Tab one will contain multiple selections to bring up sections of this report
- Tab two will have the search table for historical video game sales
- Tab three will have interactive plots
- Tab four will have our regression results
- Tab five will have the visualizations of average global sales by year and by month

#### Visualizations

Each visualization will be a bar chart of average global sales by either year of release or by month of release.



















