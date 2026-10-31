"""
Tests for sandbox/differential.py.

12 cases covering: identical, mismatches (return/exception/stdout/timeout),
empty corpus, multiple mismatches, NaN, compound values, kwargs, timeout
in either side, correct P1.
"""

from sandbox.differential import Input, differential_test


# ---------- 1. Identical ----------

def test_identical_matched():
    src = "def f(x):\n    return x + 1\n"
    result = differential_test(src, src, "f", [Input(args=(1,)), Input(args=(2,))])
    assert result.matched
    assert result.total_mismatches == 0
    assert result.total_inputs == 2


# ---------- 2. Different return ----------

def test_different_return():
    p0 = "def f(x):\n    return x + 1\n"
    p1 = "def f(x):\n    return x + 2\n"
    result = differential_test(p0, p1, "f", [Input(args=(1,))])
    assert not result.matched
    assert result.total_mismatches == 1
    m = result.mismatches[0]
    assert m.field == "return"
    assert m.p0_value == 2
    assert m.p1_value == 3


# ---------- 3. Different exception ----------

def test_different_exception():
    p0 = "def f(x):\n    raise ValueError('a')\n"
    p1 = "def f(x):\n    raise ValueError('b')\n"
    result = differential_test(p0, p1, "f", [Input(args=(1,))])
    assert not result.matched
    assert any(m.field == "exception" for m in result.mismatches)


# ---------- 4. Different stdout ----------

def test_different_stdout():
    p0 = "def f(x):\n    print('a')\n    return x\n"
    p1 = "def f(x):\n    print('b')\n    return x\n"
    result = differential_test(p0, p1, "f", [Input(args=(1,))])
    assert not result.matched
    assert any(m.field == "stdout" for m in result.mismatches)


# ---------- 5. Timeout in P1 only ----------

def test_timeout_in_p1_only():
    p0 = "def f(x):\n    return x\n"
    p1 = "def f(x):\n    while True:\n        pass\n"
    result = differential_test(p0, p1, "f", [Input(args=(1,))], timeout_sec=0.5)
    assert not result.matched
    assert result.total_timeouts == 1
    assert any(m.field == "timeout" for m in result.mismatches)


# ---------- 6. Empty corpus ----------

def test_empty_corpus():
    src = "def f(x):\n    return x\n"
    result = differential_test(src, src, "f", [])
    assert result.matched
    assert result.total_inputs == 0
    assert result.total_mismatches == 0


# ---------- 7. Multiple mismatches ----------

def test_multiple_mismatches():
    p0 = "def f(x):\n    return x\n"
    p1 = "def f(x):\n    return x + 100\n"
    corpus = [Input(args=(1,)), Input(args=(2,)), Input(args=(3,))]
    result = differential_test(p0, p1, "f", corpus)
    assert not result.matched
    assert result.total_mismatches == 3


# ---------- 8. NaN handling ----------

def test_nan_handling():
    p0 = "def f():\n    return float('nan')\n"
    p1 = "def f():\n    return float('nan')\n"
    result = differential_test(p0, p1, "f", [Input()])
    assert result.matched


# ---------- 9. Compound values ----------

def test_compound_values():
    p0 = "def f():\n    return [1, 2, {'a': 3}]\n"
    p1 = "def f():\n    return [1, 2, {'a': 3}]\n"
    result = differential_test(p0, p1, "f", [Input()])
    assert result.matched

    p2 = "def f():\n    return [1, 2, {'a': 4}]\n"
    result2 = differential_test(p0, p2, "f", [Input()])
    assert not result2.matched


# ---------- 10. kwargs passing ----------

def test_kwargs_passing():
    p0 = "def f(a, b=0):\n    return a + b\n"
    p1 = "def f(a, b=0):\n    return a + b\n"
    result = differential_test(
        p0, p1, "f",
        [Input(args=(1,), kwargs={"b": 5})],
    )
    assert result.matched


# ---------- 11. Timeout in P0 only ----------

def test_timeout_in_p0_only():
    p0 = "def f(x):\n    while True:\n        pass\n"
    p1 = "def f(x):\n    return x\n"
    result = differential_test(p0, p1, "f", [Input(args=(1,))], timeout_sec=0.5)
    assert not result.matched
    assert any(m.field == "timeout" for m in result.mismatches)
    # timeouts tuple only counts P1 timeouts
    assert result.total_timeouts == 0


# ---------- 12. P1 correct on all ----------

def test_p1_correct_all():
    p0 = "def f(x):\n    return x * 1\n"
    p1 = "def f(x):\n    return x\n"
    corpus = [Input(args=(i,)) for i in range(5)]
    result = differential_test(p0, p1, "f", corpus)
    assert result.matched
    assert result.total_mismatches == 0
    assert result.total_inputs == 5
