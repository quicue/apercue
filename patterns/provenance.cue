// Provenance projection — W3C PROV-O from dependency graphs.
//
// Maps resources to prov:Entity with derivation chains from depends_on edges.
// The graph construction itself becomes a prov:Activity.
//
// W3C PROV-O (Recommendation, 2013-04-30): provenance interchange.
//
// Export: cue export -e provenance.prov_report --out json

package patterns

import "apercue.ca/vocab"

// #ProvenanceTrace — Project a dependency graph as a PROV-O provenance record.
//
// Each resource → prov:Entity.
// Each depends_on edge → prov:wasDerivedFrom.
// The graph → prov:Activity that generated all entities.
#ProvenanceTrace: {
	Graph: #AnalyzableGraph

	// Optional: who/what constructed the graph
	Agent?: string

	_agent_id: string | *"apercue:graph-engine"
	if Agent != _|_ {
		_agent_id: Agent
	}

	prov_report: {
		"@context": vocab.context["@context"]
		"@graph": [
			// Each resource as a prov:Entity
			for name, res in Graph.resources {
				"@type":         "prov:Entity"
				"@id":           "urn:resource:" + name
				"dcterms:title": name
				if res.depends_on != _|_ {
					"prov:wasDerivedFrom": [
						for dep, _ in res.depends_on {
							{"@id": "urn:resource:" + dep}
						},
					]
				}
				"prov:wasAttributedTo": {"@id": _agent_id}
				"prov:wasGeneratedBy": {"@id": "apercue:graph-construction"}
			},

			// The graph construction activity
			{
				"@type":         "prov:Activity"
				"@id":           "apercue:graph-construction"
				"dcterms:title": "Graph construction"
				"prov:wasAssociatedWith": {"@id": _agent_id}
				"prov:generated": [
					for name, _ in Graph.resources {
						{"@id": "urn:resource:" + name}
					},
				]
			},

			// The agent
			{
				"@type": "prov:Agent"
				"@id":   _agent_id
			},
		]
	}
}
