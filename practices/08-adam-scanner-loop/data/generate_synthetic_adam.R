#!/usr/bin/env Rscript
# Generates a small, entirely fictional ADSL-shaped ADaM dataset (one row
# per subject — the standard ADaM subject-level analysis dataset shape) so
# the scanner has something realistic-but-safe to scan: made-up study,
# made-up drug, made-up subjects. Base R only, no packages, runs anywhere.
#
# Usage: Rscript generate_synthetic_adam.R [output_csv]

args <- commandArgs(trailingOnly = TRUE)
output_csv <- if (length(args) >= 1) args[[1]] else "synthetic_adsl.csv"

set.seed(42)

study_id  <- "SYNTH-001"
drug_name <- "ZYNTH"
arms <- data.frame(
  ARMCD  = c("PBO", "ZYNTH10", "ZYNTH20"),
  ARM    = c("Placebo", paste(drug_name, "10mg"), paste(drug_name, "20mg")),
  TRT01PN = c(1, 2, 3),
  stringsAsFactors = FALSE
)

n_per_arm <- 20
n <- n_per_arm * nrow(arms)

arm_idx <- rep(seq_len(nrow(arms)), each = n_per_arm)

age <- round(rnorm(n, mean = 58, sd = 10))
age[age < 18] <- 18
age[age > 85] <- 85

sex <- sample(c("M", "F"), n, replace = TRUE, prob = c(0.48, 0.52))
race <- sample(
  c("WHITE", "BLACK OR AFRICAN AMERICAN", "ASIAN", "OTHER"),
  n, replace = TRUE, prob = c(0.7, 0.15, 0.1, 0.05)
)

# Everyone randomized is ITT; a handful never dosed / weren't eligible for safety.
ittfl <- rep("Y", n)
saffl <- sample(c("Y", "N"), n, replace = TRUE, prob = c(0.95, 0.05))

# Completion: higher discontinuation on active drug, purely for demo variety.
compl_prob <- c(0.90, 0.82, 0.75)[arm_idx]
complfl <- ifelse(runif(n) < compl_prob, "Y", "N")
dcsreas <- ifelse(complfl == "N",
                   sample(c("ADVERSE EVENT", "WITHDREW CONSENT", "LOST TO FOLLOW-UP"),
                          n, replace = TRUE, prob = c(0.5, 0.3, 0.2)),
                   "")

adsl <- data.frame(
  STUDYID  = study_id,
  USUBJID  = sprintf("%s-%04d", study_id, seq_len(n)),
  ARMCD    = arms$ARMCD[arm_idx],
  ARM      = arms$ARM[arm_idx],
  TRT01PN  = arms$TRT01PN[arm_idx],
  AGE      = age,
  AGEGR1   = ifelse(age < 65, "<65", ">=65"),
  SEX      = sex,
  RACE     = race,
  ITTFL    = ittfl,
  SAFFL    = saffl,
  COMPLFL  = complfl,
  DCSREAS  = dcsreas,
  stringsAsFactors = FALSE
)

write.csv(adsl, output_csv, row.names = FALSE)
cat(sprintf("Wrote %d rows (%d subjects x %d arms) to %s\n", nrow(adsl), n_per_arm, nrow(arms), output_csv))
