library(shiny)
library(dplyr)
library(lubridate)
library(ggplot2)
library(zoo)
library(shinyWidgets)
library(waiter)

source("functions.R")

ui <- fluidPage(
  autoWaiter(),
  actionButton("search_action", "Run"),
  textOutput("text")
)



server <- function(input, output) {


  output$text <- renderText(
    {
      input$search_action
      Sys.sleep(3)
      "LONG CALCULATION"
    }
  )


}

shinyApp(ui, server)
