# Compile-Time Data Governance for Lightweight Dataspaces

## Summary

How can autonomous data owners share governed, validated data without runtime
policy enforcement infrastructure? This challenge proposes typed knowledge bases
with compile-time ODRL policies, DCAT catalogs, and PROV-O provenance as a
lightweight dataspace primitive.

## Description

Dataspace architectures typically require runtime components for policy
enforcement, catalog management, and provenance tracking. These components
add operational complexity that may be disproportionate for smaller federations
— research groups, open-source ecosystems, or institutional data networks where
participants already agree on schema definitions.

The [apercue.ca](https://github.com/quicue/apercue) project implements a
`.kb/` (knowledge base) convention where each repository maintains typed,
schema-validated data entries. CUE's constraint language provides:

**Governance as type constraints:**
- **ODRL access policies** are projections of the typed graph — permissions and
  prohibitions bind to resource types, not to runtime access control lists
- **DCAT catalog metadata** is computed from the same graph structure, enabling
  discovery of data assets and their relationships
- **PROV-O provenance** traces are structurally computed from dependency edges,
  not annotated after the fact
- **SHACL validation** happens at evaluation time — data that violates
  constraints cannot be serialized

**Federation via CUE module imports:**
- Each repository owns its `.kb/` and local schemas
- Cross-references use typed ID patterns
- Aggregation merges entries via CUE unification
- Conflicting entries are type errors caught at compile time

This has been validated across three domains: a reference implementation
(15+ entries), an infrastructure repository (20+ entries), and a construction
project management repository (8+ entries). Each validates independently;
cross-repository references resolve via shared CUE type definitions published
as modules.

### Computed Evidence

The approach produces standard W3C vocabulary output:

- **ODRL 2.2** policy sets with typed permissions/prohibitions
- **DCAT 3** catalogs with `dcat:Dataset` entries and `dcat:theme` via SKOS
- **PROV-O** entity traces with `prov:wasDerivedFrom` dependency chains
- **SHACL** validation reports (`sh:conforms: true/false`)

Full computed JSON evidence: [W3C core report](https://github.com/quicue/apercue/blob/main/w3c/core-report.md)

## Discussion Points

1. **Is compile-time governance sufficient for certain dataspace topologies?**
   Static policy evaluation at build time cannot handle dynamic access
   negotiations, but may be adequate for federations with stable, agreed-upon
   schemas. Where is the boundary?

2. **Schema agreement as a prerequisite vs. negotiated interoperability.**
   This approach requires participants to import shared CUE type definitions.
   How does this compare to the dataspace model of negotiated interoperability
   between heterogeneous participants?

3. **DCAT catalogs from typed graphs vs. maintained metadata.** DCAT metadata
   is computed, not curated. It changes when the graph changes. Does this
   satisfy the discovery requirements of a dataspace, or does curated metadata
   serve a different purpose?

4. **Provenance without provenance infrastructure.** Dependency edges become
   PROV-O traces automatically. Is structurally computed provenance as
   trustworthy as explicitly recorded provenance?

## Related Work

- **IDSA Reference Architecture** — runtime connector model for data
  sovereignty; this challenge explores whether compile-time guarantees can
  serve similar purposes for constrained topologies
- **Gaia-X** — federated data infrastructure; the `.kb/` convention
  implements a subset of federation concerns at the schema level
- **DCAT 3** (W3C Recommendation) — catalog vocabulary used for computed
  dataset metadata projections
- **ODRL 2.2** (W3C Recommendation) — policy language used for typed
  access control projections
- **Solid** — per-user data pods; the `.kb/` per-repository convention
  shares the "data stays with the owner" principle

## References

- [github.com/quicue/apercue](https://github.com/quicue/apercue) — Source (Apache 2.0)
- [apercue.ca](https://apercue.ca) — Project website
- [W3C evidence report](https://github.com/quicue/apercue/blob/main/w3c/core-report.md) — Full computed evidence with 17 W3C specs
