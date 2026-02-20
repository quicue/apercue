// Graph analysis patterns — universal, domain-agnostic.
//
// These patterns extend #Graph with higher-order analysis:
//   #CycleDetector — validate DAG property before graph construction
//   #ConnectedComponents — find isolated subgraphs / orphans
//   #Subgraph — extract induced subgraph by roots, target, or radius
//   #GraphDiff — structural delta between two graph versions
//   #CriticalPath — CPM: earliest/latest times, slack, critical resources
//
// All patterns operate on the same typed dependency graph and compose
// with existing patterns via CUE unification.
//
// PERFORMANCE: bounded BFS uses 5 doubling steps (32-hop reach).
// Sufficient for graphs up to ~30 nodes. Add steps for larger graphs.

package patterns

import (
	"list"
	"apercue.ca/vocab"
)

// ═══════════════════════════════════════════════════════════════════════════
// STRUCTURAL ANALYSIS
// ═══════════════════════════════════════════════════════════════════════════

// #CycleDetector — Validate that a resource set is acyclic (DAG).
//
// Runs on RAW input before #Graph construction. If #Graph receives
// cyclic input, CUE's fixpoint computation diverges (structural cycle error).
// Use #CycleDetector first to get a clean diagnostic.
//
// Algorithm: bounded-depth BFS with doubling. Each step extends reachability
// by composing previous results. After 5 steps → 32-hop reach. A node that
// appears in its own reachability set is on a cycle.
//
// Usage:
//   check: #CycleDetector & {Input: rawResources}
//   // check.acyclic == true → safe to build #Graph
//   // check.cycles lists offending resources if cyclic
//
#CycleDetector: {
	Input: [string]: {
		name: string
		depends_on?: {[string]: true}
		...
	}

	_names: {for n, _ in Input {(n): true}}

	// Step 0: direct dependencies (filtered to valid names)
	_r0: {
		for name, r in Input {
			(name): {
				if r.depends_on != _|_ {
					for d, _ in r.depends_on if _names[d] != _|_ {(d): true}
				}
			}
		}
	}

	// Each step: reach ∪ (∪ reach[d] for d in reach) — doubles hop distance
	_r1: {for n, reach in _r0 {(n): reach & {for d, _ in reach if _r0[d] != _|_ {_r0[d]}}}}
	_r2: {for n, reach in _r1 {(n): reach & {for d, _ in reach if _r1[d] != _|_ {_r1[d]}}}}
	_r3: {for n, reach in _r2 {(n): reach & {for d, _ in reach if _r2[d] != _|_ {_r2[d]}}}}
	_r4: {for n, reach in _r3 {(n): reach & {for d, _ in reach if _r3[d] != _|_ {_r3[d]}}}}
	_r5: {for n, reach in _r4 {(n): reach & {for d, _ in reach if _r4[d] != _|_ {_r4[d]}}}}

	// Cycle: node appears in its own reachability set
	cycles: [
		for name, reach in _r5
		if reach[name] != _|_ {
			resource: name
			// Hint: which direct deps lead back to this node?
			via: [for d, _ in _r0[name] if _r5[d] != _|_ && _r5[d][name] != _|_ {d}]
		},
	]

	has_cycles: len(cycles) > 0
	acyclic:    !has_cycles
}

// #ConnectedComponents — Find weakly connected components in the graph.
//
// Two resources are in the same component if connected by any path
// (ignoring edge direction). Useful for finding orphaned resources
// that have no dependency relationship with the main cluster.
//
// Leverages #Graph's pre-computed _ancestors and dependents for
// efficient undirected reachability (one BFS step suffices).
//
// Usage:
//   cc: #ConnectedComponents & {Graph: g}
//   // cc.count — number of components
//   // cc.is_connected — true if entire graph is one component
//   // cc.isolated — single-node components (potential orphans)
//   // cc.components — {canonical_label: {member: true, ...}, ...}
//
#ConnectedComponents: {
	Graph: #AnalyzableGraph

	// Directed reach: self ∪ ancestors ∪ dependents
	_reach: {
		for name, r in Graph.resources {
			(name): {
				(name): true
				r._ancestors
				Graph.dependents[name]
			}
		}
	}

	// One BFS step: extend reach via all reachable nodes' reach sets.
	// This gives full undirected transitive closure because any two nodes
	// in the same component share a common hub in the directed DAG.
	_full: {
		for name, reach in _reach {
			(name): reach & {
				for d, _ in reach if _reach[d] != _|_ {
					_reach[d]
				}
			}
		}
	}

	// Canonical label: lexicographically first member in component
	_canon: {
		for name, reach in _full {
			let _sorted = list.Sort([for m, _ in reach {m}], {x: _, y: _, less: x < y})
			(name): _sorted[0]
		}
	}

	// Group by canonical label
	components: {
		for name, label in _canon {
			(label): (name): true
		}
	}

	// Isolated nodes: single-member components (disconnected from everything)
	isolated: {
		for label, members in components
		if len([for m, _ in members {m}]) == 1 {
			(label): true
		}
	}

	count:        len([for c, _ in components {c}])
	is_connected: count == 1
}

