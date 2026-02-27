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
// Research publication pipeline: 5 nodes, 3 types.
// Chosen because W3C specs map to their intended domains:
//   Dublin Core → publication metadata
//   PROV-O → dataset provenance
//   ODRL → data embargo / open access
//   OWL-Time → submission deadlines
//   SHACL → metadata completeness

_resources: {
	"ethics-approval": {
		name: "ethics-approval"
		"@type": {Governance: true}
		description:       "Institutional review board approval (Protocol #2024-0142)"
		schedule_duration: 60
	}
	"sensor-dataset": {
		name: "sensor-dataset"
		"@type": {Dataset: true}
		description:       "Telemetry dataset (embargoed until publication)"
		depends_on: {"ethics-approval": true}
		schedule_duration: 90
	}
	"analysis-code": {
		name: "analysis-code"
		"@type": {Process: true}
		description:       "Statistical analysis pipeline (R + Python)"
		depends_on: {"sensor-dataset": true}
		schedule_duration: 45
	}
	"draft-paper": {
		name: "draft-paper"
		"@type": {Publication: true}
		description:       "Conference submission draft"
		depends_on: {"analysis-code": true}
		schedule_duration: 30
	}
	"peer-review": {
		name: "peer-review"
		"@type": {Review: true}
		description:       "Double-blind peer review"
		depends_on: {"draft-paper": true}
		schedule_duration: 60
	}
}

// ── Graph computation ───────────────────────────────────────────

_graph: patterns.#Graph & {Input: _resources}

// ── Compliance rules ────────────────────────────────────────────

_compliance: patterns.#ComplianceCheck & {
	Graph: _graph
	Rules: [{
		name:            "publications-need-data"
		severity:        "critical"
		match_types:     {"Publication": true}
		must_not_be_root: true
	}]
}

// ── Critical path ───────────────────────────────────────────────

_cpm: patterns.#CriticalPath & {
	Graph: _graph
	Weights: {
		"ethics-approval": 60
		"sensor-dataset":  90
		"analysis-code":   45
		"draft-paper":     30
		"peer-review":     60
	}
}

// ── ODRL policy ─────────────────────────────────────────────────

_policy: patterns.#ODRLPolicy & {
	Graph: _graph
	permissions: [{
		action: "read"
	}, {
		action:   "execute"
		assignee: "apercue:operator"
	}]
}

// ── DCAT catalog ──────────────────────────────────────────────

_catalog: patterns.#DCATCatalog & {
	Graph:       _graph
	Title:       "Research Publication Pipeline"
	Description: "Five-stage research workflow from ethics approval through peer review"
}

// ── Provenance ──────────────────────────────────────────────────

_provenance: patterns.#ProvenanceTrace & {Graph: _graph}

// ── VoID ────────────────────────────────────────────────────────

_void: patterns.#VoIDDataset & {
	Graph:      _graph
	DatasetURI: "urn:apercue:w3c-evidence"
	Title:      "W3C Evidence Dataset"
}

// ── OWL Ontology ────────────────────────────────────────────────

_ontology: patterns.#OWLOntology & {
	Graph: _graph
	Spec: {
		URI:         "https://apercue.ca/ontology/w3c-evidence#"
		Title:       "W3C Evidence Ontology"
		Description: "OWL vocabulary from research publication dependency graph"
	}
}

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

	// DCAT catalog
	dcat_catalog: _catalog.dcat_catalog

	// VoID
	void_description: _void.void_description

	// OWL
	owl_ontology: _ontology.owl_ontology
}

// ── JSON-formatted evidence blocks for report injection ─────────

// Marshal from hidden fields directly — avoids cycles through
// the public evidence struct when interpolated in report templates.
// Compact versions strip @context (shown once in the report).
_json: {
	// Full JSON-LD context (shown once at top of report)
	context: json.Indent(json.Marshal(vocab.context), "", "    ")

	// SHACL — compact (no @context)
	shacl: json.Indent(json.Marshal({
		"@type":       "sh:ValidationReport"
		"sh:conforms": _compliance.shacl_report["sh:conforms"]
		"sh:result":   _compliance.shacl_report["sh:result"]
	}), "", "    ")

	// Critical path schedule (compact tabular)
	cpm_summary:  json.Indent(json.Marshal(_cpm.summary), "", "    ")
	cpm_sequence: json.Indent(json.Marshal(_cpm.critical_sequence), "", "    ")

	// OWL-Time — single entry showing time:Interval (analysis-code)
	time_entry: json.Indent(json.Marshal(
		[for e in _cpm.time_report["@graph"]
			if e["dcterms:title"] == "analysis-code" {e}][0],
	), "", "    ")

	// ODRL — compact (no @context)
	odrl: json.Indent(json.Marshal({
		"@type":            _policy.odrl_policy["@type"]
		"odrl:uid":         _policy.odrl_policy["odrl:uid"]
		"odrl:permission":  _policy.odrl_policy["odrl:permission"]
		"odrl:prohibition": _policy.odrl_policy["odrl:prohibition"]
	}), "", "    ")

	// PROV-O — single entity with derivation chain (analysis-code)
	prov_entity: json.Indent(json.Marshal(
		[ for e in _provenance.prov_report["@graph"]
			if e["@id"] == "urn:resource:analysis-code" {e}][0],
	), "", "    ")

	// DCAT — compact catalog entry (first dataset only)
	dcat: json.Indent(json.Marshal({
		"@type":          "dcat:Catalog"
		"dcterms:title":  _catalog.dcat_catalog["dcterms:title"]
		"dcat:dataset": [
			for d in _catalog.dcat_catalog["dcat:dataset"]
			if d["dcterms:title"] == "sensor-dataset" {d},
		]
	}), "", "    ")

	// VoID — compact dataset self-description (no @context)
	void: json.Indent(json.Marshal({
		"@type":               "void:Dataset"
		"@id":                 _void.void_description["@id"]
		"dcterms:title":       _void.void_description["dcterms:title"]
		"void:entities":       _void.void_description["void:entities"]
		"void:triples":        _void.void_description["void:triples"]
		"void:classes":        _void.void_description["void:classes"]
		"void:classPartition": _void.void_description["void:classPartition"]
	}), "", "    ")

	// OWL — compact ontology showing class entries (no @context)
	owl: json.Indent(json.Marshal({
		"@graph": _ontology.owl_ontology["@graph"]
	}), "", "    ")
}
