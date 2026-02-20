// Graph patterns for typed dependency analysis.
//
// Computes: _depth, _ancestors, _path, topology, roots, leaves.
// Assumes DAG. _path follows first parent only.
//
// PERFORMANCE (tested to 1000 nodes):
// - Validation, depth, grouping: <0.5s (no transitive closure)
// - Impact/criticality queries: 1-5s (needs _ancestors)
// - Graph shape matters: wide trees (depth~10) are 10x faster than linear chains
// - Use struct field presence ({key: true}) over list.Contains for O(1) vs O(n)

package patterns

import "list"

// #GraphResource — Schema for resources with computed graph properties.
// Use this when you want automatic depth, ancestors, etc.
#GraphResource: {
	name: string
	"@type": {[string]: true}

	// Dependencies — set membership (clean unification)
	depends_on?: {[string]: true}

	// Metadata
	tags?:        {[string]: true}
	description?: string

	// Computed: depth in dependency graph (0 = root)
	_depth: int

	// Computed: all ancestors (transitive closure)
	_ancestors: {[string]: bool}

	// Computed: path to root (via first dependency)
	_path: [...string]

	// Allow extension
	...
}

// #Graph — Convert string-based resources to ref-based graph with computed properties.
//
// Usage:
//   _raw: { "dns": {name: "dns", depends_on: {"db": true}} }
//   g: #Graph & {Input: _raw}
//   // g.resources.dns._depth, g.resources.dns._ancestors, etc.
//
// For large graphs, pre-compute depth with Python:
//   g: #Graph & {Input: _raw, Precomputed: {depth: {"dns": 0, ...}}}
//
#Graph: {
	// Input: string-based resources (portable, can come from JSON)
	Input: [string]: {
		name: string
		"@type": {[string]: true}
		depends_on?: {[string]: true}
		...
	}

	// Optional: pre-computed depth values from Python (for large graphs)
	// When provided, skips expensive CUE depth recursion
	Precomputed?: {
		depth: [string]: int
	}

	// Validation: all dependency references must exist in Input
	_inputNames: {for n, _ in Input {(n): true}}
	_missingDepsNested: [
		for rname, r in Input if r.depends_on != _|_ {
			[for dep, _ in r.depends_on if _inputNames[dep] == _|_ {
				{resource: rname, missing: dep}
			}]
		},
	]
	_missingDeps: list.FlattenN(_missingDepsNested, 1)
	// Expose validation status (check this before using graph)
	valid: len(_missingDeps) == 0

	// Output: ref-based resources with computed graph properties
	resources: {
		for rname, r in Input {
			// Normalize depends_on: absent or empty becomes {}
			let _deps = *r.depends_on | {}
			let _hasDeps = len(_deps) > 0
			// Convert struct keys to list for ordered operations
			let _depsList = [for d, _ in _deps {d}]

			(rname): r & {
				// Depth: use pre-computed if available, else compute
				// Pre-computed: O(1) lookup from Python topological sort
				// Computed: O(n) recursive access (expensive for large graphs)
				_depth: [
					if Precomputed != _|_ && Precomputed.depth[rname] != _|_ {
						Precomputed.depth[rname]
					},
					if _hasDeps {list.Max([for d, _ in _deps {resources[d]._depth}]) + 1},
					0,
				][0]

				// Ancestors: transitive closure of all dependencies.
				// Uses CUE unification for fixpoint computation (rogpeppe pattern).
				// [_]: true declares shape, then direct unification merges ancestors.
				_ancestors: {
					[_]: true
					if _hasDeps {
						for d, _ in _deps {
							(d): true
							resources[d]._ancestors
						}
					}
				}

				// Path: route to root via FIRST parent only
				// NOTE: For multi-parent DAGs, use _ancestors for complete closure
				_path: [
					if _hasDeps {list.Concat([[rname], resources[_depsList[0]]._path])},
					[rname],
				][0]
			}
		}
	}

	// Computed: topology layers
	topology: {
		for rname, r in resources {
			"layer_\(r._depth)": (rname): true
		}
	}

	// Computed: root nodes (no dependencies)
	roots: {for rname, r in resources if r._depth == 0 {(rname): true}}

	// Computed: leaf nodes (nothing depends on them)
	_hasDependents: {
		for _, r in resources if r.depends_on != _|_ {
			for d, _ in r.depends_on {(d): true}
		}
	}
	leaves: {for rname, _ in resources if _hasDependents[rname] == _|_ {(rname): true}}

	// Pre-computed dependents: inverse of _ancestors for O(1) impact lookups
	// Instead of computing via pattern instantiation (O(n³)), pre-compute once (O(n²))
	dependents: {
		for t, _ in resources {
			(t): {for n, r in resources if r._ancestors[t] != _|_ {(n): true}}
		}
	}
}

