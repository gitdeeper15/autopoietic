# STRATIM — Rehearsal Log Instrument

**File:** `INSTRUMENTS/rehearsal_log/instrument.md`
**Version:** 0.1.0-protocol
**Construct:** Rehearsal (R)
**Status:** Specification only. Not yet piloted.

---

## 1. Purpose

The Rehearsal Log records repeated engagement with generating,
reviewing, comparing, or revising alternative courses of
action. It is the primary instrument for the rehearsal
variable `R`.

Rehearsal is a **process**, not a capacity. The SIC Task
measures capacity; the Rehearsal Log measures exposure.

---

## 2. The Capacity–Process Distinction

- **SIC:** capacity to generate, elaborate, compare, revise.
- **R:** repeated engagement with those operations.

A person may have high SIC but rehearse little.
A person may rehearse frequently with low strategic quality.

The two are analytically distinct.

---

## 3. What Is Recorded

Each log entry records one of the following:

| Code | Activity |
|------|----------|
| G | Generated a new alternative pathway |
| Rv | Reviewed a previously generated pathway |
| C | Compared two or more pathways |
| Rs | Revised a prior plan |

Each entry includes:

- Timestamp.
- Brief description (free text).
- Domain (if applicable).

---

## 4. Delivery

- Weekly short check-in (under 3 minutes).
- Log entries can be recorded at any time between check-ins.
- Short probes reduce retrospective bias compared to a single
  end-of-wave summary.

---

## 5. Aggregation

For each inter-wave interval, a rehearsal score is computed:

```

R_{i,t:t+1} = (number of logged entries) / (number of weeks)

```

Optional weighted version: entries weighted by activity type
(pre-specified weights, not data-driven).

---

## 6. Measurement Risks

- **Confounding with SIC.** A person with higher SIC may
  naturally rehearse more. Temporal separation of measurement
  reduces but does not eliminate this.
- **Burden-induced reactivity.** If logging itself prompts
  more rehearsal, the instrument alters the construct.
  Mitigated by keeping the log minimal.
- **Recall bias.** Mitigated by weekly probes.

See `DOCS/measurement_risks.md` Section 3.4.

---

## 7. Causal Direction Ambiguity

Even with temporal separation, the causal direction
`R → SIC` vs. `SIC → R` is not fully identified by the
design. The study can test whether
`R_{i,t:t+1}` predicts `SIC_{i,t+1}` after controlling for
`SIC_{i,t}`, but cannot rule out unobserved common causes.

This is acknowledged in Section 6.14 as a limitation.

---

## 8. What This Instrument Does Not Do

- Does not measure SIC.
- Does not measure cognitive capacity.
- Does not measure motivation to plan.

---

**End of `INSTRUMENTS/rehearsal_log/instrument.md`**
