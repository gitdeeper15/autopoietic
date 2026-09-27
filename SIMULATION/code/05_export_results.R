# =============================================================
# STRATIM — Export Simulation Results to JSON
# File: SIMULATION/code/05_export_results.R
# Version: 0.1.0-protocol
# =============================================================
#
# Reads all simulation CSV artifacts and produces a single
# JSON file consumed by the Dashboard.
#
# The JSON is a strict export of the CSVs. No numbers are
# hard-coded here. If a CSV is missing or malformed, the
# script fails with an explicit error.
#
# Output:
#   PUBLICATION/Netlify/public/data/simulation_results.json
#
# =============================================================

suppressPackageStartupMessages({
  library(stats)
})

# -------------------------------------------------------------
# Locate directories
# -------------------------------------------------------------
results_dir  <- "SIMULATION/results"
output_dir   <- "PUBLICATION/Netlify/public/data"
output_file  <- file.path(output_dir, "simulation_results.json")

if (!dir.exists(results_dir)) {
  stop("Missing directory: ", results_dir)
}
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
  cat("Created output directory:", output_dir, "\n")
}

# -------------------------------------------------------------
# Read CSV with explicit checks
# -------------------------------------------------------------
read_csv_strict <- function(path, required = TRUE) {
  if (!file.exists(path)) {
    if (required) stop("Missing required file: ", path)
    return(NULL)
  }
  df <- read.csv(path, stringsAsFactors = FALSE)
  if (nrow(df) == 0) stop("Empty CSV: ", path)
  df
}

# -------------------------------------------------------------
# Load all required CSVs
# -------------------------------------------------------------
cat("\n=== Loading CSVs ===\n")

h5_summary <- read_csv_strict(
  file.path(results_dir, "01_H5_identifiability_summary.csv"))
h5_raw     <- read_csv_strict(
  file.path(results_dir, "01_H5_identifiability.csv"))

rec_summary <- read_csv_strict(
  file.path(results_dir, "02_parameter_recovery_summary.csv"))

recb_summary <- read_csv_strict(
  file.path(results_dir, "02b_recovery_boundary_summary.csv"))

power_surface <- read_csv_strict(
  file.path(results_dir, "03_power_surface.csv"))

state_scen <- read_csv_strict(
  file.path(results_dir, "04_state_scenarios.csv"))

cat("  H5 summary rows:          ", nrow(h5_summary), "\n")
cat("  H5 raw rows:              ", nrow(h5_raw), "\n")
cat("  Recovery summary rows:    ", nrow(rec_summary), "\n")
cat("  Recovery boundary rows:   ", nrow(recb_summary), "\n")
cat("  Power surface rows:       ", nrow(power_surface), "\n")
cat("  State scenario rows:      ", nrow(state_scen), "\n")

# -------------------------------------------------------------
# Validation
# -------------------------------------------------------------
cat("\n=== Validation ===\n")

validate_no_na <- function(df, cols, name) {
  bad <- FALSE
  for (col in cols) {
    if (!(col %in% names(df))) {
      cat("  ERROR:", name, "missing column:", col, "\n")
      bad <- TRUE
      next
    }
    n_na <- sum(is.na(df[[col]]))
    if (n_na > 0) {
      cat("  WARNING:", name, "column", col, "has", n_na, "NA values\n")
    }
  }
  !bad
}

# H5: corr, lambda, rho should have no NA
ok_h5 <- validate_no_na(h5_summary,
                        c("lambda", "rho", "median_corr"),
                        "H5 summary")

# Recovery: all params should have no NA
ok_rec <- validate_no_na(rec_summary,
                         c("param", "true", "mean_est"),
                         "Recovery summary")

# Recovery boundary: flag should be set
ok_recb <- validate_no_na(recb_summary,
                          c("sigma_alpha", "N", "attrition", "flag"),
                          "Recovery boundary")

# Power surface: all power columns should have no NA
ok_power <- validate_no_na(power_surface,
                           c("N", "sigma_alpha", "power_H1", "power_H1a",
                             "power_H1c", "power_H1d"),
                           "Power surface")

# State scenarios: classified should have no NA
ok_state <- validate_no_na(state_scen,
                           c("scenario", "O", "SIC", "classified"),
                           "State scenarios")

if (!all(ok_h5, ok_rec, ok_recb, ok_power, ok_state)) {
  stop("Validation failed. Aborting JSON export.")
}
cat("  All CSVs passed basic validation.\n")

# -------------------------------------------------------------
# Build JSON structure
# -------------------------------------------------------------
cat("\n=== Building JSON ===\n")

# Helper: convert data.frame to list of records
df_to_records <- function(df) {
  lapply(seq_len(nrow(df)), function(i) as.list(df[i, ]))
}

# H5 summary table
h5_summary_records <- df_to_records(h5_summary)

# H5 aggregate
h5_max_corr <- max(h5_summary$median_corr, na.rm = TRUE)
h5_min_corr <- min(h5_summary$median_corr, na.rm = TRUE)

h5_decision <- if (h5_min_corr > 0.95) {
  "not_testable"
} else if (h5_max_corr < 0.90) {
  "testable_all"
} else {
  "testable_regions"
}

# Recovery summary
rec_records <- df_to_records(rec_summary)

