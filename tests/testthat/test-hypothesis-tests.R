# =============================================================
# STRATIM — Tests for Hypothesis Test Procedures
# File: tests/testthat/test-hypothesis-tests.R
# Version: 0.1.0-protocol
# =============================================================
#
# Tests the numerical procedures used to evaluate H1a, H1c,
# and H1d, and the ROPE-based decision rules for H1.
#
# These tests do NOT run full models. They test the
# deterministic numerical pieces that feed into the rules.
#
# =============================================================

# --- H1a: rehearsal moderation ---
h1a_supported <- function(delta1, ci_low, ci_high) {
  ci_low > 0
}

test_that("H1a is supported when delta_1 CI lies entirely above zero", {
  expect_true(h1a_supported(0.10, 0.03, 0.17))
})

test_that("H1a is not supported when delta_1 CI contains zero", {
  expect_false(h1a_supported(0.05, -0.02, 0.12))
})

# --- H1c: closure × rehearsal intensification ---
# Primary test at E*_ref:
#   delta_1 + 2 * delta_2 * E_star > 0
h1c_value <- function(delta1, delta2, E_star) {
  delta1 + 2 * delta2 * E_star
}

test_that("H1c value matches the cross-partial at E*_ref", {
  expect_equal(h1c_value(0.05, 0.03, 1.0), 0.11)
  expect_equal(h1c_value(0.05, 0.03, 2.0), 0.17)
})

test_that("H1c is supported when the posterior interval for the cross-partial is above zero", {
  # Simulate a posterior sample for delta1 + 2 delta2 E*
  set.seed(1)
  delta1 <- rnorm(1000, 0.05, 0.02)
  delta2 <- rnorm(1000, 0.03, 0.01)
  E_star <- 1.0
  cross  <- delta1 + 2 * delta2 * E_star
  ci <- quantile(cross, c(0.025, 0.975))
  expect_true(ci[1] > 0)
})

test_that("H1c is not supported when the cross-partial interval includes zero", {
  set.seed(2)
  delta1 <- rnorm(1000, 0.00, 0.05)
  delta2 <- rnorm(1000, 0.00, 0.03)
  E_star <- 1.0
  cross  <- delta1 + 2 * delta2 * E_star
  ci <- quantile(cross, c(0.025, 0.975))
  expect_false(ci[1] > 0)
})

# --- H1d: individual sensitivity heterogeneity ---
h1d_supported <- function(sigma2_alpha_ci_low) {
  sigma2_alpha_ci_low > 0
}

test_that("H1d is supported only when sigma^2_alpha CI excludes zero", {
  expect_true(h1d_supported(0.01))
  expect_false(h1d_supported(0.00))
  expect_false(h1d_supported(-0.02))
})

# --- LOO-CV kernel comparison (synthetic example) ---
# This is a light-weight check that the comparison logic is
# correct: a difference > 2 standard errors favors a kernel.
kernel_favored <- function(loo_diff, loo_se) {
  loo_diff > 2 * loo_se
}

test_that("Kernel comparison favors a kernel only when diff > 2 SE", {
  expect_true(kernel_favored(10, 3))
  expect_true(kernel_favored(7.1, 3.5))
  expect_false(kernel_favored(5, 3))
  expect_false(kernel_favored(0, 3))
})

# --- Nested model comparison (illustrative) ---
# The additive-vs-interaction comparison must not be confused
# with a test of significance. It uses predictive accuracy.
compare_additive_interaction <- function(loo_add, se_add, loo_int, se_int) {
  diff <- loo_int - loo_add
  se   <- sqrt(se_add^2 + se_int^2)
  if (diff >  2 * se) return("interaction_better")
  if (diff < -2 * se) return("additive_better")
  return("inconclusive")
}

test_that("Additive vs interaction comparison handles all three cases", {
  expect_equal(compare_additive_interaction(100, 3, 115, 3), "interaction_better")
  expect_equal(compare_additive_interaction(115, 3, 100, 3), "additive_better")
  expect_equal(compare_additive_interaction(100, 3, 102, 3), "inconclusive")
})
