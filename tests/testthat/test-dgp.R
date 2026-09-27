# =============================================================
# STRATIM — Tests for the Data Generating Process
# File: tests/testthat/test-dgp.R
# Version: 0.1.0-protocol
# =============================================================

source_dgp <- function() {
  candidates <- c(
    "SIMULATION/code/00_dgp.R",
    "../../SIMULATION/code/00_dgp.R",
    "../SIMULATION/code/00_dgp.R",
    "00_dgp.R"
  )
  for (p in candidates) {
    if (file.exists(p)) { source(p, local = FALSE); return(invisible(TRUE)) }
  }
  stop("Could not find SIMULATION/code/00_dgp.R")
}

test_that("default parameters have expected structure and scale", {
  source_dgp()
  p <- stratim_default_params()

  expect_true(is.list(p))
  expect_true(all(c("phi", "alpha_0", "delta_1", "delta_2",
                    "sigma_alpha", "waves") %in% names(p)))

  expect_true(p$phi > 0 && p$phi < 1)
  expect_true(p$alpha_0 > 0)
  expect_true(p$delta_1 >= 0)
  expect_true(p$delta_2 >= 0)
  expect_true(p$sigma_alpha > 0)
  expect_equal(length(p$waves), 4)
  expect_equal(p$waves, c(0, 6, 12, 18))
})

test_that("DGP returns expected object structure", {
  source_dgp()
  sim <- stratim_simulate_dgp(stratim_default_params(), seed = 42)

  expect_true(is.list(sim))
  expect_true(all(c("SIC", "E", "R", "G", "S_closure", "params") %in% names(sim)))

  N <- sim$params$N
  n_waves <- length(sim$params$waves)
  expect_equal(nrow(sim$SIC), N)
  expect_equal(ncol(sim$SIC), n_waves)
  expect_equal(nrow(sim$E), N)
  expect_equal(ncol(sim$E), n_waves)
})

test_that("DGP is reproducible under the same seed", {
  source_dgp()
  sim1 <- stratim_simulate_dgp(stratim_default_params(), seed = 7)
  sim2 <- stratim_simulate_dgp(stratim_default_params(), seed = 7)

  expect_equal(sim1$SIC, sim2$SIC)
  expect_equal(sim1$E, sim2$E)
  expect_equal(sim1$R, sim2$R)
})

test_that("higher alpha_0 produces stronger E-to-SIC association", {
  source_dgp()

  # Because E is standardized within wave (mean 0), alpha_0 does
  # not shift the mean of SIC. It strengthens the E-to-SIC
  # association. We therefore test the regression slope of
  # SIC_t1 on E, not the mean SIC.
  estimate_slope <- function(alpha_0, seeds) {
    slopes <- numeric(length(seeds))
    for (k in seq_along(seeds)) {
      p <- stratim_default_params()
      p$alpha_0   <- alpha_0
      p$attrition <- 0
      sim <- stratim_simulate_dgp(p, seed = seeds[k])
      df  <- stratim_dgp_to_long(sim)

      # Regression of SIC_t1 on E (controlling for SIC_t)
      fit <- stats::lm(SIC_t1 ~ SIC_t + E, data = df)
      slopes[k] <- stats::coef(fit)["E"]
    }
    mean(slopes)
  }

  seeds <- 1:10
  slope_low  <- estimate_slope(0.05, seeds)
  slope_high <- estimate_slope(0.40, seeds)

  # Higher alpha_0 should make the E coefficient more negative
  expect_true(slope_high < slope_low)
})

test_that("attrition produces missing values at the expected rate (approx)", {
  source_dgp()
  p <- stratim_default_params()
  p$attrition <- 0.40
  sim <- stratim_simulate_dgp(p, seed = 202)

  n_total <- prod(dim(sim$SIC)[1], length(p$waves) - 1)
  n_missing <- sum(is.na(sim$SIC[, -1]))
  frac_missing <- n_missing / n_total

  expect_true(frac_missing > 0.05)
  expect_true(frac_missing < 0.60)
})

test_that("dgp_to_long produces expected columns and no leakage", {
  source_dgp()
  sim <- stratim_simulate_dgp(stratim_default_params(), seed = 303)
  df  <- stratim_dgp_to_long(sim)

  expected_cols <- c("id", "t_from", "t_to", "SIC_t", "SIC_t1",
                     "E", "R", "G", "E2", "ER", "E2R", "EG")
  expect_true(all(expected_cols %in% names(df)))

  N <- sim$params$N
  n_trans <- length(sim$params$waves) - 1
  expect_lte(nrow(df), N * n_trans)
  expect_gt(nrow(df), 0)

  expect_false(any(is.na(df$SIC_t1)))
  expect_false(any(is.na(df$SIC_t)))
})
