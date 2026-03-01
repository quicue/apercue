// RDFS/OWL Ontology generation — formal vocabulary from graph types.
//
// Extracts the implicit ontology from a typed dependency graph:
// - Each @type becomes an rdfs:Class (with owl:Class annotation)
// - The depends_on relation becomes an owl:ObjectProperty
// - Optional hierarchy produces rdfs:subClassOf
//
// This turns the graph's implicit schema into a formal OWL ontology
// that can be loaded into Protégé, validated by OWL reasoners, or
// published as a standalone vocabulary.
//
// W3C RDFS (Recommendation, 2014-02-25): RDF Schema vocabulary
// W3C OWL 2 (Recommendation, 2012-12-11): Web Ontology Language
//
// Export: cue export -e ontology.owl_ontology --out json

package patterns

import (
	"list"
	"apercue.ca/vocab"
)

// #OntologySpec — optional ontology metadata.
#OntologySpec: {
	URI:          string | *"https://apercue.ca/ontology#"
	Title?:       string
	Description?: string
	Version?:     string
}

// #OWLOntology — Generate an OWL ontology from a typed dependency graph.
//
// Analyzes the graph to extract:
// - Classes: every distinct @type value
// - Properties: depends_on as owl:ObjectProperty
// - Class hierarchy: from optional Hierarchy input (parent → children list)
// - Individuals: optionally include resources as owl:NamedIndividual
#OWLOntology: {
	Graph: #AnalyzableGraph

	// Ontology metadata
	Spec: #OntologySpec | *{URI: "https://apercue.ca/ontology#"}

	// Optional type hierarchy (parent → children)
	Hierarchy?: {[string]: [...string]}

	// Whether to include resources as owl:NamedIndividual
	IncludeIndividuals: bool | *false

	// ── Computed ─────────────────────────────────────────────────

	// Collect all types from graph resources
	_all_types: {
		for _, res in Graph.resources {
			for t, _ in res["@type"] {
				(t): true
			}
		}
	}

	// Reverse hierarchy: child type → parent type
	_parent_of: {
		if Hierarchy != _|_ {
			for parent, children in Hierarchy {
				for _, child in children {
					(child): parent
				}
			}
		}
	}

	// Hierarchy parent types not already in _all_types
	_hierarchy_only_parents: {
		if Hierarchy != _|_ {
			for parent, _ in Hierarchy
			if _all_types[parent] == _|_ {
				(parent): true
			}
		}
	}

	// All classes to emit (graph types + hierarchy-only parents)
	_all_classes: _all_types & {}
	_all_classes: _hierarchy_only_parents & {}

	// ── OWL JSON-LD output ───────────────────────────────────────

	// Ontology metadata node (goes inside @graph)
	_ontology_node: {
		"@type": "owl:Ontology"
		"@id":   Spec.URI
		if Spec.Title != _|_ {
			"dcterms:title": Spec.Title
		}
		if Spec.Description != _|_ {
			"dcterms:description": Spec.Description
		}
		if Spec.Version != _|_ {
			"owl:versionInfo": Spec.Version
		}
	}

	owl_ontology: {
		"@context": vocab.context["@context"]

		"@graph": list.Concat([
			// Ontology metadata
			[_ontology_node],

			// Classes from graph types
			[
				for t, _ in _all_types {
					"@type":       ["rdfs:Class", "owl:Class"]
					"@id":         Spec.URI + t
					"rdfs:label":  t
					if _parent_of[t] != _|_ {
						"rdfs:subClassOf": {"@id": Spec.URI + _parent_of[t]}
					}
				},
			],

			// Hierarchy-only parent classes (not in graph as @type)
			[
				for parent, _ in _hierarchy_only_parents {
					"@type":       ["rdfs:Class", "owl:Class"]
					"@id":         Spec.URI + parent
					"rdfs:label":  parent
				},
			],

			// The depends_on property
			[{
				"@type":        "owl:ObjectProperty"
				"@id":          "dcterms:requires"
				"rdfs:label":   "depends on"
				"rdfs:comment": "A resource depends on another resource"
			}],

			// Individuals (optional)
			if IncludeIndividuals {
				[
					for name, res in Graph.resources {
						"@type":       list.Concat([["owl:NamedIndividual"], [for t, _ in res["@type"] {Spec.URI + t}]])
						"@id":         "urn:resource:" + name
						"rdfs:label":  name
						if res.description != _|_ {
							"rdfs:comment": res.description
						}
					},
				]
			},
			if !IncludeIndividuals {[]},
		])
	}

	summary: {
		ontology_uri:  Spec.URI
		classes:       len(_all_types) + len(_hierarchy_only_parents)
		properties:    1 // dcterms:requires
		if IncludeIndividuals {
			individuals: len(Graph.resources)
		}
	}
}
