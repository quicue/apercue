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
| **Dublin Core** | dcterms:requires | Namespace in @context | `vocab/context.cue` | N/A (namespace prefix) |
| **PROV-O** | prov:wasDerivedFrom | Namespace in @context | `vocab/context.cue` | N/A (namespace prefix) |
| **schema.org** | schema:actionStatus | Lifecycle status values | `vocab/context.cue` | N/A (namespace prefix) |

## Downstream (in quicue.ca)

| W3C Spec | Pattern | Description |
|----------|---------|-------------|
| **Hydra Core** | `#HydraApiDoc` | hydra:ApiDocumentation in quicue.ca operator dashboard |
| **DCAT 3** | `#DCATCatalog` | dcat:Catalog in quicue-kg aggregate module |

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
- [Hydra Core](https://www.hydra-cg.com/spec/latest/core/) — W3C Community Group