// ═══════════════════════════════════════════════════════════════════════════
// SUBGRAPH EXTRACTION
// ═══════════════════════════════════════════════════════════════════════════

// #Subgraph — Extract an induced subgraph by roots, target, or radius.
//
// Selection modes (provide one):
//   Roots: include roots and all their transitive dependents
//   Target + Mode: include target and neighbors by direction
//   Target + Radius: limit to N layers from target
//
// Returns the selected node set and internal edges. Consumers can use
// the `selected` set to filter their own resource collections.
//
// Usage:
//   // Everything downstream of "auth"
//   sub: #Subgraph & {Graph: g, Roots: {"auth": true}}
//
//   // Everything within 2 layers of "web-app" in both directions
//   sub: #Subgraph & {Graph: g, Target: "web-app", Radius: 2, Mode: "both"}
//
#Subgraph: {
	Graph: #AnalyzableGraph

	// Selection criteria (provide at least one)
	Roots?:  {[string]: true}
	Target?: string
	Radius?: int
	Mode:    *"descendants" | "ancestors" | "both"

	// Computed: the set of selected nodes
	selected: {
		// Root-anchored: roots + all transitive dependents
		if Roots != _|_ {
			Roots
			for root, _ in Roots {
				Graph.dependents[root]
			}
		}

		// Target-anchored
		if Target != _|_ {
			(Target): true

			if Mode == "descendants" || Mode == "both" {
				if Radius != _|_ {
					let _targetDepth = Graph.resources[Target]._depth
					for name, _ in Graph.dependents[Target]
					if Graph.resources[name]._depth - _targetDepth <= Radius {
						(name): true
					}
				}
				if Radius == _|_ {
					Graph.dependents[Target]
				}
			}

			if Mode == "ancestors" || Mode == "both" {
				if Radius != _|_ {
					let _targetDepth = Graph.resources[Target]._depth
					for name, _ in Graph.resources[Target]._ancestors
					if _targetDepth - Graph.resources[name]._depth <= Radius {
						(name): true
					}
				}
				if Radius == _|_ {
					Graph.resources[Target]._ancestors
				}
			}
		}
	}

	// Edges within the subgraph (induced: both endpoints must be selected)
	edges: [
		for name, _ in selected
		if Graph.resources[name].depends_on != _|_
		for dep, _ in Graph.resources[name].depends_on
		if selected[dep] != _|_ {
			{source: dep, target: name}
		},
	]

	summary: {
		total: len([for n, _ in selected {n}])
		edges: len(edges)
	}
}

// ═══════════════════════════════════════════════════════════════════════════
// GRAPH COMPARISON
// ═══════════════════════════════════════════════════════════════════════════

