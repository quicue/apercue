// Visualization Data Contract
//
// Defines the JSON structure consumed by visualization tools.
// Generic — no domain-specific fields.
//
// Usage:
//   cue export -e vizData --out json > viz.json

package vocab

// #VizNode — Minimal node for visualization tools.
#VizNode: {
	id:   #SafeID
	name: #SafeID
	types: [...#SafeLabel] // Flattened from @type struct
	depth:                 int
	ancestors: [...#SafeID]
	dependents:   int // Count, not list
	description?: string
}

// #VizEdge — Dependency edge.
#VizEdge: {
	source: #SafeID
	target: #SafeID
}

// #VizData — Complete visualization payload.
#VizData: {
	nodes: [...#VizNode]
	edges: [...#VizEdge]
	topology: [string]: [...string]
	roots: [...string]
	leaves: [...string]
	metrics: {
		total:    int
		maxDepth: int
		edges:    int
		roots:    int
		leaves:   int
	}
}
