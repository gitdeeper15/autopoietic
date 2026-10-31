# Experiment Protocol — Pilot Study (4 Weeks)

## 0. Governing Rule

Hypotheses H1–H4 are measured, not assumed. Every numeric threshold is
recorded as a **baseline observation** first, then specified as a limit.

## 1. Environment

- Python 3.11.x
- LibCST 1.x
- Linux (Termux on Android; Ubuntu 22.04 for CI)
- Fixed hardware for all experiments
- No parallel experiment runs

## 2. Workloads

### W1 — Micro (12 functions)

Simple computational functions: add, sub, mul, max, min, abs, clamp,
is_even, sum_list, factorial_iter, power_iter, gcd.
All stateless, no I/O.

### W2 — Realistic (6 functions)

- parse_int (string conversion)
- normalize_text (text modification)
- compute_checksum (computation)
- categorize_number (conditions)
- safe_divide (exceptions)
- format_currency (formatting)

### W3 — Edge (6 functions)

Edge cases: None-returning functions, exception-raising functions,
early-return functions.

**Total:** 24 functions × 4 transformations = 96 transform cases per trial.

## 3. Test Corpus

For each function, a corpus of 20 inputs:

- 10 valid inputs (including boundary values: 0, 1, -1, max_int)
- 5 invalid inputs (wrong type or invalid value)
- 5 random inputs (fixed seed = 42 for reproducibility)

**Mandatory seed:** `random.seed(42)` in every run.

## 4. Failure Injection

### FI-1 — Syntactic Corruption

Inject an orphan node into AST P₁ → must be rejected in I_s.

### FI-2 — Structural Corruption

Remove a variable definition but keep its usage → must be rejected in I_t.

### FI-3 — Silent Semantic Change

Change `+` to `-` in an operation → must be detected in I_b.

### FI-4 — Timeout Injection

Inject an infinite loop into P₁ → must be classified `Inconclusive`.

Each type is injected 10 times per function → 10 × 24 × 4 = 960 injection cases.

## 5. Metrics (recorded per run)

| Metric | Definition | Measurement tool |
|--------|-----------|------------------|
| `accept_rate` | Ratio of accepted P₁ | decision count |
| `reject_rate` | Ratio of rejected P₁ | decision count |
| `false_positive_rate` | Accepted incorrect P₁ (from FI) | ground-truth compare |
| `false_negative_rate` | Rejected correct P₁ (known-equivalent transforms) | ground-truth compare |
| `transform_latency_ms` | Transformation time | time.perf_counter |
| `verification_latency_ms` | I_s + I_t + I_b time | time.perf_counter |
| `total_latency_ms` | Full pipeline time | time.perf_counter |
| `memory_peak_mb` | Peak memory | tracemalloc |
| `rollback_success_rate` | Successful rollback ratio | count |
| `state_restoration_fidelity` | (deferred to later phase) | — |

## 6. Procedure (per workload)

```

for each function in workload:
for each transform in [CF, AS, DBE, LVR]:
for each trial in range(N_TRIALS):
P0 = extract(function)
P1 = transform(P0)
t0 = now()
if not I_s(P1): record(reject, "syntactic"); continue
if not I_t(P1): record(reject, "structural"); continue
sandbox_result = differential_test(P0, P1, corpus)
if sandbox_result.timeout: record(inconclusive); continue
if not I_b(P1, sandbox_result): record(reject, "behavioral"); continue
record(accept)
t1 = now()
for fi in [FI-1, FI-2, FI-3, FI-4]:
inject_and_check()

```

**N_TRIALS = 5** (to measure measurement variance).

## 7. Transition Criterion (to Module-Level)

Transition is approved only if:

| Criterion | Threshold |
|-----------|-----------|
| 1. accept_rate on valid transforms | ≥ 90% |
| 2. detection_rate on FI-1, FI-2, FI-3 | ≥ 95% |
| 3. overhead (total_latency vs baseline) | ≤ 2× |
| 4. rollback_success_rate | 100% in controlled tests |

If any criterion fails → design review, not scope expansion.

## 8. Reproducibility Requirements

- Every run produces JSON: `results/{date}/{workload}_{transform}_{trial}.json`
- Contains: environment hash, source_hash per function, seed, metrics, decision per case
- Script `SIMULATION/reproduce.sh` re-executes any run by its ID

## 9. Weeks Plan

| Week | Task | Deliverable |
|------|------|-------------|
| 1 | extractor + transformer + unit tests | 4 transforms pass on 24 functions |
| 2 | invariants + differential tester | FI detection works |
| 3 | sandbox + deployer + rollback | rollback works in 100% |
| 4 | Run pilot + analysis | numeric baseline + transition decision |

## 10. Out of Scope (Phase I)

- Function signature modifications
- Decorators, closures
- Stateful functions
- Cross-function dependencies
- Absolute semantic equivalence
