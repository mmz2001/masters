library(shiny)
library(plotly)
source("eda.R")

DEMO_CHOICES <- c("iris" = "iris", "mtcars" = "mtcars", "diamonds (capped, large)" = "diamonds")

ui <- fluidPage(
  titlePanel("EDA Explorer — interactive Plotly plots on demo or your own data"),
  sidebarLayout(
    sidebarPanel(
      selectInput("source", "Data source",
                  choices = c("Demo dataset" = "demo", "Upload CSV/Excel" = "upload", "Paste CSV text" = "paste")),
      conditionalPanel(
        "input.source == 'demo'",
        selectInput("demo_name", "Demo dataset", choices = DEMO_CHOICES, selected = "iris"),
        helpText("diamonds (53,940 rows) is row-capped to 2000 for interactivity.")
      ),
      conditionalPanel(
        "input.source == 'upload'",
        fileInput("file", "Upload CSV or Excel", accept = c(".csv", ".xlsx", ".xls"))
      ),
      conditionalPanel(
        "input.source == 'paste'",
        textAreaInput("pasted_text", "Paste CSV text", rows = 6,
                       placeholder = "a,b,c\n1,2,3\n4,5,6"),
        actionButton("parse_btn", "Parse pasted text")
      ),
      hr(),
      uiOutput("axis_pickers")
    ),
    mainPanel(
      tabsetPanel(
        id = "tabs",
        tabPanel("2D Scatter", plotlyOutput("scatter2d")),
        tabPanel("Correlation Heatmap", plotlyOutput("heatmap")),
        tabPanel("3D Scatter", plotlyOutput("scatter3d")),
        tabPanel("MDS", plotlyOutput("mds_plot"))
      )
    )
  )
)

server <- function(input, output, session) {
  pasted_df <- eventReactive(input$parse_btn, parse_pasted_text(input$pasted_text))

  df <- reactive({
    if (input$source == "demo") {
      load_demo_dataset(input$demo_name)
    } else if (input$source == "upload") {
      req(input$file)
      parse_uploaded_file(input$file$datapath, input$file$name)
    } else {
      req(pasted_df())
      pasted_df()
    }
  })

  output$axis_pickers <- renderUI({
    d <- df()
    num_cols <- numeric_columns(d)
    all_cols <- names(d)
    validate(need(length(num_cols) >= 2, "Need at least 2 numeric columns for these plots."))

    tab <- input$tabs
    tagList(
      if (tab %in% c("2D Scatter", "3D Scatter")) {
        selectInput("x_var", "X", choices = num_cols, selected = num_cols[1])
      },
      if (tab %in% c("2D Scatter", "3D Scatter")) {
        selectInput("y_var", "Y", choices = num_cols, selected = num_cols[min(2, length(num_cols))])
      },
      if (tab == "3D Scatter") {
        selectInput("z_var", "Z", choices = num_cols, selected = num_cols[min(3, length(num_cols))])
      },
      if (tab %in% c("2D Scatter", "3D Scatter", "MDS")) {
        selectInput("color_var", "Color by", choices = c("(none)", all_cols), selected = "(none)")
      }
    )
  })

  output$scatter2d <- renderPlotly({
    d <- df()
    req(input$x_var, input$y_var)
    color_vals <- if (is.null(input$color_var) || input$color_var == "(none)") NULL else d[[input$color_var]]
    plot_ly(x = d[[input$x_var]], y = d[[input$y_var]], color = color_vals,
            type = "scatter", mode = "markers") %>%
      layout(xaxis = list(title = input$x_var), yaxis = list(title = input$y_var))
  })

  output$heatmap <- renderPlotly({
    cm <- compute_correlation_matrix(df())
    plot_ly(z = cm, x = colnames(cm), y = rownames(cm), type = "heatmap", colors = "RdBu")
  })

  output$scatter3d <- renderPlotly({
    d <- df()
    req(input$x_var, input$y_var, input$z_var)
    color_vals <- if (is.null(input$color_var) || input$color_var == "(none)") NULL else d[[input$color_var]]
    plot_ly(x = d[[input$x_var]], y = d[[input$y_var]], z = d[[input$z_var]], color = color_vals,
            type = "scatter3d", mode = "markers") %>%
      layout(scene = list(xaxis = list(title = input$x_var),
                           yaxis = list(title = input$y_var),
                           zaxis = list(title = input$z_var)))
  })

  output$mds_plot <- renderPlotly({
    d <- df()
    has_color <- !is.null(input$color_var) && input$color_var != "(none)"
    mds <- compute_mds(d, extra_cols = if (has_color) input$color_var else NULL)
    color_vals <- if (has_color) mds[[input$color_var]] else NULL
    plot_ly(x = mds$MDS1, y = mds$MDS2, color = color_vals, type = "scatter", mode = "markers") %>%
      layout(xaxis = list(title = "MDS1"), yaxis = list(title = "MDS2"))
  })
}

shinyApp(ui, server)
