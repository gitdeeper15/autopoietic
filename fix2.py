from pathlib import Path

path = Path("invariants/structural.py")
src = path.read_text()

new_fn = '''def _used_names(func: cst.FunctionDef) -> set[str]:
    """
    Collect Name nodes that are read (used) in the function.

    Uses a stack-based visitor that tracks whether it is currently
    inside an assignment target (so those Names are excluded).
    """
    used: set[str] = set()
    func_name = func.name.value
    params = _function_params(func)

    class _V(cst.CSTVisitor):
        def __init__(self):
            self._in_target: int = 0  # depth counter

        def visit_Assign(self, node: cst.Assign) -> None:
            for t in node.targets:
                self._in_target += 1
                t.visit(self)
                self._in_target -= 1
            node.value.visit(self)
            # return False to skip default traversal
            return False

        def visit_AnnAssign(self, node: cst.AnnAssign) -> None:
            self._in_target += 1
            node.target.visit(self)
            self._in_target -= 1
            if node.value is not None:
                node.value.visit(self)
            return False

        def visit_AugAssign(self, node: cst.AugAssign) -> None:
            # x += 1: x is both read and written
            node.target.visit(self)
            node.value.visit(self)
            return False

        def visit_For(self, node: cst.For) -> None:
            node.iter.visit(self)
            self._in_target += 1
            node.target.visit(self)
            self._in_target -= 1
            node.body.visit(self)
            if node.orelse is not None:
                node.orelse.visit(self)
            return False

        def visit_With(self, node: cst.With) -> None:
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
                used.add(node.value)

    func.body.visit(_V())

    used.discard(func_name)
    used -= params
    return used
'''

old_start = src.find("def _used_names(")
old_end = src.find("def _collect_target_names(")
if old_start == -1 or old_end == -1:
    raise SystemExit("could not locate _used_names block")

# Also remove the _collect_target_names helper (no longer needed)
next_def = src.find("\ndef ", old_end + 1)
if next_def == -1:
    next_def = len(src)

src = src[:old_start] + new_fn + "\n\n" + src[next_def:]
path.write_text(src)
print("✅ _used_names rewritten (stack-based)")
