"""
behavioral.py — Layer 3: Behavioral Invariants (I_b).

Implements checks B1–B4 as specified in DOCS/invariants_spec.md.

B1: Return values match over the corpus.
B2: Exceptions match over the corpus (type + message).
B3: stdout traces match over the corpus.
B4: No new side effects in P1 (runtime enforcement via isolated_runner).

Design:
  - B1–B3 use differential_test (P0 vs P1).
  - B4 runs P1 alone with enforce_no_side_effects=True; if any input
    triggers _SideEffectBlocked, B4 fails. Ordinary execution failures
    (ValueError, TypeError, etc.) do NOT count as B4 failures.

Scope of B4 (documented):
  - Monkeypatching is not a security sandbox. It blocks a specific
    allowlist of side-effect entry points (see sandbox/isolated_runner.py).
  - Detection of *accidental* side effects introduced by transformations.
  - Out of scope: hostile code isolation.

Rule: this module never modifies P0, P1, or the corpus.
"""

from __future__ import annotations

from dataclasses import dataclass, field

from sandbox.differential import (
    DifferentialResult,
    Input,
    differential_test,
)
from sandbox.isolated_runner import ExecutionResult, run_isolated


# ---------- Data classes ----------

@dataclass(frozen=True)
class BehavioralCheckResult:
    """Result of a single behavioral invariant check."""
    passed: bool
    code: str             # "B1", "B2", "B3", "B4"
    reason: str = ""
    details: dict = field(default_factory=dict)


@dataclass(frozen=True)
class BehavioralVerdict:
    """Composite verdict for the behavioral layer."""
    passed: bool
    results: tuple[BehavioralCheckResult, ...] = field(default_factory=tuple)

    @property
    def failed_codes(self) -> tuple[str, ...]:
        return tuple(r.code for r in self.results if not r.passed)

    @property
    def failure_reason(self) -> str:
        failed = [r for r in self.results if not r.passed]
        if not failed:
            return ""
        return "; ".join(f"{r.code}:{r.reason}" for r in failed)


# ---------- Helpers ----------

_SIDE_EFFECT_MARKERS = (
    "_SideEffectBlocked",
    "blocked by enforce_no_side_effects",
)


def _is_side_effect_block(exc_str: str | None) -> bool:
    """True if the exception string indicates a blocked side effect."""
    if not exc_str:
        return False
    return any(marker in exc_str for marker in _SIDE_EFFECT_MARKERS)


def _filter_mismatches_by_field(
    diff: DifferentialResult, field_name: str
) -> list:
    """Return mismatches for a specific field."""
    return [m for m in diff.mismatches if m.field == field_name]


# ---------- B1: Return values match ----------

def check_b1_return_values(diff: DifferentialResult) -> BehavioralCheckResult:
    """B1: Return values match over the corpus."""
    mismatches = _filter_mismatches_by_field(diff, "return")
    if not mismatches:
        return BehavioralCheckResult(
            passed=True,
            code="B1",
            details={"total_inputs": diff.total_inputs},
        )
    return BehavioralCheckResult(
        passed=False,
        code="B1",
        reason=f"return_mismatch_on_{len(mismatches)}_input(s)",
        details={
            "mismatch_count": len(mismatches),
            "total_inputs": diff.total_inputs,
            "first_mismatch": {
                "input_label": mismatches[0].input.label,
                "p0_value": repr(mismatches[0].p0_value),
                "p1_value": repr(mismatches[0].p1_value),
            },
        },
    )


# ---------- B2: Exceptions match ----------

def check_b2_exceptions(diff: DifferentialResult) -> BehavioralCheckResult:
    """B2: Exceptions match over the corpus."""
    mismatches = _filter_mismatches_by_field(diff, "exception")
    if not mismatches:
        return BehavioralCheckResult(
            passed=True,
            code="B2",
            details={"total_inputs": diff.total_inputs},
        )
    return BehavioralCheckResult(
        passed=False,
        code="B2",
        reason=f"exception_mismatch_on_{len(mismatches)}_input(s)",
        details={
            "mismatch_count": len(mismatches),
            "total_inputs": diff.total_inputs,
            "first_mismatch": {
                "input_label": mismatches[0].input.label,
                "p0_value": mismatches[0].p0_value,
                "p1_value": mismatches[0].p1_value,
            },
        },
    )


