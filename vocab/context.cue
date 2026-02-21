// JSON-LD context for typed dependency graphs.
//
// Maps CUE field names to semantic IRIs. Domain modules extend
// this with their own type-to-IRI mappings.
//
// Export: cue export ./vocab -e context --out json > context.jsonld

package vocab

// context — JSON-LD @context template with W3C namespace prefixes.
context: {
	"@context": {
		// Base URI — override for your domain
		"@base": "urn:resource:"

		// W3C namespace prefixes
		"dcterms": "http://purl.org/dc/terms/"
		"prov":    "http://www.w3.org/ns/prov#"
		"dcat":    "http://www.w3.org/ns/dcat#"
		"sh":      "http://www.w3.org/ns/shacl#"
		"skos":    "http://www.w3.org/2004/02/skos/core#"
		"schema":  "https://schema.org/"
		"time":    "http://www.w3.org/2006/time#"
		"earl":    "http://www.w3.org/ns/earl#"
		"odrl":    "http://www.w3.org/ns/odrl/2/"
		"org":     "http://www.w3.org/ns/org#"
		"cred":    "https://www.w3.org/2018/credentials#"
		"as":      "https://www.w3.org/ns/activitystreams#"
		"apercue": "https://apercue.ca/vocab#"
		"charter": "https://apercue.ca/charter#"

		// Resource fields — use Dublin Core for universal interoperability
		"name":        "dcterms:title"
		"description": "dcterms:description"

		// Relationships
		"depends_on": {
			"@id":   "dcterms:requires"
			"@type": "@id"
		}

		// Lifecycle
		"status": {
			"@id":   "schema:actionStatus"
			"@type": "@id"
		}

		// Set containers
		"tags": {
			"@id":        "dcterms:subject"
			"@container": "@set"
		}
	}
}
