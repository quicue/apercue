// Project task tracker as a typed dependency graph.
//
// The self-hosting pattern: track project work using the same
// charter + graph pattern the project implements. Progress is
// tracked via schema:actionStatus tags on each task.
//
// Run:
//   cue vet ./examples/project-tracker/
//   cue eval ./examples/project-tracker/ -e summary
//   cue eval ./examples/project-tracker/ -e cpm.summary
//   cue eval ./examples/project-tracker/ -e summary

package main

import (
	"list"
	"apercue.ca/patterns@v0"
	"apercue.ca/charter@v0"
)

// schema:actionStatus tags
_tasks: [string]: {
	status: *"pending" | "active" | "done" | "failed"
	...
}

_tasks: {
	"design-api": {
		name: "design-api"
		"@type": {Design: true}
		description: "Design REST API schema and endpoints"
		weight:      3
	}
	"design-ui": {
		name: "design-ui"
		"@type": {Design: true}
		description: "Design user interface wireframes"
		weight:      2
	}
	"impl-auth": {
		name: "impl-auth"
		"@type": {Implementation: true}
		description: "Implement authentication system"
		depends_on: {"design-api": true}
		weight: 5
	}
	"impl-crud": {
		name: "impl-crud"
		"@type": {Implementation: true}
		description: "Implement CRUD endpoints"
		depends_on: {"design-api": true}
		weight: 4
	}
	"impl-frontend": {
		name: "impl-frontend"
		"@type": {Implementation: true}
		description: "Implement frontend components"
		depends_on: {"design-ui": true, "impl-auth": true}
		weight: 5
	}
	"test-api": {
		name: "test-api"
		"@type": {Test: true}
		description: "API integration tests"
		depends_on: {"impl-auth": true, "impl-crud": true}
		weight: 3
	}
	"test-e2e": {
		name: "test-e2e"
		"@type": {Test: true}
		description: "End-to-end browser tests"
		depends_on: {"impl-frontend": true, "test-api": true}
		weight: 4
	}
	"write-docs": {
		name: "write-docs"
		"@type": {Documentation: true}
		description: "Write API documentation and user guide"
		depends_on: {"impl-auth": true, "impl-crud": true}
		weight: 3
	}
	"setup-ci": {
		name: "setup-ci"
		"@type": {DevOps: true}
		description: "Configure CI/CD pipeline"
		depends_on: {"test-api": true}
		weight: 2
	}
	"deploy-staging": {
		name: "deploy-staging"
		"@type": {DevOps: true}
		description: "Deploy to staging environment"
		depends_on: {"test-e2e": true, "setup-ci": true, "write-docs": true}
		weight: 2
	}
}

// ═══ GRAPHS ════════════════════════════════════════════════════════
// Full plan graph (all tasks regardless of status)
plan: patterns.#Graph & {Input: _tasks}

// Progress graph (only done tasks — for gap analysis)
_done_tasks: {
	for name, t in _tasks if t.status == "done" {
		(name): {
			name:    t.name
			"@type": t["@type"]
		}
	}
}
progress: patterns.#Graph & {Input: _done_tasks}

// ═══ CRITICAL PATH ════════════════════════════════════════════════════════
// Compute weighted critical path through task graph
_cpm_simple: {
	// Simple critical path model: max (weight + path_weight) for each task
	_weights: {for name, t in _tasks {(name): t.weight}}

	// For each task, compute: weight + max(deps' weights)
	_task_critical_path: {
		for name, t in plan.resources {
			(name): {
				task:   name
				weight: _weights[name]
				_deps: t.depends_on | {}
				_ancestor_weights: [
					for dep, _ in _deps {
						_weights[dep]
					},
				]
				_ancestor_sum: *0 | int
				if len(_ancestor_weights) > 0 {
					_ancestor_sum: _weights[name] + (list.Max(_ancestor_weights) | 0)
				}
				critical_weight: *_weights[name] | int
				if len(_ancestor_weights) > 0 {
					critical_weight: _weights[name] + _ancestor_sum
				}
			}
		}
	}
}

// ═══ CHARTER ═══════════════════════════════════════════════════════
_charter: charter.#Charter & {
	name: "v1.0-release"

	scope: {
		total_resources: len(_tasks)
		required_resources: {for name, _ in _tasks {(name): true}}
		required_types: {
			Design:         true
			Implementation: true
			Test:           true
			Documentation:  true
			DevOps:         true
		}
	}

	gates: {
		"design-complete": {
			phase:       1
			description: "All design work done"
			requires: {
				"design-api": true
				"design-ui":  true
			}
		}
		"implementation-complete": {
			phase:       2
			description: "All features implemented"
			requires: {
				"impl-auth":     true
				"impl-crud":     true
				"impl-frontend": true
			}
			depends_on: {"design-complete": true}
		}
		"quality-gate": {
			phase:       3
			description: "Tests pass, docs written"
			requires: {
				"test-api":   true
				"test-e2e":   true
				"write-docs": true
			}
			depends_on: {"implementation-complete": true}
		}
		"ship": {
			phase:       4
			description: "Deployed to staging, ready for release"
			requires: {
				"setup-ci":       true
				"deploy-staging": true
			}
			depends_on: {"quality-gate": true}
		}
	}
}

gaps: charter.#GapAnalysis & {
	Charter: _charter
	Graph:   progress
}

// ═══ COMPLIANCE & METRICS ════════════════════════════════════════════════════════
metrics: patterns.#GraphMetrics & {Graph: plan}

cpm: {
	Graph: plan
	Weights: {for name, t in _tasks {(name): t.weight}}

	// Simple aggregation for critical path
	_allWeights: [for name, t in _tasks {t.weight}]
	_allDone: [for name, t in _tasks if t.status == "done" {t.weight}]

	total_weight: *0 | int
	if len(_allWeights) > 0 {
		total_weight: list.Sum(_allWeights)
	}

	completed_weight: *0 | int
	if len(_allDone) > 0 {
		completed_weight: list.Sum(_allDone)
	}

	remaining_weight: total_weight - completed_weight

	// Percentage as integer (0-100)
	_percent:         completed_weight * 100 / total_weight
	percent_complete: *0 | _percent
	if total_weight == 0 {
		percent_complete: 0
	}

	summary: {
		total:      total_weight
		completed:  completed_weight
		remaining:  remaining_weight
		percentage: percent_complete
	}
}

summary: {
	release:     _charter.name
	total_tasks: len(_tasks)
	gap: {
		complete:      gaps.complete
		missing_count: gaps.missing_resource_count
		next_gate:     gaps.next_gate
	}
	scheduling: cpm.summary
	graph: {
		resources:  metrics.total_resources
		max_depth:  metrics.max_depth
		edges:      metrics.total_edges
		root_count: metrics.root_count
		leaf_count: metrics.leaf_count
	}
}
