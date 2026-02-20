// Type Registry — Pattern for domain-specific type vocabularies.
//
// The registry is intentionally empty. Each domain fills it with
// types relevant to its context. Infrastructure, courses, recipes,
// supply chains — they all use the same shape.
//
// Usage:
//   import "apercue.ca/vocab@v0"
//
//   // Define your domain types:
//   vocab.#TypeRegistry & {
//       CoreCourse: { description: "Required course for the major" }
//       Elective:   { description: "Optional course" }
//   }

package vocab

// #TypeRegistry — Catalog of known semantic types.
// Extend this with your domain vocabulary.
// Keys must be ASCII-safe labels (prevents unicode injection in type names).
#TypeRegistry: {
	[#SafeLabel]: #TypeEntry

	// Allow extension
	...
}

// #TypeEntry — Schema for type registry entries.
#TypeEntry: {
	description: string
	requires?: {...}          // Fields that resources of this type MUST have
	grants?: [...string]      // Capability names this type provides
	structural_deps?: [...string]  // Fields that auto-create depends_on
}

// #TypeNames — Constraint for type name validation.
// Override in your domain module after populating #TypeRegistry.
// Example: #TypeNames: or([for k, _ in #TypeRegistry {k}])
#TypeNames: #SafeLabel
