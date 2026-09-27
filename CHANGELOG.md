# STRATIM Changelog

All notable changes to the STRATIM protocol will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

**Note on versioning.** STRATIM distinguishes between:
- **Protocol versions** (`0.x.y-protocol`): theoretical and methodological changes to the model, hypotheses, operationalization, or analysis plan.
- **Simulation versions** (`0.x.y-simulation`): changes to the simulation code, its execution, and its results.
- **Empirical versions** (`x.y.z`): changes following data collection and analysis.

At the current stage, no empirical data has been collected.

---

## [0.2.0-simulation] - 2026-09-26

### Simulation Pipeline and Documentation

This release implements the full simulation pipeline, executes five
simulation experiments, and documents their results with a traceable
provenance chain (code → CSV → reports → EXPERIMENTS.md → JSON →
Dashboard). No empirical data is included.

### Added

#### Simulation Code
- `SIMULATION/code/00_dgp.R` — data generating process with configurable
  parameters, kernel functions (exponential, power-law), and long-format
  converter.
- `SIMULATION/code/01_H5_identifiability.R` — design-level check of
  whether the 18-month / 4-wave design can distinguish exponential from
  power-law kernels within a (λ, ρ) grid.
- `SIMULATION/code/02_parameter_recovery.R` — parameter recovery via
  `lme4::lmer` (REML) for the 8 primary model parameters.
- `SIMULATION/code/02b_recovery_boundary.R` — recovery boundary grid
  over σ_α ∈ {0.10, 0.05, 0.03, 0.01}, N ∈ {100, 200, 300}, and
  attrition ∈ {0, 0.20, 0.35}.
- `SIMULATION/code/03_power_surface.R` — Monte Carlo power surface
  across 128 cells.
- `SIMULATION/code/04_state_scenarios.R` — validation of the state
  classifier (3A, 3B, J) on synthetic scenarios.
- `SIMULATION/code/05_export_results.R` — export of all CSV artifacts
  to a single `simulation_results.json` for the Dashboard.
- `SIMULATION/code/06_verify_documentation.R` — automated check that
  documentation values match the CSV artifacts.

#### Simulation Configuration
- `SIMULATION/configs/parameters.yaml` — default parameters and grids.

#### Simulation Documentation
- `SIMULATION/README.md` — how to run the pipeline.
- `SIMULATION/EXPERIMENTS.md` — central registry of the 5 experiments
  with headline results.
- `SIMULATION/reports/exp_01_H5_identifiability.md`
- `SIMULATION/reports/exp_02_parameter_recovery.md`
- `SIMULATION/reports/exp_03_recovery_boundary.md`
- `SIMULATION/reports/exp_04_power_surface.md`
- `SIMULATION/reports/exp_05_state_scenarios.md`

Each report includes a Reproducibility block specifying script,
inputs, outputs, replicates, seed policy, runtime, and R version.

#### Simulation Results
- `SIMULATION/results/01_H5_identifiability_summary.csv` (16 cells)
- `SIMULATION/results/02_parameter_recovery_summary.csv` (8 params)
- `SIMULATION/results/02b_recovery_boundary_summary.csv` (36 cells)
- `SIMULATION/results/03_power_surface.csv` (128 cells)
- `SIMULATION/results/04_state_scenarios.csv` (600 rows)
- `PUBLICATION/Netlify/public/data/simulation_results.json` (47 KB)

#### Tests
- `tests/testthat.R` — testthat entry point.
- `tests/testthat/test-dgp.R` — DGP structure, reproducibility,
  directional effects.
- `tests/testthat/test-kernels.R` — kernel boundary, monotonicity,
  tail behavior.
- `tests/testthat/test-exposure.R` — E_t construction.
- `tests/testthat/test-temporal-boundary.R` — no temporal leakage.
- `tests/testthat/test-state-construction.R` — priority rule.
- `tests/testthat/test-decision-rules.R` — ROPE, MID, Δ*_AUC.
- `tests/testthat/test-hypothesis-tests.R` — H1a, H1c, H1d procedures.
- `tests/testthat/test-recovery.R` — recovery infrastructure.
- `tests/testthat/test-power-surface.R` — power surface infrastructure.
- `tests/testthat/test-pipeline.R` — end-to-end pipeline.

Total: ~180 tests passing.

