// =============================================================
// STRATIM — Primary Dynamic Model
// File: MODEL/stan/primary_model.stan
// Version: 0.1.0-protocol
// =============================================================
//
// Discrete-time dynamic model for SIC (Section 6.11):
//
//   SIC_{i,t+1} = phi * SIC_{i,t}
//                 - alpha_i * E_{i,t}
//                 + beta  * R_{i,t:t+1}
//                 + gamma * G_{i,t:t+1}
//                 + delta_1 * (E_{i,t} * R_{i,t:t+1})
//                 + delta_2 * (E_{i,t}^2 * R_{i,t:t+1})
//                 + eta     * (E_{i,t} * G_{i,t:t+1})
//                 + u_i
//                 + epsilon_{i,t}
//
//   alpha_i = alpha_0 + b_i,   b_i ~ N(0, sigma_alpha^2)
//   u_i                        ~ N(0, sigma_u^2)
//   epsilon_{i,t}              ~ N(0, sigma_eps^2)
//
// Priors are weakly informative and fixed in advance
// (Section 7.5). They are NOT adjusted based on observed data.
//
// =============================================================

data {
  int<lower=1> N;              // number of individuals
  int<lower=1> T;              // number of transitions per individual
  int<lower=0> n_obs;          // total observations (may be < N*T if attrition)

  array[n_obs] int<lower=1, upper=N> id;
  array[n_obs] int<lower=1, upper=T> transition;

  vector[n_obs] SIC_t;         // SIC at start of transition
  vector[n_obs] SIC_t1;        // SIC at end of transition
  vector[n_obs] E;             // accumulated exposure
  vector[n_obs] R;             // rehearsal
  vector[n_obs] G;             // recovery
}

transformed data {
  vector[n_obs] E2;
  vector[n_obs] ER;
  vector[n_obs] E2R;
  vector[n_obs] EG;

  E2  = E .* E;
  ER  = E .* R;
  E2R = E .* E .* R;
  EG  = E .* G;
}

parameters {
  // Fixed effects
  real phi;                    // autoregressive coefficient
  real alpha_0;                // population mean sensitivity
  real beta;                   // rehearsal main effect
  real gamma;                  // recovery main effect
  real delta_1;                // E x R interaction
  real delta_2;                // E^2 x R interaction
  real eta;                    // E x G interaction

  // Variance components
  real<lower=0> sigma_alpha;   // SD of individual sensitivity
  real<lower=0> sigma_u;       // SD of individual intercept
  real<lower=0> sigma_eps;     // residual SD

  // Individual effects
  vector[N] b_i;               // sensitivity deviations
  vector[N] u_i;               // intercepts
}

transformed parameters {
  vector[N] alpha_i;
  alpha_i = alpha_0 + b_i;
}

model {
  // --- Priors (pre-specified, Section 7.5) ---
  phi     ~ normal(0.5, 0.3);       // truncated implicitly by data range
  alpha_0 ~ normal(0, 0.5);
  beta    ~ normal(0, 0.5);
  gamma   ~ normal(0, 0.5);
  delta_1 ~ normal(0, 0.3);
  delta_2 ~ normal(0, 0.3);
  eta     ~ normal(0, 0.3);

  sigma_alpha ~ normal(0, 0.3);
  sigma_u     ~ normal(0, 0.5);
  sigma_eps   ~ normal(0, 0.5);

  b_i ~ normal(0, sigma_alpha);
  u_i ~ normal(0, sigma_u);

  // --- Likelihood ---
  vector[n_obs] mu;
  for (n in 1:n_obs) {
    mu[n] = phi * SIC_t[n]
            - alpha_i[id[n]] * E[n]
            + beta  * R[n]
            + gamma * G[n]
            + delta_1 * ER[n]
            + delta_2 * E2R[n]
            + eta     * EG[n]
            + u_i[id[n]];
  }
  SIC_t1 ~ normal(mu, sigma_eps);
}

generated quantities {
  // Posterior predictive checks
  vector[n_obs] log_lik;
  vector[n_obs] y_rep;

  for (n in 1:n_obs) {
    real mu_n = phi * SIC_t[n]
                - alpha_i[id[n]] * E[n]
                + beta  * R[n]
                + gamma * G[n]
                + delta_1 * ER[n]
                + delta_2 * E2R[n]
                + eta     * EG[n]
                + u_i[id[n]];

    log_lik[n] = normal_lpdf(SIC_t1[n] | mu_n, sigma_eps);
    y_rep[n]   = normal_rng(mu_n, sigma_eps);
  }
}

// =============================================================
// End of primary_model.stan
// =============================================================
