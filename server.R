library(tidyverse)
library(DT)
SeoulBike <- read_csv("SeoulBikeData.csv")
colnames(SeoulBike) <- c("Date", "Count", "Hour", "Temperature", "Humidity",
                         "WindSpeed", "Visibility", "DewPoint", "SolarRadiation", "Rainfall", 
                         "Snowfall", "Seasons", "Holiday", "FunctioningDay")

library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
  
  #Data page - table
  output$table <- renderTable({
    #filter rows
    var <- input$season
    if (input$var == "All"){
      data <- as.data.frame(SeoulBike)
    } else {
      BikeSub <- SeoulBike[SeoulBike$Seasons == input$var,]
      data <- as.data.frame(BikeSub)
    }
    
    #filter columns
    col <- input$col
    if (input$col == "Both"){
      tab <- data 
    } else {
      if (input$col == "Weather"){
        tab <- data %>% select("Count", "Temperature", "Humidity", "WindSpeed", "Visibility", 
                               "DewPoint", "SolarRadiation", "Rainfall", "Snowfall")
      } else {
        tab <- data %>% select("Count", "Date", "Hour", "Seasons", "Holiday", "FunctioningDay")
      }
    }
    as.data.frame(tab)
  })
  
  #Data page - download button
  output$downloadData <- downloadHandler(
    filename = function() {
      paste0("data.csv")
    },
    content = function(file) {
      write.csv(SeoulBike, file)
    }
  )
  
  #Data Exploration page 
  output$distPlot <- renderPlot({
    # generate bins based on input$bins from ui.R
    x    <- faithful[, 2] 
    bins <- seq(min(x), max(x), length.out = input$bins + 1)
    
    # draw the histogram with the specified number of bins
    hist(x, breaks = bins, col = 'darkgray', border = 'white')
  })
})