#### Model Specifications
- `MODEL/stan/primary_model.stan` — primary hierarchical model.
- `MODEL/stan/threshold_recovery.stan` — H1b threshold specification.
- `MODEL/stan/kernel_comparison.stan` — exponential vs. power-law.
- `MODEL/README.md` — model documentation.

#### Instruments
- `INSTRUMENTS/sic_task/instrument.md`
- `INSTRUMENTS/opportunity_audit/instrument.md`
- `INSTRUMENTS/monthly_detection/instrument.md`
- `INSTRUMENTS/rehearsal_log/instrument.md`
- `INSTRUMENTS/recovery/instrument.md`
- `INSTRUMENTS/README.md`

#### Analysis Pipelines
- `ANALYSIS/README.md` — pipeline overview.
- `ANALYSIS/01_validation/README.md`
- `ANALYSIS/02_state_construction/README.md`
- `ANALYSIS/03_exposure_construction/README.md`
- `ANALYSIS/04_dynamic_model/README.md`
- `ANALYSIS/05_hypothesis_tests/README.md`

#### Documentation
- `DOCS/decision_rules.md` — updated with Section 2.4 (H1d
  design-based testability condition).
- `DOCS/measurement_risks.md` — updated.
- `DOCS/kernel_specification.md` — updated.

#### Pre-registration Documents
- `PREREGISTRATION/protocol.md`
- `PREREGISTRATION/hypotheses.md` — H1d design condition added.
- `PREREGISTRATION/analysis_plan.md` — Section 7.1b added for H1d.
- `PREREGISTRATION/README.md`

#### Publication Infrastructure
- `PUBLICATION/Netlify/public/index.html` — homepage.
- `PUBLICATION/Netlify/public/dashboard.html` — live view of JSON.
- `PUBLICATION/Netlify/public/results.html` — detailed tables.
- `PUBLICATION/Netlify/public/documentation.html` — protocol reference.
- `PUBLICATION/Netlify/public/assets/style.css` — shared stylesheet.
- `PUBLICATION/Netlify/netlify.toml` — deployment configuration.
- `PUBLICATION/README.md`

### Changed

#### Scientific Findings That Modified the Protocol

- **H5 identifiability is conditional.** The 18-month / 4-wave design
  cannot distinguish exponential from power-law kernels in all regions
  of the (λ, ρ) grid. H5 is now reported as testable only in
  distinguishable regions.

- **H1d has a design boundary.** Recovery of σ_α is adequate at
  σ_α ≥ 0.10, transitional at 0.05, marginal at 0.03, and inadequate
  at 0.01. If the posterior interval for σ²_α is compatible with
  σ_α < 0.05, H1d is reported as **not testable within the window**,
  not as "not supported." Documented in `DOCS/decision_rules.md`
  Section 2.4 and `PREREGISTRATION/hypotheses.md`.

- **H1c vs. H1d trade-off.** Power for H1c decreases with higher σ_α,
  while power for H1d increases. This is a substantive finding about
  the interaction between parameter heterogeneity and the detectability
  of the intensification term.

#### Documentation Updates

- `CHANGELOG.md` (this file) extended with simulation version.
- Roadmap updated to reflect completed simulation stage.

### Version History

| Version | Date | Status | Key Changes |
|---------|------|--------|-------------|
| **0.2.0-simulation** | 2026-09-26 | Current | Simulation pipeline + 5 experiments + documentation |
| 0.1.0-protocol | 2026-09 | Closed | Initial protocol release |

### Headline Simulation Results

| Experiment | Result |
|------------|--------|
| H5 Identifiability | 16 cells; min corr 0.3691, max corr 0.9974; status: testable_regions |
| Parameter Recovery | 8/8 params recovered with bias < 1% at N = 300 |
| Recovery Boundary | Adequate at σ_α ≥ 0.10; inadequate at σ_α = 0.01 |
| Power Surface | Min N for 0.80 power: H1=100, H1a=100, H1c=200, H1d=100 |
| State Scenarios | 4/4 validation checks pass (3B, 3A, J, priority rule) |

### Verification

All documentation values verified against CSV artifacts via
`SIMULATION/code/06_verify_documentation.R`:

```

RESULT: All documentation values verified. PASS

```

### Pending

The following remain to be done:

- OSF pre-registration upload.
- Zenodo DOI registration for code archive.
- IRB approval for pilot study.
- Pilot study (N ≈ 30–50).
- Threshold calibration from independent sample.
- Main data collection.

### Not Included

