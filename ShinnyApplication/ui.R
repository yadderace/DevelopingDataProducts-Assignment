#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinyjs)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  shinyjs::useShinyjs(),
  # Application title
  titlePanel("K Means Clustering"),
  
  #
  
  # Sidebar with a slider input for number of clusters 
  sidebarLayout(
    sidebarPanel(
      
      sliderInput("slidePoints", label = h3("Number of Points"), min = 20, max = 50, step =  5, value = 20),
      
      actionButton("btnGenerate", label = "Generate Random Data"),
      
      hr(),
      
      sliderInput("slideClusters", label = h3("Number of Clusters"), min = 2, max = 10, value = 3),
      
      checkboxGroupInput("configuration", "Configuration:",
                         c("Centroids" = "centroids",
                           "Area" = "area")),
      
      disabled(actionButton("btnCluster", label = "Make Clusters")),
      
      hr(),
      
      helpText("Note: You can add more points by clicking on the plot.")
      
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      
      tabsetPanel( type = "tabs",
                   tabPanel("K-Means", plotOutput("resultPlot", click = "plotClick")),
                   tabPanel("Help",
                            h2("Documentation"),
                            p("To use this application, take these steps:"),
                            HTML("<ol>
                                    <li>
                                        Generate random points by pressing <b>Generate Random Points</b> button. 
                                        It will generate the number of points specified at <b>Number of points</b> slider.
                                    </li>
                                    <li>
                                        Select the configuration for plotting the clusters. Chose the number of cluster at 
                                        <b>Number of clusters</b> slider. Check centroids checkbox to display the centers for
                                        each cluster. Check area checkbox to display the areas that wrap all points which belong to a cluster.
                                    </li>
                                    <li>
                                        Build the plot with its configuration pressing <b>Make Clusters</b> button.
                                    </li>
                                 </ol>")
                            )
        
      )
       
    )
  )
))
