library(shiny)
library(waiter)

ui <- fluidPage(
  autoWaiter(),
  actionButton("search_action", "Run"),
  tabsetPanel(
    id = "hidden_tab_panel",
    type = "hidden",
    tabPanel(
      "first"
    ),
    tabPanel(
      "second",
    textInput("more_input", "More input")
    )
  ),
  textOutput("text")
)

server <- function(input, output) {

  observeEvent(input$search_action, {
    updateTabsetPanel(inputId = "hidden_tab_panel", selected = "second")
  })

  my_text <- eventReactive(input$search_action, {
    Sys.sleep(3)
    "LONG CALCULATION"
  })

  output$text <- renderText({my_text()})
}

shinyApp(ui, server)
