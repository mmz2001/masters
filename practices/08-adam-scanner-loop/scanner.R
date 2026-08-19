# scanner.R — ADaM dataset scanner: schema discovery, distinct-value
# enumeration, per-arm subject counts. Pure functions on a data.frame, no
# file I/O and no UI — the same functions are called by the Shiny app and
# by the unit tests, so app.R stays a thin wrapper around this file.
#
# This is a clean-room reimplementation of the *idea* behind the internal
# adam-scanner skill's three phases (schema / values / per-arm stats),
# rewritten from scratch for a generic CSV input — no code or data from
# that skill is used here.

read_adam_csv <- function(path) {
  read.csv(path, stringsAsFactors = FALSE, colClasses = "character")
}

guess_type <- function(x) {
  if (all(grepl("^-?[0-9]+(\\.[0-9]+)?$", x[x != ""]))) "numeric" else "character"
}

# Phase 1: schema discovery — variable name, guessed type, distinct count,
# missing count. Mirrors "read the columns without reading all the data."
discover_schema <- function(df) {
  data.frame(
    variable   = names(df),
    type       = vapply(df, guess_type, character(1)),
    n_distinct = vapply(df, function(x) length(unique(x)), integer(1)),
    n_missing  = vapply(df, function(x) sum(x == "" | is.na(x)), integer(1)),
    row.names  = NULL,
    stringsAsFactors = FALSE
  )
}

# Phase 2: value enumeration — for low-cardinality columns (population
# flags, treatment codes, categorical demographics), list each distinct
# value and its count. High-cardinality columns (USUBJID, AGE, ...) are
# skipped automatically since enumerating them isn't useful.
enumerate_values <- function(df, max_distinct = 10) {
  candidates <- names(df)[vapply(df, function(x) length(unique(x)) <= max_distinct, logical(1))]
  out <- lapply(candidates, function(col) {
    tab <- sort(table(df[[col]]), decreasing = TRUE)
    data.frame(value = names(tab), n = as.integer(tab), row.names = NULL)
  })
  names(out) <- candidates
  out
}

# Phase 3: per-arm stats — subject counts by treatment arm, optionally
# restricted to a population flag (e.g. SAFFL == "Y").
per_arm_counts <- function(df, trt_var, pop_flag = NULL) {
  if (!trt_var %in% names(df)) {
    stop(sprintf("Column '%s' not found in dataset", trt_var))
  }
  if (!is.null(pop_flag)) {
    if (!pop_flag %in% names(df)) {
      stop(sprintf("Population flag column '%s' not found in dataset", pop_flag))
    }
    df <- df[df[[pop_flag]] == "Y", , drop = FALSE]
  }
  tab <- table(df[[trt_var]])
  data.frame(arm = names(tab), n = as.integer(tab), row.names = NULL)
}
