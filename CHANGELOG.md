# Autopoietic Code Rewriting — Changelog

All notable changes to this research project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

**Versioning scheme.**

- **Research-draft versions** (`0.x.y-research-draft`): changes to the formal model, invariant specification, architecture, or experimental protocol.
- **Implementation versions** (`0.x.y-implementation`): changes to the code (extractor, transformer, invariants, sandbox, deployer).
- **Pilot versions** (`0.x.y-pilot`): changes following pilot experiments.
- **Stable versions** (`x.y.z`): after module-level validation.

At the current stage, no pilot data has been collected.

---

## [0.2.0-implementation] — 2026-10-31

### Phase I Complete: Function-Level Runtime Code Rewriting

This release completes Phase I of the implementation. All core modules,
three verification layers (syntactic, structural, behavioral), the
isolation and differential-testing sandbox, and the atomic deployer
are implemented and tested. **118/118 tests passing.**

No pilot has been executed. No empirical data is included.
State restoration fidelity remains deferred to Phase III.

### Added — Deployer

- `core/deployer.py`:
  - `Deployer` class managing atomic swap between P0 and candidates.
  - `try_deploy(candidate, accept_condition)` — activates the candidate
    only if `accept_condition()` returns True. Any exception raised by
    the condition is treated as rejection.
  - `rollback()` — reverts to the most recent previous active source.
  - `reset()` — restores P0 and clears history.
  - `history` — immutable tuple of all deployed sources.
  - `original_source` — immutable P0.
  - Integration with `check_behavioral` verified in tests.
  - State Restoration Fidelity (SRF) intentionally deferred to Phase III
    (stateless functions only at this stage).
- `tests/test_deployer.py` — 19 tests.

### Changed — Versioning

- `VERSION` promoted from `0.1.0-research-draft` to `0.2.0-implementation`.
  Rationale: Phase I is complete (all core modules implemented and tested).
  No empirical claims are made.

### Known Issues

- `mypy` (2.4.1) raises `INTERNAL ERROR` on Python 3.13. Workaround:
  `pip install 'mypy<2' --force-reinstall` (or run `make lint-mypy`
  separately). The `lint` target skips `mypy` by default to keep CI green.
  This is a tool issue, not a code issue; all 118 tests pass regardless.

### Status — Phase I Complete

| Dimension | Status | Tests |
|-----------|--------|-------|
| Core (extractor + transformer) | ✅ Working | 7 |
| Deployer (atomic swap + rollback) | ✅ Working | 19 |
| Syntactic layer (S1–S6) | ✅ Working | 22 |
| Structural layer (T1–T5) | ✅ Working | 23 |
| Behavioral layer (B1–B4) | ✅ Working | 18 |
| Sandbox (isolated_runner + differential) | ✅ Working | 29 |
| **Total** | | **118** |
| Pilot data | ❌ Not yet collected | — |
| Empirical results | ❌ Not yet available | — |
| Stateful / SRF | ⏳ Deferred (Phase III) | — |
| Module-level rewriting | ⏳ Conditional (Phase II) | — |

### Transition to Phase II

Phase II (module-level rewriting) is conditional on the Phase I
transition criteria being met during the pilot:
  - TSR ≥ 90% on valid transformations
  - UDR ≥ 95% on injected failures
  - OH ≤ 2× baseline
  - Rollback success = 100%

The pilot itself (`0.3.0-pilot`) has not been executed yet.

---

## [0.1.0-research-draft] — 2026-10-31

### Initial Research Manuscript, Core Implementation, and Two Verification Layers

This release establishes the complete initial research manuscript for
**Autopoietic Code Rewriting inside Isolated Execution Environments**,
the first working implementation modules, the syntactic and structural
verification layers, and a passing unit-test suite (52/52).

No empirical data is included. No pilot has been executed.

### Added — Research Framework

#### Formal Model
- Two-phase rewriting architecture: candidate construction separated from activation.
- Program model: `P₀ = (A₀, D₀, S₀)` — abstract syntax, dependencies, source.
- Transformation operator: `P₁ = T(P₀, θ)`.
- Admissibility condition: `Deploy(P₁) = A(P₁) ∧ D(P₁) ∧ B(P₀, P₁, X)`.
- Observation model: `O(f, x) = (R, E, ΔS, Σ)`.
- Four equivalence levels: structural, observational, empirical, semantic.

#### Layered Invariants
- **Syntactic** (I_s): S1–S6 — parse validity, signature preservation, no new imports, no new decorators.
- **Structural** (I_t): T1–T5 — binding preservation, no invalid cycles, no orphan variables, no new globals, local call targets.
- **Behavioral** (I_b): B1–B4 — return values, exceptions, stdout trace, side effects (specified, code to follow).

#### Four-Dimensional Operational Model
Explicit separation of:
1. **Isolation** — candidate execution separated from the parent process.
2. **Verification** — candidate satisfies defined acceptance conditions.
3. **Transition integrity** — activation without partial or inconsistent deployment.
4. **Recoverability** — restoration of required state, measured via **State Restoration Fidelity (SRF)**.

