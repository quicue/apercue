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

p004: core.#Pattern & {
	name:     "input-output-pair-documentation"
	category: "methodology"
	problem:  "Documentation shows CUE input and W3C output in separate places, so readers cannot trace the full pipeline in any single document"
	solution: "Always document projections as paired examples: the CUE resource definition alongside the W3C output it produces via a specific cue export expression. Show the command, the input, and the output together."
	context:  "Any CUE module that produces W3C projections and needs to be understood by new readers"
	example:  "Show a 3-resource graph, then the SHACL report it produces, in the same README section"
	used_in: {"apercue.ca": true}
}

p005: core.#Pattern & {
	name:     "w3c-coverage-table-as-projection"
	category: "architecture"
	problem:  "W3C coverage tables in README, spec, and w3c/README.md drift out of sync as new projections are added"
	solution: "Define W3C spec coverage as structured CUE data (vocab/specs-registry.cue). Generate README tables, spec tables, and w3c/README.md from the same source via cue export."
	context:  "Any project with multiple documentation surfaces that report the same W3C compliance data"
	example:  "cue export ./vocab/ -e specs_table --out text produces the Markdown table for README insertion"
	used_in: {"apercue.ca": true}
}
