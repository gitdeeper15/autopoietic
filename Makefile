# STRATIM Makefile
# Version: 0.1.0-protocol
# Date: 2026-09

.PHONY: help structure restore simulate identifiability recovery power fit compare clean test lint

help:
	@echo "STRATIM — available targets"
	@echo ""
	@echo "  structure       Check repository structure"
	@echo "  restore         Restore R environment via renv"
	@echo ""
	@echo "  identifiability Run H5 kernel identifiability check"
	@echo "  recovery        Run parameter recovery simulation"
	@echo "  power           Run Monte Carlo power surface"
	@echo ""
	@echo "  fit             Fit primary Bayesian model (requires data)"
	@echo "  compare         Compare exponential vs power-law kernels"
	@echo ""
	@echo "  test            Run Python tests"
	@echo "  lint            Run linters (Python + R)"
	@echo "  clean           Remove temporary files"

structure:
	@echo "STRATIM structure:"
	@test -f README.md && echo "  README.md" || echo "  MISSING README.md"
	@test -f STRATIM_Research_Paper.md && echo "  STRATIM_Research_Paper.md" || echo "  MISSING paper"
	@test -f VERSION && echo "  VERSION" || echo "  MISSING VERSION"
	@test -d PREREGISTRATION && echo "  PREREGISTRATION/" || echo "  PREREGISTRATION/ (not yet created)"
	@test -d SIMULATION && echo "  SIMULATION/" || echo "  SIMULATION/ (not yet created)"
	@test -d MODEL && echo "  MODEL/" || echo "  MODEL/ (not yet created)"

restore:
	Rscript -e "renv::restore()"

identifiability:
	@if [ -f SIMULATION/code/01_H5_identifiability.R ]; then \
		Rscript SIMULATION/code/01_H5_identifiability.R; \
	else \
		echo "Identifiability script not yet available"; \
	fi

recovery:
	@if [ -f SIMULATION/code/02_parameter_recovery.R ]; then \
		Rscript SIMULATION/code/02_parameter_recovery.R; \
	else \
		echo "Recovery script not yet available"; \
	fi

power:
	@if [ -f SIMULATION/code/03_power_surface.R ]; then \
		Rscript SIMULATION/code/03_power_surface.R; \
	else \
		echo "Power surface script not yet available"; \
	fi

fit:
	@if [ -d DATA/processed ]; then \
		Rscript ANALYSIS/04_dynamic_model/fit.R; \
	else \
		echo "No processed data yet"; \
	fi

compare:
	@if [ -f ANALYSIS/04_dynamic_model/compare_kernels.R ]; then \
		Rscript ANALYSIS/04_dynamic_model/compare_kernels.R; \
	else \
		echo "Kernel comparison script not yet available"; \
	fi

test:
	pytest tests/ -v

lint:
	@echo "Python lint..."
	-flake8 . --max-line-length=88 --extend-ignore=E203,W503
	@echo "R lint..."
	@if command -v Rscript >/dev/null 2>&1; then \
		Rscript -e "if (requireNamespace('lintr', quietly=TRUE)) lintr::lint_dir('SIMULATION/code')" || true; \
	fi

clean:
	rm -rf .pytest_cache/
	rm -rf __pycache__/
	rm -rf **/__pycache__/
	rm -rf *.egg-info/
	rm -rf build/ dist/
	rm -f SIMULATION/results/*.rds
	rm -f SIMULATION/results/*.csv
