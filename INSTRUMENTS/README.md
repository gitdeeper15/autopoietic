# STRATIM — Instruments

This directory contains the specifications for each measurement
instrument used in STRATIM.

## Status

All instruments are at the **specification stage**. None has
been piloted. None has been validated in a calibration sample.

## Instrument inventory

| Variable | Instrument | File |
|----------|-----------|------|
| SIC | Behavioral scenario task | `sic_task/instrument.md` |
| `O^objective` | Structured opportunity audit | `opportunity_audit/instrument.md` |
| `O^perceived` | Self-report matched to audit | (planned) |
| `R` | Rehearsal log | `rehearsal_log/instrument.md` |
| `G` | Recovery (time, calm, behavior) | `recovery/instrument.md` |
| `Execution` | Behavioral record | (planned) |
| Closure detection | Monthly detection | `monthly_detection/instrument.md` |

## What is included

- Construct definition.
- Task or instrument structure.
- Administration protocol.
- Scoring procedure.
- Measurement risks.
- Validity criteria.

## What is not included

- **Actual item content.** SIC task scenarios, opportunity
  audit items, and calibration materials are maintained
  separately to prevent pre-exposure and contamination.
- **Data.** No data exists yet.
- **Validated thresholds.** Thresholds (τ_SIC, τ_O, ε, MID,
  Δ*_AUC) will be set from an independent calibration sample
  (see `DOCS/decision_rules.md`).

## Relationship to the protocol

Each instrument specification corresponds to a section of the
protocol:

- SIC Task → Section 5.3, Section 6.6
- Opportunity Audit → Section 5.1, Section 6.8
- Perceived Opportunity → Section 5.2
- Monthly Detection → Section 6.7
- Rehearsal Log → Section 5.4, Section 6.9
- Recovery → Section 5.5, Section 6.9
- Execution → Section 5.6

If an instrument specification contradicts the protocol, the
protocol takes precedence and the specification must be
updated.

## Next steps

1. Complete the specifications for `O^perceived` and
   `Execution`.
2. Develop scoring rubrics for the SIC Task.
3. Pilot the instruments (requires IRB approval).
4. Validate reliability and equivalence.
5. Set thresholds from an independent calibration sample.

None of these steps has been completed at the current stage.

---

**End of `INSTRUMENTS/README.md`**
