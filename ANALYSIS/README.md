# STRATIM — Analysis

This directory contains the analysis pipelines for STRATIM.

## Status

All analysis subdirectories are at the **specification stage**.
No empirical data exists yet. The R scripts referenced below
will be written once:
1. Simulation results are validated.
2. The pilot study is complete.
3. The main study begins.

## Subdirectories

| Directory | Purpose | Requires data? |
|-----------|---------|----------------|
| `01_validation/` | Measurement validation (Section 7.2) | Pilot or main |
| `02_state_construction/` | Build state variables (Section 7.3) | Main |
| `03_exposure_construction/` | Build `E_it` from audited closure (Section 7.4) | Main |
| `04_dynamic_model/` | Fit primary dynamic model + sensitivity | Main |
| `05_hypothesis_tests/` | Test H1–H5 with pre-specified rules | Main |

## Order of execution

```

01_validation
↓
02_state_construction
↓
03_exposure_construction
↓
04_dynamic_model
↓
05_hypothesis_tests

```

Each step depends on the output of the previous step. No step
may skip its predecessor.

## Principles

1. **No post hoc hypothesis creation.** All hypotheses are
   specified in Section 4 and tested as specified in
   Section 7.6.
2. **No threshold adjustment after data collection.** All
   thresholds are in `DOCS/decision_rules.md` and set before
   data collection.
3. **No partialling-out of theoretically related variables.**
   Temporal ordering is preserved.
4. **No rescuing of underpowered tests.** A test that is
   underpowered at the pre-specified N is reported as
   underpowered.

## What is not included

- Empirical data (never committed; see `.gitignore`).
- Fitted model objects (regenerable from Stan source).
- Posterior samples (regenerable from fitted models).
- Any analysis output that could be confused with a
  substantive finding before pre-registration is complete.

## Relationship to the protocol

- Section 7.0 defines the analysis logic.
- Section 7.1 defines data assembly.
- Section 7.2 defines measurement validation.
- Section 7.3 defines state construction.
- Section 7.4 defines exposure construction.
- Section 7.5 defines the primary dynamic model.
- Section 7.6 defines hypothesis tests.
- Section 7.7 defines missing data handling.
- Section 7.8 defines sensitivity analyses.
- Section 7.9 defines multiple testing.
- Section 7.11 defines falsification logic.

If any script in this directory contradicts the protocol,
the protocol takes precedence.

---

**End of `ANALYSIS/README.md`**
