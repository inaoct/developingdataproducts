#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#


if(!require(shiny)) install.packages("shiny", repos = "http://cran.us.r-project.org")
library(shiny)
#library(shiny)

## Handle library pre-requisites
# Using dplyr for its more intuitive data frame processing
if(!require(dplyr)) install.packages("dplyr", repos = "http://cran.us.r-project.org")
library(dplyr)
# Using ggmap for geo location coordinates
if(!require(ggmap)) install.packages("ggmap", repos = "http://cran.us.r-project.org")
library(ggmap)
# Using leaflet for map-based visualizations
if(!require(leaflet)) install.packages("leaflet", repos = "http://cran.us.r-project.org")
library(leaflet)

collegeData <- read.table(
    "~/developingdataproducts/FirstShinyApp/collegeData400.csv",
    sep = ",", header = TRUE, comment.char = "", quote = "\"")

collegeMapData <-
    dplyr::select(collegeData, INSTNM, CITY, STABBR, INSTURL, SATMTMID,
        SATVRMID, SATWRMID, lat, lng) %>%
    dplyr::mutate(UnivName = as.character(INSTNM),
        City = as.character(CITY),
        State = as.character(STABBR),
        SiteURL = as.character(INSTURL),
        # using suppressWarnings to avoid NA coersion message appearing in the 
        # final html doc
        MedianMathSAT = suppressWarnings(as.numeric(as.character(SATMTMID))),
        MedianVerbalSAT = suppressWarnings(as.numeric(as.character(SATVRMID))),
        MedianWritingSAT = suppressWarnings(as.numeric(as.character(SATWRMID)))
    )


# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    
    univCount <- reactive({
        mathScoreInput <- input$sliderMATH
        verbalScoreInput <- input$sliderVERBAL
        writingScoreInput <- input$sliderWRITING
        filteredData <- dplyr::filter(collegeMapData, 
            MedianMathSAT > mathScoreInput &
                MedianVerbalSAT > verbalScoreInput &
                MedianWritingSAT > writingScoreInput)
        nrow(filteredData)
    })
    
    output$plot1 <- renderLeaflet({
        
        
        
        filteredSATData <- dplyr::filter(collegeMapData, MedianMathSAT > input$sliderMATH &
                MedianVerbalSAT > input$sliderVERBAL &
                MedianWritingSAT > input$sliderWRITING)
        
        ##   highSATCollegeData <-
        ##        dplyr::mutate(filteredSATData, lat = filteredSATData$lat, lng = filteredSATData$lng)
        # univSATScore <- as.character(highSATCollegeData$MedianMathSAT)
        univLink <- paste("<a href=","'", "http://",
            filteredSATData$SiteURL, "'",
            " target='_blank'", #open link in a new tab
            ">",
            filteredSATData$UnivName,
            "</a>",
            "<br>",
            "Median Math SAT: ", 
            filteredSATData$MedianMathSAT, 
            "<br>",
            "Median Verbal SAT: ", 
            filteredSATData$MedianVerbalSAT,
            "<br>",
            "Median Writing SAT: ", 
            filteredSATData$MedianWritingSAT,sep=""
        )
        
        collegeCoordinates <- dplyr::select(filteredSATData, lat, lng)
        
        my_map <- collegeCoordinates %>%
            leaflet() %>%
            addTiles() %>%
            addMarkers(
                clusterOptions = markerClusterOptions(weight = 1),
                popup = univLink) 
        
    })
    
    
    output$scores <- renderText({
        paste("Number of Universities with Median SAT Scores Higher Than: ", 
            "Math: ", input$sliderMATH, 
            "Verbal: ", input$sliderVERBAL, 
            "Writing: ", input$sliderWRITING)
    })
    
    output$count1 <- renderText({
        univCount()
    })
    
})
