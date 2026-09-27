# STRATIM — Simulation

This directory contains the Monte Carlo simulation code for STRATIM.

The simulation serves three purposes:

1. **Design validation.** Checks whether the pre-specified design
   (18 months, 4 waves) can identify what the model claims to
   identify, before any data is collected.

2. **Parameter recovery.** Tests whether the estimation procedure
   recovers the true parameters used in the data generating
   process.

3. **Power surface.** Estimates the statistical power of each
   hypothesis as a joint function of sample size, effect size,
   individual heterogeneity, and attrition.

None of the outputs in this directory are empirical results.
They are properties of the design and the model, not of any
population.

## Directory layout

```

SIMULATION/
├── README.md                (this file)
├── code/
│   ├── 00_dgp.R             Data generating process
│   ├── 01_H5_identifiability.R   Kernel identifiability check
│   ├── 02_parameter_recovery.R   Parameter recovery study
│   └── 03_power_surface.R        Monte Carlo power surface
├── configs/
│   └── parameters.yaml      Default parameters + grids
├── results/                 Output CSV files (gitignored except .gitkeep)
└── synthetic_data/          Generated datasets (gitignored)

```

## How to run

From the repository root:

```bash
# Identifiability check (fast; ~1 minute)
Rscript SIMULATION/code/01_H5_identifiability.R

# Parameter recovery (moderate; ~5-15 minutes)
Rscript SIMULATION/code/02_parameter_recovery.R

# Power surface (slow; ~30-120 minutes depending on grid size)
Rscript SIMULATION/code/03_power_surface.R
```

Or via make:

```bash
make identifiability
make recovery
make power
```

Dependencies

R packages required:

· lme4 (for parameter recovery and power surface)
· stats (base R)

For the full Bayesian estimation (Stan / brms), additional
packages will be required once the Stan models are written.
See MODEL/stan/.

Interpreting the results

01_H5_identifiability.R

· If all median correlations > 0.95, the design cannot distinguish
  exponential from power-law kernels. H5 is reported as "not
  testable within the window."
· If some correlations < 0.90, H5 is testable only in those
  regions of the parameter grid.

02_parameter_recovery.R

· Bias > 30% of true value indicates a problem with the design
  or estimator.
· Heavy underestimation of sigma_alpha indicates that 3
  transitions per participant are insufficient to recover
  between-individual heterogeneity. H1d may need to be demoted
  to secondary.

03_power_surface.R

· Minimum N for 0.80 power is reported per hypothesis.
· If a hypothesis never reaches 0.80 power, that is a design
  finding, not a failure. The hypothesis is either demoted or
  the design is revised.

Notes on reproducibility

· All scripts use set.seed() with explicit seeds.
· Scripts source 00_dgp.R relatively, so they must be run
  from the repository root or from SIMULATION/code/.
· Results are written to SIMULATION/results/ as CSV.
· Raw .rds files are not committed (see .gitignore).

Relationship to the protocol

· Section 3.4 defines the kernel comparison.
· Section 6.11 defines the primary dynamic model.
· Section 6.12 defines the simulation-based power analysis.
· Section 7.4 defines exposure construction.
· Section 7.10 defines the H5 decision rule.
· Section 7.14 defines the underpowered-hypothesis rule.

If any script contradicts the protocol, the protocol takes
precedence and the script must be updated.

What this directory does not contain

· Empirical data.
· Any analysis that requires participant data.
· Any output that could be mistaken for a substantive finding.

All outputs are design-level or method-level artifacts.
