# Contributing to Autopoietic Code Rewriting

This project is at the **initial research-draft stage** (`0.1.0-research-draft`).
No pilot has been executed. Contributions at this stage focus on the formal
model, invariant specification, implementation, and experimental design.

## What Contributions Are Welcome

### 1. Invariant Implementation

The three invariant layers are the core of the admissibility policy:

- **Syntactic** (S1–S6): parse validity, signature preservation, no new imports, no new decorators.
- **Structural** (T1–T5): binding preservation, no invalid cycles, no orphan variables, no new globals.
- **Behavioral** (B1–B4): return values, exceptions, stdout trace, side effects over a defined corpus.

**Standard:** PEP 8, type hints, docstrings, unit tests with edge cases.

### 2. Differential Testing Strategies

The behavioral layer relies on differential testing between P₀ and P₁ over a defined corpus.

Contributions welcome in:
- Corpus design (valid, edge, invalid, fuzzed inputs).
- Fuzzing infrastructure with fixed seeds.
- Exception fingerprint comparison.
- stdout trace comparison.

### 3. Isolation Mechanisms

The initial pilot uses `multiprocessing` as **logical isolation** — not a
security sandbox. Contributions comparing stronger isolation (Docker, gVisor,
Firecracker, WASM) are welcome, but must clearly state the isolation model.

### 4. Workload Design

Three workload categories are proposed:
- **W1 Micro-benchmark:** simple computational functions.
- **W2 Representative:** functions from small application components.
- **W3 Edge cases:** early return, exception-raising, None-returning functions.

Contributions welcome: diverse function populations that stress the invariants
without extending the phase-I scope (no decorators, closures, or stateful functions).

### 5. Failure Injection Scenarios

The pilot uses four failure categories (FI-1 to FI-4):
1. Syntactic corruption.
2. Structural corruption (unresolved symbols, invalid scope).
3. Silent semantic change (e.g., `+` → `-`).
4. Timeout injection.

Contributions welcome: additional injection scenarios that stress the invariant
layers without changing them.

### 6. Documentation

Clarifying `docs/invariants_spec.md`, `docs/experiment_protocol.md`, or
`docs/decision_rules.md`.

## What Contributions Are Not Welcome at Phase I

The following are outside the current scope:

- Module-level or system-level rewriting.
- Stateful function support.
- Adversarial security isolation.
- Formal semantic equivalence proofs.
- Cross-language generalization.
- Modifications to invariants that weaken their admissibility policy without
  documented rationale.

## How to Contribute

### Reporting Issues

Open an issue with:
- A clear description.
- The relevant module or document.
- A minimal reproduction if applicable.

### Submitting Code Changes

1. Fork the repository.
2. Create a feature branch:

```

git checkout -b feature/your-feature

```

3. Make changes.
4. Run tests and linters:

```

python -m pytest -v
black .
isort .
flake8 .
mypy core invariants sandbox

```

5. Commit with a descriptive message.
6. Open a Merge Request / Pull Request.

## Code Standards

| Language | Standard |
|----------|----------|
| Python | PEP 8, black (88 chars), isort, flake8, mypy |
| Markdown | markdownlint (MD013 disabled) |
| Commit messages | Imperative mood, clear scope |

**Test coverage:** ≥ 80% for new modules.

## Review Process

- All changes are reviewed.
- Changes to the invariant specification or admissibility policy require
  explicit documentation in `CHANGELOG.md` with rationale.
- Changes to the experimental protocol after the pilot begins are documented
  as protocol amendments.

## A Note on Protocol Integrity

The experiment protocol is fixed before the pilot begins. The transition
criteria (TSR ≥ 90%, UDR ≥ 95%, OH ≤ 2×, SRF = 100%) are proposed
engineering gates — not scientific laws. They may be revised based on
baseline calibration, but any revision is documented.

## Contact

- Issues: https://gitlab.com/gitdeeper15/Autopoietic/-/issues
- Email: gitdeeper@gmail.com

---

Thank you for contributing to Autopoietic Code Rewriting.