# Recovery boundary — aggregate by sigma_alpha
sigma_levels <- sort(unique(recb_summary$sigma_alpha), decreasing = TRUE)
recb_by_sigma <- lapply(sigma_levels, function(sa) {
  sub <- recb_summary[recb_summary$sigma_alpha == sa, ]
  list(
    sigma_alpha = sa,
    n_total     = nrow(sub),
    n_adequate  = sum(sub$flag == "adequate",   na.rm = TRUE),
    n_marginal  = sum(sub$flag == "marginal",   na.rm = TRUE),
    n_inadequate = sum(sub$flag == "inadequate", na.rm = TRUE),
    median_bias = median(sub$bias, na.rm = TRUE),
    median_rmse = median(sub$rmse, na.rm = TRUE)
  )
})

# Power surface — minimum N for 0.80 power per hypothesis
min_n_for <- function(df, col, target = 0.80) {
  ok <- df[df[[col]] >= target, , drop = FALSE]
  if (nrow(ok) == 0) return(NA_integer_)
  as.integer(min(ok$N, na.rm = TRUE))
}

power_min_n <- list(
  H1  = min_n_for(power_surface, "power_H1"),
  H1a = min_n_for(power_surface, "power_H1a"),
  H1c = min_n_for(power_surface, "power_H1c"),
  H1d = min_n_for(power_surface, "power_H1d")
)

# Power surface by sigma_alpha at N=300
power_by_sigma_N300 <- lapply(sort(unique(power_surface$sigma_alpha)), function(sa) {
  sub <- power_surface[power_surface$sigma_alpha == sa &
                       power_surface$N == 300, ]
  if (nrow(sub) == 0) return(NULL)
  list(
    sigma_alpha = sa,
    power_H1  = mean(sub$power_H1,  na.rm = TRUE),
    power_H1a = mean(sub$power_H1a, na.rm = TRUE),
    power_H1c = mean(sub$power_H1c, na.rm = TRUE),
    power_H1d = mean(sub$power_H1d, na.rm = TRUE)
  )
})
power_by_sigma_N300 <- Filter(Negate(is.null), power_by_sigma_N300)

# State scenarios — summary per scenario
scen_summary <- lapply(c("3B", "3A", "J"), function(s) {
  sub <- state_scen[state_scen$scenario == s, ]
  if (nrow(sub) == 0) return(NULL)

  # Target definition
  target <- if (s == "3B") {
    sub$O <= 0.40 & sub$SIC > 0.50
  } else if (s == "3A") {
    sub$SIC <= 0.50
  } else {
    sub$O <= 0.40 & sub$SIC <= 0.50
  }

  list(
    scenario          = s,
    n                 = nrow(sub),
    n_matching_target = sum(target, na.rm = TRUE),
    frac_matching     = mean(target, na.rm = TRUE),
    classified_dist   = as.list(table(sub$classified))
  )
})
scen_summary <- Filter(Negate(is.null), scen_summary)

# -------------------------------------------------------------
# Assemble final JSON
# -------------------------------------------------------------
json <- list(
  metadata = list(
    project         = "STRATIM",
    version         = "0.1.0-protocol",
    series          = "SIC-PROTO-01",
    generated_at    = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
    generated_by    = "SIMULATION/code/05_export_results.R",
    provenance      = "Exported from CSV artifacts in SIMULATION/results/",
    n_files_loaded  = 6L,
    disclaimer      = paste(
      "All results are simulation-based and reflect properties of",
      "the design and model. No empirical data has been collected."
    )
  ),

  h5_identifiability = list(
    status           = h5_decision,
    n_cells          = nrow(h5_summary),
    n_replicates     = max(h5_raw$rep, na.rm = TRUE),
    min_corr         = h5_min_corr,
    max_corr         = h5_max_corr,
    summary_table    = h5_summary_records
  ),

  parameter_recovery = list(
    n_replicates = max(rec_summary$n, na.rm = TRUE),
    parameters   = rec_records
  ),

  recovery_boundary = list(
    by_sigma_alpha = recb_by_sigma
  ),

  power_surface = list(
    n_cells          = nrow(power_surface),
    n_replicates     = max(power_surface$n_success, na.rm = TRUE),
    min_N_for_0.80   = power_min_n,
    by_sigma_alpha   = power_by_sigma_N300,
    full_table       = df_to_records(power_surface)
  ),

  state_scenarios = list(
    summary       = scen_summary,
    full_example  = df_to_records(head(state_scen, 30))
  )
)

# -------------------------------------------------------------
# Write JSON
# -------------------------------------------------------------
if (!requireNamespace("jsonlite", quietly = TRUE)) {
  stop("Package 'jsonlite' is required. Install with: install.packages('jsonlite')")
}

json_str <- jsonlite::toJSON(json, auto_unbox = TRUE, pretty = TRUE,
                             null = "null", na = "null")
writeLines(json_str, output_file)

cat("\n=== Export complete ===\n")
cat("Output file:", output_file, "\n")
cat("File size:  ", file.info(output_file)$size, "bytes\n")

# -------------------------------------------------------------
# Post-write verification
# -------------------------------------------------------------
cat("\n=== Post-write verification ===\n")

# Re-read the JSON to confirm validity
reloaded <- jsonlite::fromJSON(output_file, simplifyVector = FALSE)
cat("  JSON parsed successfully.\n")
cat("  Sections: ", paste(names(reloaded), collapse = ", "), "\n")
cat("  H5 status: ", reloaded$h5_identifiability$status, "\n")
cat("  Power min-N H1:  ", reloaded$power_surface$min_N_for_0.80$H1, "\n")
cat("  Power min-N H1d: ", reloaded$power_surface$min_N_for_0.80$H1d, "\n")

# =============================================================
# End of 05_export_results.R
# =============================================================
