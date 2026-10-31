"""
extractor.py — Extract a Python function into a LibCST representation.

Responsibilities:
  1. Load source code (from string or file).
  2. Extract a single top-level FunctionDef by name.
  3. Preserve the original source unmodified (P₀).
  4. Provide a unified interface for textual re-serialization.

Rule: this module never modifies the original source.
"""

from __future__ import annotations

import hashlib
from dataclasses import dataclass
from pathlib import Path

import libcst as cst


class ExtractionError(Exception):
    """Raised when extraction fails."""


@dataclass(frozen=True)
class ExtractedFunction:
    """Immutable representation of an extracted function."""
    name: str
    source: str              # full original source
    function_source: str     # textual source of the function alone
    module: cst.Module       # full LibCST representation
    function_node: cst.FunctionDef
    source_hash: str         # SHA-256 of the original source


def _find_function(module: cst.Module, name: str) -> cst.FunctionDef:
    """Find a single top-level FunctionDef by name."""
    matches = [
        node for node in module.body
        if isinstance(node, cst.FunctionDef) and node.name.value == name
    ]
    if not matches:
        raise ExtractionError(f"Function '{name}' not found at top-level.")
    if len(matches) > 1:
        raise ExtractionError(f"Multiple functions named '{name}' at top-level.")
    return matches[0]


def extract_from_source(source: str, function_name: str) -> ExtractedFunction:
    """Extract a function from a source string."""
    try:
        module = cst.parse_module(source)
    except cst.ParserSyntaxError as e:
        raise ExtractionError(f"Source is not valid Python: {e}") from e

    func_node = _find_function(module, function_name)
    function_source = module.code_for_node(func_node)

    return ExtractedFunction(
        name=function_name,
        source=source,
        function_source=function_source,
        module=module,
        function_node=func_node,
        source_hash=hashlib.sha256(source.encode("utf-8")).hexdigest(),
    )


def extract_from_file(path: str | Path, function_name: str) -> ExtractedFunction:
    """Extract a function from a file."""
    p = Path(path)
    if not p.exists():
        raise ExtractionError(f"File not found: {p}")
    source = p.read_text(encoding="utf-8")
    return extract_from_source(source, function_name)


def replace_function(
    module: cst.Module,
    name: str,
    new_func: cst.FunctionDef,
) -> cst.Module:
    """Replace a FunctionDef in the module with a new one.

    Returns a new module; the original is not modified (LibCST is immutable).
    """
    body = [
        new_func if (isinstance(n, cst.FunctionDef) and n.name.value == name) else n
        for n in module.body
    ]
    return module.with_changes(body=body)
