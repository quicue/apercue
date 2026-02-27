// DCAT 3 projection — typed dependency graph as a data catalog.
//
// Projects the graph as a dcat:Catalog where each resource is a dcat:Dataset.
// Dependencies become dcterms:requires links. Resource types map to dcat:theme
// via SKOS concepts from the type vocabulary.
//
// W3C DCAT 3 (Recommendation, 2024-08-22): data catalog vocabulary.
//
// Export: cue export -e catalog.dcat_catalog --out json

package patterns

import "apercue.ca/vocab"

// #DCATDistribution — describes how a dataset can be accessed.
//
// DCAT 3 requires distributions to specify access method and format.
// Commonly used with #DCATCatalog to describe export formats.
#DCATDistribution: {
	mediaType:  string           // IANA media type (e.g. "application/ld+json")
	format?:    string           // human-readable format name
	accessURL?: string           // URL to access the distribution
	title?:     string           // human-readable title
	conformsTo?: string          // spec URL this distribution conforms to
}

// #DCATCatalog — Project a dependency graph as a DCAT 3 data catalog.
//
// Each resource → dcat:Dataset with title, description, themes from @type.
// The graph itself → dcat:Catalog containing all datasets.
// Dependencies → dcterms:requires (already in the shared @context).
//
// Optional: Distributions specify how each dataset can be accessed.
// Optional: DataService describes the export API.
#DCATCatalog: {
	Graph: #AnalyzableGraph

	// Optional catalog metadata
	Title?:       string
	Description?: string
	Publisher?:    string
	License?:     string  // SPDX or URL

	// Optional distributions applied to all datasets
	Distributions?: [...#DCATDistribution]

	// Optional data service (API endpoint)
	ServiceEndpoint?: string
	ServiceTitle?:    string

	_title: string | *"Resource Catalog"
	if Title != _|_ {
		_title: Title
	}

	_description: string | *"DCAT catalog projected from a typed dependency graph"
	if Description != _|_ {
		_description: Description
	}

	dcat_catalog: {
		"@context": vocab.context["@context"]
		"@type":    "dcat:Catalog"
		"dcterms:title":       _title
		"dcterms:description": _description
		if Publisher != _|_ {
			"dcterms:publisher": {"@id": Publisher}
		}
		if License != _|_ {
			"dcterms:license": {"@id": License}
		}

		// Data service: describes how to access the catalog programmatically
		if ServiceEndpoint != _|_ {
			"dcat:service": {
				"@type": "dcat:DataService"
				"dcterms:title": *ServiceTitle | "Graph Export API"
				"dcat:endpointURL": ServiceEndpoint
				"dcat:servesDataset": [
					for name, _ in Graph.resources {
						{"@id": "urn:resource:" + name}
					},
				]
			}
		}

		"dcat:dataset": [
			for name, res in Graph.resources {
				"@type":         "dcat:Dataset"
				"@id":           "urn:resource:" + name
				"dcterms:title": name
				if res.description != _|_ {
					"dcterms:description": res.description
				}

				// Map @type labels to dcat:theme as SKOS concepts
				"dcat:theme": [
					for t, _ in res["@type"] {
						{
							"@type":          "skos:Concept"
							"skos:prefLabel": t
						}
					},
				]

				// Dependencies as dcterms:requires links
				if res.depends_on != _|_ {
					"dcterms:requires": [
						for dep, _ in res.depends_on {
							{"@id": "urn:resource:" + dep}
						},
					]
				}

				// Distributions: how to access this dataset
				if Distributions != _|_ {
					"dcat:distribution": [
						for dist in Distributions {
							"@type":          "dcat:Distribution"
							"dcat:mediaType": dist.mediaType
							if dist.format != _|_ {
								"dcterms:format": dist.format
							}
							if dist.accessURL != _|_ {
								"dcat:accessURL": {"@id": dist.accessURL}
							}
							if dist.title != _|_ {
								"dcterms:title": dist.title
							}
							if dist.conformsTo != _|_ {
								"dcterms:conformsTo": {"@id": dist.conformsTo}
							}
						},
					]
				}
			},
		]
	}
}
