// VoID (Vocabulary of Interlinked Datasets) — graph self-description.
//
// Every dependency graph IS a dataset. VoID lets the graph describe itself:
// how many resources, how many links, what types appear, what properties
// are used. This is the graph's machine-readable "about" page.
//
// W3C VoID (Interest Group Note, 2011-03-03): dataset descriptions.
// Despite being a Note (not Recommendation), VoID is widely deployed
// in LOD (Linked Open Data) catalogs and SPARQL endpoint descriptions.
//
// Export: cue export -e void_dataset.void_description --out json

package patterns

import "apercue.ca/vocab"

// #VoIDDataset — Project a dependency graph as a VoID dataset description.
//
// Computes: entity count, class (type) partition statistics, property
// usage, link statistics, and vocabulary usage.
//
// The output is valid VoID JSON-LD: a void:Dataset with void:classPartition
// entries for each @type, void:propertyPartition for dependency edges,
// and void:vocabulary for each W3C namespace in use.
#VoIDDataset: {
	Graph: #AnalyzableGraph

	// Dataset metadata
	DatasetURI: string | *"urn:apercue:dataset"
	Title?:     string
	Homepage?:  string

	// Optional: SPARQL endpoint or data dump URL
	SparqlEndpoint?: string
	DataDump?:       string

	// ── Computed statistics ───────────────────────────────────────

	// Total entities (resources)
	_entity_count: len(Graph.resources)

	// Total triples estimate: each resource has @type, @id, name = 3 base
	// + 1 per depends_on edge + 1 if description present
	_triple_count: {
		let _base = _entity_count * 3
		let _deps = len([for _, res in Graph.resources if res.depends_on != _|_ {for _, _ in res.depends_on {1}}])
		let _descs = len([for _, res in Graph.resources if res.description != _|_ {1}])
		_base + _deps + _descs
	}

	// Distinct types used
	_all_types: {
		for _, res in Graph.resources {
			for t, _ in res["@type"] {
				(t): true
			}
		}
	}
	_class_count: len(_all_types)

	// Type partition: count resources per type
	_type_counts: {
		for t, _ in _all_types {
			(t): len([for _, res in Graph.resources if res["@type"][t] != _|_ {1}])
		}
	}

	// Property usage: count how many resources use each property
	_has_depends_on: len([for _, res in Graph.resources if res.depends_on != _|_ {1}])
	_has_description: len([for _, res in Graph.resources if res.description != _|_ {1}])

	// Total dependency links
	_link_count: len([for _, res in Graph.resources if res.depends_on != _|_ {for _, _ in res.depends_on {1}}])

	// ── VoID JSON-LD output ──────────────────────────────────────

	void_description: {
		"@context": vocab.context["@context"]
		"@type":    "void:Dataset"
		"@id":      DatasetURI
		if Title != _|_ {
			"dcterms:title": Title
		}
		if Homepage != _|_ {
			"void:homepage": {"@id": Homepage}
		}
		if SparqlEndpoint != _|_ {
			"void:sparqlEndpoint": {"@id": SparqlEndpoint}
		}
		if DataDump != _|_ {
			"void:dataDump": {"@id": DataDump}
		}

		// Core statistics
		"void:entities":        _entity_count
		"void:triples":         _triple_count
		"void:classes":         _class_count
		"void:distinctSubjects": _entity_count
		"void:properties":      3 // dcterms:title, dcterms:requires, dcterms:description

		// Class partitions — one per @type in the graph
		"void:classPartition": [
			for t, _ in _all_types {
				"@type":           "void:Dataset"
				"void:class":      {"@id": "apercue:" + t}
				"void:entities":   _type_counts[t]
			},
		]

		// Property partitions — usage stats per property
		"void:propertyPartition": [
			{
				"@type":          "void:Dataset"
				"void:property":  {"@id": "dcterms:title"}
				"void:triples":   _entity_count // every resource has a name
			},
			{
				"@type":          "void:Dataset"
				"void:property":  {"@id": "dcterms:requires"}
				"void:triples":   _link_count
			},
			if _has_description > 0 {
				"@type":          "void:Dataset"
				"void:property":  {"@id": "dcterms:description"}
				"void:triples":   _has_description
			},
		]

		// Linkset: dependency edges as explicit linkset
		"void:subset": {
			"@type":             "void:Linkset"
			"void:linkPredicate": {"@id": "dcterms:requires"}
			"void:triples":      _link_count
		}

		// Vocabularies in use
		"void:vocabulary": [
			{"@id": "http://purl.org/dc/terms/"},
			{"@id": "https://apercue.ca/vocab#"},
		]
	}

	summary: {
		entities:     _entity_count
		triples:      _triple_count
		classes:      _class_count
		links:        _link_count
		properties:   3
	}
}
