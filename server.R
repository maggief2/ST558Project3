library(tidyverse)
library(DT)
SeoulBike <- read_csv("SeoulBikeData.csv")
colnames(SeoulBike) <- c("Date", "Count", "Hour", "Temperature", "Humidity",
                         "WindSpeed", "Visibility", "DewPoint", "SolarRadiation", "Rainfall", 
                         "Snowfall", "Seasons", "Holiday", "FunctioningDay")
SeoulBike$Hour <- as.factor(SeoulBike$Hour)
library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
  
  df <- reactive({
    #filter rows
    var <- input$season
    if (var == "All"){
      data <- as.data.frame(SeoulBike)
    } else {
      BikeSub <- SeoulBike[SeoulBike$Seasons == var,]
      data <- as.data.frame(BikeSub)
    }
    
    #filter columns
    col <- input$col
    if (col == "Both"){
      tab <- data 
    } else {
      if (col == "Weather"){
        tab <- data %>% select("Count", "Temperature", "Humidity", "WindSpeed", "Visibility", 
                               "DewPoint", "SolarRadiation", "Rainfall", "Snowfall")
      } else {
        tab <- data %>% select("Count", "Date", "Hour", "Seasons", "Holiday", "FunctioningDay")
      }
    }
    sub <- as.data.frame(tab) 
  })
  
  #Data page - table
  output$table <- renderTable({
    df()
  })
  
  #Data page - download button
  output$downloadData <- downloadHandler(
    filename = function() {
      paste0("data", input$season, input$col, ".csv")
    },
    content = function(file) {
      write.csv(df(), file)
    }
  )
  
  #Data Exploration page - Plot
  graph <- reactive({
    #For qualitative data
    if (input$qualquant == "Qualitative"){
      #subset data
      new <- SeoulBike[, c("Count", input$qual)]
      g <- ggplot(new, aes(x = .data[[input$qual]]))
      #Bar graph
      if (input$qualplot == "Bar graph"){
        g + geom_bar()
      } else {
        #Box plot
        g + geom_boxplot(aes(y = Count))
      }
      #For quantitative
    } else {
      new <- SeoulBike %>% select(Count, input$quant)
      g <- ggplot(new, aes(x = .data[[input$quant]]))
      if (input$quantplot == "Histogram"){
        g + geom_histogram(bins = 30)
      } else {
        g + geom_point(aes(y = Count))
      }
    }
  })
  
  output$plot <- renderPlot({
    graph()
  })
  
  #Data Exploration - Download plot
  output$downloadPlot <- downloadHandler(
    filename = function() { 
      paste(input$qual, input$qualplot, input$quant, input$quantplot, '.png') 
      },
    content = function(file) {
      ggsave(file, graph())
    }
  )
  
  #Data Exploration page - summary table
  output$sum <- renderTable({
    #For qualitative data
    if (input$qualquant == "Qualitative"){
      val <- SeoulBike[,input$qual]
      tab <- as.data.frame(table(val))
      colnames(tab) <- c(input$qual, "Frequency")
      tab
      #For quantitative data
    } else {
      val <- SeoulBike[,input$quant]
      if (input$quantsum == "Five Number Summary"){
        summary(val)[-4]
      } else {
        val <- SeoulBike[[input$quant]]
        if (input$quantsum == "Mean and Standard Deviation"){
          tab <- data.frame(round(mean(val), 4), round(sd(val), 4))
          colnames(tab) <- c("Mean", "Standard Deviation")
          tab
        } else {
          data.frame("Correlation" = cor(val, SeoulBike$Count))
        }
      }
    }
  })
  
  #Modeling page 
  #Model Fitting
  n <- reactive({round(nrow(SeoulBike)*input$split)})
  trainIndex <- reactive({sample(nrow(SeoulBike), n())})
  train <- reactive({SeoulBike[trainIndex(),]})
  test <- reactive({SeoulBike[-trainIndex(),]})
  
  output$sample <- renderText({
    
    #h4("There are ", nrow(train()), " observations in the training set and ", nrow(test()), " in the testing set.")
  })
  
})
