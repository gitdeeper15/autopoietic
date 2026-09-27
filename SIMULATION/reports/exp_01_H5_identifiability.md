# Experiment 01 — H5 Kernel Identifiability

**File:** `SIMULATION/reports/exp_01_H5_identifiability.md`
**Version:** 0.1.0-protocol
**Experiment ID:** STRATIM-EXP-01
**Status:** Complete

---

## Purpose

Determine whether the pre-specified design (18 months, 4 waves at
t = 0, 6, 12, 18) can distinguish **exponential** from **power-law**
temporal kernels based on the shape of the exposure trajectory
`E_t` alone, before any parameter estimation.

This is a design-level check. It does not depend on sample size.
It answers: *is the question itself identifiable within the
observation window?*

---

## Hypothesis Under Test

**H5 — Kernel Persistence.** Exponential and power-law kernels
fit differently within the observed window.

If the design cannot distinguish the two kernels in a given region
of (λ, ρ), H5 is reported as **not testable within the window** for
that region, regardless of N.

---

## Design

| Parameter | Values |
|-----------|--------|
| λ (exponential decay rate) | 0.10, 0.30, 0.50, 1.00 |
| ρ (power-law exponent) | 0.50, 1.00, 1.50, 2.50 |
| Replicates per cell | 200 |
| Cells | 16 |
| Waves | t = 0, 6, 12, 18 |
| Metric | median correlation between normalized E_exp and E_pow across waves 6, 12, 18 |

---

## Result

| λ | ρ | median correlation |
|---|---|--------------------|
| 1.00 | 2.50 | 0.9974 |
| 0.10 | 0.50 | 0.9970 |
| 0.50 | 1.50 | 0.9895 |
| 1.00 | 1.50 | 0.9820 |
| 0.30 | 1.50 | 0.9808 |
| 0.50 | 2.50 | 0.9724 |
| 0.30 | 1.00 | 0.9629 |
| 0.10 | 1.00 | 0.9504 |
| 0.30 | 2.50 | 0.9213 |
| 0.50 | 1.00 | 0.8759 |
| 1.00 | 1.00 | 0.8224 |
| 0.30 | 0.50 | 0.7716 |
| 0.10 | 1.50 | 0.7517 |
| 0.50 | 0.50 | 0.4411 |
| 0.10 | 2.50 | 0.3697 |
| 1.00 | 0.50 | 0.3691 |

**Aggregate:**
- Minimum median correlation: **0.3691** (most distinguishable)
- Maximum median correlation: **0.9974** (least distinguishable)
- Status: **testable_regions**

---

## Decision Rule Applied

Per `DOCS/decision_rules.md` Section 6 and
`DOCS/kernel_specification.md` Section 4:

- If **all** cells have median correlation > 0.95 → not testable.
- If **all** cells have median correlation < 0.90 → testable everywhere.
- Otherwise → testable only in distinguishable regions.

**Outcome:** the third case. H5 is testable **only** in the regions
where median correlation < 0.90.

---

## Interpretation

**What this means.** The 18-month, 4-wave design does not have
uniform power to distinguish exponential from power-law kernels.
In the highest-correlation cells (top of the table), the two
kernels produce nearly identical exposure trajectories at the
observed waves, so no amount of additional data can resolve them.
In the lowest-correlation cells (bottom of the table), the two
kernels diverge substantially within the window, so the design
can discriminate them.

**What this does not mean.** This experiment does **not** conclude
that one kernel is better than the other. It does not estimate λ
or ρ from data. It only says: *given a true kernel in region X of
the parameter space, can the design tell the two apart?*

**Methodological consequence.** H5's decision rule must be applied
conditionally. If the estimated (λ, ρ) falls in a high-correlation
region of the grid, H5 is reported as **not testable within the
window** rather than as "not supported."

---

## Limitations

- Only 2 kernel forms compared (exponential, power-law). Other
  parametric forms (Weibull, stretched exponential, spline) are
  not tested.
- Grid is finite: intermediate (λ, ρ) values not explored.
- Identifiability of higher-order kernel differences (tail
  behavior) is not addressed; only shape within the 18-month
  window is tested.

---

## Reproducibility

**Script:** `SIMULATION/code/01_H5_identifiability.R`
**Inputs:** none (self-contained)
**Outputs:**
- `SIMULATION/results/01_H5_identifiability.csv` (raw, 3200 rows)
- `SIMULATION/results/01_H5_identifiability_summary.csv` (16 rows)

**Replicates:** 200 per cell
**Seed policy:** per-replicate seeds derived from `1000 + rep_index`
**Runtime:** ~1–3 minutes on the reference setup
**R version:** 4.5.2 (Ubuntu 22.04 in proot)
**Status:** Complete

**Regeneration:**
```bash
Rscript SIMULATION/code/01_H5_identifiability.R
```

---

Related Documents

· DOCS/kernel_specification.md (Sections 3, 4, 5)
· DOCS/decision_rules.md (Section 6)
· EXPERIMENTS.md (Experiment 01 summary)

---

End of exp_01_H5_identifiability.md
