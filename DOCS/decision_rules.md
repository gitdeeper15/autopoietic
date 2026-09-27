# STRATIM — Decision Rules

**File:** `DOCS/decision_rules.md`
**Version:** 0.1.0-protocol
**Scope:** All pre-specified thresholds used in hypothesis testing

This document consolidates every decision rule used in STRATIM.
Its purpose is to make the thresholds auditable and to prevent
post hoc adjustment after seeing data.

---

## 1. Why Pre-Specified Rules Matter

A hypothesis test that uses a threshold chosen after seeing the
data is not a hypothesis test; it is a description of the data.
STRATIM therefore fixes all thresholds **before** data collection
using one of three sources:

1. **Independent calibration sample** — a separate sample used
   only to estimate the threshold.
2. **Criterion-referenced procedure** — an expert panel sets the
   threshold by consensus, with rationale.
3. **Measurement-error framework** — the threshold is set from
   the measurement resolution itself.

The main study sample is never used to define its own thresholds.

---

## 2. The Three Core Thresholds

| Symbol | Name | Applies to | Role |
|--------|------|------------|------|
| ε | Smallest effect of practical interest | H1 | ROPE boundary |
| MID | Minimum important difference | H2 | Opportunity gap equivalence |
| Δ*_AUC | Diagnostic equivalence margin | H3 | Behavioral classifier sufficiency |

These three thresholds are set independently but with the same
discipline.

---

### 2.1 ε — Smallest Effect of Practical Interest

**Applies to:** H1 (closure-to-erosion)

**Definition:** The smallest standardized α₀ that would be
considered substantively consequential — i.e., the smallest
association between cumulative closure exposure and SIC decline
that would change a downstream decision.

**Source:** One of:
1. Independent calibration sample (smallest α₀ predicting
   meaningful Execution change).
2. Criterion-referenced panel.
3. Measurement-error framework (width of the 95% interval
   of α₀ in pilot).

**Decision rule for H1.** Let `CI(α₀)` be the 95% credible
interval.

- **Supported:** `inf CI(α₀) > ε`
- **No evidence of a practically important association:**
  `CI(α₀) ⊆ [−ε, ε]`
- **Inconclusive:** `CI(α₀)` intersects `[−ε, ε]` but is not
  contained within it.

**Non-overlap.** The three categories are mutually exclusive
and exhaustive. No interval satisfies two conditions.

**Why not use zero?** A coefficient of 0.02 with a narrow
interval may be statistically distinguishable from zero but
practically trivial if ε = 0.10. The ROPE rule aligns the
decision criterion with substantive importance.

---

### 2.2 MID — Minimum Important Difference

**Applies to:** H2 (objective/perceived opportunity dissociation)

**Definition:** The smallest difference between
`O^objective` and `O^perceived` that is considered
substantively consequential.

**Source:** One of:
1. Independent calibration sample (distribution of |ΔO| under
   a no-dissociation null).
2. Measurement-error framework: `MID = 1.96 × √2 × σ_meas`,
   where σ_meas is the pooled measurement error of the two
   instruments.
3. Criterion-referenced panel.

**Decision rule for H2.**

- **Supported:** mean `|ΔO|` > MID, with 95% interval excluding
  the MID boundary.
- **Weakened:** mean `|ΔO|` ≤ MID with 95% interval entirely
  below MID.
- **Inconclusive:** interval contains MID.

---

### 2.3 Δ*_AUC — Diagnostic Equivalence Margin

**Applies to:** H3 (behavioral equifinality / diagnostic sufficiency)

**Definition:** The largest difference between the AUC of the
full state-variable model and the AUC of a behavior-only
classifier that would still be considered diagnostically
equivalent.

**Source:** One of:
1. Independent calibration sample.
2. Criterion-referenced panel (the largest difference that
   would not change a downstream decision about distinguishing
   3A from 3B).
3. Measurement-error framework (width of the 95% interval of
   the AUC estimate in the calibration sample).

**Decision rule for H3.** Let:

```

Δ_AUC = AUC(full) − AUC(behavior-only)

```

- **Diagnostic insufficiency (H3 supported):**
  `Δ_AUC > Δ*_AUC` with 95% interval excluding Δ*_AUC.
