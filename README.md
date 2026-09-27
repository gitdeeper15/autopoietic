<div align="center">

# STRATIM

### Strategic Imagination Capacity Under Chronic Material Pressure

*A Dynamic State-Space Model of Opportunity, Capacity, and Execution*

---

[![Version](https://img.shields.io/badge/version-0.2.0--simulation-2c5f7d?style=flat-square)](CHANGELOG.md)
[![License: MIT](https://img.shields.io/badge/license-MIT-27ae60?style=flat-square)](LICENSE)
[![Docs: CC BY 4.0](https://img.shields.io/badge/docs-CC--BY--4.0-27ae60?style=flat-square)](LICENSE)
[![Python](https://img.shields.io/badge/python-3.10+-3776ab?style=flat-square&logo=python&logoColor=white)](https://python.org)
[![R](https://img.shields.io/badge/R-4.3+-276DC3?style=flat-square&logo=r&logoColor=white)](https://r-project.org)
[![Status](https://img.shields.io/badge/status-simulation--complete-blue?style=flat-square)](CHANGELOG.md)
[![Tests](https://img.shields.io/badge/tests-180%20passing-success?style=flat-square)](tests/)
[![DOI](https://img.shields.io/badge/DOI-10.5281%2Fzenodo.22975701-blue?style=flat-square)](https://doi.org/10.5281/zenodo.22975701)
[![OSF Registration](https://img.shields.io/badge/OSF%20Registration-10.17605%2FOSF.IO%2FE5F8R-1a5276?style=flat-square)](https://doi.org/10.17605/OSF.IO/E5F8R)
[![Registered](https://img.shields.io/badge/OSF-registered-1a5276?style=flat-square)](https://osf.io/3qp9u)
[![GitLab](https://img.shields.io/badge/GitLab-primary-FCA121?style=flat-square&logo=gitlab)](https://gitlab.com/gitdeeper15/STRATIM)

---

**`9 Hypotheses`** &nbsp;·&nbsp; **`5 State Regions`** &nbsp;·&nbsp; **`18-month Design`** &nbsp;·&nbsp; **`4 Waves`** &nbsp;·&nbsp; **`2 Kernels`** &nbsp;·&nbsp; **`5 Simulation Experiments`** &nbsp;·&nbsp; **`180 Tests Passing`**

---

[Research Paper](RESEARCH_PAPER/STRATIM_Research_Paper.md) &nbsp;·&nbsp;
[Protocol](PREREGISTRATION/protocol.md) &nbsp;·&nbsp;
[OSF Registration](https://doi.org/10.17605/OSF.IO/E5F8R) &nbsp;·&nbsp;
[Simulation Results](SIMULATION/EXPERIMENTS.md) &nbsp;·&nbsp;
[Instruments](INSTRUMENTS/) &nbsp;·&nbsp;
[Quick Start](#-quick-start)

---

### Repository Mirrors

[![GitLab](https://img.shields.io/badge/GitLab-Primary-FCA121?style=for-the-badge&logo=gitlab)](https://gitlab.com/gitdeeper15/STRATIM)
[![GitHub](https://img.shields.io/badge/GitHub-Mirror-181717?style=for-the-badge&logo=github)](https://github.com/gitdeeper15/STRATIM)
[![OSF](https://img.shields.io/badge/OSF-Registered-1a5276?style=for-the-badge)](https://osf.io/3qp9u)
[![Internet Archive](https://img.shields.io/badge/Internet%20Archive-Archived-8b4513?style=for-the-badge)](https://archive.org/details/osf-registrations-e5f8r-v1)

</div>

---

## 📌 Overview

**STRATIM** is a dynamic state-space model for examining **Strategic Imagination Capacity (SIC)** under chronic material pressure. It separates, both conceptually and operationally, the objective opportunity structure available to an individual from the cognitive capacity to generate, elaborate, compare, and revise alternative futures.

The model is organized around two analytically distinct state variables — **objectively audited opportunity structure** `O^objective` and **Strategic Imagination Capacity** `SIC` — and specifies how they evolve over time under exposure to closure, rehearsal, and recovery. Perceived opportunity, rehearsal, recovery, and execution are treated as measurement or process components, not as substitutes for either state variable.

> *"Execution ≈ 0 does not by itself establish whether the limiting condition is primarily O ↓ or SIC ↓."*
> — STRATIM, Section 1

Conventional accounts of behavior under material scarcity often collapse opportunity, capacity, and action into a single observed outcome. STRATIM keeps them apart, specifies how they move over an 18-month observation window, and pre-registers the exact decision rules — ε, MID, Δ\*_AUC — under which each of its nine hypotheses will be called supported, unsupported, inconclusive, or not testable.

### Framework at a Glance

| Component | STRATIM | Common Alternative |
|-----------|---------|--------------------|
| State variables | 2 (`O`, `SIC`) | 1 (behavior) |
| State regions | 5 (1, 2, 3A, 3B, J) | 3 (linear stages) |
| Hypotheses | 9 (H1–H1d, H2–H5) | — |
| Design | 18-month, 4 waves | cross-sectional |
| Decision rules | Pre-specified (ε, MID, Δ\*_AUC) | post hoc |
| Estimation | Bayesian hierarchical (HMC) | fixed-effects |
| Kernel forms | 2 (exponential, power-law) | — |
| Simulation | **5 experiments, executed** | — |
| Empirical data | none yet | — |
| Pilot | not yet conducted | — |

---

## 🗂️ Table of Contents

- [Overview](#-overview)
- [What's New in v0.2.0-simulation](#-whats-new-in-v020-simulation)
- [Key Features](#-key-features)
- [Five State Regions](#-five-state-regions)
- [Dynamic Architecture](#-dynamic-architecture)
- [Simulation Results](#-simulation-results)
- [Project Structure](#-project-structure)
- [Quick Start](#-quick-start)
- [Installation](#️-installation)
- [Usage](#️-usage)
- [API Reference](#-api-reference)
- [Research Paper](#-research-paper)
- [Platforms & Resources](#-platforms--resources)
- [Contributing](#-contributing)
- [Citation](#-citation)
- [License](#-license)
- [Author](#-author)

---

## 🆕 What's New in v0.2.0-simulation

> **Status:** Protocol closed · Simulation complete · No empirical data

This release executes the full simulation pipeline specified in the protocol and closes the simulation stage without altering STRATIM's confirmatory status.

- Full simulation pipeline implemented and run: data-generating process, H5 identifiability, parameter recovery, recovery-boundary grid, power surface, and state-classifier validation
- Five simulation experiments completed with a traceable provenance chain (code → CSV → reports → `EXPERIMENTS.md` → JSON → dashboard)
- ~180 automated tests passing (`testthat`), covering the DGP, kernels, exposure construction, temporal-leakage guards, state construction, decision rules, hypothesis-test procedures, and the end-to-end pipeline
- Two scientific findings fed back into the protocol: **H5 identifiability is conditional** on the (λ, ρ) region, and **H1d carries a design-based testability boundary** in σ_α (Section 2.4 of `DOCS/decision_rules.md`)
- Publication infrastructure added: static homepage, live results dashboard, and documentation site (Netlify)
- All documentation values automatically cross-verified against the underlying CSV artifacts (`SIMULATION/code/06_verify_documentation.R`) — result: **PASS**
- Pre-registration formally registered on OSF ([osf.io/3qp9u](https://osf.io/3qp9u), Registration DOI [10.17605/OSF.IO/E5F8R](https://doi.org/10.17605/OSF.IO/E5F8R)) and permanently archived on the Internet Archive ([archive.org/details/osf-registrations-e5f8r-v1](https://archive.org/details/osf-registrations-e5f8r-v1)), under CC-BY 4.0

### Version History

| Version | Date | Status | Key Changes |
|---------|------|--------|-------------|
| **v0.2.0-simulation** | 2026-09-26 | Current | Simulation pipeline, 5 experiments, 180 tests, documentation |
| v0.1.0-protocol | 2026-09 | Closed | Initial theoretical model and pre-registration protocol |

Full details: [`CHANGELOG.md`](CHANGELOG.md)

---

## ✨ Key Features

| Feature | Description |
|---------|-------------|
| Two-State Architecture | Objective opportunity `O` and Strategic Imagination Capacity `SIC` are analytically distinct |
| Five Reference Regions | Stage 1 · Stage 2 · 3A · 3B · Joint closure `J` |
| Nine Hypotheses | H1 · H1a · H1b · H1c · H1d · H2 · H3 · H4 · H5, each with a pre-specified disconfirming region |
| Longitudinal Design | 4 principal waves over 18 months plus monthly exposure measurement |
| Pre-Specified Decision Rules | ε (practical effect) · MID (opportunity gap) · Δ\*_AUC (diagnostic margin) |
| Bayesian Hierarchical Model | HMC estimation (Stan) with ROPE-based decision rules; REML sensitivity analysis |
| Kernel Comparison | Exponential vs. power-law temporal memory, with a documented identifiability boundary |
| Simulation-Verified Power | Monte Carlo power surface across 128 cells — not a single MDE number |
| Diagnostic Sufficiency | Behavioral-only classifier vs. full state-variable model (H3) |
| Reproducible Simulation | 5 experiments, ~180 automated tests, full CSV → JSON → dashboard provenance chain |
| Pre-Registration Ready | Designed for OSF Registered Report submission |

---

## 🧭 Five State Regions

> All regions are defined in the two-dimensional space `(O^objective, SIC)` and are **not** mutually exclusive. The mutually exclusive classification used in hypothesis testing is `3A` vs. `3B`.

| Region | Condition | Meaning |
|--------|-----------|---------|
| **1 · Narrow but Real Margin** | `SIC > τ_SIC` and `O^objective > 0` under chronic constraint | Real, constrained opportunity plus preserved capacity |
| **2 · Erosion of Comparison Mechanism** | SIC partially eroded · `O` variable | Comparison/revision mechanism weakening |
| **3A · Internal SIC Erosion** | `SIC ≤ τ_SIC` | Capacity erosion can occur even when opportunity remains open |
| **3B · Objective Closure, Preserved SIC** | `O^objective ≤ τ_O` and `SIC > τ_SIC` | Inability to act is not equivalent to inability to imagine |
| **J · Joint Closure** | `O^objective ≤ τ_O` and `SIC ≤ τ_SIC` | Region of joint closure — not a separate stage |

4 of 4 state-classification validation checks (3B, 3A, J, and the priority rule) passed against synthetic scenarios in `SIMULATION/code/04_state_scenarios.R`.

---

## 🏗️ Dynamic Architecture

```
┌────────────────────────────────────────────────────────────────────┐
│                STRATIM — Three-Layer Architecture                  │
└────────────────────────────────────────────────────────────────────┘

   STATE LAYER              PROCESS LAYER             INFERENCE LAYER
 ┌──────────────┐         ┌──────────────┐          ┌───────────────┐
 │ O^objective  │──audit─▶│  E_t         │──Stan───▶│  Posterior    │
 │ SIC          │──task──▶│  R_t         │  HMC     │  Distributions│
 │ O^perceived  │─report─▶│  G_t         │          │               │
 │ Execution    │─record─▶│  Kernels     │          │  ROPE Rules   │
 │              │         │  (exp, PL)   │          │  LOO-CV       │
 │              │         │              │          │  WAIC         │
 └──────────────┘         └──────────────┘          └───────────────┘
  2 state vars              3 process vars            5 decision rules
  measured at 4 waves       measured continuously     pre-specified
```

| Layer | Technology |
|-------|------------|
| Language (analysis) | R 4.3+, Stan, brms |
| Language (tooling) | Python 3.10+ |
| Estimation | Hamiltonian Monte Carlo (Stan) |
| Frequentist sensitivity | lme4 / REML |
| Model comparison | LOO-CV, WAIC |
| Diagnostic performance | Cross-validated AUC, Brier score |
| Missing data | Multiple imputation, MNAR pattern-mixture |
| Simulation | Monte Carlo parameter recovery, power surface (`SIMULATION/code/`) |
| Testing | testthat — ~180 tests (`tests/`) |
| Pre-registration | OSF Registered Report format |
| Reproducibility | renv, targets, Docker |

---

## 📊 Simulation Results

All results are from `SIMULATION/results/` and are simulation-only — no empirical participant data is included at this stage. Full write-ups are in [`SIMULATION/EXPERIMENTS.md`](SIMULATION/EXPERIMENTS.md).

| Experiment | Result |
|------------|--------|
| **H5 Identifiability** (16 cells) | Kernel correlation range 0.3691–0.9974; status: testable only in identified regions of the (λ, ρ) grid |
| **Parameter Recovery** (8 params) | 8 of 8 primary model parameters recovered with bias < 1% at `N = 300` |
| **Recovery Boundary** (36 cells) | σ_α recovery adequate at ≥ 0.10, transitional at 0.05, marginal at 0.03, inadequate at 0.01 |
| **Power Surface** (128 cells) | Minimum `N` for 80% power — H1: 100 · H1a: 100 · H1c: 200 · H1d: 100 |
| **State Scenarios** (600 rows) | 4 of 4 validation checks passed (3B, 3A, J, priority rule) |

**Two findings fed back into the protocol:**
- **H5 is conditionally identifiable** — the design distinguishes the exponential and power-law kernels only within certain regions of the (λ, ρ) grid, so H5 is now reported as testable within those regions rather than as testable or untestable overall.
- **H1d has a design-based testability boundary** — if the posterior interval for σ²_α is compatible with σ_α < 0.05, H1d is reported as *not testable within the observation window*, not as *not supported*. Power for H1c decreases as σ_α increases while power for H1d increases — a substantive heterogeneity/detectability trade-off, not a defect to be tuned away.

Reproduce any result:

```bash
Rscript SIMULATION/code/01_H5_identifiability.R
Rscript SIMULATION/code/02_parameter_recovery.R
Rscript SIMULATION/code/02b_recovery_boundary.R
Rscript SIMULATION/code/03_power_surface.R
Rscript SIMULATION/code/04_state_scenarios.R

# Verify all documented values against the CSV artifacts
Rscript SIMULATION/code/06_verify_documentation.R
# → RESULT: All documentation values verified. PASS
```

---

## 📁 Project Structure

```
stratim/
├── README.md
├── CHANGELOG.md
├── LICENSE
├── CITATION.cff
├── VERSION
├── Makefile
├── renv.lock
├── Dockerfile
│
├── PREREGISTRATION/
│   ├── protocol.md
│   ├── hypotheses.md
│   ├── analysis_plan.md
│   └── README.md
│
├── SIMULATION/
│   ├── README.md                          # how to run the pipeline
│   ├── EXPERIMENTS.md                     # registry of the 5 experiments + headline results
│   ├── code/
│   │   ├── 00_dgp.R                       # data-generating process
│   │   ├── 01_H5_identifiability.R
│   │   ├── 02_parameter_recovery.R
│   │   ├── 02b_recovery_boundary.R
│   │   ├── 03_power_surface.R
│   │   ├── 04_state_scenarios.R
│   │   ├── 05_export_results.R            # CSV → simulation_results.json
│   │   └── 06_verify_documentation.R       # docs ↔ CSV cross-check
│   ├── configs/
│   │   └── parameters.yaml
│   ├── reports/
│   │   ├── exp_01_H5_identifiability.md
│   │   ├── exp_02_parameter_recovery.md
│   │   ├── exp_03_recovery_boundary.md
│   │   ├── exp_04_power_surface.md
│   │   └── exp_05_state_scenarios.md
│   └── results/
│       ├── 01_H5_identifiability_summary.csv
│       ├── 02_parameter_recovery_summary.csv
│       ├── 02b_recovery_boundary_summary.csv
│       ├── 03_power_surface.csv
│       └── 04_state_scenarios.csv
│
├── MODEL/
│   ├── README.md
│   ├── stan/
│   │   ├── primary_model.stan
│   │   ├── threshold_recovery.stan
│   │   └── kernel_comparison.stan
│   └── brms/
│
├── INSTRUMENTS/
│   ├── README.md
│   ├── sic_task/instrument.md
│   ├── opportunity_audit/instrument.md
│   ├── monthly_detection/instrument.md
│   ├── rehearsal_log/instrument.md
│   └── recovery/instrument.md
│
├── ANALYSIS/
│   ├── README.md
│   ├── 01_validation/
│   ├── 02_state_construction/
│   ├── 03_exposure_construction/
│   ├── 04_dynamic_model/
│   └── 05_hypothesis_tests/
│
├── DATA/
│   ├── synthetic/
│   ├── raw/
│   └── processed/
│
├── VALIDATION/
│
├── DOCS/
│   ├── decision_rules.md                   # incl. §2.4 H1d testability boundary
│   ├── measurement_risks.md
│   └── kernel_specification.md
│
├── PAPER_PARTS/
│   ├── section_01_introduction.md
│   ├── section_02_background.md
│   ├── section_03_state_space.md
│   ├── section_04_hypotheses.md
│   ├── section_05_operationalization.md
│   ├── section_06_design.md
│   ├── section_07_analysis_plan.md
│   ├── section_08_discussion.md
│   ├── section_09_limitations.md
│   └── section_10_conclusion.md
│
├── PUBLICATION/
│   ├── README.md
│   └── Netlify/
│       ├── netlify.toml
│       └── public/
│           ├── index.html
│           ├── dashboard.html              # live view of simulation_results.json
│           ├── results.html
│           ├── documentation.html
│           ├── assets/style.css
│           └── data/simulation_results.json
│
├── RESEARCH_PAPER/
│   └── STRATIM_Research_Paper.md
│
└── tests/
    ├── testthat.R
    └── testthat/
        ├── test-dgp.R
        ├── test-kernels.R
        ├── test-exposure.R
        ├── test-temporal-boundary.R
        ├── test-state-construction.R
        ├── test-decision-rules.R
        ├── test-hypothesis-tests.R
        ├── test-recovery.R
        ├── test-power-surface.R
        └── test-pipeline.R                 # ~180 tests total
```

---

## 🚀 Quick Start

```bash
# Clone the repository (GitLab primary)
git clone https://gitlab.com/gitdeeper15/STRATIM.git
cd STRATIM

# Restore R environment
Rscript -e "renv::restore()"

# Run the full simulation pipeline
Rscript SIMULATION/code/00_dgp.R
Rscript SIMULATION/code/01_H5_identifiability.R
Rscript SIMULATION/code/02_parameter_recovery.R
Rscript SIMULATION/code/02b_recovery_boundary.R
Rscript SIMULATION/code/03_power_surface.R
Rscript SIMULATION/code/04_state_scenarios.R

# Export results for the dashboard, then verify docs against CSVs
Rscript SIMULATION/code/05_export_results.R
Rscript SIMULATION/code/06_verify_documentation.R

# Run the test suite (~180 tests)
Rscript tests/testthat.R
```

Docker (optional):

```bash
docker build -t stratim .
docker run --rm stratim Rscript SIMULATION/code/01_H5_identifiability.R
```

---

## ⚙️ Installation

**R (simulation, model fitting):**

```bash
# Ubuntu / Debian
sudo apt install -y r-base r-base-dev

# macOS
brew install r

# Restore package environment
Rscript -e "install.packages('renv'); renv::restore()"
```

**Python (tooling):**

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

---

## 🖥️ Usage

```bash
# Read the pre-registered protocol
cat PREREGISTRATION/protocol.md

# Run individual simulation experiments
Rscript SIMULATION/code/01_H5_identifiability.R
Rscript SIMULATION/code/02_parameter_recovery.R
Rscript SIMULATION/code/03_power_surface.R

# Compile the primary Bayesian model (Stan)
Rscript -e "cmdstanr::cmdstan_model('MODEL/stan/primary_model.stan')"

# Serve the results dashboard locally
cd PUBLICATION/Netlify && npx serve public
```

---

## 🔌 API Reference

**Status:** Not yet published as a package. STRATIM is currently at the simulation-complete protocol stage; the R functions below exist as internal simulation code (`SIMULATION/code/`) and will be packaged for the pilot stage (`v0.3.0-instruments`).

Planned (R):

| Function | Purpose |
|----------|---------|
| `stratim::simulate_dgp()` | Data-generating process |
| `stratim::compute_E()` | Kernel-weighted exposure `E_t` |
| `stratim::fit_primary_model()` | Bayesian hierarchical model (Stan/HMC) |
| `stratim::compare_kernels()` | Exponential vs. power-law identifiability (H5) |
| `stratim::classify_states()` | 3A / 3B / J classification |
| `stratim::test_h1()` | ROPE-based H1 decision |
| `stratim::power_surface()` | Monte Carlo power surface across the parameter grid |

Planned (Python):

| Function | Purpose |
|----------|---------|
| `stratim.instruments.sic_task()` | SIC task administration |
| `stratim.instruments.opportunity_audit()` | Structured opportunity audit |
| `stratim.diagnostics.auc_compare()` | Diagnostic sufficiency (H3) |

---

## 📄 Research Paper

**Title:** *Strategic Imagination Capacity Under Chronic Material Pressure: A Dynamic State-Space Model*
**Author:** Samir Baladi
**Status:** Working manuscript (v0.2.0-simulation), not yet submitted
**Sections:** 10 (Introduction → Conclusion), plus simulation results (§7.13)

Key claims:

- Two state variables (`O`, `SIC`) instead of one collapsed behavioral outcome
- Sequential stages replaced by a dynamic state space with reference regions
- Pre-specified decision rules: ε, MID, Δ\*_AUC
- Nine hypotheses, each with a pre-specified disconfirming region
- Simulation-verified identifiability, parameter recovery, and power — see [Simulation Results](#-simulation-results)

```bibtex
@misc{baladi2026stratim,
  author = {Baladi, Samir},
  title  = {STRATIM: Strategic Imagination Capacity Under Chronic
            Material Pressure — A Dynamic State-Space Model},
  year   = {2026},
  version = {0.2.0-simulation},
  doi    = {10.5281/zenodo.22975701},
  url    = {https://doi.org/10.5281/zenodo.22975701},
  note   = {Working manuscript, simulation-complete protocol stage}
}
```

---

## 🌐 Platforms & Resources

| Platform | URL | Role |
|----------|-----|------|
| 🦊 **GitLab** (Primary) | [gitlab.com/gitdeeper15/STRATIM](https://gitlab.com/gitdeeper15/STRATIM) | Source code, CI/CD |
| 🐙 **GitHub** (Mirror) | [github.com/gitdeeper15/STRATIM](https://github.com/gitdeeper15/STRATIM) | Mirror, issues |
| 🔬 **Zenodo** | [doi.org/10.5281/zenodo.22975701](https://doi.org/10.5281/zenodo.22975701) | Citable DOI (reserved) |
| 📋 **OSF Project** | [osf.io/3qp9u](https://osf.io/3qp9u) | Associated project |
| 📝 **OSF Registration** | [doi.org/10.17605/OSF.IO/E5F8R](https://doi.org/10.17605/OSF.IO/E5F8R) | Pre-registration record (CC-BY 4.0) |
| 🗄️ **Internet Archive** | [archive.org/details/osf-registrations-e5f8r-v1](https://archive.org/details/osf-registrations-e5f8r-v1) | Permanent archival copy of the registration |
| 🧑‍🔬 **ORCID** | [orcid.org/0009-0003-8903-0029](https://orcid.org/0009-0003-8903-0029) | Researcher identity |

**What is not yet available:**

- Empirical participant data (no study conducted yet)
- Pilot data (pilot not yet conducted)
- Deposited Zenodo record (DOI reserved, not yet deposited)
- PyPI package (STRATIM is a research protocol, not a shipped library)

---

## 🤝 Contributing

At the simulation-complete protocol stage, contributions are welcome in the following forms:

```bash
git checkout -b feature/YourFeature
git commit -m 'Add YourFeature'
git push origin feature/YourFeature
# Open a Merge Request on GitLab (primary) or a Pull Request on GitHub (mirror)
```

Preferred contributions:

- Simulation code improvements (R / Stan)
- Power-surface extension (additional parameter combinations)
- Kernel-identifiability analysis beyond the current (λ, ρ) grid
- Instrument design review (SIC task, opportunity audit)
- Documentation clarity

**Standards:** PEP 8 (Python), tidyverse style (R), type hints, docstrings, test coverage above 80%.

---

## 📖 Citation

If STRATIM contributes to your research, please cite the working manuscript:

```bibtex
@misc{baladi2026stratim,
  author = {Baladi, Samir},
  title  = {STRATIM: Strategic Imagination Capacity Under Chronic
            Material Pressure — A Dynamic State-Space Model},
  year   = {2026},
  version = {0.2.0-simulation},
  doi    = {10.5281/zenodo.22975701},
  url    = {https://doi.org/10.5281/zenodo.22975701},
  note   = {Working manuscript, simulation-complete protocol stage}
}
```

**APA (inline):**
> Baladi, S. (2026). *STRATIM: Strategic Imagination Capacity Under Chronic Material Pressure — A Dynamic State-Space Model* (Version 0.2.0-simulation). <https://doi.org/10.5281/zenodo.22975701>

To cite the formal pre-registration record instead:

```bibtex
@misc{baladi2026stratim_osf,
  author    = {Baladi, Samir},
  title     = {STRATIM: Strategic Imagination Capacity Under Chronic
               Material Pressure — Pre-Registration},
  year      = {2026},
  publisher = {Open Science Framework},
  doi       = {10.17605/OSF.IO/E5F8R},
  url       = {https://doi.org/10.17605/OSF.IO/E5F8R},
  note      = {OSF Registration; associated project: https://osf.io/3qp9u;
               archived at https://archive.org/details/osf-registrations-e5f8r-v1}
}
```

**APA (inline):**
> Baladi, S. (2026). *STRATIM: Strategic Imagination Capacity Under Chronic Material Pressure* [Pre-registration]. Open Science Framework. <https://doi.org/10.17605/OSF.IO/E5F8R>

---

## 📜 License

- **Code:** MIT License
- **Manuscript and documentation:** CC-BY-4.0
- **OSF pre-registration** ([10.17605/OSF.IO/E5F8R](https://doi.org/10.17605/OSF.IO/E5F8R)): CC-BY Attribution 4.0 International

See [`LICENSE`](LICENSE) for full text.

---

## 👤 Author

**Samir Baladi** — Independent Interdisciplinary Researcher, Principal Investigator
Ronin Institute / Rite of Renaissance

| Contact | Link |
|---------|------|
| 📧 Email | <gitdeeper@gmail.com> |
| 🧑‍🔬 ORCID | [0009-0003-8903-0029](https://orcid.org/0009-0003-8903-0029) |
| 🦊 GitLab | [gitlab.com/gitdeeper15](https://gitlab.com/gitdeeper15) |
| 🔬 Zenodo (reserved DOI) | [doi.org/10.5281/zenodo.22975701](https://doi.org/10.5281/zenodo.22975701) |
| 📋 OSF Project | [osf.io/3qp9u](https://osf.io/3qp9u) |
| 📝 OSF Registration DOI | [doi.org/10.17605/OSF.IO/E5F8R](https://doi.org/10.17605/OSF.IO/E5F8R) |
| 🗄️ Internet Archive | [archive.org/details/osf-registrations-e5f8r-v1](https://archive.org/details/osf-registrations-e5f8r-v1) |

**Acknowledgments:** the open-source scientific ecosystem (R, Stan, brms, lme4); researchers working on scarcity, opportunity structure, and future-oriented cognition; methodologists in Bayesian hierarchical modeling and kernel identification. No external funding, partners, or field sites yet — pending: IRB, pilot site, calibration-sample provider.

---

<div align="center">

**STRATIM v0.2.0-simulation · September 2026 · No empirical data yet**

Made with care by Samir Baladi

Star · Share · Cite · Contribute

[Back to top](#stratim)

</div>
