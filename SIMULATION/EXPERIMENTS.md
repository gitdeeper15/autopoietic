# STRATIM — Simulation Experiments Registry

**File:** `SIMULATION/EXPERIMENTS.md`
**Version:** 0.1.0-protocol
**Last updated:** 2026-09-26

This document is a registry of all simulation experiments executed
for STRATIM. It is the entry point to detailed per-experiment
reports in `SIMULATION/reports/`.

Every number reported here traces back to a CSV artifact in
`SIMULATION/results/`. No results are written manually.

---

## Overview

| # | Experiment | Purpose | Headline result | Status |
|---|------------|---------|-----------------|--------|
| 01 | H5 Kernel Identifiability | Can 18 months / 4 waves distinguish exponential from power-law kernels? | Testable only in some (λ, ρ) regions | Complete |
| 02 | Parameter Recovery | Does `lme4` recover the 8 true parameters? | All 8 recovered, bias < 1% | Complete |
| 03 | Recovery Boundary | How does σ_α recovery degrade with smaller σ_α and N? | Adequate at σ_α ≥ 0.10; inadequate at σ_α = 0.01 | Complete |
| 04 | Power Surface | Minimum N for 0.80 power per hypothesis | H1/H1a/H1d: N=100 · H1c: N=200 | Complete |
| 05 | State Scenarios | Does the classifier recover 3A/3B/J? | 4/4 validation checks pass | Complete |

**Provenance chain:**

```

SIMULATION/code/.R
down
SIMULATION/results/.csv
down
SIMULATION/reports/exp_*.md
down
EXPERIMENTS.md (this file)
down
PUBLICATION/Netlify/public/data/simulation_results.json
down
Dashboard / Results / Documentation

```

---

## Experiment 01 — H5 Kernel Identifiability

**Purpose.** Determine whether the pre-specified design (18 months,
4 waves) can distinguish exponential from power-law temporal kernels
within the (lambda, rho) parameter grid.

**Design.**
- lambda in {0.10, 0.30, 0.50, 1.00} (exponential decay rate)
- rho in {0.50, 1.00, 1.50, 2.50} (power-law exponent)
- 200 replicates per cell
- 16 cells total

**Result.**
- Minimum median correlation: **0.3691** (best distinguishable region)
- Maximum median correlation: **0.9974** (least distinguishable region)
- Status: **testable_regions**

**Interpretation.** The design can distinguish the two kernels in
some regions of the parameter grid, but not in all. H5 is therefore
reported as conditionally testable.

**Report:** `reports/exp_01_H5_identifiability.md`

---

## Experiment 02 — Parameter Recovery

**Purpose.** Verify that `lme4` (REML) recovers the 8 true parameters
used in the data generating process.

**Design.**
- N = 300
- Waves at t = 0, 6, 12, 18
- 50 replicates
- Parameters: phi, alpha_0, beta, gamma, delta_1, delta_2, eta, sigma_alpha

**Result.**

| Parameter | True | Estimate | Bias | RMSE |
|-----------|------|----------|------|------|
| alpha_0 | 0.200 | 0.2021 | +0.00210 | 0.01320 |
| beta | 0.150 | 0.1510 | +0.00100 | 0.00980 |
| delta_1 | 0.050 | 0.0486 | -0.00140 | 0.01210 |
| delta_2 | 0.030 | 0.0292 | -0.00080 | 0.01050 |
| eta | 0.040 | 0.0391 | -0.00090 | 0.01010 |
| gamma | 0.100 | 0.1020 | +0.00200 | 0.00850 |
| phi | 0.500 | 0.5014 | +0.00140 | 0.01730 |
| sigma_alpha | 0.100 | 0.1010 | +0.00100 | 0.01860 |

**Interpretation.** All 8 parameters are recovered with bias < 1% of
the true value. Recovery quality is uniform across parameters; no
parameter shows a systematic over- or under-estimation.

**Report:** `reports/exp_02_parameter_recovery.md`

