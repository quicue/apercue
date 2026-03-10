// Form projection — UI form definitions from CUE type metadata.
//
// Generates form field definitions from #TypeRegistry entries.
// Each registered type produces a form with fields derived from
// the type's required constraints and structural dependencies.
//
// This is a UI-facing projection, not a SHACL shapes converter.
// For SHACL shapes, use #SHACLShapes in patterns/shapes.cue.
//
// Export: cue export -e form_defs.form_definitions --out json

package patterns

import (
	"list"
	"apercue.ca/vocab"
)

// #FormField — one field in a generated form.
#FormField: {
	name:       string
	required:   bool
	field_type: "string" | "boolean" | "reference" | "set"
	label:      string
	help_text?: string
}

// #FormProjection — Project type registry entries as form definitions.
//
// Each type in the registry produces a form definition containing:
// - Base #Resource fields (name, description, depends_on, tags)
// - Type-specific required fields (from #TypeEntry.requires)
// - Structural dependency fields (from #TypeEntry.structural_deps)
#FormProjection: {
	Types: vocab.#TypeRegistry

	_base_fields: [...#FormField] & [
		{name: "name", required: true, field_type: "string", label: "Name", help_text: "ASCII identifier: letters, digits, hyphens, dots, underscores"},
		{name: "description", required: false, field_type: "string", label: "Description"},
		{name: "depends_on", required: false, field_type: "set", label: "Dependencies", help_text: "Resources this depends on"},
		{name: "tags", required: false, field_type: "set", label: "Tags"},
	]

	form_definitions: {
		"@context": vocab.context["@context"]
		"@graph": [
			for tname, tentry in Types {
				"@type":         "apercue:FormDefinition"
				"@id":           "urn:form:" + tname
				"dcterms:title": tname
				"dcterms:description": tentry.description
				"apercue:fields": list.Concat([_base_fields, [
					if tentry.requires != _|_ for fname, _ in tentry.requires {
						{name: fname, required: true, field_type: "string", label: fname}
					},
					if tentry.structural_deps != _|_ for _, fname in tentry.structural_deps {
						{name: fname, required: false, field_type: "reference", label: fname, help_text: "Creates a dependency edge"}
					},
				]])
			},
		]
	}

	summary: {
		total_forms: len([for t, _ in Types {t}])
	}
}
