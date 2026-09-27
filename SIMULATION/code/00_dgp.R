# =============================================================
# STRATIM — Data Generating Process (DGP)
# File: SIMULATION/code/00_dgp.R
# Version: 0.1.0-protocol
# =============================================================
#
# This script defines the data generating process for the STRATIM
# dynamic state-space model (Sections 3 and 6 of the protocol).
#
# The DGP is used by:
#   - 01_H5_identifiability.R
#   - 02_parameter_recovery.R
#   - 03_power_surface.R
#
# Primary model (Section 6.11):
#
#   SIC_{i,t+1} = phi * SIC_{i,t}
#                 - alpha_i * E_{i,t}
#                 + beta  * R_{i,t:t+1}
#                 + gamma * G_{i,t:t+1}
#                 + delta_1 * (E_{i,t} * R_{i,t:t+1})
#                 + delta_2 * (E_{i,t}^2 * R_{i,t:t+1})
#                 + eta     * (E_{i,t} * G_{i,t:t+1})
#                 + u_i
#                 + epsilon_{i,t}
#
#   alpha_i = alpha_0 + b_i,   b_i ~ N(0, sigma_alpha^2)
#   u_i                        ~ N(0, sigma_u^2)
#   epsilon_{i,t}              ~ N(0, sigma_eps^2)
#
# =============================================================

suppressPackageStartupMessages({
  library(stats)
})

# -------------------------------------------------------------
# Default parameters
# -------------------------------------------------------------

stratim_default_params <- function() {
  list(
    # Fixed effects (standardized scale)
    phi     = 0.50,   # autoregressive coefficient
    alpha_0 = 0.20,   # population mean sensitivity to closure exposure
    beta    = 0.15,   # rehearsal main effect
    gamma   = 0.10,   # recovery main effect
    delta_1 = 0.05,   # E x R interaction
    delta_2 = 0.03,   # E^2 x R interaction
    eta     = 0.04,   # E x G interaction

    # Random effects
    sigma_alpha = 0.10,   # SD of b_i
    sigma_u     = 0.30,   # SD of u_i
    sigma_eps   = 0.20,   # residual SD

    # Design
    N         = 300,
    n_months  = 18,
    waves     = c(0, 6, 12, 18),
    attrition = 0.20,

    # Kernel
    kernel       = "exponential",  # or "powerlaw"
    lambda       = 0.30,
    rho_powerlaw = 1.50,

    # Baseline
    SIC_sd_0 = 1.0
  )
}

# -------------------------------------------------------------
# Kernel functions
# -------------------------------------------------------------

stratim_kernel_weights <- function(delta_t, kernel,
                                   lambda = 0.3, rho = 1.5) {
  if (kernel == "exponential") {
    exp(-lambda * delta_t)
  } else if (kernel == "powerlaw") {
    (1 + delta_t)^(-rho)
  } else {
    stop("Unknown kernel: ", kernel)
  }
}

# -------------------------------------------------------------
# Cumulative exposure E_it
# -------------------------------------------------------------
# Computes E_it at each wave from a monthly closure series.
# E_it uses ONLY closure events up to and including time t
# (no temporal leakage; Section 7.1).

stratim_compute_E <- function(S_closure, waves, kernel, lambda, rho) {
  n_waves <- length(waves)
  E <- numeric(n_waves)
  for (k in seq_along(waves)) {
    t <- waves[k]
    if (t == 0) { E[k] <- 0; next }
    tau <- 1:t
    w   <- stratim_kernel_weights(t - tau, kernel, lambda, rho)
    E[k] <- sum(w * S_closure[tau])
  }
  E
}

# -------------------------------------------------------------
# Main DGP function
# -------------------------------------------------------------

