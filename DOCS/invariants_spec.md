# Invariants Specification — Function-Level Rewriting (v0.1)

## Scope

This document specifies the acceptance and rejection conditions for any
AST transformation on a single function (Function-Level).

The decisions here are **binding** for both `transformer.py` and `deployer.py`.

## Terminology

- P₀ : original representation (LibCST FunctionDef).
- P₁ : representation after transformation.
- T  : transformation function.
- I_s, I_t, I_b : the three invariant layers.
- O  : observable behaviors = (return values, raised exceptions, stdout trace).

## Layer 1 — Syntactic Invariants (I_s)

Verified via LibCST parser directly after transformation.

| # | Condition | Check |
|---|-----------|-------|
| S1 | P₁ parses as valid Module | `cst.parse_module(src(P₁))` |
| S2 | Contains exactly one FunctionDef | count `FunctionDef` nodes |
| S3 | Function name unchanged | `P₀.name == P₁.name` |
| S4 | Signature unchanged | compare `params` |
| S5 | No new decorators | decorator set |
| S6 | No new imports inside the function | scan `Import`/`ImportFrom` |

**Reject:** any failure in S1–S6 → `Rejected(reason="syntactic:<code>")`.

## Layer 2 — Structural Invariants (I_t)

Verified via local dependency graph analysis (within the function).

| # | Condition | Check |
|---|-----------|-------|
| T1 | Every `Name` used has a binding in scope | scope analysis |
| T2 | No invalid cycles in local dependency graph | DFS cycle detection |
| T3 | No orphan variables (defined but unused if used in P₀) | liveness diff |
| T4 | No new `global` statements | AST scan |
| T5 | Every local call refers to an existing name | symbol table check |

**Reject:** any failure in T1–T5 → `Rejected(reason="structural:<code>")`.

## Layer 3 — Behavioral Invariants (I_b)

Verified via Differential Testing inside an isolated sandbox.

| # | Condition | Check |
|---|-----------|-------|
| B1 | For every input x in corpus: `P₀(x) == P₁(x)` in return value | equality check |
| B2 | Same exception type and message (if any) | exception fingerprint |
| B3 | Same stdout trace (if any) | trace comparison |
| B4 | No new side effects (no file I/O, no network) | sandbox enforcement |

**Reject:** any failure in B1–B4 → `Rejected(reason="behavioral:<code>")`.

**Declared limits:**

- I_b does not prove absolute semantic equivalence — only over the corpus.
- Corpus is defined in `DOCS/experiment_protocol.md`.
- Timeout cases → `Inconclusive` (never `Accepted`).

## Decision Policy

```

Accept(P₁)     ⟺  I_s(P₁) ∧ I_t(P₁) ∧ I_b(P₁)
Reject(P₁)     ⟺  ¬I_s ∨ ¬I_t ∨ ¬I_b
Inconclusive   ⟺  timeout or unresolved in any layer

```

**Golden rule:** `Inconclusive` is never treated as `Accept`. Default to rejection when in doubt.

## Failure Codes

| Code | Layer | Meaning |
|------|-------|---------|
| `syntactic:parse` | I_s | P₁ does not parse |
| `syntactic:signature` | I_s | signature changed |
| `structural:undefined_name` | I_t | undefined name |
| `structural:cycle` | I_t | cycle in dependency graph |
| `behavioral:return_mismatch` | I_b | return value differs |
| `behavioral:exception_mismatch` | I_b | exception differs |
| `behavioral:timeout` | I_b | timeout exceeded |
