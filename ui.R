library(shiny)

# Define UI for application that draws a histogram
shinyUI(
  navbarPage("Bike Modeling (Seoul)",
      tabPanel("About",
               #Picture related to data
               img(src='bicycle.png', height = "20%", width = "20%"),
               
               #Purpose of App
               h3("Purpose of the App"),
               h4("This app will allow the user to explore and model the Seoul bike sharing demand."),
               
               #Discussion of data and its source
               h3("The Data"),
               h4("The data comes from the UCI machine learning repository and was labeled ",
               a("Seoul Bike Sharing Demand.", href = "https://archive.ics.uci.edu/ml/datasets/Seoul+Bike+Sharing+Demand"), " The variable of interest is the Rented Bike Count, because it is important that the bikes are available and accessible to the public at the right time to reduce waiting time. The remaining 13 varables in this dataset are: Date, Hour, Temperature, Humidity, Wind speed, Visibility, Dew Point Temperature, Solar Radiation, Rainfall, Snowfall, Seasons, Holiday, and Functioning Day."
               ),
               
               #Purpose of each tab
               h3("Tabs"),
               h4("The Data page will allow the user to have an initial look at the data set, subset it, and save the full data set as a file."),
               h4("The Data Exploration page will allow the user to explore the data. The user can change and filter the variables; create numerical and graphical summaries; and download the plots."),
               h4("The Modeling page will fit three supervised learning models. There will be a multiple linear regression model, regression tree, and a random forest model. The three tabs within the page will give information about the modeling approaches, fit the model, and predict the response.")
      ),
      
      tabPanel("Data", fluidPage(
        #Title
        titlePanel("Data"),
        
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
        #Application title
        titlePanel("Old Faithful Geyser Data"),
        
        #Sidebar with a slider input for number of bins
        sidebarLayout(
          sidebarPanel(
            sliderInput("bins", "Number of bins:", min = 1,max = 50, value = 30)
          ),
          #table
          mainPanel(plotOutput("distPlot"))
        )
      )),
      
      tabPanel("Modeling", tabsetPanel(
        tabPanel("Modeling Info"),
        
        tabPanel("Model Fitting"),
        
        tabPanel("Prediction")
      )
      )
    )
)
