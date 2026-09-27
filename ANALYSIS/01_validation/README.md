# 01 — Measurement Validation

**Corresponds to:** Section 7.2

## Purpose

Validate each measurement instrument before any hypothesis
is tested. If a validation criterion fails, the affected
hypothesis is reported as **not testable under the observed
measurement conditions**.

## Pre-specified criteria

| Criterion | Adequate | Marginal | Inadequate |
|-----------|----------|----------|------------|
| SIC internal consistency (ω) | ≥ .70 | .60–.69 | < .60 |
| SIC inter-rater ICC (per dimension) | ≥ .75 | .60–.74 | < .60 |
| Opportunity audit κ (per domain) | ≥ .70 | .50–.69 | < .50 |
| Monthly detection sensitivity | ≥ .70 | .60–.69 | < .60 |

## Planned scripts

| Script | Purpose |
|--------|---------|
| `01a_sic_reliability.R` | Cronbach's α, McDonald's ω per wave |
| `01b_sic_icc.R` | Inter-rater ICC per dimension |
| `01c_parallel_forms.R` | Parallel-form equivalence (A–D) |
| `01d_sic_discriminant.R` | SIC vs. verbal fluency, working memory |
| `01e_audit_kappa.R` | Audit κ per domain |
| `01f_detection_concordance.R` | Monthly detection vs. audit |

## Outputs

- Reliability tables per wave.
- ICC tables per dimension.
- Equivalence test results.
- Discriminant validity tests.
- Adequacy classification for each instrument.

## Decision

Based on the adequacy classification, the following
variables may be:
- Used as specified in primary analysis.
- Analyzed with explicit caveat.
- Analyzed separately (per dimension or domain).
- Excluded from hypothesis testing.

---

**End of `ANALYSIS/01_validation/README.md`**
