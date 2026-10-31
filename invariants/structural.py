"""
structural.py — Layer 2: Structural Invariants (I_t).

Implements checks T1–T5 as specified in DOCS/invariants_spec.md.

T1: Every `Name` used has a binding in scope (local/param/global/builtin).
T2: No invalid cycles in the local dependency graph.
T3: No orphan variables (defined and used in P0, but unused in P1).
T4: No new `global` statements.
T5: Every local call refers to an existing name.

Design:
  - Pure functions (no state).
  - Each check returns a CheckResult (pass/fail + reason).
  - A composite function `check_structural(P0, P1)` runs all checks and
    returns a StructuralVerdict.

Rule: this module never modifies P0 or P1.
"""

from __future__ import annotations

import builtins
from dataclasses import dataclass, field

import libcst as cst


# ---------- Data classes ----------

@dataclass(frozen=True)
class CheckResult:
    """Result of a single structural invariant check."""
    passed: bool
    code: str             # e.g., "T1", "T2"
    reason: str = ""      # human-readable explanation


@dataclass(frozen=True)
class StructuralVerdict:
    """Composite verdict for the structural layer."""
    passed: bool
    results: tuple[CheckResult, ...] = field(default_factory=tuple)

    @property
    def failed_codes(self) -> tuple[str, ...]:
        return tuple(r.code for r in self.results if not r.passed)

    @property
    def failure_reason(self) -> str:
        failed = [r for r in self.results if not r.passed]
        if not failed:
            return ""
        return "; ".join(f"{r.code}:{r.reason}" for r in failed)


# ---------- Helpers: name collection ----------

_BUILTIN_NAMES: frozenset[str] = frozenset(dir(builtins))


def _function_params(func: cst.FunctionDef) -> set[str]:
    """Collect all parameter names of a function."""
    names: set[str] = set()
    params = func.params

    for p in params.posonly_params:
        names.add(p.name.value)
    for p in params.params:
        names.add(p.name.value)
    if params.kwonly_params:
        for p in params.kwonly_params:
            names.add(p.name.value)
    if isinstance(params.star_arg, cst.Param):
        names.add(params.star_arg.name.value)
    if isinstance(params.star_kwarg, cst.Param):
        names.add(params.star_kwarg.name.value)

    return names


def _assigned_names(func: cst.FunctionDef) -> set[str]:
    """Collect names assigned by Assign/AnnAssign/AugAssign/For/With."""
    found: set[str] = set()

    class _V(cst.CSTVisitor):
        def visit_Assign(self, node: cst.Assign) -> None:
            for t in node.targets:
                self._collect_target(t.target)

        def visit_AnnAssign(self, node: cst.AnnAssign) -> None:
            self._collect_target(node.target)

        def visit_AugAssign(self, node: cst.AugAssign) -> None:
            self._collect_target(node.target)

        def visit_For(self, node: cst.For) -> None:
            self._collect_target(node.target)

        def visit_With(self, node: cst.With) -> None:
            for item in node.items:
                if item.asname is not None:
                    if isinstance(item.asname.name, cst.Name):
                        found.add(item.asname.name.value)

        def _collect_target(self, target: cst.BaseExpression) -> None:
            if isinstance(target, cst.Name):
                found.add(target.value)
            elif isinstance(target, cst.Tuple):
                for el in target.elements:
                    if el is not None:
                        self._collect_target(el.value)
            elif isinstance(target, cst.List):
                for el in target.elements:
                    if el is not None:
                        self._collect_target(el.value)
            # attributes/subscripts are not local bindings

    func.visit(_V())
    return found


def _global_names(func: cst.FunctionDef) -> set[str]:
    """Collect names declared `global` in the function."""
    found: set[str] = set()

    class _V(cst.CSTVisitor):
        def visit_Global(self, node: cst.Global) -> None:
            for n in node.names:
                found.add(n.name.value)

    func.visit(_V())
    return found


def _used_names(func: cst.FunctionDef) -> set[str]:
    """Collect Name values read (used) in the function.

    Uses a top-level visitor class for stability.
    """
    visitor = _UsedNameVisitor()
    func.body.visit(visitor)
    func_name = func.name.value
    params = _function_params(func)
    return visitor.used - params - {func_name}