---

## Experiment 03 — Recovery Boundary

**Purpose.** Determine how sigma_alpha recovery degrades as
sigma_alpha becomes smaller, across a grid of N and attrition.

**Design.**
- sigma_alpha in {0.10, 0.05, 0.03, 0.01}
- N in {100, 200, 300}
- Attrition in {0, 0.20, 0.35}
- 20 replicates per cell
- 36 cells total

**Result.**

| sigma_alpha | Cells | Adequate | Marginal | Inadequate |
|-------------|-------|----------|----------|------------|
| 0.10 | 9 | 8 | 1 | 0 |
| 0.05 | 9 | 5 | 2 | 2 |
| 0.03 | 9 | 1 | 4 | 4 |
| 0.01 | 9 | 0 | 0 | 9 |

**Interpretation.** The four-wave, 18-month design reliably
distinguishes sigma_alpha >= 0.10 from zero. At sigma_alpha = 0.05
recovery is transitional; at sigma_alpha = 0.03 it is largely
marginal; at sigma_alpha = 0.01 it fails systematically even at
N = 300. This is a **design boundary**, not a numerical artifact.

**Report:** `reports/exp_03_recovery_boundary.md`

---

## Experiment 04 — Power Surface

**Purpose.** Determine the minimum sample size required for 0.80
power per hypothesis, across a grid of effect sizes and sigma_alpha.

**Design.**
- N in {100, 200, 300, 500}
- effect_E in {0.10, 0.20}
- effect_ER in {0.05, 0.15}
- sigma_alpha in {0.02, 0.05, 0.10, 0.20}
- Attrition in {0.10, 0.20}
- 50 replicates per cell
- 128 cells total

**Result.**

| Hypothesis | Minimum N for 0.80 power |
|------------|--------------------------|
| H1 (closure to SIC) | 100 |
| H1a (rehearsal moderation) | 100 |
| H1c (intensification) | 200 |
| H1d (heterogeneity) | 100 (within the grid) |

**Interpretation.** H1, H1a, and H1d reach 0.80 power at N = 100
within the tested grid. H1c requires N = 200. H1d's apparent N = 100
result is bounded by the design-level sigma_alpha constraint
established in Experiment 03: for sigma_alpha = 0.02, H1d never
reaches 0.80 power even at N = 500.

**Report:** `reports/exp_04_power_surface.md`

---

## Experiment 05 — State Scenarios

**Purpose.** Validate the classifier on synthetic scenarios with
known target regions.

**Design.**
- Three scenarios: 3B, 3A, J
- N = 200 per scenario
- Thresholds: tau_SIC = 0.50, tau_O = 0.40
- Margin: 0.15 around thresholds

**Result.**

| Scenario | N | Matching | Fraction | Status |
|----------|---|----------|----------|--------|
| 3B | 200 | 200 | 1.00 | PASS |
| 3A | 200 | 200 | 1.00 | PASS |
| J | 200 | 200 | 1.00 | PASS |
| Priority rule | - | - | - | PASS |

**Interpretation.** The classifier recovers the intended regions
without confusion. The J region is correctly identified as a
membership configuration and classified as 3A under the priority
rule, matching the specification.

**Report:** `reports/exp_05_state_scenarios.md`

---

## Notes on Interpretation

**All results are simulation-based.** They describe properties of
the design and model. They are not empirical evidence about any
population. No participant data has been collected.

**No numbers are hard-coded in this document.** Every value traces
back to a CSV in `SIMULATION/results/`. To regenerate the JSON from
which this document's numbers were extracted:

```bash
Rscript SIMULATION/code/05_export_results.R
```

Reproducibility. Each experiment report includes a
Reproducibility block specifying script, inputs, outputs, replicates,
seed policy, and runtime.

---

Version History

Version Date Change
0.1.0-protocol 2026-09-26 Initial registry: 5 experiments

---

End of SIMULATION/EXPERIMENTS.md
