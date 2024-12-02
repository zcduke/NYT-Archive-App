library(shiny)
library(bslib)
library(tidyverse)

# The following line will load all of your R code from the qmd
# this will make your get_nyt_articles function available to your
# shiny app.
source(
  knitr::purl("midterm2.qmd", output=tempfile(), quiet=TRUE)
)

# Helper function to get the best available image URL
get_best_image = function(multimedia) {
  if (length(multimedia) > 0 && nrow(multimedia) > 0) {
    # Filter for images of type "image" and subtype "xlarge"
    img_data = multimedia[multimedia$type == "image" & multimedia$subtype == "xlarge", ]
    if (nrow(img_data) > 0) {
      # Return the URL of the first xlarge image
      return(paste0("https://static01.nyt.com/", img_data$url[1]))
    }
  }
  return(NULL)
}

ui = page_sidebar(
  title = "New York Times Front End",
  theme = bs_theme(version = 5, bootswatch = "flatly"),
  
  sidebar = sidebar(
    dateInput(
      "date",
      "Select Date:",
      value = as.Date("2020-09-18"), # Default date
      min = as.Date("1851-09-18"),   # NYT's first publication
      max = Sys.Date()
    ),
    
    # API key
    passwordInput(
      "api_key",
      "NYT API Key:",
      value = "MhgXZQJilpJv1wFcJmW1ZFW52GcPuQAL"   #Default API key
    ),
    
    actionButton(
      "get",
      "Get Articles",
      class = "btn-primary",
      width = "100%"
    ),
    
    hr(),
    
    textOutput("status")
  ),
  
  # Main panel with article headlines
  mainPanel(
    div(
      class = "container",
      uiOutput("headlines")
    )
  )
)

server = function(input, output, session) {
  articles = reactiveVal(NULL)
  state = reactiveValues(
    # List used to keep track of our current observers
    observers = list()
  )
  
  # Get articles when button is clicked
  observeEvent(input$get, {
    output$status = renderText("Getting articles...")
    
    date = input$date
    year = year(date)
    month = month(date)
    day = day(date)
    
    # Try to get articles
    tryCatch({
      result = get_nyt_articles(year, month, day, input$api_key)
      articles(result)
      output$status = renderText(paste("Found", nrow(result), "articles"))
    }, error = function(e) {
      output$status = renderText(paste("Error:", e$message))
    })
  })
  
  # Create dynamic UI for headlines
  observe({
    req(articles())
    data = articles()
    
    # Destroy existing observers
    purrr::walk(
      state$observers,
      ~.x$destroy()
    )
    
    # Create headline cards with preview images
    ui_elems = purrr::map(
      seq_len(nrow(data)),
      function(i) {
        article = data[i,]
        img_url = get_best_image(article$multimedia[[1]])
        
        div(
          class = "card mb-3",
          style = "cursor: pointer;",
          if (!is.null(img_url)) {
            div(
              class = "card-img-top",
              style = "height: 200px; background-size: cover; background-position: center;",
              style = sprintf("background-image: url('%s');", img_url)
            )
          },
          div(
            class = "card-body",
            h5(
              class = "card-title",
              actionLink(
                inputId = paste0("headline_", i),
                label = article$headline,
                class = "text-decoration-none text-dark"
              )
            ),
            p(
              class = "card-text text-muted",
              article$byline
            )
          )
        )
      }
    )
    
    output$headlines = renderUI(
      div(
        class = "row row-cols-1 row-cols-md-2 g-4",
        map(ui_elems, ~div(class = "col", .x))
      )
    )
    
    # Create observers for each headline
    state$observers = purrr::map(
      seq_len(nrow(data)),
      function(i) {
        article = data[i,]
        img_url = get_best_image(article$multimedia[[1]])
        
        observe({
          showModal(modalDialog(
            title = NULL,
            div(
              class = "modal-content border-0",
              if (!is.null(img_url)) {
                div(
                  class = "modal-img-top w-100",
                  style = "height: 300px; background-size: cover; background-position: center;",
                  style = sprintf("background-image: url('%s');", img_url)
                )
              },
              div(
                class = "modal-body p-4",
                h2(article$headline),
                div(
                  class = "text-muted mb-4",
                  article$byline,
                  br(),
                  article$source
                ),
                p(
                  class = "lead",
                  article$lead_paragraph
                ),
                div(
                  class = "abstract mt-3",
                  p(article$abstract)
                ),
                hr(),
                div(
                  class = "d-grid gap-2",
                  a(
                    "Read full article on NYTimes.com",
                    href = article$web_url,
                    target = "_blank",
                    class = "btn btn-primary btn-lg"
                  )
                )
              )
            ),
            size = "xl",
            easyClose = TRUE
          ))
        }) |>
          bindEvent(input[[paste0("headline_", i)]])
      }
    )
  }) |>
    bindEvent(articles())
}

shinyApp(ui = ui, server = server)