class _UsedNameVisitor(cst.CSTVisitor):
    """Top-level visitor. Tracks whether we are inside an assignment target."""

    def __init__(self) -> None:
        self.used: set[str] = set()
        self._in_target: int = 0

    def visit_Assign(self, node: cst.Assign) -> bool:
        for t in node.targets:
            self._in_target += 1
            t.visit(self)
            self._in_target -= 1
        node.value.visit(self)
        return False

    def visit_AnnAssign(self, node: cst.AnnAssign) -> bool:
        self._in_target += 1
        node.target.visit(self)
        self._in_target -= 1
        if node.value is not None:
            node.value.visit(self)
        return False

    def visit_AugAssign(self, node: cst.AugAssign) -> bool:
        node.target.visit(self)
        node.value.visit(self)
        return False

    def visit_For(self, node: cst.For) -> bool:
        node.iter.visit(self)
        self._in_target += 1
        node.target.visit(self)
        self._in_target -= 1
        node.body.visit(self)
        if node.orelse is not None:
            node.orelse.visit(self)
        return False

    def visit_With(self, node: cst.With) -> bool:
        for item in node.items:
            item.item.visit(self)
            if item.asname is not None:
                self._in_target += 1
                item.asname.visit(self)
                self._in_target -= 1
        node.body.visit(self)
        return False

    def visit_Name(self, node: cst.Name) -> None:
        if self._in_target == 0:
            self.used.add(node.value)


def _called_names(func: cst.FunctionDef) -> set[str]:
    """Collect names that appear as the callee of a Call node."""
    callees: set[str] = set()

    class _V(cst.CSTVisitor):
        def visit_Call(self, node: cst.Call) -> None:
            callee = node.func
            if isinstance(callee, cst.Name):
                callees.add(callee.value)

    func.visit(_V())
    return callees


# ---------- T1: Every used Name has a binding ----------

def check_t1_undefined_names(
    p1_func: cst.FunctionDef,
    allowed_globals: frozenset[str] | None = None,
) -> CheckResult:
    """
    T1: Every Name used in P1 has a binding in scope.

    Allowed bindings:
      - function parameters
      - local assignments
      - `global`-declared names (treated as external bindings)
      - builtins
      - names in `allowed_globals` (optional module-level context)
    """
    if allowed_globals is None:
        allowed_globals = frozenset()

    params = _function_params(p1_func)
    assigned = _assigned_names(p1_func)
    globals_declared = _global_names(p1_func)
    used = _used_names(p1_func)

    known = params | assigned | globals_declared | _BUILTIN_NAMES | set(allowed_globals)

    # Filter out attribute access (only Name nodes are collected anyway).
    undefined = {n for n in used if n not in known}

    if not undefined:
        return CheckResult(passed=True, code="T1")
    return CheckResult(
        passed=False,
        code="T1",
        reason=f"undefined_names:{sorted(undefined)}",
    )


# ---------- T2: No invalid cycles in dependency graph ----------

def _build_dependency_graph(func: cst.FunctionDef) -> dict[str, set[str]]:
    """
    Build a local dependency graph: variable -> variables used in its
    defining expression.

    Only considers simple `name = expr` Assign statements where `name`
    is a simple Name, and inspects direct Name usages in `expr`.
    Conservative: may miss some edges, but should never create spurious
    cycles on valid code.
    """
    graph: dict[str, set[str]] = {}

    class _V(cst.CSTVisitor):
        def visit_Assign(self, node: cst.Assign) -> None:
            if len(node.targets) != 1:
                return
            target = node.targets[0].target
            if not isinstance(target, cst.Name):
                return
            lhs = target.value
            deps: set[str] = set()

            class _DepV(cst.CSTVisitor):
                def visit_Name(self, n: cst.Name) -> None:
                    deps.add(n.value)

            node.value.visit(_DepV())

            # Remove self-reference (x = x + 1 is not a cycle)
            deps.discard(lhs)
            graph.setdefault(lhs, set()).update(deps)

    func.visit(_V())
    return graph


def _find_cycle(graph: dict[str, set[str]]) -> list[str] | None:
    """Return a cycle (list of names) if one exists, else None."""
    WHITE, GRAY, BLACK = 0, 1, 2
    color = {n: WHITE for n in graph}
    # Some deps may not be keys (external names) — ignore them
    stack: list[str] = []

    def dfs(node: str) -> list[str] | None:
        color[node] = GRAY
        stack.append(node)
        for dep in graph.get(node, ()):
            if dep not in color:
                continue
            if color[dep] == GRAY:
                # Found cycle
                idx = stack.index(dep)
                return stack[idx:] + [dep]
            if color[dep] == WHITE:
                result = dfs(dep)
                if result is not None:
                    return result
        color[node] = BLACK
        stack.pop()
        return None

    for n in list(graph):
        if color.get(n, WHITE) == WHITE:
            result = dfs(n)
            if result is not None:
                return result
    return None