// #GraphDiff — Structural delta between two graph versions.
//
// Compares Before and After graphs, producing:
//   added/removed nodes, type changes, added/removed edges.
//
// Useful for change review, drift analysis, and computing the blast radius
// of structural changes (compose with #CompoundRiskAnalysis on changed nodes).
//
// Usage:
//   diff: #GraphDiff & {Before: graphV1, After: graphV2}
//   // diff.summary.has_changes — quick check
//   // diff.added_nodes, diff.removed_nodes — topology changes
//   // diff.added_edges, diff.removed_edges — dependency changes
//
#GraphDiff: {
	Before: #AnalyzableGraph
	After:  #AnalyzableGraph

	// Added nodes (in After but not Before)
	added_nodes: {
		for name, _ in After.resources
		if Before.resources[name] == _|_ {
			(name): After.resources[name]["@type"]
		}
	}

	// Removed nodes (in Before but not After)
	removed_nodes: {
		for name, _ in Before.resources
		if After.resources[name] == _|_ {
			(name): Before.resources[name]["@type"]
		}
	}

	// Type changes (nodes present in both with different @type)
	type_changes: {
		for name, r in After.resources
		if Before.resources[name] != _|_
		let _before = Before.resources[name]
		let _added = {for t, _ in r["@type"] if _before["@type"][t] == _|_ {(t): true}}
		let _removed = {for t, _ in _before["@type"] if r["@type"][t] == _|_ {(t): true}}
		let _hasChanges = len([for t, _ in _added {t}]) + len([for t, _ in _removed {t}]) > 0
		if _hasChanges {
			(name): {
				added_types:   _added
				removed_types: _removed
			}
		}
	}

	// Added edges (new dependency relationships)
	added_edges: [
		for name, r in After.resources
		if r.depends_on != _|_
		for dep, _ in r.depends_on
		if Before.resources[name] == _|_ ||
			Before.resources[name].depends_on == _|_ ||
			Before.resources[name].depends_on[dep] == _|_ {
			{source: dep, target: name}
		},
	]

	// Removed edges
	removed_edges: [
		for name, r in Before.resources
		if r.depends_on != _|_
		for dep, _ in r.depends_on
		if After.resources[name] == _|_ ||
			After.resources[name].depends_on == _|_ ||
			After.resources[name].depends_on[dep] == _|_ {
			{source: dep, target: name}
		},
	]

	summary: {
		added_node_count:   len([for n, _ in added_nodes {n}])
		removed_node_count: len([for n, _ in removed_nodes {n}])
		type_change_count:  len([for n, _ in type_changes {n}])
		added_edge_count:   len(added_edges)
		removed_edge_count: len(removed_edges)
		has_changes:        added_node_count > 0 || removed_node_count > 0 || type_change_count > 0 || added_edge_count > 0 || removed_edge_count > 0
	}
}

// ═══════════════════════════════════════════════════════════════════════════
// SCHEDULING / CRITICAL PATH
// ═══════════════════════════════════════════════════════════════════════════

// #CriticalPath — Critical Path Method analysis on a dependency graph.
//
// Computes earliest/latest start times and slack for each resource.
// Resources with zero slack form the critical path — any delay on these
// delays the entire project/deployment.
//
// Weights are optional durations per resource (default: 1 unit each).
// Compose with #Charter gates for milestone-aware scheduling.
//
// Usage:
//   cpm: #CriticalPath & {
//     Graph: g
//     Weights: {"database": 5, "web-app": 2}  // optional durations
//   }
//   // cpm.critical — resources on the critical path
//   // cpm.total_duration — project duration
//   // cpm.slack — per-resource float time
//
#CriticalPath: {
	Graph:    #AnalyzableGraph
	Weights?:  [string]: number
	UnitType:  string | *"time:unitDay" // OWL-Time unit (e.g. time:unitDay, time:unitHour)

	// Helper: duration for a resource (default 1)
	_dur: {
		for name, _ in Graph.resources {
			(name): [
				if Weights != _|_ && Weights[name] != _|_ {Weights[name]},
				1,
			][0]
		}
	}

	// Forward pass: earliest start time (recursive from roots)
	// EST[n] = max(EST[d] + dur[d]) for all dependencies d of n
	_earliest: {
		for name, r in Graph.resources {
			let _deps = *r.depends_on | {}
			(name): [
				if len([for d, _ in _deps {d}]) > 0 {
					list.Max([for d, _ in _deps {_earliest[d] + _dur[d]}])
				},
				0,
			][0]
		}
	}

	// Finish time per resource
	_finish: {
		for name, _ in Graph.resources {
			(name): _earliest[name] + _dur[name]
		}
	}

	// Total project duration
	_allFinish: [for _, f in _finish {f}]
	total_duration: [
		if len(_allFinish) > 0 {list.Max(_allFinish)},
		0,
	][0]

	// Precompute immediate dependents map: O(edges), not O(n²)
	// Maps each resource to the set of resources that directly depend on it.
	_immDeps: {
		for name, _ in Graph.resources {(name): {}}
		for rname, r in Graph.resources if r.depends_on != _|_ {
			for dep, _ in r.depends_on {
				(dep): (rname): true
			}
		}
	}

	// Backward pass: latest start time (recursive from leaves)
	// LST[n] = min(LST[d]) - dur[n] for all immediate dependents d of n
	_latest: {
		for name, _ in Graph.resources {
			let _deps = [for d, _ in _immDeps[name] {_latest[d]}]
			(name): [
				if len(_deps) > 0 {
					list.Min(_deps) - _dur[name]
				},
				total_duration - _dur[name],
			][0]
		}
	}

	// Slack: how much a resource can be delayed without affecting total duration
	slack: {
		for name, _ in Graph.resources {
			(name): _latest[name] - _earliest[name]
		}
	}

	// Critical path: resources with zero slack
	critical: {
		for name, s in slack
		if s == 0 {
			(name): {
				start:    _earliest[name]
				finish:   _finish[name]
				duration: _dur[name]
			}
		}
	}

	// Ordered critical path (by start time)
	critical_sequence: list.Sort([
		for name, c in critical {
			{resource: name} & c
		},
	], {x: {}, y: {}, less: x.start < y.start})

	// Hidden intermediaries to avoid self-reference inside summary
	// (same pattern as charter.cue — field names shadow outer scope)
	_total_dur:  total_duration
	_crit_count: len([for c, _ in critical {c}])
	_res_count:  len(Graph.resources)
	_max_slack: [
		if len([for _, s in slack {s}]) > 0 {
			list.Max([for _, s in slack {s}])
		},
		0,
	][0]

	summary: {
		total_duration:  _total_dur
		critical_count:  _crit_count
		total_resources: _res_count
		max_slack:       _max_slack
	}

	// ── OWL-Time projection ───────────────────────────────────────
	// W3C OWL-Time (Recommendation, 2017 / CRD 2022): express
	// scheduled intervals using Allen's temporal algebra.
	// Domain extensions: apercue:slack, apercue:isCritical.
	//
	// Export: cue export -e cpm.time_report --out json
	time_report: {
		"@context": vocab.context["@context"]
		for name, _ in Graph.resources {
			(name): {
				"@type": "time:Interval"
				"time:hasBeginning": {
					"@type":              "time:Instant"
					"time:inXSDDecimal":  _earliest[name]
				}
				"time:hasEnd": {
					"@type":              "time:Instant"
					"time:inXSDDecimal":  _finish[name]
				}
				"time:hasDuration": {
					"@type":                "time:Duration"
					"time:numericDuration": _dur[name]
					"time:unitType":        {"@id": UnitType}
				}
				"apercue:slack":      slack[name]
				"apercue:isCritical": critical[name] != _|_
			}
		}
	}
}

