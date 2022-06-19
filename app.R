library(shiny)
library(waiter)

ui <- fluidPage(
  autoWaiter(),
  actionButton("search_action", "Run"),
  textOutput("text")
)

server <- function(input, output) {

  my_text <- eventReactive(
    input$search_action,
    {
     Sys.sleep(3)
     "LONG CALCULATION"
    })

  output$text <- renderText(
    {
      my_text()
    }
  )


}

shinyApp(ui, server)
