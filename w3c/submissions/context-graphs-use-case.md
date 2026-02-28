# Multi-Context Resource Identity via Struct-as-Set Types in CUE

**A use case for the Context Graphs Community Group**

---

## Problem Statement

A resource in a knowledge graph often participates in multiple contexts
simultaneously. A dataset might be subject to provenance tracking (PROV-O
context), access governance (ODRL context), scheduling (OWL-Time context), and
quality validation (SHACL context) — all at the same time. How should a resource
express simultaneous membership in multiple contexts, and how should those
contexts compose without conflicts?

Most approaches assign a primary type and add context through annotation,
tagging, or named graph membership. This requires deciding which context is
primary and managing context-specific metadata separately from the resource
definition.

## Approach: @type as a Set

The [apercue.ca](https://github.com/quicue/apercue) project uses CUE's type
system to represent multi-context identity directly. Each resource declares its
types as a struct with boolean values:

```cue
"sensor-dataset": {
    name:       "sensor-dataset"
    "@type":    {Dataset: true, Schedulable: true, Governed: true}
    depends_on: {"ethics-approval": true}
}
```

This resource exists simultaneously in three contexts:
- **Dataset** context: subject to provenance tracking
- **Schedulable** context: subject to critical path analysis
- **Governed** context: subject to embargo and access policies

No context is primary. The resource IS all of these simultaneously, and CUE
unification guarantees consistency across all contexts.

### Context Binding via Set Intersection

Providers (tools, validators, policies) declare which types they serve.
Binding is set intersection:

```cue
for tname, _ in provider.types
if resource["@type"][tname] != _|_ {tname}
```

A resource with `{Dataset: true, Governed: true}` matches a data repository
(serves Dataset) AND an ethics board (serves Governed) simultaneously.

### Cross-Context Consistency

If two contexts place conflicting constraints on the same resource, CUE
unification produces bottom (`_|_`). The graph cannot be constructed. This is
a type error caught before any output is generated — not a runtime conflict.

### Context Composition

Adding a context to a resource is adding a key to a struct. Merging contexts
is struct unification:

```cue
{Dataset: true} & {Governed: true} → {Dataset: true, Governed: true}
```

This uses CUE's lattice semantics. Context composition is not a graph
operation — it is type unification.

## Evidence: Multiple W3C Projections From One Graph

A single 5-node research publication graph (defined once) produces output in
17 different W3C specifications. Each projection selects a different context
of the same resources:

| Context | W3C Specification | Projection Expression |
|---------|------------------|----------------------|
| Scheduling | OWL-Time | `cue export -e cpm.time_report` |
| Compliance | SHACL | `cue export -e compliance.shacl_report` |
| Provenance | PROV-O | `cue export -e provenance.prov_report` |
| Access control | ODRL | `cue export -e access_policy.odrl_policy` |
| Cataloging | DCAT 3 | `cue export -e catalog.dcat_catalog` |
| Self-description | VoID | `cue export -e void_dataset.void_description` |
| Quality | DQV | `cue export -e _quality.quality_report` |
| Annotation | Web Annotation | `cue export -e annotations.annotation_collection` |
| Vocabulary | SKOS | `cue export -e _taxonomy.taxonomy_scheme` |
| Type system | RDFS/OWL | `cue export -e ontology.owl_ontology` |
| Testing | EARL | `cue export -e smoke.earl_report` |
| Discovery | schema.org | `cue export -e schema_view.schema_graph` |
| Organization | W3C Org | `cue export -e structure.org_report` |
| Activity log | Activity Streams | `cue export -e activity_stream.stream` |
| Attestation | VC 2.0 | `cue export -e validation_credential.vc` |
| Identity | JSON-LD 1.1 | `cue export -e context` |

Resource identity (`@id`) is stable across all projections because the graph
is the single source of truth.

**Scheduling context (OWL-Time):**

```json
{
    "@type": "time:Interval",
    "@id": "urn:resource:analysis-code",
    "time:hasBeginning": {"@type": "time:Instant", "time:inXSDDecimal": 150},
    "time:hasEnd": {"@type": "time:Instant", "time:inXSDDecimal": 195},
    "time:hasDuration": {
        "@type": "time:Duration",
        "time:numericDuration": 45,
        "time:unitType": {"@id": "time:unitDay"}
    },
    "apercue:slack": 0,
    "apercue:isCritical": true
}
```

**Provenance context (PROV-O):**

```json
{
    "@type": "prov:Entity",
    "@id": "urn:resource:analysis-code",
    "prov:wasDerivedFrom": [{"@id": "urn:resource:sensor-dataset"}],
    "prov:wasGeneratedBy": {"@id": "apercue:graph-construction"}
}
```

**Access control context (ODRL):**

```json
{
    "@type": "odrl:Set",
    "odrl:permission": [
        {"odrl:action": {"@id": "odrl:read"}},
        {"odrl:action": {"@id": "odrl:execute"}, "odrl:assignee": {"@id": "apercue:operator"}}
    ]
}
```

Same resource (`analysis-code`), same `@id`, three different contexts — each
a standard W3C vocabulary.

## Multi-Domain Validation

| Domain | Resources | Contexts Per Resource |
|--------|-----------|----------------------|
| Research data management | 5 resources | Dataset + governance + scheduling |
| IT infrastructure | 30 nodes | 2–4 types per resource |
| University curricula | 12 courses | Department + prerequisite + scheduling |
| Construction PM | 18 work packages | Phase + gate + compliance |

The same `#Graph` pattern and set intersection dispatch works across all
domains. The contexts are domain-specific; the mechanism is universal.

## Relevance to Context Graphs

| Context Graphs Concern | CUE Approach |
|----------------------|--------------|
| Multi-context identity | `@type` struct-as-set: `{A: true, B: true}` |
| Context binding | Set intersection between resource types and provider types |
| Cross-context consistency | CUE unification — conflicts are type errors |
| Context-specific views | `cue export -e <projection>` per context |
| Context composition | Struct merging: `{A: true} & {B: true}` |

## Limitations

- **Closed-world:** contexts must be declared, not discovered at runtime
- **Flat namespace:** no hierarchical context inheritance (by design — keeps dispatch simple)
- **Boolean membership only:** no weighted or probabilistic context participation
- **Static:** context assignment is compile-time, not dynamic

## Discussion

This approach treats context as a first-class property of resources rather than
an external annotation. The key trade-off is expressiveness vs. guarantees:
CUE's closed-world lattice semantics provide strong consistency guarantees but
cannot model open-world context discovery.

For the Context Graphs CG's investigations into how context affects graph
structure and querying, the struct-as-set pattern offers a concrete,
implemented example of compile-time multi-context identity with formal
consistency guarantees.

## References

- [github.com/quicue/apercue](https://github.com/quicue/apercue) — Source (Apache 2.0)
- [W3C core report](https://github.com/quicue/apercue/blob/main/w3c/core-report.md) — Full evidence with 17 W3C specs
- [apercue.ca](https://apercue.ca) — Project website
