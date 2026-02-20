package main

import (
	"list"
	"strings"
	"strconv"
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
	nodes: [
		for rname, raw in _tasks {
			id:          rname
			name:        rname
			types:       [for t, _ in raw["@type"] {t}]
			depth:       _charter_depth_map[rname]
			description: raw.description
			planned:     raw._planned
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
}

// Export-friendly ecosystem data for D3 visualization
// Iterate over _ecosystem (raw input) to get concrete keys.
// Depth comes from the computed graph topology, not dependency count.
eco_viz: {
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
