videogames <- read.csv(file = 'data/Video_Games_Sales_as_at_22_Dec_2016.csv')

tabledata <- videogames %>% 
  dplyr::select(Name, Platform, Year_of_Release, Global_Sales)

tabledata

