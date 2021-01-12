library(shiny)
library(shinythemes)
library(readr)
library(ggplot2)
library(dplyr)
library(stringr)
library(patchwork)
library(ggthemes)
library(tidyverse)
library(rvest)
# devtools::install_github("clauswilke/ggtext")
library(ggtext)
# devtools::install_github("hadley/emo")
library(emo)
source("R_plots/prepare_data.R")


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
      
      # checkboxGroupInput(inputId = "persons",
      #                    label = "hehe",
      #                    choices =  c("Kuba K.", "Kuba L.", "Bartek S.")),
      
      tags$div(HTML(
        '<div id="persons" class="form-group shiny-input-checkboxgroup shiny-input-container shiny-bound-input">
        <label class="control-label" for="persons">hehe</label>
          <div class="shiny-options-group">
            <div class="checkbox">
              <label>
              <input type="checkbox" name="persons" value="Kuba K.">
              <span><img src="https://scontent-waw1-1.xx.fbcdn.net/v/t1.30497-1/c29.0.100.100a/p100x100/84241059_189132118950875_4138507100605120512_n.jpg?_nc_cat=1&ccb=2&_nc_sid=7206a8&_nc_ohc=ZUBgBA4cH8QAX9IyWEj&_nc_ad=z-m&_nc_cid=0&_nc_ht=scontent-waw1-1.xx&tp=27&oh=502ad4ebf86d02d6adcfa22dccd701d7&oe=601F529E" height = "80"/></span>
              </label>
            </div>
            <div class="checkbox">
              <label>
              <input type="checkbox" name="persons" value="Kuba L.">
              <span><img src="https://scontent-waw1-1.xx.fbcdn.net/v/t1.0-1/p100x100/122856167_1760056047475701_3097338334731053317_o.jpg?_nc_cat=108&ccb=2&_nc_sid=7206a8&_nc_ohc=BN2tqo9jmG0AX8FfTPI&_nc_ad=z-m&_nc_cid=0&_nc_ht=scontent-waw1-1.xx&tp=6&oh=1d4df0ff84a0b36b581b57fcd600968f&oe=601EC427" height = "80"></span>
              </label>
            </div>
            <div class="checkbox">
              <label>
              <input type="checkbox" name="persons" value="Bartek S.">
              <span><img src="https://scontent-waw1-1.xx.fbcdn.net/v/t1.0-9/1526556_254831838188045_5566807436520804551_n.jpg?_nc_cat=100&ccb=2&_nc_sid=09cbfe&_nc_ohc=Astqsg6awukAX-gAMxT&_nc_ht=scontent-waw1-1.xx&oh=3720f0f128f381bf9ebd36d3e4da07fe&oe=601F928E" height = "80"></span>
              </label>
            </div>
          </div>
        </div>
        '
      ))
    ),

    mainPanel(
      tabsetPanel(
        tabPanel("tab1", "Hello"),
        tabPanel("The Most Used Emojis", br(),
                 plotOutput("emojiPlot")),
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
  output$emojiPlot <- renderPlot({
    if (length(input$persons) == 0){
      return(NULL)
    }
    plot_emoji(input$dateRange[1], input$dateRange[2],
               input$persons)
    
  })
}

shinyApp(ui, server)
