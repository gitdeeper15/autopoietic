# =============================================================
# STRATIM — End-to-End Pipeline Test
# File: tests/testthat/test-pipeline.R
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

# Find repository root by looking for a known marker
find_repo_root <- function() {
  candidates <- c(
    ".",
    "../..",
    "/data/data/com.termux/files/home/storage/downloads/STRATIM"
  )
  for (p in candidates) {
    if (file.exists(file.path(p, "SIMULATION", "code", "00_dgp.R"))) {
      return(normalizePath(p))
    }
  }
  NA_character_
}

test_that("full minimal pipeline runs end-to-end", {
  source_dgp()

  p <- stratim_default_params()
  p$N <- 50
  p$attrition <- 0.0

  sim <- stratim_simulate_dgp(p, seed = 999)
  expect_true(is.list(sim))
  expect_true(all(c("SIC", "E", "R", "G") %in% names(sim)))

  df <- stratim_dgp_to_long(sim)
  expect_true(is.data.frame(df))
  expect_true(nrow(df) > 0)
  expect_true(all(c("SIC_t", "SIC_t1", "E", "R", "G",
                    "ER", "E2R", "EG") %in% names(df)))

  expect_false(any(is.na(df$SIC_t1)))
  expect_true(sd(df$E) > 0)
  expect_equal(df$ER,  df$E * df$R)
  expect_equal(df$E2R, df$E^2 * df$R)
  expect_equal(df$EG,  df$E * df$G)
})

test_that("pipeline is reproducible with the same seed", {
  source_dgp()

  p <- stratim_default_params()
  p$N <- 30

  sim1 <- stratim_simulate_dgp(p, seed = 111)
  sim2 <- stratim_simulate_dgp(p, seed = 111)

  df1 <- stratim_dgp_to_long(sim1)
  df2 <- stratim_dgp_to_long(sim2)

  expect_equal(df1, df2)
})

test_that("different seeds produce different data", {
  source_dgp()

  p <- stratim_default_params()
  p$N <- 30

  sim1 <- stratim_simulate_dgp(p, seed = 111)
  sim2 <- stratim_simulate_dgp(p, seed = 222)

  df1 <- stratim_dgp_to_long(sim1)
  df2 <- stratim_dgp_to_long(sim2)

  expect_false(isTRUE(all.equal(df1$SIC_t1, df2$SIC_t1)))
})

test_that("pipeline handles attrition correctly", {
  source_dgp()

  p <- stratim_default_params()
  p$N <- 100
  p$attrition <- 0.30

  sim <- stratim_simulate_dgp(p, seed = 333)
  df  <- stratim_dgp_to_long(sim)

  expect_lte(nrow(df), 300)
  expect_gt(nrow(df), 150)

  expect_false(any(is.na(df$SIC_t1)))
  expect_false(any(is.na(df$E)))
})

test_that("all required source files exist", {
  root <- find_repo_root()
  skip_if(is.na(root), "Could not find repository root")

  required <- c(
    "SIMULATION/code/00_dgp.R",
    "SIMULATION/code/01_H5_identifiability.R",
    "SIMULATION/code/02_parameter_recovery.R",
    "SIMULATION/code/03_power_surface.R"
  )
  for (f in required) {
    full_path <- file.path(root, f)
    expect_true(file.exists(full_path),
                info = paste("Missing file:", full_path))
  }
})