- **No evidence of diagnostic insufficiency (H3 weakened):**
  interval for `Δ_AUC` lies entirely within
  `(−Δ*_AUC, Δ*_AUC)`.
- **Inconclusive:** otherwise.

**Note:** This mirrors the MID logic for H2. Both use a
pre-specified margin from an independent source and both
separate "evidence for difference" from "evidence for
equivalence."

---

## 3. State Classification Thresholds

### 3.1 τ_SIC — SIC Threshold

**Applies to:** Classification of 3A vs. not-3A.

**Definition:** The value of SIC below which SIC is considered
substantively eroded.

**Source:** Independent calibration sample or pre-registered
normative procedure. Never from the main study.

**Used in:**
- 3A: `SIC ≤ τ_SIC` (regardless of O)
- 3B: `SIC > τ_SIC` AND `O^objective ≤ τ_O`
- J: `SIC ≤ τ_SIC` AND `O^objective ≤ τ_O`

### 3.2 τ_O — Opportunity Threshold

**Applies to:** Classification of restricted opportunity.

**Definition:** The value of `O^objective` below which the
opportunity set is considered restricted.

**Source:** Same as τ_SIC.

**Used in:**
- Eligibility for H1: `O^objective ≤ τ_O`
- 3B: `SIC > τ_SIC` AND `O^objective ≤ τ_O`
- J: same as 3B + `SIC ≤ τ_SIC`

### 3.3 Priority rule for transition matrices

When a transition matrix is reported, a fixed priority order
applies to avoid double classification:

1. If `SIC ≤ τ_SIC` → classify as **3A** (regardless of O).
2. Else if `O^objective ≤ τ_O` → classify as **3B**.
3. Else if `O^objective > 0` under chronic constraint → **1**.
4. Else → **2** (intermediate).

This priority is fixed in advance and does not change between
analyses.

---

## 4. Recovery Thresholds (H1b)

### 4.1 τ_G — Recovery Threshold

**Applies to:** H1b (recovery threshold)

**Definition:** The level of recovery G below which recovery
has no measurable protective effect on SIC.

**Source:** Independent calibration sample or criterion-referenced
procedure.

**Decision rule for H1b.** Compare additive vs. threshold
specifications.

- **Threshold supported:** threshold specification provides
  substantially better predictive accuracy (LOO-CV difference
  > 2 standard errors) AND γ₂ > 0 with 95% interval excluding
  zero.
- **Not supported:** additive specification fits as well or
  better.

### 4.2 τ_T, τ_C — Time and Calm Thresholds

**Applies to:** H1b (recovery gating)

**Definition:** The minimum unstructured time (τ_T) and minimum
internal quiescence (τ_C) below which recovery has no
protective effect.

**Source:** Fixed in advance (e.g., 25th percentile of
observed T and C in calibration sample).

**Sensitivity analysis:** Re-run H1b across a grid of τ_T, τ_C
values (± 0.5 SD) and report the stability of γ₂.

---

## 5. H1c Reference Point

### 5.1 E*_ref — Reference Exposure Level

**Applies to:** H1c (closure × rehearsal intensification)

**Definition:** The value of accumulated exposure E at which
the primary test for H1c is evaluated.

**Source:** One of:
1. Median of E in calibration sample.
2. Criterion-referenced value below which rehearsal is not
   expected to attenuate closure effects.
3. E*_ref = 1 SD above the calibration-sample mean.

**Primary test:**

```

δ₁ + 2 δ₂ E*_ref > 0

```

**Interpretation:**

- **Supported:** posterior interval for `δ₁ + 2 δ₂ E*_ref`
  lies entirely above zero.
- **Partially supported:** lies above zero for E above some
  threshold E* within the observed range, but not at E*_ref.
- **Not supported:** interval includes zero for most of the
  observed range.

**Full E-range:** reported as descriptive, not confirmatory.

---

## 6. Kernel Comparison (H5)

### 6.1 Identifiability precondition

Before H5 is tested, the design-level identifiability check
(`SIMULATION/code/01_H5_identifiability.R`) must show that the
design can distinguish exponential from power-law kernels in
at least part of the parameter grid.

If it cannot, H5 is reported as **not testable within the
window**, regardless of sample size.

### 6.2 Decision rule for H5

