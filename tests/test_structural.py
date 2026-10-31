"""
Tests for invariants/structural.py.

Covers acceptance and rejection for T1–T5, plus composite verdict.

Note: These tests do not touch core/ or invariants/syntactic.py.
"""
import libcst as cst

from invariants.structural import (
    check_t1_undefined_names,
    check_t2_no_invalid_cycles,
    check_t3_no_orphan_variables,
    check_t4_no_new_globals,
    check_t5_local_call_targets,
    check_structural,
)


# ---------- Helpers ----------

def _module(src: str) -> cst.Module:
    return cst.parse_module(src)


def _func(src: str) -> cst.FunctionDef:
    for n in _module(src).body:
        if isinstance(n, cst.FunctionDef):
            return n
    raise AssertionError("No FunctionDef")


# ---------- T1: Undefined names ----------

def test_t1_pass_simple():
    f = _func("def f(x):\n    y = x + 1\n    return y\n")
    r = check_t1_undefined_names(f)
    assert r.passed


def test_t1_pass_builtin():
    f = _func("def f(x):\n    return len(x)\n")
    r = check_t1_undefined_names(f)
    assert r.passed


def test_t1_fail_undefined():
    f = _func("def f(x):\n    return x + z\n")
    r = check_t1_undefined_names(f)
    assert not r.passed
    assert "undefined_names" in r.reason
    assert "z" in r.reason


def test_t1_pass_with_allowed_globals():
    f = _func("def f(x):\n    return helper(x)\n")
    r = check_t1_undefined_names(f, allowed_globals=frozenset({"helper"}))
    assert r.passed


def test_t1_fail_without_allowed_globals():
    f = _func("def f(x):\n    return helper(x)\n")
    r = check_t1_undefined_names(f)
    assert not r.passed


# ---------- T2: Cycles ----------

def test_t2_pass_no_cycle():
    f = _func("def f(x):\n    a = x\n    b = a + 1\n    return b\n")
    r = check_t2_no_invalid_cycles(f)
    assert r.passed


def test_t2_pass_self_reference():
    # x = x + 1 is a self-reference but not a cycle
    f = _func("def f(x):\n    x = x + 1\n    return x\n")
    r = check_t2_no_invalid_cycles(f)
    assert r.passed


def test_t2_fail_cycle():
    f = _func("def f(x):\n    a = b + 1\n    b = a + 1\n    return a\n")
    r = check_t2_no_invalid_cycles(f)
    assert not r.passed
    assert "cycle" in r.reason


# ---------- T3: Orphan variables ----------

def test_t3_pass_no_change():
    p0 = _func("def f(x):\n    y = x + 1\n    return y\n")
    p1 = _func("def f(x):\n    y = x + 1\n    return y\n")
    r = check_t3_no_orphan_variables(p0, p1)
    assert r.passed


def test_t3_pass_rename():
    p0 = _func("def f(x):\n    y = x + 1\n    return y\n")
    p1 = _func("def f(x):\n    z = x + 1\n    return z\n")
    r = check_t3_no_orphan_variables(p0, p1)
    assert r.passed


def test_t3_fail_orphan():
    p0 = _func("def f(x):\n    y = x + 1\n    return y\n")
    p1 = _func("def f(x):\n    y = x + 1\n    return x\n")
    r = check_t3_no_orphan_variables(p0, p1)
    assert not r.passed
    assert "orphan_vars" in r.reason
    assert "y" in r.reason


# ---------- T4: New globals ----------

def test_t4_pass_no_global():
    p0 = _func("def f(x):\n    return x\n")
    p1 = _func("def f(x):\n    return x + 0\n")
    r = check_t4_no_new_globals(p0, p1)
    assert r.passed


def test_t4_pass_same_global():
    p0 = _func("def f(x):\n    global counter\n    counter = 1\n    return counter\n")
    p1 = _func("def f(x):\n    global counter\n    counter = 2\n    return counter\n")
    r = check_t4_no_new_globals(p0, p1)
    assert r.passed


def test_t4_fail_new_global():
    p0 = _func("def f(x):\n    return x\n")
    p1 = _func("def f(x):\n    global state\n    state = x\n    return state\n")
    r = check_t4_no_new_globals(p0, p1)
    assert not r.passed
    assert "new_globals" in r.reason
    assert "state" in r.reason


# ---------- T5: Local call targets ----------

def test_t5_pass_builtin_call():
    f = _func("def f(x):\n    return len(x)\n")
    r = check_t5_local_call_targets(f)
    assert r.passed


def test_t5_pass_local_call():
    f = _func("def f(x):\n    def g(y):\n        return y + 1\n    return g(x)\n")
    r = check_t5_local_call_targets(f)
    # T5 does NOT resolve nested function definitions as bindings
    # (documented in DOCS/invariants_spec.md, T5 scope note).
    assert not r.passed
    assert "g" in r.reason


def test_t5_fail_unresolved():
    f = _func("def f(x):\n    return unknown_func(x)\n")
    r = check_t5_local_call_targets(f)
    assert not r.passed
    assert "unresolved_call_targets" in r.reason
    assert "unknown_func" in r.reason


def test_t5_pass_with_allowed_globals():
    f = _func("def f(x):\n    return helper(x)\n")
    r = check_t5_local_call_targets(f, allowed_globals=frozenset({"helper"}))
    assert r.passed


# ---------- Composite verdict ----------

def test_composite_pass():
    p0 = _func("def f(x):\n    return x * 1\n")
    p1 = _func("def f(x):\n    return x\n")
    v = check_structural(p0, p1)
    assert v.passed
    assert v.failed_codes == ()


def test_composite_fail_undefined():
    p0 = _func("def f(x):\n    return x\n")
    p1 = _func("def f(x):\n    return x + z\n")
    v = check_structural(p0, p1)
    assert not v.passed
    assert "T1" in v.failed_codes


def test_composite_fail_cycle():
    p0 = _func("def f(x):\n    return x\n")
    p1 = _func("def f(x):\n    a = b + 1\n    b = a + 1\n    return a\n")
    v = check_structural(p0, p1)
    assert not v.passed
    assert "T2" in v.failed_codes


def test_composite_fail_orphan():
    p0 = _func("def f(x):\n    y = x + 1\n    return y\n")
    p1 = _func("def f(x):\n    y = x + 1\n    return x\n")
    v = check_structural(p0, p1)
    assert not v.passed
    assert "T3" in v.failed_codes


def test_composite_fail_new_global():
    p0 = _func("def f(x):\n    return x\n")
    p1 = _func("def f(x):\n    global g\n    g = x\n    return g\n")
    v = check_structural(p0, p1)
    assert not v.passed
    assert "T4" in v.failed_codes
