// Type Contract Validation & Derivation
//
// Core insight: Types are contracts. Declaring @type means:
//   1. Required fields MUST exist (validation at CUE eval time)
//   2. Granted actions WILL be derived (auto-derivation)
//   3. Structural fields WILL create dependencies (inference)
//
// Usage:
//   import "apercue.ca/patterns@v0"
//
//   myResource: (patterns.#ApplyTypeContracts & {Input: {
//       name: "dns-server"
//       "@type": {DNSServer: true, LXCContainer: true}
//       ip: "192.0.2.10"
//       container_id: 101
//       host: "pve-node"
//   }}).Output
//
// The Output will have:
//   - All Input fields (validated against type requirements)
//   - Auto-populated depends_on from structural_deps fields
//   - Auto-derived actions from type grants

package patterns

import "apercue.ca/vocab"

// #ApplyTypeContracts - Validate and derive from type declarations
// Takes a resource Input and produces a validated Output with derived fields
#ApplyTypeContracts: {
	Input: _

	// =========================================================================
	// Step 1: Validate required fields exist for each type
	// =========================================================================
	// For each type in @type, check that required fields exist.
	// Validation happens via unification - if fields are missing, CUE fails.
	// We use a separate _validation struct to avoid carrying type constraints
	// into the output (which would make it "incomplete").
	_validation: {
		for typeName, _ in Input["@type"] if vocab.#TypeRegistry[typeName] != _|_ {
			if vocab.#TypeRegistry[typeName].requires != _|_ {
				// Check each required field exists and matches type
				for fieldName, fieldType in vocab.#TypeRegistry[typeName].requires {
					(fieldName): Input[fieldName] & fieldType
				}
			}
		}
	}

	// =========================================================================
	// Step 2: Derive structural dependencies
	// =========================================================================
	// Types can declare fields that auto-create depends_on edges.
	// e.g., LXCContainer has structural_deps: ["host"]
	// If resource.host = "pve-node", then depends_on["pve-node"] is auto-added.
	_structuralDeps: {
		for typeName, _ in Input["@type"] if vocab.#TypeRegistry[typeName] != _|_ {
			if vocab.#TypeRegistry[typeName].structural_deps != _|_ {
				for fieldName in vocab.#TypeRegistry[typeName].structural_deps if Input[fieldName] != _|_ {
					(Input[fieldName]): true
				}
			}
		}
	}

	// Merge explicit depends_on with inferred structural deps
	_allDeps: (*Input.depends_on | {}) & _structuralDeps

	// =========================================================================
	// Step 3: Collect granted actions from all types
	// =========================================================================
	// Each type grants certain actions. A multi-type resource gets all grants.
	// e.g., {DNSServer: true, LXCContainer: true} grants both DNS and container actions.
	_grantedActions: {
		for typeName, _ in Input["@type"] if vocab.#TypeRegistry[typeName] != _|_ {
			if vocab.#TypeRegistry[typeName].grants != _|_ {
				for actionName in vocab.#TypeRegistry[typeName].grants {
					(actionName): true
				}
			}
		}
	}

	// =========================================================================
	// Output: Validated resource with derived fields
	// =========================================================================
	// Build output from Input (not _validation, which has type constraints)
	_withDeps: Input & {
		if len(_structuralDeps) > 0 || Input.depends_on != _|_ {
			depends_on: _allDeps
		}
	}

	// Expose grants directly (needed for action derivation)
	grants: _grantedActions

	// Output: Input with derived dependencies (validation was side-effect)
	Output: _withDeps
}

// #ValidateTypes - Apply type contracts to all resources in a graph
// (Renamed from #ValidateGraph to avoid collision with graph.cue's structural validator)
// Usage:
//   validatedGraph: patterns.#ValidateTypes & {Input: myResources}
#ValidateTypes: {
	Input: [string]: _

	// Apply type contracts to each resource
	Output: {
		for name, res in Input {
			(name): (#ApplyTypeContracts & {Input: res}).Output
		}
	}

	// Validation summary
	resourceCount: len(Input)
	validated:     true // If we get here, validation passed
}

// #TypeRequirements - Extract all required fields for a set of types
// Useful for understanding what a multi-type resource needs
// Usage:
//   reqs: patterns.#TypeRequirements & {Types: ["DNSServer", "LXCContainer"]}
#TypeRequirements: {
	Types: [...string]

	// Merge all requirements from all types
	requires: {
		for typeName in Types if vocab.#TypeRegistry[typeName] != _|_ {
			if vocab.#TypeRegistry[typeName].requires != _|_ {
				for fieldName, fieldType in vocab.#TypeRegistry[typeName].requires {
					(fieldName): fieldType
				}
			}
		}
		...
	}

	// Collect all grants as struct-set (avoids array index conflicts)
	grants: {
		for typeName in Types if vocab.#TypeRegistry[typeName] != _|_ {
			if vocab.#TypeRegistry[typeName].grants != _|_ {
				for actionName in vocab.#TypeRegistry[typeName].grants {
					(actionName): true
				}
			}
		}
	}

	// Collect structural deps as struct-set
	structural_deps: {
		for typeName in Types if vocab.#TypeRegistry[typeName] != _|_ {
			if vocab.#TypeRegistry[typeName].structural_deps != _|_ {
				for fieldName in vocab.#TypeRegistry[typeName].structural_deps {
					(fieldName): true
				}
			}
		}
	}
}