// #ImpactQuery — Find all resources affected if target goes down
//
// Usage:
//   impact: #ImpactQuery & {Graph: g, Target: "dns-primary"}
//   // impact.affected = {"web-app": true, "api": true, ...}
//
#ImpactQuery: {
	Graph:  #Graph
	Target: string

	affected: {
		for rname, r in Graph.resources
		if r._ancestors[Target] != _|_ {(rname): true}
	}

	affected_count: len([for k, _ in affected {k}])
}

// #DependencyChain — Get full dependency chain for a resource
//
// Usage:
//   chain: #DependencyChain & {Graph: g, Target: "frontend"}
//   // chain.path = ["frontend", "web-app", "db", "storage"]
//
#DependencyChain: {
	Graph:  #Graph
	Target: string

	path:      Graph.resources[Target]._path
	depth:     Graph.resources[Target]._depth
	ancestors: Graph.resources[Target]._ancestors
}

// #GroupByType — Group resources by @type
//
// Usage:
//   byType: #GroupByType & {Graph: g}
//   // byType.groups.Database = ["postgres": true, "mongo": true]
//
#GroupByType: {
	Graph: #Graph

	// Build groups using struct accumulation (avoids empty entries from nested for)
	groups: {
		for rname, r in Graph.resources {
			for t, _ in r["@type"] {
				(t): (rname): true
			}
		}
	}

	counts: {
		for typeName, members in groups {
			(typeName): len([for m, _ in members {m}])
		}
	}
}

// #CriticalityRank — Rank resources by how many things depend on them
//
// Usage:
//   crit: #CriticalityRank & {Graph: g}
//   // crit.ranked = [{name: "auth", dependents: 8}, ...]
//
#CriticalityRank: {
	Graph: #Graph

	ranked: [
		for rname, _ in Graph.resources {
			name: rname
			dependents: len([
				for _, r in Graph.resources
				if r._ancestors[rname] != _|_ {r.name},
			])
		},
	]
}

// #RiskScore — Compute risk score per resource
//
// Risk score = direct dependents × (transitive dependents + 1)
// Higher scores indicate resources whose failure has wider blast radius.
//
// Usage:
//   risk: #RiskScore & {Graph: g}
//   // risk.ranked = [{name: "auth", score: 150, direct: 5, transitive: 29}, ...]
//
#RiskScore: {
	Graph: #Graph

	// For each resource, compute risk score using O(1) dependents lookup
	// direct = number of immediate dependents (from Graph.dependents)
	// transitive = number of ALL resources that depend on this (via _ancestors)
	ranked: list.Sort([
		for rname, _ in Graph.resources {
			let _direct = len([for k, _ in Graph.dependents[rname] {k}])
			let _transitive = len([
				for rname2, r2 in Graph.resources
				if r2._ancestors[rname] != _|_ && rname2 != rname {rname2}
			])
			name:       rname
			direct:     _direct
			transitive: _transitive
			score:      _direct * (_transitive + 1)
		},
	], {x: {}, y: {}, less: x.score > y.score})
}

