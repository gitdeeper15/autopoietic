
Experiment 03 — Recovery Boundary

File: SIMULATION/reports/exp_03_recovery_boundary.md
Version: 0.1.0-protocol
Experiment ID: STRATIM-EXP-03
Status: Complete

---

Purpose

Determine how σ_α recovery degrades as σ_α becomes smaller, across
a grid of N and attrition. This establishes the design boundary
for H1d: below which σ_α can the four-wave design still distinguish
heterogeneity from zero?

---

Design

Parameter Values
σ_α 0.10, 0.05, 0.03, 0.01
N 100, 200, 300
Attrition 0.00, 0.20, 0.35
Replicates per cell 20
Cells 36
Estimator lme4::lmer (REML), random slope for E
Seed policy per-cell seeds 70000 + cell_id * 1000 + r

---

Result — σ_α Recovery Boundary

σ_α Cells Adequate Marginal Inadequate
0.10 9 8 1 0
0.05 9 5 2 2
0.03 9 1 4 4
0.01 9 0 0 9

Classification rule (bias > 30% of true or coverage < 0.85 → inadequate;
bias > 10% or coverage < 0.90 → marginal; else adequate).

---

Key Findings

σ_α = 0.10 — Adequate in 8 of 9 cells. Recovery is robust to
N and attrition at this scale.

σ_α = 0.05 — Transitional. Adequate in 5 of 9 cells, but
deteriorates with smaller N and higher attrition.

σ_α = 0.03 — Marginal. Only 1 of 9 cells adequate. Recovery is
unreliable even at N = 300.

σ_α = 0.01 — Inadequate in all 9 cells. Recovery fails
systematically, including at N = 300, attrition = 0.

---

Interpretation

What this means. The four-wave, 18-month design has a
design-level testability boundary for σ_α. Below σ_α ≈ 0.05,
recovery becomes unreliable. Below σ_α ≈ 0.03, it is systematically
inadequate. This is not a numerical artifact of the estimator; it
is a property of the design.

What this does not mean. This does not say σ_α is meaningless
or unmeasurable in general. It says: with 3 transitions per
participant over 18 months, σ_α below ~0.05 cannot be reliably
distinguished from zero.

Methodological consequence. H1d's decision rule now includes a
design-based testability condition (see DOCS/decision_rules.md
Section 2.4). If the observed posterior interval is compatible with
σ_α < 0.05, H1d is reported as not testable within the window,
not as "not supported."

---

Limitations

· 20 replicates per cell. Higher precision would require more,
  but the qualitative boundary is clear.
· Frequentist estimator. Bayesian recovery may differ in detail,
  but the underlying information bound is design-level.
· Single DGP configuration per cell. Other effect sizes covered
  by Experiment 04.

---

Reproducibility

Script: SIMULATION/code/02b_recovery_boundary.R
Inputs: none
Outputs:

· SIMULATION/results/02b_recovery_boundary_raw.csv (~720 rows)
· SIMULATION/results/02b_recovery_boundary_summary.csv (288 rows)

Replicates: 20 per cell
Seed policy: 70000 + cell_id * 1000 + r
Runtime: ~7 minutes (4 parallel workers on 8-core setup)
R version: 4.5.2 (Ubuntu 22.04 in proot)
Status: Complete

Regeneration:

```bash
Rscript SIMULATION/code/02b_recovery_boundary.R
```

---

Related Documents

· DOCS/decision_rules.md (Section 2.4 — H1d design boundary)
· PREREGISTRATION/hypotheses.md (H1d design-based condition)
· EXPERIMENTS.md (Experiment 03 summary)
· SIMULATION/reports/exp_04_power_surface.md

---

End of exp_03_recovery_boundary.md
