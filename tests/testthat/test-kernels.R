# =============================================================
# STRATIM — Tests for Kernel Functions
# File: tests/testthat/test-kernels.R
# Version: 0.1.0-protocol
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

test_that("exponential kernel equals 1 at delta_t = 0", {
  source_dgp()
  expect_equal(stratim_kernel_weights(0, "exponential", lambda = 0.3), 1)
})

test_that("power-law kernel equals 1 at delta_t = 0", {
  source_dgp()
  expect_equal(stratim_kernel_weights(0, "powerlaw", rho = 1.5), 1)
})

test_that("exponential kernel is monotonically decreasing in delta_t", {
  source_dgp()
  d <- seq(0, 18, by = 1)
  w <- stratim_kernel_weights(d, "exponential", lambda = 0.3)
  expect_true(all(diff(w) < 0))
})

test_that("power-law kernel is monotonically decreasing in delta_t", {
  source_dgp()
  d <- seq(0, 18, by = 1)
  w <- stratim_kernel_weights(d, "powerlaw", rho = 1.5)
  expect_true(all(diff(w) < 0))
})

test_that("exponential kernel with larger lambda decays faster", {
  source_dgp()
  d <- 5
  w_slow <- stratim_kernel_weights(d, "exponential", lambda = 0.1)
  w_fast <- stratim_kernel_weights(d, "exponential", lambda = 1.0)
  expect_true(w_fast < w_slow)
})

test_that("power-law kernel with larger rho decays faster", {
  source_dgp()
  d <- 5
  w_slow <- stratim_kernel_weights(d, "powerlaw", rho = 0.5)
  w_fast <- stratim_kernel_weights(d, "powerlaw", rho = 2.5)
  expect_true(w_fast < w_slow)
})

test_that("unknown kernel raises an error", {
  source_dgp()
  expect_error(stratim_kernel_weights(1, "unknown_kernel"),
               "Unknown kernel")
})

test_that("power-law kernel has heavier tail than exponential at same scale", {
  source_dgp()
  # Compare decay at large distance
  d_large <- 17
  w_exp <- stratim_kernel_weights(d_large, "exponential", lambda = 0.3)
  w_pow <- stratim_kernel_weights(d_large, "powerlaw", rho = 1.5)
  expect_true(w_pow > w_exp)
})
