#!/usr/bin/env python3
"""Setup script for STRATIM.

Note: STRATIM is currently at the protocol stage (v0.1.0-protocol).
Primary statistical modeling is performed in R (Stan / brms).
This Python package provides tooling for instruments and dashboards
to be developed as the study progresses.
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
    name="stratim",
    version="0.1.0.dev0",
    author="Samir Baladi",
    author_email="gitdeeper@gmail.com",
    description=(
        "STRATIM: A Dynamic State-Space Model of Strategic Imagination "
        "Capacity under Chronic Material Pressure"
    ),
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://gitlab.com/gitdeeper15/STRATIM",
    project_urls={
        "Documentation": "https://gitlab.com/gitdeeper15/STRATIM/-/blob/main/README.md",
        "Source": "https://gitlab.com/gitdeeper15/STRATIM",
        "Tracker": "https://gitlab.com/gitdeeper15/STRATIM/-/issues",
        "Paper": "https://gitlab.com/gitdeeper15/STRATIM/-/blob/main/RESEARCH_PAPER/STRATIM_Research_Paper.md",
    },
    packages=find_packages(where="src"),
    package_dir={"": "src"},
    include_package_data=True,
    install_requires=requirements,
    extras_require={
        "dev": [
            "pytest>=7.0.0",
            "pytest-cov>=4.0.0",
            "black>=22.0.0",
            "flake8>=4.0.0",
            "mypy>=0.9.0",
            "pre-commit>=2.0.0",
            "isort>=5.12.0",
        ],
        "instruments": [
            "click>=8.1.0",
            "rich>=13.0.0",
            "tqdm>=4.65.0",
        ],
        "dashboard": [
            "streamlit>=1.20.0",
            "plotly>=5.13.0",
        ],
    },
    python_requires=">=3.10",
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Intended Audience :: Science/Research",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
        "Programming Language :: R",
        "Topic :: Scientific/Engineering",
        "Topic :: Scientific/Engineering :: Information Analysis",
        "Topic :: Scientific/Engineering :: Mathematics",
        "Topic :: Scientific/Engineering :: Psychology",
    ],
    keywords=(
        "strategic imagination, state-space model, chronic scarcity, "
        "opportunity structure, Bayesian hierarchical, longitudinal"
    ),
    # Console scripts are not enabled at protocol stage.
    # entry_points={
    #     "console_scripts": [
    #         "stratim-simulate=stratim.cli:simulate",
    #         "stratim-validate=stratim.cli:validate",
    #     ],
    # },
)
