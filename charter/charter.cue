// Charter — constraint-first project planning via CUE unification.
//
// Declare what "done" looks like. Build the graph incrementally.
// cue vet tells you what's missing. When it passes, the charter is satisfied.
//
// The gap between constraints and data IS the remaining work.
//
// Usage:
//   charter: charter.#Charter & {
//       name: "NHCF Deep Retrofit"
//       scope: {
//           total_resources: 18
//           root: "nhcf-agreement"
//           required_types: {Assessment: true, Design: true, Retrofit: true}
//       }
//       gates: {
//           "design-complete": {
//               phase: 3
//               requires: {"rideau-design": true, "gladstone-design": true}
//           }
//       }
//   }
//
//   gaps: charter.#GapAnalysis & {Charter: charter, Graph: infra}
//   // gaps.complete == false → gaps.missing tells you what's left

package charter

import (
	"list"
	"apercue.ca/patterns@v0"
)

// #Charter — what "done" looks like.
//
// A scope declaration that must eventually unify with the built graph.
// The gap analysis computes what's missing; when the gap is zero,
// the charter is satisfied.
#Charter: {
	name: string

	scope: {
		// Expected total resource count (graph must reach this)
		total_resources?: int & >0

		// Named root(s) — every project starts somewhere
		root?: string | {[string]: true}

		// Resources that must exist by name
		required_resources?: {[string]: true}

		// Types that must be represented in the graph
		required_types?: {[string]: true}

		// Minimum graph depth (layers of dependency)
		min_depth?: int & >=0
	}

	// Phase gates — checkpoints where subsets of constraints must hold.
	// Gates can depend on other gates (DAG, not linear).
	gates?: {
		[string]: #Gate
	}
}

// #Gate — a checkpoint where named resources must exist.
#Gate: {
	phase?:       int & >=0
	requires:     {[string]: true} // resource names that must be present
	depends_on?:  {[string]: true} // other gate names that must be satisfied first
	description?: string
}

