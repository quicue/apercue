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
	[_]: _planned: bool | *false

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

	// ── Phase 6: Projection Completeness ──────────────────────────
	"safeid-constraints": {
		name:        "safeid-constraints"
		"@type":     {Schema: true}
		description: "#SafeID and #SafeLabel ASCII-safe identifier constraints"
		depends_on:  {"resource-schema": true}
	}
	"ci-workflow": {
		name:        "ci-workflow"
		"@type":     {CI: true}
		description: "GitHub Actions validate.yml with unicode rejection tests"
		depends_on:  {"safeid-constraints": true, "github-repo": true}
	}
	"specs-registry": {
		name:        "specs-registry"
		"@type":     {Schema: true, Projection: true}
		description: "W3C spec coverage as structured CUE data (single source of truth)"
		depends_on:  {"shacl-projection": true, "skos-projection": true, "owl-time-projection": true, "earl-projection": true}
	}
	"respec-projection": {
		name:        "respec-projection"
		"@type":     {Projection: true, Documentation: true}
		description: "ReSpec HTML spec generated from CUE via cue export -e spec_html"
		depends_on:  {"specs-registry": true, "safeid-constraints": true}
	}
	"site-build": {
		name:        "site-build"
		"@type":     {CI: true, Projection: true}
		description: "Build pipeline replacing hardcoded site data with CUE projections"
		depends_on:  {"specs-registry": true, "cf-pages": true}
	}
	"ci-regen-check": {
		name:        "ci-regen-check"
		"@type":     {CI: true}
		description: "CI step verifying generated artifacts match CUE exports"
		depends_on:  {"ci-workflow": true, "site-build": true}
	}

	// ── Phase 7: Semantic Integrity + Live Tracking ──────────────
	"w3c-namespace-cleanup": {
		name:        "w3c-namespace-cleanup"
		"@type":     {Schema: true}
		description: "Remove dead ODRL/OA/AS/Hydra/DCAT prefixes from @context"
		depends_on:  {"jsonld-context": true}
	}
	"context-canonical-url": {
		name:        "context-canonical-url"
		"@type":     {Projection: true, CI: true}
		description: "Deploy @context.jsonld at apercue.ca/vocab/context.jsonld"
		depends_on:  {"w3c-namespace-cleanup": true, "cf-pages": true}
	}
	"charter-status-tracking": {
		name:        "charter-status-tracking"
		"@type":     {Pattern: true, Schema: true}
		description: "Add _planned status to charter tasks, filter for gap analysis"
		depends_on:  {"charter-module": true, "site-build": true}
	}
	"charter-live-viz": {
		name:        "charter-live-viz"
		"@type":     {Projection: true}
		description: "Charter page shows planned vs completed nodes with status coloring"
		depends_on:  {"charter-status-tracking": true}
	}
	"quicue-semantic-sync": {
		name:        "quicue-semantic-sync"
		"@type":     {Schema: true}
		description: "Apply dcterms + W3C @context fixes to quicue.ca repo"
		depends_on:  {"w3c-namespace-cleanup": true}
		_planned:    true
	}
	"ci-auto-deploy": {
		name:        "ci-auto-deploy"
		"@type":     {CI: true}
		description: "GitHub Actions triggers Cloudflare Pages deploy on push"
		depends_on:  {"ci-workflow": true, "cf-pages": true}
	}
	"kb-charter-bridge": {
		name:        "kb-charter-bridge"
		"@type":     {Pattern: true, Documentation: true}
		description: "Design .kb entries as charter node annotations with provenance"
		depends_on:  {"kb-setup": true, "charter-status-tracking": true}
	}
	"grdn-mirror": {
		name:        "grdn-mirror"
		"@type":     {CI: true}
		description: "Push to git.infra.grdn as primary, GitHub as mirror"
		depends_on:  {"github-repo": true}
	}

	// ── Phase 8: Local Hardening + Presentation ──────────────────
	"site-data-locality": {
		name:        "site-data-locality"
		"@type":     {CI: true, Schema: true}
		description: "Split build into public (landing, spec, examples) and private (charter, ecosystem, projections) targets"
		depends_on:  {"site-build": true}
	}
	"grdn-site-deploy": {
		name:        "grdn-site-deploy"
		"@type":     {CI: true}
		description: "Deploy private site data to grdn network with Caddy static serve"
		depends_on:  {"site-data-locality": true, "grdn-mirror": true}
	}
	"charter-cpm-overlay": {
		name:        "charter-cpm-overlay"
		"@type":     {Projection: true}
		description: "CPM critical path highlighting, earliest/latest/slack on charter nodes"
		depends_on:  {"charter-live-viz": true}
	}
	"projections-dashboard": {
		name:        "projections-dashboard"
		"@type":     {Projection: true, Documentation: true}
		description: "Interactive page showing SHACL gaps, OWL-Time intervals, CPM schedule"
		depends_on:  {"site-data-locality": true}
		_planned:    true
	}
	"spec-v2-update": {
		name:        "spec-v2-update"
		"@type":     {Documentation: true}
		description: "Update ReSpec spec with AnalyzableGraph, precomputed CPM, KB bridge"
		depends_on:  {"specs-registry": true}
		_planned:    true
	}
}

