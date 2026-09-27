# =============================================================
# STRATIM — Simulation-Based Power Surface
# File: SIMULATION/code/03_power_surface.R
# Version: 0.1.0-protocol
# =============================================================
#
# Purpose:
#   Compute a Monte Carlo power surface, not a single MDE number.
#   The power of H1, H1a, H1c, and H1d depends jointly on N, ICC,
#   attrition, effect size, and sigma_alpha^2. A single number
#   would misrepresent this.
#
# Decision rule (Section 7.14):
#   - If a hypothesis is underpowered at the target N before
#     data collection, target N is increased, or the hypothesis
#     is demoted to secondary. This decision is made at design
#     stage, not after seeing data.
#
# Estimator:
#   lme4::lmer (REML) for speed. The full study uses Bayesian
#   HMC, but the power surface is a property of the design,
#   not of the specific estimator. lmer is adequate for
#   design-stage power estimation.
#
# =============================================================

suppressPackageStartupMessages({
  library(lme4)
  library(stats)
})

# --- Source DGP ---
source_ok <- FALSE
tryCatch({
  source("SIMULATION/code/00_dgp.R")
  source_ok <- TRUE
}, error = function(e) {
  tryCatch({
    source("00_dgp.R")
    source_ok <- TRUE
  }, error = function(e2) {
    stop("Could not source 00_dgp.R.")
  })
})

# --- Fit function (same as recovery, kept self-contained) ---
fit_power_model <- function(df) {
  tryCatch(
    lmer(
      SIC_t1 ~ SIC_t + E + R + G + ER + E2R + EG + (1 + E | id),
      data = df,
      REML = TRUE,
      control = lmerControl(
        optimizer = "bobyqa",
        optCtrl = list(maxfun = 1e5)
      )
    ),
    error = function(e) NULL
  )
}

# --- Check whether a coefficient is "detected" ---
# For power estimation, we use the Wald z-statistic from lmer.
# A coefficient is detected if |t| > 1.96 (two-sided, alpha = 0.05).
coefficient_detected <- function(fit, coef_name, alpha = 0.05) {
  if (is.null(fit)) return(FALSE)
  fe <- lme4::fixef(fit)
  if (!(coef_name %in% names(fe))) return(FALSE)
  se_all <- sqrt(diag(as.matrix(vcov(fit))))
  if (!(coef_name %in% names(se_all))) return(FALSE)
  z <- fe[coef_name] / se_all[coef_name]
  abs(z) > qnorm(1 - alpha / 2)
}

# --- Power grid ---
# Reduced grid for tractability on a laptop.
# Full study pre-registration uses the same grid but with more reps.
power_grid <- expand.grid(
  N             = c(100, 200, 300, 500),
  effect_E      = c(0.10, 0.20),  # alpha_0
  effect_ER     = c(0.05, 0.15),  # delta_1
  sigma_alpha   = c(0.02, 0.05, 0.10, 0.20),
  attrition     = c(0.10, 0.20),
  stringsAsFactors = FALSE
)

n_rep_per_cell <- 50

cat("\n")
cat("=====================================================\n")
cat("STRATIM — Power Surface\n")
cat("=====================================================\n")
cat("Grid size:          ", nrow(power_grid), "cells\n")
cat("Replicates per cell:", n_rep_per_cell, "\n")
cat("Total simulations:  ", nrow(power_grid) * n_rep_per_cell, "\n")
cat("\n")
cat("This may take a while. Progress will be reported every\n")
cat("5 cells.\n\n")

# --- Main loop ---
results <- vector("list", nrow(power_grid))

