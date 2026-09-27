# STRATIM — Recovery Instrument

**File:** `INSTRUMENTS/recovery/instrument.md`
**Version:** 0.1.0-protocol
**Construct:** Recovery / Cognitive Availability (G)
**Status:** Specification only. Not yet piloted.

---

## 1. Purpose

The Recovery Instrument measures conditions that restore
cognitive availability: unstructured time and internal
quiescence. It is the primary instrument for the recovery
variable `G`.

Recovery is **not** a psychological trait. It is a set of
conditions whose effect on SIC may be conditional (H1b).

---

## 2. Three Components

`G` is deliberately split into three components to reduce
common-method contamination:

| Component | Instrument | What it captures |
|-----------|------------|------------------|
| `G^objective` | Time diary | Unstructured time available |
| `G^subjective` | State measure | Internal quiescence |
| `G^behavioral` | Attention-restoration task | Capacity for rest |

**At least one non-self-report component is required.**
The time diary provides this.

---

## 3. Measurement Schedule

| Component | Frequency |
|-----------|-----------|
| Time diary | Monthly |
| State measure | Monthly |
| Behavioral task | At main waves only |

---

## 4. Alternative Specifications

The relationship between T (unstructured time) and C (internal
quiescence) is not assumed in advance. Three specifications
are compared (H1b):

**Additive:**
```

G = a·T + b·C

```

**Interaction:**
```

G = a·T + b·C + c·(T × C)

```

**Threshold:**
```

G = g(T, C) · 1(T > τ_T, C > τ_C)

```

The comparison is the empirical test of H1b.

**Important:** the threshold applies to the **effect** of
recovery on SIC, not to the definition of recovery itself.

---

## 5. Measurement Risks

- **Subjective contamination by SIC.** A person in 3A may
  report low internal quiescence because SIC erosion colors
  the self-report, not because G is objectively low.
  Mitigation: compare `G^objective` and `G^subjective`
  and report discrepancies.
- **Common-method bias.** Mitigation: multi-component
  measurement.
- **Burden.** Time diaries can be burdensome. Mitigation:
  short daily entries rather than retrospective summaries.

See `DOCS/measurement_risks.md` Section 3.5.

---

## 6. Aggregation

For each inter-wave interval:

```

G^objective_{i,t:t+1} = mean daily unstructured hours
G^subjective_{i,t:t+1} = mean state measure score
G^behavioral_{i,t:t+1} = post-rest attention task score

```

The three components are reported separately before any
combination.

---

## 7. What This Instrument Does Not Do

- Does not measure sleep quality (separate construct).
- Does not measure stress (separate construct).
- Does not measure psychological resilience.

---

**End of `INSTRUMENTS/recovery/instrument.md`**