// ═══════════════════════════════════════════════════════════════════════════
// GRAPH + ANALYSIS
// ═══════════════════════════════════════════════════════════════════════════

graph: patterns.#GraphLite & {Input: _tasks, Precomputed: _precomputed}

// CPM: precomputed in Python (CUE's recursive fixpoint is too slow
// for 38 nodes). Forward/backward passes + slack computed by toposort.py.
// cue eval ./self-charter/ -e cpm.summary
cpm: patterns.#CriticalPathPrecomputed & {
	Graph:       graph
	Precomputed: _precomputed_cpm
}

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
		"projections-complete": {
			phase:       6
			description: "All artifacts are CUE projections — spec, site data, CI validation"
			requires: {
				"safeid-constraints": true
				"ci-workflow":        true
				"specs-registry":     true
				"respec-projection":  true
				"site-build":         true
				"ci-regen-check":     true
			}
			depends_on: {"ship": true}
		}
		"semantic-integrity": {
			phase:       7
			description: "Clean W3C usage, live charter tracking, cross-repo sync"
			requires: {
				"w3c-namespace-cleanup":  true
				"context-canonical-url":  true
				"charter-status-tracking": true
				"charter-live-viz":       true
				"quicue-semantic-sync":   true
				"ci-auto-deploy":         true
				"kb-charter-bridge":      true
				"grdn-mirror":            true
			}
			depends_on: {"projections-complete": true}
		}
		"local-hardening": {
			phase:       8
			description: "Real data local on grdn, public site clean, projections dashboard live"
			requires: {
				"site-data-locality":      true
				"grdn-site-deploy":        true
				"charter-cpm-overlay":     true
				"projections-dashboard":   true
				"spec-v2-update":          true
			}
			depends_on: {"semantic-integrity": true}
		}
	}
}

// Gap analysis uses only completed tasks — planned tasks are "not yet present"
_completed_resources: {
	for name, t in graph.resources if !_tasks[name]._planned {
		(name): t
	}
}

gaps: charter.#GapAnalysis & {
	Charter: _charter
	Graph: {
		resources: _completed_resources
		roots:     graph.roots
		topology:  graph.topology
	}
}

summary: {
	project:      _charter.name
	deliverables: len(_tasks)
	complete:     gaps.complete
	missing:      gaps.missing_resource_count
	next_gate:    gaps.next_gate
}

// ═══════════════════════════════════════════════════════════════════════════
// KB ↔ CHARTER BRIDGE — link .kb entries to charter deliverables
// ═══════════════════════════════════════════════════════════════════════════
//
// Each charter task can reference KB decisions, insights, or patterns
// that motivated or documented it. The viz shows these as tooltip context.
// Format: task-id → [{type, id, title}]

_kb_annotations: {
	"graph-engine": [{type: "decision", id: "ADR-001", title: "Domain-agnostic graph engine"}]
	"validation-patterns": [
		{type: "decision", id: "ADR-003", title: "Comprehension-level filtering"},
		{type: "pattern", id: "P-003", title: "comprehension-level-filtering"},
	]
	"shacl-projection": [
		{type: "decision", id: "ADR-002", title: "W3C artifacts as zero-cost projections"},
		{type: "insight", id: "INSIGHT-001", title: "CUE unification subsumes SPARQL + SHACL"},
		{type: "pattern", id: "P-001", title: "zero-cost-projection"},
	]
	"skos-projection":     [{type: "decision", id: "ADR-002", title: "W3C artifacts as zero-cost projections"}]
	"owl-time-projection": [{type: "decision", id: "ADR-002", title: "W3C artifacts as zero-cost projections"}]
	"earl-projection":     [{type: "decision", id: "ADR-002", title: "W3C artifacts as zero-cost projections"}]
	"charter-module": [
		{type: "insight", id: "INSIGHT-002", title: "Charter makes completion a compile-time property"},
		{type: "pattern", id: "P-002", title: "charter-as-constraint"},
	]
	"example-course-prereqs": [{type: "insight", id: "INSIGHT-003", title: "Non-infra examples prove generality"}]
	"example-recipe":         [{type: "insight", id: "INSIGHT-003", title: "Non-infra examples prove generality"}]
	"example-supply-chain":   [{type: "insight", id: "INSIGHT-003", title: "Non-infra examples prove generality"}]
	// Phase 6-7 decisions documented in this session
	"safeid-constraints":      [{type: "decision", id: "ADR-004", title: "ASCII-safe identifiers prevent injection"}]
	"w3c-namespace-cleanup":   [{type: "decision", id: "ADR-005", title: "Remove dead W3C namespace prefixes"}]
	"charter-status-tracking": [{type: "decision", id: "ADR-006", title: "_planned field for gap analysis filtering"}]
	"charter-live-viz":        [{type: "decision", id: "ADR-006", title: "_planned field for gap analysis filtering"}]
}