for (c_idx in seq_len(nrow(power_grid))) {
  cell <- power_grid[c_idx, ]

  detections <- matrix(FALSE,
                       nrow = n_rep_per_cell,
                       ncol = 4,
                       dimnames = list(NULL,
                                       c("H1", "H1a", "H1c", "H1d")))

  for (r in seq_len(n_rep_per_cell)) {
    params <- stratim_default_params()
    params$N         <- cell$N
    params$alpha_0   <- cell$effect_E
    params$delta_1   <- cell$effect_ER
    params$sigma_alpha <- cell$sigma_alpha
    params$attrition <- cell$attrition

    sim <- stratim_simulate_dgp(params,
                                seed = 50000 + c_idx * 1000 + r)
    df  <- stratim_dgp_to_long(sim)
    fit <- fit_power_model(df)

    if (!is.null(fit)) {
      # H1:  alpha_0 corresponds to -beta_E
      #      We test the E coefficient in the model.
      detections[r, "H1"] <- coefficient_detected(fit, "E")

      # H1a: delta_1 corresponds to ER
      detections[r, "H1a"] <- coefficient_detected(fit, "ER")

      # H1c: delta_2 corresponds to E2R
      detections[r, "H1c"] <- coefficient_detected(fit, "E2R")

      # H1d: sigma_alpha > 0 — check whether the random slope
      #      variance is estimated as non-zero.
      #      A simple check: is the random slope SD > 0.01?
      vc <- lme4::VarCorr(fit)
      sd_E <- tryCatch(
        as.numeric(attr(vc$id, "stddev")["E"]),
        error = function(e) NA_real_
      )
      detections[r, "H1d"] <- is.finite(sd_E) && sd_E > 0.01
    }
  }

  results[[c_idx]] <- data.frame(
    N            = cell$N,
    effect_E     = cell$effect_E,
    effect_ER    = cell$effect_ER,
    sigma_alpha = cell$sigma_alpha,
    attrition    = cell$attrition,
    power_H1     = mean(detections[, "H1"],  na.rm = TRUE),
    power_H1a    = mean(detections[, "H1a"], na.rm = TRUE),
    power_H1c    = mean(detections[, "H1c"], na.rm = TRUE),
    power_H1d    = mean(detections[, "H1d"], na.rm = TRUE),
    n_success    = sum(!is.na(detections[, "H1"])),
    stringsAsFactors = FALSE
  )

  if (c_idx %% 5 == 0 || c_idx == nrow(power_grid)) {
    cat("  Completed cell", c_idx, "of", nrow(power_grid), "\n")
  }
}

power_surface <- do.call(rbind, results)

# --- Summary ---
cat("\n")
cat("-----------------------------------------------------\n")
cat("Power surface summary\n")
cat("-----------------------------------------------------\n")

# Minimum N for 0.80 power, per hypothesis, across all other conditions
min_n_for <- function(df, col) {
  ok <- df[df[[col]] >= 0.80, , drop = FALSE]
  if (nrow(ok) == 0) return(NA_integer_)
  min(ok$N, na.rm = TRUE)
}

cat("Minimum N for 0.80 power:\n")
cat("  H1  (closure-to-erosion):    ", min_n_for(power_surface, "power_H1"),  "\n")
cat("  H1a (rehearsal moderation):  ", min_n_for(power_surface, "power_H1a"), "\n")
cat("  H1c (interaction intensif.): ", min_n_for(power_surface, "power_H1c"), "\n")
cat("  H1d (heterogeneity):         ", min_n_for(power_surface, "power_H1d"), "\n")
cat("-----------------------------------------------------\n")

# Warn about H1d
if (is.na(min_n_for(power_surface, "power_H1d"))) {
  cat("\nNOTE: H1d never reaches 0.80 power in the tested grid.\n")
  cat("This may indicate that 3 transitions per participant are\n")
  cat("insufficient to reliably detect sigma_alpha > 0.\n")
  cat("H1d may need to be demoted to secondary, or the design\n")
  cat("may need more waves.\n")
}

# --- Save ---
results_dir <- "SIMULATION/results"
if (!dir.exists(results_dir)) {
  dir.create(results_dir, recursive = TRUE)
}

out_file <- file.path(results_dir, "03_power_surface.csv")
write.csv(power_surface, out_file, row.names = FALSE)
cat("\nPower surface written to:", out_file, "\n")

# =============================================================
# End of 03_power_surface.R
# =============================================================
