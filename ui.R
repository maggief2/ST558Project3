
library(plotly)
library(shiny)
library(shinybusy)

# Define UI for application that draws a histogram
shinyUI(
  navbarPage("Bike Modeling (Seoul)",
      tabPanel("About",
               #Picture related to data
               img(src='bicycle.png', height = "20%", width = "20%"),
               
               #Purpose of App
               h3("Purpose of the App"),
               h4("This is an interactive app that allows the user to explore, model, and predict the Seoul bike sharing demand."),
               br(),
               
               #Discussion of data and its source
               h3("The Data"),
               h4("The data comes from the UCI machine learning repository and was labeled ",
               a("Seoul Bike Sharing Demand.", href = "https://archive.ics.uci.edu/ml/datasets/Seoul+Bike+Sharing+Demand"), " The response variable of interest is the Rented Bike Count. This is because it is important for the company to know the availability of bikes so the public can access them without waiting. The remaining 13 varables in this dataset fall into two categories that I have dubbed: Time or Weather. For the time variables there is the Date, Hour, Seasons, Holiday, and Functioning Day. The weather variables include the Temperature (Celsius), Humidity (%), Wind speed (m/s), Visibility (10m), Dew Point Temperature (Celsius), Solar Radiation (MJ/m2), Rainfall (mm), and Snowfall (cm)."
               ),
               br(),
               
               #Purpose of each tab
               h3("Tabs"),
               h4("The Data page will allow the user to have an initial look at the data set, subset it, and save the data set as a file."),
               h4("The Data Exploration page will allow the user to visualize the data and view summary statistics. The user can change and filter the variables; create numerical and graphical summaries; and download the plots. The graphs created are also downloadable, however by doing so they will lose their interactive abilities."),
               h4("The Modeling page will fit three supervised learning models: multiple linear regression, regression tree, and random forest. The first of the three tabs, labeled Modeling Info, provides information about the three models. The second tab, labeled Model Fitting, allows the user to fit the model using variables of their choice. The third tab, labeled Prediction, allows the user to select one of the three models; select predictor variables and input values for each variable; and predict the response.")
      ),
      
      tabPanel("Data", fluidPage(
        #filter rows by season
        selectInput("season", "Select a season or all seasons", 
                    list("All", "Winter", "Spring", "Summer", "Autumn")),
        
        #select columns by category 
        selectInput("col", "Select all columns or by category",
                    list("Both", "Weather", "Time")),
        
        #Download 
        downloadButton("downloadData", "Download"),
        
        #Table outputted
        tableOutput("table")
      )),
      
      tabPanel("Data Exploration", fluidPage(
                 #Sidebar with a slider input for number of bins
                 sidebarLayout(
                   sidebarPanel(
                     h3("Select the variable of interest"),
                     
                     radioButtons("qualquant", h4("What kind of variable?"), 
                                  c("Qualitative", "Quantitative")),
                     
                     conditionalPanel(
                       condition = "input.qualquant == 'Qualitative'",
                       selectInput("qual", "Variable", 
                                   list("Hour", "Seasons", "Holiday", "FunctioningDay")),
                       selectInput("qualplot", "Type of Plot", c("Bar graph", "Box plot")),
                       selectInput("qualsum", "Type of Summary", c("Frequency"))
                     ),

                     conditionalPanel(
                       condition = "input.qualquant == 'Quantitative'",
                       selectInput("quant", "Variable", 
                                   list("Temperature", "Humidity", "WindSpeed", "Visibility", 
                                        "DewPoint", "SolarRadiation", "Rainfall", "Snowfall")),
                       selectInput("quantplot", "Type of Plot", c("Histogram", "Scatterplot")),
                       selectInput("quantsum", "Type of Summary", 
                                   c("Mean and Standard Deviation", "Correlation with Count", 
                                     "Five Number Summary"))
                     ),
                     
                     #Download Plot
                     downloadButton('downloadPlot', 'Download Plot')
                   ),
                   # Show outputs
                   mainPanel(
                     #plotOutput("plot"),
                     plotlyOutput("plot"),
                     tableOutput("sum")
                   )
                 )
                 )),
      
      tabPanel("Modeling", tabsetPanel(
        tabPanel("Modeling Info",
                 h3("Multiple Linear Regression"),
                 uiOutput('ex2'),
                 h4("The multiple linear regression model estimates the relationship between several predictor variables and one response variable. This model is relatively easy to interpret. The intercept, ",  HTML(paste0("&beta;",tags$sub("0"))), ", is interpreted as the response when all predictors are zero. The remaining", HTML(paste0("&beta;",tags$sub("i"))), "s is the estimated increase in the predictor variable given all other predictor variables are held constant.  The output from this model also allows us to see the relevance or importance of since we also obtain the standard error, t value, and p-values. The downside of this model would be the assumption of linearity, which makes it worse for data that is truly complex."),
                 
                 h3("Regression Tree"),
                 h4("The regression tree builds a model in a tree-like structure. The full dataset splits into two branches based on a certain criterion of a predictor variable in the data. The following branches then split, if the stop criteria are not met, and this process continues until a tree is formed. The endpoints predict the value of the response variable, using the decision tree that was created. This form of modeling is conceptually easy to understand and easy to visualize. It can handle non-linear models well because it automatically handles interactions. However, small changes in the data, or in our case the training data set, can cause large changes in the structure of the decision tree. This is because the model generally overfits to the training set, making the variance large, so it may not perform well on the testing data."),
                 
                 h3("Random Forest Model"),
                 h4("The random forest model is similar in concept to the regression trees, where the data would split into multiple branches. However random forest models reduce the overfitting issue that is seen in regression trees. It does so by using a random sample of predictors variables from the sample and building the tree. Then the process repeatedly many times using bootstrap samples of the data. Then we predict the values using the outputted trees by averaging the outcome from each tree. However, this process takes a longer time because of the tree generating process and it is less interpretable because the outcome is the average of the trees that were made. ")
                 ),
        
        tabPanel("Model Fitting",
                 h4("Step 1. Select the proportion of the data that will be randomly sampled for the training data set"),
                 sliderInput("split", "Select the Proportion",
                             min = 0.1, max = 0.9, value = 0.5, step = 0.01),
                 textOutput("sample"),
                 br(),
                 
                 h4("Step 2. Select settings and variables for the models"),
                 #MLR
                 h5(strong("Multiple Linear Regression:")),
                 checkboxGroupInput("mlr", "Variable(s)",
                                    c("Hour", "Temperature", "Humidity", "WindSpeed", 
                                      "Visibility", "DewPoint", "SolarRadiation", "Rainfall", 
                                      "Snowfall", "Seasons", "Holiday", "FunctioningDay"), 
                                    inline = TRUE),
                 radioButtons("mlrcv", "Method", c("repeatedcv", "cv"), inline = TRUE),
                 sliderInput("mlrfolds", "Number of folds", min = 5, max = 10, value = 5, step = 1),
                 
                 #Regress Tree
                 h5(strong("Regression Tree:")),
                 checkboxGroupInput("tree", "Variable(s)",
                                    c("Hour", "Temperature", "Humidity", "WindSpeed", 
                                      "Visibility", "DewPoint", "SolarRadiation", "Rainfall", 
                                      "Snowfall", "Seasons", "Holiday", "FunctioningDay"), 
                                    inline = TRUE),
                 radioButtons("treecv", "Method", c("repeatedcv", "cv"), inline = TRUE),
                 sliderInput("treefolds", "Number of folds", min = 5, max = 10, value = 5, step = 1),
                 
                 #Rand Forest
                 h5(strong("Random Forest:")),
                 checkboxGroupInput("rf", "Variable(s)",
                                    c("Hour", "Temperature", "Humidity", "WindSpeed", 
                                      "Visibility", "DewPoint", "SolarRadiation", "Rainfall", 
                                      "Snowfall", "Seasons", "Holiday", "FunctioningDay"), 
                                    inline = TRUE),
                 radioButtons("rfcv", "Method", c("repeatedcv", "cv"), inline = TRUE),
                 sliderInput("rffolds", "Number of folds", min = 5, max = 10, value = 5, step = 1),
                 br(),
                 
                 h4("Step 3. Fit the models and compare"),
                 actionButton("fit", "Press to fit the three models"),
                 
                 h5(strong("Multiple Linear Regression:")),
                 verbatimTextOutput("modmlrsum"),
                 textOutput("modmlr"),
                 
                 h5(strong("Regression Tree:")),
                 verbatimTextOutput("modrtsum"),
                 textOutput("modrt"),
                 
                 h5(strong("Random Forest:")),
                 verbatimTextOutput("modrfsum"),
                 textOutput("modrf")
                 ),
        
        tabPanel("Prediction",
                 radioButtons("model", h4("Model selection"),
                              c("Multiple Linear Regression", "Regression Tree", "Random Forest"),
                              inline = TRUE),
                 checkboxGroupInput("predvars", "Select Variable(s):",
                                    c("Hour", "Temperature", "Humidity", "WindSpeed", 
                                      "Visibility", "DewPoint", "SolarRadiation", "Rainfall", 
                                      "Snowfall", "Seasons", "Holiday", "FunctioningDay"), 
                                    inline = TRUE),
                 conditionalPanel(
                   condition = "input.predvars.includes('Hour')",
                   selectInput("hr", "Hour",
                               c("0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", 
                                 "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23"))
                 ),
                 conditionalPanel(
                   condition = "input.predvars.includes('Temperature')",
                   numericInput("temp", "Temperature (Celsius)", 
                               min = -17.8, max = 39.4, value = 0, step = 0.1)
                 ),
                 conditionalPanel(
                   condition = "input.predvars.includes('Humidity')",
                   numericInput("humid", "Humidity (%)", 
                                min = 0, max = 98, value = 0, step = 1)
                 ),
                 conditionalPanel(
                   condition = "input.predvars.includes('WindSpeed')",
                   numericInput("wind", "Wind Speed (m/s)", 
                                min = 0, max = 7.4, value = 0, step = 0.1)
                 ),
                 conditionalPanel(
                   condition = "input.predvars.includes('Visibility')",
                   sliderInput("vis", "Visibility (10m)", 
                                min = 27, max = 2000, value = 2000, step = 1)
                 ),
                 conditionalPanel(
                   condition = "input.predvars.includes('DewPoint')",
                   numericInput("dew", "Dew point temperature (Celsius)", 
                               min = -30.6, max = 27.2, value = 0, step = 0.1)
                 ),
                 conditionalPanel(
                   condition = "input.predvars.includes('SolarRadiation')",
                   numericInput("solar", "Solar Radiation (MJ/m2)", 
                                min = -30.6, max = 27.2, value = 0, step = 0.1)
                 ),
                 conditionalPanel(
                   condition = "input.predvars.includes('Rainfall')",
                   numericInput("rain", "Rainfall (mm)", 
                                min = 0, max = 35, value = 0, step = 0.1)
                 ),
                 conditionalPanel(
                   condition = "input.predvars.includes('Snowfall')",
                   numericInput("snow", "Snowfall (cm)", 
                                min = 0, max = 8.8, value = 0, step = 0.1)
                 ),
                 conditionalPanel(
                   condition = "input.predvars.includes('Seasons')",
                   selectInput("season4", "Season",
                               c("Winter", "Spring", "Summer", "Autumn"))
                 ),
                 conditionalPanel(
                   condition = "input.predvars.includes('Holiday')",
                   selectInput("holiday", "Holiday",
                               c("Holiday", "No Holiday"))
                 ),
                 conditionalPanel(
                   condition = "input.predvars.includes('FunctioningDay')",
                   selectInput("day", "Functioning Day",
                               c("Yes", "No"))
                 ),
                 
                 actionButton("predict", "Predict"),
                 textOutput("prediction")
        )
      ))
))
