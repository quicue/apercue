# Compile-Time Asset Lifecycle Attestation via Typed Dependency Graphs

**A use case for the Physical Asset Attestation (UORA) Community Group**

---

## Problem Statement

Physical asset lifecycle tracking requires multiple interlocking concerns:
identity (which asset?), state verification (what happened to it?), provenance
(where did it come from?), compliance (does it meet requirements?), and
attestation (can we prove all of the above?). These concerns are typically
handled by separate systems — an asset registry, a provenance store, a
compliance engine, a credential issuer — each with its own data model and
integration surface.

What if the asset lifecycle were a single typed dependency graph, and identity,
provenance, compliance, and attestation were all projections of that same graph?

## Approach: Asset Lifecycles as Dependency Graphs

The [apercue.ca](https://github.com/quicue/apercue) project uses
[CUE](https://cuelang.org) — a constraint language with lattice-based type
semantics — to model dependency graphs where each resource is a typed node
with declared dependencies. The same patterns used for knowledge graphs,
project scheduling, and data governance apply directly to physical asset
lifecycle tracking.

A physical asset lifecycle is a DAG (directed acyclic graph):

```
Raw Material → Manufacturing → Quality Control → Shipping → Delivery → Installation
```

Each stage depends on the previous one. Each has typed requirements (certifications,
inspections, chain-of-custody handoffs). In CUE:

```cue
"quality-control": {
    name:       "quality-control"
    "@type":    {Attestable: true, Governed: true, Schedulable: true}
    depends_on: {"manufacturing": true}
    duration:   14  // days
}
```

This resource simultaneously participates in three contexts:
- **Attestable**: produces a Verifiable Credential upon completion
- **Governed**: subject to ODRL access policies (who can see QC results?)
- **Schedulable**: has a duration and position in the critical path

## Evidence: Verifiable Credentials (implemented)

The `#ValidationCredential` pattern wraps a SHACL validation report in a
W3C Verifiable Credential 2.0 envelope:

```json
{
    "@context": [
        "https://www.w3.org/ns/credentials/v2",
        {
            "dcterms": "http://purl.org/dc/terms/",
            "prov": "http://www.w3.org/ns/prov#",
            "sh": "http://www.w3.org/ns/shacl#",
            "apercue": "https://apercue.ca/vocab#"
        }
    ],
    "type": ["VerifiableCredential", "ValidationCredential"],
    "issuer": "apercue:graph-engine",
    "validFrom": "2026-02-26T00:00:00Z",
    "credentialSubject": {
        "type": "sh:ValidationReport",
        "sh:conforms": true,
        "apercue:violationCount": 0,
        "apercue:validationReport": {
            "@type": "sh:ValidationReport",
            "sh:conforms": true,
            "sh:result": []
        }
    }
}
```

This credential attests: "this graph passed all structural compliance rules
at time T." For a physical asset lifecycle, this becomes: "this asset
completed all required stages and all compliance checks passed."

Note: This produces the credential **data model** only. Cryptographic proof
(signatures, zero-knowledge) is a deployment concern handled by an external
VC issuer. CUE handles structural conformance; signing is orthogonal.

## Evidence: Provenance (implemented)

The `#ProvenanceTrace` pattern computes PROV-O from dependency edges:

```json
{
    "@type": "prov:Entity",
    "@id": "urn:resource:quality-control",
    "dcterms:title": "quality-control",
    "prov:wasDerivedFrom": [
        {"@id": "urn:resource:manufacturing"}
    ],
    "prov:wasGeneratedBy": {
        "@id": "apercue:graph-construction"
    }
}
```

In a UORA context, `prov:wasDerivedFrom` traces the chain of custody.
Each lifecycle stage is a `prov:Entity` derived from its predecessor.
The provenance chain is structurally computed — not annotated after the fact.

## Evidence: Access Policies (implemented)

The `#ODRLPolicy` pattern produces ODRL 2.2 policy sets:

```json
{
    "@type": "odrl:Set",
    "odrl:uid": "apercue:graph-policy",
    "odrl:permission": [
        {"odrl:action": {"@id": "odrl:read"}},
        {"odrl:action": {"@id": "odrl:execute"},
         "odrl:assignee": {"@id": "apercue:operator"}}
    ],
    "odrl:prohibition": []
}
```

For multi-party supply chains, ODRL policies govern which participants can
read which lifecycle stages. A manufacturer sees QC results; a shipping
partner sees logistics data; a customer sees delivery attestation.

## Evidence: Scheduling (implemented)

The `#CriticalPath` pattern computes OWL-Time intervals:

```json
{
    "@type": "time:Interval",
    "@id": "urn:resource:quality-control",
    "time:hasBeginning": {"@type": "time:Instant", "time:inXSDDecimal": 44},
    "time:hasEnd": {"@type": "time:Instant", "time:inXSDDecimal": 58},
    "time:hasDuration": {
        "@type": "time:Duration",
        "time:numericDuration": 14,
        "time:unitType": {"@id": "time:unitDay"}
    },
    "apercue:slack": 0,
    "apercue:isCritical": true
}
```

For physical assets, this answers: "when does QC start?", "is it on the
critical path?", "how much slack before it delays delivery?"

## Relevance to UORA

| UORA Concern | CUE Approach |
|-------------|--------------|
| Universal addressing | `@id` URIs for every lifecycle stage (`urn:resource:*`) |
| Event-based attestation | `#ValidationCredential` — VC 2.0 wrapping SHACL reports |
| Lifecycle tracking | `depends_on` edges form the lifecycle DAG |
| State verification | `#ComplianceCheck` — `sh:conforms` true/false per gate |
| Chain of custody | `#ProvenanceTrace` — PROV-O from dependency structure |
| Multi-party trust | `#ODRLPolicy` — access policies per resource type |
| Critical path | `#CriticalPath` — OWL-Time scheduling with slack analysis |
| Structural integrity | CUE unification — incomplete lifecycles are type errors |

## What This Is (and Isn't)

This is a **compile-time structural model** for asset lifecycle attestation.
It demonstrates that the data model for physical asset tracking can be
expressed as a typed dependency graph with W3C vocabulary projections.

This is **not** a runtime attestation protocol. It does not handle:
- Cryptographic signing (VC proof generation)
- DID resolution for physical assets
- Real-time event ingestion
- Sensor binding or IoT integration

These are complementary concerns. The CUE model defines the structural
shape of what gets attested; UORA's protocol work defines how attestations
are signed, resolved, and verified at runtime.

## Multi-Domain Validation

The same patterns have been validated across:

| Domain | Resources | Attestation Target |
|--------|-----------|-------------------|
| Research data management | 5 stages | Publication pipeline completion |
| IT infrastructure | 30+ nodes | Service deployment readiness |
| Federal LLM governance | 52 obligations | Regulatory compliance (DADM) |
| Construction PM | 18 work packages | Phase-gate completion |

Each uses the identical `#ValidationCredential` + `#ProvenanceTrace` +
`#ODRLPolicy` projection stack.

## References

- [github.com/quicue/apercue](https://github.com/quicue/apercue) — Source (Apache 2.0)
- [W3C core report](https://github.com/quicue/apercue/blob/main/w3c/core-report.md) — 14 W3C spec evidence
- [patterns/credentials.cue](https://github.com/quicue/apercue/blob/main/patterns/credentials.cue) — VC 2.0 pattern source
- [apercue.ca](https://apercue.ca) — Project website
