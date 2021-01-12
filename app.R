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


library(dygraphs)
library(datasets)
library(zoo)
library(xts)
library(dplyr)
library(gridExtra)

source("R_plots/data_messages_over_years.R")
source("R_plots/prepare_data.R")




ui <- fluidPage(theme = shinytheme("slate"),
                titlePanel("TYTUL"),
                sidebarLayout(
                  sidebarPanel(
                    dateRangeInput(
                      inputId = "dateRange",
                      label = "Date range",
                      start = Sys.Date() - 365,
                      end = Sys.Date(),
                      format = "dd-mm-yyyy",
                      weekstart = 1
                    ),
                    
                    # checkboxGroupInput(inputId = "persons",
                    #                    label = "hehe",
                    #                    choices =  c("Kuba K.", "Kuba L.", "Bartek S.")),
                    
                    tags$div(
                      HTML(
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
                      )
                    )
                  ),
                  
                  mainPanel(tabsetPanel(
                    tabPanel(
                      "Data over time",
                      mainPanel(
                        dygraphOutput("dygraph", width = "150%"),
                        checkboxInput("checkbox", "Aplly 14-days rolling average", FALSE),
                        actionButton("do", "Generate boxplots"),
                        plotOutput(outputId = "boxplots", width = "150%")
                        
                        
                      )
                    ),
                    tabPanel("The most used emojis", br(),
                             plotOutput("emojiPlot")),
                    tabPanel(
                      "Activity time",
                      br(),
                      selectInput(
                        inputId = "dayOfWeek",
                        label = "Day of the week",
                        choices = c(
                          "Monday",
                          "Tuesday",
                          "Wednesday",
                          "Thursday",
                          "Friday",
                          "Saturday",
                          "Sunday",
                          "all"
                        )
                      ),
                      br(),
                      plotOutput("activityPlot"),
                    )
                  ))
                ))

server <- function(input, output, session) {
  output$emojiPlot <- renderPlot({
    if (length(input$persons) == 0) {
      return(NULL)
    }
    plot_emoji(input$dateRange[1], input$dateRange[2],
               input$persons)
    
  })
  
  ### Tab 3
  output$activityPlot <- renderPlot({
    if (length(input$persons) == 0) {
      return(NULL)
    }
    plot_activity_time(input$dateRange[1],
                       input$dateRange[2],
                       input$persons,
                       input$dayOfWeek)
  })
  
  
  ############ Tab 1 functionality
  
  output$dygraph <- renderDygraph({
    if (input$checkbox) {
      dygraph(total_xts_rolling) %>% dyRangeSelector() %>%
        dyShading(from = min(index(total_xts)),
                  to = max(index(total_xts)),
                  color = "#fdf6e3") %>%
        dyAxis(name = "x", axisLabelColor = "white") %>%
        dyAxis(name = "y", axisLabelColor = "white") %>%
        dySeries("Koziel", color = '#F2133C') %>%
        dySeries("Lis", color = '#5741A6') %>%
        dySeries("Sawicki", color = '#F2BD1D')
    } else {
      dygraph(total_xts) %>% dyRangeSelector() %>%
        dyShading(from = min(index(total_xts)),
                  to = max(index(total_xts)),
                  color = "#fdf6e3") %>%
        dyAxis(name = "x", axisLabelColor = "white") %>%
        dyAxis(name = "y", axisLabelColor = "white") %>%
        dySeries("Koziel", color = '#F2133C') %>%
        dySeries("Lis", color = '#5741A6') %>%
        dySeries("Sawicki", color = '#F2BD1D')
    }

    
  })
  
  
  
  data_box <- eventReactive(input$do, {
    date_start <-
      strftime(req(input$dygraph_date_window[[1]]), "%Y-%m-%d")
    date_end <-
      strftime(req(input$dygraph_date_window[[2]]), "%Y-%m-%d")
    
    
    out <- list()
    
    
    out$Koziel <-
      mess_Koziel %>% filter(date > as.Date(date_start) &
                               date < as.Date(date_end))
    out$Lis <-
      mess_Lis %>% filter(date > as.Date(date_start) &
                            date < as.Date(date_end))
    out$Sawicki <-
      mess_Sawicki %>% filter(date > as.Date(date_start) &
                                date < as.Date(date_end))
    
    return(out)
    
    
  })
  
  
  
  
  box_Koziel <- reactive({
    if (!"Kuba K." %in% input$persons)
      return(NULL)
    ggplot(data_box()$Koziel, aes(x = day_of_the_week, y = length)) + geom_boxplot(fill = '#F2133C',
                                                                                   color = '#F2133C',
                                                                                   alpha = 0.2) + scale_y_log10() +
      theme_minimal() +
      theme_solarized() + ylab("message length") + xlab("")
  })
  box_Lis <- reactive({
    if (!"Kuba L." %in% input$persons)
      return(NULL)
    ggplot(data_box()$Lis , aes(x = day_of_the_week, y = length)) + geom_boxplot(fill = '#5741A6',
                                                                                 color = '#5741A6',
                                                                                 alpha = 0.2) + scale_y_log10() +
      theme_minimal() +
      theme_solarized() + ylab("message length") + xlab("")
  })
  box_Sawicki <- reactive({
    if (!"Bartek S." %in% input$persons)
      return(NULL)
    ggplot(data_box()$Sawicki, aes(x = day_of_the_week, y = length)) +
      geom_boxplot(fill = '#F2BD1D',
                   color = '#F2BD1D',
                   alpha = 0.2) + scale_y_log10()  +
      theme_minimal() +
      theme_solarized() + ylab("message length") + xlab("")
  })
  
  
  output$boxplots = renderPlot({
    ptlist <- list(box_Koziel(), box_Lis(), box_Sawicki())
    
    
    
    to_delete <- !sapply(ptlist, is.null)
    ptlist <- ptlist[to_delete]
    
    if (length(ptlist) == 0)
      return(NULL)
    
    grid.arrange(grobs = ptlist, ncol = length(ptlist))
  })
  
  ############ End of tab 1 functionality
  
  
}

shinyApp(ui, server)
