# STRATIM — Model

This directory contains the Stan models for STRATIM.

## Status

The models are **specifications**. They have not yet been
compiled or tested against simulated data. Parameter recovery
using these models (rather than `lme4`) will be run once
simulation outputs from `SIMULATION/code/` are validated.

## Files

| File | Purpose |
|------|---------|
| `stan/primary_model.stan` | Primary dynamic model (Section 6.11) |
| `stan/threshold_recovery.stan` | H1b threshold specification |
| `stan/kernel_comparison.stan` | H5 exponential vs power-law |

## Estimation framework

The primary estimation framework is **Bayesian hierarchical
with Hamiltonian Monte Carlo** (Section 7.5). Frequentist
mixed-effects (REML) is a sensitivity analysis.

Priors are weakly informative and specified in advance. They
are not adjusted based on observed data. If convergence
fails, the pre-specified model reduction sequence is applied
(Section 7.5), not arbitrary prior changes.

## How to compile

With `cmdstanr`:

```r
library(cmdstanr)
model <- cmdstan_model("MODEL/stan/primary_model.stan")
```

With rstan:

```r
library(rstan)
model <- stan_model("MODEL/stan/primary_model.stan")
```

Dependencies

· Stan (via cmdstanr or rstan)
· R 4.3+
· LOO package (for LOO-CV comparison)

Relationship to the protocol

· primary_model.stan → Section 3.3, Section 6.11
· threshold_recovery.stan → Section 4 (H1b), Section 7.6
· kernel_comparison.stan → Section 3.4, Section 7.10

If a Stan model contradicts the protocol, the protocol takes
precedence and the Stan model must be updated.

What is not included

· Compiled binaries (.exe, .o)
· Fitted model objects (.rds)
· Posterior samples

These are regenerable from the Stan source and are not
committed to the repository.

---

End of MODEL/README.md
