"""
isolated_runner.py — Execute a function in an isolated process.

Responsibilities:
  - Run P₁ (a function source) in a separate process via multiprocessing.
  - Capture return value, exception, stdout, and duration.
  - Enforce a timeout (for FI-4 detection).
  - Never modify the parent process's state.

Isolation model (Phase I):
  - Logical isolation via multiprocessing.Process.
  - NOT a security sandbox (does not defend against adversarial code).
  - Shares memory with parent via fork (read-only discipline assumed).

API:
  run_isolated(source, function_name, args, kwargs, timeout_sec) -> ExecutionResult
"""

from __future__ import annotations

import contextlib
import io
import multiprocessing as mp
import time
from dataclasses import dataclass
from typing import Any


@dataclass
class ExecutionResult:
    """Result of a single isolated execution."""
    return_value: Any = None
    exception: str | None = None          # "TypeName: message" or None
    stdout: str = ""
    timed_out: bool = False
    duration_ms: float = 0.0
    error: str | None = None              # non-execution errors (load, pickling)


# ---------- Side-effect enforcement ----------

class _SideEffectBlocked(PermissionError):
    """Raised when a blocked side-effect function is called."""


def _make_blocker(name: str):
    """Create a stub that raises _SideEffectBlocked with a clear message."""
    def _blocked(*args, **kwargs):
        raise _SideEffectBlocked(
            f"Side effect '{name}' is blocked by enforce_no_side_effects."
        )
    _blocked.__name__ = name
    return _blocked


def _install_side_effect_blockers() -> None:
    """Replace a curated set of side-effect entry points with stubs.

    Called inside the child process before exec. Only affects the child.
    """
    import os
    import socket
    import subprocess
    import urllib.request

    # builtins / io
    import builtins
    import io

    builtins.open = _make_blocker("open")
    io.open = _make_blocker("io.open")

    # os
    for fname in (
        "system", "popen", "remove", "unlink", "rmdir",
        "makedirs", "mkdir", "rename", "replace", "chmod",
    ):
        if hasattr(os, fname):
            setattr(os, fname, _make_blocker(f"os.{fname}"))

    # subprocess
    for fname in ("run", "Popen", "call", "check_output", "check_call"):
        if hasattr(subprocess, fname):
            setattr(subprocess, fname, _make_blocker(f"subprocess.{fname}"))

    # socket
    if hasattr(socket, "socket"):
        socket.socket = _make_blocker("socket.socket")
    if hasattr(socket, "create_connection"):
        socket.create_connection = _make_blocker("socket.create_connection")

    # urllib
    if hasattr(urllib.request, "urlopen"):
        urllib.request.urlopen = _make_blocker("urllib.request.urlopen")


# ---------- Child worker ----------

def _worker(
    source: str,
    function_name: str,
    args: tuple,
    kwargs: dict,
    result_queue: mp.Queue,
    enforce_no_side_effects: bool = False,
) -> None:
    """
    Runs inside the child process.

    Loads `source` as a module-like namespace, calls `function_name(*args, **kwargs)`,
    captures stdout/exception/return value, and pushes to `result_queue`.
    """
    start = time.perf_counter()
    stdout_buf = io.StringIO()

    if enforce_no_side_effects:
        try:
            _install_side_effect_blockers()
        except Exception as e:
            result_queue.put(
                ExecutionResult(
                    error=f"blocker_install_failed: {type(e).__name__}: {e}",
                )
            )
            return

    try:
        with contextlib.redirect_stdout(stdout_buf):
            namespace: dict[str, Any] = {}
            exec(compile(source, "<P1>", "exec"), namespace)

            if function_name not in namespace:
                raise NameError(
                    f"Function '{function_name}' not found after exec."
                )
            func = namespace[function_name]
            result = func(*args, **kwargs)

        duration = (time.perf_counter() - start) * 1000.0
        result_queue.put(
            ExecutionResult(
                return_value=result,
                exception=None,
                stdout=stdout_buf.getvalue(),
                timed_out=False,
                duration_ms=duration,
            )
        )
    except BaseException as e:
        duration = (time.perf_counter() - start) * 1000.0
        exc_str = f"{type(e).__name__}: {e}"
        result_queue.put(
            ExecutionResult(
                return_value=None,
                exception=exc_str,
                stdout=stdout_buf.getvalue(),
                timed_out=False,
                duration_ms=duration,
            )
        )


# ---------- Public API ----------

def run_isolated(
    source: str,
    function_name: str,
    args: tuple = (),
    kwargs: dict | None = None,
    timeout_sec: float = 1.0,
    enforce_no_side_effects: bool = False,
) -> ExecutionResult:
    """
    Execute `function_name` from `source` in an isolated process.

    Side-effect enforcement (when enforce_no_side_effects=True):
        Monkeypatches a small allowlist of side-effect entry points in the
        child process before executing the source:
          - builtins.open, io.open
          - os.system, os.popen, os.remove, os.unlink, os.rmdir,
            os.makedirs, os.mkdir, os.rename, os.replace, os.chmod
          - subprocess.run, subprocess.Popen, subprocess.call,
            subprocess.check_output, subprocess.check_call
          - socket.socket, socket.create_connection
          - urllib.request.urlopen

    IMPORTANT — scope of the guarantee:
        Monkeypatching is NOT a security sandbox. It blocks a specific
        allowlist of side-effect entry points via replacement with stubs
        that raise PermissionError. It does NOT defend against:
          - Adversarial code that reconstructs blocked functions via
            ctypes/cffi or other low-level mechanisms.
          - Direct system calls via OS-specific primitives.
          - Side effects via libraries not on the block list.
        Purpose: detect *accidental* side effects introduced by
        transformations (e.g., a transformation that adds `open(...)` to
        a pure function). Out of scope: hostile code isolation.

    Args:
        source: Python source code containing the function.
        function_name: Name of the function to invoke.
        args: Positional arguments.
        kwargs: Keyword arguments.
        timeout_sec: Maximum execution time in seconds.

    Returns:
        ExecutionResult with return_value, exception, stdout, timed_out,
        and duration_ms. If the child times out, `timed_out=True` and the
        process is forcefully terminated.

    Raises:
        Nothing — all errors are captured in ExecutionResult.
    """
    if kwargs is None:
        kwargs = {}

    queue: mp.Queue = mp.Queue()
    proc = mp.Process(
        target=_worker,
        args=(source, function_name, args, kwargs, queue, enforce_no_side_effects),
        daemon=True,
    )

    start = time.perf_counter()
    proc.start()

    try:
        result = queue.get(timeout=timeout_sec)
        proc.join(timeout=1.0)
        if proc.is_alive():
            proc.terminate()
            proc.join(timeout=1.0)
        return result
    except mp.queues.Empty:
        # Timeout
        proc.terminate()
        proc.join(timeout=1.0)
        duration = (time.perf_counter() - start) * 1000.0
        return ExecutionResult(
            return_value=None,
            exception=None,
            stdout="",
            timed_out=True,
            duration_ms=duration,
        )
    except BaseException as e:
        # Defensive: pickling errors, process errors, etc.
        proc.terminate()
        proc.join(timeout=1.0)
        duration = (time.perf_counter() - start) * 1000.0
        return ExecutionResult(
            return_value=None,
            exception=None,
            stdout="",
            timed_out=False,
            duration_ms=duration,
            error=f"{type(e).__name__}: {e}",
        )


__all__ = ["ExecutionResult", "run_isolated", "_SideEffectBlocked"]