// #ImmediateDependents — Find resources that directly depend on target
//
// Usage:
//   deps: #ImmediateDependents & {Graph: g, Target: "auth"}
//   // deps.dependents = {api: true, web: true} (only direct, not transitive)
//
#ImmediateDependents: {
	Graph:  #Graph
	Target: string

	dependents: {
		for rname, r in Graph.resources
		if r.depends_on != _|_
		if r.depends_on[Target] != _|_ {(rname): true}
	}

	count: len([for k, _ in dependents {k}])
}

// #GraphMetrics — Summary statistics for the graph
//
// Usage:
//   metrics: #GraphMetrics & {Graph: g}
//   // metrics.total_resources, metrics.max_depth, etc.
//
#GraphMetrics: {
	Graph: #Graph

	total_resources: len(Graph.resources)
	root_count:      len(Graph.roots)
	leaf_count:      len(Graph.leaves)
	_depths: [for _, r in Graph.resources {r._depth}]
	// Guard: handle empty graph (no resources)
	max_depth: *0 | int
	if len(_depths) > 0 {
		max_depth: list.Max(_depths)
	}
	total_edges: len([
		for _, r in Graph.resources
		if r.depends_on != _|_ {
			for _, _ in r.depends_on {1}
		},
	])
}

// #ExportGraph — Export graph with clean IDs for external consumption
//
// Usage:
//   export: #ExportGraph & {Graph: g}
//   // export.resources = [{name: "auth", depends_on: {"db": true}, ...}, ...]
//
#ExportGraph: {
	Graph: #Graph

	// Export resources as flat list with string references (no CUE refs)
	resources: [
		for rname, r in Graph.resources {
			name:    rname
			"@type": r["@type"]
			if r.depends_on != _|_ {depends_on: r.depends_on}
			depth: r._depth
			ancestors: [for a, _ in r._ancestors {a}]
		},
	]

	// Compute max_depth from exported resources (avoids hidden field access issues)
	_depths: [for r in resources {r.depth}]

	// Summary metrics
	summary: {
		total:  len(resources)
		roots:  Graph.roots
		leaves: Graph.leaves
		// Guard: handle empty graph
		max_depth: *0 | int
		if len(_depths) > 0 {
			max_depth: list.Max(_depths)
		}
	}
}

// #ValidateGraph — Validate graph structure and return issues
//
// Usage:
//   validate: #ValidateGraph & {Input: myResources}
//   // validate.valid == true if no issues
//   // validate.issues contains any problems found
//
#ValidateGraph: {
	Input: [string]: {
		name: string
		"@type": {[string]: true}
		depends_on?: {[string]: true}
		...
	}

	_names: {for n, _ in Input {(n): true}}

	// Check for missing dependency references
	_missingDeps: [
		for rname, r in Input
		if r.depends_on != _|_
		for dep, _ in r.depends_on
		if _names[dep] == _|_ {
			resource: rname
			missing:  dep
		},
	]

	// Check for self-references
	_selfRefs: [
		for rname, r in Input
		if r.depends_on != _|_
		if r.depends_on[rname] != _|_ {
			resource: rname
		},
	]

	// Check for empty @type (struct with no fields)
	_emptyTypes: [
		for rname, r in Input
		if len([for t, _ in r["@type"] {t}]) == 0 {
			resource: rname
		},
	]

	issues: {
		missing_dependencies: _missingDeps
		self_references:      _selfRefs
		empty_types:          _emptyTypes
	}

	valid: len(_missingDeps) == 0 && len(_selfRefs) == 0 && len(_emptyTypes) == 0
}

