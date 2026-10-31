"""
syntactic.py — Layer 1: Syntactic Invariants (I_s).

Implements checks S1–S6 as specified in DOCS/invariants_spec.md.

S1: P₁ parses as a valid Module.
S2: P₁ contains exactly one top-level FunctionDef.
S3: Function name unchanged.
S4: Function signature unchanged.
S5: No new decorators.
S6: No new imports inside the function.

Design:
  - Pure functions (no state).
  - Each check returns a CheckResult (pass/fail + reason).
  - A composite function `check_syntactic(P0, P1)` runs all checks and
    returns a SyntacticVerdict.

Rule: this module never modifies P0 or P1.
"""

from __future__ import annotations

from dataclasses import dataclass, field

import libcst as cst


# ---------- Data classes ----------

@dataclass(frozen=True)
class CheckResult:
    """Result of a single invariant check."""
    passed: bool
    code: str             # e.g., "S1", "S2"
    reason: str = ""      # human-readable explanation


@dataclass(frozen=True)
class SyntacticVerdict:
    """Composite verdict for the syntactic layer."""
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


# ---------- S1: Parses as valid Module ----------

def check_s1_parses(module_src: str) -> CheckResult:
    """S1: P₁ parses as a valid Module."""
    try:
        cst.parse_module(module_src)
        return CheckResult(passed=True, code="S1")
    except cst.ParserSyntaxError as e:
        return CheckResult(
            passed=False,
            code="S1",
            reason=f"parse_error:{e}",
        )


# ---------- S2: Exactly one top-level FunctionDef ----------

def check_s2_single_function(module: cst.Module) -> CheckResult:
    """S2: P₁ contains exactly one top-level FunctionDef."""
    funcs = [n for n in module.body if isinstance(n, cst.FunctionDef)]
    if len(funcs) == 1:
        return CheckResult(passed=True, code="S2")
    return CheckResult(
        passed=False,
        code="S2",
        reason=f"expected_1_function,got_{len(funcs)}",
    )


# ---------- S3: Function name unchanged ----------

def check_s3_name_preserved(
    p0_func: cst.FunctionDef, p1_func: cst.FunctionDef
) -> CheckResult:
    """S3: Function name unchanged."""
    if p0_func.name.value == p1_func.name.value:
        return CheckResult(passed=True, code="S3")
    return CheckResult(
        passed=False,
        code="S3",
        reason=f"name_changed:'{p0_func.name.value}'→'{p1_func.name.value}'",
    )


# ---------- S4: Signature unchanged ----------

def _signature_key(func: cst.FunctionDef) -> tuple:
    """
    Build a comparable signature key: (param_names, kinds, defaults_count).
    This is conservative: it does not compare default values themselves,
    only their presence, because syntactic-layer checks are structural.
    """
    params = func.params
    names: list[str] = []
    kinds: list[str] = []
    defaults_count = 0

    # positional-only
    for p in params.posonly_params:
        names.append(p.name.value)
        kinds.append("posonly")
        if p.default is not None:
            defaults_count += 1
    # positional-or-keyword
    for p in params.params:
        names.append(p.name.value)
        kinds.append("poskw")
        if p.default is not None:
            defaults_count += 1
    # keyword-only
    if params.kwonly_params:
        for p in params.kwonly_params:
            names.append(p.name.value)
            kinds.append("kwonly")
            if p.default is not None:
                defaults_count += 1
    # *args / **kwargs
    if (
        params.star_arg is not cst.MaybeSentinel.DEFAULT
        and isinstance(params.star_arg, cst.Param)
    ):
        names.append(params.star_arg.name.value)
        kinds.append("star_arg")
    if isinstance(params.star_kwarg, cst.Param):
        names.append(params.star_kwarg.name.value)
        kinds.append("star_kwarg")

    return tuple(names), tuple(kinds), defaults_count


def check_s4_signature_preserved(
    p0_func: cst.FunctionDef, p1_func: cst.FunctionDef
) -> CheckResult:
    """S4: Function signature unchanged (names, kinds, defaults presence)."""
    try:
        k0 = _signature_key(p0_func)
        k1 = _signature_key(p1_func)
    except Exception as e:  # defensive: unexpected LibCST shape
        return CheckResult(
            passed=False,
            code="S4",
            reason=f"signature_analysis_error:{e}",
        )
    if k0 == k1:
        return CheckResult(passed=True, code="S4")
    return CheckResult(
        passed=False,
        code="S4",
        reason="signature_changed",
    )


# ---------- S5: No new decorators ----------

