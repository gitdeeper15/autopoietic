# STRATIM — SIC Task Instrument

**File:** `INSTRUMENTS/sic_task/instrument.md`
**Version:** 0.1.0-protocol
**Construct:** Strategic Imagination Capacity (SIC)
**Status:** Specification only. Not yet piloted.

---

## 1. Purpose

The SIC Task is a behavioral scenario task that measures the
capacity to generate, elaborate, compare, and revise
alternative courses of action under material constraint. It
is the primary instrument for the SIC state variable.

The task is **not** a self-report measure of hope, optimism,
motivation, or aspiration. It measures performance on a
structured cognitive-behavioral task.

---

## 2. Task Structure

Each administration of the task produces four dimension
scores:

| Dimension | What is measured | Example prompt |
|-----------|------------------|----------------|
| Generate | Number of distinct alternatives produced | "List possible ways to X." |
| Elaborate | Concrete steps per alternative | "For alternative A, what steps would it require?" |
| Compare | Distinct evaluative dimensions used | "On what dimensions do A and B differ?" |
| Revise | Successful modification after constraint | "Suppose Y becomes impossible. What changes?" |

---

## 3. Parallel Forms

Four parallel forms (A, B, C, D) are used across the four
main waves:

- Structurally equivalent.
- Content-distinct (different scenarios).
- Validated for equivalence in pilot.
- Form assignment rotates across waves to control for
  order effects.

Form content is not included in this repository. It is
maintained separately to prevent pre-exposure and
contamination.

---

## 4. Administration Protocol

1. **Setting.** Individual administration, controlled
   environment, no time pressure for the core task.
2. **Order.** `O^perceived` is measured **before** the SIC
   task in each wave (Section 5.2). Control tasks (verbal
   fluency, working memory) are administered **after** the
   SIC task.
3. **Recording.** Audio-recorded (with consent) for coding
   reliability.
4. **Duration.** Approximately 20–30 minutes per
   administration.

---

## 5. Scoring

### 5.1 Coding procedure

- Two trained coders per administration.
- Coders are blind to wave order and participant identity.
- Inter-rater ICC reported per dimension.
- Disagreements resolved by consensus or third coder.

### 5.2 Dimension scores

Each dimension is scored on a pre-specified scale. The
scales are described in `INSTRUMENTS/sic_task/scoring_rubric.md`
(to be developed in a separate stage).

### 5.3 Composite score

A composite SIC score is created **only if** factor analysis
supports a common latent factor across the four dimensions
(Section 7.2). Otherwise, the four dimensions are retained
separately.

---

## 6. Measurement Risks

- **Verbal fluency overlap.** Addressed with a control task.
- **Working memory overlap.** Addressed with a span task.
- **Practice effects.** Addressed with parallel forms and a
  substudy.
- **Task reactivity.** Addressed by administering
  `O^perceived` first.

See `DOCS/measurement_risks.md` Section 3.3.

---

## 7. Validity Criteria

| Criterion | Adequate | Marginal | Inadequate |
|-----------|----------|----------|------------|
| Internal consistency (ω) | ≥ .70 | .60–.69 | < .60 |
| Inter-rater ICC (per dimension) | ≥ .75 | .60–.74 | < .60 |

If inadequate, the affected dimension is dropped from
primary analysis.

---

## 8. What This Instrument Does Not Do

- Does not measure general intelligence.
- Does not measure clinical status.
- Does not measure motivation.
- Does not measure self-efficacy.

Scores on the SIC Task should not be interpreted as any
of the above.

---

**End of `INSTRUMENTS/sic_task/instrument.md`**
