# Seoul Bike Demand App

## Purpose

The purpose of this app is to allow users to explore the [Seoul Bike Sharing Demand Data Set]( https://archive.ics.uci.edu/ml/datasets/Seoul+Bike+Sharing+Demand). The user will have the ability to download the data set or a subset of the data; create and download the plots; and create predictive models and predict the demand.  

## Packages

The packages needed to run the R code are: 

+ caret
+ DT
+ plotly
+ shiny
+ shinybusy
+ tidyverse

### A Quick way to load all the packages

```{r}
invisible(lapply(c("caret", "DT", "plotly", "shiny", "shinybusy", "tidyverse"), library, character.only = TRUE))
```

## Run the App

Below is the code that can be copy and pasted into RStudio to run the app.

```{r}
shiny::runGitHub("ST558Project3", username = "maggief2", ref = "main")
```
