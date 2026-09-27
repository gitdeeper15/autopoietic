# STRATIM — Measurement Risks

**File:** `DOCS/measurement_risks.md`
**Version:** 0.1.0-protocol
**Scope:** Validity threats for each measurement instrument

This document consolidates the measurement risks for every
variable in STRATIM and the mitigation strategies that were
specified in Section 5. It is a reference for the pre-registration
and for the measurement-validation stage (Section 7.2).

---

## 1. Why Measurement Risk Must Be Pre-Specified

A measurement risk that is identified after seeing data can
almost always be framed as harmless. A measurement risk
identified in advance becomes a constraint on interpretation.

STRATIM separates six variables analytically. The primary
methodological risk is **contamination**: one variable being
measured by an instrument that partially captures another
variable. If contamination is not anticipated, the empirical
separation of the variables collapses.

---

## 2. The Six Variables and Their Instruments

| Variable | Instrument type | Primary risk |
|----------|-----------------|--------------|
| `O^objective` | Structured audit + external verification | Nominal vs. actionable conflation |
| `O^perceived` | Self-report | Contamination by SIC |
| `SIC` | Behavioral scenario task | Overlap with verbal fluency / working memory |
| `R` (rehearsal) | Behavioral log + repeated probes | Confounding with SIC |
| `G` (recovery) | Time diary + state measure + behavioral task | Common-method contamination |
| `Execution` | Behavioral records | Opportunity confounding |

---

## 3. Measurement Risks by Variable

### 3.1 `O^objective` — Objective Opportunity

**Definition.** The set of courses of action independently
verifiable as materially and institutionally accessible within
a defined time window and constraint set.

**Primary risk.** Confusing *nominal* opportunity with
*actionable* opportunity. An opportunity exists nominally if it
is offered; it is actionable if the individual can meet the
access criteria.

**Mitigation.**
- Pre-specified accessibility criteria per domain
  (employment, education, housing, mobility, financing, care).
- Independent verification for a random subsample.
- Inter-rater reliability checks.
- The audit measures what is verifiable under pre-specified
  criteria, not what exists in a metaphysical sense.

**Residual risk.** Opportunities that exist but are not
captured by the audit criteria. This is acknowledged in
Section 9.2 as a scope limitation.

---

### 3.2 `O^perceived` — Perceived Opportunity

**Definition.** The set of courses of action the individual
currently represents as available and executable.

**Primary risk.** Contamination by SIC. An individual with
reduced SIC may under-report perceived opportunity not because
opportunity is genuinely misperceived, but because the capacity
to represent alternatives is impaired.

**Mitigation.**
- Instrument designed independently of the objective audit;
  no shared item stems.
- Administer `O^perceived` **before** the SIC task in each wave,
  to avoid carryover from task exposure.
- Estimate the association between `O^perceived`,
  `O^objective`, and SIC using models that preserve their
  hypothesized temporal ordering (Section 5.2), rather than
  partialling out SIC as a nuisance variable.

**Residual risk.** Some contamination is unavoidable. The
magnitude is treated as an empirical question, not assumed
to be zero.

---

### 3.3 `SIC` — Strategic Imagination Capacity

**Definition.** The capacity to generate, elaborate, compare,
and revise representations of future alternative courses of
action under active material constraint.

**Primary risk.** Overlap with general cognitive ability,
specifically verbal fluency and working memory. A participant
who produces many alternatives may be verbally fluent rather
than strategically imaginative.

**Mitigation.**
- Four dimension scores (Generate, Elaborate, Compare, Revise)
  reported separately before any composite.
- Factor-analytic step before combining into a single SIC score.
- Verbal fluency control task and working memory span task as
  covariates.
- If SIC is fully explained by these controls, the construct
  is not empirically distinct and the interpretation narrows
  accordingly.

**Secondary risk.** Practice effects across waves.

**Mitigation.**
- Parallel forms A–D, structurally equivalent but
  content-distinct.
- Pilot test of parallel-form equivalence.
- A substudy estimates the practice effect separately.

**Residual risk.** Construct validity of SIC cannot be
established by a single study. This is acknowledged in
Section 9.2.

---

### 3.4 `R` — Rehearsal

**Definition.** Repeated engagement with generating, reviewing,
comparing, or revising alternative courses of action.

**Primary risk.** Confounding with SIC. A person with high
SIC may rehearse more, so `R` and `SIC` may co-vary for
reasons that are not causal.