- **Supported for a kernel:** one kernel provides substantially
  better predictive accuracy (LOO-CV difference > 2 standard
  errors) than the other, AND the estimated parameters
  (λ or ρ) are not at boundary values.
- **Undetermined:** neither kernel is clearly favored.
- **Not testable:** simulation indicates the design cannot
  distinguish the two kernels within the window.

**Scope limitation:** Any conclusion is restricted to
`0 ≤ t ≤ 18 months`. No extrapolation beyond the window.

---

## 7. Underpowered Hypotheses

**Rule:** If simulation indicates insufficient power for a
pre-registered primary test at the target N, the test is
reported as **underpowered**, and **no confirmatory inference
is drawn**.

**Not permitted:** Using sensitivity analysis to compensate
for insufficient power. Sensitivity analysis assesses
robustness of adequately powered estimates, not rescue of
underpowered ones.

**Design-stage decision:** If simulation indicates a primary
test is underpowered at the target N **before data collection**,
either N is increased or the test is demoted to secondary. This
decision is made at design stage.

---

## 8. Multiple Testing

Primary hypotheses (H1, H1a, H1c, H1d, H2, H4, H5) form one
family. Secondary hypotheses (H1b, H3) form another family.

Benjamini-Hochberg FDR control (α = 0.05) is applied
separately within each family.

H1c is tested at E*_ref as the primary test. The full E-grid is
reported descriptively without adjustment (see Section 5.1).

---

## 9. Summary Table

| Symbol | Applies to | Source | Decision role |
|--------|------------|--------|---------------|
| ε | H1 | Calibration / panel / measurement error | ROPE boundary |
| MID | H2 | Calibration / panel / measurement error | Equivalence |
| Δ*_AUC | H3 | Calibration / panel / measurement error | Diagnostic equivalence |
| τ_SIC | State classification | Calibration | 3A boundary |
| τ_O | State classification | Calibration | 3B boundary |
| τ_G | H1b | Calibration / panel | Recovery threshold |
| τ_T, τ_C | H1b | Fixed in advance | Recovery gating |
| E*_ref | H1c | Calibration / panel | Reference exposure |

---

## 10. What These Rules Do Not Do

These rules do **not**:

- Determine which hypotheses are true.
- Replace substantive judgment about effect sizes.
- Allow the main study to define its own thresholds.
- Permit post hoc adjustment.

They specify, in advance, what pattern of evidence would be
treated as support, weakness, or inconclusiveness for each
pre-registered hypothesis.

---

**End of `DOCS/decision_rules.md`**

---

## 2.4 H1d Design-Based Testability Condition

**Applies to:** H1d (individual sensitivity heterogeneity: σ²_α > 0)

**Nature of the condition.** This is not a threshold on the true
value of σ_α (which is unknown before the study). It is a
**design-based testability condition**, derived from the
pre-registered simulation grid.

**Statement.** H1d is considered adequately testable within the
present four-wave, 18-month design only for heterogeneity
magnitudes that achieve the pre-specified power criterion
(0.80) under the preregistered simulation grid.

**Evidence from simulation.** In the Monte Carlo power surface
(`SIMULATION/results/03_power_surface.csv`), σ_α = 0.02 remained
below 0.80 power even at N = 500. Therefore, heterogeneity of
this magnitude is not reliably testable within the present
design.

**Decision rule for H1d.** After data collection, the observed
posterior for σ²_α is interpreted as follows:

- **Supported:** 95% credible interval for σ²_α excludes zero,
  AND the observed data are consistent with heterogeneity
  magnitudes within the adequately-testable region of the
  design (σ_α ≥ 0.05 under the preregistered grid).
- **Not testable within the window:** the observed interval is
  compatible with σ_α < 0.05, indicating that the design
  cannot distinguish "very small heterogeneity" from "no
  heterogeneity." In this case, H1d is reported as **not
  testable** rather than as "not supported."
- **Not supported:** the interval includes zero AND the observed
  point estimate is close to zero.

**Rationale.** Reporting "not supported" when the design cannot
distinguish small σ_α from zero would misrepresent a limitation
of the design as a finding about the phenomenon. The distinction
between "not supported" and "not testable" is preserved.

**Scope.** This condition is a property of the four-wave,
three-transition design. Increasing N does not remove it.
Addressing smaller σ_α would require additional waves
(more within-individual transitions).
