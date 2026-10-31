#!/usr/bin/env python3
"""Setup script for Autopoietic Code Rewriting.

Function-level runtime AST rewriting with layered invariants.
Scope: Python 3.11+ / LibCST / multiprocessing.

No PyPI distribution at the research-draft stage.
"""

from setuptools import setup, find_packages

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

with open("requirements.txt", "r", encoding="utf-8") as fh:
    requirements = [
        line.strip()
        for line in fh
        if line.strip() and not line.startswith("#")
    ]

setup(
    name="autopoietic-rewriting",
    version="0.2.0.dev0",
    author="Samir Baladi",
    author_email="gitdeeper@gmail.com",
    description=(
        "Autopoietic Code Rewriting inside Isolated Execution Environments — "
        "Controlled Runtime AST Transformation with Layered Invariants"
    ),
    long_description=long_description,
    long_description_content_type="text/markdown",
    packages=find_packages(exclude=["tests", "tests.*", "docs", "docs.*"]),
    include_package_data=True,
    install_requires=requirements,
    extras_require={
        "dev": [
            "pytest>=8.0.0",
            "pytest-cov>=4.1.0",
            "black>=24.0.0",
            "flake8>=7.0.0",
            "mypy>=1.8.0",
            "isort>=5.13.0",
            "pre-commit>=3.6.0",
        ],
    },
    python_requires=">=3.11",
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Intended Audience :: Science/Research",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.11",
        "Programming Language :: Python :: 3.12",
        "Topic :: Software Development :: Compilers",
        "Topic :: Software Development :: Quality Assurance",
        "Topic :: Scientific/Engineering",
    ],
    keywords=(
        "ast transformation, runtime rewriting, self-modifying code, "
        "libcst, differential testing, software reliability, invariants"
    ),
)