// #VizData — Generate visualization data for the graph explorer
//
// Usage:
//   viz: #VizData & {Graph: g, Resources: _resources}
//   // Export: cue export -e viz.data --out json
//
#VizData: {
	Graph: #Graph
	Resources: [string]: {...}

	// Compute helper patterns
	_criticality: #CriticalityRank & {"Graph": Graph}
	_byType: #GroupByType & {"Graph": Graph}
	_export: #ExportGraph & {"Graph": Graph}
	_spof: #SinglePointsOfFailure & {"Graph": Graph}

	// Build edges from raw resources
	_edges: list.FlattenN([
		for rname, r in Resources if r.depends_on != _|_ {
			[for dep, _ in r.depends_on {{source: dep, target: rname}}]
		},
	], 1)

	// Build nodes with computed properties
	// Uses Graph.dependents (struct-as-set) for O(1) lookup
	_nodes: [
		for r in _export.resources {
			let _directDeps = len([for k, _ in Graph.dependents[r.name] {k}])
			let _transitive = len([
				for rname2, r2 in Graph.resources
				if r2._ancestors[r.name] != _|_ && rname2 != r.name {rname2}
			])
			id:         r.name
			name:       r.name
			types:      [for t, _ in r["@type"] {t}]
			depth:      r.depth
			ancestors:  r.ancestors
			dependents: _directDeps
			// Risk score: direct dependents × (transitive dependents + 1)
			risk_score: _directDeps * (_transitive + 1)
		},
	]

	// Convert topology layers to arrays
	_topology: {
		for layerName, members in Graph.topology {
			(layerName): [for m, _ in members {m}]
		}
	}

	// Format criticality for export
	_critList: [
		for c in _criticality.ranked {
			name:       c.name
			dependents: c.dependents
		},
	]

	// Format SPOF risks for export (filter out empty structs from conditional comprehension)
	_spofList: [
		for s in _spof.risks
		if s.name != _|_ {
			name:       s.name
			dependents: s.dependents
			types:      [for t, _ in s.types {t}]
			depth:      s.depth
		},
	]

	// Coupling points: resources where >30% of graph depends on them
	_totalNodes: len(_nodes)
	_couplingThreshold: _totalNodes * 3 / 10 // 30%
	_couplingRaw: [
		for rname, deps in Graph.dependents {
			let _count = len([for k, _ in deps {k}])
			name:       rname
			dependents: _count
			percentage: _count * 100 / _totalNodes
		},
	]
	_couplingList: [for c in _couplingRaw if c.dependents >= _couplingThreshold {c}]

	// The output data structure (arrays for JavaScript compatibility)
	data: {
		nodes:       _nodes
		edges:       _edges
		topology:    _topology
		roots:       [for r, _ in Graph.roots {r}]
		leaves:      [for l, _ in Graph.leaves {l}]
		criticality: _critList
		byType: {for t, members in _byType.groups {(t): [for m, _ in members {m}]}}
		spof:        _spofList
		coupling:    _couplingList
		metrics: {
			total:    len(_nodes)
			maxDepth: _export.summary.max_depth
			edges:    len(_edges)
			roots:    len([for r, _ in Graph.roots {r}])
			leaves:   len([for l, _ in Graph.leaves {l}])
			spofCount: len(_spofList)
			couplingCount: len(_couplingList)
		}
		validation: {
			valid: Graph.valid
			issues: []
		}
	}
}

// ═══════════════════════════════════════════════════════════════════════════
// OPERATIONAL PATTERNS
// These patterns enable deployment orchestration, health tracking, and
// change management based on the dependency graph.
// ═══════════════════════════════════════════════════════════════════════════

