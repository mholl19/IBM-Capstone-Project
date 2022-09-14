# Load required libraries
require(leaflet)


# Create a RShiny UI
shinyUI(
  fluidPage(padding=5,
            titlePanel("Bike-sharing demand prediction app"), 
            # Create a side-bar layout
            sidebarLayout(
              # Create a main panel to show cities on a leaflet map
              mainPanel(
                leafletOutput('city_bike_map', height = 600, width = 800)
            
              ),
              # Create a side bar to show detailed plots for a city
              sidebarPanel(
                selectInput(inputId = "city_dropdown", "Select City: ",
                            c("All", "Seoul", "Suzhou", "London", "New York", "Paris"))
                # select drop down list to select city
              ))
  ))
