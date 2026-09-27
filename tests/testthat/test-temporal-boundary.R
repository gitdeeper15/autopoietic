# =============================================================
# STRATIM — Tests for Temporal Boundary (No Leakage)
# File: tests/testthat/test-temporal-boundary.R
# Version: 0.1.0-protocol
# =============================================================
#
# This is the most sensitive test file in the suite. It checks
# that E_it never incorporates closure events that occurred
# after time t. Leakage here would invalidate every downstream
# estimate.
#
# Section 7.1: E_it^{<= t} must use ONLY closure events up to
# and including time t.
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

test_that("E at time t does not depend on closure events after t", {
  source_dgp()
  waves <- c(0, 6, 12, 18)

  # Two series identical up to t=6, different afterwards
  S1 <- rep(0, 18); S1[1:6] <- 0.5; S1[7:18] <- 0.1
  S2 <- rep(0, 18); S2[1:6] <- 0.5; S2[7:18] <- 0.9

  E1 <- stratim_compute_E(S1, waves, "exponential", 0.3, 1.5)
  E2 <- stratim_compute_E(S2, waves, "exponential", 0.3, 1.5)

  # E at wave 6 must be identical
  expect_equal(E1[2], E2[2])
})

test_that("E at later waves DOES reflect earlier differences", {
  source_dgp()
  waves <- c(0, 6, 12, 18)

  S1 <- rep(0, 18); S1[1:6]  <- 0.5; S1[7:18] <- 0.1
  S2 <- rep(0, 18); S2[1:6]  <- 0.5; S2[7:18] <- 0.9

  E1 <- stratim_compute_E(S1, waves, "exponential", 0.3, 1.5)
  E2 <- stratim_compute_E(S2, waves, "exponential", 0.3, 1.5)

  # E at wave 18 should differ (events 7-18 differ)
  expect_true(!isTRUE(all.equal(E1[4], E2[4])))
})

test_that("E at time t equals manual computation on S[1:t]", {
  source_dgp()
  S <- runif(18, 0, 1)
  waves <- c(0, 6, 12, 18)
  lambda <- 0.3

  E <- stratim_compute_E(S, waves, "exponential", lambda, 1.5)

  # Manual computation for wave 6 (t = 6)
  t <- 6
  tau <- 1:t
  manual <- sum(exp(-lambda * (t - tau)) * S[tau])
  expect_equal(E[2], manual)
})

test_that("changing post-t closure does not alter E at t", {
  source_dgp()
  waves <- c(0, 6, 12, 18)

  S_base <- runif(18, 0, 1)

  # Modify only entries after t = 12
  S_mod <- S_base
  S_mod[13:18] <- S_mod[13:18] + 10

  E_base <- stratim_compute_E(S_base, waves, "exponential", 0.3, 1.5)
  E_mod  <- stratim_compute_E(S_mod,  waves, "exponential", 0.3, 1.5)

  # E at waves 0, 6, 12 must be identical
  expect_equal(E_base[1], E_mod[1])
  expect_equal(E_base[2], E_mod[2])
  expect_equal(E_base[3], E_mod[3])

  # E at wave 18 must differ
  expect_true(!isTRUE(all.equal(E_base[4], E_mod[4])))
})
