// KG-Construct CG submission — generated via cue export.
//
// Usage:
//   cue export ./w3c/ -e kg_construct_report --out text > w3c/kg-construct.md
package w3c

kg_construct_report: """
	# CUE as a Declarative Knowledge Graph Construction Language

	**Use Case Submission for the KG-Construct Community Group**

	---

	## Summary

	[apercue.ca](https://github.com/quicue/apercue) uses
	[CUE](https://cuelang.org) — a constraint language with lattice-based type
	semantics — to construct, validate, and serialize knowledge graphs entirely at
	compile time. Graph building, SHACL validation, and JSON-LD output happen in a
	single `cue export` invocation. No mapping language, no runtime pipeline, no
	triplestore.

	This submission demonstrates CUE as a KG construction language and explains how
	it relates to the KG-Construct CG's work on declarative KG construction.

	## The Construction Pipeline (One Step)

	Traditional KG construction requires a multi-stage pipeline:

	```
	Source Data → Mapping (R2RML/RML) → RDF Store → SHACL Validation → Serialization
	```

	CUE collapses this to:

	```
	Source Data (CUE structs) → cue export -e <projection>
	```

	The "mapping" is CUE type unification. The "validation" is CUE constraint
	resolution. The "serialization" is JSON-LD context injection. All three happen
	during evaluation — there is no separate step for any of them.

	## Example: Supply Chain Graph

	Five nodes define a supply chain. Each declares `@type` (what it is) and
	`depends_on` (what it needs):

	```cue
	"cpu-chip": {
	    name:       "cpu-chip"
	    "@type":    {Component: true}
	    depends_on: {"silicon-wafer": true}
	}
	```

	The `#Graph` pattern computes topology, depth, roots, leaves, ancestors,
	dependents, and impact sets from this declaration alone.

	## Evidence: SHACL Validation (computed)

	A compliance rule requires that assemblies have upstream dependencies. The
	`#ComplianceCheck` pattern produces a standard `sh:ValidationReport`:

	```json
	\(_json.shacl)
	```

	This is produced during CUE evaluation. `sh:conforms: true` means the graph
	satisfies all constraints. If any resource violates a rule, unification with
	`true` produces bottom (`_|_`) and `cue vet` fails — the graph cannot be
	constructed in an invalid state.

	## Evidence: Provenance (computed)

	The `#ProvenanceTrace` pattern maps dependency edges to PROV-O:

	```json
	\(_json.prov_entity)
	```

	Every resource becomes a `prov:Entity`. Dependency edges become
	`prov:wasDerivedFrom` links. Provenance is not annotated after the fact — it
	is structurally computed from the same graph that produces the KG.

	## Evidence: JSON-LD Context (computed)

	The vocabulary registry produces a JSON-LD 1.1 `@context`:

	```json
	\(_json.context)
	```

	Every field mapping (`name` → `dcterms:title`, `depends_on` → `dcterms:requires`)
	is a CUE constraint. Adding a vocabulary term means extending a CUE definition,
	not editing a context file.

	## Relevance to KG-Construct

	| KG-Construct Concern | CUE Approach |
	|---------------------|--------------|
	| Declarative mapping | CUE types + comprehensions (no R2RML) |
	| Source heterogeneity | Adapter scripts output `{name, @type, depends_on}` |
	| Validation | SHACL reports from constraint unification |
	| Provenance | PROV-O from dependency structure |
	| Serialization | JSON-LD via `@context` injection |
	| Incremental construction | Add a `.cue` file; graph extends via unification |

	CUE does not replace RML for arbitrary RDF construction from relational
	sources. It targets constrained domains where the schema is known and the
	graph structure maps directly to typed dependencies. For these domains, the
	entire KG construction pipeline reduces to a type-checked `cue export`.

	## Limitations

	- Closed-world: all resources declared upfront
	- DAGs only: no cyclic dependencies
	- Not a general RDF toolkit: targets constrained dependency graphs
	- Performance: pre-compute transitive closure for graphs exceeding ~40 nodes

	## References

	- [Core report](https://github.com/quicue/apercue/blob/main/w3c/core-report.md)
	  — Full implementation evidence with \(evidence.spec_counts.total) W3C specs
	- [github.com/quicue/apercue](https://github.com/quicue/apercue) — Source (Apache 2.0)
	- [demo.quicue.ca](https://demo.quicue.ca) — Interactive D3 graph explorer
	"""
