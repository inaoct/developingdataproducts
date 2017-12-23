#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

if(!require(shiny)) install.packages("shiny", repos = "http://cran.us.r-project.org")
library(shiny)

if(!require(leaflet)) install.packages("leaflet", repos = "http://cran.us.r-project.org")
library(leaflet)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
    
    
    titlePanel("Predict Horsepower from MPG"),
    sidebarLayout(
        sidebarPanel(
            sliderInput("sliderMATH", "What is Your Math SAT Score?", 400, 800, value = 500),
            sliderInput("sliderVERBAL", "What is Your Verbal SAT Score?", 400, 800, value = 500),
            sliderInput("sliderWRITING", "What is Your Writing SAT Score?", 400, 800, value = 500)
        ),
        
        mainPanel(
            leafletOutput("plot1"),
            h3(textOutput("scores")),
            h4(textOutput("count1"))
        )
    )
))
