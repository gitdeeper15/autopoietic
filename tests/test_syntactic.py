"""
Tests for invariants/syntactic.py.

Covers acceptance and rejection for each invariant S1–S6, plus the
composite verdict function.

Note: These tests do not touch core/extractor.py or core/transformer.py.
They construct P0/P1 modules directly via cst.parse_module.
"""
import libcst as cst

from invariants.syntactic import (
    check_s1_parses,
    check_s2_single_function,
    check_s3_name_preserved,
    check_s4_signature_preserved,
    check_s5_decorators_preserved,
    check_s6_no_new_imports,
    check_syntactic,
)


# ---------- Helpers ----------

def _module(src: str) -> cst.Module:
    return cst.parse_module(src)


def _func(module: cst.Module) -> cst.FunctionDef:
    for n in module.body:
        if isinstance(n, cst.FunctionDef):
            return n
    raise AssertionError("No FunctionDef in module")


def _func_src(src: str) -> str:
    return _module(src).code


# ---------- S1: Parses as valid Module ----------

def test_s1_pass():
    r = check_s1_parses("def f(x):\n    return x\n")
    assert r.passed
    assert r.code == "S1"


def test_s1_fail():
    r = check_s1_parses("def f(x:\n    return x\n")
    assert not r.passed
    assert r.code == "S1"
    assert "parse_error" in r.reason


# ---------- S2: Exactly one top-level FunctionDef ----------

def test_s2_pass():
    m = _module("def f(x):\n    return x\n")
    r = check_s2_single_function(m)
    assert r.passed


def test_s2_fail_none():
    m = _module("x = 1\n")
    r = check_s2_single_function(m)
    assert not r.passed
    assert "got_0" in r.reason


def test_s2_fail_multiple():
    m = _module("def f():\n    pass\ndef g():\n    pass\n")
    r = check_s2_single_function(m)
    assert not r.passed
    assert "got_2" in r.reason


# ---------- S3: Function name unchanged ----------

def test_s3_pass():
    m0 = _module("def f(x):\n    return x\n")
    m1 = _module("def f(x):\n    return x + 0\n")
    r = check_s3_name_preserved(_func(m0), _func(m1))
    assert r.passed


def test_s3_fail():
    m0 = _module("def f(x):\n    return x\n")
    m1 = _module("def g(x):\n    return x\n")
    r = check_s3_name_preserved(_func(m0), _func(m1))
    assert not r.passed
    assert "name_changed" in r.reason


# ---------- S4: Signature unchanged ----------

def test_s4_pass():
    m0 = _module("def f(x, y=1):\n    return x + y\n")
    m1 = _module("def f(x, y=1):\n    return x + 0 + y\n")
    r = check_s4_signature_preserved(_func(m0), _func(m1))
    assert r.passed


def test_s4_fail_missing_param():
    m0 = _module("def f(x, y):\n    return x + y\n")
    m1 = _module("def f(x):\n    return x\n")
    r = check_s4_signature_preserved(_func(m0), _func(m1))
    assert not r.passed
    assert "signature_changed" in r.reason


def test_s4_fail_default_presence():
    m0 = _module("def f(x, y=0):\n    return x + y\n")
    m1 = _module("def f(x, y):\n    return x + y\n")
    r = check_s4_signature_preserved(_func(m0), _func(m1))
    assert not r.passed


# ---------- S5: No new decorators ----------

def test_s5_pass_none():
    m0 = _module("def f(x):\n    return x\n")
    m1 = _module("def f(x):\n    return x + 0\n")
    r = check_s5_decorators_preserved(_func(m0), _func(m1))
    assert r.passed


def test_s5_pass_same_decorator():
    m0 = _module("@staticmethod\ndef f(x):\n    return x\n")
    m1 = _module("@staticmethod\ndef f(x):\n    return x + 0\n")
    r = check_s5_decorators_preserved(_func(m0), _func(m1))
    assert r.passed


def test_s5_fail_new_decorator():
    m0 = _module("def f(x):\n    return x\n")
    m1 = _module("@staticmethod\ndef f(x):\n    return x\n")
    r = check_s5_decorators_preserved(_func(m0), _func(m1))
    assert not r.passed
    assert "new_decorators" in r.reason


# ---------- S6: No new imports ----------

def test_s6_pass_no_imports():
    m0 = _module("def f(x):\n    return x\n")
    m1 = _module("def f(x):\n    return x + 0\n")
    r = check_s6_no_new_imports(_func(m0), _func(m1))
    assert r.passed


def test_s6_pass_same_import():
    m0 = _module("def f(x):\n    import math\n    return math.sqrt(x)\n")
    m1 = _module("def f(x):\n    import math\n    return math.sqrt(x + 0)\n")
    r = check_s6_no_new_imports(_func(m0), _func(m1))
    assert r.passed


def test_s6_fail_new_import():
    m0 = _module("def f(x):\n    return x\n")
    m1 = _module("def f(x):\n    import math\n    return math.sqrt(x)\n")
    r = check_s6_no_new_imports(_func(m0), _func(m1))
    assert not r.passed
    assert "new_imports" in r.reason


# ---------- Composite verdict ----------

def test_composite_pass():
    p0 = _module("def f(x):\n    return x * 1\n")
    p1 = _module("def f(x):\n    return x\n")
    v = check_syntactic(p0, p1)
    assert v.passed
    assert v.failed_codes == ()


def test_composite_fail_name():
    p0 = _module("def f(x):\n    return x\n")
    p1 = _module("def g(x):\n    return x\n")
    v = check_syntactic(p0, p1)
    assert not v.passed
    assert "S3" in v.failed_codes


def test_composite_fail_signature():
    p0 = _module("def f(x, y):\n    return x + y\n")
    p1 = _module("def f(x):\n    return x\n")
    v = check_syntactic(p0, p1)
    assert not v.passed
    assert "S4" in v.failed_codes


def test_composite_fail_decorator():
    p0 = _module("def f(x):\n    return x\n")
    p1 = _module("@staticmethod\ndef f(x):\n    return x\n")
    v = check_syntactic(p0, p1)
    assert not v.passed
    assert "S5" in v.failed_codes


def test_composite_fail_import():
    p0 = _module("def f(x):\n    return x\n")
    p1 = _module("def f(x):\n    import math\n    return math.sqrt(x)\n")
    v = check_syntactic(p0, p1)
    assert not v.passed
    assert "S6" in v.failed_codes


def test_composite_fail_multiple_functions():
    p0 = _module("def f(x):\n    return x\n")
    p1 = _module("def f(x):\n    return x\ndef g():\n    pass\n")
    v = check_syntactic(p0, p1)
    assert not v.passed
    assert "S2" in v.failed_codes
