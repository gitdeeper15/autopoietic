# STRATIM — testthat entry point
# Version: 0.1.0-protocol

library(testthat)

test_dir(
  "tests/testthat",
  reporter = "summary",
  stop_on_failure = FALSE
)