**Mitigation.**
- `R` measured continuously between waves; SIC measured at
  waves. Temporal separation reduces but does not eliminate
  reciprocal influence.
- Behavioral logs and time-stamped records preferred over
  retrospective self-report.
- Frequent short probes rather than one retrospective summary.

**Residual risk.** Even with temporal separation, the causal
direction `R → SIC` vs. `SIC → R` is not fully identified.
The design is compatible with cross-lagged modeling; stronger
identification would require external instruments or natural
experiments (Section 6.14).

---

### 3.5 `G` — Recovery

**Definition.** Restoration of cognitive availability through
sufficient unstructured time and internal quiescence.

**Primary risk.** Common-method contamination. If all three
components of G (objective time, subjective quiescence,
behavioral restoration) are self-reported in the same
instrument, associations among them may reflect the instrument
rather than the construct.

**Mitigation.**
- `G` split into components: `G^objective` (time diary),
  `G^subjective` (state measure), `G^behavioral`
  (attention-restoration task).
- At least one non-self-report component required.
- Alternative specifications compared (additive, interaction,
  threshold).

**Residual risk.** Subjective quiescence may be contaminated
by SIC. A person in 3A may report low quiescence not because
G is low but because SIC erosion colors the self-report. The
discrepancy between `G^objective` and `G^subjective` is itself
reported and interpreted.

---

### 3.6 `Execution`

**Definition.** Observable behavioral conversion of an
available and represented alternative into action.

**Primary risk.** Opportunity confounding. Non-execution may
reflect absence of opportunity rather than absence of capacity
or motivation.

**Mitigation.**
- Execution measured independently of `O^objective` and SIC.
- Behavioral records (applications, registrations, contacts,
  training enrollment, defined pathway steps), not intentions.
- The equifinality hypothesis (H3) explicitly tests whether
  non-execution alone can distinguish 3A from 3B.

**Residual risk.** Execution may be influenced by additional
constraints (`X_t`) not captured by O and SIC. These are
acknowledged in Section 9.9 as outside the two-state-variable
formulation.

---

## 4. Cross-Variable Contamination Summary

| Contaminating variable | Affected variable | Direction | Mitigation |
|------------------------|-------------------|-----------|------------|
| SIC | `O^perceived` | Overlap | Temporal ordering |
| Verbal fluency | SIC | Overlap | Control tasks |
| Working memory | SIC | Overlap | Control tasks |
| SIC | `R` | Reciprocal | Temporal separation |
| SIC | `G^subjective` | Overlap | Multi-component G |
| `O^objective` | Execution | Confounding | Independent measurement |

---

## 5. Measurement Validation Criteria

These are pre-specified in Section 7.2. Each criterion uses
graduated adequacy rules rather than binary pass/fail.

| Criterion | Adequate | Marginal | Inadequate |
|-----------|----------|----------|------------|
| SIC internal consistency (ω) | ≥ .70 | .60–.69 | < .60 |
| SIC inter-rater ICC (per dimension) | ≥ .75 | .60–.74 | < .60 |
| `O^objective` audit κ (per domain) | ≥ .70 | .50–.69 | < .50 |
| Monthly detection sensitivity | ≥ .70 | .60–.69 | < .60 |

**Responses:**

- **Adequate:** variable used as specified in primary analysis.
- **Marginal:** variable analyzed with an explicit caveat;
  composite not used if its components fail; dimensions or
  domains analyzed separately.
- **Inadequate:** variable not used for hypothesis testing. The
  hypothesis that depends on it is reported as **not testable
  under the observed measurement conditions**, and the
  measurement failure is reported as a finding.

---

## 6. Temporal Ordering Rules

To reduce contamination:

1. **At each wave:** `O^perceived` → SIC task → control tasks.
   This order ensures that the SIC task does not prime
   `O^perceived` responses.
2. **Objective audit:** conducted separately from the self-report
   instruments, at the same wave but not in the same session.
3. **Rehearsal and recovery:** measured continuously between
   waves, not retrospectively at the next wave.
4. **Execution:** recorded continuously where possible.

---

## 7. What Measurement Risks Do Not Do

These risks do **not**:

- Invalidate the study.
- Assume that the variables are unmeasurable.
- Replace the need for substantive interpretation.

They specify, in advance, what aspects of the measurement
framework are uncertain and how the study addresses them.

---

**End of `DOCS/measurement_risks.md`**
