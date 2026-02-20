// apercue.ca knowledge base manifest
//
// Declares this repo's knowledge topology: which semantic graphs
// it maintains, what types they contain, and which W3C vocabularies
// they map to. The directory structure IS the ontology.
package kb

import "quicue.ca/kg/ext@v0"

_project: ext.#Context & {
	"@id":       "https://apercue.ca/project/apercue"
	name:        "apercue.ca"
	description: "Compile-time W3C linked data from typed dependency graphs"
	module:      "apercue.ca@v0"
	repo:        "https://github.com/quicue/apercue"
	license:     "Apache-2.0"
	status:      "active"
	cue_version: "v0.15.4"
	uses: [
		{"@id": "https://quicue.ca/pattern/struct-as-set"},
		{"@id": "https://quicue.ca/pattern/compile-time-binding"},
		{"@id": "https://quicue.ca/pattern/zero-cost-projection"},
	]
	knows: [
		{"@id": "https://quicue.ca/concept/cue-unification"},
		{"@id": "https://quicue.ca/concept/json-ld"},
		{"@id": "https://quicue.ca/concept/dependency-graph"},
		{"@id": "https://quicue.ca/concept/shacl"},
		{"@id": "https://quicue.ca/concept/skos"},
		{"@id": "https://quicue.ca/concept/owl-time"},
	]
}

kb: ext.#KnowledgeBase & {
	context: _project
	graphs: {
		decisions: ext.#DecisionsGraph
		patterns:  ext.#PatternsGraph
		insights:  ext.#InsightsGraph
		rejected:  ext.#RejectedGraph
	}
}
