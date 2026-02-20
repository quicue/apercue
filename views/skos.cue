// SKOS Vocabulary View — type registry as a ConceptScheme.
//
// Maps each type in #TypeRegistry to a skos:Concept.
// The full registry becomes a skos:ConceptScheme.
//
// W3C SKOS (Recommendation, 2009-08-18): Simple Knowledge Organization System.
//
// Usage:
//   import "apercue.ca/views@v0"
//   scheme: views.#TypeVocabulary & {Registry: myTypes}
//   // Export: cue export -e scheme.concept_scheme --out json

package views

import "apercue.ca/vocab@v0"

// #TypeVocabulary — Project a type registry as a SKOS ConceptScheme.
#TypeVocabulary: {
	Registry: vocab.#TypeRegistry
	BaseIRI:  string | *"https://apercue.ca/vocab#"

	concept_scheme: {
		"@type":          "skos:ConceptScheme"
		"@id":            BaseIRI + "TypeVocabulary"
		"skos:prefLabel": "Type Vocabulary"
		"skos:hasTopConcept": [
			for name, entry in Registry {
				"@type":           "skos:Concept"
				"@id":             BaseIRI + name
				"skos:prefLabel":  name
				"skos:definition": entry.description
			},
		]
	}
}
