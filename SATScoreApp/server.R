#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#


## Handle library pre-requisites
if(!require(shiny)) install.packages("shiny", repos = "http://cran.us.r-project.org")
library(shiny)
# Using dplyr for its more intuitive data frame processing
if(!require(dplyr)) install.packages("dplyr", repos = "http://cran.us.r-project.org")
library(dplyr)
# Using ggmap for geo location coordinates
if(!require(ggmap)) install.packages("ggmap", repos = "http://cran.us.r-project.org")
library(ggmap)
# Using leaflet for map-based visualizations
if(!require(leaflet)) install.packages("leaflet", repos = "http://cran.us.r-project.org")
library(leaflet)

# Using scales for percentage formatting
if(!require(scales)) install.packages("scales", repos = "http://cran.us.r-project.org")
library(scales)

collegeData <- read.table(
    "./collegeData400.csv",
    sep = ",", header = TRUE, comment.char = "", quote = "\"")

collegeMapData <-
    dplyr::select(collegeData, INSTNM, CITY, STABBR, INSTURL, SATMTMID,
        SATVRMID, SATWRMID, C150_4_POOLED_SUPP, lat, lng) %>%
    dplyr::mutate(UnivName = as.character(INSTNM),
        City = as.character(CITY),
        State = as.character(STABBR),
        SiteURL = as.character(INSTURL),
        # using suppressWarnings to avoid NA coersion message appearing in the 
        # final html doc
        MedianMathSAT = suppressWarnings(as.numeric(as.character(SATMTMID))),
        MedianVerbalSAT = suppressWarnings(as.numeric(as.character(SATVRMID))),
        MedianWritingSAT = suppressWarnings(as.numeric(as.character(SATWRMID))),
        CompletionRate = suppressWarnings(as.numeric(as.character(C150_4_POOLED_SUPP)))
    )

lm.fitA <- lm(CompletionRate ~ MedianMathSAT, data = collegeMapData)

lm.fitB <- lm(CompletionRate ~ MedianWritingSAT, data = collegeMapData)

lm.fitC <- lm(CompletionRate ~ MedianMathSAT + 
        MedianWritingSAT, data = collegeMapData)

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
    
    modelPredA <- reactive({
        mathScoreInput <- input$sliderMATH
        predict(lm.fitA, newdata = data.frame(MedianMathSAT = mathScoreInput))
    })
    
    modelPredB <- reactive({
        writingScoreInput <- input$sliderWRITING
        predict(lm.fitB, newdata = data.frame(MedianWritingSAT = writingScoreInput))
    })
    
    modelPredC <- reactive({
        mathScoreInput <- input$sliderMATH
        writingScoreInput <- input$sliderWRITING
        predict(lm.fitC, newdata = data.frame(MedianMathSAT = mathScoreInput,
            MedianWritingSAT = writingScoreInput))
    })
    
   
    
    output$plot1 <- renderLeaflet({
        filteredSATData <- dplyr::filter(collegeMapData, MedianMathSAT > input$sliderMATH &
                MedianVerbalSAT > input$sliderVERBAL &
                MedianWritingSAT > input$sliderWRITING)
        
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
    
    output$plot2 <- renderPlot({
        mathScoreInput <- input$sliderMATH
        writingScoreInput <- input$sliderWRITING
        par(mfrow=c(1,2))
        
        # model A vs model C
        plot(collegeMapData$MedianMathSAT, collegeMapData$CompletionRate,
            xlab = "Median Math SAT Score", ylab = "Completion Rate")
        abline(lm.fitA, col = "red", lwd = 2)
        abline(a = coef(lm.fitC)[1] + coef(lm.fitC)[3]*writingScoreInput, 
            b = coef(lm.fitC)[2], col = "blue", lwd = 2)
        legend(510, 0.2, c("Model A Prediction", "Model C Prediction"), pch = 16, 
            col = c("red", "blue"), bty = "n", cex = 1.2)
        points(mathScoreInput, modelPredA(), col = "red", pch = 16, cex = 2)
        points(mathScoreInput, modelPredC(), col = "blue", pch = 16, cex = 2)
        
        # model B vs model C
        plot(collegeMapData$MedianWritingSAT, collegeMapData$CompletionRate, 
            xlab = "Median Writing SAT Score", ylab = "Completion Rate")
        abline(lm.fitB, col = "green", lwd = 2)
        abline(a = coef(lm.fitC)[1] + coef(lm.fitC)[2]*mathScoreInput, 
            b = coef(lm.fitC)[3], col = "blue", lwd = 2)
        legend(510, 0.2, c("Model B Prediction", "Model C Prediction"), pch = 16, 
            col = c("green", "blue"), bty = "n", cex = 1.2)
        points(writingScoreInput, modelPredB(), col = "green", pch = 16, cex = 2)
        points(writingScoreInput, modelPredC(), col = "blue", pch = 16, cex = 2)
        
    })
    
   
    output$scores <- renderText({
        paste(
            "Math: ", input$sliderMATH, 
            "Verbal: ", input$sliderVERBAL, 
            "Writing: ", input$sliderWRITING)
    })
    
    output$count1 <- renderText({
        univCount()
    })
    
    output$predA <- renderText({
        percent(modelPredA())
    })
    
    
    output$predB <- renderText({
        percent(modelPredB())
    })
    
    output$predC <- renderText({
        percent(modelPredC())
    })
    
})
