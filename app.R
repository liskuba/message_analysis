library(shiny)
library(shinythemes)


ui <- fluidPage(
  theme = shinytheme("slate"),
  titlePanel("TYTUL"),
  sidebarLayout(
    sidebarPanel(
      dateRangeInput(inputId = "dateRange",
                     label = "Date range",
                     start = Sys.Date() - 365,
                     end = Sys.Date(),
                     format = "dd-mm-yyyy",
                     weekstart = 1),
      checkboxGroupInput(inputId = "persons",
                         label = "hehe",
                         choices = c("Kuba K.", "Kuba L.", "Bartek S."))
    ),

    mainPanel(
      tabsetPanel(
        tabPanel("tab1", "Hello"),
        tabPanel("tab2", "World"),
        tabPanel("tab3", br(),
                 selectInput(inputId = "dayOfWeek",
                             label = "Day of the week",
                             choices = c("Monday", "Tuesday", "Wednesday",
                                         "Thursday", "Friday", "Saturday",
                                         "Sunday", "all???")))
      )
    )
  )
)

server <- function(input, output, session) {
  
}

shinyApp(ui, server)
