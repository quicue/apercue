package main

import "list"

// Reverse-map topology to get depth per resource (avoids cross-package _depth access)
_depth_map: {
	for layerName, members in _eco_graph.topology {
		for rname, _ in members {
			// Extract layer number: "layer_0" → 0, "layer_1" → 1, etc.
			// Use depends_on length as proxy since topology keys aren't parseable
			(rname): len([for d, _ in *_ecosystem[rname].depends_on | {} {d}])
		}
	}
}

// Export-friendly ecosystem data for D3 visualization
// Iterate over _ecosystem (raw input) to get concrete keys.
eco_viz: {
	nodes: [
		for rname, raw in _ecosystem {
			id:          rname
			name:        rname
			types:       [for t, _ in raw["@type"] {t}]
			depth:       len([for d, _ in *raw.depends_on | {} {d}])
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
