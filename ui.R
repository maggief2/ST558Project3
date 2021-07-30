library(shiny)
library(plotly)

# Define UI for application that draws a histogram
shinyUI(
  navbarPage("Bike Modeling (Seoul)",
      tabPanel("About",
               #Picture related to data
               img(src='bicycle.png', height = "20%", width = "20%"),
               
               #Purpose of App
               h3("Purpose of the App"),
               h4("This app will allow the user to explore and model the Seoul bike sharing demand."),
               br(),
               
               #Discussion of data and its source
               h3("The Data"),
               h4("The data comes from the UCI machine learning repository and was labeled ",
               a("Seoul Bike Sharing Demand.", href = "https://archive.ics.uci.edu/ml/datasets/Seoul+Bike+Sharing+Demand"), " The variable of interest is the Rented Bike Count, because it is important that the bikes are available and accessible to the public at the right time to reduce waiting time. The remaining 13 varables in this dataset are: Date, Hour, Temperature, Humidity, Wind speed, Visibility, Dew Point Temperature, Solar Radiation, Rainfall, Snowfall, Seasons, Holiday, and Functioning Day."
               ),
               br(),
               
               #Purpose of each tab
               h3("Tabs"),
               h4("The Data page will allow the user to have an initial look at the data set, subset it, and save the full data set as a file."),
               h4("The Data Exploration page will allow the user to explore the data. The user can change and filter the variables; create numerical and graphical summaries; and download the plots."),
               h4("The Modeling page will fit three supervised learning models. There will be a multiple linear regression model, regression tree, and a random forest model. The three tabs within the page will give information about the modeling approaches, fit the model, and predict the response.")
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
                                   c("Five Number Summary", "Mean and Standard Deviation",
                                     "Correlation with Count"))
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
                 h3("Linear Regression Model"),
                 h4("explain benefits/drawbacks"),
                 
                 h3("Regression Tree"),
                 h4("explain benefits/drawbacks"),
                 
                 h3("Random Forest Model"),
                 h4("explain benefits/drawbacks")
                 ),
        
        tabPanel("Model Fitting",
                 h4("Step 1. Select the proportion of the data that will be randomly sampled for the training data set"),
                 sliderInput("split", "Select the Proportion",
                             min = 0.1, max = 0.9, value = 0.5, step = 0.01),
                 textOutput("sample"),
                 br(),
                 
                 h4("Step 2. Select variables for the models"),
                 checkboxGroupInput("mlr", "Multiple Linear Regression Variable(s):",
                                    c("Hour", "Temperature", "Humidity", "WindSpeed", 
                                      "Visibility", "DewPoint", "SolarRadiation", "Rainfall", 
                                      "Snowfall", "Seasons", "Holiday", "FunctioningDay"), 
                                    inline = TRUE),
                 checkboxGroupInput("tree", "Regression Tree Variable(s):",
                                    c("Hour", "Temperature", "Humidity", "WindSpeed", 
                                      "Visibility", "DewPoint", "SolarRadiation", "Rainfall", 
                                      "Snowfall", "Seasons", "Holiday", "FunctioningDay"), 
                                    inline = TRUE),
                 checkboxGroupInput("rf", "Random Forest Variable(s):",
                                    c("Hour", "Temperature", "Humidity", "WindSpeed", 
                                      "Visibility", "DewPoint", "SolarRadiation", "Rainfall", 
                                      "Snowfall", "Seasons", "Holiday", "FunctioningDay"), 
                                    inline = TRUE),
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
                   selectInput("season", "Season",
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
                 
                 #textOutput("prediction")
                 actionButton("predict", "Predict"),
                 verbatimTextOutput("prediction")
        )
      ))
))
