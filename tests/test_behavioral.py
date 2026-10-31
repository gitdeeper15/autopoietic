"""
Tests for invariants/behavioral.py.

Covers B1–B4 acceptance and rejection, including the B4 distinction
between side-effect blocks and ordinary execution failures.
"""
from invariants.behavioral import (
    check_b1_return_values,
    check_b2_exceptions,
    check_b3_stdout,
    check_b4_no_new_side_effects,
    check_behavioral,
)
from sandbox.differential import Input, differential_test


# ---------- Helpers ----------

def _diff(p0, p1, fname="f", corpus=None, timeout_sec=1.0):
    if corpus is None:
        corpus = [Input()]
    return differential_test(p0, p1, fname, corpus, timeout_sec=timeout_sec)


# ---------- B1: return values ----------

def test_b1_pass():
    src = "def f(x):\n    return x + 1\n"
    diff = _diff(src, src, corpus=[Input(args=(1,))])
    r = check_b1_return_values(diff)
    assert r.passed
    assert r.code == "B1"


def test_b1_fail():
    p0 = "def f(x):\n    return x + 1\n"
    p1 = "def f(x):\n    return x + 2\n"
    diff = _diff(p0, p1, corpus=[Input(args=(1,))])
    r = check_b1_return_values(diff)
    assert not r.passed
    assert "return_mismatch" in r.reason


# ---------- B2: exceptions ----------

def test_b2_pass():
    src = "def f(x):\n    return x\n"
    diff = _diff(src, src)
    r = check_b2_exceptions(diff)
    assert r.passed


def test_b2_fail():
    p0 = "def f(x):\n    raise ValueError('a')\n"
    p1 = "def f(x):\n    raise ValueError('b')\n"
    diff = _diff(p0, p1, corpus=[Input(args=(1,))])
    r = check_b2_exceptions(diff)
    assert not r.passed
    assert "exception_mismatch" in r.reason


# ---------- B3: stdout ----------

def test_b3_pass():
    src = "def f(x):\n    print('hi')\n    return x\n"
    diff = _diff(src, src)
    r = check_b3_stdout(diff)
    assert r.passed


def test_b3_fail():
    p0 = "def f(x):\n    print('a')\n    return x\n"
    p1 = "def f(x):\n    print('b')\n    return x\n"
    diff = _diff(p0, p1, corpus=[Input(args=(1,))])
    r = check_b3_stdout(diff)
    assert not r.passed
    assert "stdout_mismatch" in r.reason


# ---------- B4: side effects ----------

def test_b4_pass_pure_function():
    src = "def f(x):\n    return x + 1\n"
    r = check_b4_no_new_side_effects(src, "f", [Input(args=(1,))])
    assert r.passed
    assert r.code == "B4"


def test_b4_fail_open():
    src = "def f():\n    open('/tmp/x', 'w').write('y')\n    return 0\n"
    r = check_b4_no_new_side_effects(src, "f", [Input()])
    assert not r.passed
    assert "side_effect_blocked" in r.reason
    assert r.details["blocked_count"] == 1
    assert "open" in r.details["blocked_inputs"][0]["exception"]


def test_b4_fail_os_system():
    src = "def f():\n    import os\n    os.system('ls')\n    return 0\n"
    r = check_b4_no_new_side_effects(src, "f", [Input()])
    assert not r.passed
    assert "os.system" in r.details["blocked_inputs"][0]["exception"]


def test_b4_fail_subprocess():
    src = (
        "def f():\n"
        "    import subprocess\n"
        "    subprocess.run(['ls'])\n"
        "    return 0\n"
    )
    r = check_b4_no_new_side_effects(src, "f", [Input()])
    assert not r.passed
    assert "subprocess.run" in r.details["blocked_inputs"][0]["exception"]


def test_b4_fail_socket():
    src = "def f():\n    import socket\n    socket.socket()\n    return 0\n"
    r = check_b4_no_new_side_effects(src, "f", [Input()])
    assert not r.passed
    assert "socket" in r.details["blocked_inputs"][0]["exception"]


def test_b4_pass_on_ordinary_exception():
    """Critical: ValueError is NOT a B4 failure."""
    src = "def f(x):\n    raise ValueError('bad')\n"
    r = check_b4_no_new_side_effects(src, "f", [Input(args=(1,))])
    assert r.passed  # No side effect; just a normal exception


def test_b4_pass_empty_corpus():
    src = "def f(x):\n    return x\n"
    r = check_b4_no_new_side_effects(src, "f", [])
    assert r.passed


def test_b4_fail_on_one_of_many_inputs():
    """Only the input that triggers a side effect should fail B4."""
    src = (
        "def f(x):\n"
        "    if x == 999:\n"
        "        open('/tmp/x', 'w')\n"
        "    return x\n"
    )
    corpus = [Input(args=(1,)), Input(args=(999,)), Input(args=(2,))]
    r = check_b4_no_new_side_effects(src, "f", corpus)
    assert not r.passed
    assert r.details["blocked_count"] == 1


# ---------- Composite verdict ----------

def test_composite_all_pass():
    p0 = "def f(x):\n    return x * 1\n"
    p1 = "def f(x):\n    return x\n"
    corpus = [Input(args=(1,)), Input(args=(2,))]
    v = check_behavioral(p0, p1, "f", corpus)
    assert v.passed
    assert v.failed_codes == ()


def test_composite_b1_fail():
    p0 = "def f(x):\n    return x + 1\n"
    p1 = "def f(x):\n    return x + 2\n"
    v = check_behavioral(p0, p1, "f", [Input(args=(1,))])
    assert not v.passed
    assert "B1" in v.failed_codes


def test_composite_b4_fail_only():
    """B1–B3 pass, B4 fails (P1 has same output but introduces a side effect)."""
    p0 = "def f():\n    return 0\n"
    p1 = "def f():\n    open('/tmp/x', 'w')\n    return 0\n"
    v = check_behavioral(p0, p1, "f", [Input()])
    assert not v.passed
    assert "B4" in v.failed_codes


def test_composite_multiple_fail():
    p0 = "def f(x):\n    return x + 1\n"
    p1 = "def f(x):\n    open('/tmp/x', 'w')\n    return x + 2\n"
    v = check_behavioral(p0, p1, "f", [Input(args=(1,))])
    assert not v.passed
    assert "B1" in v.failed_codes
    assert "B4" in v.failed_codes
