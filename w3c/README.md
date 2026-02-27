# W3C Spec Coverage

How apercue.ca CUE patterns map to W3C specifications.

Every entry below is a **zero-cost projection** of the same typed dependency graph.
No runtime infrastructure required --- `cue export -e <expression> --out json` produces
the standards-compliant output.

## Implemented

| W3C Spec | Status | CUE Pattern | File | Export Expression |
|----------|--------|-------------|------|-------------------|
| **JSON-LD 1.1** | @context, @type, @id | All resources | `vocab/context.cue` | `cue export -e context` |
| **SHACL** | sh:ValidationReport | `#ComplianceCheck.shacl_report` | `patterns/validation.cue` | `cue export -e compliance.shacl_report` |
| **SHACL** | sh:ValidationReport | `#GapAnalysis.shacl_report` | `charter/charter.cue` | `cue export -e gaps.shacl_report` |
| **SKOS** | skos:ConceptScheme | `#LifecyclePhasesSKOS` | `patterns/lifecycle.cue` | `cue export -e lifecycle_skos` |
| **SKOS** | skos:ConceptScheme | `#TypeVocabulary` | `views/skos.cue` | `cue export -e type_vocab` |
| **EARL** | earl:Assertion | `#SmokeTest.earl_report` | `patterns/lifecycle.cue` | `cue export -e smoke.earl_report` |
| **OWL-Time** | time:Interval | `#CriticalPath.time_report` | `patterns/analysis.cue` | `cue export -e cpm.time_report` |
| **Dublin Core** | dcterms:requires, dcterms:title, dcterms:conformsTo | Every depends_on edge, resource name, and conformance link in SHACL/EARL reports | `vocab/context.cue` | Structural — present in all JSON-LD output |
| **PROV-O** | prov:Entity, prov:wasDerivedFrom | `#ProvenanceTrace.prov_report` | `patterns/provenance.cue` | `cue export -e provenance.prov_report` |
| **ODRL 2.2** | odrl:Set, odrl:Permission | `#ODRLPolicy.odrl_policy` | `patterns/policy.cue` | `cue export -e access_policy.odrl_policy` |
| **W3C ORG** | org:Organization, org:OrganizationalUnit | `#OrgStructure.org_report` | `views/org.cue` | `cue export -e structure.org_report` |
| **schema.org** | schema:additionalType | `#SchemaOrgAlignment.schema_graph` | `patterns/schema_alignment.cue` | `cue export -e schema_view.schema_graph` |
| **VC 2.0** | VerifiableCredential | `#ValidationCredential.vc` | `patterns/credentials.cue` | `cue export -e validation_credential.vc` |
| **Activity Streams 2.0** | as:OrderedCollection | `#ActivityStream.stream` | `patterns/activity.cue` | `cue export -e activity_stream.stream` |
| **DCAT 3** | dcat:Catalog, dcat:Dataset | `#DCATCatalog.dcat_catalog` | `patterns/catalog.cue` | `cue export -e catalog.dcat_catalog` |

## Downstream (in quicue.ca)

| W3C Spec | Pattern | Description |
|----------|---------|-------------|
| **Hydra Core** | `#HydraApiDoc` | hydra:ApiDocumentation in quicue.ca operator dashboard |
| **DCAT 3** | `#DCAT3Catalog`, `#DCATKnowledgeBase` | Extended dcat:Catalog and .kb/ projections in quicue.ca (builds on apercue's `#DCATCatalog`) |

## How It Works

The traditional semantic web stack requires:

```
Data → RDF Store → SPARQL Queries → SHACL Validator → JSON-LD Serializer
```

apercue.ca collapses this to:

```
Data → cue export -e <projection>
```

CUE comprehensions precompute all queries at evaluation time. CUE unification
enforces all shapes at constraint resolution time. The W3C artifacts are
different views of the same typed graph, not separate processing stages.

## References

- [JSON-LD 1.1](https://www.w3.org/TR/json-ld11/) — W3C Recommendation
- [SHACL](https://www.w3.org/TR/shacl/) — W3C Recommendation
- [SKOS](https://www.w3.org/TR/skos-reference/) — W3C Recommendation
- [EARL](https://www.w3.org/TR/EARL10-Schema/) — W3C Note
- [OWL-Time](https://www.w3.org/TR/owl-time/) — W3C Recommendation
- [DCAT 3](https://www.w3.org/TR/vocab-dcat-3/) — W3C Recommendation
- [ODRL 2.2](https://www.w3.org/TR/odrl-model/) — W3C Recommendation
- [W3C ORG](https://www.w3.org/TR/vocab-org/) — W3C Recommendation
- [Verifiable Credentials 2.0](https://www.w3.org/TR/vc-data-model-2.0/) — W3C Recommendation
- [Activity Streams 2.0](https://www.w3.org/TR/activitystreams-core/) — W3C Recommendation
- [Hydra Core](https://www.hydra-cg.com/spec/latest/core/) — W3C Community Group
