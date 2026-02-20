// Resource — Core typed node in a dependency graph.
//
// A resource is anything with a name, type(s), and optional dependencies.
// Domain-specific fields are added by extending this schema.
//
// Usage:
//   import "apercue.ca/vocab@v0"
//
//   resources: [Name=string]: vocab.#Resource & { name: Name }

package vocab

// #Resource — the universal node type.
// Every node in the graph conforms to this schema.
#Resource: {
	// Identity
	name:   string
	"@id"?: string | *("urn:resource:" + name)

	// Semantic types (struct-as-set for O(1) membership checks)
	"@type": {[string]: true}

	// Dependencies (set membership for clean unification)
	depends_on?: {[string]: true}

	// Metadata
	description?: string
	tags?: {[string]: true}

	// Allow domain-specific extensions
	...
}
