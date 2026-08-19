library(shinytest2)

test_that("app renders schema, values, and per-arm tables matching scanner.R output", {
  source("../../scanner.R")
  default_df <- read_adam_csv("../../data/synthetic_adsl.csv")
  expected_arm_saffl <- per_arm_counts(default_df, trt_var = "ARM", pop_flag = "SAFFL")
  expected_arm_all <- per_arm_counts(default_df, trt_var = "ARM")

  app <- AppDriver$new(app_dir = "../../", name = "adam-scanner", height = 900, width = 1000)

  schema_text <- app$get_text("#schema_table")
  for (col in names(default_df)) {
    expect_true(grepl(col, schema_text, fixed = TRUE),
                info = paste("missing column in schema table:", col))
  }

  arm_text <- app$get_text("#arm_table")
  for (i in seq_len(nrow(expected_arm_saffl))) {
    expect_true(grepl(expected_arm_saffl$arm[i], arm_text, fixed = TRUE))
    expect_true(grepl(as.character(expected_arm_saffl$n[i]), arm_text, fixed = TRUE))
  }

  # Switch the population filter off and confirm counts reflect all subjects
  # (every arm has exactly n_per_arm subjects by construction, regardless of SAFFL).
  app$set_inputs(pop_flag = "(none)")
  arm_text_unfiltered <- app$get_text("#arm_table")
  for (i in seq_len(nrow(expected_arm_all))) {
    expect_true(grepl(expected_arm_all$arm[i], arm_text_unfiltered, fixed = TRUE))
    expect_true(grepl(as.character(expected_arm_all$n[i]), arm_text_unfiltered, fixed = TRUE))
  }

  app$stop()
})
