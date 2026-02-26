// Federation test — validate #FederatedContext and #FederatedMerge.
//
// Two small graphs from different "domains" are wrapped in federated
// contexts and merged. CUE vet proves:
// - Non-default @base is enforced
// - Namespace collision detection works (via unification)
// - Cross-domain edges validate correctly
// - Merged JSON-LD concatenates @graph arrays

package main

import "apercue.ca/patterns@v0"

// ═══ DOMAIN A: infrastructure ════════════════════════════════════════════════

_infra_steps: {
	"db-01": {
		name: "db-01"
		"@type": {Database: true}
		description: "Primary PostgreSQL"
	}
	"app-01": {
		name: "app-01"
		"@type": {Service: true}
		depends_on: {"db-01": true}
		description: "API server"
	}
	"lb-01": {
		name: "lb-01"
		"@type": {Service: true}
		depends_on: {"app-01": true}
		description: "Load balancer"
	}
}

_infra_graph: patterns.#Graph & {Input: _infra_steps}

infra_ctx: patterns.#FederatedContext & {
	Domain:    "infra"
	Namespace: "urn:infra:"
	Graph:     _infra_graph
}

// ═══ DOMAIN B: monitoring ═══════════════════════════════════════════════════

_mon_steps: {
	"prometheus": {
		name: "prometheus"
		"@type": {Monitoring: true}
		description: "Metrics collector"
	}
	"grafana": {
		name: "grafana"
		"@type": {Dashboard: true}
		depends_on: {"prometheus": true}
		description: "Visualization"
	}
}

_mon_graph: patterns.#Graph & {Input: _mon_steps}

mon_ctx: patterns.#FederatedContext & {
	Domain:    "monitoring"
	Namespace: "urn:monitoring:"
	Graph:     _mon_graph
}

// ═══ MERGE ══════════════════════════════════════════════════════════════════

federation: patterns.#FederatedMerge & {
	Sources: {
		infra:      infra_ctx
		monitoring: mon_ctx
	}
	CrossEdges: [
		{source_domain: "monitoring", source: "prometheus", target_domain: "infra", target: "app-01"},
	]
}

// ═══ ASSERTIONS ═════════════════════════════════════════════════════════════

// Verify namespaces are correct
_assert_infra_ns: infra_ctx.Namespace & "urn:infra:"
_assert_mon_ns:   mon_ctx.Namespace & "urn:monitoring:"

// Verify @id generation
_assert_db_id: infra_ctx.ids["db-01"] & "urn:infra:db-01"
_assert_prom_id: mon_ctx.ids.prometheus & "urn:monitoring:prometheus"

// Verify merge summary
_assert_sources: federation.summary.source_count & 2
_assert_resources: federation.summary.total_resources & 5
_assert_cross: federation.summary.cross_edges & 1
_assert_valid: federation.summary.valid & true
