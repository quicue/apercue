// A 2-node graph against a charter that wants 3 resources and a gate that
// requires a resource not in the graph.
// report-only: cue vet must pass and the report must list both problems.
// enforce:     cue vet must fail.
package test

import (
	"apercue.ca/patterns@v0"
	"apercue.ca/charter@v0"
)

_g: patterns.#Graph & {Input: {
	a: {name: "a", "@type": {Dataset: true}}
	b: {name: "b", "@type": {Process: true}, depends_on: {a: true}}
}}

gaps: charter.#GapAnalysis & {
	Graph:   _g
	Enforce: true
	Charter: {
		name: "incomplete"
		scope: total_resources: 3
		gates: release: requires: {a: true, "ethics-approval": true}
	}
}