# ---------- B3: stdout traces match ----------

def check_b3_stdout(diff: DifferentialResult) -> BehavioralCheckResult:
    """B3: stdout traces match over the corpus."""
    mismatches = _filter_mismatches_by_field(diff, "stdout")
    if not mismatches:
        return BehavioralCheckResult(
            passed=True,
            code="B3",
            details={"total_inputs": diff.total_inputs},
        )
    return BehavioralCheckResult(
        passed=False,
        code="B3",
        reason=f"stdout_mismatch_on_{len(mismatches)}_input(s)",
        details={
            "mismatch_count": len(mismatches),
            "total_inputs": diff.total_inputs,
            "first_mismatch": {
                "input_label": mismatches[0].input.label,
                "p0_value": repr(mismatches[0].p0_value),
                "p1_value": repr(mismatches[0].p1_value),
            },
        },
    )


# ---------- B4: No new side effects ----------

def check_b4_no_new_side_effects(
    p1_source: str,
    function_name: str,
    corpus: list[Input],
    timeout_sec: float = 1.0,
) -> BehavioralCheckResult:
    """
    B4: No new side effects in P1.

    Runs P1 alone on each corpus input with enforce_no_side_effects=True.
    If any execution triggers _SideEffectBlocked, B4 fails.

    Ordinary execution failures (ValueError, TypeError, etc.) are NOT
    counted as B4 failures — they are behavioral mismatches (B2) if they
    differ from P0, or legitimate execution outcomes if they match.

    An AST scan alone is not sufficient; this uses runtime enforcement
    per the DOCS/invariants_spec.md B4 specification.
    """
    if not corpus:
        return BehavioralCheckResult(
            passed=True,
            code="B4",
            reason="empty_corpus",
            details={"total_inputs": 0},
        )

    blocked_inputs: list[dict] = []

    for input_ in corpus:
        result: ExecutionResult = run_isolated(
            source=p1_source,
            function_name=function_name,
            args=input_.args,
            kwargs=input_.kwargs,
            timeout_sec=timeout_sec,
            enforce_no_side_effects=True,
        )

        if _is_side_effect_block(result.exception):
            blocked_inputs.append({
                "input_label": input_.label,
                "exception": result.exception,
            })
        # Note: non-side-effect exceptions (e.g., ValueError) are
        # intentionally NOT counted as B4 failures.

    if not blocked_inputs:
        return BehavioralCheckResult(
            passed=True,
            code="B4",
            details={"total_inputs": len(corpus)},
        )

    return BehavioralCheckResult(
        passed=False,
        code="B4",
        reason=f"side_effect_blocked_on_{len(blocked_inputs)}_input(s)",
        details={
            "blocked_count": len(blocked_inputs),
            "total_inputs": len(corpus),
            "blocked_inputs": blocked_inputs,
        },
    )


# ---------- Composite check ----------

def check_behavioral(
    p0_source: str,
    p1_source: str,
    function_name: str,
    corpus: list[Input],
    timeout_sec: float = 1.0,
) -> BehavioralVerdict:
    """
    Run all behavioral checks B1–B4.

    B1–B3 are computed from a single differential_test run.
    B4 runs P1 separately with side-effect enforcement.
    """
    diff = differential_test(
        p0_source=p0_source,
        p1_source=p1_source,
        function_name=function_name,
        corpus=corpus,
        timeout_sec=timeout_sec,
    )

    results: list[BehavioralCheckResult] = [
        check_b1_return_values(diff),
        check_b2_exceptions(diff),
        check_b3_stdout(diff),
        check_b4_no_new_side_effects(
            p1_source=p1_source,
            function_name=function_name,
            corpus=corpus,
            timeout_sec=timeout_sec,
        ),
    ]

    passed = all(r.passed for r in results)
    return BehavioralVerdict(passed=passed, results=tuple(results))


__all__ = [
    "BehavioralCheckResult",
    "BehavioralVerdict",
    "check_b1_return_values",
    "check_b2_exceptions",
    "check_b3_stdout",
    "check_b4_no_new_side_effects",
    "check_behavioral",
]
