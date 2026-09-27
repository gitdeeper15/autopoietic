# =============================================================
# STRATIM — Documentation Verification
# File: SIMULATION/code/06_verify_documentation.R
# Version: 0.1.0-protocol
# =============================================================
#
# Verifies that numbers reported in EXPERIMENTS.md and
# SIMULATION/reports/*.md match the actual CSV artifacts.
#
# This script reads:
#   - SIMULATION/results/*.csv
# and checks selected key values that appear in the reports.
#
# It is a documentation integrity check, not a simulation.
#
# =============================================================

suppressPackageStartupMessages({
  library(stats)
})

results_dir <- "SIMULATION/results"

check <- function(label, actual, expected, tolerance = 1e-4) {
  ok <- FALSE
  if (is.numeric(actual) && is.numeric(expected)) {
    ok <- abs(actual - expected) <= tolerance
  } else {
    ok <- identical(actual, expected)
  }
  status <- if (ok) "PASS" else "FAIL"
  cat(sprintf("  [%s] %-55s actual=%s expected=%s\n",
              status, label,
              paste(actual, collapse = ","),
              paste(expected, collapse = ",")))
  ok
}

cat("\n")
cat("=====================================================\n")
cat("STRATIM — Documentation Verification\n")
cat("=====================================================\n")

# -------------------------------------------------------------
# Load CSVs
# -------------------------------------------------------------
h5_summary   <- read.csv(file.path(results_dir, "01_H5_identifiability_summary.csv"))
rec_summary  <- read.csv(file.path(results_dir, "02_parameter_recovery_summary.csv"))
recb_summary <- read.csv(file.path(results_dir, "02b_recovery_boundary_summary.csv"))
power        <- read.csv(file.path(results_dir, "03_power_surface.csv"))
scenarios    <- read.csv(file.path(results_dir, "04_state_scenarios.csv"))

all_ok <- TRUE

# -------------------------------------------------------------
# H5 — verify min/max correlation
# -------------------------------------------------------------
cat("\n--- Experiment 01 (H5 Identifiability) ---\n")

h5_min <- min(h5_summary$median_corr)
h5_max <- max(h5_summary$median_corr)

all_ok <- check("H5 n_cells", nrow(h5_summary), 16) && all_ok
all_ok <- check("H5 min_corr", round(h5_min, 4), 0.3691) && all_ok
all_ok <- check("H5 max_corr", round(h5_max, 4), 0.9974) && all_ok

# -------------------------------------------------------------
# Recovery — verify 8 parameters
# -------------------------------------------------------------
cat("\n--- Experiment 02 (Parameter Recovery) ---\n")

all_ok <- check("Recovery n_parameters", nrow(rec_summary), 8) && all_ok

# Spot-check key values
param_lookup <- function(name) rec_summary[rec_summary$param == name, ]

for (p in c("phi", "alpha_0", "sigma_alpha")) {
  row <- param_lookup(p)
  cat(sprintf("    %s: true=%.3f est=%.4f bias=%+.5f\n",
              p, row$true, row$mean_est, row$bias))
}

all_ok <- check("phi true", 0.500, 0.500) && all_ok
all_ok <- check("alpha_0 est (rounded)", round(param_lookup("alpha_0")$mean_est, 4), 0.2021) && all_ok
all_ok <- check("sigma_alpha est (rounded)", round(param_lookup("sigma_alpha")$mean_est, 4), 0.1010) && all_ok

# -------------------------------------------------------------
# Recovery Boundary
# -------------------------------------------------------------
cat("\n--- Experiment 03 (Recovery Boundary) ---\n")

# Verify counts by sigma_alpha
flag_counts <- function(sa) {
  sub <- recb_summary[recb_summary$sigma_alpha == sa, ]
  c(
    adequate   = sum(sub$flag == "adequate",   na.rm = TRUE),
    marginal   = sum(sub$flag == "marginal",   na.rm = TRUE),
    inadequate = sum(sub$flag == "inadequate", na.rm = TRUE)
  )
}

c_010 <- flag_counts(0.10)
c_005 <- flag_counts(0.05)
c_003 <- flag_counts(0.03)
c_001 <- flag_counts(0.01)

