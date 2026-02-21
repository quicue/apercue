// Schema.org alignment — map graph resource types to schema.org vocabulary.
//
// Adds schema:additionalType annotations to resources based on a configurable
// type mapping. Produces JSON-LD consumable by Google Rich Results and
// other schema.org processors.
//
// schema.org (W3C Community Group, ongoing): structured data vocabulary.
//
// Export: cue export -e schema_view.schema_graph --out json

package patterns

import "apercue.ca/vocab"

// #SchemaOrgAlignment — Project a dependency graph with schema.org type annotations.
//
// Provide a TypeMap of {graphType: "schema:SchemaOrgType"} to control the mapping.
// Resources without a mapped type get schema:Thing as fallback.
#SchemaOrgAlignment: {
	Graph: #AnalyzableGraph

	// User-provided mapping: graph @type key → schema.org type IRI
	TypeMap: {[string]: string}

	// Fallback for unmapped types
	Fallback: string | *"schema:Thing"

	schema_graph: {
		"@context": vocab.context["@context"] & {
			"schema:additionalType": {"@id": "schema:additionalType", "@type": "@id"}
		}
		"@graph": [
			for name, res in Graph.resources {
				"@type":         res["@type"]
				"@id":           "urn:resource:" + name
				"dcterms:title": name
				if res.description != _|_ {
					"dcterms:description": res.description
				}

				// Map each graph type to schema.org
				let _mapped = [
					for t, _ in res["@type"] if TypeMap[t] != _|_ {TypeMap[t]},
				]
				"schema:additionalType": [
					if len(_mapped) > 0 for m in _mapped {m},
					if len(_mapped) == 0 {Fallback},
				]

				// Dependencies as schema.org isPartOf (closest generic relation)
				if res.depends_on != _|_ {
					"schema:isPartOf": [
						for dep, _ in res.depends_on {
							{"@id": "urn:resource:" + dep}
						},
					]
				}
			},
		]
	}
}
