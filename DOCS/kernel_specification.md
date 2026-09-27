# STRATIM — Kernel Specification

**File:** `DOCS/kernel_specification.md`
**Version:** 0.1.0-protocol
**Scope:** Temporal memory of closure exposure (H5)

This document specifies how accumulated closure exposure
`E_t` is constructed, which kernels are compared, and what
can and cannot be inferred from the comparison.

---

## 1. Why Temporal Memory Matters

Chronic material pressure is not a point event. It accumulates.
The theoretical model (Section 3.4) treats closure exposure as
a temporally weighted sum of past closure events:

```

E_t = ∫₀ᵗ K(t − τ) S_closure(τ) dτ

```

where:

- `S_closure(τ)` = severity of objective opportunity closure
  at time τ.
- `K(Δ)` = kernel function describing how much a past closure
  event still matters at distance Δ.
- `E_t` = accumulated effective exposure at time t.

The choice of `K` determines whether past closures are treated
as short-lived, persistent, or long-tailed. That is the H5
question.

---

## 2. The Two Candidate Kernels

### 2.1 Exponential

```

K_E(Δ) = exp(−λ Δ)

```

- Single parameter: λ (decay rate).
- Memory fades geometrically. Half-life = ln(2)/λ.
- Well-behaved, easy to estimate.
- Implies that very old closures have negligible effect.

### 2.2 Power-law

```

K_P(Δ) = (1 + Δ)^(−ρ)

```

- Single parameter: ρ (decay exponent).
- Memory fades slowly, with a heavy tail.
- Implies that very old closures can still contribute
  non-negligibly to current exposure.
- Harder to estimate; differences from exponential may only
  appear at long distances.

### 2.3 A note on scope

The comparison is **between these two specific parametric
forms**, not between "exponential" and "power-law" as
ontological categories. Other kernels (Weibull, stretched
exponential, spline) may fit better. They are not part of the
primary comparison.

---

## 3. Exposure Construction

### 3.1 From audited closure to E_t

`S_closure` is built from the **audited** closure series,
not from self-report. The two-stage procedure (Section 6.7)
is:

1. **Monthly detection.** A short instrument identifies
   potential changes in the opportunity structure. The
   participant report is a detection signal, not the
   measurement.
2. **Objective verification.** Any materially consequential
   change is verified against administrative records,
   program rosters, third-party confirmation, or structured
   assessor review.

Only verified changes enter `S_closure^audit(τ)`.

### 3.2 Temporal boundary

`E_it` uses **only** closure events occurring up to and
including time t:

```

E_{it}^{≤ t} = ∫₀ᵗ K(t − τ) S_closure^audit(τ) dτ

```

Events occurring between t and t+1 enter the **next**
transition, not the current one. This prevents temporal
leakage.

### 3.3 Numerical integration

With monthly measurement (τ ∈ {1, 2, …, 18}):

```

E_{it} = Σ_{τ=1}^{t} K(t − τ) · S_closure^audit(τ)

```

Linear interpolation is used between monthly observations
when needed.

### 3.4 Standardization

Before entering the dynamic model, `E_it` is standardized
within each wave:

```

E_it^std = (E_it − mean(E_·t)) / sd(E_·t)

```

Raw units are retained for descriptive reporting.

---

## 4. The Identifiability Problem

### 4.1 Why identifiability must be checked first

If exponential and power-law kernels produce nearly identical
`E_t` at the observed waves for all plausible (λ, ρ), then
no amount of data can distinguish them from shape alone. The
design has an identifiability ceiling.

This is tested **before** any hypothesis test:

`SIMULATION/code/01_H5_identifiability.R`

### 4.2 What the check does

For a grid of (λ, ρ) and 200 replicates:

1. Generate a random monthly closure series.
2. Compute `E_exp` and `E_pow` at waves 0, 6, 12, 18.
3. Normalize both to max = 1 (removes scale, keeps shape).
4. Compute correlation between `E_exp[6,12,18]` and
   `E_pow[6,12,18]`.

If the median correlation is > 0.95 in **all** cells, the
design cannot distinguish the kernels, and H5 is reported as
**not testable within the window**.

If the median correlation is < 0.90 in some cells, H5 is
testable **only** in those regions of the parameter grid.

### 4.3 What the check does not do

The check does not:

- Estimate λ or ρ from data.
- Compare kernels in a model.
- Establish which kernel is "true."

It is a design-level diagnostic. Its purpose is to prevent
H5 from being reported as "not supported" when the correct
conclusion is "not testable."

---

## 5. Model Comparison Procedure

If the identifiability check passes, H5 is tested as follows.

### 5.1 Fitting

Three models are fit to the same data:

- **Model E:** primary dynamic model with exponential kernel.
- **Model P:** primary dynamic model with power-law kernel.
- **Model F:** primary dynamic model with flexible kernel
  (spline-based). Only included if simulation shows sufficient
  power to distinguish it from the other two.

### 5.2 Comparison criterion

Comparison uses predictive accuracy:

- **LOO-CV** (leave-one-out cross-validation).
- **WAIC** (widely applicable information criterion).

Model comparison uses differences with standard errors. A
difference of less than 2 standard errors is treated as
**inconclusive**.

### 5.3 Decision rule

- **Supported for a kernel:** one kernel provides substantially
  better predictive accuracy (LOO-CV difference > 2 SE) than
  the other, AND the estimated parameters (λ or ρ) are not at
  boundary values.
- **Undetermined:** neither kernel is clearly favored.
- **Not testable:** simulation (Section 4) indicates the design
  cannot distinguish the kernels within the window.

### 5.4 Scope limitation

Any conclusion is restricted to:

```

0 ≤ t ≤ 18 months

```

No claim is made about persistence beyond the observation
window. The Discussion (Section 8) must respect this boundary.
No inference is made about kernel tails.

---

## 6. What the Kernel Comparison Can and Cannot Show

### 6.1 Can show

- Whether, within the observed window, the two specific
  kernels produce distinguishable fits.
- Whether one parametric form provides better predictive
  accuracy than the other, among the forms compared.
- Whether the estimated λ or ρ falls in a meaningful
  (non-boundary) region.

### 6.2 Cannot show

- That power-law persistence is the "true" underlying
  mechanism.
- That closure effects persist beyond 18 months.
- That alternative kernels (Weibull, stretched exponential,
  spline) would not fit better.
- That the choice between kernels has substantive
  implications for intervention design.

---

## 7. Relationship to Other Documents

- `SIMULATION/code/01_H5_identifiability.R` — the design-level
  check.
- `SIMULATION/code/03_power_surface.R` — includes kernel
  misspecification as a power-surface dimension.
- `DOCS/decision_rules.md` — Section 6 consolidates the H5
  decision rule.
- `MODEL/stan/kernel_comparison.stan` — planned Stan model for
  kernel comparison.
- Section 3.4, Section 6.7, Section 7.4, Section 7.10 —
  protocol sections that define the kernel model.

---

## 8. Notes on Implementation

- All kernel computations use R base functions (no external
  dependencies).
- Numerical integration uses monthly grid, linear interpolation.
- Standardization is per-wave, not global.
- No extrapolation beyond the wave window is performed.

---

**End of `DOCS/kernel_specification.md`**
