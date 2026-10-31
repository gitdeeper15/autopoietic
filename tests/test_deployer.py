"""
Tests for core/deployer.py.

Covers atomic swap, acceptance conditions, rollback, history,
and the integration with the verification layers.
"""

import pytest

from core.deployer import Deployer


P0 = "def f(x):\n    return x * 1\n"
P1 = "def f(x):\n    return x\n"
P2 = "def f(x):\n    return x + 0\n"


# ---------- Initial state ----------

def test_initial_state():
    d = Deployer(P0, "f")
    assert d.original_source == P0
    assert d.active_source == P0
    assert d.is_original
    assert len(d.history) == 1
    assert d.history[0] == P0


def test_empty_source_raises():
    with pytest.raises(ValueError):
        Deployer("", "f")


def test_empty_function_name_raises():
    with pytest.raises(ValueError):
        Deployer(P0, "")


# ---------- Deployment ----------

def test_deploy_accept():
    d = Deployer(P0, "f")
    result = d.try_deploy(P1, lambda: True)
    assert result.activated
    assert result.reason == "accepted"
    assert result.previous_source == P0
    assert d.active_source == P1
    assert not d.is_original
    assert len(d.history) == 2


def test_deploy_reject():
    d = Deployer(P0, "f")
    result = d.try_deploy(P1, lambda: False)
    assert not result.activated
    assert result.reason == "accept_condition_returned_false"
    assert d.active_source == P0
    assert d.is_original
    assert len(d.history) == 1


def test_deploy_empty_candidate():
    d = Deployer(P0, "f")
    result = d.try_deploy("", lambda: True)
    assert not result.activated
    assert result.reason == "empty_candidate_source"
    assert d.active_source == P0


def test_deploy_condition_raises():
    d = Deployer(P0, "f")

    def bad():
        raise RuntimeError("boom")
    result = d.try_deploy(P1, bad)
    assert not result.activated
    assert "accept_condition_raised" in result.reason
    assert d.active_source == P0


# ---------- Rollback ----------

def test_rollback_after_deploy():
    d = Deployer(P0, "f")
    d.try_deploy(P1, lambda: True)
    assert d.active_source == P1

    result = d.rollback()
    assert result.rolled_back
    assert result.active_source == P0
    assert d.active_source == P0
    assert d.is_original
    assert len(d.history) == 1


def test_rollback_without_deploy():
    d = Deployer(P0, "f")
    result = d.rollback()
    assert not result.rolled_back
    assert result.reason == "no_previous_source_to_rollback_to"
    assert d.active_source == P0


def test_rollback_restores_previous_not_original():
    d = Deployer(P0, "f")
    d.try_deploy(P1, lambda: True)
    d.try_deploy(P2, lambda: True)
    assert d.active_source == P2

    r1 = d.rollback()
    assert r1.rolled_back
    assert d.active_source == P1

    r2 = d.rollback()
    assert r2.rolled_back
    assert d.active_source == P0


# ---------- History ----------

def test_history_tracked():
    d = Deployer(P0, "f")
    d.try_deploy(P1, lambda: True)
    d.try_deploy(P2, lambda: True)
    assert d.history == (P0, P1, P2)


def test_history_immutable():
    d = Deployer(P0, "f")
    d.try_deploy(P1, lambda: True)
    h = d.history
    assert isinstance(h, tuple)
    # Attempting to modify should raise
    with pytest.raises((AttributeError, TypeError)):
        h[0] = "hacked"  # type: ignore


# ---------- Reset ----------

def test_reset_clears_history():
    d = Deployer(P0, "f")
    d.try_deploy(P1, lambda: True)
    d.try_deploy(P2, lambda: True)

    result = d.reset()
    assert result.rolled_back
    assert d.active_source == P0
    assert d.is_original
    assert d.history == (P0,)


def test_reset_when_original():
    d = Deployer(P0, "f")
    result = d.reset()
    assert not result.rolled_back  # no change
    assert d.active_source == P0


# ---------- No partial state on reject ----------

def test_no_partial_state_on_reject():
    d = Deployer(P0, "f")
    original_active = d.active_source
    original_history = d.history

    d.try_deploy(P1, lambda: False)

    assert d.active_source == original_active
    assert d.history == original_history


# ---------- Integration with verification layers ----------

def test_deploy_with_behavioral_verification():
    from invariants.behavioral import check_behavioral
    from sandbox.differential import Input

    corpus = [Input(args=(i,)) for i in range(5)]

    def condition():
        v = check_behavioral(P0, P1, "f", corpus)
        return v.passed

    d = Deployer(P0, "f")
    result = d.try_deploy(P1, condition)
    assert result.activated
    assert d.active_source == P1


def test_deploy_rejected_by_behavioral():
    from invariants.behavioral import check_behavioral
    from sandbox.differential import Input

    bad_candidate = "def f(x):\n    return x + 100\n"
    corpus = [Input(args=(i,)) for i in range(5)]

    def condition():
        v = check_behavioral(P0, bad_candidate, "f", corpus)
        return v.passed

    d = Deployer(P0, "f")
    result = d.try_deploy(bad_candidate, condition)
    assert not result.activated
    assert d.active_source == P0


# ---------- P0 immutability ----------

def test_original_source_immutable():
    d = Deployer(P0, "f")
    d.try_deploy(P1, lambda: True)
    d.try_deploy(P2, lambda: True)
    d.rollback()
    d.rollback()

    # Original must never change
    assert d.original_source == P0


# ---------- State Restoration Fidelity (deferred) ----------

def test_srf_not_implemented():
    """Phase I: state restoration fidelity is not measured."""
    d = Deployer(P0, "f")
    # Sanity: no SRF attribute exists on Deployer
    assert not hasattr(d, "state_restoration_fidelity")
    assert not hasattr(d, "measure_srf")