No dimension is assumed to guarantee another.

### Added — Implementation

#### Core Modules (working)
- `core/__init__.py` — package marker.
- `core/extractor.py` — `ExtractedFunction`, `extract_from_source`,
  `extract_from_file`, `replace_function`. Immutable extraction with
  SHA-256 source hash.
- `core/transformer.py` — four controlled transformations:
  - `ConstantFolding` — folds `2 + 3 → 5`, restricted to int/float and `+`, `-`, `*`.
  - `AlgebraicSimplification` — `x * 1 → x`, `x + 0 → x`, `x - 0 → x`.
  - `DeadBranchElimination` — removes branches with literal `True`/`False` conditions.
  - `LocalVariableRenaming` — scope-aware rename of a local variable.
  - `TransformationResult` dataclass + `TransformationError`.
  - `TRANSFORMATIONS` registry.

#### Invariants — Syntactic Layer (I_s)
- `invariants/syntactic.py` — implements S1–S6 as specified in `DOCS/invariants_spec.md`:
  - **S1** `check_s1_parses` — P₁ parses as a valid Module.
  - **S2** `check_s2_single_function` — exactly one top-level FunctionDef.
  - **S3** `check_s3_name_preserved` — function name unchanged.
  - **S4** `check_s4_signature_preserved` — signature (names, kinds, defaults presence) unchanged.
  - **S5** `check_s5_decorators_preserved` — no new decorators.
  - **S6** `check_s6_no_new_imports` — no new imports inside the function.
  - `CheckResult` dataclass, `SyntacticVerdict` composite.
  - `check_syntactic(P0, P1)` — runs all checks, returns composite verdict.

#### Invariants — Structural Layer (I_t)
- `invariants/structural.py` — implements T1–T5 as specified in `DOCS/invariants_spec.md`:
  - **T1** `check_t1_undefined_names` — every Name used has a binding (params, locals, globals, builtins, allowed_globals).
  - **T2** `check_t2_no_invalid_cycles` — no invalid cycles in local dependency graph (DFS).
  - **T3** `check_t3_no_orphan_variables` — variables used in P0 remain used in P1.
  - **T4** `check_t4_no_new_globals` — no new `global` statements.
  - **T5** `check_t5_local_call_targets` — local call targets resolve to known names.
  - `_UsedNameVisitor` — top-level visitor that correctly distinguishes assignment targets from uses (stack-based `_in_target` counter).
  - `check_structural(P0, P1)` — runs all checks, returns composite verdict.

#### Invariants — Behavioral Layer (I_b)
- `invariants/behavioral.py` — implements B1–B4 as specified in `DOCS/invariants_spec.md`:
  - **B1** `check_b1_return_values` — return values match over the corpus.
  - **B2** `check_b2_exceptions` — exceptions match (type + message) over the corpus.
  - **B3** `check_b3_stdout` — stdout traces match over the corpus.
  - **B4** `check_b4_no_new_side_effects` — no new side effects in P1, verified by runtime enforcement.
  - `BehavioralCheckResult` dataclass, `BehavioralVerdict` composite.
  - `check_behavioral(P0, P1, corpus)` — runs all checks.
  - **B4 scope (documented):** Monkeypatching is not a security sandbox. It detects *accidental* side effects introduced by transformations, not hostile code.

#### Package Structure
- `invariants/__init__.py` — package marker.
- `sandbox/__init__.py` — package marker.

#### Sandbox — Isolation and Differential Testing
- `sandbox/isolated_runner.py` — `run_isolated(source, function_name, args, kwargs, timeout_sec, enforce_no_side_effects)`:
  - Executes P1 in a separate process via `multiprocessing` (fork on Linux/Termux).
  - Captures return value, exception, stdout, timeout, duration.
  - **Timeout enforcement** (FI-4 detection).
  - **`enforce_no_side_effects=True`** — monkeypatches a curated allowlist of side-effect entry points (builtins.open, os.system, subprocess.*, socket.socket, urllib.request.urlopen) to stubs raising `_SideEffectBlocked(PermissionError)`.
  - **Scope documented:** monkeypatching is not a security sandbox; it detects accidental side effects, not hostile code.
  - `ExecutionResult` dataclass with fields: `return_value`, `exception`, `stdout`, `timed_out`, `duration_ms`, `error`.

- `sandbox/differential.py` — `differential_test(p0_source, p1_source, function_name, corpus, timeout_sec)`:
  - Runs P0 and P1 in isolation over a corpus.
  - Compares return values (NaN-aware), exceptions (strict), stdout (strict), timeouts.
  - `Input` dataclass, `Mismatch` dataclass, `DifferentialResult` composite.
  - Timeout in either side → mismatch; timeouts in P1 recorded separately.

### Added — Documentation

