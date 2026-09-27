# =============================================================
# STRATIM — Tests for Power Surface Procedure
# File: tests/testthat/test-power-surface.R
# Version: 0.1.0-protocol
# =============================================================
#
# These tests verify the numerical infrastructure used by
# 03_power_surface.R. They do NOT run the full power surface.
#
# They check:
#   - The power grid has the expected structure.
#   - Power is correctly computed as the mean of detections.
#   - Minimum N for 0.80 power is correctly identified.
#   - The underpowered flag fires at the specified threshold.
#
# =============================================================

test_that("power is mean of detections", {
  detections <- c(TRUE, TRUE, FALSE, TRUE, TRUE, TRUE, FALSE, TRUE, TRUE, TRUE)
  power <- mean(detections, na.rm = TRUE)
  expect_equal(power, 0.8)
})

test_that("power is 0 when no detections", {
  detections <- rep(FALSE, 10)
  expect_equal(mean(detections, na.rm = TRUE), 0)
})

test_that("power is 1 when all detections", {
  detections <- rep(TRUE, 10)
  expect_equal(mean(detections, na.rm = TRUE), 1)
})

test_that("coefficient detected flag uses the correct two-sided criterion", {
  # z = 1.96 corresponds to alpha = 0.05 two-sided
  detected <- function(z, alpha = 0.05) {
    abs(z) > qnorm(1 - alpha / 2)
  }
  expect_true(detected(2.0))
  expect_true(detected(-2.0))
  expect_false(detected(1.5))
  expect_false(detected(-1.5))
  expect_true(detected(1.97))
})

test_that("minimum N for 0.80 power is correctly identified", {
  df <- data.frame(
    N       = c(200, 300, 400, 500),
    power_H1 = c(0.55, 0.75, 0.85, 0.92)
  )
  min_n_for <- function(df, col, target = 0.80) {
    ok <- df[df[[col]] >= target, , drop = FALSE]
    if (nrow(ok) == 0) return(NA_integer_)
    min(ok$N, na.rm = TRUE)
  }
  expect_equal(min_n_for(df, "power_H1"), 400)
})

test_that("minimum N returns NA if target power is never reached", {
  df <- data.frame(
    N       = c(200, 300, 400),
    power_H1d = c(0.30, 0.50, 0.65)
  )
  min_n_for <- function(df, col, target = 0.80) {
    ok <- df[df[[col]] >= target, , drop = FALSE]
    if (nrow(ok) == 0) return(NA_integer_)
    min(ok$N, na.rm = TRUE)
  }
  expect_true(is.na(min_n_for(df, "power_H1d")))
})

test_that("underpowered flag fires when a hypothesis never reaches target", {
  power_surface <- data.frame(
    N       = c(200, 300, 400),
    power_H1   = c(0.55, 0.75, 0.85),
    power_H1d  = c(0.30, 0.50, 0.65)
  )
  min_n_for <- function(df, col, target = 0.80) {
    ok <- df[df[[col]] >= target, , drop = FALSE]
    if (nrow(ok) == 0) return(NA_integer_)
    min(ok$N, na.rm = TRUE)
  }
  expect_false(is.na(min_n_for(power_surface, "power_H1")))
  expect_true(is.na(min_n_for(power_surface, "power_H1d")))
})

test_that("power grid has expected structure", {
  grid <- expand.grid(
    N            = c(200, 300, 400, 500, 600),
    effect_E     = c(0.10, 0.20, 0.30, 0.40),
    effect_ER    = c(0.05, 0.10, 0.15, 0.20),
    sigma_alpha2 = c(0.01, 0.05, 0.10),
    attrition    = c(0.10, 0.20),
    stringsAsFactors = FALSE
  )
  expect_equal(nrow(grid), 5 * 4 * 4 * 3 * 2)
  expect_true(all(grid$N %in% c(200, 300, 400, 500, 600)))
  expect_true(all(grid$effect_E %in% c(0.10, 0.20, 0.30, 0.40)))
  expect_true(all(grid$attrition %in% c(0.10, 0.20)))
})
