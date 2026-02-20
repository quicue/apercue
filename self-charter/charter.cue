// apercue.ca build charter — self-hosting the dependency graph pattern.
//
// This file tracks the apercue.ca build itself as a typed dependency graph.
// The charter gates define "done" for each phase.
// The gap between constraints and completed resources IS the remaining work.
//
// Run:
//   cue eval  charter.cue -e summary
//   cue eval  charter.cue -e gaps.complete
//   cue export charter.cue -e gaps.shacl_report --out json
//   cue export charter.cue -e cpm.critical_sequence --out json

package main

import (
	"apercue.ca/patterns@v0"
	"apercue.ca/charter@v0"
)

_tasks: {
	// ── Phase 1: Scaffold + Vocab ──────────────────────────────────
	"repo-scaffold": {
		name:        "repo-scaffold"
		"@type":     {CI: true}
		description: "cue mod init apercue.ca@v0, directory structure"
	}
	"resource-schema": {
		name:        "resource-schema"
		"@type":     {Schema: true}
		description: "Generic #Resource definition (no infra fields)"
		depends_on:  {"repo-scaffold": true}
	}
	"type-registry": {
		name:        "type-registry"
		"@type":     {Schema: true}
		description: "Empty #TypeRegistry pattern (domain-extensible)"
		depends_on:  {"repo-scaffold": true}
	}
	"jsonld-context": {
		name:        "jsonld-context"
		"@type":     {Schema: true, Projection: true}
		description: "JSON-LD @context with W3C namespace prefixes"
		depends_on:  {"repo-scaffold": true}
	}
	"viz-contract": {
		name:        "viz-contract"
		"@type":     {Schema: true}
		description: "#VizData, #VizNode, #VizEdge for visualization"
		depends_on:  {"repo-scaffold": true}
	}

	// ── Phase 2: Core Patterns ─────────────────────────────────────
	"graph-engine": {
		name:        "graph-engine"
		"@type":     {Pattern: true}
		description: "#Graph (renamed from #InfraGraph) — universal dependency graph"
		depends_on:  {"resource-schema": true}
	}
	"analysis-patterns": {
		name:        "analysis-patterns"
		"@type":     {Pattern: true}
		description: "#CycleDetector, #ConnectedComponents, #Subgraph, #GraphDiff, #CriticalPath"
		depends_on:  {"graph-engine": true}
	}
	"validation-patterns": {
		name:        "validation-patterns"
		"@type":     {Pattern: true}
		description: "#ComplianceCheck with SHACL ValidationReport projection"
		depends_on:  {"graph-engine": true}
	}
	"lifecycle-patterns": {
		name:        "lifecycle-patterns"
		"@type":     {Pattern: true}
		description: "#BootstrapPlan, #DriftReport, #SmokeTest with SKOS + EARL"
		depends_on:  {"graph-engine": true}
	}
	"charter-module": {
		name:        "charter-module"
		"@type":     {Pattern: true}
		description: "#Charter, #GapAnalysis, #Milestone with SHACL report"
		depends_on:  {"graph-engine": true}
	}

	// ── Phase 3: W3C Projections ───────────────────────────────────
	"shacl-projection": {
		name:        "shacl-projection"
		"@type":     {Projection: true}
		description: "sh:ValidationReport from #ComplianceCheck and #GapAnalysis"
		depends_on:  {"validation-patterns": true, "charter-module": true}
	}
	"skos-projection": {
		name:        "skos-projection"
		"@type":     {Projection: true}
		description: "skos:ConceptScheme from #TypeVocabulary and lifecycle phases"
		depends_on:  {"lifecycle-patterns": true, "type-registry": true}
	}
	"owl-time-projection": {
		name:        "owl-time-projection"
		"@type":     {Projection: true}
		description: "time:Interval from #CriticalPath scheduling"
		depends_on:  {"analysis-patterns": true}
	}
	"earl-projection": {
		name:        "earl-projection"
		"@type":     {Projection: true}
		description: "earl:Assertion from #SmokeTest test plans"
		depends_on:  {"lifecycle-patterns": true}
	}

	// ── Phase 4: Examples ──────────────────────────────────────────
	"example-course-prereqs": {
		name:        "example-course-prereqs"
		"@type":     {Example: true}
		description: "University course prerequisites (12 courses, 3 charter gates)"
		depends_on:  {"charter-module": true, "validation-patterns": true, "analysis-patterns": true}
	}
	"example-recipe": {
		name:        "example-recipe"
		"@type":     {Example: true}
		description: "Beef bourguignon recipe (17 steps, critical path)"
		depends_on:  {"graph-engine": true, "analysis-patterns": true}
	}
	"example-project-tracker": {
		name:        "example-project-tracker"
		"@type":     {Example: true}
		description: "Software release tasks (10 tasks, status tracking)"
		depends_on:  {"charter-module": true, "analysis-patterns": true}
	}
	"example-supply-chain": {
		name:        "example-supply-chain"
		"@type":     {Example: true}
		description: "Laptop assembly supply chain (15 parts, 5 tiers)"
		depends_on:  {"charter-module": true, "validation-patterns": true, "analysis-patterns": true}
	}

	// ── Phase 5: Documentation + Deployment ────────────────────────
	"docs-readme": {
		name:        "docs-readme"
		"@type":     {Documentation: true}
		description: "Project README with quick start and module structure"
		depends_on:  {"example-course-prereqs": true}
	}
	"docs-w3c-index": {
		name:        "docs-w3c-index"
		"@type":     {Documentation: true}
		description: "W3C spec coverage index (w3c/README.md)"
		depends_on:  {"shacl-projection": true, "skos-projection": true, "owl-time-projection": true}
	}
	"docs-novelty": {
		name:        "docs-novelty"
		"@type":     {Documentation: true}
		description: "Novelty document in 3 tones (academic, practitioner, executive)"
		depends_on:  {"example-course-prereqs": true}
	}
	"kb-setup": {
		name:        "kb-setup"
		"@type":     {CI: true}
		description: "Knowledge base (.kb/) with decisions, insights, patterns"
		depends_on:  {"graph-engine": true}
	}
	"github-repo": {
		name:        "github-repo"
		"@type":     {CI: true}
		description: "GitHub repo created, initial commit pushed"
		depends_on:  {"docs-readme": true, "kb-setup": true}
	}
	"cf-pages": {
		name:        "cf-pages"
		"@type":     {CI: true}
		description: "CF Pages project with custom domain apercue.ca"
		depends_on:  {"github-repo": true}
	}
}

