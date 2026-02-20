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
	id:         string
	name:       string
	types:      [...string]   // Flattened from @type struct
	depth:      int
	ancestors:  [...string]
	dependents: int           // Count, not list
	description?: string
}

// #VizEdge — Dependency edge.
#VizEdge: {
	source: string
	target: string
}

// #VizData — Complete visualization payload.
#VizData: {
	nodes:    [...#VizNode]
	edges:    [...#VizEdge]
	topology: [string]: [...string]
	roots:    [...string]
	leaves:   [...string]
	metrics: {
		total:    int
		maxDepth: int
		edges:    int
		roots:    int
		leaves:   int
	}
}
