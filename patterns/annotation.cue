// Web Annotation projection — annotate graph resources with structured notes.
//
// Maps user-provided annotations to W3C Web Annotation model (oa:Annotation).
// Annotations can target specific resources with bodies that carry motivation,
// text content, and structured tags.
//
// Use cases:
//   - Quality review comments on specific resources
//   - Compliance notes linking rules to evidence
//   - Risk flags on critical path nodes
//   - Human-in-the-loop review markers
//
// W3C Web Annotation Data Model (Recommendation, 2017-02-23):
// Uses: oa:Annotation, oa:TextualBody, oa:SpecificResource, oa:Motivation
//
// Export: cue export -e annotations.annotation_collection --out json

package patterns

import "apercue.ca/vocab"

// #AnnotationMotivation — W3C-defined annotation purposes.
#AnnotationMotivation:
	"oa:assessing" |
	"oa:bookmarking" |
	"oa:classifying" |
	"oa:commenting" |
	"oa:describing" |
	"oa:editing" |
	"oa:highlighting" |
	"oa:identifying" |
	"oa:linking" |
	"oa:moderating" |
	"oa:questioning" |
	"oa:replying" |
	"oa:tagging"

// #ResourceAnnotation — a single annotation on a graph resource.
#ResourceAnnotation: {
	target:     string                          // resource name
	body:       string                          // annotation text
	motivation: #AnnotationMotivation | *"oa:commenting"
	creator?:   string                          // who created the annotation
	tags?: [...string]                          // optional classification tags
}

// #AnnotationCollection — Project annotations on graph resources as Web Annotations.
//
// Input: a graph and a list of annotations targeting resources by name.
// Output: oa:Annotation entries in an as:OrderedCollection.
//
// Each annotation validates that its target exists in the graph (CUE
// constraint: if the target resource doesn't exist, eval fails).
#AnnotationCollection: {
	Graph: #AnalyzableGraph

	// Annotations to project
	Annotations: [...#ResourceAnnotation]

	// Collection metadata
	CollectionLabel: string | *"Graph Annotations"

	// Validate all targets exist in the graph
	_target_check: {
		for a in Annotations {
			(a.target): Graph.resources[a.target].name
		}
	}

	annotation_collection: {
		"@context": [
			"http://www.w3.org/ns/anno.jsonld",
			vocab.context["@context"],
		]
		"type":       "AnnotationCollection"
		"label":      CollectionLabel
		"total":      len(Annotations)

		"items": [
			for i, a in Annotations {
				"type":       "Annotation"
				"motivation": a.motivation

				"body": {
					"type":   "TextualBody"
					"value":  a.body
					"format": "text/plain"
					if a.tags != _|_ if len(a.tags) > 0 {
						"purpose": "tagging"
					}
				}

				"target": {
					"type":   "SpecificResource"
					"source": "urn:resource:" + a.target
				}

				if a.creator != _|_ {
					"creator": {
						"type": "Person"
						"name": a.creator
					}
				}

				if a.tags != _|_ if len(a.tags) > 0 {
					"bodyValue": a.tags
				}
			},
		]
	}

	summary: {
		total:       len(Annotations)
		by_motivation: {
			for a in Annotations {
				(a.motivation): (*by_motivation[a.motivation] | 0) + 1
			}
		}
	}
}
