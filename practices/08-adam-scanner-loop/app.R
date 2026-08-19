library(shiny)

source("scanner.R")

default_df <- read_adam_csv("data/synthetic_adsl.csv")
default_cols <- names(default_df)

ui <- fluidPage(
  titlePanel("ADaM Scanner (demo) — synthetic data only, no real trial data"),
  sidebarLayout(
    sidebarPanel(
      fileInput("file", "Upload an ADaM-shaped CSV (optional)", accept = ".csv"),
      selectInput("trt_var", "Treatment variable", choices = default_cols, selected = "ARM"),
      selectInput("pop_flag", "Population flag (optional)",
                  choices = c("(none)", default_cols), selected = "SAFFL")
    ),
    mainPanel(
      h3("1. Schema"),
      tableOutput("schema_table"),
      h3("2. Distinct values (low-cardinality columns)"),
      tableOutput("values_table"),
      h3("3. Per-arm counts"),
      tableOutput("arm_table")
    )
  )
)

server <- function(input, output, session) {
  df <- reactive({
    if (is.null(input$file)) default_df else read_adam_csv(input$file$datapath)
  })

  observeEvent(df(), {
    cols <- names(df())
    updateSelectInput(session, "trt_var", choices = cols,
                       selected = if ("ARM" %in% cols) "ARM" else cols[1])
    updateSelectInput(session, "pop_flag", choices = c("(none)", cols),
                       selected = if ("SAFFL" %in% cols) "SAFFL" else "(none)")
  }, ignoreInit = TRUE)

  output$schema_table <- renderTable(discover_schema(df()))

  output$values_table <- renderTable({
    vals <- enumerate_values(df())
    do.call(rbind, lapply(names(vals), function(col) data.frame(variable = col, vals[[col]])))
  })

  output$arm_table <- renderTable({
    pf <- if (input$pop_flag == "(none)") NULL else input$pop_flag
    per_arm_counts(df(), trt_var = input$trt_var, pop_flag = pf)
  })
}

shinyApp(ui, server)