// ═══════════════════════════════════════════════════════════════════════════
// GRAPH + ANALYSIS
// ═══════════════════════════════════════════════════════════════════════════

graph: patterns.#Graph & {Input: _tasks}

cpm: patterns.#CriticalPath & {Graph: graph}

spof: patterns.#SinglePointsOfFailure & {Graph: graph}

// ═══════════════════════════════════════════════════════════════════════════
// CHARTER — apercue build requirements
// ═══════════════════════════════════════════════════════════════════════════

_charter: charter.#Charter & {
	name: "apercue-build"

	scope: {
		total_resources: len(_tasks)
		root: {
			"repo-scaffold": true
		}
		required_types: {
			Schema:        true
			Pattern:       true
			Projection:    true
			Example:       true
			Documentation: true
			CI:            true
		}
	}

	gates: {
		"vocab-ready": {
			phase:       1
			description: "Core schemas defined"
			requires: {
				"repo-scaffold":   true
				"resource-schema": true
				"type-registry":   true
				"jsonld-context":  true
				"viz-contract":    true
			}
		}
		"patterns-ready": {
			phase:       2
			description: "All graph patterns extracted and validated"
			requires: {
				"graph-engine":        true
				"analysis-patterns":   true
				"validation-patterns": true
				"lifecycle-patterns":  true
				"charter-module":      true
			}
			depends_on: {"vocab-ready": true}
		}
		"projections-ready": {
			phase:       3
			description: "All W3C projection layers working"
			requires: {
				"shacl-projection":    true
				"skos-projection":     true
				"owl-time-projection": true
				"earl-projection":     true
			}
			depends_on: {"patterns-ready": true}
		}
		"examples-ready": {
			phase:       4
			description: "All four non-infra examples validate"
			requires: {
				"example-course-prereqs":    true
				"example-recipe":            true
				"example-project-tracker":   true
				"example-supply-chain":      true
			}
			depends_on: {"projections-ready": true}
		}
		"ship": {
			phase:       5
			description: "Docs, .kb, GitHub, CF Pages — ready to share"
			requires: {
				"docs-readme":    true
				"docs-w3c-index": true
				"docs-novelty":   true
				"kb-setup":       true
				"github-repo":    true
				"cf-pages":       true
			}
			depends_on: {"examples-ready": true}
		}
	}
}

gaps: charter.#GapAnalysis & {
	Charter: _charter
	Graph:   graph
}

summary: {
	project:     _charter.name
	deliverables: len(_tasks)
	complete:    gaps.complete
	missing:     gaps.missing_resource_count
	next_gate:   gaps.next_gate
	scheduling:  cpm.summary
	bottlenecks: spof.summary
}
