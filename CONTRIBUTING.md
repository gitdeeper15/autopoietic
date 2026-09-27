# Contributing to STRATIM

STRATIM is currently at the **protocol stage** (v0.1.0-protocol). No empirical data has been collected. Contributions at this stage focus on the protocol itself, the simulation code, and the instrument design.

## What Contributions Are Welcome

### 1. Simulation Code (R / Stan)

The highest-priority contribution area. Currently, the `SIMULATION/code/` directory is under construction. Contributions are welcome in:

- Data generating process (R)
- Kernel identifiability analysis (R)
- Parameter recovery simulations (R / Stan)
- Power surface computation (R)
- Model diagnostics (Stan)

**Standard:** R code follows the [tidyverse style guide](https://style.tidyverse.org/). Stan code follows the [Stan style guide](https://mc-stan.org/docs/stan-users-guide/style-guide.html).

### 2. Methodological Review

Critical review of the protocol is welcome, particularly regarding:

- Whether the two-state-variable separation (`O^objective`, `SIC`) is empirically identifiable.
- Whether the ROPE-based decision rules (ε, MID, Δ*_AUC) are adequately specified.
- Whether the kernel comparison (H5) is feasible within the 18-month window.
- Whether the model reduction sequence is adequate for convergence failures.
- Whether the SIC task dimension structure (generate, elaborate, compare, revise) is psychometrically defensible.

### 3. Instrument Design

Review of planned instruments, including:

- SIC task forms A–D (parallel-form equivalence).
- Opportunity audit instrument (domain coverage, accessibility criteria).
- Monthly detection instrument (sensitivity vs. burden tradeoff).
- Rehearsal log (retrospective bias minimization).
- Recovery measures (objective, subjective, behavioral components).

### 4. Documentation

Clarifying the protocol, improving the README, or contributing to `DOCS/`.

## What Contributions Are Not Welcome

The following are explicitly outside the scope of STRATIM:

- Empirical data submissions (none exists yet, and the design has strict eligibility criteria).
- Deployment infrastructure (dashboards, APIs, web apps).
- Hardware or sensor integration.
- PyPI package releases at this stage.
- Changes to hypotheses or decision rules after pre-registration without explicit documentation as protocol amendments.

## How to Contribute

### Reporting Issues

Open an issue on [GitLab Issues](https://gitlab.com/gitdeeper15/STRATIM/-/issues) with:

- A clear description of the issue.
- The relevant section of the protocol or code.
- A suggested resolution, if available.

### Submitting Code Changes

1. Fork the repository.
2. Create a feature branch:
   ```bash
   git checkout -b feature/your-feature
```

3. Make your changes.
4. Run tests and linters:
   ```bash
   make test
   make lint
   ```
5. Commit with a descriptive message.
6. Push and open a Merge Request.

Code Standards

· Python: PEP 8, type hints, docstrings (Google style). Format with black, isort, flake8, mypy.
· R: tidyverse style, styler for formatting, lintr for linting.
· Stan: Stan style guide.
· Markdown: markdownlint (MD013 disabled).
· Commit messages: imperative mood, clear scope.

Review Process

· All changes are reviewed by the maintainer.
· Changes that affect hypotheses, decision rules, or the primary model require explicit documentation as protocol amendments.
· Changes to the analysis plan after data collection begins are documented as deviations and reported in the manuscript.

A Note on Protocol Integrity

STRATIM is a pre-registered protocol. Changes to hypotheses, decision rules, or the primary model after pre-registration must be:

1. Documented in CHANGELOG.md.
2. Labeled as protocol amendments (if before data collection) or deviations (if after).
3. Reported in the final manuscript with explicit rationale.

This ensures the protocol's pre-registration remains auditable.

Contact

· Issues: https://gitlab.com/gitdeeper15/STRATIM/-/issues
· Email: gitdeeper@gmail.com

---

Thank you for contributing to STRATIM.
