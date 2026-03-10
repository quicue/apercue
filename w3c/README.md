# W3C Spec Coverage

How apercue.ca CUE patterns map to W3C specifications.

Every entry below is a **projection** of the same typed dependency graph.
For domains with bounded, known resource sets — project plans, infrastructure,
curricula, supply chains — CUE evaluation produces standards-compliant output
directly, without a runtime triplestore or query engine.

This is not a replacement for the semantic web stack. RDF stores, SPARQL
endpoints, and SHACL engines serve open-world, federated, and dynamic use
cases that CUE's closed-world model does not address. What CUE offers is a
complementary approach for constrained domains where the full graph is known
at evaluation time, and where compile-time guarantees (type safety,
constraint consistency) are more valuable than runtime flexibility.

## Implemented

| W3C Spec | Status | CUE Pattern | File | Export Expression |
|----------|--------|-------------|------|-------------------|
| **JSON-LD 1.1** | @context, @type, @id | All resources | `vocab/context.cue` | `cue export -e context` |
| **SHACL** | sh:ValidationReport | `#ComplianceCheck.shacl_report` | `patterns/validation.cue` | `cue export -e compliance.shacl_report` |
| **SHACL** | sh:ValidationReport | `#GapAnalysis.shacl_report` | `charter/charter.cue` | `cue export -e gaps.shacl_report` |
| **SHACL** | sh:NodeShape, sh:PropertyShape | `#SHACLShapes.shapes_graph` | `patterns/shapes.cue` | `cue export -e shape_export.shapes_graph` |
| **SKOS** | skos:ConceptScheme | `#LifecyclePhasesSKOS` | `patterns/lifecycle.cue` | `cue export -e lifecycle_skos` |
| **SKOS** | skos:ConceptScheme | `#TypeVocabulary` | `views/skos.cue` | `cue export -e type_vocab` |
| **SKOS** | skos:broader, skos:narrower | `#SKOSTaxonomy.taxonomy_scheme` | `patterns/taxonomy.cue` | `cue export -e _taxonomy.taxonomy_scheme` |
| **EARL** | earl:Assertion, earl:TestCase, earl:Software | `#SmokeTest.earl_report` | `patterns/lifecycle.cue` | `cue export -e smoke.earl_report` |
| **OWL-Time** | time:Interval | `#CriticalPath.time_report` | `patterns/analysis.cue` | `cue export -e cpm.time_report` |
| **OWL-Time** | time:Instant | `#ContextEventLog.event_report` | `patterns/context_event.cue` | `cue export -e event_log.event_report` |
| **Dublin Core** | dcterms:requires, dcterms:title, dcterms:conformsTo | Every depends_on edge, resource name, and conformance link in SHACL/EARL reports | `vocab/context.cue` | Structural — present in all JSON-LD output |
| **PROV-O** | prov:Entity, prov:Generation, prov:SoftwareAgent | `#ProvenanceTrace.prov_report` | `patterns/provenance.cue` | `cue export -e provenance.prov_report` |
| **PROV-O** | prov:Plan, prov:Activity | `#ProvenancePlan.plan_report` | `patterns/provenance_plan.cue` | `cue export -e _prov_plan.plan_report` |
| **PROV-O** | prov:Activity, prov:Collection | `#ContextEventLog.event_report` | `patterns/context_event.cue` | `cue export -e event_log.event_report` |
| **ODRL 2.2** | odrl:Set, odrl:Permission | `#ODRLPolicy.odrl_policy` | `patterns/policy.cue` | `cue export -e access_policy.odrl_policy` |
| **W3C ORG** | org:Organization, org:OrganizationalUnit | `#OrgStructure.org_report` | `views/org.cue` | `cue export -e structure.org_report` |
| **schema.org** | schema:additionalType | `#SchemaOrgAlignment.schema_graph` | `patterns/schema_alignment.cue` | `cue export -e schema_view.schema_graph` |
| **VC 2.0** | VerifiableCredential | `#ValidationCredential.vc` | `patterns/credentials.cue` | `cue export -e validation_credential.vc` |
| **Activity Streams 2.0** | as:OrderedCollection | `#ActivityStream.stream` | `patterns/activity.cue` | `cue export -e activity_stream.stream` |
| **DCAT 3** | dcat:Catalog, dcat:Dataset | `#DCATCatalog.dcat_catalog` | `patterns/catalog.cue` | `cue export -e catalog.dcat_catalog` |
| **VoID** | void:Dataset, void:Linkset | `#VoIDDataset.void_description` | `patterns/void.cue` | `cue export -e void_dataset.void_description` |
| **DQV** | dqv:QualityMeasurement, dqv:Metric | `#DataQualityReport.quality_report` | `patterns/quality.cue` | `cue export -e _quality.quality_report` |
| **Web Annotation** | oa:Annotation, oa:TextualBody | `#AnnotationCollection.annotation_collection` | `patterns/annotation.cue` | `cue export -e annotations.annotation_collection` |
| **RDFS** | rdfs:Class, rdfs:subClassOf, rdfs:domain/range | `#OWLOntology.owl_ontology` | `patterns/ontology.cue` | `cue export -e ontology.owl_ontology` |

## Downstream (in quicue.ca)

| W3C Spec | Pattern | Description |
|----------|---------|-------------|
| **Hydra Core** | `#HydraApiDoc` | hydra:ApiDocumentation in quicue.ca operator dashboard |
| **DCAT 3** | `#DCAT3Catalog`, `#DCATKnowledgeBase` | Extended dcat:Catalog and .kb/ projections in quicue.ca (builds on apercue's `#DCATCatalog`) |

## How It Works

The traditional semantic web stack uses separate components for storage,
querying, validation, and serialization:

```
Data → RDF Store → SPARQL Queries → SHACL Validator → JSON-LD Serializer
```

For domains where the resource set is bounded and known upfront, CUE can
serve these roles in a single evaluation step:

```
Data → cue export -e <projection>
```

CUE comprehensions handle pattern matching over the graph (analogous to
SPARQL). CUE unification enforces shape constraints (analogous to SHACL
validation). JSON-LD `@context` injection handles serialization. These happen
during a single `cue export` invocation.

The trade-off is closed-world semantics: every resource must be declared,
and there is no runtime discovery or open-world inference. This is
appropriate for project plans, infrastructure topologies, curricula, and
similar domains where completeness is a feature rather than a limitation.

## Community Group Engagement

| CG | Status | Link |
|----|--------|------|
| **KG-Construct** | PR #21 merged (2 use cases) | [kg-construct/use-cases#21](https://github.com/kg-construct/use-cases/pull/21) |
| **Context Graphs** | Use case submitted, Standards committee | [w3.org/community/context-graph](https://www.w3.org/community/context-graph/) |

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
- [VoID](https://www.w3.org/TR/void/) — W3C Interest Group Note
- [DQV](https://www.w3.org/TR/vocab-dqv/) — W3C Note
- [Web Annotation](https://www.w3.org/TR/annotation-model/) — W3C Recommendation
- [RDF Schema](https://www.w3.org/TR/rdf-schema/) — W3C Recommendation
- [OWL 2](https://www.w3.org/TR/owl2-overview/) — W3C Recommendation
- [Hydra Core](https://www.hydra-cg.com/spec/latest/core/) — W3C Community Group
