// Reusable patterns identified in apercue.ca
package patterns

import "quicue.ca/kg/core@v0"

p001: core.#Pattern & {
	name:     "zero-cost-projection"
	category: "architecture"
	problem:  "W3C artifacts (SHACL, SKOS, OWL-Time) traditionally require separate runtime processors, each adding infrastructure and failure modes"
	solution: "Express each W3C artifact as a CUE comprehension that projects from the same typed graph. Different cue export -e expressions produce different standards-compliant outputs from one data source."
	context:  "Any typed dependency graph where W3C compliance is needed without deploying triplestores, SPARQL endpoints, or SHACL validators"
	example:  "cue export -e compliance.shacl_report --out json produces a valid sh:ValidationReport"
	used_in: {"apercue.ca": true, "quicue.ca": true}
}

p002: core.#Pattern & {
	name:     "charter-as-constraint"
	category: "methodology"
	problem:  "Project completion is typically tracked via external tools (Jira, spreadsheets) disconnected from the actual data model"
	solution: "Declare 'done' as CUE constraints (#Charter with scope, gates, required types). #GapAnalysis computes what's missing. When cue vet passes and gaps.complete == true, the charter is satisfied."
	context:  "Any project where deliverables can be modelled as typed resources in a dependency graph"
	example:  "Charter with 4 gates (first-year → second-year → third-year → graduation) for a CS degree"
	used_in: {"apercue.ca": true, "quicue.ca": true, "cmhc-retrofit": true}
}

p003: core.#Pattern & {
	name:     "comprehension-level-filtering"
	category: "cue-idiom"
	problem:  "CUE list comprehensions with body-level if produce empty structs {} instead of filtering elements, causing downstream field-access errors"
	solution: "Place all filtering if clauses and computed let bindings at comprehension level (before the body {}). Body-level if controls field inclusion, not element inclusion."
	context:  "Any CUE list comprehension where elements should be conditionally included or excluded"
	example:  "[for x in list if cond { field: x }] filters; [for x in list { if cond { field: x } }] does not"
	used_in: {"apercue.ca": true, "quicue.ca": true}
}
