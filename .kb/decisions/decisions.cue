// Architecture decisions for apercue.ca
package decisions

import "quicue.ca/kg/core@v0"

d001: core.#Decision & {
	id:        "ADR-001"
	title:     "Domain-agnostic graph engine extracted from quicue.ca"
	status:    "accepted"
	date:      "2026-02-19"
	context:   "quicue.ca's #InfraGraph and analysis patterns work for any domain, not just infrastructure. The 'Infra' prefix creates a false impression that the patterns are infrastructure-specific."
	decision:  "Extract generic patterns into apercue.ca as #Graph (renamed from #InfraGraph). Strip all infrastructure-specific fields (ip, fqdn, host, container_id, vm_id, ssh_user, hosted_on, actions, provides). Keep the core: name, @type, depends_on, description."
	rationale: "The dependency graph engine, CPM analysis, compliance checking, and W3C projections are domain-agnostic. Proving this with non-infrastructure examples (courses, recipes, supply chains) strengthens the theoretical contribution."
	consequences: [
		"apercue.ca has no infrastructure vocabulary — #TypeNames is unconstrained",
		"quicue.ca imports apercue.ca for generic patterns, adds infra-specific layers",
		"Four non-infrastructure examples prove the generality claim",
	]
	appliesTo: [{"@id": "https://apercue.ca/project/apercue"}]
}

d002: core.#Decision & {
	id:        "ADR-002"
	title:     "W3C artifacts as zero-cost projections, not separate processors"
	status:    "accepted"
	date:      "2026-02-19"
	context:   "Traditional semantic web requires separate tools for each concern: triplestore for storage, SPARQL for queries, SHACL processor for validation, serializer for JSON-LD. Each adds infrastructure and failure modes."
	decision:  "Implement W3C artifacts (SHACL ValidationReport, SKOS ConceptScheme, OWL-Time Interval, EARL Assertion) as CUE comprehensions that project from the same typed graph. No runtime infrastructure required."
	rationale: "CUE comprehensions are evaluated at constraint resolution time. A comprehension that produces sh:ValidationReport is structurally identical to a SHACL processor's output but requires zero additional infrastructure. The same graph, different -e expression."
	consequences: [
		"Every W3C artifact is a cue export expression, not a separate service",
		"Validation happens at cue vet time, not at runtime",
		"Limited to closed-world, schema-controlled DAGs (not open-world RDF reasoning)",
	]
	appliesTo: [{"@id": "https://apercue.ca/project/apercue"}]
}

d003: core.#Decision & {
	id:        "ADR-003"
	title:     "Comprehension-level filtering for list comprehensions"
	status:    "accepted"
	date:      "2026-02-19"
	context:   "CUE list comprehensions with body-level if statements produce empty structs {} instead of filtering elements. This caused bugs in #ComplianceCheck where violation lists contained {} entries without resource/check fields."
	decision:  "Always use comprehension-level if (before the body {}) for filtering. Use comprehension-level let for computed values that feed into filters. Never use body-level if to control element inclusion."
	rationale: "In CUE, if inside a body {} conditionally includes fields, not elements. When false, it produces {} (empty struct). Comprehension-level if controls whether an element is emitted at all."
	consequences: [
		"All list comprehensions in patterns/ use comprehension-level if/let",
		"#ComplianceCheck _v1, _v2, _v5 checks restructured",
		"Pattern documented as a gotcha for future CUE development",
	]
	appliesTo: [
		{"@id": "https://apercue.ca/project/apercue"},
		{"@id": "https://quicue.ca/project/quicue-ca"},
	]
}

d004: core.#Decision & {
	id:        "ADR-004"
	title:     "ASCII-safe identifiers prevent zero-width unicode injection"
	status:    "accepted"
	date:      "2026-02-19"
	context:   "Graph identifiers (resource names, type labels) are used in CUE field names, JSON keys, and HTML rendering. Zero-width unicode characters could create visually identical but structurally different identifiers, enabling injection attacks or data corruption."
	decision:  "Enforce _#SafeID (^[a-zA-Z][a-zA-Z0-9_.-]*$) and _#SafeLabel (^[a-zA-Z][a-zA-Z0-9_-]*$) constraints on all graph surfaces. CI validates with unicode rejection test fixtures."
	rationale: "Compile-time prevention is cheaper than runtime detection. CUE regex constraints make invalid identifiers impossible to construct."
	consequences: [
		"All resource names, type labels, and dependency keys are ASCII-only",
		"Unicode rejection tests in CI verify the constraints catch violations",
		"Legitimate unicode use cases (i18n labels) go in description, not name",
	]
	appliesTo: [{"@id": "https://apercue.ca/project/apercue"}]
}

