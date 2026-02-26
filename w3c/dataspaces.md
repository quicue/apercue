# Typed Knowledge Bases as Lightweight Dataspace Primitives

**Use Case Submission for the Dataspaces Community Group**

---

## Summary

[apercue.ca](https://github.com/quicue/apercue) implements a `.kb/`
(Knowledge Base) convention where structured entries — decisions, insights,
patterns, tasks — validate against typed CUE schemas at evaluation time.
ODRL access policies and DCAT catalog metadata are projections of the same
typed graph. The result is a lightweight dataspace primitive: governed data
sharing with compile-time structural validation.

This submission demonstrates how CUE's constraint system maps to the
Dataspaces CG's work on data governance and interoperability.

## The .kb/ Convention

Each repository maintains a `.kb/` directory with typed graph subdirectories:

```
.kb/
├── decisions/    # ADR-001, ADR-002, ...
├── insights/     # INSIGHT-001, INSIGHT-002, ...
├── patterns/     # P-001, P-002, ...
├── rejected/     # REJ-001, REJ-002, ...
├── tasks/        # Typed work items with dependencies
└── manifest.cue  # Graph topology declaration
```

Each subdirectory is a CUE package that validates against a typed schema
(`#Decision`, `#Insight`, `#Pattern`, `#Task`). The manifest declares
which graphs exist and their semantic types:

```cue
graphs: {
    decisions: ext.#DecisionsGraph   // schema:ChooseAction
    insights:  ext.#InsightsGraph    // schema:DiscoverAction
    patterns:  ext.#PatternsGraph    // schema:HowTo
    tasks:     ext.#TasksGraph       // schema:Action
}
```

`cue vet .kb/` validates all entries against their schemas. Invalid entries
are type errors — they cannot enter the knowledge base.

## Evidence: Access Policy / ODRL (computed)

The `#ODRLPolicy` pattern produces standard ODRL 2.2 policy sets from graph
resources:

```json
{
    "@type": "odrl:Set",
    "odrl:uid": "apercue:graph-policy",
    "odrl:permission": [
        {
            "odrl:action": {
                "@id": "odrl:read"
            }
        },
        {
            "odrl:action": {
                "@id": "odrl:execute"
            },
            "odrl:assignee": {
                "@id": "apercue:operator"
            }
        }
    ],
    "odrl:prohibition": []
}
```

Permissions and prohibitions bind to resource types. In a dataspace context,
this governs which participants can read or execute which resource categories.
The policy is a CUE projection — it changes when the graph changes.

## Evidence: Provenance (computed)

Every knowledge base entry has computable provenance via the
`#ProvenanceTrace` pattern:

```json
{
    "@type": "prov:Entity",
    "@id": "urn:resource:analysis-code",
    "dcterms:title": "analysis-code",
    "prov:wasAttributedTo": {
        "@id": "apercue:graph-engine"
    },
    "prov:wasDerivedFrom": [
        {
            "@id": "urn:resource:sensor-dataset"
        }
    ],
    "prov:wasGeneratedBy": {
        "@id": "apercue:graph-construction"
    }
}
```

`prov:wasDerivedFrom` tracks dependency edges. In a federated dataspace,
this provenance chain answers "where did this data come from?" without
external provenance stores.

## Governance as Constraints

Dataspace governance typically requires runtime policy enforcement:
access control, data quality, provenance tracking. In CUE:

| Governance Concern | CUE Mechanism |
|-------------------|---------------|
| Access control | ODRL policy projection (`#ODRLPolicy`) |
| Data quality | CUE schema validation (`cue vet`) |
| Provenance | PROV-O projection (`#ProvenanceTrace`) |
| Catalog metadata | DCAT projection (`#DCATKnowledgeBase`) |
| Structural integrity | Type unification (dependency edges must resolve) |
| Policy consistency | Unification — conflicting policies are type errors |

These are not separate systems. Each is a CUE expression applied to the
same typed graph. Adding governance is adding a `.cue` file.

## Federation Model

The `.kb/` convention enables lightweight federation:

1. **Each repository** maintains its own `.kb/` with local schemas
2. **Cross-references** use typed ID patterns (`ADR-001`, `INSIGHT-003`)
3. **Aggregation** merges `.kb/` entries via CUE unification
4. **Conflict detection** is automatic — incompatible entries fail unification

This is not full dataspace interoperability. It is a structural primitive:
governed, typed, validated knowledge sharing between repositories that agree
on schema definitions.

## Relevance to Dataspaces

| Dataspaces Concern | CUE Approach |
|-------------------|--------------|
| Data sovereignty | `.kb/` per repository, local schema ownership |
| Interoperability | Shared CUE type definitions (imported as modules) |
| Access governance | ODRL policies as graph projections |
| Catalog / discovery | DCAT metadata from knowledge base manifests |
| Trust / provenance | PROV-O traces from dependency structure |
| Validation | Compile-time schema enforcement (`cue vet`) |

## Multi-Domain Evidence

The `.kb/` convention is deployed across:

| Repository | KB Entries | Graphs | Schema Validation |
|-----------|-----------|--------|-------------------|
| apercue.ca (reference) | 15+ | decisions, insights, patterns | CUE types |
| quicue.ca (infrastructure) | 20+ | + tasks, rejected | CUE types |
| cmhc-retrofit (construction) | 8+ | decisions, insights | CUE types |

Each `.kb/` validates independently. Cross-repository references resolve
via shared type definitions published as CUE modules.

## Limitations

- Not a full dataspace runtime (no negotiation protocol)
- Static governance (policies evaluated at build time, not request time)
- Schema agreement required between participants
- No dynamic discovery (catalog metadata is pre-computed)

## References

- [Core report](https://github.com/quicue/apercue/blob/main/w3c/core-report.md)
  — Full implementation evidence with 14 W3C specs
- [github.com/quicue/apercue](https://github.com/quicue/apercue) — Source (Apache 2.0)
- [docs.quicue.ca](https://docs.quicue.ca) — Module documentation
