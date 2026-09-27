# 04 — Dynamic Model

**Corresponds to:** Section 7.5

## Purpose

Fit the primary Bayesian hierarchical dynamic model and
conduct model comparison.

## Primary model

See `MODEL/stan/primary_model.stan`.

## Estimation

- **Primary:** Bayesian hierarchical, HMC (Stan / cmdstanr).
- **Sensitivity:** Frequentist mixed-effects (lme4, REML).

Priors are weakly informative and fixed in advance.

## Model reduction sequence

If convergence fails, the following reduction is applied
**in order** (Section 7.5):

1. Full model with random slope and nonlinear interactions.
2. Remove `δ₂` (three-way nonlinear term).
3. Remove random slope for E; retain random intercept only.
4. Simplify kernel to exponential only.
5. Intercept-only with fixed kernel.

Priors are **not adjusted** in response to convergence
failure. The reduction sequence is the only response.

## Nested comparisons

1. Additive vs. interaction specification (H1a, H1c).
2. Additive recovery vs. threshold recovery (H1b).
3. Exponential vs. power-law kernel (H5).

## Planned scripts

| Script | Purpose |
|--------|---------|
| `04a_fit_primary.R` | Fit primary model |
| `04b_fit_sensitivity.R` | Frequentist sensitivity |
| `04c_model_reduction.R` | Apply reduction sequence if needed |
| `04d_compare_models.R` | LOO-CV / WAIC comparison |
| `04e_diagnostics.R` | Convergence, ESS, R-hat |
| `04f_posterior_checks.R` | Posterior predictive checks |

## Outputs

- Fitted model objects (not committed).
- Posterior summaries (CSV).
- Convergence diagnostics.
- Model comparison table.

---

**End of `ANALYSIS/04_dynamic_model/README.md`**
