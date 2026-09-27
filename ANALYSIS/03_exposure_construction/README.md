# 03 — Exposure Construction

**Corresponds to:** Section 7.4

## Purpose

Construct `E_it` (accumulated closure exposure) from the
audited closure series, for both kernel forms.

## Inputs

- `S_closure^audit(τ)` — verified monthly closure series.
- Wave schedule: `t_0, t_6, t_12, t_18`.

## Outputs

- `E_exp_it` — exponential kernel
  `∫ exp(−λ(t−τ)) S_closure(τ) dτ`
- `E_pow_it` — power-law kernel
  `∫ (1 + t − τ)^(−ρ) S_closure(τ) dτ`
- `E_flex_it` — flexible kernel (only if simulation permits).

## Temporal boundary

`E_it` uses only closure events up to and including time `t`:

```

E_it^{≤ t} = ∫_0^t K(t − τ) S_closure^audit(τ) dτ

```

No closure events after `t` enter `E_it`. This prevents
temporal leakage.

## Standardization

`E_it` is standardized within each wave before entering the
dynamic model.

## Planned scripts

| Script | Purpose |
|--------|---------|
| `03a_audited_series.R` | Build verified monthly closure series |
| `03b_kernel_exp.R` | Compute E_exp_it |
| `03c_kernel_pow.R` | Compute E_pow_it |
| `03d_kernel_flex.R` | Flexible kernel (if applicable) |
| `03e_standardize.R` | Within-wave standardization |
| `03f_leakage_check.R` | Confirm no post-t leakage |

## Flags

Observations with missing monthly data > 20% within an
interval are flagged **low-confidence** and analyzed
separately in sensitivity analysis.

---

**End of `ANALYSIS/03_exposure_construction/README.md`**
