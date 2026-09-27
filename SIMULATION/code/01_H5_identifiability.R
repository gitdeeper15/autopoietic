# =============================================================
# STRATIM — H5 Kernel Identifiability Check
# File: SIMULATION/code/01_H5_identifiability.R
# Version: 0.1.0-protocol
# =============================================================

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

lambda_vals <- c(0.10, 0.30, 0.50, 1.00)
rho_vals    <- c(0.50, 1.00, 1.50, 2.50)
n_rep       <- 200
waves       <- c(0, 6, 12, 18)

grid <- expand.grid(
  lambda = lambda_vals,
  rho    = rho_vals,
  rep    = seq_len(n_rep),
  stringsAsFactors = FALSE
)

results <- vector("list", nrow(grid))

for (k in seq_len(nrow(grid))) {
  set.seed(1000 + grid$rep[k])

  z <- numeric(18); z[1] <- rnorm(1)
  for (t in 2:18) z[t] <- 0.7 * z[t - 1] + rnorm(1, 0, 0.7)
  S_closure <- plogis(z)

  E_exp <- stratim_compute_E(S_closure, waves, "exponential",
                             grid$lambda[k], 0)
  E_pow <- stratim_compute_E(S_closure, waves, "powerlaw",
                             0, grid$rho[k])

  if (max(E_exp) > 0) E_exp <- E_exp / max(E_exp)
  if (max(E_pow) > 0) E_pow <- E_pow / max(E_pow)

  E_exp_w <- E_exp[-1]
  E_pow_w <- E_pow[-1]

  results[[k]] <- data.frame(
    lambda  = grid$lambda[k],
    rho     = grid$rho[k],
    rep     = grid$rep[k],
    corr    = stats::cor(E_exp_w, E_pow_w),
    maxdiff = max(abs(E_exp_w - E_pow_w)),
    l2      = sqrt(sum((E_exp_w - E_pow_w)^2))
  )
}

res <- do.call(rbind, results)

# --- Summary using tapply (avoids aggregate dimension issues) ---
cells <- unique(res[, c("lambda", "rho")])
summary_flat <- data.frame(
  lambda         = cells$lambda,
  rho            = cells$rho,
  median_corr    = NA_real_,
  median_maxdiff = NA_real_,
  median_l2      = NA_real_
)

for (i in seq_len(nrow(cells))) {
  sel <- res$lambda == cells$lambda[i] & res$rho == cells$rho[i]
  summary_flat$median_corr[i]    <- median(res$corr[sel])
  summary_flat$median_maxdiff[i] <- median(res$maxdiff[sel])
  summary_flat$median_l2[i]      <- median(res$l2[sel])
}

summary_flat <- summary_flat[order(-summary_flat$median_corr), ]
rownames(summary_flat) <- NULL

cat("\n")
cat("=====================================================\n")
cat("STRATIM — H5 Kernel Identifiability Check\n")
cat("=====================================================\n")
cat("Design: 18 months, waves at 0/6/12/18\n")
cat("Replicates per cell:", n_rep, "\n")
cat("Parameter grid:\n")
cat("  lambda (exponential):", paste(lambda_vals, collapse = ", "), "\n")
cat("  rho    (power-law):   ", paste(rho_vals, collapse = ", "), "\n")
cat("\n")
cat("Results by cell (median across replicates):\n")
cat("-----------------------------------------------------\n")
print(summary_flat, row.names = FALSE)
cat("-----------------------------------------------------\n")

max_corr <- max(summary_flat$median_corr)
min_corr <- min(summary_flat$median_corr)

cat("\n")
cat("Decision summary:\n")
cat("-----------------------------------------------------\n")

if (min_corr > 0.95) {
  cat("All cells have median correlation > 0.95.\n")
  cat("=> The 18-month, 4-wave design CANNOT distinguish\n")
  cat("   exponential from power-law kernels.\n")
  cat("=> H5 should be reported as 'not testable within the window'\n")
  cat("   regardless of sample size.\n")
} else if (max_corr < 0.90) {
  cat("All cells have median correlation < 0.90.\n")
  cat("=> The design CAN distinguish the two kernels across\n")
  cat("   the entire parameter grid.\n")
  cat("=> H5 remains testable for all (lambda, rho) combinations.\n")
} else {
  cat("Some cells have median correlation > 0.95 (indistinguishable),\n")
  cat("others have median correlation < 0.90 (distinguishable).\n")
  cat("=> H5 is testable ONLY in the distinguishable regions.\n")
}
cat("-----------------------------------------------------\n")

results_dir <- "SIMULATION/results"
if (!dir.exists(results_dir)) dir.create(results_dir, recursive = TRUE)

write.csv(res, file.path(results_dir, "01_H5_identifiability.csv"),
          row.names = FALSE)
write.csv(summary_flat,
          file.path(results_dir, "01_H5_identifiability_summary.csv"),
          row.names = FALSE)

cat("\nFull results written to:",
    file.path(results_dir, "01_H5_identifiability.csv"), "\n")
cat("Summary written to:",
    file.path(results_dir, "01_H5_identifiability_summary.csv"), "\n")
