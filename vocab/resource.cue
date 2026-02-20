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

// #SafeID — ASCII-only identifier for graph keys and references.
// Prevents zero-width unicode injection, homoglyph attacks, and
// invisible characters that break CUE unification silently.
#SafeID: =~"^[a-zA-Z][a-zA-Z0-9_.-]*$"

// #SafeLabel — ASCII-only type/tag label (PascalCase or kebab-case).
#SafeLabel: =~"^[a-zA-Z][a-zA-Z0-9_-]*$"

// #Resource — the universal node type.
// Every node in the graph conforms to this schema.
#Resource: {
	// Identity — ASCII-only to prevent unicode injection
	name:   #SafeID
	"@id"?: string | *("urn:resource:" + name)

	// Semantic types (struct-as-set for O(1) membership checks)
	// Keys must be ASCII-safe labels
	"@type": {[#SafeLabel]: true}

	// Dependencies (set membership for clean unification)
	// Keys reference resource names — must match #SafeID
	depends_on?: {[#SafeID]: true}

	// Metadata — descriptions may contain unicode for i18n
	description?: string
	tags?: {[#SafeLabel]: true}

	// Allow domain-specific extensions
	...
}