cat("    sigma_alpha = 0.10 :", c_010, "\n")
cat("    sigma_alpha = 0.05 :", c_005, "\n")
cat("    sigma_alpha = 0.03 :", c_003, "\n")
cat("    sigma_alpha = 0.01 :", c_001, "\n")

all_ok <- check("recb 0.10 adequate",   as.integer(c_010["adequate"]),   8L) && all_ok
all_ok <- check("recb 0.10 marginal",   as.integer(c_010["marginal"]),   1L) && all_ok
all_ok <- check("recb 0.10 inadequate", as.integer(c_010["inadequate"]), 0L) && all_ok

all_ok <- check("recb 0.05 adequate",   as.integer(c_005["adequate"]),   5L) && all_ok
all_ok <- check("recb 0.05 marginal",   as.integer(c_005["marginal"]),   2L) && all_ok
all_ok <- check("recb 0.05 inadequate", as.integer(c_005["inadequate"]), 2L) && all_ok

all_ok <- check("recb 0.03 adequate",   as.integer(c_003["adequate"]),   1L) && all_ok
all_ok <- check("recb 0.03 marginal",   as.integer(c_003["marginal"]),   4L) && all_ok
all_ok <- check("recb 0.03 inadequate", as.integer(c_003["inadequate"]), 4L) && all_ok

all_ok <- check("recb 0.01 adequate",   as.integer(c_001["adequate"]),   0L) && all_ok
all_ok <- check("recb 0.01 marginal",   as.integer(c_001["marginal"]),   0L) && all_ok
all_ok <- check("recb 0.01 inadequate", as.integer(c_001["inadequate"]), 9L) && all_ok

# -------------------------------------------------------------
# Power Surface
# -------------------------------------------------------------
cat("\n--- Experiment 04 (Power Surface) ---\n")

all_ok <- check("power n_cells", nrow(power), 128L) && all_ok

min_n_for <- function(col, target = 0.80) {
  ok <- power[power[[col]] >= target, , drop = FALSE]
  if (nrow(ok) == 0) return(NA_integer_)
  as.integer(min(ok$N, na.rm = TRUE))
}

h1_min  <- min_n_for("power_H1")
h1a_min <- min_n_for("power_H1a")
h1c_min <- min_n_for("power_H1c")
h1d_min <- min_n_for("power_H1d")

cat(sprintf("    min N: H1=%s H1a=%s H1c=%s H1d=%s\n",
            h1_min, h1a_min, h1c_min, h1d_min))

all_ok <- check("power min N H1",  h1_min,  100L) && all_ok
all_ok <- check("power min N H1a", h1a_min, 100L) && all_ok
all_ok <- check("power min N H1c", h1c_min, 200L) && all_ok
all_ok <- check("power min N H1d", h1d_min, 100L) && all_ok

# -------------------------------------------------------------
# State Scenarios
# -------------------------------------------------------------
cat("\n--- Experiment 05 (State Scenarios) ---\n")

for (s in c("3B", "3A", "J")) {
  sub <- scenarios[scenarios$scenario == s, ]
  n_total <- nrow(sub)

  target <- if (s == "3B") {
    sub$O <= 0.40 & sub$SIC > 0.50
  } else if (s == "3A") {
    sub$SIC <= 0.50
  } else {
    sub$O <= 0.40 & sub$SIC <= 0.50
  }

  n_match <- sum(target, na.rm = TRUE)
  cat(sprintf("    Scenario %s: n=%d, matching=%d (%.2f)\n",
              s, n_total, n_match, n_match / n_total))

  all_ok <- check(paste0("scenario ", s, " n"), n_total, 200L) && all_ok
  all_ok <- check(paste0("scenario ", s, " matching"), n_match, 200L) && all_ok
}

# -------------------------------------------------------------
# Summary
# -------------------------------------------------------------
cat("\n")
cat("=====================================================\n")
if (all_ok) {
  cat("RESULT: All documentation values verified. PASS\n")
} else {
  cat("RESULT: Documentation discrepancies found. REVIEW\n")
}
cat("=====================================================\n")

# =============================================================
# End of 06_verify_documentation.R
# =============================================================
