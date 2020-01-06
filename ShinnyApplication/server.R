#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)
library(tidyverse)
library(cluster)
library(plyr)


# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  values <- reactiveValues();
  
  # For save all clustered points.
  values$dfResult <- data.frame(
    x = numeric(0),
    y = numeric(0),
    cluster = numeric(0)
  );
  
  # For save all new points.
  values$dfNewPoints <- data.frame(
    x = numeric(0),
    y = numeric(0)
  )
  
  # For save the cluster for points.
  values$clusters <- NULL;
  
  # For save the centroids
  values$centroids <- NULL;
  
  # Colors for clusters.
  colors <- c("#550000", "#D46A6A",
              "#FFD1AA", "#804515",
              "#116611", "#88CC88",
              "#003333", "#407F7F",
              "#D4D369", "#555500");
  
  # ==========================================================
  # RENDERING
  
  # To render the plot
  output$resultPlot <- renderPlot({
    
    dfData <- values$dfResult;
    
    if(is.null(dfData) | nrow(dfData) == 0) return(NULL);
    
    myPlot <- ggplot(mapping = aes(x = x, y = y))
    
    
    # Verifying if there are clusters to set color
    if(!is.null(values$clusters)){ 
      myPlot <- myPlot + geom_point(dfData, size = 3, mapping = aes(color = as.factor(values$clusters))) +
        scale_colour_manual(values = colors[1:input$slideClusters])
      
      
      # Checking if it is necessary to plot areas.
      if("area" %in% input$configuration){
        
        dfData$cluster <- values$clusters;
        
        # Getting the convex hull of each unique point set
        fncFindHull <- function(dfTemp) dfTemp[chull(dfTemp$x, dfTemp$y), ]
        hulls <- ddply(dfData, "cluster", fncFindHull)
        
        
        myPlot <- myPlot + geom_polygon(data = hulls, alpha = 0.5, aes(colour = as.factor(cluster), fill = as.factor(cluster))) +
          scale_fill_manual(values = colors[1:input$slideClusters]);
        
        
        dfData$cluster <- NULL;
      }
      
      # Checking if it is necessary to plot centroids.
      if("centroids" %in% input$configuration){
        myPlot <- myPlot + geom_point(values$centroids, shape = 4, size = 3.5, mapping = aes())
      }
      
    }
    else { myPlot <- myPlot + geom_point(dfData, size = 3.5, mapping = aes()); }
    
    # Verifying if there are new points to set
    if(nrow(values$dfNewPoints) > 0){ 
      myPlot <- myPlot + geom_point(values$dfNewPoints, size = 2, mapping = aes()); 
    }
    
    # Setting axis limits
    myPlot <-  myPlot +
      theme(legend.position = "none") +
      xlim(0, 105) +
      ylim(0, 105);
    
    return(myPlot)
  });
  
  # ==========================================================
  # EVENTS
  
  # To generate random data
  observeEvent(input$btnGenerate, {
    
    qtyPoints <- input$slidePoints
    
    isolate(
      values$dfResult <- data.frame(
      x = runif(qtyPoints, min = 0, max = 100),
      y = runif(qtyPoints, min = 0, max = 100)
    ));
    
    isolate(
      values$clusters <- NULL
    );
    
    isolate(
      values$dfNewPoints <- data.frame(
        x = numeric(0),
        y = numeric(0)
      )
    );
    
    shinyjs::enable("btnCluster");
    
  });
  
  # To add a new point
  observeEvent(input$plotClick, {
    
    if(is.null(input$plotClick$x)) return(NULL);
    
    newX <- input$plotClick$x;
    newY <- input$plotClick$y;
    
    isolate(
      values$dfNewPoints <- rbind(values$dfNewPoints, data.frame(x = newX, y = newY))
    );
    
  });
  
  # To make clusters
  observeEvent(input$btnCluster, {
    
    if(is.null(values$dfResult)) return(NULL);
    
    dfTemp <- data.frame(x = values$dfResult$x, y = values$dfResult$y)
    
    dfTemp <- rbind(dfTemp, values$dfNewPoints)
    
    isolate(
      values$dfNewPoints <- data.frame(
        x = numeric(0),
        y = numeric(0))
    );
    
    objCluster <- kmeans(dfTemp, centers = input$slideClusters);
    
    isolate(values$dfResult <- dfTemp);
    isolate(values$clusters <- objCluster$cluster);
    isolate(values$centroids <- data.frame(objCluster$centers)); 
    
  })
  
})
