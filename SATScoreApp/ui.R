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
    
    
    titlePanel("College Choices Based on SAT Scores"),
    sidebarLayout(
        sidebarPanel(
            sliderInput("sliderMATH", "What is Your Math SAT Score?", 400, 800, value = 500),
            sliderInput("sliderVERBAL", "What is Your Verbal SAT Score?", 400, 800, value = 500),
            sliderInput("sliderWRITING", "What is Your Writing SAT Score?", 400, 800, value = 500)
        ),
        
        mainPanel(tabsetPanel(type = "tabs",
            tabPanel("College Map", br(),
                textOutput("out1"),
                leafletOutput("plot1"),
                h4("Total Number of Universities with Scores Greater Than"),
                h4(textOutput("scores")),
                h3(textOutput("count1"))),
                
            tabPanel("Prediction", br(),
                plotOutput("plot2"),
                h4("Predicted Completion Rate from Model A"),
                h5("(Simple  Linear Regression on Math SAT)"),
                textOutput("predA"),
                h4("Predicted Completion Rate from Model B"),
                h5("(Simple Linear Regression on Writing SAT)"),
                textOutput("predB"),
                h4("Predicted Completion Rate from Model C"),
                h5("(Linear Regression on Math SAT and Writing SAT)"),
                textOutput("predC")),
          
            tabPanel("Help", br(), 
                includeHTML("./help.html"))
        ))
            
)))
