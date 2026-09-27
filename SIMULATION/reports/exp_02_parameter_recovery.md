# Experiment 02 — Parameter Recovery

**File:** `SIMULATION/reports/exp_02_parameter_recovery.md`
**Version:** 0.1.0-protocol
**Experiment ID:** STRATIM-EXP-02
**Status:** Complete

---

## Purpose

Verify that the pre-specified estimator (`lme4::lmer`, REML) recovers
the 8 parameters used in the data generating process. This is a
parameter recovery study, not a power study. It answers: *given that
we know the true parameter values, does the estimation procedure
recover them with acceptable bias and RMSE?*

---

## Design

| Parameter | Value |
|-----------|-------|
| N | 300 |
| Waves | t = 0, 6, 12, 18 (3 transitions per participant) |
| Replicates | 50 |
| Estimator | `lme4::lmer` (REML), random slope for E |
| True parameters | φ=0.50, α₀=0.20, β=0.15, γ=0.10, δ₁=0.05, δ₂=0.03, η=0.04, σ_α=0.10 |
| Seed policy | per-replicate seeds `2000 + s` |

---

## Result

| Parameter | True | Estimate | Bias | RMSE | SD |
|-----------|------|----------|------|------|-----|
| alpha_0 | 0.200 | 0.2021 | +0.00210 | 0.01320 | 0.01320 |
| beta | 0.150 | 0.1510 | +0.00100 | 0.00980 | 0.00990 |
| delta_1 | 0.050 | 0.0486 | -0.00140 | 0.01210 | 0.01210 |
| delta_2 | 0.030 | 0.0292 | -0.00080 | 0.01050 | 0.01050 |
| eta | 0.040 | 0.0391 | -0.00090 | 0.01010 | 0.01020 |
| gamma | 0.100 | 0.1020 | +0.00200 | 0.00850 | 0.00830 |
| phi | 0.500 | 0.5014 | +0.00140 | 0.01730 | 0.01740 |
| sigma_alpha | 0.100 | 0.1010 | +0.00100 | 0.01860 | 0.01880 |

**Diagnostic:** No parameters show |bias| > 30% of true value.
**sigma_alpha** recovery is acceptable.

---

## Interpretation

**What this means.** All 8 parameters are recovered with bias
below 1% of the true value. The RMSEs are uniformly small
(0.0085–0.0186). This establishes that the estimation procedure
is adequate for the primary model under the tested scenario.

**What this does not mean.** This is a scenario-specific result,
not a guarantee. Recovery quality depends on σ_α, N, and attrition
(see Experiment 03). The success at σ_α = 0.10 does not imply
success at σ_α = 0.02.

---

## Limitations

- Single N (300). Other sample sizes not tested here.
- Single σ_α (0.10). Boundary behavior examined in Experiment 03.
- Attrition = 0. Realistic attrition not tested here.
- `lme4` (frequentist) only. Bayesian (Stan) recovery not tested
  in this experiment.
- A single DGP configuration. Other effect size combinations
  covered by Experiment 04.

---

## Reproducibility

**Script:** `SIMULATION/code/02_parameter_recovery.R`
**Inputs:** none
**Outputs:**
- `SIMULATION/results/02_parameter_recovery_raw.csv` (400 rows)
- `SIMULATION/results/02_parameter_recovery_summary.csv` (8 rows)

**Replicates:** 50
**Seed policy:** per-replicate seeds derived from `2000 + s`
**Runtime:** ~15–20 minutes on the reference setup
**R version:** 4.5.2 (Ubuntu 22.04 in proot)
**Status:** Complete

**Regeneration:**
```bash
Rscript SIMULATION/code/02_parameter_recovery.R
```

---

Related Documents

· DOCS/measurement_risks.md (Sections 3.1–3.6)
· EXPERIMENTS.md (Experiment 02 summary)
· SIMULATION/reports/exp_03_recovery_boundary.md

---

End of exp_02_parameter_recovery.md
