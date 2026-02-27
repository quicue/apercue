// Multi-tier supply chain as a typed dependency graph.
//
// Proves that apercue patterns work for any domain — supply chains are
// resources, components are suppliers, and assemblies depend on components.
// Charter gates verify Bill of Materials (BOM) completeness checks.
//
// The insight: supply chains ARE dependency graphs. A laptop depends on its
// assemblies, which depend on components, which depend on raw materials.
// Critical path = longest lead time through the supply chain.
//
// Run:
//   cue vet ./examples/supply-chain/
//   cue eval ./examples/supply-chain/ -e summary
//   cue eval ./examples/supply-chain/ -e gaps.complete
//   cue eval ./examples/supply-chain/ -e cpm.summary
//   cue export ./examples/supply-chain/ -e cpm.critical_sequence --out json

package main

import (
	"apercue.ca/patterns@v0"
	"apercue.ca/charter@v0"
)

// ═══ SUPPLY CHAIN RESOURCES ════════════════════════════════════════════════
_parts: {
	// ═══ Tier 0: Raw Materials (roots) ═════════════════════════════════
	"silicon-wafer": {
		name: "silicon-wafer"
		"@type": {RawMaterial: true}
		description: "300mm silicon wafer"
		lead_days:   14
		supplier:    "TSMC"
	}
	"copper-pcb": {
		name: "copper-pcb"
		"@type": {RawMaterial: true}
		description: "Copper-clad PCB laminate"
		lead_days:   7
		supplier:    "Isola Group"
	}
	"lithium-cells": {
		name: "lithium-cells"
		"@type": {RawMaterial: true}
		description: "18650 lithium-ion cells"
		lead_days:   21
		supplier:    "Samsung SDI"
	}
	"lcd-glass": {
		name: "lcd-glass"
		"@type": {RawMaterial: true}
		description: "LCD glass substrate"
		lead_days:   10
		supplier:    "Corning"
	}
	"aluminum-stock": {
		name: "aluminum-stock"
		"@type": {RawMaterial: true}
		description: "6061-T6 aluminum billet"
		lead_days:   5
		supplier:    "Alcoa"
	}

	// ═══ Tier 1: Components ════════════════════════════════════════════
	"cpu-chip": {
		name: "cpu-chip"
		"@type": {Component: true}
		description: "Application processor (5nm)"
		depends_on: {"silicon-wafer": true}
		lead_days: 30
	}
	"memory-module": {
		name: "memory-module"
		"@type": {Component: true}
		description: "16GB LPDDR5 memory module"
		depends_on: {"silicon-wafer": true}
		lead_days: 21
	}
	"battery-pack": {
		name: "battery-pack"
		"@type": {Component: true}
		description: "72Wh battery pack"
		depends_on: {"lithium-cells": true}
		lead_days: 14
	}
	"display-panel": {
		name: "display-panel"
		"@type": {Component: true}
		description: "14-inch IPS display panel"
		depends_on: {"lcd-glass": true}
		lead_days: 18
	}
	"chassis": {
		name: "chassis"
		"@type": {Component: true}
		description: "CNC-machined aluminum chassis"
		depends_on: {"aluminum-stock": true}
		lead_days: 10
	}

	// ═══ Tier 2: Sub-Assemblies ════════════════════════════════════════
	"motherboard-assy": {
		name: "motherboard-assy"
		"@type": {SubAssembly: true}
		description: "Populated motherboard with CPU and RAM"
		depends_on: {"cpu-chip": true, "memory-module": true, "copper-pcb": true}
		lead_days: 7
	}
	"display-assy": {
		name: "display-assy"
		"@type": {SubAssembly: true}
		description: "Display assembly with panel and bezel"
		depends_on: {"display-panel": true, "chassis": true}
		lead_days: 5
	}

	// ═══ Tier 3: Final Assembly ════════════════════════════════════════
	"laptop-assy": {
		name: "laptop-assy"
		"@type": {Assembly: true}
		description: "Final laptop assembly"
		depends_on: {
			"motherboard-assy": true
			"display-assy":     true
			"battery-pack":     true
			"chassis":          true
		}
		lead_days: 3
	}

	// ═══ Tier 4: Finished Product ══════════════════════════════════════
	"laptop-finished": {
		name: "laptop-finished"
		"@type": {Finished: true}
		description: "Tested, packaged, shipped laptop"
		depends_on: {"laptop-assy": true}
		lead_days: 2
	}
}

