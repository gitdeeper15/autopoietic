# =============================================================
# STRATIM — State Scenarios Validation
# File: SIMULATION/code/04_state_scenarios.R
# Version: 0.1.0-protocol
# =============================================================
#
# Purpose:
#   Validate the state-construction rules from Section 6.10.
#   We construct synthetic data with KNOWN target regions
#   (3A, 3B, J) and check whether the classifier recovers
#   those regions correctly.
#
# Important:
#   - This script does NOT touch 00_dgp.R. The primary DGP
#     has been validated in earlier experiments and must
#     remain unchanged.
#   - O^objective is NOT derived from S_closure. In these
#     scenarios, O and SIC are independently generated.
#   - This is a pipeline validation, not a causal test.
#
# Scenarios:
#   3B: O_high, SIC_high   (objective closure with preserved SIC)
#   3A: O_high, SIC_low    (internal SIC erosion)
#   J:  O_low,  SIC_low    (joint closure)
#
# =============================================================

suppressPackageStartupMessages({
  library(stats)
})

# -------------------------------------------------------------
# Thresholds (fixed, from protocol Section 6.10)
# -------------------------------------------------------------
# In the real study, thresholds come from an independent
# calibration sample. Here, we use fixed values for the
# purpose of pipeline validation.

TAU_SIC <- 0.50
TAU_O   <- 0.40

# Margin around thresholds to avoid boundary effects
MARGIN  <- 0.15

# -------------------------------------------------------------
# Classifier (Section 6.10 priority rule)
# -------------------------------------------------------------
classify_state <- function(SIC, O, tau_SIC = TAU_SIC, tau_O = TAU_O) {
  # Priority rule:
  #   1. If SIC <= tau_SIC  -> 3A (regardless of O)
  #   2. Else if O <= tau_O -> 3B
  #   3. Else if O > 0      -> 1
  #   4. Else               -> 2
  ifelse(SIC <= tau_SIC, "3A",
    ifelse(O <= tau_O,   "3B",
      ifelse(O > 0,      "1", "2")))
}

# -------------------------------------------------------------
# Scenario generator
# -------------------------------------------------------------
generate_scenario <- function(scenario, N = 200, seed = NULL) {
  if (!is.null(seed)) set.seed(seed)

  if (scenario == "3B") {
    # O_high, SIC_high
    O   <- runif(N, TAU_O + MARGIN, 1.0)
    SIC <- runif(N, TAU_SIC + MARGIN, 1.0)
    # Note: 3B by definition has O <= tau_O. But the priority
    # classifier assigns 3B only when SIC > tau_SIC AND O <= tau_O.
    # To get "3B" from the priority classifier, we need O <= tau_O
    # AND SIC > tau_SIC.
    #
    # CORRECTION: O must be BELOW tau_O for 3B.
    O   <- runif(N, 0.0, TAU_O - MARGIN)
    SIC <- runif(N, TAU_SIC + MARGIN, 1.0)
  } else if (scenario == "3A") {
    # O_high, SIC_low
    # Priority rule: SIC <= tau_SIC -> 3A regardless of O.
    O   <- runif(N, TAU_O + MARGIN, 1.0)
    SIC <- runif(N, 0.0, TAU_SIC - MARGIN)
  } else if (scenario == "J") {
    # O_low, SIC_low
    # Priority rule: SIC <= tau_SIC -> 3A (not J).
    # J is the intersection region, not a priority-classified state.
    # We therefore track J as a separate membership test:
    #   J_true = (O <= tau_O) AND (SIC <= tau_SIC)
    O   <- runif(N, 0.0, TAU_O - MARGIN)
    SIC <- runif(N, 0.0, TAU_SIC - MARGIN)
  } else {
    stop("Unknown scenario: ", scenario)
  }

  data.frame(
    id        = seq_len(N),
    scenario  = scenario,
    O         = O,
    SIC       = SIC,
    O_low     = O <= TAU_O,
    SIC_low   = SIC <= TAU_SIC,
    J_true    = (O <= TAU_O) & (SIC <= TAU_SIC)
  )
}

# -------------------------------------------------------------
# Run all scenarios
# -------------------------------------------------------------
N <- 200

