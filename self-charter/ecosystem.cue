// Ecosystem graph — models the entire quicue/apercue project ecosystem
// as a typed dependency graph. Each repo/module is a resource, import
// relationships are edges, and health/status comes from real state.
//
// This is the "unification surface" — one graph that composes all projects.
//
// Run:
//   cue eval ./self-charter/ -e ecosystem.summary
//   cue eval ./self-charter/ -e ecosystem.cpm.summary
//   cue eval ./self-charter/ -e ecosystem.gaps.complete

package main

import (
	"apercue.ca/patterns@v0"
	"apercue.ca/charter@v0"
)

// ═══ ECOSYSTEM RESOURCES ════════════════════════════════════════════
_ecosystem: {
	// ── Foundation layer ──────────────────────────────────────────
	"apercue": {
		name: "apercue"
		"@type": {Module: true, Reference: true}
		description: "Generic reference repo — domain-agnostic typed graphs + W3C projections"
		status:      "active"
		repo:        "github:quicue/apercue"
		domain:      "apercue.ca"
	}

	// ── Pattern layer ────────────────────────────────────────────
	"quicue-patterns": {
		name: "quicue-patterns"
		"@type": {Module: true, Patterns: true}
		description: "Infrastructure-specific patterns — 40+ types, 29 providers"
		depends_on: {apercue: true}
		status: "active"
		repo:   "github:quicue/quicue.ca"
		domain: "quicue.ca"
	}
	"quicue-kg": {
		name: "quicue-kg"
		"@type": {Module: true, Framework: true}
		description: "Knowledge graph framework — core types, ext, aggregate, CLI"
		depends_on: {apercue: true}
		status: "active"
		repo:   "github:quicue/quicue-kg"
		domain: "kg.quicue.ca"
	}

	// ── Instance layer ───────────────────────────────────────────
	"grdn": {
		name: "grdn"
		"@type": {Instance: true, Homelab: true}
		description: "Infrastructure instance — datacenter-as-code deployment"
		depends_on: {"quicue-patterns": true, "quicue-kg": true}
		status: "active"
	}
	"cmhc-retrofit": {
		name: "cmhc-retrofit"
		"@type": {Instance: true, Standalone: true}
		description: "CMHC housing retrofit — NHCF + Greener Homes graphs"
		depends_on: {"quicue-patterns": true}
		status: "active"
		repo:   "github:quicue/cmhc-retrofit"
		domain: "cmhc-retrofit.quicue.ca"
	}
	"property-tracker": {
		name: "property-tracker"
		"@type": {Instance: true, Standalone: true}
		description: "Real estate transaction modeling with compliance rules"
		depends_on: {"quicue-patterns": true}
		status: "active"
	}

	// ── Services layer ───────────────────────────────────────────
	"demo-site": {
		name: "demo-site"
		"@type": {Service: true, Frontend: true}
		description: "D3 graph explorer, planner, Hydra browser"
		depends_on: {"quicue-patterns": true}
		status: "active"
		domain: "demo.quicue.ca"
	}
	"static-api": {
		name: "static-api"
		"@type": {Service: true, API: true}
		description: "727 pre-computed JSON responses from cue export"
		depends_on: {"quicue-patterns": true, grdn: true}
		status: "active"
		domain: "api.quicue.ca"
	}
	"forgejo": {
		name: "forgejo"
		"@type": {Service: true, GitServer: true}
		description: "Self-hosted Forgejo git server"
		depends_on: {grdn: true}
		status: "active"
	}

	// ── Tool layer ───────────────────────────────────────────────
	"quicue-swamp": {
		name: "quicue-swamp"
		"@type": {Tool: true}
		description: "CLI extension framework for knowledge graph operations"
		depends_on: {"quicue-kg": true}
		status: "active"
	}
}

// ═══ GRAPH ═════════════════════════════════════════════════════════
_eco_graph: patterns.#Graph & {Input: _ecosystem}

// ═══ SCHEDULING ════════════════════════════════════════════════════
_eco_cpm: patterns.#CriticalPath & {
	Graph: _eco_graph
	// Weights: estimated effort in days
	Weights: {
		apercue:            5
		"quicue-patterns":  10
		"quicue-kg":        5
		grdn:               8
		"cmhc-retrofit":    3
		"property-tracker": 3
		"demo-site":        2
		"static-api":       2
		forgejo:            1
		"quicue-swamp":     2
	}
}

// ═══ CHARTER — Ecosystem completeness ══════════════════════════════
_eco_charter: charter.#Charter & {
	name: "quicue-ecosystem"

	scope: {
		total_resources: 10
		root: {apercue: true}
		required_types: {
			Module:   true
			Instance: true
			Service:  true
			Tool:     true
		}
	}

	gates: {
		"foundation": {
			phase:       1
			description: "Generic patterns published and validated"
			requires: {
				apercue: true
			}
		}
		"patterns-published": {
			phase:       2
			description: "Infrastructure patterns and kg framework operational"
			requires: {
				"quicue-patterns": true
				"quicue-kg":       true
			}
			depends_on: {foundation: true}
		}
		"instances-live": {
			phase:       3
			description: "At least 2 production instances running"
			requires: {
				grdn:            true
				"cmhc-retrofit": true
			}
			depends_on: {"patterns-published": true}
		}
		"ecosystem-complete": {
			phase:       4
			description: "Full ecosystem: services, tools, self-hosted git"
			requires: {
				"demo-site":        true
				"static-api":       true
				forgejo:            true
				"quicue-swamp":     true
				"property-tracker": true
			}
			depends_on: {"instances-live": true}
		}
	}
}

_eco_gaps: charter.#GapAnalysis & {
	Charter: _eco_charter
	Graph:   _eco_graph
}

// ═══ EXPORT ════════════════════════════════════════════════════════
ecosystem: {
	summary: {
		name:          _eco_charter.name
		total_modules: len(_ecosystem)
		graph_valid:   _eco_graph.valid
		complete:      _eco_gaps.complete
		missing:       _eco_gaps.missing_resource_count
		next_gate:     _eco_gaps.next_gate
	}
	cpm:   _eco_cpm
	gaps:  _eco_gaps
	graph: _eco_graph
	status: {for name, r in _ecosystem {(name): r.status}}
}