// #HealthStatus — Propagate health through the graph
//
// If a resource is "down", all its dependents become "degraded".
// Health flows upward: roots can be healthy/down, dependents inherit degraded status.
//
// Usage:
//   health: #HealthStatus & {
//       Graph: g
//       Status: {"auth": "down", "db": "healthy"}  // known statuses
//   }
//   // health.propagated.web = "degraded" (depends on auth)
//
#HealthStatus: {
	Graph: #Graph
	Status: [string]: "healthy" | "degraded" | "down"

	// Resources explicitly marked as down
	_down: {for name, s in Status if s == "down" {(name): true}}

	// Propagate: if any ancestor is down, resource is degraded
	propagated: {
		for rname, r in Graph.resources {
			(rname): *"healthy" | "degraded" | "down"
			if Status[rname] != _|_ {
				(rname): Status[rname]
			}
			if Status[rname] == _|_ {
				// Check if any ancestor is down
				let hasDownAncestor = len([for a, _ in r._ancestors if _down[a] != _|_ {a}]) > 0
				if hasDownAncestor {
					(rname): "degraded"
				}
			}
		}
	}

	// Summary counts
	summary: {
		healthy: len([for _, s in propagated if s == "healthy" {1}])
		degraded: len([for _, s in propagated if s == "degraded" {1}])
		down: len([for _, s in propagated if s == "down" {1}])
	}
}

// #BlastRadius — Analyze impact of a change before making it
//
// Shows what resources are affected, in what order to rollback,
// and what can safely be taken down together.
//
// Usage:
//   blast: #BlastRadius & {Graph: g, Target: "auth"}
//   // blast.affected = {api: true, web: true}
//   // blast.rollback_order = ["web", "api", "auth"]  // leaves first
//   // blast.safe_peers = {logging: true}  // same layer, not affected
//
#BlastRadius: {
	Graph:  #Graph
	Target: string

	// All resources that depend on target (transitively)
	_impact: #ImpactQuery & {"Graph": Graph, "Target": Target}
	affected: _impact.affected

	// Target's depth for layer analysis
	_targetDepth: Graph.resources[Target]._depth

	// Rollback order: affected resources sorted by depth (deepest first), then target
	_affectedWithDepth: [
		for rname, _ in affected {
			name:  rname
			depth: Graph.resources[rname]._depth
		},
	]
	_sortedAffected: list.Sort(_affectedWithDepth, {x: {}, y: {}, less: x.depth > y.depth})
	rollback_order: list.Concat([[for r in _sortedAffected {r.name}], [Target]])

	// Startup order: reverse of rollback (target first, then dependents by layer)
	startup_order: list.Reverse(rollback_order)

	// Safe peers: resources at same layer that aren't affected
	_layerKey: "layer_\(_targetDepth)"
	safe_peers: {
		for name, _ in Graph.topology[_layerKey]
		if name != Target && affected[name] == _|_ {(name): true}
	}

	// Summary
	summary: {
		target:          Target
		affected_count:  len([for k, _ in affected {k}])
		rollback_steps:  len(rollback_order)
		safe_peer_count: len([for k, _ in safe_peers {k}])
	}
}

// #ZoneAwareBlastRadius — Blast radius analysis with zone grouping
//
// Extends #BlastRadius to group affected resources by zone.
// Zones are assigned via resource metadata (zone or networkLocation fields).
//
// Usage:
//   zblast: #ZoneAwareBlastRadius & {
//     Graph: g
//     Target: "auth"
//     Zones: {"auth": "Restricted", "web": "Public", ...}  // resource → zone mapping
//   }
//
#ZoneAwareBlastRadius: {
	Graph:  #Graph
	Target: string
	Zones: [string]: string // resource name → zone name

	_blast: #BlastRadius & {"Graph": Graph, "Target": Target}
	affected:       _blast.affected
	rollback_order: _blast.rollback_order
	startup_order:  _blast.startup_order
	safe_peers:     _blast.safe_peers

	// Group affected resources by zone
	by_zone: {
		for rname, _ in affected {
			let _zone = *Zones[rname] | "Unknown"
			(_zone): (rname): true
		}
	}

	// Zone risk levels based on affected count
	zone_risk: {
		for zoneName, members in by_zone {
			let _count = len([for m, _ in members {m}])
			let _level = [
				if _count >= 10 {"critical"},
				if _count >= 5 {"high"},
				if _count >= 2 {"medium"},
				"low",
			][0]
			(zoneName): {
				count: _count
				level: _level
			}
		}
	}

	summary: _blast.summary & {
		zones_affected: len([for z, _ in by_zone {z}])
	}
}