// ═══ GRAPH CONSTRUCTION ════════════════════════════════════════════════════
graph: patterns.#Graph & {Input: _parts}

// ═══ CRITICAL PATH ANALYSIS ════════════════════════════════════════════════
// Critical path: minimum total lead time from raw material to ship
cpm: patterns.#CriticalPath & {
	Graph: graph
	Weights: {for name, p in _parts {(name): p.lead_days}}
}

// ═══ SINGLE POINTS OF FAILURE ══════════════════════════════════════════════
spof: patterns.#SinglePointsOfFailure & {Graph: graph}

// ═══ CHARTER — BOM Completeness ════════════════════════════════════════════
_charter: charter.#Charter & {
	name: "laptop-bom"

	scope: {
		total_resources: len(_parts)
		root: {
			"silicon-wafer":  true
			"copper-pcb":     true
			"lithium-cells":  true
			"lcd-glass":      true
			"aluminum-stock": true
		}
		required_types: {
			RawMaterial: true
			Component:   true
			SubAssembly: true
			Assembly:    true
			Finished:    true
		}
	}

	gates: {
		"materials-sourced": {
			phase:       1
			description: "All raw materials identified and sourced"
			requires: {
				"silicon-wafer":  true
				"copper-pcb":     true
				"lithium-cells":  true
				"lcd-glass":      true
				"aluminum-stock": true
			}
		}
		"components-ready": {
			phase:       2
			description: "All components manufactured"
			requires: {
				"cpu-chip":      true
				"memory-module": true
				"battery-pack":  true
				"display-panel": true
				"chassis":       true
			}
			depends_on: {"materials-sourced": true}
		}
		"assemblies-complete": {
			phase:       3
			description: "Sub-assemblies and final assembly done"
			requires: {
				"motherboard-assy": true
				"display-assy":     true
				"laptop-assy":      true
			}
			depends_on: {"components-ready": true}
		}
		"ship-ready": {
			phase:       4
			description: "Finished product tested and packaged"
			requires: {"laptop-finished": true}
			depends_on: {"assemblies-complete": true}
		}
	}
}

// ═══ GAP ANALYSIS ══════════════════════════════════════════════════════════
gaps: charter.#GapAnalysis & {
	Charter: _charter
	Graph:   graph
}

// ═══ COMPLIANCE RULES ══════════════════════════════════════════════════════
compliance: patterns.#ComplianceCheck & {
	Graph: graph
	Rules: [
		{
			name:        "assemblies-need-components"
			description: "Assemblies must depend on components"
			match_types: {Assembly: true}
			must_not_be_root: true
			severity:         "critical"
		},
		{
			name:        "components-need-materials"
			description: "Components must depend on raw materials"
			match_types: {Component: true}
			must_not_be_root: true
			severity:         "critical"
		},
		{
			name:        "sub-assemblies-need-components"
			description: "Sub-assemblies must depend on components"
			match_types: {SubAssembly: true}
			must_not_be_root: true
			severity:         "critical"
		},
	]
}

// ═══ W3C PROJECTIONS ═══════════════════════════════════════════════════════
// DCAT — supply chain as a data catalog
catalog: patterns.#DCATCatalog & {
	Graph: graph
	Title: "Laptop Supply Chain"
}

// PROV-O — dependency provenance
provenance: patterns.#ProvenanceTrace & {Graph: graph}

// Activity Streams — build order as activity stream
activity_stream: patterns.#ActivityStream & {Graph: graph}

// SHACL Shapes — structural shapes from graph types
shape_export: patterns.#SHACLShapes & {
	Graph:     graph
	Namespace: "https://apercue.ca/shapes/supply-chain#"
}

