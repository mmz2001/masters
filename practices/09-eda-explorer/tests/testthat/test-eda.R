# test-eda.R — unit tests for eda.R core logic (no Shiny, no browser).

source("../../eda.R")

test_that("load_demo_dataset returns the right shape for each demo set", {
  expect_equal(nrow(load_demo_dataset("iris")), 150)
  expect_equal(nrow(load_demo_dataset("mtcars")), 32)
  expect_true(nrow(load_demo_dataset("diamonds", row_cap = 500)) == 500)
  expect_error(load_demo_dataset("nope"), "Unknown demo dataset")
})

test_that("load_demo_dataset row-caps large datasets deterministically", {
  d1 <- load_demo_dataset("diamonds", row_cap = 300, seed = 1)
  d2 <- load_demo_dataset("diamonds", row_cap = 300, seed = 1)
  expect_equal(d1, d2)
})

test_that("parse_pasted_text parses CSV text into a data.frame", {
  df <- parse_pasted_text("a,b\n1,2\n3,4")
  expect_equal(nrow(df), 2)
  expect_equal(names(df), c("a", "b"))
  expect_error(parse_pasted_text(""), "empty")
  expect_error(parse_pasted_text("   "), "empty")
})

test_that("parse_uploaded_file reads csv and xlsx by extension", {
  csv_path <- tempfile(fileext = ".csv")
  write.csv(data.frame(x = 1:3, y = 4:6), csv_path, row.names = FALSE)
  df_csv <- parse_uploaded_file(csv_path, "upload.csv")
  expect_equal(df_csv$x, 1:3)

  xlsx_path <- tempfile(fileext = ".xlsx")
  openxlsx::write.xlsx(data.frame(x = 1:3, y = 7:9), xlsx_path)
  df_xlsx <- parse_uploaded_file(xlsx_path, "upload.xlsx")
  expect_equal(df_xlsx$x, 1:3)

  expect_error(parse_uploaded_file(csv_path, "upload.txt"), "Unsupported file extension")
})

test_that("numeric_columns returns only numeric column names", {
  df <- data.frame(a = 1:3, b = letters[1:3], c = c(1.1, 2.2, 3.3), stringsAsFactors = FALSE)
  expect_equal(numeric_columns(df), c("a", "c"))
})

test_that("compute_correlation_matrix matches base cor() and rejects <2 numeric cols", {
  df <- iris[, 1:4]
  expected <- cor(df)
  expect_equal(compute_correlation_matrix(df), expected)
  expect_error(compute_correlation_matrix(data.frame(a = 1:3)), "at least 2 numeric")
})

test_that("compute_mds returns a 2-column MDS1/MDS2 data.frame sized to input (after row-cap)", {
  mds <- compute_mds(iris, row_cap = 500)
  expect_equal(names(mds), c("MDS1", "MDS2"))
  expect_equal(nrow(mds), 150)

  mds_capped <- compute_mds(iris, row_cap = 50)
  expect_equal(nrow(mds_capped), 50)

  expect_error(compute_mds(data.frame(a = 1:5)), "at least 2 numeric")
  expect_error(compute_mds(data.frame(a = 1:2, b = 3:4)), "at least 3 complete rows")
})

test_that("compute_mds carries extra_cols through row-cap and complete-case filtering aligned to output rows", {
  mds <- compute_mds(iris, extra_cols = "Species", row_cap = 500)
  expect_true("Species" %in% names(mds))
  expect_equal(nrow(mds), 150)

  mds_capped <- compute_mds(iris, extra_cols = "Species", row_cap = 40)
  expect_equal(nrow(mds_capped), 40)
  expect_true(all(mds_capped$Species %in% levels(iris$Species)))
})
