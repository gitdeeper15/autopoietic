"""
transformer.py — Four controlled transformations (Function-Level).

Each transformation:
  - accepts a FunctionDef and returns (new_function_node, metadata)
  - does NOT verify invariants (that is invariants/'s job)
  - raises TransformationError when the transformation itself fails
    (e.g., no matching pattern found)

Supported transformations:
  1. ConstantFolding
  2. AlgebraicSimplification
  3. DeadBranchElimination
  4. LocalVariableRenaming
"""

from __future__ import annotations

from dataclasses import dataclass, field

import libcst as cst


class TransformationError(Exception):
    """Raised when the transformation itself fails (not P₁ rejection)."""


@dataclass
class TransformationResult:
    """Result of a transformation, before verification."""
    new_function: cst.FunctionDef
    transform_name: str
    metadata: dict = field(default_factory=dict)


def _parse_expr_to_cst(expr_src: str) -> cst.BaseExpression:
    """Convert a text expression to a CST expression."""
    wrapped = cst.parse_module(f"_x = {expr_src}\n")
    assign = wrapped.body[0]
    assert isinstance(assign, cst.SimpleStatementLine)
    assert isinstance(assign.body[0], cst.Assign)
    return assign.body[0].value


def _eval_const_binop(op: str, left: int | float, right: int | float) -> int | float:
    """Constant evaluation of simple arithmetic operations."""
    ops = {
        "+": lambda a, b: a + b,
        "-": lambda a, b: a - b,
        "*": lambda a, b: a * b,
    }
    if op not in ops:
        raise TransformationError(f"Unsupported constant binop: {op}")
    return ops[op](left, right)


# ---------- 1. Constant Folding ----------

class ConstantFolding:
    """
    Replaces constant binary expressions (e.g., 2 + 3) with their value (5).
    Restricted to int/float and +, -, *.
    """

    name = "constant_folding"

    def __init__(self) -> None:
        self.fold_count = 0

    def _fold_expr(self, node: cst.BaseExpression) -> cst.BaseExpression:
        if not isinstance(node, cst.BinaryOperation):
            return node

        left_val = self._as_const(node.left)
        right_val = self._as_const(node.right)

        if left_val is None or right_val is None:
            return node

        op_src = node.operator.__class__.__name__
        op_map = {"Add": "+", "Subtract": "-", "Multiply": "*"}
        if op_src not in op_map:
            return node

        try:
            folded = _eval_const_binop(op_map[op_src], left_val, right_val)
        except TransformationError:
            return node

        self.fold_count += 1
        return _parse_expr_to_cst(repr(folded))

    @staticmethod
    def _as_const(node: cst.BaseExpression) -> int | float | None:
        if isinstance(node, cst.Integer):
            return int(node.value)
        if isinstance(node, cst.Float):
            return float(node.value)
        return None

    def apply(self, func: cst.FunctionDef) -> TransformationResult:
        new_func = func.visit(_ConstFoldVisitor(self))
        if self.fold_count == 0:
            raise TransformationError("No constant expressions to fold.")
        return TransformationResult(
            new_function=new_func,
            transform_name=self.name,
            metadata={"fold_count": self.fold_count},
        )


class _ConstFoldVisitor(cst.CSTTransformer):
    def __init__(self, owner: ConstantFolding) -> None:
        self.owner = owner

    def leave_BinaryOperation(
        self, original_node: cst.BinaryOperation, updated_node: cst.BinaryOperation
    ) -> cst.BaseExpression:
        return self.owner._fold_expr(updated_node)


# ---------- 2. Algebraic Simplification ----------

class AlgebraicSimplification:
    """
    Simplifies controlled algebraic expressions:
      x * 1  → x
      1 * x  → x
      x + 0  → x
      0 + x  → x
      x - 0  → x
    """

    name = "algebraic_simplification"

    def __init__(self) -> None:
        self.simplify_count = 0

    def _try_simplify(self, node: cst.BinaryOperation) -> cst.BaseExpression:
        op_cls = node.operator.__class__.__name__
        left, right = node.left, node.right

        def is_one(n: cst.BaseExpression) -> bool:
            return isinstance(n, cst.Integer) and n.value == "1"

        def is_zero(n: cst.BaseExpression) -> bool:
            return isinstance(n, cst.Integer) and n.value == "0"

        if op_cls == "Multiply":
            if is_one(right):
                self.simplify_count += 1
                return left
            if is_one(left):
                self.simplify_count += 1
                return right

        if op_cls == "Add":
            if is_zero(right):
                self.simplify_count += 1
                return left
            if is_zero(left):
                self.simplify_count += 1
                return right

        if op_cls == "Subtract" and is_zero(right):
            self.simplify_count += 1
            return left

        return node

    def apply(self, func: cst.FunctionDef) -> TransformationResult:
        new_func = func.visit(_AlgebraicVisitor(self))
        if self.simplify_count == 0:
            raise TransformationError("No algebraic simplifications applicable.")
        return TransformationResult(
            new_function=new_func,
            transform_name=self.name,
            metadata={"simplify_count": self.simplify_count},
        )


