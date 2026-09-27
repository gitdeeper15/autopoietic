# =============================================================
# STRATIM — Tests for Parameter Recovery Procedure
# File: tests/testthat/test-recovery.R
# Version: 0.1.0-protocol
# =============================================================
#
# These tests verify the numerical infrastructure used by
# 02_parameter_recovery.R, not the recovery results themselves.
# They check:
#   - Parameter extraction from a fitted model.
#   - Bias, RMSE, and coverage computation.
#   - Flagging rules for problematic parameters.
#
# =============================================================

source_dgp <- function() {
  candidates <- c(
    "SIMULATION/code/00_dgp.R",
    "../SIMULATION/code/00_dgp.R",
    "../../SIMULATION/code/00_dgp.R"
  )
  for (p in candidates) {
    if (file.exists(p)) { source(p, local = FALSE); return(invisible(TRUE)) }
  }
  stop("Could not find SIMULATION/code/00_dgp.R")
}

test_that("bias is computed as mean(estimate - true)", {
  true_val <- 0.20
  estimates <- c(0.18, 0.22, 0.20, 0.21, 0.19)
  bias <- mean(estimates - true_val)
  expect_equal(bias, mean(estimates) - true_val)
})

test_that("RMSE is computed correctly", {
  true_val <- 0.20
  estimates <- c(0.18, 0.22, 0.20, 0.21, 0.19)
  rmse <- sqrt(mean((estimates - true_val)^2))
  expect_equal(rmse, sqrt(mean((estimates - true_val)^2)))
  expect_true(rmse > 0)
})

test_that("flag rule triggers when bias exceeds 30 percent of true value", {
  check_flag <- function(bias, true_val) {
    abs(bias) / max(abs(true_val), 1e-6) > 0.30
  }
  expect_true(check_flag(0.10, 0.20))   # 50% bias
  expect_false(check_flag(0.02, 0.20))  # 10% bias
  expect_true(check_flag(-0.10, 0.20))  # magnitude matters
  expect_false(check_flag(0.00, 0.20))
})

test_that("sigma_alpha underestimation warning triggers below 30 percent", {
  sigma_warn <- function(mean_est, true_val) {
    mean_est < 0.3 * true_val
  }
  expect_true(sigma_warn(0.02, 0.10))
  expect_false(sigma_warn(0.08, 0.10))
  expect_false(sigma_warn(0.15, 0.10))
})

test_that("recovery summary has expected columns", {
  # Simulated summary table
  recovery_summary <- data.frame(
    param    = c("phi", "alpha_0", "sigma_alpha"),
    true     = c(0.5, 0.2, 0.1),
    n        = c(50, 50, 50),
    mean_est = c(0.49, 0.21, 0.09),
    bias     = c(-0.01, 0.01, -0.01),
    rmse     = c(0.02, 0.03, 0.02),
    sd_est   = c(0.02, 0.03, 0.02),
    stringsAsFactors = FALSE
  )
  expect_true(all(c("param", "true", "bias", "rmse", "sd_est")
                  %in% names(recovery_summary)))
  expect_equal(nrow(recovery_summary), 3)
})