d005: core.#Decision & {
	id:        "ADR-005"
	title:     "Remove dead W3C namespace prefixes from @context"
	status:    "accepted"
	date:      "2026-02-20"
	context:   "The JSON-LD @context registered ODRL, OA, AS, Hydra, and DCAT namespace prefixes from an earlier design phase. None were used in any apercue projection or schema."
	decision:  "Remove all namespace prefixes that have no corresponding CUE comprehension producing output in that vocabulary. Keep only prefixes with active projections (SHACL, SKOS, OWL-Time, EARL, Dublin Core, Schema.org)."
	rationale: "Dead prefixes create false expectations of vocabulary support. JSON-LD contexts should be minimal and honest about what the system actually produces."
	consequences: [
		"@context reduced from 14 to 9 namespace prefixes",
		"PROV-O and DCAT retained as downstream (quicue.ca uses them)",
		"Any future vocabulary additions require an active projection pattern",
	]
	appliesTo: [{"@id": "https://apercue.ca/project/apercue"}]
}

d006: core.#Decision & {
	id:        "ADR-006"
	title:     "_planned status field for charter gap analysis filtering"
	status:    "accepted"
	date:      "2026-02-20"
	context:   "Charter tasks need to exist in the graph for visualization positioning, but planned (future) tasks should not satisfy gap analysis gates. Without a status field, all tasks in the graph appear complete."
	decision:  "Add _planned: bool | *false to charter tasks. Gap analysis filters to _completed_resources (where !_planned). Planned tasks appear in the graph visualization with dashed styling but don't close gates."
	rationale: "The graph topology is shared between visualization and analysis. Removing planned tasks from the graph would lose their dependency edges and depth. Filtering at the gap analysis level keeps the topology intact while correctly computing remaining work."
	consequences: [
		"Planned tasks visible in charter visualization with distinct styling",
		"Gap analysis correctly reports unsatisfied gates for planned work",
		"Completing a task = removing _planned: true, not adding new data",
	]
	appliesTo: [{"@id": "https://apercue.ca/project/apercue"}]
}

d007: core.#Decision & {
	id:        "ADR-007"
	title:     "#AnalyzableGraph interface + precomputed CPM"
	status:    "accepted"
	date:      "2026-02-20"
	context:   "#CriticalPath and analysis patterns required Graph: #Graph, forcing _path computation even with #GraphLite precomputation. CUE's recursive fixpoint for CPM forward/backward passes timed out on 38 nodes."
	decision:  "Introduce #AnalyzableGraph — minimal interface without _path requirement. Both #Graph and #GraphLite satisfy it. Precompute CPM scheduling in Python (O(V+E)). #CriticalPathPrecomputed consumes static data."
	rationale: "One graph, many lenses. The precomputed closure contains all the information; projections are cheap struct comprehensions. CUE validates schemas and produces output shapes, Python handles O(V+E) graph algorithms."
	consequences: [
		"All analysis patterns accept #AnalyzableGraph (only #DependencyChain, #ExportGraph, #VizData still need #Graph)",
		"Unified projections export: 46ms for SHACL + OWL-Time + CPM on 38 nodes",
		"Python toposort.py computes graph closure + CPM in one pass",
	]
	appliesTo: [{"@id": "https://apercue.ca/project/apercue"}]
}

d008: core.#Decision & {
	id:        "ADR-008"
	title:     "Public/private site split — operational data stays on grdn"
	status:    "accepted"
	date:      "2026-02-20"
	context:   "Charter visualization and ecosystem graphs contain real operational data: task completion status, CPM scheduling, gate satisfaction. Publishing this to the public apercue.ca site exposes internal project tracking to the internet."
	decision:  "Split build-site.sh into public (landing, spec, vocab, examples) and private (charter, ecosystem, projections) targets. CI deploys only public content to Cloudflare Pages. Private data is served from grdn network via deploy-local.sh."
	rationale: "The spec and examples are the public interface — they demonstrate capability. Charter progress and scheduling data are operational intelligence that belongs on the infrastructure owner's own network."
	consequences: [
		"Cloudflare Pages serves only generic documentation",
		"Charter, ecosystem, and projections dashboards are local-only",
		"deploy-local.sh handles full build + optional rsync to grdn target",
		"CI workflow simplified — no Python needed for public deploy",
	]
	appliesTo: [{"@id": "https://apercue.ca/project/apercue"}]
}