class _AlgebraicVisitor(cst.CSTTransformer):
    def __init__(self, owner: AlgebraicSimplification) -> None:
        self.owner = owner

    def leave_BinaryOperation(
        self, original_node: cst.BinaryOperation, updated_node: cst.BinaryOperation
    ) -> cst.BaseExpression:
        return self.owner._try_simplify(updated_node)


# ---------- 3. Dead Branch Elimination ----------

class DeadBranchElimination:
    """
    Removes if-branches with known constant conditions (literal True/False).
    """

    name = "dead_branch_elimination"

    def __init__(self) -> None:
        self.eliminated = 0

    def apply(self, func: cst.FunctionDef) -> TransformationResult:
        visitor = _DeadBranchVisitor(self)
        new_func = func.visit(visitor)
        if self.eliminated == 0:
            raise TransformationError("No dead branches to eliminate.")
        return TransformationResult(
            new_function=new_func,
            transform_name=self.name,
            metadata={"eliminated_count": self.eliminated},
        )


def _is_literal_bool(node: cst.BaseExpression) -> bool | None:
    if isinstance(node, cst.Name):
        if node.value == "True":
            return True
        if node.value == "False":
            return False
    return None


class _DeadBranchVisitor(cst.CSTTransformer):
    def __init__(self, owner: DeadBranchElimination) -> None:
        self.owner = owner

    def leave_If(self, original_node: cst.If, updated_node: cst.If):
        cond_val = _is_literal_bool(updated_node.test)
        if cond_val is True:
            self.owner.eliminated += 1
            return cst.FlattenSentinel(updated_node.body.body)
        if cond_val is False:
            self.owner.eliminated += 1
            if updated_node.orelse is not None:
                if isinstance(updated_node.orelse, cst.If):
                    return updated_node.orelse
                return cst.FlattenSentinel(updated_node.orelse.body)
            return cst.RemoveFromParent()
        return updated_node


# ---------- 4. Local Variable Renaming ----------

class LocalVariableRenaming:
    """
    Renames a local variable and updates all its uses in the function.

    Rejects if the new name already exists in scope.
    """

    name = "local_variable_renaming"

    def __init__(self, old_name: str, new_name: str) -> None:
        if old_name == new_name:
            raise TransformationError("old_name and new_name must differ.")
        self.old_name = old_name
        self.new_name = new_name
        self.rename_count = 0

    def apply(self, func: cst.FunctionDef) -> TransformationResult:
        existing = _collect_local_names(func)
        if self.new_name in existing:
            raise TransformationError(
                f"Cannot rename: '{self.new_name}' already exists in scope."
            )
        if self.old_name not in existing:
            raise TransformationError(
                f"Cannot rename: '{self.old_name}' not found in scope."
            )

        visitor = _RenameVisitor(self)
        new_func = func.visit(visitor)

        if self.rename_count == 0:
            raise TransformationError(f"No occurrences of '{self.old_name}' found.")

        return TransformationResult(
            new_function=new_func,
            transform_name=self.name,
            metadata={
                "old_name": self.old_name,
                "new_name": self.new_name,
                "rename_count": self.rename_count,
            },
        )


def _collect_local_names(func: cst.FunctionDef) -> set[str]:
    """Collect parameter names and local variable names (via Assign)."""
    names: set[str] = set()

    for p in func.params.params:
        names.add(p.name.value)

    class _Collector(cst.CSTVisitor):
        def visit_Assign(self, node: cst.Assign) -> None:
            for target in node.targets:
                if isinstance(target.target, cst.Name):
                    names.add(target.target.value)

    func.visit(_Collector())
    return names


class _RenameVisitor(cst.CSTTransformer):
    def __init__(self, owner: LocalVariableRenaming) -> None:
        self.owner = owner

    def leave_Name(
        self, original_node: cst.Name, updated_node: cst.Name
    ) -> cst.Name:
        if updated_node.value == self.owner.old_name:
            self.owner.rename_count += 1
            return updated_node.with_changes(value=self.owner.new_name)
        return updated_node


# ---------- Registry ----------

TRANSFORMATIONS = {
    "constant_folding": ConstantFolding,
    "algebraic_simplification": AlgebraicSimplification,
    "dead_branch_elimination": DeadBranchElimination,
}
