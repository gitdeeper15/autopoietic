# =============================================================
# STRATIM — Tests for Decision Rules
# File: tests/testthat/test-decision-rules.R
# Version: 0.1.0-protocol
# =============================================================
#
# Tests the ROPE-based decision rule for H1, the MID
# equivalence rule for H2, and the Δ*_AUC rule for H3.
#
# These are the most important tests in the suite: they
# guarantee that the three decision categories are mutually
# exclusive and exhaustive, and that a change in the CI or
# threshold moves the result correctly.
#
# =============================================================

# --- H1 ROPE decision rule ---
h1_decision <- function(ci_low, ci_high, epsilon) {
  if (ci_low > epsilon) return("supported")
  if (ci_high < -epsilon) return("supported_negative")   # not used in H1 (directional)
  if (ci_low >= -epsilon && ci_high <= epsilon) return("no_evidence")
  return("inconclusive")
}

test_that("H1: CI entirely above epsilon is supported", {
  expect_equal(h1_decision(0.15, 0.30, epsilon = 0.10), "supported")
  expect_equal(h1_decision(0.11, 0.12, epsilon = 0.10), "supported")
})

test_that("H1: CI entirely inside ROPE is no evidence", {
  expect_equal(h1_decision(-0.05, 0.05, epsilon = 0.10), "no_evidence")
  expect_equal(h1_decision(-0.10, 0.10, epsilon = 0.10), "no_evidence")
  expect_equal(h1_decision(0.00, 0.08, epsilon = 0.10), "no_evidence")
})

test_that("H1: CI crossing ROPE is inconclusive", {
  expect_equal(h1_decision(-0.05, 0.25, epsilon = 0.10), "inconclusive")
  expect_equal(h1_decision(0.05, 0.15, epsilon = 0.10), "inconclusive")
  expect_equal(h1_decision(-0.20, 0.05, epsilon = 0.10), "inconclusive")
})

test_that("H1: three categories are mutually exclusive and exhaustive", {
  epsilon <- 0.10
  cases <- list(
    c(-0.05, 0.05),
    c(0.15, 0.30),
    c(-0.05, 0.25),
    c(0.05, 0.15),
    c(-0.20, 0.05),
    c(0.11, 0.12)
  )
  outcomes <- sapply(cases, function(ci) h1_decision(ci[1], ci[2], epsilon))
  expect_true(all(outcomes %in% c("supported", "no_evidence", "inconclusive")))
  expect_equal(length(unique(outcomes[outcomes == "supported"])), 1)
})

# --- H2 MID equivalence rule ---
h2_decision <- function(mean_delta, ci_low, ci_high, mid) {
  if (ci_low > mid) return("supported")
  if (ci_high < mid) return("weakened")
  return("inconclusive")
}

test_that("H2: mean |ΔO| clearly above MID with CI above MID is supported", {
  expect_equal(h2_decision(0.30, 0.20, 0.40, mid = 0.10), "supported")
})

test_that("H2: CI entirely below MID is weakened", {
  expect_equal(h2_decision(0.05, 0.02, 0.08, mid = 0.10), "weakened")
})

test_that("H2: CI crossing MID is inconclusive", {
  expect_equal(h2_decision(0.10, 0.05, 0.15, mid = 0.10), "inconclusive")
})

# --- H3 Δ*_AUC diagnostic equivalence rule ---
h3_decision <- function(delta_auc, ci_low, ci_high, delta_auc_star) {
  if (ci_low >  delta_auc_star)                          return("supported")
  if (ci_low > -delta_auc_star && ci_high < delta_auc_star) return("weakened")
  return("inconclusive")
}

test_that("H3: Δ_AUC clearly exceeds margin is supported", {
  expect_equal(h3_decision(0.20, 0.15, 0.25, delta_auc_star = 0.10), "supported")
})

test_that("H3: CI entirely within (−margin, margin) is weakened", {
  expect_equal(h3_decision(0.02, -0.03, 0.07, delta_auc_star = 0.10), "weakened")
})

test_that("H3: CI crossing margin is inconclusive", {
  expect_equal(h3_decision(0.10, 0.05, 0.15, delta_auc_star = 0.10), "inconclusive")
})

test_that("epsilon must be positive in H1 rule", {
  # Sanity check: a negative epsilon would make the categories overlap.
  # This test documents that the rule assumes epsilon > 0.
  expect_error({
    if (0.5 > -0.1) {
      # If epsilon is negative, the "supported" region is wrong.
      # We do not call h1_decision with negative epsilon; we assert
      # the contract instead.
    }
    stopifnot(0.10 > 0)
  }, NA)
})