scenarios <- c("3B", "3A", "J")
results <- lapply(scenarios, function(s) {
  df <- generate_scenario(s, N = N, seed = 1234)
  df$classified <- classify_state(df$SIC, df$O)
  df
})
names(results) <- scenarios

# -------------------------------------------------------------
# Summary per scenario
# -------------------------------------------------------------
cat("\n")
cat("=====================================================\n")
cat("STRATIM — State Scenario Validation\n")
cat("=====================================================\n")
cat("N per scenario:", N, "\n")
cat("Thresholds: tau_SIC =", TAU_SIC, ", tau_O =", TAU_O, "\n")
cat("Margin:     ", MARGIN, "\n")
cat("\n")

for (s in scenarios) {
  df <- results[[s]]
  cat("-----------------------------------------------------\n")
  cat("Scenario:", s, "\n")
  cat("-----------------------------------------------------\n")
  cat("Target: ")

  if (s == "3B") {
    cat("3B (O <= tau_O AND SIC > tau_SIC)\n")
    target_ok <- df$O <= TAU_O & df$SIC > TAU_SIC
  } else if (s == "3A") {
    cat("3A (SIC <= tau_SIC)\n")
    target_ok <- df$SIC <= TAU_SIC
  } else {
    cat("J  (O <= tau_O AND SIC <= tau_SIC)\n")
    target_ok <- df$J_true
  }

  cat("Classifier output distribution:\n")
  print(table(df$classified))

  cat("\nFraction matching target:\n")
  cat(sprintf("  %.2f\n", mean(target_ok)))

  cat("\nCross-tabulation (classified x target_ok):\n")
  print(table(df$classified, target_ok))

  cat("\n")
}

# -------------------------------------------------------------
# Detailed validation
# -------------------------------------------------------------
cat("=====================================================\n")
cat("Validation checks\n")
cat("=====================================================\n\n")

# Check 1: 3B scenario
df_3B <- results[["3B"]]
frac_3B <- mean(df_3B$classified == "3B")
cat(sprintf("Check 1 — 3B scenario: fraction classified as 3B = %.2f\n", frac_3B))
cat("         Expected: > 0.95\n")
cat("         Status:  ", ifelse(frac_3B > 0.95, "PASS", "FAIL"), "\n\n")

# Check 2: 3A scenario
df_3A <- results[["3A"]]
frac_3A <- mean(df_3A$classified == "3A")
cat(sprintf("Check 2 — 3A scenario: fraction classified as 3A = %.2f\n", frac_3A))
cat("         Expected: > 0.95\n")
cat("         Status:  ", ifelse(frac_3A > 0.95, "PASS", "FAIL"), "\n\n")

# Check 3: J scenario
df_J <- results[["J"]]
frac_J_membership <- mean(df_J$J_true)
frac_J_as_3A       <- mean(df_J$classified == "3A")
cat(sprintf("Check 3 — J scenario:\n"))
cat(sprintf("         fraction satisfying J membership = %.2f\n", frac_J_membership))
cat(sprintf("         fraction classified as 3A      = %.2f\n", frac_J_as_3A))
cat("         Expected: J membership = 1.00\n")
cat("         Expected: classified as 3A = 1.00 (priority rule)\n")
cat("         Status:  ",
    ifelse(frac_J_membership > 0.95 && frac_J_as_3A > 0.95, "PASS", "FAIL"), "\n\n")

# Check 4: priority rule
# Verify that all SIC <= tau_SIC observations are classified as 3A
all_states <- do.call(rbind, results)
priority_ok <- all(
  (all_states$SIC <= TAU_SIC) == (all_states$classified == "3A")
)
cat(sprintf("Check 4 — Priority rule: SIC <= tau_SIC -> 3A\n"))
cat("         Status:  ", ifelse(priority_ok, "PASS", "FAIL"), "\n\n")

# -------------------------------------------------------------
# Save results
# -------------------------------------------------------------
results_dir <- "SIMULATION/results"
if (!dir.exists(results_dir)) dir.create(results_dir, recursive = TRUE)

all_df <- do.call(rbind, results)
write.csv(all_df,
          file.path(results_dir, "04_state_scenarios.csv"),
          row.names = FALSE)

cat("Results written to:",
    file.path(results_dir, "04_state_scenarios.csv"), "\n")

# =============================================================
# End of 04_state_scenarios.R
# =============================================================
