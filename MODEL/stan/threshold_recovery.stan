// =============================================================
// STRATIM — Threshold Recovery Model (H1b)
// File: MODEL/stan/threshold_recovery.stan
// Version: 0.1.0-protocol
// =============================================================
//
// Same as primary_model.stan, but the recovery effect on SIC is
// modelled as conditional on crossing both a time threshold
// (tau_T) and a calm threshold (tau_C):
//
//   gamma_effect = gamma_1 * G + gamma_2 * G * 1(T > tau_T, C > tau_C)
//
// H1b tests:
//   H0: gamma_2 = 0
//   H1: gamma_2 > 0
//
// tau_T and tau_C are fixed in advance (Section 7.6), not
// estimated from the data.
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
  vector[n_obs] E;
  vector[n_obs] R;
  vector[n_obs] G;

  // Recovery components (for threshold computation)
  vector[n_obs] T_time;   // unstructured time
  vector[n_obs] C_calm;   // internal quiescence

  // Pre-specified thresholds
  real tau_T;
  real tau_C;
}

transformed data {
  vector[n_obs] E2;
  vector[n_obs] ER;
  vector[n_obs] E2R;
  vector[n_obs] EG;

  // Indicator for crossing both thresholds
  vector[n_obs] G_above;

  E2  = E .* E;
  ER  = E .* R;
  E2R = E .* E .* R;
  EG  = E .* G;

  for (n in 1:n_obs) {
    G_above[n] = (T_time[n] > tau_T && C_calm[n] > tau_C) ? 1.0 : 0.0;
  }
}

parameters {
  real phi;
  real alpha_0;
  real beta;
  real gamma_1;    // recovery main effect
  real gamma_2;    // threshold interaction effect
  real delta_1;
  real delta_2;
  real eta;

  real<lower=0> sigma_alpha;
  real<lower=0> sigma_u;
  real<lower=0> sigma_eps;

  vector[N] b_i;
  vector[N] u_i;
}

transformed parameters {
  vector[N] alpha_i;
  alpha_i = alpha_0 + b_i;
}

model {
  // Priors
  phi      ~ normal(0.5, 0.3);
  alpha_0  ~ normal(0, 0.5);
  beta     ~ normal(0, 0.5);
  gamma_1  ~ normal(0, 0.5);
  gamma_2  ~ normal(0, 0.3);
  delta_1  ~ normal(0, 0.3);
  delta_2  ~ normal(0, 0.3);
  eta      ~ normal(0, 0.3);

  sigma_alpha ~ normal(0, 0.3);
  sigma_u     ~ normal(0, 0.5);
  sigma_eps   ~ normal(0, 0.5);

  b_i ~ normal(0, sigma_alpha);
  u_i ~ normal(0, sigma_u);

  // Likelihood
  vector[n_obs] mu;
  for (n in 1:n_obs) {
    mu[n] = phi * SIC_t[n]
            - alpha_i[id[n]] * E[n]
            + beta  * R[n]
            + gamma_1 * G[n]
            + gamma_2 * G[n] * G_above[n]
            + delta_1 * ER[n]
            + delta_2 * E2R[n]
            + eta     * EG[n]
            + u_i[id[n]];
  }
  SIC_t1 ~ normal(mu, sigma_eps);
}

generated quantities {
  vector[n_obs] log_lik;
  for (n in 1:n_obs) {
    real mu_n = phi * SIC_t[n]
                - alpha_i[id[n]] * E[n]
                + beta  * R[n]
                + gamma_1 * G[n]
                + gamma_2 * G[n] * G_above[n]
                + delta_1 * ER[n]
                + delta_2 * E2R[n]
                + eta     * EG[n]
                + u_i[id[n]];
    log_lik[n] = normal_lpdf(SIC_t1[n] | mu_n, sigma_eps);
  }
}

// =============================================================
// End of threshold_recovery.stan
// =============================================================
