// ORG projection — W3C Organization Ontology from dependency graphs.
//
// Groups resources by @type into org:OrganizationalUnit.
// The graph itself becomes an org:Organization.
//
// W3C ORG (Recommendation, 2014-01-16): organizational structures.
//
// Usage:
//   import "apercue.ca/views@v0"
//   structure: views.#OrgStructure & {Graph: myGraph}
//   // Export: cue export -e structure.org_report --out json

package views

import "apercue.ca/vocab@v0"

// #OrgStructure — Project a typed graph as a W3C Organization hierarchy.
//
// Each @type becomes an org:OrganizationalUnit.
// Resources become org:hasMember of their type's unit.
// The graph is the org:Organization.
#OrgStructure: {
	Graph: {
		resources: [string]: {
			name:    string
			"@type": {[string]: true}
			...
		}
		...
	}
	OrgName: string | *"Graph Organization"
	BaseIRI: string | *"https://apercue.ca/org#"

	// Collect all unique types across all resources
	_types: {
		for _, res in Graph.resources {
			for t, _ in res["@type"] {
				(t): true
			}
		}
	}

	org_report: {
		"@context": vocab.context["@context"]
		"@type":    "org:Organization"
		"@id":      BaseIRI + "org"
		"skos:prefLabel": OrgName

		"org:hasUnit": [
			for typeName, _ in _types {
				"@type":          "org:OrganizationalUnit"
				"@id":            BaseIRI + "unit/" + typeName
				"skos:prefLabel": typeName
				"org:hasMember": [
					for resName, res in Graph.resources if res["@type"][typeName] != _|_ {
						"@id":            "urn:resource:" + resName
						"dcterms:title":  resName
					},
				]
			},
		]
	}
}
