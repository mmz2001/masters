# eda.R — core EDA logic, decoupled from any UI: dataset loading (with
# row-cap sampling for large demo sets), file/text parsing, numeric-column
# detection, correlation matrix, and classical MDS. Pure functions on a
# data.frame in, data.frame/matrix out — no Shiny, no file I/O side effects
# beyond reading the path/text handed to it.

# Demo datasets ----

load_demo_dataset <- function(name, row_cap = 2000, seed = 42) {
  df <- switch(
    name,
    iris     = iris,
    mtcars   = mtcars,
    diamonds = { requireNamespace("ggplot2", quietly = TRUE); as.data.frame(ggplot2::diamonds) },
    stop(sprintf("Unknown demo dataset '%s' (expected iris, mtcars, or diamonds)", name))
  )
  if (nrow(df) > row_cap) {
    set.seed(seed)
    df <- df[sample(nrow(df), row_cap), , drop = FALSE]
  }
  df
}

# File / text parsing ----

parse_uploaded_file <- function(path, original_name = path) {
  ext <- tolower(tools::file_ext(original_name))
  if (ext == "csv") {
    read.csv(path, stringsAsFactors = FALSE)
  } else if (ext %in% c("xlsx", "xls")) {
    requireNamespace("readxl", quietly = TRUE)
    as.data.frame(readxl::read_excel(path))
  } else {
    stop(sprintf("Unsupported file extension '%s' (expected csv, xlsx, or xls)", ext))
  }
}

parse_pasted_text <- function(text) {
  if (!nzchar(trimws(text))) stop("Pasted text is empty")
  read.csv(text = text, stringsAsFactors = FALSE)
}

# Column helpers ----

numeric_columns <- function(df) {
  names(df)[vapply(df, is.numeric, logical(1))]
}

# Correlation + MDS ----

compute_correlation_matrix <- function(df, cols = numeric_columns(df)) {
  if (length(cols) < 2) stop("Need at least 2 numeric columns to compute a correlation matrix")
  cor(df[, cols, drop = FALSE], use = "pairwise.complete.obs")
}

compute_mds <- function(df, cols = numeric_columns(df), row_cap = 500, seed = 42, extra_cols = NULL) {
  if (length(cols) < 2) stop("Need at least 2 numeric columns to compute MDS")
  mat <- df[, cols, drop = FALSE]
  keep <- stats::complete.cases(mat)
  mat <- mat[keep, , drop = FALSE]
  extra <- if (!is.null(extra_cols)) df[keep, extra_cols, drop = FALSE] else NULL
  if (nrow(mat) > row_cap) {
    set.seed(seed)
    idx <- sample(nrow(mat), row_cap)
    mat <- mat[idx, , drop = FALSE]
    if (!is.null(extra)) extra <- extra[idx, , drop = FALSE]
  }
  if (nrow(mat) < 3) stop("Need at least 3 complete rows to compute MDS")
  d <- stats::dist(scale(mat))
  fit <- stats::cmdscale(d, k = 2)
  out <- data.frame(MDS1 = fit[, 1], MDS2 = fit[, 2], row.names = NULL)
  if (!is.null(extra)) out <- cbind(out, extra)
  out
}
