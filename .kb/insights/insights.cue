// Insights discovered during apercue.ca development
package insights

import "quicue.ca/kg/core@v0"

i001: core.#Insight & {
	id:         "INSIGHT-001"
	statement:  "CUE unification subsumes both SPARQL graph pattern matching and SHACL shape validation into a single evaluation model"
	evidence: [
		"Comprehension 'for r in resources if r._ancestors[target] != _|_' is equivalent to a SPARQL property path query",
		"Definition '#Resource & {name: string}' is equivalent to a SHACL NodeShape constraint",
		"Both resolve at cue eval time without runtime processors",
	]
	method:     "cross_reference"
	confidence: "high"
	discovered: "2026-02-19"
	implication: "A single CUE module can replace three separate runtime components (triplestore, SPARQL endpoint, SHACL validator) for closed-world dependency graphs"
}

i002: core.#Insight & {
	id:         "INSIGHT-002"
	statement:  "The charter pattern makes project completion a compile-time structural property rather than a judgment call"
	evidence: [
		"When cue vet passes and gaps.complete == true, the charter is provably satisfied",
		"The gap between declared constraints and actual data IS the remaining work, computed automatically",
		"Four examples (courses, recipes, projects, supply chains) all use the same gap analysis",
	]
	method:     "experiment"
	confidence: "high"
	discovered: "2026-02-19"
	implication: "Project planning can be expressed as CUE constraints where 'done' is a boolean computed from structural properties, not a human assessment"
}

i003: core.#Insight & {
	id:         "INSIGHT-003"
	statement:  "Non-infrastructure examples are the strongest proof that the dependency graph pattern is domain-agnostic"
	evidence: [
		"Course prerequisites, recipe ingredients, supply chains, and project tasks all use the same #Graph engine",
		"#CriticalPath computes valid CPM for credit-weighted courses and cook-time-weighted recipe steps",
		"#ComplianceCheck produces valid SHACL reports for courses ('core needs prereqs') and supply chains ('assemblies need components')",
	]
	method:     "experiment"
	confidence: "high"
	discovered: "2026-02-19"
	implication: "The 'Infra' prefix on quicue.ca patterns was limiting adoption perception — removing it and proving generality with diverse examples strengthens the theoretical contribution"
}
