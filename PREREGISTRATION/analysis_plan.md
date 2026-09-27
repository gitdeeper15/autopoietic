# STRATIM — Analysis Plan

**File:** `PREREGISTRATION/analysis_plan.md`
**Version:** 0.1.0-protocol
**Corresponds to:** Section 7 of the manuscript

This document consolidates the analysis plan for the OSF
pre-registration. It does not introduce new hypotheses or
decision rules. Full derivations are in
`RESEARCH_PAPER/STRATIM_Research_Paper.md`.

---

## 1. Analysis Logic

```

measurements
↓
audited states
↓
exposure construction
↓
dynamic model
↓
hypothesis-specific tests

```

Each stage is conditional on the previous stage. No stage may
be skipped. No hypothesis may be tested before the
measurement validation of its constituent variables is
complete.

---

## 2. Data Assembly

### 2.1 Wave structure

Four principal waves: t₀, t₆, t₁₂, t₁₈.

Monthly closure detection between waves.

Continuous rehearsal logging and execution records.

### 2.2 Temporal alignment

For individual i and wave t:

```

E_it^{≤ t} = ∫₀ᵗ K(t − τ) · S_closure^audit(τ) dτ

```

Closure events after time t do not enter E_it. This prevents
temporal leakage.

Aggregated R and G over each inter-wave interval:

```

R_{i,t:t+1} = mean(R over interval)
G_{i,t:t+1} = mean(G over interval)

```

### 2.3 Transition windows

Three transitions per individual:

```

t₀ → t₆,  t₆ → t₁₂,  t₁₂ → t₁₈

```

Each transition produces one observation.

---

## 3. Measurement Validation (Section 7.2)

Conducted before hypothesis testing.

### 3.1 Criteria

| Criterion | Adequate | Marginal | Inadequate |
|-----------|----------|----------|------------|
| SIC ω | ≥ .70 | .60–.69 | < .60 |
| SIC ICC (per dimension) | ≥ .75 | .60–.74 | < .60 |
| Audit κ (per domain) | ≥ .70 | .50–.69 | < .50 |
| Detection sensitivity | ≥ .70 | .60–.69 | < .60 |

### 3.2 Responses

- **Adequate:** variable used as specified.
- **Marginal:** analyzed with explicit caveat; composite not
  used if components fail.
- **Inadequate:** hypothesis reported as **not testable** under
  the observed measurement conditions.

---

## 4. State Construction (Section 7.3)

Build:

- `O^objective_it` — domain-level vector.
- `O^perceived_it` — matched vector.
- `SIC_it` — composite only if factor analysis supports it.
- `ΔO_it` — for H2.

Classify into reference regions using thresholds τ_SIC and τ_O
from an independent calibration sample.

Priority rule for transition matrices (fixed in advance):

1. SIC ≤ τ_SIC → 3A
2. O^objective ≤ τ_O → 3B
3. O^objective > 0 → 1
4. Otherwise → 2

---

## 5. Exposure Construction (Section 7.4)

Two kernels:

```

E_exp_it = ∫ exp(−λ(t−τ)) S_closure^audit(τ) dτ
E_pow_it = ∫ (1 + t − τ)^(−ρ) S_closure^audit(τ) dτ

```

Flexible kernel included only if simulation indicates
sufficient power.

Standardization within each wave.

Observations with missing monthly data > 20% are flagged
low-confidence and analyzed separately.

---

## 6. Primary Dynamic Model (Section 7.5)

### 6.1 Model

```

SIC_{i,t+1} = φ · SIC_{i,t}
− α_i · E_{i,t}
+ β · R_{i,t:t+1}
+ γ · G_{i,t:t+1}
+ δ₁ · (E_{i,t} · R_{i,t:t+1})
+ δ₂ · (E_{i,t}² · R_{i,t:t+1})
+ η · (E_{i,t} · G_{i,t:t+1})
+ u_i
+ ε_{i,t}

```

with:

```

α_i = α₀ + b_i,   b_i ~ N(0, σ²_α)
u_i              ~ N(0, σ²_u)
ε_{i,t}          ~ N(0, σ²_ε)

```

### 6.2 Estimation

**Primary:** Bayesian hierarchical, HMC (Stan).

**Sensitivity:** Frequentist mixed-effects (lme4, REML).

Priors are weakly informative and fixed in advance. They are
not adjusted based on observed data.

### 6.3 Model reduction sequence

If convergence fails, applied in order:

1. Full model.
2. Remove δ₂.
3. Remove random slope for E.
4. Exponential kernel only.
5. Intercept-only with fixed kernel.

Priors are not changed. The reduction sequence is the only
response.

### 6.4 Nested comparisons

1. Additive vs. interaction (H1a, H1c).
2. Additive recovery vs. threshold recovery (H1b).
3. Exponential vs. power-law kernel (H5).

Comparison uses LOO-CV or WAIC, with standard errors.

---

## 7. Hypothesis Tests (Section 7.6)

Each hypothesis is tested with its pre-specified decision
rule. See `hypotheses.md` for the full decision rules.

### 7.1 Primary family

