# STRATIM — Hypotheses

**File:** `PREREGISTRATION/hypotheses.md`
**Version:** 0.1.0-protocol
**Purpose:** Consolidated list of all pre-registered hypotheses
and their corresponding decision rules.

This document is a reference for the OSF pre-registration and
for the analysis stage. It does not introduce new hypotheses
or modify existing ones.

---

## Dependency structure

```

H2 → H3 → H1 → (H1a, H1b, H1c, H1d) → H4
H5 (parallel)

```

H2 is a validity condition for H3.
H3 is a validity condition for H4.
H1 is prior to H1a–H1d.
H1c presupposes H1a.
H5 is orthogonal.

---

## H1 — Closure-to-Erosion

**Statement.** Among individuals entering the study with
preserved SIC and objectively restricted opportunity, greater
cumulative closure exposure is associated with subsequent
SIC decline.

**Formal.** α₀ > ε, where ε is the smallest effect of
practical interest.

**Decision rule.** Let CI(α₀) be the 95% credible interval.

- **Supported:** inf CI(α₀) > ε
- **No evidence of a practically important association:**
  CI(α₀) ⊆ [−ε, ε]
- **Inconclusive:** CI(α₀) intersects [−ε, ε] but is not
  contained within it.

The three categories are mutually exclusive and exhaustive.

---

## H1a — Rehearsal Moderation

**Statement.** Rehearsal attenuates the negative association
between closure exposure and SIC.

**Formal.** δ₁ > 0 in the primary model.

**Decision rule.** Supported if the 95% credible interval for
δ₁ lies entirely above zero.

---

## H1b — Recovery Threshold

**Statement.** Recovery has a conditional rather than purely
additive protective effect on SIC.

**Formal.** γ₂ > 0 in the threshold specification:

```

γ₁ · G + γ₂ · G · 1(T > τ_T, C > τ_C)

```

**Decision rule.** Supported if:
- The threshold specification provides substantially better
  predictive accuracy (LOO-CV difference > 2 SE) than the
  additive specification, AND
- γ₂ > 0 with 95% interval excluding zero.

Not supported if the additive specification fits as well or
better.

**Classification.** Secondary hypothesis (see `analysis_plan.md`).

---

## H1c — Closure × Rehearsal Intensification

**Statement.** The protective moderation of rehearsal
becomes stronger as cumulative closure exposure increases.

**Formal.** δ₁ + 2δ₂ E*_ref > 0, where δ₁ and δ₂ are the
first- and second-order exposure × rehearsal coefficients.

**Decision rule.**
- **Supported:** posterior interval for δ₁ + 2δ₂ E*_ref lies
  entirely above zero.
- **Partially supported:** lies above zero for E above some
  threshold E* within the observed range, but not at E*_ref.
- **Not supported:** interval includes zero for most of the
  observed range.

**Conditional interpretation.** H1c is estimated
unconditionally but interpreted conditionally on H1a. If H1a
is unsupported, H1c is reported but not interpreted as
evidence for intensification.

**Multiple testing.** H1c is tested at E*_ref as the primary
test. The full E-grid is descriptive.

---

## H1d — Individual Sensitivity Heterogeneity

**Statement.** Individuals differ in their estimated
sensitivity to closure exposure.

**Formal.** σ²_α > 0 in the hierarchical model:

```

α_i = α₀ + b_i,   b_i ~ N(0, σ²_α)

```

**Decision rule.** Supported if the 95% credible interval for
σ²_α excludes zero.

If σ²_α is indistinguishable from zero, the model collapses
to a constant-sensitivity specification.

**Interpretation caution.** α_i is an estimated parameter,
not a psychological trait. Baseline predictors (CD-RISC,
social support) are tested as secondary, not as construct
validity for a trait.

---

## H2 — Objective/Perceived Opportunity Dissociation

**Statement.** Objective and perceived opportunity are not
equivalent under the study's measurement framework.

**Formal.** mean |ΔO| > MID, where ΔO = O^objective − O^perceived.

