library(shiny)
library(dplyr)
library(lubridate)
library(ggplot2)
library(zoo)

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
        id = "wizard",
        type = "hidden",
        tabPanel(
          "first",
          "hi"
        ),
        tabPanel(
          "second",
          "sup",
          dateInput(
            inputId = "start_date",
            label = "start date"
          )
        )
      ),
      # tabsetPanel(
      #   id = "wizard",
      #   type = "hidden",
      #   tabPanel(
      #     "initial",
      #     "first",
      #     dateInput(
      #       inputId = "start_date",
      #       label = "start date"
      #     )
      #   ),
      #   tabPanel(
      #     "set_2",
      #     "second"
      #   ),
      # ),
    ),
    mainPanel(
      plotOutput("figure")
    )
  )
)



server <- function(input, output) {
  my_data <- eventReactive(input$search_action, {
    get_edit_history(input$text_input) %>%
      mutate(dates =  as_date(timestamp))
  })

  output$figure <- renderPlot(
    ggplot(my_data() %>% count(dates), aes(x = dates, n)) +
      geom_point(alpha = 0.1, color='darkblue') +
      geom_line(aes(y=rollmean(n, 14, na.pad=TRUE)), color="purple", size =1.5) +
      labs(y = "edit count") +
      #lims(x = as.Date(c("2016-01-01", "2020-01-01")), y = c(0,50))+
      theme_minimal() +
      theme(axis.title.x = element_blank())
  )
}

shinyApp(ui, server)
