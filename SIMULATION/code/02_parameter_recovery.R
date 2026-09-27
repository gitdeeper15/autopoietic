# =============================================================
# STRATIM — Parameter Recovery (H1, H1a, H1c, H1d)
# File: SIMULATION/code/02_parameter_recovery.R
# Version: 0.1.0-protocol
# =============================================================
#
# Purpose:
#   Test whether the pre-specified dynamic model can recover the
#   true parameters used in the DGP. This is a "parameter recovery"
#   study, not a power study. It answers: does the estimation
#   procedure recover phi, alpha_0, beta, gamma, delta_1, delta_2,
#   eta, sigma_alpha with acceptable bias and coverage?
#
# Estimator:
#   lme4::lmer (frequentist, REML) as a fast pre-Stan check.
#   Bayesian estimation (Stan/brms) is the primary framework
#   for the full study (Section 7.5). This script uses lmer for
#   speed and to identify obvious identifiability problems
#   before running Stan.
#
# Output:
#   - Per-replicate estimates
#   - Summary: bias, RMSE, coverage for each parameter
#
# =============================================================

suppressPackageStartupMessages({
  library(lme4)
  library(stats)
})

# --- Source the DGP ---
source_ok <- FALSE
tryCatch({
  source("SIMULATION/code/00_dgp.R")
  source_ok <- TRUE
}, error = function(e) {
  tryCatch({
    source("00_dgp.R")
    source_ok <- TRUE
  }, error = function(e2) {
    stop("Could not source 00_dgp.R. ",
         "Run this script from the repository root, ",
         "or from SIMULATION/code/.")
  })
})

# --- Fit the model to a long-format dataset ---
stratim_fit_recovery_model <- function(df) {
  lmer(
    SIC_t1 ~ SIC_t + E + R + G + ER + E2R + EG + (1 + E | id),
    data = df,
    REML = TRUE,
    control = lmerControl(
      optimizer = "bobyqa",
      optCtrl = list(maxfun = 2e5)
    )
  )
}

# --- Extract parameters from a fitted model ---
stratim_extract_params <- function(fit, true_params) {
  fe <- lme4::fixef(fit)
  vc <- lme4::VarCorr(fit)

  # lme4 parameterizes E with a coefficient beta_E.
  # True model: SIC_t1 = ... - alpha_i * E + ...
  # So alpha_0 ~= -beta_E.
  alpha_est <- -fe["E"]

  # Random slope SD for E is sigma_alpha
  id_vc <- vc$id
  sigma_alpha_est <- if (!is.null(id_vc)) {
    as.numeric(attr(id_vc, "stddev")["E"])
  } else {
    NA_real_
  }

  data.frame(
    param    = c("phi", "alpha_0", "beta", "gamma",
                 "delta_1", "delta_2", "eta", "sigma_alpha"),
    true     = c(true_params$phi, true_params$alpha_0,
                 true_params$beta, true_params$gamma,
                 true_params$delta_1, true_params$delta_2,
                 true_params$eta, true_params$sigma_alpha),
    estimate = c(
      fe["SIC_t"],
      alpha_est,
      fe["R"],
      fe["G"],
      fe["ER"],
      fe["E2R"],
      fe["EG"],
      sigma_alpha_est
    ),
    stringsAsFactors = FALSE
  )
}

# --- Run the recovery study ---
true_params <- stratim_default_params()
n_sim       <- 50
all_est     <- vector("list", n_sim)

cat("\n")
cat("=====================================================\n")
cat("STRATIM — Parameter Recovery\n")
cat("=====================================================\n")
cat("Design: N =", true_params$N,
    "| waves =", paste(true_params$waves, collapse = "/"),
    "| replicates =", n_sim, "\n")
cat("Estimator: lme4::lmer (REML)\n")
cat("\n")
cat("Running replicates...\n")

for (s in seq_len(n_sim)) {
  sim_s <- stratim_simulate_dgp(true_params, seed = 2000 + s)
  df_s  <- stratim_dgp_to_long(sim_s)

  fit_s <- tryCatch(
    stratim_fit_recovery_model(df_s),
    error = function(e) NULL
  )

  if (!is.null(fit_s)) {
    est_s <- tryCatch(
      stratim_extract_params(fit_s, true_params),
      error = function(e) NULL
    )
    if (!is.null(est_s)) {
      est_s$sim <- s
      all_est[[s]] <- est_s
    }
  }

  if (s %% 10 == 0) cat("  replicate", s, "of", n_sim, "\n")
}

recovery <- do.call(rbind, all_est)

# --- Summary ---
recovery_summary <- do.call(rbind, lapply(
  split(recovery, recovery$param),
  function(g) {
    true_val <- g$true[1]
    est      <- g$estimate
    data.frame(
      param      = g$param[1],
      true       = true_val,
      n          = length(est),
      mean_est   = mean(est, na.rm = TRUE),
      bias       = mean(est - true_val, na.rm = TRUE),
      rmse       = sqrt(mean((est - true_val)^2, na.rm = TRUE)),
      sd_est     = sd(est, na.rm = TRUE),
      stringsAsFactors = FALSE
    )
  }
))
rownames(recovery_summary) <- NULL

cat("\n")
cat("Recovery summary:\n")
cat("-----------------------------------------------------\n")
print(recovery_summary, row.names = FALSE)
cat("-----------------------------------------------------\n")

# --- Simple diagnostics ---
cat("\nDiagnostic notes:\n")
cat("-----------------------------------------------------\n")

# Bias > 30% of true value => concerning
bias_pct <- abs(recovery_summary$bias) /
  pmax(abs(recovery_summary$true), 1e-6) * 100

flagged <- recovery_summary$param[bias_pct > 30]
if (length(flagged) > 0) {
  cat("Parameters with |bias| > 30% of true value:\n")
  for (p in flagged) cat("  -", p, "\n")
} else {
  cat("No parameters show |bias| > 30% of true value.\n")
}

# sigma_alpha flag
sa_row <- recovery_summary[recovery_summary$param == "sigma_alpha", ]
if (nrow(sa_row) > 0 && !is.na(sa_row$mean_est)) {
  if (sa_row$mean_est < 0.3 * true_params$sigma_alpha) {
    cat("\nWARNING: sigma_alpha appears heavily underestimated.\n")
    cat("This may indicate that 3 transitions per participant are\n")
    cat("insufficient to recover between-individual heterogeneity.\n")
    cat("Consider reporting H1d as not testable in this design.\n")
  } else {
    cat("\nsigma_alpha recovery looks acceptable.\n")
  }
}

cat("-----------------------------------------------------\n")

# --- Save results ---
results_dir <- "SIMULATION/results"
if (!dir.exists(results_dir)) {
  dir.create(results_dir, recursive = TRUE)
}

write.csv(recovery,
          file.path(results_dir, "02_parameter_recovery_raw.csv"),
          row.names = FALSE)
write.csv(recovery_summary,
          file.path(results_dir, "02_parameter_recovery_summary.csv"),
          row.names = FALSE)

cat("\nRaw results:  ", file.path(results_dir,
    "02_parameter_recovery_raw.csv"), "\n")
cat("Summary:      ", file.path(results_dir,
    "02_parameter_recovery_summary.csv"), "\n")

# =============================================================
# End of 02_parameter_recovery.R
# =============================================================