// #CriticalPathPrecomputed — CPM with Python-precomputed scheduling data.
//
// CUE's recursive fixpoint evaluation is too slow for forward/backward
// passes on graphs >20 nodes. This pattern takes precomputed earliest,
// latest, and duration values from Python and produces the same outputs
// (summary, critical path, OWL-Time projection).
//
// Usage:
//   python3 tools/toposort.py ./dir/ --cue --cpm > precomputed.cue
//   cpm: patterns.#CriticalPathPrecomputed & {
//     Graph: graph
//     Precomputed: _precomputed_cpm
//   }
//
#CriticalPathPrecomputed: {
	Graph:    #AnalyzableGraph
	UnitType: string | *"time:unitDay"

	Precomputed: {
		earliest: [string]: number
		latest:   [string]: number
		duration: [string]: number
	}

	// Derived from precomputed values
	_finish: {for name, _ in Graph.resources {(name): Precomputed.earliest[name] + Precomputed.duration[name]}}

	slack: {for name, _ in Graph.resources {(name): Precomputed.latest[name] - Precomputed.earliest[name]}}

	_allFinish: [for _, f in _finish {f}]
	total_duration: [
		if len(_allFinish) > 0 {list.Max(_allFinish)},
		0,
	][0]

	critical: {
		for name, s in slack if s == 0 {
			(name): {
				start:    Precomputed.earliest[name]
				finish:   _finish[name]
				duration: Precomputed.duration[name]
			}
		}
	}

	critical_sequence: list.Sort([
		for name, c in critical {{resource: name} & c},
	], {x: {}, y: {}, less: x.start < y.start})

	_total_dur:  total_duration
	_crit_count: len([for c, _ in critical {c}])
	_res_count:  len(Graph.resources)
	_max_slack: [
		if len([for _, s in slack {s}]) > 0 {list.Max([for _, s in slack {s}])},
		0,
	][0]

	summary: {
		total_duration:  _total_dur
		critical_count:  _crit_count
		total_resources: _res_count
		max_slack:       _max_slack
	}

	// OWL-Time projection — same output shape as #CriticalPath
	time_report: {
		"@context": vocab.context["@context"]
		for name, _ in Graph.resources {
			(name): {
				"@type": "time:Interval"
				"time:hasBeginning": {
					"@type":              "time:Instant"
					"time:inXSDDecimal":  Precomputed.earliest[name]
				}
				"time:hasEnd": {
					"@type":              "time:Instant"
					"time:inXSDDecimal":  _finish[name]
				}
				"time:hasDuration": {
					"@type":                "time:Duration"
					"time:numericDuration": Precomputed.duration[name]
					"time:unitType":        {"@id": UnitType}
				}
				"apercue:slack":      slack[name]
				"apercue:isCritical": critical[name] != _|_
			}
		}
	}
}
