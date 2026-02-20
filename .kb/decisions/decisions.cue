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