// #CompoundRiskAnalysis — Analyze compound risk from multiple simultaneous changes
//
// When multiple resources are changed at once, some downstream resources
// may be affected by more than one change ("compound risk").
//
// Usage:
//   compound: #CompoundRiskAnalysis & {
//     Graph: g
//     Targets: ["auth", "db"]
//   }
//
#CompoundRiskAnalysis: {
	Graph: #Graph
	Targets: [...string]

	// Compute blast radius per target
	_blasts: {
		for _, t in Targets {
			(t): #ImpactQuery & {"Graph": Graph, "Target": t}
		}
	}

	// Find resources affected by each target
	_exposure: {
		for rname, r in Graph.resources {
			let _hitBy = [
				for _, t in Targets
				if _blasts[t].affected[rname] != _|_ {t},
			]
			if len(_hitBy) > 0 {
				(rname): {
					affected_by: _hitBy
					compound:    len(_hitBy) >= 2
				}
			}
		}
	}

	// Resources hit by 2+ changes
	compound_risk: {
		for rname, exp in _exposure if exp.compound {
			(rname): exp.affected_by
		}
	}

	// All affected resources (union)
	all_affected: {
		for rname, _ in _exposure {(rname): true}
	}

	summary: {
		targets:             len(Targets)
		total_affected:      len([for k, _ in _exposure {k}])
		compound_risk_count: len([for k, _ in compound_risk {k}])
	}
}

// #DeploymentPlan — Generate layer-by-layer deployment sequence
//
// Converts topology into actionable deployment steps with explicit
// layer boundaries for gating/approval.
//
// Usage:
//   deploy: #DeploymentPlan & {Graph: g}
//   // deploy.layers = [
//   //   {layer: 0, resources: ["storage"], gate: "Layer 0 complete"},
//   //   {layer: 1, resources: ["db", "auth"], gate: "Layer 1 complete"},
//   //   ...
//   // ]
//
#DeploymentPlan: {
	Graph: #Graph

	_metrics: #GraphMetrics & {"Graph": Graph}
	_maxDepth: _metrics.max_depth

	// Build ordered layers
	layers: [
		for d in list.Range(0, _maxDepth+1, 1) {
			layer: d
			resources: [
				for rname, r in Graph.resources
				if r._depth == d {rname},
			]
			gate: "Layer \(d) complete - ready for layer \(d+1)"
		},
	]

	// Flatten for simple iteration
	startup_sequence: list.FlattenN([for l in layers {l.resources}], 1)
	shutdown_sequence: list.Reverse(startup_sequence)

	// Summary
	summary: {
		total_layers:    len(layers)
		total_resources: len(startup_sequence)
		gates_required:  len(layers) - 1 // No gate after last layer
	}
}

// #RollbackPlan — Generate rollback sequence when deployment fails
//
// Given a failed layer, generates the sequence to safely rollback
// all affected resources in reverse dependency order.
//
// Usage:
//   rollback: #RollbackPlan & {Graph: g, FailedAt: 2}
//   // rollback.sequence = ["web", "api", "proxy"]  // layer 2+ in reverse
//
#RollbackPlan: {
	Graph:    #Graph
	FailedAt: int // Layer number where failure occurred

	_metrics: #GraphMetrics & {"Graph": Graph}
	_maxDepth: _metrics.max_depth

	// Resources at or above the failed layer (need rollback)
	_needsRollback: [
		for rname, r in Graph.resources
		if r._depth >= FailedAt {
			name:  rname
			depth: r._depth
		},
	]

	// Sort by depth descending (deepest first = leaves first)
	_sorted: list.Sort(_needsRollback, {x: {}, y: {}, less: x.depth > y.depth})
	sequence: [for r in _sorted {r.name}]

	// Resources that are safe (below failed layer)
	safe: [
		for rname, r in Graph.resources
		if r._depth < FailedAt {rname},
	]

	summary: {
		failed_at:      FailedAt
		rollback_count: len(sequence)
		safe_count:     len(safe)
	}
}