def check_t2_no_invalid_cycles(p1_func: cst.FunctionDef) -> CheckResult:
    """T2: No invalid cycles in the local dependency graph."""
    graph = _build_dependency_graph(p1_func)
    cycle = _find_cycle(graph)
    if cycle is None:
        return CheckResult(passed=True, code="T2")
    return CheckResult(
        passed=False,
        code="T2",
        reason=f"cycle:{'->'.join(cycle)}",
    )


# ---------- T3: No orphan variables ----------

def _defined_and_used(func: cst.FunctionDef) -> tuple[set[str], set[str]]:
    defined = _assigned_names(func)
    used = _used_names(func)
    return defined, used


def check_t3_no_orphan_variables(
    p0_func: cst.FunctionDef, p1_func: cst.FunctionDef
) -> CheckResult:
    """
    T3: No orphan variables.

    Rule (per DOCS/invariants_spec.md):
      If a variable v was defined AND used in P0, then v must still be
      used in P1. Removing a use while leaving the definition is
      considered an orphan.
    """
    p0_def, p0_used = _defined_and_used(p0_func)
    p1_def, p1_used = _defined_and_used(p1_func)

    was_used = p0_def & p0_used
    still_defined = p1_def
    still_used = p1_used

    orphans = {v for v in was_used if v in still_defined and v not in still_used}

    if not orphans:
        return CheckResult(passed=True, code="T3")
    return CheckResult(
        passed=False,
        code="T3",
        reason=f"orphan_vars:{sorted(orphans)}",
    )


# ---------- T4: No new global statements ----------

def check_t4_no_new_globals(
    p0_func: cst.FunctionDef, p1_func: cst.FunctionDef
) -> CheckResult:
    """T4: No new `global` statements in P1 relative to P0."""
    g0 = _global_names(p0_func)
    g1 = _global_names(p1_func)
    new_globals = g1 - g0
    if not new_globals:
        return CheckResult(passed=True, code="T4")
    return CheckResult(
        passed=False,
        code="T4",
        reason=f"new_globals:{sorted(new_globals)}",
    )


# ---------- T5: Every local call refers to an existing name ----------

def check_t5_local_call_targets(
    p1_func: cst.FunctionDef,
    allowed_globals: frozenset[str] | None = None,
) -> CheckResult:
    """
    T5: Every local call (i.e., a Call whose callee is a bare Name)
    refers to an existing name.

    Existing names: parameters, locals, globals-declared, builtins,
    allowed_globals.

    Note: method calls (obj.method()) and attribute calls are not
    covered by T5 — they are out of scope at the function level.
    """
    if allowed_globals is None:
        allowed_globals = frozenset()

    params = _function_params(p1_func)
    assigned = _assigned_names(p1_func)
    globals_declared = _global_names(p1_func)
    known = params | assigned | globals_declared | _BUILTIN_NAMES | set(allowed_globals)

    callees = _called_names(p1_func)
    unresolved = {c for c in callees if c not in known}

    if not unresolved:
        return CheckResult(passed=True, code="T5")
    return CheckResult(
        passed=False,
        code="T5",
        reason=f"unresolved_call_targets:{sorted(unresolved)}",
    )


# ---------- Composite check ----------

def check_structural(
    p0_func: cst.FunctionDef,
    p1_func: cst.FunctionDef,
    allowed_globals: frozenset[str] | None = None,
) -> StructuralVerdict:
    """Run all structural checks T1–T5."""
    if allowed_globals is None:
        allowed_globals = frozenset()

    results: list[CheckResult] = [
        check_t1_undefined_names(p1_func, allowed_globals),
        check_t2_no_invalid_cycles(p1_func),
        check_t3_no_orphan_variables(p0_func, p1_func),
        check_t4_no_new_globals(p0_func, p1_func),
        check_t5_local_call_targets(p1_func, allowed_globals),
    ]
    passed = all(r.passed for r in results)
    return StructuralVerdict(passed=passed, results=tuple(results))


__all__ = [
    "CheckResult",
    "StructuralVerdict",
    "check_t1_undefined_names",
    "check_t2_no_invalid_cycles",
    "check_t3_no_orphan_variables",
    "check_t4_no_new_globals",
    "check_t5_local_call_targets",
    "check_structural",
]