stratim_simulate_dgp <- function(params = stratim_default_params(),
                                 seed = NULL) {
  if (!is.null(seed)) set.seed(seed)

  with(params, {
    # 1. Individual effects
    b_i     <- rnorm(N, 0, sigma_alpha)
    u_i     <- rnorm(N, 0, sigma_u)
    alpha_i <- alpha_0 + b_i

    # 2. Baseline SIC
    SIC_0 <- rnorm(N, 0, SIC_sd_0)

    # 3. Monthly closure series (AR(1) mapped to (0,1))
    S_closure <- matrix(NA_real_, N, n_months)
    for (i in seq_len(N)) {
      z <- numeric(n_months)
      z[1] <- rnorm(1)
      for (tau in 2:n_months) {
        z[tau] <- 0.7 * z[tau - 1] + rnorm(1, 0, 0.7)
      }
      S_closure[i, ] <- plogis(z)
    }

    # 4. E_it at each wave
    E_it <- matrix(NA_real_, N, length(waves))
    for (i in seq_len(N)) {
      E_it[i, ] <- stratim_compute_E(S_closure[i, ], waves,
                                     kernel, lambda, rho_powerlaw)
    }
    # Standardize E within each wave
    for (k in seq_along(waves)) {
      s <- sd(E_it[, k])
      if (is.finite(s) && s > 0) {
        E_it[, k] <- (E_it[, k] - mean(E_it[, k])) / s
      }
    }

    # 5. R and G per transition
    n_trans <- length(waves) - 1
    R <- matrix(rnorm(N * n_trans), N, n_trans)
    G <- matrix(rnorm(N * n_trans), N, n_trans)

    # 6. SIC trajectory
    SIC <- matrix(NA_real_, N, length(waves))
    SIC[, 1] <- SIC_0
    for (k in seq_len(n_trans)) {
      E_k <- E_it[, k]
      R_k <- R[, k]
      G_k <- G[, k]
      SIC[, k + 1] <-
        phi      * SIC[, k] +
        -alpha_i * E_k +
        beta     * R_k +
        gamma    * G_k +
        delta_1  * (E_k * R_k) +
        delta_2  * (E_k^2 * R_k) +
        eta      * (E_k * G_k) +
        u_i +
        rnorm(N, 0, sigma_eps)
    }

    # 7. Attrition (random per-wave)
    if (attrition > 0) {
      per_wave <- attrition / n_trans
      for (i in seq_len(N)) {
        for (k in 2:length(waves)) {
          if (runif(1) < per_wave) {
            SIC[i, k:length(waves)] <- NA
            break
          }
        }
      }
    }

    list(
      SIC       = SIC,
      E         = E_it,
      R         = R,
      G         = G,
      S_closure = S_closure,
      params    = params
    )
  })
}

# -------------------------------------------------------------
# Reshape DGP output to long format
# -------------------------------------------------------------
# Converts the wide-format DGP output to a long-format data.frame
# with one row per (individual, transition).

stratim_dgp_to_long <- function(sim) {
  N     <- nrow(sim$SIC)
  waves <- sim$params$waves
  n_tr  <- length(waves) - 1

  rows <- vector("list", N * n_tr)
  idx <- 1
  for (i in seq_len(N)) {
    for (k in seq_len(n_tr)) {
      rows[[idx]] <- data.frame(
        id     = i,
        t_from = waves[k],
        t_to   = waves[k + 1],
        SIC_t  = sim$SIC[i, k],
        SIC_t1 = sim$SIC[i, k + 1],
        E      = sim$E[i, k],
        R      = sim$R[i, k],
        G      = sim$G[i, k]
      )
      idx <- idx + 1
    }
  }
  df <- do.call(rbind, rows)
  df <- df[!is.na(df$SIC_t1), ]
  df$E2  <- df$E^2
  df$ER  <- df$E * df$R
  df$E2R <- df$E^2 * df$R
  df$EG  <- df$E * df$G
  rownames(df) <- NULL
  df
}

# =============================================================
# End of 00_dgp.R
# =============================================================
