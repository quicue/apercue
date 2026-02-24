// Visualization Patterns for Dependency Graphs
// Generates Graphviz DOT and Mermaid diagrams from apercue resources
//
// Usage:
//   import "apercue.ca/patterns"
//
//   myViz: patterns.#GraphvizDiagram & {
//       Input: myGraph.resources
//   }
package patterns

import (
	"list"
	"strings"
	"apercue.ca/vocab"
)

// #GraphvizConfig - Configuration for Graphviz DOT output
#GraphvizConfig: {
	layout:  *"dot" | "neato" | "fdp" | "sfdp" | "circo" | "twopi"
	rankdir: *"TB" | "LR" | "BT" | "RL"
	splines: *"true" | "false" | "ortho" | "polyline" | "curved"
	overlap: *"false" | "true" | "scale" | "scalexy"
	sep:     string | *"+0.5"
}

// #NodeStyle - Style for a node type in Graphviz
#NodeStyle: {
	shape:     string | *"box"
	color:     string | *"#607D8B"
	fontcolor: string | *"white"
	fillstyle: string | *"filled"
	icon:      string | *""
}

// #DefaultNodeStyles — preset styles for common semantic types.
// These are visualization presets, not domain-specific constraints.
// Override or extend via NodeStyles in #GraphvizDiagram.
#DefaultNodeStyles: {
	LoadBalancer: #NodeStyle & {
		shape: "hexagon"
		color: "#2196F3"
		icon:  "LB"
	}
	Database: #NodeStyle & {
		shape: "cylinder"
		color: "#4CAF50"
		icon:  "DB"
	}
	WebServer: #NodeStyle & {
		shape: "box"
		color: "#FF9800"
		icon:  "WEB"
	}
	Container: #NodeStyle & {
		shape: "box3d"
		color: "#00BCD4"
		icon:  "CT"
	}
	VM: #NodeStyle & {
		shape: "box"
		color: "#9C27B0"
		icon:  "VM"
	}
	ProxmoxVM: #NodeStyle & {
		shape: "box"
		color: "#E65100"
		icon:  "PVE"
	}
	ProxmoxLXC: #NodeStyle & {
		shape: "box3d"
		color: "#00695C"
		icon:  "LXC"
	}
	VCFResource: #NodeStyle & {
		shape: "box"
		color: "#1565C0"
		icon:  "VCF"
	}
	_default: #NodeStyle
}

// #GraphvizDiagram - Generate Graphviz DOT from resources
#GraphvizDiagram: {
	// Input: resources collection
	Input: [string]: vocab.#Resource

	// Configuration
	Config: #GraphvizConfig

	// Custom node styles (merged with defaults)
	NodeStyles: #DefaultNodeStyles

	// Build nodes with resolved styles
	_nodes: {
		for name, resource in Input {
			(name): {
				id:           strings.Replace(name, "-", "_", -1)
				resourceName: name
				displayName:  resource.name | name
				// Get first type from struct-as-set
				_typeList: [for t, _ in resource["@type"] {t}]
				_type:     *_typeList[0] | "VM"
				ip:        resource.ip | ""
				nodeStyle: NodeStyles[_type] | NodeStyles._default
			}
		}
	}

	// Build edges from depends_on
	_edges: [
		for name, resource in Input
		if resource.depends_on != _|_
		for dep, _ in resource.depends_on {
			from: strings.Replace(name, "-", "_", -1)
			to:   strings.Replace(dep, "-", "_", -1)
		},
	]

	// Generate DOT header
	_dotHeader: """
		digraph Graph {
		  layout="\(Config.layout)";
		  rankdir="\(Config.rankdir)";
		  splines="\(Config.splines)";
		  overlap="\(Config.overlap)";

		  graph [fontname="Helvetica", fontsize=12, bgcolor="#FAFAFA"];
		  node [fontname="Helvetica", fontsize=11, margin="0.2"];
		  edge [fontname="Helvetica", fontsize=10, color="#666666"];
		"""

	// Generate node definitions
	_dotNodes: strings.Join([
		for _, n in _nodes {
			"  " + n.id + " [label=\"" + n.nodeStyle.icon + " " + n.displayName + "\", shape=\"" + n.nodeStyle.shape + "\", fillcolor=\"" + n.nodeStyle.color + "\", fontcolor=\"" + n.nodeStyle.fontcolor + "\", style=\"" + n.nodeStyle.fillstyle + "\"];"
		},
	], "\n")

	// Generate edge definitions
	_dotEdges: strings.Join([
		for e in _edges {
			"  " + e.from + " -> " + e.to + ";"
		},
	], "\n")

	// Complete DOT output
	DOT: _dotHeader + "\n\n" + _dotNodes + "\n\n" + _dotEdges + "\n}"
}

// #MermaidDiagram - Generate Mermaid diagram from resources
#MermaidDiagram: {
	// Input: resources collection
	Input: [string]: vocab.#Resource

	// Direction: TB (top-bottom), LR (left-right), etc.
	Direction: *"LR" | "TB" | "BT" | "RL"

	// Build nodes
	_nodes: {
		for name, resource in Input {
			(name): {
				id:          strings.Replace(name, "-", "_", -1)
				displayName: resource.name | name
				// Get first type from struct-as-set
				_typeList: [for t, _ in resource["@type"] {t}]
				_type: *_typeList[0] | "Resource"
			}
		}
	}

	// Build edges from depends_on
	_edges: [
		for name, resource in Input
		if resource.depends_on != _|_
		for dep, _ in resource.depends_on {
			from: strings.Replace(name, "-", "_", -1)
			to:   strings.Replace(dep, "-", "_", -1)
		},
	]

	// Generate Mermaid flowchart
	Flowchart: strings.Join(list.Concat([
		["graph " + Direction],
		[
			for _, n in _nodes {
				"    " + n.id + "[" + n.displayName + "]"
			},
		],
		[""],
		[
			for e in _edges {
				"    " + e.from + " --> " + e.to
			},
		],
	]), "\n")
}

// #DependencyMatrix - Generate dependency matrix data
#DependencyMatrix: {
	// Input: resources collection
	Input: [string]: vocab.#Resource

	// For each resource, list what it depends on (convert struct keys to list)
	Dependencies: {
		for name, resource in Input {
			(name): [for d, _ in (*resource.depends_on | {}) {d}]
		}
	}

	// For each resource, list what depends on it (reverse lookup)
	Dependents: {
		for name, _ in Input {
			(name): [
				for other, resource in Input
				if resource.depends_on != _|_
				for dep, _ in resource.depends_on
				if dep == name {
					other
				},
			]
		}
	}

	// Resources with no dependencies (roots)
	Roots: [
		for name, deps in Dependencies
		if len(deps) == 0 {
			name
		},
	]

	// Resources with no dependents (leaves)
	Leaves: [
		for name, deps in Dependents
		if len(deps) == 0 {
			name
		},
	]
}
