# =============================================================
# STRATIM — Tests for State Construction
# File: tests/testthat/test-state-construction.R
# Version: 0.1.0-protocol
# =============================================================
#
# Tests the state classification rules from Section 6.10
# (priority rule) and the region definitions from Section 3.2.
#
# =============================================================

# Reference implementation of the priority rule.
# This mirrors the specification in Section 6.10 exactly.
classify_state <- function(SIC, O, tau_SIC, tau_O) {
  if (SIC <= tau_SIC) {
    return("3A")
  }
  if (O <= tau_O) {
    return("3B")
  }
  if (O > 0) {
    return("1")
  }
  return("2")
}

test_that("SIC below threshold yields 3A regardless of O", {
  expect_equal(classify_state(SIC = 0.3, O = 0.9, tau_SIC = 0.5, tau_O = 0.4), "3A")
  expect_equal(classify_state(SIC = 0.3, O = 0.1, tau_SIC = 0.5, tau_O = 0.4), "3A")
  expect_equal(classify_state(SIC = 0.3, O = 0.0, tau_SIC = 0.5, tau_O = 0.4), "3A")
})

test_that("SIC above threshold and O below threshold yields 3B", {
  expect_equal(classify_state(SIC = 0.8, O = 0.2, tau_SIC = 0.5, tau_O = 0.4), "3B")
  expect_equal(classify_state(SIC = 0.6, O = 0.4, tau_SIC = 0.5, tau_O = 0.4), "3B")
})

test_that("SIC above threshold and O above threshold yields 1", {
  expect_equal(classify_state(SIC = 0.8, O = 0.7, tau_SIC = 0.5, tau_O = 0.4), "1")
})

test_that("priority rule: 3A wins over 3B when SIC is below threshold", {
  # This is the crux of the priority rule. If SIC <= tau_SIC,
  # classification is 3A even if O <= tau_O (which would
  # otherwise be 3B).
  expect_equal(classify_state(SIC = 0.4, O = 0.2, tau_SIC = 0.5, tau_O = 0.4), "3A")
})

test_that("J region is detected as joint closure (3A ∩ 3B criteria)", {
  # J is not produced by the priority classifier; it is the
  # intersection of low O and low SIC. Here we test the
  # membership criterion directly.
  is_J <- function(SIC, O, tau_SIC, tau_O) {
    SIC <= tau_SIC && O <= tau_O
  }
  expect_true(is_J(SIC = 0.3, O = 0.2, tau_SIC = 0.5, tau_O = 0.4))
  expect_false(is_J(SIC = 0.8, O = 0.2, tau_SIC = 0.5, tau_O = 0.4))
  expect_false(is_J(SIC = 0.3, O = 0.9, tau_SIC = 0.5, tau_O = 0.4))
})

test_that("classifier is a function of thresholds alone (deterministic)", {
  s1 <- classify_state(SIC = 0.6, O = 0.5, tau_SIC = 0.5, tau_O = 0.4)
  s2 <- classify_state(SIC = 0.6, O = 0.5, tau_SIC = 0.5, tau_O = 0.4)
  expect_equal(s1, s2)
})
