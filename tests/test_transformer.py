"""Tests for core/transformer.py"""
from core.extractor import extract_from_source
from core.transformer import (
    ConstantFolding,
    AlgebraicSimplification,
    DeadBranchElimination,
    LocalVariableRenaming,
)


def _apply(transform, src, fname="f"):
    ext = extract_from_source(src, fname)
    result = transform.apply(ext.function_node)
    return ext.module.code_for_node(result.new_function)


def test_constant_folding():
    out = _apply(ConstantFolding(), "def f(x):\n    return 2 + 3 + x\n")
    assert "5 + x" in out


def test_algebraic_simplify():
    out = _apply(AlgebraicSimplification(), "def f(x):\n    return x * 1\n")
    assert "return x" in out


def test_dead_branch_true():
    out = _apply(DeadBranchElimination(),
                 "def f(x):\n    if True:\n        return x\n    return 0\n")
    assert "if True" not in out


def test_rename():
    out = _apply(LocalVariableRenaming("y", "z"),
                 "def f(x):\n    y = x + 1\n    return y\n")
    assert "z = x + 1" in out
    assert "return z" in out
