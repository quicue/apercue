// SHACL Shapes projection — generate sh:NodeShape from graph type structure.
//
// Produces SHACL shapes that describe the structure of the typed dependency
// graph. These shapes can be applied to external RDF data to validate it
// against the same structure the CUE graph enforces internally.
//
// This is the "CUE as SHACL preprocessor" pattern: a closed-world graph
// generates shapes for open-world validation.
//
// W3C SHACL (Recommendation, 2017-07-20): shape constraint language.
//
// Export: cue export -e shape_export.shapes_graph --out json

package patterns

import "apercue.ca/vocab"

// #SHACLShapes — Generate SHACL NodeShapes from a typed dependency graph.
//
// For each resource type in the graph, produces a sh:NodeShape with:
//   - sh:targetClass pointing to the type IRI
//   - sh:PropertyShape for required fields (name, @type)
//   - sh:PropertyShape for depends_on relationships
//   - sh:PropertyShape for description (optional)
//
// Usage:
//   shape_export: patterns.#SHACLShapes & {
//     Graph: myGraph
//     Namespace: "https://example.com/shapes#"
//   }
//   // shape_export.shapes_graph — JSON-LD with sh:NodeShape entries
//   // shape_export.shapes — list of individual shapes
//
#SHACLShapes: {
	Graph: #AnalyzableGraph

	// Shape namespace — prefix for shape IRIs
	Namespace: string | *"https://apercue.ca/shapes#"

	// Collect all types used across the graph
	_all_types: {
		for _, res in Graph.resources
		for t, _ in res["@type"] {
			(t): true
		}
	}

	// For each type, find which resources have it and what fields they use
	_type_profiles: {
		for tname, _ in _all_types {
			(tname): {
				// Resources of this type
				_members: {
					for rname, res in Graph.resources
					if res["@type"][tname] != _|_ {
						(rname): res
					}
				}
				count: len([for m, _ in _members {m}])

				// Do any members have depends_on?
				has_dependencies: len([
					for _, res in _members
					if res.depends_on != _|_ {1},
				]) > 0

				// Do any members have description?
				has_description: len([
					for _, res in _members
					if res.description != _|_ {1},
				]) > 0

				// Do any members have tags?
				has_tags: len([
					for _, res in _members
					if res.tags != _|_ {1},
				]) > 0

				// Dependency types: what types do this type's members depend on?
				_dep_types: {
					for _, res in _members
					if res.depends_on != _|_
					for dep, _ in res.depends_on
					if Graph.resources[dep] != _|_
					for dt, _ in Graph.resources[dep]["@type"] {
						(dt): true
					}
				}
			}
		}
	}

	// Generate one sh:NodeShape per type
	shapes: [
		for tname, profile in _type_profiles {
			"@type": "sh:NodeShape"
			"@id":   Namespace + tname + "Shape"
			"sh:targetClass": {"@id": "apercue:" + tname}
			"rdfs:label": tname + " Shape"
			"rdfs:comment": "Structural shape for resources of type " + tname +
				" (derived from " + "\(profile.count)" + " resources)"

			"sh:property": [
				// name is required on all resources
				{
					"@type":       "sh:PropertyShape"
					"sh:path":     {"@id": "dcterms:title"}
					"sh:minCount": 1
					"sh:maxCount": 1
					"sh:datatype": {"@id": "xsd:string"}
					"sh:name":     "name"
				},

				// @type is required
				{
					"@type":       "sh:PropertyShape"
					"sh:path":     {"@id": "rdf:type"}
					"sh:minCount": 1
					"sh:name":     "type"
				},

				// depends_on if any members have it
				if profile.has_dependencies {
					{
						"@type":   "sh:PropertyShape"
						"sh:path": {"@id": "dcterms:requires"}
						"sh:name": "depends_on"
						"sh:nodeKind": {"@id": "sh:IRI"}
					}
				},

				// description if any members have it
				if profile.has_description {
					{
						"@type":       "sh:PropertyShape"
						"sh:path":     {"@id": "dcterms:description"}
						"sh:maxCount": 1
						"sh:datatype": {"@id": "xsd:string"}
						"sh:name":     "description"
					}
				},

				// tags if any members have it
				if profile.has_tags {
					{
						"@type":   "sh:PropertyShape"
						"sh:path": {"@id": "dcterms:subject"}
						"sh:name": "tags"
					}
				},
			]

			// If this type's members depend on specific types, document it
			if len([for dt, _ in profile._dep_types {dt}]) > 0 {
				"apercue:dependsOnTypes": [
					for dt, _ in profile._dep_types {
						{"@id": "apercue:" + dt}
					},
				]
			}
		},
	]

	// Full shapes graph with context
	shapes_graph: {
		"@context": vocab.context["@context"] & {
			"sh":   "http://www.w3.org/ns/shacl#"
			"rdfs": "http://www.w3.org/2000/01/rdf-schema#"
			"xsd":  "http://www.w3.org/2001/XMLSchema#"
			"rdf":  "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
		}
		"@graph": shapes
	}

	// Summary
	summary: {
		total_shapes:      len(shapes)
		total_types:       len([for t, _ in _all_types {t}])
		total_resources:   len([for r, _ in Graph.resources {r}])
		shapes_namespace:  Namespace
	}
}