**Decision rule.**
- **Supported:** mean |ΔO| > MID with 95% interval excluding
  the MID boundary.
- **Weakened:** 95% interval for mean |ΔO| lies entirely below
  MID.
- **Inconclusive:** otherwise.

**Validity condition.** H2 is a validity condition for H3.
If H2 fails, the distinction between 3A and 3B becomes harder
to maintain empirically.

**Exploratory.** The relationship between SIC and |ΔO| is
reported descriptively, not as a hypothesis test.

---

## H3 — Behavioral Equifinality of Non-Execution

**Statement.** Non-execution alone is diagnostically
insufficient to distinguish 3A from 3B.

**Formal.** Δ_AUC > Δ*_AUC, where
Δ_AUC = AUC(full) − AUC(behavior-only).

**Decision rule.**
- **Diagnostic insufficiency (H3 supported):**
  Δ_AUC > Δ*_AUC with 95% interval excluding Δ*_AUC.
- **No evidence of insufficiency (H3 weakened):**
  interval for Δ_AUC lies within (−Δ*_AUC, Δ*_AUC).
- **Inconclusive:** otherwise.

**Classification.** Secondary hypothesis (see `analysis_plan.md`).

**Note.** The threshold Δ*_AUC is set from an independent
calibration sample or a criterion-referenced procedure, not
from the main study.

---

## H4 — Differential Recovery Pathways

**Statement.** After opportunity reopening:

- 3B cases transition toward Stage 1 without intermediate
  SIC decline.
- 3A cases show progressive SIC recovery.

**Formal.** Event-contingent longitudinal analysis. Pre-event
and post-event SIC measured within a pre-specified window.

**Decision rule.** Supported if:
- The 3B group shows no significant decline in SIC between
  pre and post.
- The 3A group shows a positive SIC trajectory across
  post-event waves.
- The two trajectories are statistically distinguishable.

**Testability condition.** If fewer than a pre-specified
minimum number of reopening events occur across the sample,
H4 is reported as **not testable within the observation
window**.

**Interpretation caution.** H4 concerns descriptive
within-individual change. It does not establish causal
effects of reopening.

---

## H5 — Kernel Persistence

**Statement.** Exponential and power-law kernels fit
differently within the observed 18-month window.

**Formal.** LOO-CV or WAIC comparison between
Model E (exponential) and Model P (power-law).

**Precondition.** Design-level identifiability must pass
(`SIMULATION/code/01_H5_identifiability.R`). If the design
cannot distinguish the two kernels, H5 is reported as **not
testable within the window**.

**Decision rule.**
- **Supported for a kernel:** one kernel provides substantially
  better predictive accuracy (LOO-CV difference > 2 SE) than
  the other, AND the estimated parameter (λ or ρ) is not at a
  boundary value.
- **Undetermined:** neither kernel is clearly favored.
- **Not testable:** identifiability fails.

**Scope limitation.** Any conclusion is restricted to
0 ≤ t ≤ 18 months.

---

## Summary table

| Hypothesis | Formal test | Primary / Secondary | Threshold |
|------------|-------------|---------------------|-----------|
| H1 | α₀ > ε | Primary | ε |
| H1a | δ₁ > 0 | Primary | — |
| H1b | γ₂ > 0, LOO-CV | Secondary | τ_G, τ_T, τ_C |
| H1c | δ₁ + 2δ₂E*_ref > 0 | Primary (conditional on H1a) | E*_ref |
| H1d | σ²_α > 0 | Primary | — |
| H2 | mean |ΔO| > MID | Primary | MID |
| H3 | Δ_AUC > Δ*_AUC | Secondary | Δ*_AUC |
| H4 | trajectory comparison | Primary | event count |
| H5 | LOO-CV comparison | Primary | identifiability |

---

## What this document does not do

- Does not introduce new hypotheses.
- Does not alter decision rules after data collection.
- Does not specify the exact numerical values of thresholds
  (these are set from an independent calibration sample).

Changes to this document after pre-registration are reported
as protocol amendments.

---

**End of `PREREGISTRATION/hypotheses.md`**
