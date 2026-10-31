"""
deployer.py — Atomic swap and rollback for runtime function replacement.

Phase I scope (function-level, in-memory):
  - Atomic activation of a candidate source (P1) only if a supplied
    acceptance condition returns True.
  - Rollback to any previous state in history.
  - No file-based deployment.
  - No concurrency handling (single-threaded assumed).
  - No state restoration (stateless functions only in Phase I).

Design principles:
  - The original source (P0) is immutable and always retained.
  - Every successful deployment is recorded in a history stack.
  - A rejected deployment leaves the active source unchanged.
  - Rollback restores the most recent previous active source (or P0).

State Restoration Fidelity (SRF) is deferred to Phase III (stateful).
This module does not measure or claim SRF.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable


# ---------- Data classes ----------

@dataclass(frozen=True)
class DeploymentResult:
    """Result of a deployment or rollback operation."""
    activated: bool
    active_source: str
    rolled_back: bool = False
    reason: str = ""
    previous_source: str = ""


# ---------- Deployer ----------

class Deployer:
    """
    Manage atomic swap between an original source (P0) and candidates.

    Attributes:
        original_source: The initial P0 source. Immutable.
        active_source: The currently active source (P0 or a deployed Pn).
        history: Ordered list of sources, most recent last.
                 history[0] is always original_source.
    """

    def __init__(self, initial_source: str, function_name: str) -> None:
        if not initial_source:
            raise ValueError("initial_source must be non-empty.")
        if not function_name:
            raise ValueError("function_name must be non-empty.")

        self._original_source: str = initial_source
        self._active_source: str = initial_source
        self._function_name: str = function_name
        self._history: list[str] = [initial_source]

    # ---------- Properties ----------

    @property
    def original_source(self) -> str:
        """The immutable P0 source."""
        return self._original_source

    @property
    def active_source(self) -> str:
        """The currently active source."""
        return self._active_source

    @property
    def function_name(self) -> str:
        """The function name managed by this deployer."""
        return self._function_name

    @property
    def history(self) -> tuple[str, ...]:
        """Immutable view of the deployment history."""
        return tuple(self._history)

    @property
    def is_original(self) -> bool:
        """True if the active source equals P0."""
        return self._active_source == self._original_source

    # ---------- Deployment ----------

    def try_deploy(
        self,
        candidate_source: str,
        accept_condition: Callable[[], bool],
    ) -> DeploymentResult:
        """
        Attempt to activate candidate_source.

        The candidate is activated only if accept_condition() returns True.
        Any exception raised by accept_condition is treated as rejection.

        Args:
            candidate_source: The candidate Pn source.
            accept_condition: A zero-argument callable returning bool.
                              Typically wraps check_syntactic ∧ check_structural
                              ∧ check_behavioral.

        Returns:
            DeploymentResult with:
              - activated=True if the swap occurred.
              - reason explains the decision.
        """
        if not candidate_source:
            return DeploymentResult(
                activated=False,
                active_source=self._active_source,
                reason="empty_candidate_source",
            )

        # Evaluate acceptance
        try:
            accepted = bool(accept_condition())
        except Exception as e:
            return DeploymentResult(
                activated=False,
                active_source=self._active_source,
                reason=f"accept_condition_raised:{type(e).__name__}:{e}",
            )

        if not accepted:
            return DeploymentResult(
                activated=False,
                active_source=self._active_source,
                reason="accept_condition_returned_false",
            )

        # Atomic swap
        previous = self._active_source
        self._active_source = candidate_source
        self._history.append(candidate_source)

        return DeploymentResult(
            activated=True,
            active_source=self._active_source,
            reason="accepted",
            previous_source=previous,
        )

    # ---------- Rollback ----------

    def rollback(self) -> DeploymentResult:
        """
        Revert to the most recent previous active source.

        If history has only one entry (P0), no-op.
        """
        if len(self._history) <= 1:
            return DeploymentResult(
                activated=False,
                active_source=self._active_source,
                rolled_back=False,
                reason="no_previous_source_to_rollback_to",
            )

        previous = self._history.pop()      # remove current
        restored = self._history[-1]        # peek previous
        self._active_source = restored

        return DeploymentResult(
            activated=False,                # rollback, not a new deployment
            active_source=self._active_source,
            rolled_back=True,
            reason="rolled_back",
            previous_source=previous,
        )

    # ---------- Reset ----------

    def reset(self) -> DeploymentResult:
        """
        Reset to the original source P0.

        Clears all history except P0.
        """
        previous = self._active_source
        self._active_source = self._original_source
        self._history = [self._original_source]

        return DeploymentResult(
            activated=False,
            active_source=self._active_source,
            rolled_back=(previous != self._original_source),
            reason="reset_to_original",
            previous_source=previous,
        )


__all__ = ["DeploymentResult", "Deployer"]