The following are explicitly **not** part of STRATIM at this stage:

- Empirical participant data.
- Pilot data.
- PyPI package distribution.

---

## [0.1.0-protocol] - 2026-09

### Initial Protocol Release

This is the first complete version of the STRATIM protocol. It establishes the theoretical model, hypotheses, operationalization, study design, analysis plan, and decision rules. No empirical data is included.

### Added

#### Theoretical Framework
- Two-state-variable architecture: `O^objective` (objectively audited opportunity) and `SIC` (Strategic Imagination Capacity).
- Reformulation of the original three-stage conception as a dynamic state space.
- Five reference regions: Stage 1 (narrow but real margin), Stage 2 (partial erosion), 3A (internal SIC erosion), 3B (objective closure with preserved SIC), and J (joint closure).
- Separation of objective opportunity, perceived opportunity, SIC, rehearsal, recovery, and execution as analytically distinct variables.

#### Hypotheses
- H1: Closure-to-Erosion.
- H1a: Rehearsal moderation.
- H1b: Recovery threshold.
- H1c: Closure × Rehearsal intensification.
- H1d: Individual sensitivity heterogeneity.
- H2: Objective/perceived opportunity dissociation.
- H3: Behavioral equifinality of non-execution.
- H4: Differential recovery pathways.
- H5: Kernel persistence.

#### Operationalization
- Behavioral SIC task with four dimensions (generate, elaborate, compare, revise).
- Structured opportunity audit with pre-specified accessibility criteria.
- Monthly closure detection with independent verification.
- Rehearsal logs and recovery measurement specifications.
- Separation of perceived opportunity from SIC by temporal ordering.

#### Study Design
- Longitudinal design: 4 principal waves at `t_0, t_6, t_12, t_18`.
- Monthly closure exposure measurement between waves.
- Target population: adults with chronic material pressure and preserved SIC at baseline.
- Eligibility thresholds determined from an independent calibration procedure.

#### Analysis Plan
- Bayesian hierarchical dynamic model with HMC estimation.
- Frequentist mixed-effects sensitivity analysis (REML).
- Pre-specified model reduction sequence.
- Kernel comparison: exponential vs. power-law.
- Pre-specified decision rules: ε (smallest practical effect), MID (opportunity gap), Δ*_AUC (diagnostic margin).
- Simulation-based power analysis (Monte Carlo).

#### Documentation
- `README.md` — repository overview.
- `RESEARCH_PAPER/STRATIM_Research_Paper.md` — full manuscript (Sections 1–10).
- `AUTHORS.md` — contributors and status.
- `CITATION.cff` — citation metadata.
- `CONTRIBUTING.md` — contribution guidelines.

#### Infrastructure
- `.gitlab-ci.yml` — CI/CD pipeline.
- `.pre-commit-config.yaml` — pre-commit hooks.
- `.readthedocs.yaml` — documentation build configuration.
- `Makefile` — common targets.
- `pyproject.toml`, `setup.py`, `setup.cfg` — Python packaging.
- `requirements.txt` — Python dependencies.

---

## Version History (Complete)

| Version | Date | Status | Key Changes |
|---------|------|--------|-------------|
| **0.2.0-simulation** | 2026-09-26 | Current | Simulation pipeline + 5 experiments + documentation |
| 0.1.0-protocol | 2026-09 | Closed | Initial protocol release |

---

## Roadmap

### 0.3.0-instruments (planned)
- SIC task forms A–D (content).
- Coding rubrics.
- Instrument pilot protocol.

### 0.4.0-preregistration (planned)
- OSF-style pre-registration document finalization.
- Upload to OSF.
- Zenodo DOI for code archive.

### 0.5.0-pilot (planned, requires IRB)
- Pilot study (N ≈ 30–50).
- Instrument validation.
- Threshold calibration from independent sample.

### 1.0.0 (planned, requires funding + IRB)
- Main data collection (N = 300).
- Analysis execution.
- Publication submission.

---

## Notes on the Changelog

- This changelog is updated with **substantive** changes, not
  editorial fixes.
- Any change to hypotheses, decision rules, or the primary model
  after pre-registration is recorded here as an amendment with
  explicit rationale.
- Changes made **after** pre-registration and **before** data
  collection are documented as protocol amendments.
- Changes made **after** data collection are documented as
  deviations and reported in the manuscript.

---

**Last Updated:** 2026-09-26
**Current Version:** 0.2.0-simulation
