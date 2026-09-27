# STRATIM — Opportunity Audit Instrument

**File:** `INSTRUMENTS/opportunity_audit/instrument.md`
**Version:** 0.1.0-protocol
**Construct:** Objective Opportunity Structure (`O^objective`)
**Status:** Specification only. Not yet piloted.

---

## 1. Purpose

The Opportunity Audit produces an independently verifiable
measure of the courses of action materially and
institutionally accessible to an individual within a defined
time window and constraint set.

It is the primary instrument for `O^objective`. It is
**not** a self-report instrument.

---

## 2. Domains

The audit covers six pre-specified domains:

1. **Employment** — job openings, eligibility, application
   feasibility.
2. **Education** — programs, eligibility, cost, timing.
3. **Housing** — availability, eligibility, cost, geographic
   access.
4. **Mobility** — transportation options, cost, geographic
   reach.
5. **Financing** — credit, loans, benefits, transfers.
6. **Care** — health, childcare, eldercare, social services.

Each domain produces a domain-level opportunity vector.

---

## 3. Accessibility Criteria

An opportunity enters the audit **only if** it passes all
applicable criteria:

- **Factual availability**: the opportunity exists.
- **Eligibility**: the individual qualifies.
- **Application feasibility**: the individual can apply.
- **Requirements**: the individual can meet them.
- **Geographic constraints**: reachable within time and cost.
- **Direct cost**: manageable within the individual's resources.
- **Institutional access**: not blocked by administrative
  barriers.
- **Temporal window**: the opportunity is open within the
  study window.

This is the distinction between *nominal* and *actionable*
opportunity.

---

## 4. Data Sources

Where possible, the audit uses external verification:

- Administrative records (employment status, benefit
  eligibility).
- Program rosters (training, education).
- Third-party confirmation (case worker, program staff).
- Structured interview with a trained assessor using a
  fixed protocol.

---

## 5. Reliability Procedure

- A random subsample (target: 15%) is re-audited by a second
  assessor.
- Agreement is reported as percent agreement and Cohen's κ
  per domain.
- Domains below κ = 0.70 are reported as low-reliability and
  analyzed separately.

---

## 6. Output Format

The audit produces a domain-level vector for each individual
at each wave:

```

O^objective_it = (o_emp, o_edu, o_hou, o_mob, o_fin, o_car)

```

A scalar summary (count or weighted index) may be computed
for descriptive purposes, but all classification and
hypothesis testing use the domain-level vector.

---

## 7. What This Instrument Does Not Do

- Does not claim to capture every opportunity that exists.
- Does not measure perceived opportunity.
- Does not measure motivation or intention.

The audit measures what is verifiable under pre-specified
criteria. This is a deliberate scope limitation (Section 9.2).

---

**End of `INSTRUMENTS/opportunity_audit/instrument.md`**
