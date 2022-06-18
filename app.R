library(shiny)
library(dplyr)
library(lubridate)
library(ggplot2)
library(zoo)
library(shinyWidgets)

source("functions.R")

ui <- fluidPage(
  h1("Wikipedia Edit History Viewer"),
  sidebarLayout(
    sidebarPanel(
      textInput(
        "text_input",
        "search"
      ),
      actionButton("search_action", "Search"),
      tabsetPanel(
        id = "hidden_tab_panel",
        type = "hidden",
        tabPanel(
          "first"
        ),
        tabPanel(
          "second",
          hr(),
          dateInput(
            inputId = "start_date",
            label = "start date"
          )
        )
      ),
    ),
    mainPanel(
      tabsetPanel(
        id = "hidden_tab_panel_main",
        type = "hidden",
        tabPanel(
          "first_main"
        ),
        tabPanel(
          "second_main",
          addSpinner(
            plotOutput("figure"), spin = "circle", color = "#E41A1C"
          )
        )
      )
    )
  )
)



server <- function(input, output) {

  observeEvent(
    input$search_action, {
      updateTabsetPanel(inputId = "hidden_tab_panel_main", selected = "second_main")

    },
    once = TRUE,
    priority = 10)

  observeEvent(
    length(my_data()) > 1, {
      updateTabsetPanel(inputId = "hidden_tab_panel", selected = "second")
    },
    priority = 2,
    once = TRUE
    )



  my_data <- eventReactive(
    input$search_action,
    {
      get_edit_history(input$text_input) %>%
        process_edits()
    })



  output$figure <- renderPlot(
    ggplot(my_data(), aes(x = dates, n)) +
      geom_point(alpha = 0.1, color='darkblue') +
      geom_line(aes(y=rollmean(n, 30, na.pad=TRUE)), color="purple", size =1.5) +
      labs(y = "edit count") +
      theme_minimal() +
      theme(axis.title.x = element_blank())
  )
}

shinyApp(ui, server)
