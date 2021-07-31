
library(caret)
library(DT)
library(plotly)
library(shiny)
library(tidyverse)

SeoulBike <- read_csv("SeoulBikeData.csv")
colnames(SeoulBike) <- c("Date", "Count", "Hour", "Temperature", "Humidity",
                         "WindSpeed", "Visibility", "DewPoint", "SolarRadiation", "Rainfall", 
                         "Snowfall", "Seasons", "Holiday", "FunctioningDay")
SeoulBike$Hour <- as.factor(SeoulBike$Hour)

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
    as.data.frame(tab) 
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
  
  output$plot <- renderPlotly({
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
  #Text 
  output$ex2 <- renderUI({
    withMathJax(
      helpText('Model $$ Y = \\beta_0+ \\beta_1 X_1 + ... + \\beta_p X_p$$')
    )
  })
  
  #Model Fitting - Training and Testing sets
  n <- reactive({round(nrow(SeoulBike)*input$split)})
  trainIndex <- reactive({sample(nrow(SeoulBike), n())})
  trainset <- reactive({SeoulBike[trainIndex(),]})
  testset <- reactive({SeoulBike[-trainIndex(),]})
  
  output$sample <- renderText({
    paste0("There are ", nrow(trainset()), " observations in the training set and ", nrow(testset()), " in the testing set.")
  })
  
  #Model Fitting - Model Fitting MLR
  mlr <- eventReactive(input$fit, {
    trainset() %>% select(Count, input$mlr)
  })
  
  #Multiple Linear Regression
  modmlr <- reactive({
    train(Count ~ .,
          data = mlr(),
          method = "lm",
          preProcess = c("center","scale"),
          trControl = trainControl(method = input$mlrcv, number = input$mlrfolds))
  })
  
  output$modmlrsum <- renderPrint({
    summary(modmlr())
  })
  
  output$modmlr <- renderText({
    #training MSE
    trainpred <- predict(modmlr(), newdata = trainset())
    trainmse <- postResample(trainpred, trainset()$Count)[[1]]
    #testing MSE
    testpred <- predict(modmlr(), newdata = testset())
    testmse <- postResample(testpred, obs = testset()$Count)[[1]]
    
    paste0("The training set RMSE is ", round(trainmse,2) , " and the testing set RMSE is ", round(testmse,2))
  })
  
  #Model Fitting - Model Fitting Reg Tree
  rtree <- eventReactive(input$fit, {
    trainset() %>% select(Count, input$tree)
  })
  
  #Regression Tree
  regTree <- reactive({
    train(Count ~ .,
          data = rtree(),
          method = "rpart",
          preProcess = c("center", "scale"),
          trControl = trainControl(method = input$treecv, input$treefolds))
  })
  
  output$modrtsum <- renderPrint({
    regTree()
  })  
  
  output$modrt <- renderText({
    #training RMSE
    trainpred <- predict(regTree(), testset())
    trainmse <- postResample(trainpred, trainset()$Count)[[1]]
    #testing RMSE
    testpred <- predict(regTree(), trainset())
    testmse <- postResample(testpred, testset()$Count)[[1]]
    
    paste0("The training set RMSE is ", round(trainmse,2) , " and the testing set RMSE is ", round(testmse,2))
  })
  
  #Model Fitting - Model Fitting Random Forest
  rforest <- eventReactive(input$fit, {
    trainset() %>% select(Count, input$rf)
  })
  
  #Random forest
  randForest <- reactive({
    train(Count ~ ., 
          data = rforest(),
          method = "rf",
          preProcess = c("center", "scale"),
          trControl = trainControl(method = input$rfcv, number = input$rffolds))
  })
  
  output$modrfsum <- renderPrint({
    randForest()
  })
  
  output$modrf <- renderText({
    #training MSE
    trainpred <- predict(randForest(), trainset())
    trainmse <- postResample(trainpred, trainset()$Count)[[1]]
    #testing MSE
    testpred <- predict(randForest(), testset())
    testmse <- postResample(testpred, testset()$Count)[[1]]
    
    paste0("The training set RMSE is ", round(trainmse,2) , " and the testing set RMSE is ", round(testmse,2))
  })
  
  #Modeling page - Prediction
  subdata <- eventReactive(input$predict, {
    trainset() %>% select(Count, input$predvars)
  })
  
  output$prediction <- renderPrint({
    df <- data.frame(Hour = input$hr, Temperature = input$temp, Humidity = input$humid,
                     WindSpeed = input$wind, Visibility = input$vis, DewPoint = input$dew, 
                     SolarRadiation = input$solar, Rainfall = input$rain, Snowfall = input$snow, 
                     Seasons = input$season4, Holiday = input$holiday, FunctioningDay = input$day)
    
    if (input$model == "Multiple Linear Regression"){
      modmethod <- "lm"
    } else {
      if (input$model == "Regression Tree"){
        modmethod <- "rpart"
      } else {
        modmethod = "rf"
      }
    }
    
    model <- train(Count ~ .,
                   data = subdata(),
                   method = modmethod,
                   preProcess = c("center", "scale"),
                   trControl = trainControl(method = "repeatedcv", number = 10))
    
    pred <- predict(model, df)
    paste0("The predicted value of Bike Count is ", round(pred))
  })
})
