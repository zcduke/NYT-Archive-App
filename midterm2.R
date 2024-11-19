library(shiny)
library(bslib)
library(tidyverse)

# The following line will load all of your R code from the qmd
# this will make your get_nyt_articles function available to your
# shiny app.
source(
  knitr::purl("midterm2.qmd", output=tempfile(), quiet=TRUE)
)

ui = page_sidebar(
  title = "NYTimes API",
  sidebar = sidebar(
    sliderInput("n","Number of links", min = 0, max = 10, value = 5)
  ),
  uiOutput("links")
)

server = function(input, output, session) {
  state = reactiveValues(
    # List used to keep track of our current observers
    observers = list()
  )
  
  observe({
    req(state$observers)
    
    # Destroy existing observers
    purrr::walk(
      state$observers,
      ~ .x$destroy()
    )
    
    ui_elems = purrr::map(
      seq_len(input$n), 
      function(i) {
        layout_columns(
          actionLink(inputId = paste0("link",i), label = paste0("This is link ",i,"."))
        )
      }
    )
    output$links = renderUI(ui_elems)
    
    # Reset and create new observers for each of our links
    state$observers = purrr::map(
      seq_len(input$n), 
      function(i) {
        label = paste0("link",i)
        
        observe({
          cat("You clicked link ", i,"!\n",sep="")
        }) |>
          bindEvent(input[[label]])
      }
    )
  }) |>
    bindEvent(input$n)
}

shinyApp(ui = ui, server = server)