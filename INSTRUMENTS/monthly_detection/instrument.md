# STRATIM — Monthly Detection Instrument

**File:** `INSTRUMENTS/monthly_detection/instrument.md`
**Version:** 0.1.0-protocol
**Role:** Event detection for closure exposure
**Status:** Specification only. Not yet piloted.

---

## 1. Purpose

The Monthly Detection Instrument is a short monthly probe that
identifies **potential** changes in the opportunity structure.
Its output is a detection signal, **not** a measurement of
closure exposure.

Only verified changes enter the audited closure series.

---

## 2. Why a Detection Signal, Not a Measurement

Self-reported closure may be contaminated by:

- Perceived opportunity (`O^perceived`).
- SIC itself (an individual with reduced SIC may
  under-report closure).
- Retrospective bias.

Therefore, the monthly report is treated as a signal that
prompts verification, not as the measurement.

---

## 3. Instrument Structure

Each monthly probe asks, for each domain:

- Since the last probe, did a previously available
  opportunity close?
- Did a previously closed domain reopen?
- Did the severity of an existing closure change?

Responses are recorded on a fixed scale.

---

## 4. Delivery

- SMS, app, or brief phone contact.
- Under 3 minutes per probe.
- Weekly or monthly depending on domain.

---

## 5. Verification Procedure

Any reported change that is materially consequential (by
pre-specified criteria) is independently verified:

- Administrative records.
- Program rosters.
- Third-party confirmation.
- Structured assessor verification.

Only verified changes enter `S_closure^audit(τ)`.

---

## 6. Concordance Check

At each main wave, the audited closure series is compared
against the monthly detection signal.

- **Sensitivity:** proportion of audited changes detected
  monthly.
- **Specificity:** proportion of no-change audits with no
  monthly detection.

If sensitivity < 0.60, the monthly series is treated as
event-detection only, and H5 (kernel comparison) is reported
as not testable within the window (see `DOCS/kernel_specification.md`).

---

## 7. What This Instrument Does Not Do

- Does not measure closure severity directly.
- Does not replace the main-wave audit.
- Does not constitute `E_t` on its own.

---

**End of `INSTRUMENTS/monthly_detection/instrument.md`**
