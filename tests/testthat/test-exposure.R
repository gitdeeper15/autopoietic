# =============================================================
# STRATIM — Tests for Exposure Construction
# File: tests/testthat/test-exposure.R
# Version: 0.1.0-protocol
# =============================================================
#
# Tests the kernel-weighted construction of E_it. Verifies
# both the numerical behavior and the boundary conditions
# that are essential to avoid temporal leakage.
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

test_that("E at wave 0 is exactly zero", {
  source_dgp()
  S <- rep(1, 18)
  E <- stratim_compute_E(S, waves = c(0, 6, 12, 18),
                         kernel = "exponential",
                         lambda = 0.3, rho = 1.5)
  expect_equal(E[1], 0)
})

test_that("E is non-negative for non-negative closure series", {
  source_dgp()
  S <- runif(18, 0, 1)
  E <- stratim_compute_E(S, waves = c(0, 6, 12, 18),
                         kernel = "exponential",
                         lambda = 0.3, rho = 1.5)
  expect_true(all(E >= 0))
})

test_that("E is monotone non-decreasing in closure severity", {
  source_dgp()
  S_low  <- rep(0.1, 18)
  S_high <- rep(0.9, 18)
  E_low  <- stratim_compute_E(S_low,  c(0, 6, 12, 18), "exponential", 0.3, 1.5)
  E_high <- stratim_compute_E(S_high, c(0, 6, 12, 18), "exponential", 0.3, 1.5)

  expect_true(all(E_high[-1] > E_low[-1]))
})

test_that("E grows with number of observed months (all else equal)", {
  source_dgp()
  S <- rep(0.5, 18)

  # Manual: sum of weights × 0.5 for waves at 0, 6, 12, 18
  E <- stratim_compute_E(S, c(0, 6, 12, 18), "exponential", 0.3, 1.5)

  # By construction, E at wave 18 must exceed E at wave 6
  # (unless kernel weights are zero, which they are not).
  expect_true(E[4] > E[2])
  expect_true(E[3] > E[2])
})

test_that("exponential kernel with large lambda ignores far past", {
  source_dgp()
  # Only month 1 has closure; measure E at wave 6 and 18
  S <- rep(0, 18)
  S[1] <- 1.0

  E_fast <- stratim_compute_E(S, c(0, 6, 12, 18), "exponential", 5.0, 1.5)
  # With lambda = 5, weight at distance 5 is exp(-25), essentially zero
  expect_true(E_fast[2] < 1e-6)
  expect_true(E_fast[4] < 1e-6)
})

test_that("power-law kernel retains more memory than exponential", {
  source_dgp()
  S <- rep(0, 18); S[1] <- 1.0

  E_exp <- stratim_compute_E(S, c(0, 6, 12, 18), "exponential", 0.3, 1.5)
  E_pow <- stratim_compute_E(S, c(0, 6, 12, 18), "powerlaw",    0.3, 1.5)

  # At wave 18, power-law should still reflect the early event
  expect_true(E_pow[4] > E_exp[4])
})
