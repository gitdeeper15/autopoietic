# 05 — Hypothesis Tests

**Corresponds to:** Section 7.6

## Purpose

Test each pre-registered hypothesis using its corresponding
decision rule from `DOCS/decision_rules.md`.

No new hypotheses are introduced at this stage.

## Hypotheses and decision rules

| Hypothesis | Rule | Source |
|------------|------|--------|
| H1 | ROPE-based, ε boundary | Section 7.6, ε |
| H1a | δ₁ > 0 | Section 7.6 |
| H1b | threshold vs. additive comparison | Section 7.6, τ_G |
| H1c | δ₁ + 2δ₂E*_ref > 0 | Section 7.6, E*_ref |
| H1d | σ²_α > 0 | Section 7.6 |
| H2 | mean |ΔO| > MID | Section 7.6, MID |
| H3 | Δ_AUC > Δ*_AUC | Section 7.6, Δ*_AUC |
| H4 | event-contingent trajectories | Section 7.9 |
| H5 | kernel comparison | Section 7.10 |

## Order of testing

The tests follow the dependency structure (Section 4.6):

```

H2 → H3 → H1 → (H1a, H1b, H1c, H1d) → H4

```

H5 is parallel (kernel specification).

## Planned scripts

| Script | Purpose |
|--------|---------|
| `05a_h1_closure_erosion.R` | H1 test |
| `05b_h1a_rehearsal.R` | H1a test |
| `05b_h1b_threshold.R` | H1b test |
| `05b_h1c_intensification.R` | H1c test |
| `05b_h1d_heterogeneity.R` | H1d test |
| `05c_h2_dissociation.R` | H2 test |
| `05d_h3_equifinality.R` | H3 test |
| `05e_h4_recovery.R` | H4 event-contingent test |
| `05f_h5_kernel.R` | H5 kernel comparison |
| `05g_multiple_testing.R` | FDR adjustment |

## Reporting

Each hypothesis is reported as:

- **Supported**
- **Not supported**
- **Inconclusive**
- **Not testable** (with reason: underpowered, measurement
  failed, identifiability failed)

No hypothesis is reported as "confirmed."

## Multiple testing

Primary family: H1, H1a, H1c, H1d, H2, H4, H5.
Secondary family: H1b, H3.
Benjamini-Hochberg FDR = 0.05 within each family.

---

**End of `ANALYSIS/05_hypothesis_tests/README.md`**
