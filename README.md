<div align="center">

# Autopoietic Code Rewriting

### Controlled Runtime AST Transformation inside Isolated Execution Environments

*Stability Conditions · Structural Invariants · Differential Verification · Controlled Deployment*

---

[![Python](https://img.shields.io/badge/python-3.11+-3776ab?style=flat-square&logo=python&logoColor=white)](https://python.org)
[![LibCST](https://img.shields.io/badge/LibCST-1.x-2c5f7d?style=flat-square)](https://libcst.readthedocs.io/)
[![Status](https://img.shields.io/badge/status-experimental--design-blue?style=flat-square)]()
[![Scope](https://img.shields.io/badge/scope-function--level-orange?style=flat-square)]()
[![License: MIT](https://img.shields.io/badge/license-MIT-27ae60?style=flat-square)](LICENSE)

---

**`4 Transformations`** · **`3 Invariant Layers`** · **`4 Operational Dimensions`** · **`6 Pipeline Stages`** · **`4-Week Pilot`**

---

[Research Paper](RESEARCH_PAPER/) · [Protocol](PREREGISTRATION/) · [Simulation](SIMULATION/) · [Instruments](INSTRUMENTS/) · [Quick Start](#-quick-start)

</div>

---

## Overview

**Autopoietic Code Rewriting** investigates the conditions under which a software system can modify its own source-code representation during runtime while preserving structural integrity, execution continuity, and behavioral consistency.

Rather than treating self-modification as an unrestricted capability, this project defines it as a **constrained transformation process** governed by explicit syntactic, structural, and behavioral invariants.

The initial implementation is deliberately restricted to **individual top-level Python functions**, using **LibCST** for AST transformation and **multiprocessing** for logical execution isolation.

> *"The ability to generate a modified program is separated from the ability to establish its admissibility."*

### Core Principle

```

Accept(P₁) ⟺ I_syntactic(P₁) ∧ I_structural(P₁) ∧ I_behavioral(P₁, P₀)
Reject(P₁) ⟺ ¬I_s ∨ ¬I_t ∨ ¬I_b
Inconclusive ⟺ timeout (never treated as Accept)

```

---

## What's New

> **Status:** Initial Research Draft — Implementation Specification
> **Scope:** Function-Level Runtime Code Rewriting (Python 3.11+ / LibCST / multiprocessing)

This release establishes:

- A **layered invariant model** separating syntactic, structural, and behavioral validity.
- A **two-phase rewriting architecture** (candidate construction → controlled activation).
- A **four-dimensional operational model** separating isolation, verification, transition integrity, and recoverability.
- A **reproducible pilot protocol** with explicit transition criteria from function-level to module-level.

**What is *not* yet demonstrated:**

- Empirical results (no pilot executed yet)
- Module-level or system-level rewriting
- Stateful recovery fidelity (deferred to a later phase)
- Adversarial security isolation (multiprocessing is logical, not hardened)

---

## Key Features

| Feature | Description |
|---------|-------------|
| **Two-State Architecture** | Original (P₀) and candidate (P₁) program representations held independently |
| **Layered Verification** | I_syntactic · I_structural · I_behavioral — three distinct evidence layers |
| **Differential Testing** | Empirical observational equivalence over a defined input corpus (not formal proof) |
| **Isolated Candidate Execution** | `multiprocessing` — logical isolation, not a security sandbox |
| **Two-Phase Rewriting** | Candidate construction is separated from activation |
| **Atomic Swap + Rollback** | Controlled transition with explicit rollback path |
| **State Restoration Fidelity** | Measured independently from rollback success (deferred to stateful phase) |
| **Transition Criteria** | Explicit numeric gates before extending scope to module-level |
| **Reproducible Protocol** | 4-week pilot with fixed seeds, workload sets, and failure injection |

---

## Four Operational Dimensions

> No dimension is assumed to guarantee another.

| Dimension | Primary Question | Evaluation |
|-----------|------------------|------------|
| **Isolation** | Can candidate execution be separated from the original process? | Isolation tests |
| **Verification** | Does the candidate satisfy defined acceptance conditions? | Invariant + behavioral tests |
| **Transition Integrity** | Can activation occur without partial or inconsistent deployment? | Deployment continuity tests |
| **Recoverability** | Can the previous required state be restored? | Rollback + SRF |

---

## Four Transformation Classes (Initial Scope)

| Transformation | Example | Invariant Tested |
|----------------|---------|------------------|
| **Constant Folding** | `2 + 3` → `5` | Syntactic + Behavioral |
| **Algebraic Simplification** | `x * 1` → `x` | Structural + Behavioral |
| **Dead Branch Elimination** | `if False: ...` → removed | Structural |
| **Local Variable Renaming** | `y` → `z` (scope-aware) | Structural (binding preservation) |

**Excluded in Phase I:**
Function signature changes · imports · closures · decorators · cross-function dependencies · arbitrary external state.

---

## Six-Stage Pipeline

```

┌─────────────────────────────────────────────────────────────┐
│  1. Extract      →  Load P₀, preserve source hash          │
│  2. Analyze      →  Build dependency graph, symbol table   │
│  3. Transform    →  Produce candidate P₁ = T(P₀, θ)        │
│  4. Sandbox      →  Execute P₁ in isolated multiprocessing │
│  5. Verify       →  I_s ∧ I_t ∧ I_b + differential test    │
│  6. Deploy       →  Atomic swap  or  rollback              │
└─────────────────────────────────────────────────────────────┘

```

Each stage is implemented as an independent module with its own test suite.

---


## Implementation Status

| Layer | Module | Spec | Status | Tests |
|-------|--------|------|--------|-------|
| Core — Extraction | `core/extractor.py` | — | ✅ Complete | 3 |
| Core — Transformation | `core/transformer.py` | 4 transforms | ✅ Complete | 4 |
| Syntactic (I_s) | `invariants/syntactic.py` | S1–S6 | ✅ Complete | 22 |
| Structural (I_t) | `invariants/structural.py` | T1–T5 | ✅ Complete | 23 |
| Behavioral (I_b) | `invariants/behavioral.py` | B1–B4 | ✅ Complete | 18 |
| Sandbox — Isolation | `sandbox/isolated_runner.py` | multiprocessing + side-effect enforcement | ✅ Complete | 17 |
| Sandbox — Differential | `sandbox/differential.py` | P₀ vs P₁ on corpus | ✅ Complete | 12 |
| Deployer | `core/deployer.py` | atomic swap + rollback | ✅ Complete | 19 |
| **Total** | | | **118/118 passing** | **118** |

**Current VERSION:** `0.2.0-implementation`
**Scope:** Function-level, stateless, Python 3.11+
**Test environment:** Python 3.13.13, libcst 1.9.0, pytest 9.0.3
**Phase I status:** ✅ Complete — all 8 modules implemented and tested.

---


## Project Structure

```

Autopoietic/
├── README.md                       # this file
├── CHANGELOG.md                    # version history
├── LICENSE                         # MIT
├── CITATION.cff                    # citation metadata
├── VERSION                         # 0.1.0-research-draft
├── pyproject.toml                  # package + tool config
├── setup.py / setup.cfg            # legacy compatibility
├── requirements.txt                # runtime dependencies
├── Makefile                        # common targets
│
├── core/
│   ├── extractor.py                # P₀ → ExtractedFunction
│   ├── transformer.py              # 4 controlled transformations
│   └── deployer.py                 # atomic swap + rollback
│
├── invariants/
│   ├── syntactic.py                # I_s: parse, signature, no new imports
│   ├── structural.py               # I_t: bindings, dependencies, scope
│   └── behavioral.py               # I_b: return, exception, stdout
│
├── sandbox/
│   ├── isolated_runner.py          # multiprocessing execution
│   └── differential.py             # P₀ vs P₁ on corpus
│
├── experiments/
│   ├── workloads/                  # 24 functions (W1/W2/W3)
│   ├── injectors/                  # FI-1 to FI-4 failure injection
│   └── runners/                    # pilot runner + metrics collector
│
├── tests/
│   ├── test_extractor.py
│   ├── test_transformer.py
│   ├── test_invariants.py
│   ├── test_sandbox.py
│   └── test_deployer.py
│
├── DOCS/
│   ├── invariants_spec.md          # formal acceptance/rejection rules
│   ├── experiment_protocol.md      # 4-week pilot specification
│   └── decision_rules.md           # transition criteria thresholds
│
├── RESEARCH_PAPER/                 # manuscript
├── PREREGISTRATION/                # hypotheses + analysis plan
├── SIMULATION/                     # future: numerical experiments
├── VALIDATION/                     # future: results validation
├── ANALYSIS/                       # future: post-pilot analysis
├── DATA/                           # future: raw/processed datasets
├── MODEL/                          # future: numerical model
├── INSTRUMENTS/                    # future: measurement instruments
├── DOCS/                           # extended documentation
├── PUBLICATION/                    # future: release artifacts
└── results/                        # experiment outputs (JSON)

```

---

## Quick Start

```bash
# Clone / enter the project
cd /storage/emulated/0/Download/Autopoietic

# Create and activate virtual environment
python -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install --upgrade pip
pip install libcst pytest pytest-cov

# Run the test suite
python -m pytest -v

# Verify the environment
python -c "import libcst; print('libcst', libcst.__version__)"
```

---

Installation

Python (required):

```bash
# Termux / Debian
pkg install python
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

Dependencies:

Package Purpose
libcst Concrete syntax tree with formatting preservation
pytest Test runner
pytest-cov Coverage reporting

---

Usage

```bash
# Extract a function and inspect its AST representation
python -c "from core.extractor import extract_from_source; \
           ext = extract_from_source('def f(x): return 2+3+x', 'f'); \
           print(ext.function_source)"

# Apply a single transformation
python -c "from core.transformer import ConstantFolding; \
           from core.extractor import extract_from_source; \
           ext = extract_from_source('def f(x): return 2+3+x', 'f'); \
           r = ConstantFolding().apply(ext.function_node); \
           print(ext.module.code_for_node(r.new_function))"

# Run the full test suite
python -m pytest -v

# Run only one module's tests
python -m pytest tests/test_transformer.py -v
```

---

Verification Model

Syntactic Invariants (I_s)

# Condition Check
S1 P₁ parses as valid Module cst.parse_module
S2 Contains one FunctionDef node count
S3 Function name unchanged name compare
S4 Signature unchanged params compare
S5 No new decorators decorator set
S6 No new imports Import scan

Structural Invariants (I_t)

# Condition Check
T1 Every Name has a binding scope analysis
T2 No invalid dependency cycles DFS cycle detection
T3 No orphan variables liveness diff
T4 No new global statements AST scan
T5 All local calls resolve symbol table

Behavioral Invariants (I_b)

# Condition Check
B1 Return values match on corpus differential
B2 Exceptions match (type + message) differential
B3 stdout trace matches differential
B4 No new side effects sandbox enforcement

Timeout → Inconclusive (never Accepted).

---

Evaluation Metrics

Metric Definition
TSR Transformation Success Rate
UDR Unsafe-change Detection Rate
FPR False Positive Rate (valid rejected)
FNR False Negative Rate (unsafe accepted)
OH Runtime Overhead vs. baseline
MTTR Mean Time to Recovery
SRF State Restoration Fidelity (deferred)
Coverage Proportion of invariants actually verified

Numeric thresholds are established after baseline calibration — not assumed.

---

Transition Criteria (Function → Module)

Criterion Required Measurement
Mechanism stability TSR ≥ 90% on valid transforms pilot
Unsafe-change detection UDR ≥ 95% on injected failures FI suite
Computational cost OH ≤ 2× baseline repeated benchmark
Recovery fidelity SRF = 100% on controlled tests recovery experiments

If any criterion fails → revise architecture before expansion.

---

Four-Week Pilot Plan

Week Focus Deliverable
1 Extraction + Transformation extractor.py, transformer.py, unit tests
2 Invariant Verification invariants/, differential.py, FI suite
3 Isolation + Deployment isolated_runner.py, deployer.py, rollback
4 Pilot Evaluation Baseline metrics, transition decision

---

Research Status

Dimension Status
Formal model ✅ Defined (paper §3)
Architecture ✅ Specified (paper §4)
Invariant layers ✅ Specified (paper §6)
Implementation 🟡 In progress (function-level)
Pilot data ❌ Not yet collected
Empirical results ❌ Not yet available
Module-level ❌ Out of scope (Phase II)
Stateful recovery ❌ Deferred (Phase III)
Adversarial isolation ❌ Out of scope

---

Threats to Validity

Type Concern Mitigation
Construct Observation model determines what differential testing can detect Explicit corpus + documented observables
Internal Results may reflect implementation details Fixed hardware, versions, workloads
External Python-only results may not generalize Scope explicitly restricted
Statistical Pilot too small for general claims Feasibility only; variance for future study
Security multiprocessing is not a hardened sandbox Documented; not claimed

---

Limitations

The present study is restricted to:

· Python 3.11+ and LibCST
· Individual top-level functions (no methods, closures, decorators)
· Stateless functions (no mutable global state)
· Four transformation classes
· Logical isolation via multiprocessing

Not addressed in Phase I:

· Formal semantic equivalence (only empirical over corpus)
· Concurrency and live deployment
· Cross-language generalization
· Adversarial code isolation

---

Research Paper

Title: Autopoietic Code Rewriting inside Isolated Execution Environments — Stability Conditions, Structural Invariants, and Controlled Runtime Transformation

Status: Initial Complete Research Manuscript — Experimental Validation Pending
Scope: Function-Level Runtime Code Rewriting
Implementation Baseline: Python 3.11+ / LibCST / multiprocessing

See RESEARCH_PAPER/ for the full manuscript.

---

Contributing

At the implementation-specification stage, contributions are welcome in:

· Invariant implementations (syntactic, structural, behavioral)
· Differential testing strategies (corpus design, fuzzers)
· Isolation mechanisms (beyond multiprocessing)
· Workload design (diverse function populations)
· Failure injection scenarios
· Documentation clarity

Standards: PEP 8, type hints, docstrings, test coverage ≥ 80%.

---

License

· Code: MIT License (see LICENSE)
· Manuscript and documentation: CC-BY-4.0

---

Citation

```bibtex
@misc{autopoietic_rewriting_2026,
  title  = {Autopoietic Code Rewriting inside Isolated Execution
            Environments: Stability Conditions, Structural Invariants,
            and Controlled Runtime Transformation},
  year   = {2026},
  version = {0.1.0-research-draft},
  note   = {Initial Research Manuscript — Experimental Validation Pending}
}
```

DOI, OSF, and Zenodo records to be added upon submission.

---

<div align="center">

Autopoietic Code Rewriting · v0.1.0-research-draft · 2026

Function-Level Scope · Experimental Validation Pending

</div>
