from pathlib import Path

path = Path("invariants/structural.py")
src = path.read_text()

new_fn = '''def _used_names(func: cst.FunctionDef) -> set[str]:
    """
    Collect Name nodes that are read (used) in the function.

    Excluded:
      - The function's own name.
      - Parameter names (definitions).
      - Assignment target names on the LHS of `=` and `AnnAssign`.
      - For-loop iteration variable names.
      - With-statement `as` names.

    Included:
      - RHS of assignments (AnnAssign value, Assign value).
      - Augmented assignment target (x += 1 reads x).
      - Return expressions, call arguments, conditions, etc.
    """
    used: set[str] = set()
    func_name = func.name.value
    params = _function_params(func)
    skip: set[int] = set()  # use id() to avoid hashability issues

    class _TargetCollector(cst.CSTVisitor):
        def visit_Assign(self, node: cst.Assign) -> None:
            for t in node.targets:
                _collect_target_names(t.target, skip)

        def visit_AnnAssign(self, node: cst.AnnAssign) -> None:
            _collect_target_names(node.target, skip)

        def visit_For(self, node: cst.For) -> None:
            _collect_target_names(node.target, skip)

        def visit_With(self, node: cst.With) -> None:
            for item in node.items:
                if item.asname is not None:
                    _collect_target_names(item.asname.name, skip)

    func.visit(_TargetCollector())

    class _V(cst.CSTVisitor):
        def visit_Name(self, node: cst.Name) -> None:
            if id(node) in skip:
                return
            used.add(node.value)

    func.body.visit(_V())

    used.discard(func_name)
    used -= params
    return used


def _collect_target_names(node, out: set[int]) -> None:
    """Recursively collect id() of Name nodes that appear as targets."""
    if node is None:
        return
    if isinstance(node, cst.Name):
        out.add(id(node))
    elif isinstance(node, cst.Tuple):
        for el in node.elements:
            if el is not None:
                _collect_target_names(el.value, out)
    elif isinstance(node, cst.List):
        for el in node.elements:
            if el is not None:
                _collect_target_names(el.value, out)
'''

old_start = src.find("def _used_names(")
old_end = src.find("def _called_names(")
if old_start == -1 or old_end == -1:
    raise SystemExit("could not locate _used_names block")

src = src[:old_start] + new_fn + "\n\n" + src[old_end:]
path.write_text(src)
print("✅ _used_names rewritten")
