// =============================================================
// STRATIM — Kernel Comparison Model (H5)
// File: MODEL/stan/kernel_comparison.stan
// Version: 0.1.0-protocol
// =============================================================
//
// Tests whether the exponential or power-law kernel produces
// better predictive accuracy for the observed exposure-SIC
// relationship (Section 7.10).
//
// The kernel is estimated as a parameter within the model,
// not fixed in advance. The parameter lambda (exponential) or
// rho (power-law) is estimated from data.
//
// Model comparison uses LOO-CV or WAIC. Decision rule
// (DOCS/decision_rules.md Section 6.2):
//   - Supported for a kernel: LOO-CV difference > 2 SE AND
//     the estimated parameter is not at a boundary.
//   - Undetermined: neither kernel is clearly favored.
//   - Not testable: design-level identifiability fails
//     (see SIMULATION/code/01_H5_identifiability.R).
//
// NOTE: this Stan model assumes E_t has been pre-computed
// using the corresponding kernel in R. The kernel parameter
// is passed in as data, not estimated here. A future version
// may estimate the kernel parameter inside Stan using a
// monthly exposure series.
//
// =============================================================

data {
  int<lower=1> N;
  int<lower=1> T;
  int<lower=0> n_obs;

  array[n_obs] int<lower=1, upper=N> id;
  array[n_obs] int<lower=1, upper=T> transition;

  vector[n_obs] SIC_t;
  vector[n_obs] SIC_t1;

  // E_t computed from the exponential kernel
  vector[n_obs] E_exp;

  // E_t computed from the power-law kernel
  vector[n_obs] E_pow;

  vector[n_obs] R;
  vector[n_obs] G;
}

transformed data {
  vector[n_obs] E2_exp;
  vector[n_obs] E2_pow;
  vector[n_obs] ER_exp;
  vector[n_obs] ER_pow;
  vector[n_obs] E2R_exp;
  vector[n_obs] E2R_pow;
  vector[n_obs] EG_exp;
  vector[n_obs] EG_pow;

  E2_exp   = E_exp .* E_exp;
  E2_pow   = E_pow .* E_pow;
  ER_exp   = E_exp .* R;
  ER_pow   = E_pow .* R;
  E2R_exp  = E_exp .* E_exp .* R;
  E2R_pow  = E_pow .* E_pow .* R;
  EG_exp   = E_exp .* G;
  EG_pow   = E_pow .* G;
}

parameters {
  // Exponential-kernel model parameters
  real phi_exp;
  real alpha_0_exp;
  real beta_exp;
  real gamma_exp;
  real delta_1_exp;
  real delta_2_exp;
  real eta_exp;
  real<lower=0> sigma_alpha_exp;
  real<lower=0> sigma_u_exp;
  real<lower=0> sigma_eps_exp;
  vector[N] b_i_exp;
  vector[N] u_i_exp;

  // Power-law-kernel model parameters
  real phi_pow;
  real alpha_0_pow;
  real beta_pow;
  real gamma_pow;
  real delta_1_pow;
  real delta_2_pow;
  real eta_pow;
  real<lower=0> sigma_alpha_pow;
  real<lower=0> sigma_u_pow;
  real<lower=0> sigma_eps_pow;
  vector[N] b_i_pow;
  vector[N] u_i_pow;
}

transformed parameters {
  vector[N] alpha_i_exp;
  vector[N] alpha_i_pow;
  alpha_i_exp = alpha_0_exp + b_i_exp;
  alpha_i_pow = alpha_0_pow + b_i_pow;
}

model {
  // --- Exponential kernel model ---
  phi_exp      ~ normal(0.5, 0.3);
  alpha_0_exp  ~ normal(0, 0.5);
  beta_exp     ~ normal(0, 0.5);
  gamma_exp    ~ normal(0, 0.5);
  delta_1_exp  ~ normal(0, 0.3);
  delta_2_exp  ~ normal(0, 0.3);
  eta_exp      ~ normal(0, 0.3);
  sigma_alpha_exp ~ normal(0, 0.3);
  sigma_u_exp     ~ normal(0, 0.5);
  sigma_eps_exp   ~ normal(0, 0.5);
  b_i_exp ~ normal(0, sigma_alpha_exp);
  u_i_exp ~ normal(0, sigma_u_exp);

  // --- Power-law kernel model ---
  phi_pow      ~ normal(0.5, 0.3);
  alpha_0_pow  ~ normal(0, 0.5);
  beta_pow     ~ normal(0, 0.5);
  gamma_pow    ~ normal(0, 0.5);
  delta_1_pow  ~ normal(0, 0.3);
  delta_2_pow  ~ normal(0, 0.3);
  eta_pow      ~ normal(0, 0.3);
  sigma_alpha_pow ~ normal(0, 0.3);
  sigma_u_pow     ~ normal(0, 0.5);
  sigma_eps_pow   ~ normal(0, 0.5);
  b_i_pow ~ normal(0, sigma_alpha_pow);
  u_i_pow ~ normal(0, sigma_u_pow);

  // --- Likelihood for exponential model ---
  for (n in 1:n_obs) {
    real mu_exp = phi_exp * SIC_t[n]
                  - alpha_i_exp[id[n]] * E_exp[n]
                  + beta_exp  * R[n]
                  + gamma_exp * G[n]
                  + delta_1_exp * ER_exp[n]
                  + delta_2_exp * E2R_exp[n]
                  + eta_exp     * EG_exp[n]
                  + u_i_exp[id[n]];
    target += normal_lpdf(SIC_t1[n] | mu_exp, sigma_eps_exp);
  }

  // --- Likelihood for power-law model ---
  for (n in 1:n_obs) {
    real mu_pow = phi_pow * SIC_t[n]
                  - alpha_i_pow[id[n]] * E_pow[n]
                  + beta_pow  * R[n]
                  + gamma_pow * G[n]
                  + delta_1_pow * ER_pow[n]
                  + delta_2_pow * E2R_pow[n]
                  + eta_pow     * EG_pow[n]
                  + u_i_pow[id[n]];
    target += normal_lpdf(SIC_t1[n] | mu_pow, sigma_eps_pow);
  }
}

generated quantities {
  // Log-likelihoods for LOO-CV / WAIC comparison
  vector[n_obs] log_lik_exp;
  vector[n_obs] log_lik_pow;

  for (n in 1:n_obs) {
    real mu_exp = phi_exp * SIC_t[n]
                  - alpha_i_exp[id[n]] * E_exp[n]
                  + beta_exp  * R[n]
                  + gamma_exp * G[n]
                  + delta_1_exp * ER_exp[n]
                  + delta_2_exp * E2R_exp[n]
                  + eta_exp     * EG_exp[n]
                  + u_i_exp[id[n]];
    log_lik_exp[n] = normal_lpdf(SIC_t1[n] | mu_exp, sigma_eps_exp);

    real mu_pow = phi_pow * SIC_t[n]
                  - alpha_i_pow[id[n]] * E_pow[n]
                  + beta_pow  * R[n]
                  + gamma_pow * G[n]
                  + delta_1_pow * ER_pow[n]
                  + delta_2_pow * E2R_pow[n]
                  + eta_pow     * EG_pow[n]
                  + u_i_pow[id[n]];
    log_lik_pow[n] = normal_lpdf(SIC_t1[n] | mu_pow, sigma_eps_pow);
  }
}

// =============================================================
// End of kernel_comparison.stan
// =============================================================
