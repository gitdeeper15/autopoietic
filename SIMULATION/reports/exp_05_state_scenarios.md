
Experiment 05 — State Scenarios

File: SIMULATION/reports/exp_05_state_scenarios.md
Version: 0.1.0-protocol
Experiment ID: STRATIM-EXP-05
Status: Complete

---

Purpose

Validate the state classifier (Section 6.10 priority rule) on
synthetic scenarios with known target regions. This is a pipeline
validation, not a model test: it checks whether the classifier
recovers the configurations we deliberately constructed.

---

Design

Parameter Value
Scenarios 3B, 3A, J
N per scenario 200
τ_SIC 0.50
τ_O 0.40
Margin around thresholds 0.15
Seed 1234 (fixed for reproducibility)
DGP Independent from 00_dgp.R (state-construction only)

Scenario definitions:

· 3B: O ≤ τ_O AND SIC > τ_SIC (objective closure with preserved SIC)
· 3A: SIC ≤ τ_SIC (internal SIC erosion)
· J: O ≤ τ_O AND SIC ≤ τ_SIC (joint closure membership)

---

Result

Scenario N Matching Target Fraction Status
3B 200 200 1.00 PASS
3A 200 200 1.00 PASS
J 200 200 1.00 PASS
Priority rule — — — PASS

Validation checks performed:

1. Check 1 — 3B scenario: fraction classified as 3B = 1.00 (expected > 0.95). PASS.
2. Check 2 — 3A scenario: fraction classified as 3A = 1.00 (expected > 0.95). PASS.
3. Check 3 — J scenario: fraction satisfying J membership = 1.00, fraction classified as 3A = 1.00 (priority rule). PASS.
4. Check 4 — Priority rule: all observations with SIC ≤ τ_SIC classified as 3A. PASS.

---

Key Findings

No confusion between 3A and 3B. Each scenario produces the
intended classification without leakage.

J is correctly handled as a membership region. It is not a
priority class. Under the priority rule, observations in J are
classified as 3A (since SIC ≤ τ_SIC). The J membership is tracked
separately in the output column J_true.

Priority rule is deterministic and correct. The specification
in Section 6.10 maps each (SIC, O) pair to exactly one of
{3A, 3B, 1, 2}, with J as an overlay.

---

Interpretation

What this means. The state-construction pipeline functions as
specified. The classifier does not introduce ambiguity in regions
where the target state is clearly defined.

What this does not mean. This does not validate the classifier
under measurement noise, near-threshold observations, or missing
data. Those are real-data conditions that the synthetic scenarios
deliberately exclude.

---

Limitations

· Synthetic scenarios are generated with a clear margin around
  thresholds. Real data will include near-threshold observations
  that are harder to classify.
· The DGP here is independent from 00_dgp.R — it does not test
  the dynamic model, only state construction.
· Threshold sensitivity (τ_SIC ± 0.05, τ_O ± 0.05) is not tested
  here. It is listed in the sensitivity analysis plan
  (ANALYSIS/README.md).
· No measurement error, no missing data, no multi-wave transitions.

---

Reproducibility

Script: SIMULATION/code/04_state_scenarios.R
Inputs: none
Outputs:

· SIMULATION/results/04_state_scenarios.csv (600 rows)

Replicates: not applicable (deterministic given seed)
Seed policy: fixed seed = 1234 per scenario
Runtime: < 30 seconds
R version: 4.5.2 (Ubuntu 22.04 in proot)
Status: Complete

Regeneration:

```bash
Rscript SIMULATION/code/04_state_scenarios.R
```

---

Related Documents

· DOCS/decision_rules.md (Section 3 — State Classification Thresholds)
· PREREGISTRATION/analysis_plan.md (Section 4 — State Construction)
· EXPERIMENTS.md (Experiment 05 summary)

---

End of exp_05_state_scenarios.md