- **H1:** ROPE-based, ε boundary.
- **H1a:** δ₁ > 0.
- **H1c:** δ₁ + 2δ₂ E*_ref > 0.
- **H1d:** σ²_α > 0.
- **H2:** mean |ΔO| > MID.
- **H4:** event-contingent trajectory comparison.
- **H5:** LOO-CV kernel comparison.

### 7.1b Design-Based Testability for H1d

H1d (σ²_α > 0) is tested conditionally on the design’s
ability to distinguish the observed level of heterogeneity
from zero. The present four-wave design has a pre-specified
power boundary:

- σ_α ≥ 0.05 → adequately testable at N = 300.
- σ_α = 0.02 → not reliably testable even at N = 500.

After data collection, if the posterior interval for σ²_α
is compatible with σ_α < 0.05, H1d is reported as
**not testable within the window**, not as “not supported.”

This preserves the distinction between evidence of absence
and absence of evidence. See `DOCS/decision_rules.md`
Section 2.4 and `SIMULATION/results/03_power_surface.csv`.

### 7.2 Secondary family

- **H1b:** threshold vs. additive.
- **H3:** Δ_AUC > Δ*_AUC.

### 7.3 Exploratory

- Domain-level effects.
- Wave-specific effects.
- Relationship between SIC and |ΔO|.

Exploratory analyses are reported without adjustment and
flagged as exploratory.

---

## 8. Missing Data (Section 7.7)

### 8.1 Primary assumption

Missing at random (MAR), conditional on observed variables.

### 8.2 Methods

Multiple imputation by chained equations (MICE) with 50
imputations, or direct Bayesian missing-outcome modeling,
depending on the multilevel structure.

### 8.3 Sensitivity

Missing not at random (MNAR) pattern-mixture model. The
missingness mechanism is allowed to depend on SIC trajectory.

Discrepancies between MAR and MNAR estimates are reported
explicitly.

---

## 9. Sensitivity Analyses (Section 7.8)

Pre-registered:

1. Threshold variation (± 0.5 SD).
2. SIC composite vs. dimensions.
3. Alternative recovery specifications.
4. Alternative kernels.
5. Exclusion of low-confidence exposure intervals.
6. MAR vs. MNAR.
7. Outlier sensitivity (top/bottom 5% of E).
8. Subsample with high detection concordance.

Results are reported in a structured table alongside primary
results.

---

## 10. Multiple Testing (Section 7.9)

- Primary family: H1, H1a, H1c, H1d, H2, H4, H5.
- Secondary family: H1b, H3.

Benjamini-Hochberg FDR = 0.05, applied separately within each
family.

H1c primary test is at E*_ref. The E-grid is descriptive.

---

## 11. Simulation-Based Power (Section 6.12, Section 7.14)

Monte Carlo simulation across a grid of N, effect sizes,
σ²_α, ICC, and attrition.

The result is a power surface, not a single MDE number.

### 11.1 Decision rule if underpowered

If a primary test is underpowered at the target N **before
data collection**:

- Either increase N, or
- Demote the test to secondary.

This decision is made at design stage.

### 11.2 Not permitted

Using sensitivity analysis to compensate for insufficient
power. Sensitivity analysis assesses robustness of adequately
powered estimates, not rescue of underpowered ones.

---

## 12. Falsification Logic (Section 7.11)

Each hypothesis has a pre-specified disconfirming region:

| Hypothesis | Disconfirming pattern |
|------------|----------------------|
| H1 | Effect interval within practical-null region |
| H1a | No positive moderation |
| H1b | Threshold model does not improve prediction |
| H1c | Cross-partial does not become positive at E*_ref |
| H1d | Negligible heterogeneity |
| H2 | |ΔO| within practical-equivalence region |
| H3 | Behavioral-only model performs comparably |
| H4 | Trajectory distinction absent or untestable |
| H5 | Kernels cannot be distinguished |

Disconfirmation is reported at the level of the specific
hypothesis, not as a global verdict.

---

## 13. Reporting Limits (Section 7.12)

The analysis does not infer:

- Causality.
- Prevalence.
- Clinical diagnosis.
- Intervention efficacy.
- Persistence beyond the observation period.

---

## 14. Order of Reporting

Results are reported in this order:

1. Measurement validation.
2. Descriptive state distribution.
3. Exposure construction.
4. Primary model.
5. Hypothesis tests.
6. Missing data and attrition.
7. Sensitivity analyses.
8. Multiple testing summary.
9. Simulation results.
10. Falsification summary.

No result is reported without its corresponding uncertainty
estimate. No hypothesis is reported as "confirmed."

---

## What this document does not do

- Does not introduce new analyses.
- Does not change decision rules after data collection.
- Does not specify numerical thresholds (set from
  calibration).
- Does not replace the full protocol
  (`PREREGISTRATION/protocol.md`) or the manuscript
  (`RESEARCH_PAPER/STRATIM_Research_Paper.md`).

Changes to this document after pre-registration are reported
as protocol amendments.

---

**End of `PREREGISTRATION/analysis_plan.md`**
