"""Tests for core/extractor.py"""
import pytest
from core.extractor import extract_from_source, ExtractionError

SOURCE = '''
def add(x, y):
    return x + y

def other():
    return 0
'''


def test_extract_add():
    ext = extract_from_source(SOURCE, "add")
    assert ext.name == "add"
    assert "def add" in ext.function_source
    assert ext.source_hash


def test_extract_missing():
    with pytest.raises(ExtractionError):
        extract_from_source(SOURCE, "missing")


def test_extract_invalid_python():
    with pytest.raises(ExtractionError):
        extract_from_source("def broken(: pass", "broken")
