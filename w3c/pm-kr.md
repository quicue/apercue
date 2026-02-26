# Project Management as Constraint Satisfaction in CUE

**Use Case Submission for the PM-KR Community Group**

---

## Summary

[apercue.ca](https://github.com/quicue/apercue) implements project management
patterns — critical path scheduling, gap analysis, milestone evaluation, and
EARL test plans — as CUE type constraints. A project charter declares required
resources, types, and completion gates. The `#GapAnalysis` pattern computes
what is missing. `cue vet` fails if the project is incomplete. Project
management becomes type checking.

This submission demonstrates how CUE's constraint system maps to PM-KR's
work on knowledge representation for project management.

## The Charter Pattern

A project charter declares scope and gates:

```cue
#Charter: {
    scope: {
        total_resources:    int
        required_resources: {[string]: true}
        required_types:     {[string]: true}
    }
    gates: [...#Gate]
}

#Gate: {
    name:     string
    min_depth: int
    required: {[string]: true}
}
```

The `#GapAnalysis` pattern unifies the charter against a `#Graph` and
computes: which resources are missing, which types are unsatisfied, which
gates are blocked, and which gates are complete. The result is a SHACL
validation report — project incompleteness surfaces as constraint violations.

## Evidence: Critical Path (computed)

The `#CriticalPath` pattern computes forward/backward scheduling passes
from dependency weights:

```json
[
    {
        "resource": "ethics-approval",
        "start": 0,
        "finish": 60,
        "duration": 60
    },
    {
        "resource": "sensor-dataset",
        "start": 60,
        "finish": 150,
        "duration": 90
    },
    {
        "resource": "analysis-code",
        "start": 150,
        "finish": 195,
        "duration": 45
    },
    {
        "resource": "draft-paper",
        "start": 195,
        "finish": 225,
        "duration": 30
    },
    {
        "resource": "peer-review",
        "start": 225,
        "finish": 285,
        "duration": 60
    }
]
```

5-node critical path,
285-day total duration,
maximum slack 0 days. This is standard CPM
(Critical Path Method) computed at CUE evaluation time.

The same data produces OWL-Time `time:Interval` entries:

```json
{
    "@type": "time:Interval",
    "@id": "urn:resource:analysis-code",
    "dcterms:title": "analysis-code",
    "time:hasBeginning": {
        "@type": "time:Instant",
        "time:inXSDDecimal": 150
    },
    "time:hasEnd": {
        "@type": "time:Instant",
        "time:inXSDDecimal": 195
    },
    "time:hasDuration": {
        "@type": "time:Duration",
        "time:numericDuration": 45,
        "time:unitType": {
            "@id": "time:unitDay"
        }
    },
    "apercue:slack": 0,
    "apercue:isCritical": true
}
```

Each resource has `time:hasBeginning`, `time:hasEnd`, `time:hasDuration`,
plus `apercue:slack` and `apercue:isCritical` extensions. The scheduling
model IS the semantic model — no translation layer.

## Evidence: Compliance Validation (computed)

The `#ComplianceCheck` pattern evaluates rules against the graph and
produces a SHACL validation report:

```json
{
    "@type": "sh:ValidationReport",
    "sh:conforms": true,
    "sh:result": []
}
```

For project charters, this same mechanism validates gate completion. A gate
that requires `{sensor-dataset: true, ethics-approval: true}` checks
membership in `_graph.resources` via set intersection. Missing resources
produce `sh:conforms: false`.

## How It Maps to PM-KR

| PM Concept | CUE Implementation |
|-----------|-------------------|
| Work Breakdown Structure | `#Graph` with typed resources and `depends_on` edges |
| Critical Path Method | `#CriticalPath` — forward/backward pass on weighted DAG |
| Milestone / Gate | `#Gate` — set membership check on required resources |
| Gap Analysis | `#GapAnalysis` — charter scope vs. actual graph |
| Test Plan | EARL `earl:Assertion` from smoke test definitions |
| Schedule | OWL-Time `time:Interval` per resource |
| Risk (single points of failure) | `#SinglePointsOfFailure` — nodes whose removal disconnects dependents |

The key insight: CUE constraints and project constraints use the same
formalism. "The project needs resource X" is `required_resources: {"X": true}`.
"Resource X exists" is `resources["X"]` being defined. Unification of
requirement with actuality either succeeds (gate passes) or produces bottom
(gate blocked). Project management is type checking.

## Multi-Domain Evidence

| Domain | WBS Nodes | Gates | Critical Path |
|--------|-----------|-------|---------------|
| Research data mgmt | 5 | — | 5-node, 285-day pipeline |
| IT infrastructure | 30 | 8 | 9 layers, 53 resources |
| University curricula | 12 | 5 | 4th-year capstone chain |
| Construction PM (CMHC) | 18 | 5 | Phase-gated retrofit |

## Limitations

- No resource leveling or cost optimization (CPM only, not PERT)
- Deterministic durations (no probabilistic scheduling)
- DAG structure required (no iterative loops)
- Pre-compute transitive closure for graphs exceeding ~40 nodes

## References

- [Core report](https://github.com/quicue/apercue/blob/main/w3c/core-report.md)
  — Full implementation evidence with 14 W3C specs
- [github.com/quicue/apercue](https://github.com/quicue/apercue) — Source (Apache 2.0)
- [demo.quicue.ca](https://demo.quicue.ca) — Interactive D3 graph explorer
