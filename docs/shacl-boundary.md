# Compliance rules and SHACL Core

`#ComplianceCheck.rule_shapes` compiles each `#ComplianceRule` to a SHACL
Core `sh:NodeShape` (`apercue:rule/<name>`, targeting `vocab.TypeBase + type`).
`tests/rdf/test_rdf.py` runs pyshacl on those shapes over `#DataGraph` and
requires the same `sh:conforms` and the same (shape, focus node) pairs as
apercue's own `shacl_report`. It does this on a graph that exercises every
rule kind (`tests/rule-kinds/`) and on every single-step mutation of it:
each edge dropped, each node retyped, each node removed (19 graphs).

| Rule field | SHACL Core | Agreement tested |
|---|---|---|
| `must_not_be_root` | `sh:path dcterms:requires; sh:minCount 1` | yes |
| `must_not_be_leaf` | `sh:path [sh:inversePath dcterms:requires]; sh:minCount 1` | yes |
| `min_dependents: N` | `sh:path [sh:oneOrMorePath [sh:inversePath dcterms:requires]]; sh:minCount N` (dependents are transitive) | yes |
| `requires_dependency_type` | `sh:path dcterms:requires; sh:qualifiedValueShape [sh:class T]` (or `sh:or` of classes); `sh:qualifiedMinCount 1` | yes |
| `requires_dependent_type` | same, on `[sh:oneOrMorePath [sh:inversePath dcterms:requires]]` | yes |
| `requires_transitive_dependency_type` | same, on `[sh:oneOrMorePath dcterms:requires]` | yes |
| `max_depth` | none | not expressible: needs path length. Reported as `apercue:max_depth`, omitted from the shape |
| `conditional_severity` | none | not expressible: severity depends on tags of all matched resources. The shape uses the rule's base `severity` |

The last two rows are the boundary of the claim: for those, apercue's
report has no independent SHACL check.