- `DOCS/invariants_spec.md` — formal acceptance/rejection rules for the three layers (S1–S6, T1–T5, B1–B4) + failure codes + decision policy.
- `DOCS/experiment_protocol.md` — 4-week pilot specification: workloads, corpus, failure injection, metrics, transition criteria.
- `README.md` — project overview, architecture, verification model, implementation status.
- `AUTHORS.md` — Principal Investigator: Samir Baladi (ORCID 0009-0003-8903-0029).
- `CONTRIBUTING.md` — scope, standards, contact.
- `LICENSE` — MIT for code, CC-BY-4.0 for documentation.
- `CITATION.cff` — citation metadata with author block.

### Added — Tests

| Module | Test file | Tests |
|--------|-----------|-------|
| `core/extractor.py` | `tests/test_extractor.py` | 3 |
| `core/transformer.py` | `tests/test_transformer.py` | 4 |
| `invariants/syntactic.py` | `tests/test_syntactic.py` | 22 |
| `invariants/structural.py` | `tests/test_structural.py` | 23 |
| `invariants/behavioral.py` | `tests/test_behavioral.py` | 18 |
| `sandbox/isolated_runner.py` | `tests/test_isolated_runner.py` | 17 |
| `sandbox/differential.py` | `tests/test_differential.py` | 12 |
| **Total** | | **99** |

**Status:** 99/99 tests passing (pytest 9.0.3, Python 3.13.13, libcst 1.9.0).

### Added — Project Infrastructure

- `pyproject.toml` — package metadata, dependencies (`libcst>=1.0.0`), tool config.
- `setup.py` / `setup.cfg` — legacy compatibility, author metadata.
- `requirements.txt` — runtime + dev dependencies.
- `Makefile` — `install`, `structure`, `test`, `lint`, `format`, `transform-demo`, `verify`, `clean`.
- `.gitignore` — Python, coverage, editors, OS, project-specific.
- `.coveragerc` — coverage configuration with `multiprocessing` concurrency.
- `.gitlab-ci.yml` — CI pipeline (validate, test, archive).
- `.pre-commit-config.yaml` — black, isort, flake8, mypy, pyupgrade, markdownlint, yamllint + local project checks.
- `.readthedocs.yaml` — documentation build configuration.

### Preserved from Prior Project

The following directories are preserved from the prior STRATIM project and
are not currently used by Autopoietic Code Rewriting:

- `ANALYSIS/`, `DATA/`, `INSTRUMENTS/`, `MODEL/`, `PREREGISTRATION/`,
  `PUBLICATION/`, `SIMULATION/`, `VALIDATION/`
- `RESEARCH_PAPER/` (target location for the manuscript)
- `tests/testthat/` (R tests, preserved)

The research manuscript text is preserved unchanged.

### Explicitly Out of Scope (Phase I)

- Module-level or system-level rewriting.
- Stateful functions and state recovery (deferred to Phase III).
- Adversarial security isolation.
- Formal semantic equivalence.
- Cross-language generalization.
- Concurrency and live deployment.
- `core/deployer.py` implementation (atomic swap + rollback) — **not yet coded** (Phase I, next step).
- Stateful function support and State Restoration Fidelity measurement.
- Module-level and system-level rewriting.
- Formal semantic equivalence.
- Cross-language generalization.
- Adversarial security isolation (monkeypatching is not a security sandbox).

### Not Included

- Empirical results (no pilot executed).
- DOI, OSF, or Zenodo records.
- Package distribution (PyPI).

### Status

| Dimension | Status | Tests |
|-----------|--------|-------|
| Formal model | Defined | — |
| Architecture | Specified | — |
| Invariant specification | Documented | — |
| Core (extractor + transformer) | ✅ Working | 7 |
| Syntactic layer (S1–S6) | ✅ Working | 22 |
| Structural layer (T1–T5) | ✅ Working | 23 |
| Behavioral layer (B1–B4) | ✅ Working | 18 |
| Sandbox (isolated_runner + differential) | ✅ Working | 29 |
| **Total** | | **99** |
| Deployer (atomic swap + rollback) | ⏳ Not yet coded | — |
| Pilot data | ❌ Not yet collected | — |
| Empirical results | ❌ Not yet available | — |

---

## Roadmap

### 0.1.1-implementation (next)
- Implement `core/deployer.py` (atomic swap + rollback).
- Add `tests/test_deployer.py`.
- Complete Phase I (function-level) implementation.

### 0.2.0-pilot
- Execute 4-week pilot.
- Collect baseline metrics.
- Determine transition criteria outcomes.

### 0.4.0-module-level (conditional)
- Extend to module-level rewriting **only if** transition criteria pass.

### 1.0.0-stateful (conditional)
- Introduce stateful functions.
- Measure State Restoration Fidelity under controlled snapshots.

---

## Notes on the Changelog

- Substantive changes only.
- Any change to invariants or the admissibility policy after the pilot begins
  is recorded as a protocol amendment with explicit rationale.
- Baseline numeric thresholds are set **after** pilot calibration, not before.
- Directories preserved from the prior STRATIM project are documented under
  "Preserved from Prior Project".

---

**Last Updated:** 2026-10-31
**Current Version:** 0.1.0-research-draft
**Status:** Phase I — Verification Complete (99/99)
