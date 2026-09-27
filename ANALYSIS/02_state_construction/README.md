# 02 — State Construction

**Corresponds to:** Section 7.3

## Purpose

Build the state variables (`O^objective`, `O^perceived`, SIC)
and classify individuals into reference regions (1, 2, 3A, 3B, J).

## Constructed variables

- `O^objective_it` — domain-level vector (6 domains).
- `O^perceived_it` — matched vector.
- `SIC_it` — composite only if factor analysis supports it;
  otherwise 4 dimension scores.
- `ΔO_it = O^objective_it - O^perceived_it` — for H2.

## State classification

Thresholds `τ_SIC` and `τ_O` are imported from the calibration
sample (never from the main study).

Priority rule for transition matrices:

1. If `SIC ≤ τ_SIC` → 3A
2. Else if `O^objective ≤ τ_O` → 3B
3. Else if `O^objective > 0` → 1
4. Else → 2

## Planned scripts

| Script | Purpose |
|--------|---------|
| `02a_objective_vector.R` | Build domain-level opportunity vector |
| `02b_perceived_vector.R` | Build matched perceived vector |
| `02c_sic_composite.R` | Factor analysis + composite construction |
| `02d_delta_O.R` | Compute ΔO and |ΔO| |
| `02e_state_classification.R` | Assign 3A/3B/1/2/J per wave |
| `02f_transition_matrix.R` | Compute transition matrices |

## Outputs

- Long-format panel with state variables per wave.
- Transition matrices (individual-level).
- Distribution of states across waves.
- Flag for sparse states (< 20 observations).

---

**End of `ANALYSIS/02_state_construction/README.md`**
