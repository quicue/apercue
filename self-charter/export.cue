package main

import (
	"list"
	"strings"
	"strconv"
	"apercue.ca/vocab@v0"
)

// Reverse-map topology to get actual depth per resource.
// #Graph computes topology as {layer_0: {...}, layer_1: {...}, ...}
// _depth is a hidden field scoped to package patterns — not accessible here.
// So we parse "layer_N" → N using strconv.Atoi.
_depth_map: {
	for layerName, members in _eco_graph.topology {
		let _n = strconv.Atoi(strings.TrimPrefix(layerName, "layer_"))
		for rname, _ in members {
			(rname): _n
		}
	}
}

// Build charter depth map from GraphLite topology
_charter_depth_map: {
	for layerName, members in graph.topology {
		let _n = strconv.Atoi(strings.TrimPrefix(layerName, "layer_"))
		for rname, _ in members {
			(rname): _n
		}
	}
}

// Export-friendly charter data for D3 visualization
charter_viz: {
	"@context":       vocab.context["@context"]
	"@type":          "apercue:CharterVisualization"
	"dct:conformsTo": {"@id": "https://apercue.ca/charter"}
	nodes: [
		for rname, raw in _tasks {
			id:          rname
			name:        rname
			types:       [for t, _ in raw["@type"] {t}]
			depth:       _charter_depth_map[rname]
			description: raw.description
			planned:     raw._planned
			kb: *_kb_annotations[rname] | []
			// CPM scheduling data
			earliest: _precomputed_cpm.earliest[rname]
			latest:   _precomputed_cpm.latest[rname]
			duration: _precomputed_cpm.duration[rname]
			slack:    _precomputed_cpm.latest[rname] - _precomputed_cpm.earliest[rname]
			// Determine phase from charter gates
			phase: [
				for gname, gate in _charter.gates
				if gate.requires[rname] != _|_ {gate.phase},
				0,
			][0]
			gate: [
				for gname, gate in _charter.gates
				if gate.requires[rname] != _|_ {gname},
				"",
			][0]
		},
	]
	edges: list.FlattenN([
		for rname, raw in _tasks if raw.depends_on != _|_ {
			[for dep, _ in raw.depends_on {{source: dep, target: rname}}]
		},
	], 1)
	gates: {
		for gname, gate in _charter.gates {
			(gname): {
				phase:       gate.phase
				description: gate.description
				satisfied:   gaps.gate_status[gname].satisfied
				resources:   [for r, _ in gate.requires {r}]
			}
		}
	}
	charter_summary: summary
	topology:        graph.topology
	scheduling: {
		summary:           cpm.summary
		critical_sequence: cpm.critical_sequence
	}
}

// ═══════════════════════════════════════════════════════════════════════════
// PROJECTIONS — One graph, many lenses. One cue export, all W3C outputs.
//
// The precomputed closure (ancestors, dependents, depth, CPM) is computed
// once in Python. Each projection is a cheap struct comprehension over
// the same data. Export: cue export ./self-charter/ -e projections --out json
// ═══════════════════════════════════════════════════════════════════════════

projections: {
	"@context":       vocab.context["@context"]
	"@type":          "apercue:ProjectionSet"
	"dct:conformsTo": {"@id": "https://apercue.ca/vocab"}
	// SHACL — gap analysis as validation report
	shacl: gaps.shacl_report

	// OWL-Time — CPM scheduling as temporal intervals
	owl_time: cpm.time_report

	// CPM summary + critical sequence
	scheduling: {
		summary:          cpm.summary
		critical_sequence: cpm.critical_sequence
	}
}

// Export-friendly ecosystem data for D3 visualization
// Iterate over _ecosystem (raw input) to get concrete keys.
// Depth comes from the computed graph topology, not dependency count.
eco_viz: {
	"@context":       vocab.context["@context"]
	"@type":          "apercue:EcosystemVisualization"
	"dct:conformsTo": {"@id": "https://apercue.ca/charter"}
	nodes: [
		for rname, raw in _ecosystem {
			id:          rname
			name:        rname
			types:       [for t, _ in raw["@type"] {t}]
			depth:       _depth_map[rname]
			status:      raw.status
			description: raw.description
			domain:      *raw.domain | ""
		},
	]
	edges: list.FlattenN([
		for rname, raw in _ecosystem if raw.depends_on != _|_ {
			[for dep, _ in raw.depends_on {{source: dep, target: rname}}]
		},
	], 1)
	charter:       ecosystem.summary
	cpm:           _eco_cpm.summary
	critical_path: _eco_cpm.critical_sequence
	status:        {for rname, r in _ecosystem {(rname): r.status}}
	topology:      _eco_graph.topology
}

// ═══════════════════════════════════════════════════════════════════════════
// SKOS — Task type taxonomy as a ConceptScheme.
//
// Projects the task types used in the charter as SKOS Concepts.
// W3C SKOS (Recommendation, 2009-08-18): Simple Knowledge Organization System.
//
// Export: cue export ./self-charter/ -e type_vocabulary --out json
// ═══════════════════════════════════════════════════════════════════════════

_charter_types: {
	Schema:        {description: "Schema or type definition task"}
	Pattern:       {description: "Reusable computational pattern"}
	Projection:    {description: "W3C standard output projection"}
	Example:       {description: "Example or demonstration"}
	CI:            {description: "Continuous integration or automation"}
	Documentation: {description: "Documentation or knowledge base entry"}
}

type_vocabulary: {
	"@context":       vocab.context["@context"]
	"@type":          "skos:ConceptScheme"
	"@id":            "https://apercue.ca/charter#TaskTypes"
	"skos:prefLabel": "Charter Task Type Vocabulary"
	"dcterms:title":  "Charter Task Type Vocabulary"
	"skos:hasTopConcept": [
		for name, entry in _charter_types {
			"@type":             "skos:Concept"
			"@id":               "https://apercue.ca/charter#" + name
			"skos:prefLabel":    name
			"skos:definition":   entry.description
			"skos:inScheme":     {"@id": "https://apercue.ca/charter#TaskTypes"}
			"skos:topConceptOf": {"@id": "https://apercue.ca/charter#TaskTypes"}
		},
	]
}
