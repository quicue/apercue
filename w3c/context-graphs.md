# Struct-as-Set @type: Multi-Context Resource Identity in CUE

**Use Case Submission for the Context Graphs Community Group**

---

## Summary

[apercue.ca](https://github.com/quicue/apercue) represents resource types
as CUE structs (`{TypeA: true, TypeB: true}`) rather than arrays or class
hierarchies. This "struct-as-set" pattern gives every resource simultaneous
membership in multiple contexts — data governance, provenance, scheduling,
semantic web — resolved through set intersection at evaluation time.

This submission demonstrates how CUE's type system naturally models the
multi-context identity that the Context Graphs CG investigates.

## The Pattern: @type as a Set

Each resource declares its types as a struct with boolean values:

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

No context is primary. No context is added after the fact. The resource IS
all of these simultaneously, and CUE unification guarantees consistency
across all contexts.

## How Context Resolution Works

### Set Intersection as Dispatch

Providers (tools, validators, policies) declare which types they serve:

```cue
for tname, _ in provider.types
if resource["@type"][tname] != _|_ {tname}
```

A resource with `{Dataset: true, Governed: true}` matches a data
repository (serves Dataset) AND an ethics board (serves Governed)
simultaneously. The binding is set intersection, not registration.

### Unification Guarantees Consistency

If two contexts place conflicting constraints on the same resource, CUE
unification produces bottom (`_|_`). The graph cannot be constructed. This
is not a runtime error — it is a type error caught before any output is
generated.

## Evidence: Multiple Projections From One Graph

The same 5-node research publication graph (defined once) produces output in
17 different W3C specifications. Each projection
selects a different context:

**Scheduling context** (OWL-Time):

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

**Compliance context** (SHACL):

```json
{
    "@type": "sh:ValidationReport",
    "sh:conforms": true,
    "sh:result": []
}
```

**Provenance context** (PROV-O):

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

**Access control context** (ODRL):

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

Each projection is a `cue export -e <expression>` invocation. The resource
identity is stable across all contexts because the graph is the single
source of truth.

## Relevance to Context Graphs

| Context Graphs Concern | CUE Approach |
|----------------------|--------------|
| Multi-context identity | `@type` struct-as-set: `{A: true, B: true}` |
| Context binding | Set intersection between resource types and provider types |
| Cross-context consistency | CUE unification — conflicts are type errors |
| Context-specific views | `cue export -e <projection>` per context |
| Context composition | Struct merging: `{A: true} & {B: true}` = `{A: true, B: true}` |

CUE's lattice semantics mean that context composition is not a graph
operation — it is type unification. Adding a context to a resource is
adding a key to a struct. Merging contexts is struct unification. Testing
context membership is field presence.

## Multi-Domain Evidence

This pattern has been validated across four domains:

| Domain | Resources | Contexts Per Resource |
|--------|-----------|----------------------|
| Research data mgmt | 5 resources | Dataset + governance + scheduling |
| IT infrastructure | 30 nodes | 2-4 types per resource |
| University curricula | 12 courses | Department + prerequisite + scheduling |
| Construction PM | 18 work packages | Phase + gate + compliance |

The same `#Graph` pattern, the same set intersection dispatch. The contexts
are domain-specific; the mechanism is universal.

## Limitations

- Closed-world: contexts must be declared, not discovered
- Flat namespace: no hierarchical context inheritance (by design — keeps dispatch simple)
- Boolean membership only: no weighted or probabilistic context participation

## References

- [Core report](https://github.com/quicue/apercue/blob/main/w3c/core-report.md)
  — Full implementation evidence
- [github.com/quicue/apercue](https://github.com/quicue/apercue) — Source (Apache 2.0)
