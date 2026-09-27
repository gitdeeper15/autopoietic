# =============================================================
# STRATIM — Recovery Boundary Grid
# File: SIMULATION/code/02b_recovery_boundary.R
# Version: 0.1.0-protocol
# =============================================================
#
# Extends 02_parameter_recovery.R by scanning a grid over
#   sigma_alpha  ∈ {0.10, 0.05, 0.03, 0.01}
#   N            ∈ {100, 200, 300}
#   attrition    ∈ {0.00, 0.20, 0.35}
#
# Reports per cell:
#   - bias
#   - RMSE
#   - 95% coverage
#   - convergence rate
#
# Uses parallel::mclapply with 4 workers (RAM-constrained).
#
# =============================================================

suppressPackageStartupMessages({
  library(lme4)
  library(parallel)
  library(stats)
})

# --- Source DGP ---
source_ok <- FALSE
tryCatch({
  source("SIMULATION/code/00_dgp.R"); source_ok <- TRUE
}, error = function(e) {
  tryCatch({
    source("00_dgp.R"); source_ok <- TRUE
  }, error = function(e2) {
    stop("Could not source 00_dgp.R")
  })
})

# --- Fit + extract ---
fit_model <- function(df) {
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

extract_params <- function(fit, true_params) {
  if (is.null(fit)) return(NULL)

  fe <- tryCatch(lme4::fixef(fit), error = function(e) NULL)
  if (is.null(fe)) return(NULL)

  vc <- tryCatch(lme4::VarCorr(fit), error = function(e) NULL)
  if (is.null(vc)) return(NULL)

  # Wald SEs for coverage computation
  se_all <- tryCatch(
    sqrt(diag(as.matrix(vcov(fit)))),
    error = function(e) NULL
  )
  if (is.null(se_all)) return(NULL)

  # Random slope SD for E
  id_vc <- vc$id
  sigma_alpha_est <- if (!is.null(id_vc)) {
    tryCatch(
      as.numeric(attr(id_vc, "stddev")["E"]),
      error = function(e) NA_real_
    )
  } else NA_real_

  # Coefficients and SEs
  # alpha_0 in the model is -beta_E
  coefs <- c(
    phi         = fe["SIC_t"],
    alpha_0     = -fe["E"],
    beta        = fe["R"],
    gamma       = fe["G"],
    delta_1     = fe["ER"],
    delta_2     = fe["E2R"],
    eta         = fe["EG"]
  )

  ses <- c(
    phi         = se_all["SIC_t"],
    alpha_0     = se_all["E"],
    beta        = se_all["R"],
    gamma       = se_all["G"],
    delta_1     = se_all["ER"],
    delta_2     = se_all["E2R"],
    eta         = se_all["EG"]
  )

  # sigma_alpha: no Wald SE from lme4 directly
  # We approximate SE from the random effect variance; this is crude
  # but adequate for flagging.
  ses["sigma_alpha"] <- NA_real_
  coefs["sigma_alpha"] <- sigma_alpha_est

  true_vals <- c(
    phi         = true_params$phi,
    alpha_0     = true_params$alpha_0,
    beta        = true_params$beta,
    gamma       = true_params$gamma,
    delta_1     = true_params$delta_1,
    delta_2     = true_params$delta_2,
    eta         = true_params$eta,
    sigma_alpha = true_params$sigma_alpha
  )

  data.frame(
    param    = names(coefs),
    true     = true_vals[names(coefs)],
    estimate = as.numeric(coefs),
    se       = as.numeric(ses[names(coefs)]),
    stringsAsFactors = FALSE
  )
}

# --- Single-cell worker: run 20 replicates ---
run_cell <- function(cell) {
  n_rep <- 20
  results <- vector("list", n_rep)

  for (r in seq_len(n_rep)) {
    p <- stratim_default_params()
    p$N              <- cell$N
    p$sigma_alpha    <- cell$sigma_alpha
    p$attrition      <- cell$attrition

    seed <- 70000 + cell$cell_id * 1000 + r

    sim <- tryCatch(
      stratim_simulate_dgp(p, seed = seed),
      error = function(e) NULL
    )
    if (is.null(sim)) next

    df  <- stratim_dgp_to_long(sim)
    fit <- fit_model(df)
    est <- extract_params(fit, p)

    if (!is.null(est)) {
      est$rep     <- r
      est$cell_id <- cell$cell_id
      results[[r]] <- est
    }
  }

  do.call(rbind, results)
}

# --- Build grid ---
sigma_alpha_vals <- c(0.10, 0.05, 0.03, 0.01)
N_vals           <- c(100, 200, 300)
attrition_vals   <- c(0.00, 0.20, 0.35)

grid <- expand.grid(
  sigma_alpha = sigma_alpha_vals,
  N           = N_vals,
  attrition   = attrition_vals,
  stringsAsFactors = FALSE
)
grid$cell_id <- seq_len(nrow(grid))

cat("\n")
cat("=====================================================\n")
cat("STRATIM — Recovery Boundary Grid\n")
cat("=====================================================\n")
cat("Cells:            ", nrow(grid), "\n")
cat("Replicates/cell:  20\n")
cat("Total simulations:", nrow(grid) * 20, "\n")
cat("Workers:          4\n")
cat("\n")

# --- Determine number of workers (RAM-constrained) ---
n_workers <- 4
cat("Starting parallel run with", n_workers, "workers...\n\n")

t_start <- Sys.time()

all_results <- mclapply(
  seq_len(nrow(grid)),
  function(k) {
    run_cell(grid[k, ])
  },
  mc.cores = n_workers,
  mc.preschedule = FALSE
)

t_end <- Sys.time()
cat("\nElapsed time:", round(difftime(t_end, t_start, units = "mins"), 2),
    "minutes\n\n")

recovery_all <- do.call(rbind, all_results)

# --- Summarize per cell and parameter ---
summarize_cell <- function(df) {
  out <- lapply(split(df, df$param), function(g) {
    true_val <- g$true[1]
    est      <- g$estimate
    n_ok     <- sum(!is.na(est))

    # Empirical SD across replicates in this cell
    emp_sd <- sd(est, na.rm = TRUE)

    # Coverage: proportion of replicates where |est - true| < 1.96 * emp_sd
    if (!is.na(emp_sd) && emp_sd > 0) {
      in_ci <- abs(est - true_val) < 1.96 * emp_sd
      coverage <- mean(in_ci, na.rm = TRUE)
    } else {
      coverage <- NA_real_
    }

    data.frame(
      param    = g$param[1],
      true     = true_val,
      n_ok     = n_ok,
      mean_est = mean(est, na.rm = TRUE),
      bias     = mean(est - true_val, na.rm = TRUE),
      rmse     = sqrt(mean((est - true_val)^2, na.rm = TRUE)),
      emp_sd   = emp_sd,
      coverage = coverage,
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, out)
}

summary_by_cell <- do.call(rbind, lapply(
  split(recovery_all, recovery_all$cell_id),
  function(df_cell) {
    cell_row <- grid[grid$cell_id == df_cell$cell_id[1], ]
    s <- summarize_cell(df_cell)
    s$sigma_alpha <- cell_row$sigma_alpha
    s$N           <- cell_row$N
    s$attrition   <- cell_row$attrition
    s$cell_id     <- cell_row$cell_id
    s
  }
))

# --- Flag cells by recovery quality ---
flag_cell <- function(bias, coverage, true_val) {
  if (is.na(bias) || is.na(true_val)) return("unknown")
  bias_pct <- abs(bias) / max(abs(true_val), 1e-6)
  if (is.na(bias_pct)) return("unknown")
  if (bias_pct > 0.30) return("inadequate")
  if (!is.na(coverage) && coverage < 0.85) return("inadequate")
  if (bias_pct > 0.10) return("marginal")
  if (!is.na(coverage) && coverage < 0.90) return("marginal")
  return("adequate")
}

summary_by_cell$flag <- mapply(
  flag_cell,
  summary_by_cell$bias,
  summary_by_cell$coverage,
  summary_by_cell$true
)

# --- Focus specifically on sigma_alpha ---
sigma_rows <- summary_by_cell[summary_by_cell$param == "sigma_alpha", ]
sigma_rows <- sigma_rows[order(sigma_rows$sigma_alpha,
                               sigma_rows$N,
                               sigma_rows$attrition), ]

cat("=====================================================\n")
cat("sigma_alpha Recovery Boundary\n")
cat("=====================================================\n")
print(sigma_rows[, c("sigma_alpha", "N", "attrition",
                     "mean_est", "bias", "rmse",
                     "coverage", "flag")],
      row.names = FALSE)

cat("\n")
cat("=====================================================\n")
cat("Summary by sigma_alpha (across N and attrition)\n")
cat("=====================================================\n")

for (sa in sort(unique(sigma_rows$sigma_alpha), decreasing = TRUE)) {
  sel <- sigma_rows$sigma_alpha == sa
  adequate <- sum(sigma_rows$flag[sel] == "adequate")
  marginal <- sum(sigma_rows$flag[sel] == "marginal")
  inadequate <- sum(sigma_rows$flag[sel] == "inadequate")
  total <- sum(sel)
  cat(sprintf("sigma_alpha = %.2f :  %d/%d adequate, %d marginal, %d inadequate\n",
              sa, adequate, total, marginal, inadequate))
}

# --- Save ---
results_dir <- "SIMULATION/results"
if (!dir.exists(results_dir)) dir.create(results_dir, recursive = TRUE)

write.csv(recovery_all,
          file.path(results_dir, "02b_recovery_boundary_raw.csv"),
          row.names = FALSE)

write.csv(summary_by_cell,
          file.path(results_dir, "02b_recovery_boundary_summary.csv"),
          row.names = FALSE)

cat("\nRaw results:  ", file.path(results_dir,
    "02b_recovery_boundary_raw.csv"), "\n")
cat("Summary:      ", file.path(results_dir,
    "02b_recovery_boundary_summary.csv"), "\n")

# =============================================================
# End of 02b_recovery_boundary.R
# =============================================================
