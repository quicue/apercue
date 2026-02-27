// SKOS Taxonomy projection — hierarchical type vocabulary from graph structure.
//
// Extends the flat SKOS ConceptScheme from views/skos.cue with:
//   - skos:broader / skos:narrower from declared type hierarchies
//   - skos:related from co-occurrence (types that appear together on resources)
//   - skos:scopeNote from usage statistics
//
// W3C SKOS (Recommendation, 2009-08-18): Simple Knowledge Organization System.
//
// Export: cue export -e taxonomy.taxonomy_scheme --out json

package patterns

import (
	"list"
	"apercue.ca/vocab"
)

// #TypeHierarchy — declares parent-child relationships between types.
//
// Used by #SKOSTaxonomy to produce skos:broader/narrower.
// If omitted, the taxonomy is flat (all types are top concepts).
#TypeHierarchy: {
	// parent type → child types
	[string]: [...string]
}

// #SKOSTaxonomy — Project graph types as a hierarchical SKOS ConceptScheme.
//
// Analyzes a graph to discover:
//   - Which types exist and how many resources have each
//   - Which types co-occur on resources (→ skos:related)
//   - Optional explicit hierarchy (→ skos:broader/narrower)
//
// Usage:
//   taxonomy: patterns.#SKOSTaxonomy & {
//     Graph: myGraph
//     Hierarchy: {
//       "Infrastructure": ["Database", "Application", "LoadBalancer"]
//       "Governance":     ["Policy", "Attestable"]
//     }
//   }
//
#SKOSTaxonomy: {
	Graph: #AnalyzableGraph

	// Optional type hierarchy
	Hierarchy?: #TypeHierarchy

	// Optional metadata
	SchemeTitle?: string
	BaseIRI:      string | *"https://apercue.ca/vocab#"

	_scheme_title: string | *"Type Taxonomy"
	if SchemeTitle != _|_ {
		_scheme_title: SchemeTitle
	}

	// Collect all types and their usage counts
	_type_counts: {
		for _, res in Graph.resources
		for t, _ in res["@type"] {
			(t): true
		}
	}

	_type_usage: {
		for tname, _ in _type_counts {
			(tname): len([
				for _, res in Graph.resources
				if res["@type"][tname] != _|_ {1},
			])
		}
	}

	// Find co-occurring types (types that appear together on a resource)
	_cooccurrence: {
		for _, res in Graph.resources
		for t1, _ in res["@type"]
		for t2, _ in res["@type"]
		if t1 < t2 {
			(t1 + "|" + t2): {
				a: t1
				b: t2
			}
		}
	}

	// Build set of child types (for identifying top concepts)
	_child_types: {
		if Hierarchy != _|_ {
			for _, children in Hierarchy
			for child in children {
				(child): true
			}
		}
	}

	// Build parent lookup
	_parent_of: {
		if Hierarchy != _|_ {
			for parent, children in Hierarchy
			for child in children {
				(child): parent
			}
		}
	}

	// Top concepts: types with no parent
	_top_concepts: {
		for tname, _ in _type_counts
		if _child_types[tname] == _|_ {
			(tname): true
		}
	}

	// Concepts
	_concepts: [
		for tname, _ in _type_counts {
			"@type":          "skos:Concept"
			"@id":            BaseIRI + tname
			"skos:prefLabel": tname
			"skos:inScheme": {"@id": BaseIRI + "TypeTaxonomy"}
			"skos:scopeNote": "\(tname) — used by \(_type_usage[tname]) resources"

			// Top concept?
			if _top_concepts[tname] != _|_ {
				"skos:topConceptOf": {"@id": BaseIRI + "TypeTaxonomy"}
			}

			// broader (parent)
			if _parent_of[tname] != _|_ {
				"skos:broader": {"@id": BaseIRI + _parent_of[tname]}
			}

			// narrower (children)
			if Hierarchy != _|_ if Hierarchy[tname] != _|_ {
				"skos:narrower": [
					for child in Hierarchy[tname] {
						{"@id": BaseIRI + child}
					},
				]
			}

			// related (co-occurring types)
			let _related = list.Concat([[
				for key, pair in _cooccurrence
				if pair.a == tname {pair.b},
			], [
				for key, pair in _cooccurrence
				if pair.b == tname {pair.a},
			]])
			if len(_related) > 0 {
				"skos:related": [
					for r in _related {
						{"@id": BaseIRI + r}
					},
				]
			}
		},
	]

	taxonomy_scheme: {
		"@context": vocab.context["@context"]
		"@type":    "skos:ConceptScheme"
		"@id":      BaseIRI + "TypeTaxonomy"
		"skos:prefLabel": _scheme_title
		"dcterms:title":  _scheme_title
		"skos:hasTopConcept": [
			for tname, _ in _top_concepts {
				{"@id": BaseIRI + tname}
			},
		]
		"apercue:concepts": _concepts
	}

	summary: {
		total_types:    len([for t, _ in _type_counts {t}])
		top_concepts:   len([for t, _ in _top_concepts {t}])
		cooccurrences:  len([for k, _ in _cooccurrence {k}])
		has_hierarchy:  Hierarchy != _|_
	}
}
