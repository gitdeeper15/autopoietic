# STRATIM — Study Protocol

**Version:** 0.1.0-protocol
**Status:** Draft for OSF Registered Report submission
**Title:** Strategic Imagination Capacity Under Chronic Material Pressure: A Dynamic State-Space Model

---

## 1. Title

Strategic Imagination Capacity Under Chronic Material Pressure:
A Dynamic State-Space Model.

## 2. Authors

Samir Baladi (ORCID 0009-0003-8903-0029)
Email: gitdeeper@gmail.com

## 3. Description

The study develops and tests a dynamic state-space model of
Strategic Imagination Capacity (SIC) under chronic material
pressure. The model separates objectively audited opportunity
structure, perceived opportunity, SIC, rehearsal, recovery,
and execution as analytically distinct variables.

The study is a longitudinal, multi-source observational
design with four principal measurement waves over 18 months
and higher-frequency measurement of closure exposure and
process variables. No empirical data has been collected at
the time of pre-registration.

## 4. Hypotheses

Nine hypotheses are pre-registered:

- **H1** — Closure-to-Erosion: cumulative closure exposure
  is associated with subsequent SIC decline (α₀ > ε).
- **H1a** — Rehearsal moderation: rehearsal attenuates the
  negative E → SIC association (δ₁ > 0).
- **H1b** — Recovery threshold: recovery has a conditional
  rather than purely additive protective effect (γ₂ > 0).
- **H1c** — Closure × Rehearsal intensification: the
  protective moderation of rehearsal increases with exposure
  (δ₁ + 2δ₂E*_ref > 0).
- **H1d** — Individual sensitivity: individuals differ in
  sensitivity to closure (σ²_α > 0).
- **H2** — Objective/perceived dissociation: O^objective and
  O^perceived are empirically non-equivalent (mean |ΔO| > MID).
- **H3** — Behavioral equifinality: behavioral non-execution
  alone is diagnostically insufficient to distinguish 3A from
  3B (Δ_AUC > Δ*_AUC).
- **H4** — Differential recovery: after opportunity
  reopening, 3B moves to 1 without intermediate SIC decline;
  3A shows progressive recovery.
- **H5** — Kernel persistence: exponential vs. power-law
  kernels fit differently within the observed window.

Full hypotheses and decision rules are in `hypotheses.md`.

## 5. Sampling Plan

### 5.1 Target population

Adults experiencing chronic material pressure, operationalized
as sustained low or unstable income over the preceding 12
months and restricted objective opportunity in at least three
pre-specified domains.

### 5.2 Eligibility for H1

- Preserved SIC at baseline (SIC > τ_SIC).
- Restricted objective opportunity (O^objective ≤ τ_O).
- No acute crisis that would dominate the measurement period.

### 5.3 Sampling strategy

Stratified purposive sampling across three recruitment
streams: community organizations, vocational/adult education
programs, and referral/snowball pathways.

### 5.4 Target N

Primary target: N = 300 (based on simulation-based power
analysis, `SIMULATION/code/03_power_surface.R`).

### 5.5 Attrition

Expected cumulative attrition: ~20%. Retention procedures,
MAR modeling, and MNAR sensitivity analyses are pre-specified.

## 6. Variables

### 6.1 State variables

- `O^objective` — audited opportunity structure.
- `SIC` — Strategic Imagination Capacity.

### 6.2 Measurement and process variables

- `O^perceived` — perceived opportunity.
- `R` — rehearsal.
- `G` — recovery.
- Execution — observable behavioral conversion.

### 6.3 State classification

Five reference regions: 1, 2, 3A, 3B, J. Only 3A and 3B are
mutually exclusive categories for hypothesis testing.

### 6.4 Thresholds

Thresholds (ε, MID, Δ*_AUC, τ_SIC, τ_O, τ_G, E*_ref) are set
from an independent calibration sample or a pre-registered
external procedure, and are fixed before data collection.

## 7. Analysis Plan

The full analysis plan is in `analysis_plan.md`.

### 7.1 Primary model

Bayesian hierarchical dynamic model, HMC estimation
(Stan / cmdstanr). Frequentist mixed-effects (lme4, REML) is
a sensitivity analysis.

### 7.2 Decision rules

Each hypothesis has a pre-specified decision rule, including
a smallest effect of practical interest where applicable.
See `analysis_plan.md` and `../DOCS/decision_rules.md`.

### 7.3 Missing data

MAR is the primary assumption. MNAR pattern-mixture is used
as a sensitivity analysis.

### 7.4 Multiple testing

Benjamini-Hochberg FDR = 0.05, applied separately to
primary and secondary families.

### 7.5 Simulations

Simulation-based power analysis (Monte Carlo) is run before
data collection and reported in the manuscript. Underpowered
primary tests are either promoted (with increased N) or
demoted to secondary before data collection.

## 8. Timeline

| Stage | Duration | Status |
|-------|----------|--------|
| Protocol | — | ✅ Complete |
| Simulation code | — | ✅ Written |
| Simulation runs | 1–2 weeks | ⬜ Pending |
| Pre-registration upload | — | ⬜ Pending |
| IRB submission | 1–2 months | ⬜ Pending |
| Pilot study | 3 months | ⬜ Pending |
| Main data collection | 18 months | ⬜ Pending |
| Analysis | 3 months | ⬜ Pending |
| Manuscript | 2 months | ⬜ Pending |

## 9. Ethics

- IRB approval will be obtained before any data collection.
- Informed consent will be documented.
- Participant data will never be committed to this repository.
- Any data sharing will follow separate ethical protocols.
- 3A is not a clinical diagnosis and the study does not
  provide clinical care.

## 10. Data Availability

No empirical data exists at pre-registration. Simulation code
and synthetic data (regenerable from seed) are available in
`SIMULATION/`. Empirical data will be deposited separately
following IRB-approved protocols.

## 11. What This Study Does Not Claim

The study does not claim:

- Causal effects of closure on SIC.
- Population prevalence of any state.
- Persistence of kernel effects beyond 18 months.
- Universal applicability of the model.
- Clinical interpretation of 3A.

## 12. References

See `RESEARCH_PAPER/STRATIM_Research_Paper.md` References
section.

---

**End of `PREREGISTRATION/protocol.md`**