def check_s5_decorators_preserved(
    p0_func: cst.FunctionDef, p1_func: cst.FunctionDef
) -> CheckResult:
    """S5: No new decorators (set comparison by source text)."""
    def deco_texts(func: cst.FunctionDef) -> set[str]:
        out: set[str] = set()
        for d in func.decorators:
            try:
                out.add(cst.Module(body=[]).code_for_node(d.decorator))
            except Exception:
                out.add("<unparseable>")
        return out

    d0 = deco_texts(p0_func)
    d1 = deco_texts(p1_func)

    if d1 <= d0:
        # no new decorator added (removals are structurally suspicious too,
        # but S5 is specifically about *new* decorators; removal is
        # covered by S4 or later layers if signature impact is relevant)
        return CheckResult(passed=True, code="S5")
    new = d1 - d0
    return CheckResult(
        passed=False,
        code="S5",
        reason=f"new_decorators:{sorted(new)}",
    )


# ---------- S6: No new imports inside the function ----------

def check_s6_no_new_imports(
    p0_func: cst.FunctionDef, p1_func: cst.FunctionDef
) -> CheckResult:
    """
    S6: No new imports inside the function.

    We collect import *targets* (module names / imported names) from both
    functions and require that the set of imports in P1 is a subset of
    those in P0. This allows an import to be removed (not the concern of
    S6), but forbids any new import target to appear.
    """
    def collect_imports(func: cst.FunctionDef) -> set[str]:
        found: set[str] = set()

        class _V(cst.CSTVisitor):
            def visit_Import(self, node: cst.Import) -> None:
                for alias in node.names:
                    found.add(cst.Module(body=[]).code_for_node(alias.name))

            def visit_ImportFrom(self, node: cst.ImportFrom) -> None:
                module_txt = (
                    cst.Module(body=[]).code_for_node(node.module)
                    if node.module is not None else ""
                )
                for alias in node.names:
                    if isinstance(alias, cst.ImportAlias):
                        found.add(
                            f"{module_txt}."
                            + cst.Module(body=[]).code_for_node(alias.name)
                        )
                    elif isinstance(alias, cst.ImportStar):
                        found.add(f"{module_txt}.*")

        func.visit(_V())
        return found

    i0 = collect_imports(p0_func)
    i1 = collect_imports(p1_func)

    if i1 <= i0:
        return CheckResult(passed=True, code="S6")
    new = i1 - i0
    return CheckResult(
        passed=False,
        code="S6",
        reason=f"new_imports:{sorted(new)}",
    )


# ---------- Composite check ----------

def check_syntactic(
    p0_module: cst.Module,
    p1_module: cst.Module,
) -> SyntacticVerdict:
    """
    Run all syntactic checks S1–S6 on (P0, P1).

    P0 and P1 are full modules containing one top-level FunctionDef each.
    The function names are assumed to be equal (verified by S3).
    """
    results: list[CheckResult] = []

    # S1: P1 parses as valid module (already parsed, but we re-verify)
    p1_src = p1_module.code
    results.append(check_s1_parses(p1_src))
    if not results[-1].passed:
        return SyntacticVerdict(passed=False, results=tuple(results))

    # S2: exactly one top-level FunctionDef in P1
    results.append(check_s2_single_function(p1_module))
    if not results[-1].passed:
        return SyntacticVerdict(passed=False, results=tuple(results))

    # Extract the P0 and P1 function nodes for the remaining checks.
    p0_func = _single_function(p0_module)
    p1_func = _single_function(p1_module)
    if p0_func is None or p1_func is None:
        results.append(
            CheckResult(
                passed=False,
                code="S2",
                reason="function_extraction_failed",
            )
        )
        return SyntacticVerdict(passed=False, results=tuple(results))

    # S3: name preserved
    results.append(check_s3_name_preserved(p0_func, p1_func))
    # S4: signature preserved
    results.append(check_s4_signature_preserved(p0_func, p1_func))
    # S5: no new decorators
    results.append(check_s5_decorators_preserved(p0_func, p1_func))
    # S6: no new imports
    results.append(check_s6_no_new_imports(p0_func, p1_func))

    passed = all(r.passed for r in results)
    return SyntacticVerdict(passed=passed, results=tuple(results))


def _single_function(module: cst.Module) -> cst.FunctionDef | None:
    funcs = [n for n in module.body if isinstance(n, cst.FunctionDef)]
    return funcs[0] if len(funcs) == 1 else None


__all__ = [
    "CheckResult",
    "SyntacticVerdict",
    "check_s1_parses",
    "check_s2_single_function",
    "check_s3_name_preserved",
    "check_s4_signature_preserved",
    "check_s5_decorators_preserved",
    "check_s6_no_new_imports",
    "check_syntactic",
]
