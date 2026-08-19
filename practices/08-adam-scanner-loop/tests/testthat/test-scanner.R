library(testthat)
source("../../scanner.R")

toy_df <- data.frame(
  USUBJID = c("S-01", "S-02", "S-03", "S-04"),
  ARM     = c("Placebo", "Placebo", "Drug", "Drug"),
  AGE     = c("60", "70", "55", "65"),
  SAFFL   = c("Y", "Y", "Y", "N"),
  stringsAsFactors = FALSE
)

test_that("discover_schema reports one row per column with correct types", {
  schema <- discover_schema(toy_df)
  expect_equal(nrow(schema), 4)
  expect_equal(schema$type[schema$variable == "AGE"], "numeric")
  expect_equal(schema$type[schema$variable == "USUBJID"], "character")
  expect_equal(schema$n_distinct[schema$variable == "ARM"], 2)
})

test_that("enumerate_values skips high-cardinality columns and counts low-cardinality ones", {
  vals <- enumerate_values(toy_df, max_distinct = 3)
  expect_false("USUBJID" %in% names(vals))  # 4 distinct values, above the cap
  expect_true("ARM" %in% names(vals))
  arm_tab <- vals[["ARM"]]
  expect_equal(arm_tab$n[arm_tab$value == "Placebo"], 2)
  expect_equal(arm_tab$n[arm_tab$value == "Drug"], 2)
})

test_that("per_arm_counts counts subjects per arm", {
  counts <- per_arm_counts(toy_df, trt_var = "ARM")
  expect_equal(sum(counts$n), 4)
  expect_equal(counts$n[counts$arm == "Placebo"], 2)
})

test_that("per_arm_counts respects a population flag filter", {
  counts <- per_arm_counts(toy_df, trt_var = "ARM", pop_flag = "SAFFL")
  expect_equal(sum(counts$n), 3)  # one Drug subject is SAFFL == N
  expect_equal(counts$n[counts$arm == "Drug"], 1)
})

test_that("per_arm_counts errors clearly on an unknown column", {
  expect_error(per_arm_counts(toy_df, trt_var = "NOPE"), "not found")
})
