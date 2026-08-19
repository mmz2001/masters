library(shinytest2)

test_that("app loads, renders all 4 tabs with no error, switches demo dataset, upload, and paste all work", {
  app <- AppDriver$new(app_dir = "../../", name = "eda-explorer", height = 900, width = 1200,
                        load_timeout = 30000, timeout = 15000)

  no_shiny_error <- function() {
    html <- app$get_html("body")
    !grepl("shiny-output-error", html, fixed = TRUE)
  }
  has_plotly_widget <- function(output_id) {
    # plotlyOutput()'s own placeholder div already has class "plotly ..." even
    # when nothing was ever rendered into it, so checking for "plotly" alone
    # is vacuous. Plotly.js only adds "js-plotly-plot" to the div once it has
    # actually drawn a chart, so that's the real signal a render happened.
    html <- app$get_html(paste0("#", output_id))
    grepl("js-plotly-plot", html, fixed = TRUE)
  }

  # 1. Default (iris, 2D Scatter tab) renders with no error
  expect_true(no_shiny_error())
  expect_true(has_plotly_widget("scatter2d"))

  # 2. Each tab renders its plotly widget with no error
  tab_to_output <- c(
    "2D Scatter" = "scatter2d",
    "Correlation Heatmap" = "heatmap",
    "3D Scatter" = "scatter3d",
    "MDS" = "mds_plot"
  )
  for (tab in names(tab_to_output)) {
    app$set_inputs(tabs = tab)
    app$wait_for_idle()
    expect_true(no_shiny_error(), info = paste("tab:", tab))
    expect_true(has_plotly_widget(tab_to_output[[tab]]), info = paste("tab:", tab))
  }

  # 3. Switching demo dataset re-renders without error
  for (ds in c("mtcars", "diamonds", "iris")) {
    app$set_inputs(demo_name = ds)
    app$wait_for_idle()
    expect_true(no_shiny_error(), info = paste("dataset:", ds))
  }

  # 4. Upload a small CSV
  csv_path <- tempfile(fileext = ".csv")
  write.csv(data.frame(alpha = 1:6, beta = 6:1, gamma = c(1, 2, 1, 2, 1, 2)), csv_path, row.names = FALSE)
  app$set_inputs(source = "upload")
  app$upload_file(file = csv_path)
  app$wait_for_idle()
  expect_true(no_shiny_error())
  expect_true(has_plotly_widget("scatter2d"))

  # 5. Paste CSV text
  app$set_inputs(source = "paste")
  app$set_inputs(pasted_text = "p,q,r\n1,4,7\n2,5,8\n3,6,9\n4,7,10")
  app$click("parse_btn")
  app$wait_for_idle()
  expect_true(no_shiny_error())
  expect_true(has_plotly_widget("scatter2d"))

  app$stop()
})
