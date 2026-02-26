// W3C submission evidence — computed from an inline example graph.
//
// This is NOT hand-written output. Every JSON block is computed by
// the same patterns used in production. The evidence IS the proof.
//
// Usage:
//   cue export ./w3c/ -e evidence --out json
//   cue export ./w3c/ -e core_report --out text
package w3c

import (
	"encoding/json"

	"apercue.ca/patterns@v0"
	"apercue.ca/vocab@v0"
)

// ── Inline example graph ────────────────────────────────────────
// Minimal supply chain: 5 nodes, 3 types, enough to show every pattern.

_parts: {
	"silicon-wafer": {
		name: "silicon-wafer"
		"@type": {RawMaterial: true}
		description:       "300mm semiconductor-grade silicon substrate"
		schedule_duration: 14
	}
	"copper-pcb": {
		name: "copper-pcb"
		"@type": {RawMaterial: true}
		description: "FR-4 copper-clad laminate"
	}
	"cpu-chip": {
		name: "cpu-chip"
		"@type": {Component: true}
		description: "Application processor (5nm)"
		depends_on: {"silicon-wafer": true}
		schedule_duration: 30
	}
	"motherboard": {
		name: "motherboard"
		"@type": {SubAssembly: true}
		description: "Main logic board"
		depends_on: {"cpu-chip": true, "copper-pcb": true}
		schedule_duration: 7
	}
	"laptop": {
		name: "laptop"
		"@type": {Assembly: true}
		description: "Finished product"
		depends_on: {"motherboard": true}
		schedule_duration: 2
	}
}

// ── Graph computation ───────────────────────────────────────────

_graph: patterns.#Graph & {Input: _parts}

// ── Compliance rules ────────────────────────────────────────────

_compliance: patterns.#ComplianceCheck & {
	Graph: _graph
	Rules: [{
		name:       "assemblies-need-components"
		severity:   "critical"
		match_types: {"Assembly": true}
		must_not_be_root: true
	}]
}

// ── Critical path ───────────────────────────────────────────────

_cpm: patterns.#CriticalPath & {
	Graph: _graph
	Weights: {
		"silicon-wafer": 14
		"copper-pcb":    7
		"cpu-chip":      30
		"motherboard":   7
		"laptop":        2
	}
}

// ── ODRL policy ─────────────────────────────────────────────────

_policy: patterns.#ODRLPolicy & {
	Graph: _graph
	permissions: [{
		action: "odrl:read"
	}, {
		action:   "odrl:execute"
		assignee: "apercue:operator"
	}]
}

// ── Provenance ──────────────────────────────────────────────────

_provenance: patterns.#ProvenanceTrace & {Graph: _graph}

// ── Spec counts from registry ───────────────────────────────────

_spec_counts: {
	_implemented: len([for _, s in vocab.Specs if s.status == "Implemented" {s}])
	_downstream:  len([for _, s in vocab.Specs if s.status == "Downstream" {s}])
	implemented:  _implemented
	downstream:   _downstream
	total:        _implemented + _downstream
}

// ── Evidence export ─────────────────────────────────────────────

evidence: {
	// Spec coverage
	spec_counts: _spec_counts

	// JSON-LD context
	context: vocab.context

	// Graph summary
	graph_summary: {
		total_resources: len(_graph.resources)
		roots:           _graph.roots
		leaves:          _graph.leaves
		max_depth: len(_graph.topology) - 1
		layers:    len(_graph.topology)
	}

	// SHACL
	shacl: _compliance.shacl_report

	// Critical path
	cpm_summary: _cpm.summary
	cpm_sequence: _cpm.critical_sequence

	// OWL-Time
	time_report: _cpm.time_report

	// ODRL
	odrl_policy: _policy.odrl_policy

	// Provenance
	prov_report: _provenance.prov_report
}

// ── JSON-formatted evidence blocks for report injection ─────────

// Marshal from hidden fields directly — avoids cycles through
// the public evidence struct when interpolated in report templates.
_json: {
	shacl:        json.Indent(json.Marshal(_compliance.shacl_report), "", "    ")
	cpm_summary:  json.Indent(json.Marshal(_cpm.summary), "", "    ")
	cpm_sequence: json.Indent(json.Marshal(_cpm.critical_sequence), "", "    ")
	context:      json.Indent(json.Marshal(vocab.context), "", "    ")
	odrl:         json.Indent(json.Marshal(_policy.odrl_policy), "", "    ")
	prov:         json.Indent(json.Marshal(_provenance.prov_report), "", "    ")
}