// SKOS Taxonomy — supply chain type hierarchy
_taxonomy: patterns.#SKOSTaxonomy & {
	Graph:       graph
	SchemeTitle: "Supply Chain Type Taxonomy"
	Hierarchy: {
		"Material":    ["RawMaterial", "Component"]
		"Assemblable": ["SubAssembly", "Assembly"]
	}
}

// ═══ OWL Ontology — Formal vocabulary from graph types ════════════════════
// Export: cue export ./examples/supply-chain/ -e ontology.owl_ontology --out json
ontology: patterns.#OWLOntology & {
	Graph: graph
	Spec: {
		URI:         "https://apercue.ca/ontology/supply-chain#"
		Title:       "Supply Chain Ontology"
		Description: "OWL vocabulary generated from laptop supply chain graph types"
	}
	Hierarchy: {
		"Material":    ["RawMaterial", "Component"]
		"Assemblable": ["SubAssembly", "Assembly"]
	}
}

// ═══ Web Annotations — Quality notes on supply chain ═════════════════════
// Export: cue export ./examples/supply-chain/ -e annotations.annotation_collection --out json
annotations: patterns.#AnnotationCollection & {
	Graph: graph
	CollectionLabel: "Supply Chain Quality Annotations"
	Annotations: [
		{
			target:     "silicon-wafer"
			body:       "Single source supplier — explore secondary wafer sources"
			motivation: "oa:assessing"
			tags: ["risk", "single-source"]
		},
		{
			target:     "laptop-assy"
			body:       "Final assembly depends on 4 inputs — bottleneck risk"
			motivation: "oa:assessing"
			tags: ["bottleneck", "critical-path"]
		},
		{
			target:     "lithium-cells"
			body:       "Longest raw material lead time (21 days) — drives critical path"
			motivation: "oa:highlighting"
			tags: ["critical-path", "lead-time"]
		},
	]
}

// ═══ VoID — Graph Self-Description ════════════════════════════════════════
// Export: cue export ./examples/supply-chain/ -e void_dataset.void_description --out json
void_dataset: patterns.#VoIDDataset & {
	Graph:      graph
	DatasetURI: "urn:apercue:supply-chain"
	Title:      "Laptop Supply Chain Dependency Graph"
}

// ═══ PROV-O Plan — Charter as Provenance Plan ════════════════════════════
// Export: cue export ./examples/supply-chain/ -e _prov_plan.plan_report --out json
_prov_plan: patterns.#ProvenancePlan & {
	Charter:    _charter
	Graph:      graph
	GateStatus: gaps.gate_status
}

// ═══ DQV — Data Quality Report ═══════════════════════════════════════════
// Export: cue export ./examples/supply-chain/ -e _quality.quality_report --out json
_quality: patterns.#DataQualityReport & {
	Graph:             graph
	DatasetURI:        "urn:apercue:supply-chain"
	ComplianceResults: compliance.results
	GapComplete:       gaps.complete
	MissingResources:  gaps.missing_resource_count
	MissingTypes:      gaps.missing_type_count
}

// ═══ SUMMARY ═══════════════════════════════════════════════════════════════
// Hidden intermediaries to avoid incomplete field references
_summary_compliance_total: len(compliance.Rules)
_summary_compliance_passed: len([for r in compliance.results if r.passed {1}])
_summary_compliance_failed: len([for r in compliance.results if !r.passed {1}])
_summary_compliance_critical_failures: len([for r in compliance.results if !r.passed && r.severity == "critical" {1}])

summary: {
	product:      _charter.name
	total_parts:  len(_parts)
	supply_tiers: 5
	graph_valid:  graph.valid
	gap: {
		complete:  gaps.complete
		missing:   gaps.missing_resource_count
		next_gate: gaps.next_gate
	}
	scheduling: {
		total_lead_days:     cpm.summary.total_duration
		critical_path_parts: cpm.summary.critical_count
		max_slack:           cpm.summary.max_slack
	}
	supply_chain_risks: spof.summary
	compliance: {
		total:             _summary_compliance_total
		passed:            _summary_compliance_passed
		failed:            _summary_compliance_failed
		critical_failures: _summary_compliance_critical_failures
	}
}