// #GapAnalysis — given a charter and a graph, compute what's missing.
//
// Usage:
//   gaps: #GapAnalysis & {Charter: myCharter, Graph: myGraph}
//   // gaps.complete          — true when charter is fully satisfied
//   // gaps.missing_resources — names in scope not yet in graph
//   // gaps.missing_types     — types required but not represented
//   // gaps.gate_status       — per-gate satisfaction with missing lists
//   // gaps.next_gate         — nearest unsatisfied gate (by phase)
#GapAnalysis: {
	Charter: #Charter
	Graph:   patterns.#Graph

	// ── Present state ────────────────────────────────────────────
	_present: {for name, _ in Graph.resources {(name): true}}
	_types_present: {
		for _, r in Graph.resources {
			for t, _ in r["@type"] {(t): true}
		}
	}

	resource_count: len(Graph.resources)

	// ── Missing resources ────────────────────────────────────────
	missing_resources: {
		if Charter.scope.required_resources != _|_ {
			for name, _ in Charter.scope.required_resources
			if _present[name] == _|_ {(name): true}
		}
	}
	missing_resource_count: len([for _, _ in missing_resources {1}])

	// ── Missing types ────────────────────────────────────────────
	missing_types: {
		if Charter.scope.required_types != _|_ {
			for t, _ in Charter.scope.required_types
			if _types_present[t] == _|_ {(t): true}
		}
	}
	missing_type_count: len([for _, _ in missing_types {1}])

	// ── Root check ───────────────────────────────────────────────
	_root_satisfied: bool
	if Charter.scope.root == _|_ {
		_root_satisfied: true
	}
	// String root: must exist and be a graph root
	if (Charter.scope.root & string) != _|_ {
		_root_satisfied: Graph.roots[Charter.scope.root] != _|_
	}
	// Struct root: all named roots must be graph roots
	if (Charter.scope.root & {[string]: true}) != _|_ {
		let _root_struct = Charter.scope.root & {[string]: true}
		_root_satisfied: len([
			for name, _ in _root_struct
			if Graph.roots[name] == _|_ {name},
		]) == 0
	}

	// ── Depth check ──────────────────────────────────────────────
	// Only accesses Graph.topology when min_depth is set, avoiding
	// the O(n²) _ancestors transitive closure for charters that
	// don't constrain depth.
	depth_satisfied: bool
	if Charter.scope.min_depth == _|_ {
		depth_satisfied: true
	}
	if Charter.scope.min_depth != _|_ {
		depth_satisfied: len(Graph.topology) - 1 >= Charter.scope.min_depth
	}

	// ── Resource count check ─────────────────────────────────────
	count_satisfied: bool
	if Charter.scope.total_resources == _|_ {
		count_satisfied: true
	}
	if Charter.scope.total_resources != _|_ {
		count_satisfied: resource_count >= Charter.scope.total_resources
	}

	// ── Gate status ──────────────────────────────────────────────
	gate_status: {
		if Charter.gates != _|_ {
			for gname, gate in Charter.gates {
				(gname): {
					_missing: {
						for rname, _ in gate.requires
						if _present[rname] == _|_ {(rname): true}
					}
					missing:   _missing
					satisfied: len([for _, _ in _missing {1}]) == 0

					// Check gate dependencies (DAG ordering)
					_deps_met: *true | bool
					if gate.depends_on != _|_ {
						_deps_met: len([
							for dep, _ in gate.depends_on
							if gate_status[dep].satisfied != true {dep},
						]) == 0
					}
					ready: _deps_met && satisfied
				}
			}
		}
	}

	// ── Unsatisfied gates ────────────────────────────────────────
	unsatisfied_gates: {
		for gname, gs in gate_status
		if !gs.satisfied {(gname): gs.missing}
	}

	// ── Next gate (lowest phase among unsatisfied) ───────────────
	_unsatisfied_with_phase: [
		for gname, gs in gate_status
		if !gs.satisfied && Charter.gates[gname].phase != _|_ {
			name:  gname
			phase: Charter.gates[gname].phase
		},
	]
	_sorted_unsatisfied: list.Sort(_unsatisfied_with_phase, {x: {}, y: {}, less: x.phase < y.phase})
	next_gate: *"" | string
	if len(_sorted_unsatisfied) > 0 {
		next_gate: _sorted_unsatisfied[0].name
	}

	// ── Overall completion ───────────────────────────────────────
	complete: missing_resource_count == 0 &&
		missing_type_count == 0 &&
		_root_satisfied &&
		depth_satisfied &&
		count_satisfied &&
		len([for _, _ in unsatisfied_gates {1}]) == 0

	// ── SHACL ValidationReport projection ──────────────────────
	// W3C SHACL (Recommendation, 2017-07-20): express gap analysis
	// results as sh:ValidationReport. Missing resources and types
	// become sh:ValidationResult entries with sh:Violation severity.
	//
	// Export: cue export -e gaps.shacl_report --out json
	shacl_report: {
		"@type":              "sh:ValidationReport"
		"sh:conforms":        complete
		"dcterms:conformsTo": {"@id": "charter:" + Charter.name}
		"sh:result": list.Concat([[
			for name, _ in missing_resources {
				"@type":                        "sh:ValidationResult"
				"sh:focusNode":                 {"@id": name}
				"sh:resultSeverity":            {"@id": "sh:Violation"}
				"sh:resultMessage":             "Required resource '" + name + "' not present in graph"
				"sh:sourceConstraintComponent": {"@id": "apercue:RequiredResource"}
			},
		], [
			for t, _ in missing_types {
				"@type":                        "sh:ValidationResult"
				"sh:focusNode":                 {"@id": t}
				"sh:resultSeverity":            {"@id": "sh:Violation"}
				"sh:resultMessage":             "Required type '" + t + "' not represented in graph"
				"sh:sourceConstraintComponent": {"@id": "apercue:RequiredType"}
			},
		]])
	}
}

// #Milestone — evaluate a single gate against the graph.
//
// Usage:
//   milestone: #Milestone & {Charter: c, Gate: "design-complete", Graph: myGraph}
//   // milestone.satisfied  — bool
//   // milestone.missing    — resources still needed
//   // milestone.blockers   — deps of missing resources that also don't exist
#Milestone: {
	Charter: #Charter
	Gate:    string
	Graph:   patterns.#Graph

	_gate: Charter.gates[Gate]
	_present: {for name, _ in Graph.resources {(name): true}}

	// Missing resources for this gate
	_missing: {
		for rname, _ in _gate.requires
		if _present[rname] == _|_ {(rname): true}
	}
	missing:   _missing
	satisfied: len([for _, _ in _missing {1}]) == 0

	// Blockers: for each missing resource, check if its expected
	// dependencies are also missing (compounding the gap)
	_blockers: {
		for rname, _ in _missing {
			if Charter.scope.required_resources != _|_ {
				if Charter.scope.required_resources[rname] != _|_ {
					(rname): true
				}
			}
		}
	}
	blockers: _blockers

	// Use hidden intermediaries to avoid self-referencing field names
	_is_satisfied:  len([for _, _ in _missing {1}]) == 0
	_missing_count: len([for _, _ in _missing {1}])
	_blocker_count: len([for _, _ in _blockers {1}])

	summary: {
		gate:          Gate
		phase:         *_gate.phase | null
		satisfied:     _is_satisfied
		missing_count: _missing_count
		blocker_count: _blocker_count
		...
	}
}

