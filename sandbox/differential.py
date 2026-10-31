"""
differential.py — Differential Testing between P0 and P1.

Given two function sources (original and transformed) and a corpus of
inputs, run both through isolated execution and compare their observable
behavior.

Observables (per DOCS/invariants_spec.md, Layer 3):
  - return_value (with NaN/compound-value handling)
  - exception (strict string equality)
  - stdout (strict string equality, no normalization)
  - timed_out (mismatch if either side times out differently)

Rule: this module never modifies P0, P1, or the corpus.
"""

from __future__ import annotations

import math
from dataclasses import dataclass, field
from typing import Any

from sandbox.isolated_runner import ExecutionResult, run_isolated


# ---------- Data classes ----------

@dataclass(frozen=True)
class Input:
    """A single test input."""
    args: tuple = ()
    kwargs: dict = field(default_factory=dict)
    label: str = ""


@dataclass(frozen=True)
class Mismatch:
    """A single input where P0 and P1 differ."""
    input: Input
    field: str              # "return" | "exception" | "stdout" | "timeout" | "error"
    p0_value: Any
    p1_value: Any


@dataclass(frozen=True)
class DifferentialResult:
    """Aggregate result of differential testing."""
    matched: bool
    mismatches: tuple[Mismatch, ...] = ()
    timeouts: tuple[Input, ...] = ()
    total_inputs: int = 0
    total_mismatches: int = 0
    total_timeouts: int = 0


# ---------- Value comparison ----------

def _values_equal(a: Any, b: Any) -> bool:
    """
    Compare two values with NaN and compound-type handling.

    - NaN == NaN (Python default is False).
    - Compound values (list, dict, tuple) are compared via == first,
      then via repr() as a fallback for unorderable types.
    """
    # NaN handling
    if isinstance(a, float) and isinstance(b, float):
        if math.isnan(a) and math.isnan(b):
            return True

    # Fast path
    try:
        if a == b:
            return True
    except Exception:
        pass

    # Slow path: repr fallback
    try:
        return repr(a) == repr(b)
    except Exception:
        return False


# ---------- Single-input comparison ----------

def _compare_single(
    input: Input,
    p0_result: ExecutionResult,
    p1_result: ExecutionResult,
) -> list[Mismatch]:
    """Compare P0 and P1 results for one input."""
    mismatches: list[Mismatch] = []

    # Timeout: mismatch if either side times out differently
    if p0_result.timed_out != p1_result.timed_out:
        mismatches.append(
            Mismatch(
                input=input,
                field="timeout",
                p0_value=p0_result.timed_out,
                p1_value=p1_result.timed_out,
            )
        )
    # If both timed out → consider matched (no further checks)
    if p0_result.timed_out and p1_result.timed_out:
        return mismatches

    # Error (non-execution errors: pickling, process failures)
    if p0_result.error != p1_result.error:
        mismatches.append(
            Mismatch(
                input=input,
                field="error",
                p0_value=p0_result.error,
                p1_value=p1_result.error,
            )
        )

    # Exception (strict string equality)
    if p0_result.exception != p1_result.exception:
        mismatches.append(
            Mismatch(
                input=input,
                field="exception",
                p0_value=p0_result.exception,
                p1_value=p1_result.exception,
            )
        )

    # stdout (strict equality, no normalization)
    if p0_result.stdout != p1_result.stdout:
        mismatches.append(
            Mismatch(
                input=input,
                field="stdout",
                p0_value=p0_result.stdout,
                p1_value=p1_result.stdout,
            )
        )

    # Return value (NaN-aware)
    if not _values_equal(p0_result.return_value, p1_result.return_value):
        mismatches.append(
            Mismatch(
                input=input,
                field="return",
                p0_value=p0_result.return_value,
                p1_value=p1_result.return_value,
            )
        )

    return mismatches


# ---------- Public API ----------

def differential_test(
    p0_source: str,
    p1_source: str,
    function_name: str,
    corpus: list[Input],
    timeout_sec: float = 1.0,
) -> DifferentialResult:
    """
    Run differential testing between P0 and P1 over a corpus.

    Args:
        p0_source: Source code of the original program.
        p1_source: Source code of the candidate (transformed) program.
        function_name: Name of the function to invoke in both.
        corpus: List of Input objects.
        timeout_sec: Timeout per execution (applied to both P0 and P1).

    Returns:
        DifferentialResult with matched, mismatches, timeouts, and counts.

    Notes:
        - Both P0 and P1 are executed through sandbox.isolated_runner,
          ensuring the same isolation model.
        - If P1 times out, the input is recorded in `timeouts` and a
          timeout mismatch is added.
        - If P0 times out but P1 does not (or vice versa), a timeout
          mismatch is added regardless of `timeouts`.
    """
    mismatches: list[Mismatch] = []
    timeouts: list[Input] = []

    for input_ in corpus:
        p0_result = run_isolated(
            source=p0_source,
            function_name=function_name,
            args=input_.args,
            kwargs=input_.kwargs,
            timeout_sec=timeout_sec,
        )
        p1_result = run_isolated(
            source=p1_source,
            function_name=function_name,
            args=input_.args,
            kwargs=input_.kwargs,
            timeout_sec=timeout_sec,
        )

        if p1_result.timed_out:
            timeouts.append(input_)

        mismatches.extend(_compare_single(input_, p0_result, p1_result))

    return DifferentialResult(
        matched=len(mismatches) == 0,
        mismatches=tuple(mismatches),
        timeouts=tuple(timeouts),
        total_inputs=len(corpus),
        total_mismatches=len(mismatches),
        total_timeouts=len(timeouts),
    )


__all__ = [
    "Input",
    "Mismatch",
    "DifferentialResult",
    "differential_test",
]
