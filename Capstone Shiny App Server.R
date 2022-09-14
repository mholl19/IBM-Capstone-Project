# Install and import required libraries
require(shiny)
require(ggplot2)
require(leaflet)
require(tidyverse)
require(httr)
require(scales)
# Import model_prediction R which contains methods to call OpenWeather API
# and make predictions
source("model_prediction.R")


test_weather_data_generation<-function(){
  #Test generate_city_weather_bike_data() function
  city_weather_bike_df<-generate_city_weather_bike_data()
  stopifnot(length(city_weather_bike_df)>0)
  print(head(city_weather_bike_df))
  return(city_weather_bike_df)
}

# Create a RShiny server
shinyServer(function(input, output){
  # Define a city list
  
  
  # Define color factor
  color_levels <- colorFactor(c("green", "yellow", "red"), 
                              levels = c("small", "medium", "large"))
  city_weather_bike_df <- test_weather_data_generation()
  
  # Create another data frame called `cities_max_bike` with each row contains city location info and max bike
  # prediction for the city
  cities_max_bike <- city_weather_bike_df %>%
    group_by(CITY_ASCII) %>%
    slice(which.max(BIKE_PREDICTION))
  
  # Observe drop-down event
  observeEvent(input$city_dropdown, {
    if(input$city_dropdown == 'All') {
      #Render the city overview map
      output$city_bike_map <- renderLeaflet({
        #complete this function to render a leaflet map
        leaflet(cities_max_bike) %>% 
          addTiles() %>%
          setMaxBounds(lng1 = -171.522125, lat1 = 84.700978, lng2 = 210.469585, lat2 = -51.869708) %>%
          addCircleMarkers(data = cities_max_bike, 
                           lng= cities_max_bike$LNG,
                           lat = cities_max_bike$LAT, 
                           popup = cities_max_bike$LABEL,
                           radius = ~ifelse(cities_max_bike$BIKE_PREDICTION_LEVEL == 'small', 6, 12),
                           color = ~color_levels(cities_max_bike$BIKE_PREDICTION_LEVEL))
      })
    }
    else {
      #Render the specific city map
      filteredcity <- cities_max_bike %>% 
        filter(CITY_ASCII == input$city_dropdown)
      output$city_bike_map <- renderLeaflet({
        leaflet(filteredcity) %>%
          addTiles() %>%
          addCircleMarkers(data = filteredcity,
                           lng = filteredcity$LNG,
                           lat = filteredcity$LAT,
                           popup = filteredcity$DETAILED_LABEL,
                           radius = ~ifelse(filteredcity$BIKE_PREDICTION_LEVEL == 'small', 6, 12),
                           color = ~color_levels(filteredcity$BIKE_PREDICTION_LEVEL))
          
      })
    } 
  })
})