// #SinglePointsOfFailure — Find resources that are critical with no redundancy
//
// A SPOF is a resource where:
// - Something depends on it (dependents > 0)
// - No peer of same type exists at same layer
//
// Usage:
//   spof: #SinglePointsOfFailure & {Graph: g}
//   // spof.risks = [{name: "auth", dependents: 5, type: "AuthService"}, ...]
//
#SinglePointsOfFailure: {
	Graph: #Graph

	_crit: #CriticalityRank & {"Graph": Graph}
	_byType: #GroupByType & {"Graph": Graph}

	// Find resources with dependents
	_withDependents: [for c in _crit.ranked if c.dependents > 0 {c}]

	// Check each for redundancy (same type, same layer)
	// Note: let bindings and if condition at comprehension level
	// excludes non-matching items (doesn't produce empty structs)
	risks: [
		for c in _withDependents
		let _r = Graph.resources[c.name]
		let _types = _r["@type"]
		let _depth = _r._depth
		let _hasPeer = len([
			for t, _ in _types
			for peer, _ in _byType.groups[t]
			if peer != c.name && Graph.resources[peer]._depth == _depth {peer},
		]) > 0
		if !_hasPeer {
			name:       c.name
			dependents: c.dependents
			types:      _types
			depth:      _depth
		},
	]

	summary: {
		spof_count:      len(risks)
		total_with_deps: len(_withDependents)
	}
}

// #SPOFWithRedundancy — Enhanced SPOF detection with redundancy overlap
//
// Extends #SinglePointsOfFailure with peer redundancy analysis.
// A resource is NOT a SPOF if a peer of same type at same layer
// shares significant dependent overlap (configurable threshold).
//
// Example: Two auth services at same layer are NOT SPOFs if they
// share >50% of their consumers (common dual-primary pattern).
//
// Usage:
//   spof: #SPOFWithRedundancy & {
//     Graph: g
//     OverlapThreshold: 50  // 50% overlap to declare redundancy
//   }
//
#SPOFWithRedundancy: {
	Graph: #Graph
	// Overlap threshold as percentage (0-100).
	// 50 = resource is redundant if peer shares >=50% of its dependents.
	OverlapThreshold: *50 | int

	_basic: #SinglePointsOfFailure & {"Graph": Graph}
	_byType: #GroupByType & {"Graph": Graph}

	// For each basic SPOF risk, check if any peer of same type has significant overlap
	risks: [
		for s in _basic.risks {
			let _deps = Graph.dependents[s.name]
			let _depCount = len([for k, _ in _deps {k}])
			let _types = s.types
			let _depth = s.depth

			// Count peers with sufficient overlap
			// For each type this resource has, check all peers
			let _redundantPeers = len([
				for t, _ in _types
				for peer, _ in _byType.groups[t]
				if peer != s.name && Graph.resources[peer]._depth == _depth {
					// Check overlap: count how many of my dependents also depend on peer
					let _peerDeps = Graph.dependents[peer]
					let _shared = len([for d, _ in _deps if _peerDeps[d] != _|_ {d}])
					// Integer math: _shared * 100 >= threshold% * _depCount
					if _depCount > 0 && (_shared * 100) >= (OverlapThreshold * _depCount) {peer}
				},
			])

			// Only include if no redundant peers found
			if _redundantPeers == 0 {
				name:       s.name
				dependents: s.dependents
				types:      s.types
				depth:      s.depth
			}
		},
	]

	summary: {
		spof_count:             len(risks)
		basic_spof_count:       len(_basic.risks)
		filtered_by_redundancy: len(_basic.risks) - len(risks)
		overlap_threshold:      OverlapThreshold
	}
}
