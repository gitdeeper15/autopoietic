"""
Tests for sandbox/isolated_runner.py.

Covers:
  - Successful execution (return value, stdout).
  - Exception capture.
  - Timeout detection (FI-4).
  - Isolation (parent state unchanged).
  - Duration measurement.
"""

from sandbox.isolated_runner import run_isolated


def test_simple_return():
    result = run_isolated(
        source="def f(x):\n    return x * 2\n",
        function_name="f",
        args=(5,),
    )
    assert not result.timed_out
    assert result.error is None
    assert result.exception is None
    assert result.return_value == 10
    assert result.duration_ms > 0


def test_stdout_capture():
    src = (
        "def f(x):\n"
        "    print('hello', x)\n"
        "    return x + 1\n"
    )
    result = run_isolated(src, "f", args=(42,))
    assert result.return_value == 43
    assert "hello 42" in result.stdout


def test_exception_capture():
    src = (
        "def f(x):\n"
        "    raise ValueError('bad input')\n"
    )
    result = run_isolated(src, "f", args=(1,))
    assert result.exception is not None
    assert "ValueError" in result.exception
    assert "bad input" in result.exception
    assert result.return_value is None


def test_timeout():
    src = (
        "def f():\n"
        "    while True:\n"
        "        pass\n"
    )
    result = run_isolated(src, "f", timeout_sec=0.5)
    assert result.timed_out
    assert result.duration_ms >= 400  # should be close to timeout


def test_missing_function():
    src = "def g():\n    return 0\n"
    result = run_isolated(src, "nonexistent")
    assert result.exception is not None
    assert "not found" in result.exception


def test_isolation_parent_state_unchanged():
    # Parent variable should be untouched
    parent_var = 100

    src = (
        "def f():\n"
        "    return 'child ran'\n"
    )
    result = run_isolated(src, "f")
    assert result.return_value == "child ran"
    assert parent_var == 100  # unchanged


def test_kwargs_passing():
    src = "def f(a, b, c=0):\n    return a + b + c\n"
    result = run_isolated(src, "f", args=(1, 2), kwargs={"c": 10})
    assert result.return_value == 13


def test_multiple_executions_independent():
    src = "def f(x):\n    return x * x\n"
    r1 = run_isolated(src, "f", args=(3,))
    r2 = run_isolated(src, "f", args=(5,))
    assert r1.return_value == 9
    assert r2.return_value == 25


def test_invalid_source():
    src = "def f(:\n    return 1\n"
    result = run_isolated(src, "f")
    # Should capture syntax error as exception
    assert result.exception is not None
    assert "SyntaxError" in result.exception


def test_duration_measured():
    src = (
        "def f():\n"
        "    total = 0\n"
        "    for i in range(100000):\n"
        "        total += i\n"
        "    return total\n"
    )
    result = run_isolated(src, "f")
    assert result.duration_ms > 0
    assert result.return_value == sum(range(100000))


# ---------- Side-effect enforcement tests ----------

def test_block_open():
    src = "def f():\n    open('/tmp/test', 'w').write('x')\n    return 'done'\n"
    result = run_isolated(src, "f", enforce_no_side_effects=True)
    assert result.exception is not None
    assert "_SideEffectBlocked" in result.exception
    assert "open" in result.exception


def test_block_os_system():
    src = "def f():\n    import os\n    os.system('echo hi')\n    return 0\n"
    result = run_isolated(src, "f", enforce_no_side_effects=True)
    assert result.exception is not None
    assert "_SideEffectBlocked" in result.exception
    assert "os.system" in result.exception


def test_block_subprocess():
    src = "def f():\n    import subprocess\n    subprocess.run(['ls'])\n    return 0\n"
    result = run_isolated(src, "f", enforce_no_side_effects=True)
    assert result.exception is not None
    assert "_SideEffectBlocked" in result.exception
    assert "subprocess.run" in result.exception


def test_stdout_still_works_when_enforced():
    src = "def f():\n    print('hello')\n    return 42\n"
    result = run_isolated(src, "f", enforce_no_side_effects=True)
    assert result.exception is None
    assert result.return_value == 42
    assert "hello" in result.stdout


def test_no_side_effects_pure_function():
    src = "def f(x):\n    return x + 1\n"
    result = run_isolated(src, "f", args=(5,), enforce_no_side_effects=True)
    assert result.exception is None
    assert result.return_value == 6


def test_enforce_disabled_by_default():
    src = "def f():\n    import os\n    return os.system('echo hi')\n"
    result = run_isolated(src, "f")
    # default: not enforced, so os.system runs (returns 0)
    assert result.exception is None
    assert result.return_value == 0


def test_block_socket():
    src = "def f():\n    import socket\n    s = socket.socket()\n    return 0\n"
    result = run_isolated(src, "f", enforce_no_side_effects=True)
    assert result.exception is not None
    assert "_SideEffectBlocked" in result.exception
    assert "socket" in result.exception
