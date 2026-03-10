// ContextEvent — timestamped record of a federation boundary crossing.
//
// Append-only audit trail for graph operations: merges, validations,
// projections, and exports. Each event records what happened, which
// domains were involved, which resources were affected, and the outcome.
//
// Motivated by Kurt Cagle's context graph model (The Ontologist, March
// 2026): ContextEvents are written by a control plane, readable by any
// authorized party, and form a permanent temporal record of how graphs
// interact across domain boundaries.
//
// W3C alignment: PROV-O Activity + OWL-Time instant.
//
// Usage:
//   import "apercue.ca/vocab@v0"
//
//   events: [...vocab.#ContextEvent] & [
//       {type: "merge", source: "apercue", target: "quicue-kg", ...},
//   ]

package vocab

// #EventType — what kind of boundary operation occurred.
#EventType: "merge" | "validate" | "project" | "export"

// #EventOutcome — result of the boundary operation.
#EventOutcome: "success" | "conflict" | "partial"

// #ContextEvent — one timestamped boundary crossing record.
#ContextEvent: {
	// When the event occurred (RFC 3339)
	timestamp: =~"^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}"

	// What operation was performed
	type: #EventType

	// Which domains were involved
	source_domain: #SafeID
	target_domain: #SafeID

	// Which resources were affected
	resources: [...#SafeID]

	// What happened
	outcome: #EventOutcome

	// Optional provenance link (to a #ProvenanceTrace @id)
	provenance_ref?: string

	// Optional description of what happened
	description?: string
}
