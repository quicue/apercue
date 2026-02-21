// PROV-O Provenance Projection — audit trail from source to LLM response.
//
// Traces the chain: authoritative document -> knowledge graph entry -> LLM response.
// Every fact the LLM uses can be traced back to its authoritative source.
//
// Export: cue export ./examples/gc-llm-governance/ -e provenance --out json

package main

import "apercue.ca/vocab@v0"

provenance: {
	"@context": vocab.context["@context"]
	"@type":    "prov:Bundle"
	"@id":      "urn:gc:llm-governance:provenance"
	"@graph": [
		// Agent: the governance framework itself
		{
			"@type":          "prov:Agent"
			"@id":            "urn:gc:agent:governance-framework"
			"dcterms:title":  "GC LLM Governance Framework"
			"prov:actedOnBehalfOf": {"@id": "urn:gc:org:tbs"}
		},
		// Agent: TBS as the delegating organization
		{
			"@type":         "prov:Agent"
			"@id":           "urn:gc:org:tbs"
			"dcterms:title": "Treasury Board of Canada Secretariat"
		},
		// Activity: knowledge graph construction
		{
			"@type":                  "prov:Activity"
			"@id":                    "urn:gc:activity:kg-construction"
			"dcterms:title":          "Knowledge graph construction from authoritative sources"
			"prov:wasAssociatedWith":  {"@id": "urn:gc:agent:governance-framework"}
			"prov:used": [
				for _, src in sources {
					{"@id": "urn:gc:source:" + src.id}
				},
			]
			"prov:generated": [
				for _, fact in facts {
					{"@id": "urn:gc:fact:" + fact.id}
				},
			]
		},
		// Entities: each authoritative source
		for _, src in sources {
			"@type":         "prov:Entity"
			"@id":           "urn:gc:source:" + src.id
			"dcterms:title": src.title
			"prov:wasAttributedTo": {"@id": "urn:gc:org:tbs"}
		},
		// Entities: each policy fact (derived from sources)
		for _, fact in facts {
			"@type":         "prov:Entity"
			"@id":           "urn:gc:fact:" + fact.id
			"dcterms:title": fact.claim
			"prov:wasDerivedFrom":  {"@id": "urn:gc:source:" + fact.source}
			"prov:wasGeneratedBy":  {"@id": "urn:gc:activity:kg-construction"}
			"prov:wasAttributedTo": {"@id": "urn:gc:agent:governance-framework"}
		},
		// Activity: LLM response generation (template)
		{
			"@type":                  "prov:Activity"
			"@id":                    "urn:gc:activity:llm-response-template"
			"dcterms:title":          "LLM response generation (constrained by knowledge graph)"
			"prov:wasAssociatedWith":  {"@id": "urn:gc:agent:governance-framework"}
			"dcterms:description":    "Each LLM response traces to specific facts from the knowledge graph, which in turn trace to authoritative source documents"
		},
	]
}
