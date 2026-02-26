// Context Graphs CG submission — generated via cue export.
//
// Usage:
//   cue export ./w3c/ -e context_graphs_report --out text > w3c/context-graphs.md
package w3c

context_graphs_report: """
	# Struct-as-Set @type: Multi-Context Resource Identity in CUE

	**Use Case Submission for the Context Graphs Community Group**

	---

	## Summary

	[apercue.ca](https://github.com/quicue/apercue) represents resource types
	as CUE structs (`{TypeA: true, TypeB: true}`) rather than arrays or class
	hierarchies. This "struct-as-set" pattern gives every resource simultaneous
	membership in multiple contexts — infrastructure, compliance, scheduling,
	semantic web — resolved through set intersection at evaluation time.

	This submission demonstrates how CUE's type system naturally models the
	multi-context identity that the Context Graphs CG investigates.

	## The Pattern: @type as a Set

	Each resource declares its types as a struct with boolean values:

	```cue
	"cpu-chip": {
	    name:       "cpu-chip"
	    "@type":    {Component: true, Schedulable: true, Auditable: true}
	    depends_on: {"silicon-wafer": true}
	}
	```

	This resource exists simultaneously in three contexts:
	- **Component** context: part of a supply chain BOM
	- **Schedulable** context: subject to critical path analysis
	- **Auditable** context: subject to compliance checks

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

	A resource with `{LXCContainer: true, DNSServer: true}` matches Proxmox
	(serves LXCContainer) AND PowerDNS (serves DNSServer) simultaneously. The
	binding is set intersection, not registration.

	### Unification Guarantees Consistency

	If two contexts place conflicting constraints on the same resource, CUE
	unification produces bottom (`_|_`). The graph cannot be constructed. This
	is not a runtime error — it is a type error caught before any output is
	generated.

	## Evidence: Multiple Projections From One Graph

	The same 5-node supply chain graph (defined once) produces output in
	\(evidence.spec_counts.total) different W3C specifications. Each projection
	selects a different context:

	**Scheduling context** (OWL-Time):

	```json
	\(_json.time_entry)
	```

	**Compliance context** (SHACL):

	```json
	\(_json.shacl)
	```

	**Provenance context** (PROV-O):

	```json
	\(_json.prov_entity)
	```

	**Access control context** (ODRL):

	```json
	\(_json.odrl)
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
	| IT infrastructure | 30 nodes | 2-4 types per resource |
	| University curricula | 12 courses | Department + prerequisite + scheduling |
	| Construction PM | 18 work packages | Phase + gate + compliance |
	| Supply chain | 14 parts | Tier + BOM + scheduling |

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
	"""
