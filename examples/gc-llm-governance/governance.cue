// Government of Canada LLM Governance as a typed dependency graph.
//
// Models the full lifecycle of LLM constraint, control, and compliance
// for the federal government: obligations, control objectives, compliance
// rules, knowledge grounding, ODRL policies, provider binding, deployments,
// audit, and W3C-standard compliance reporting.
//
// The insight: governance IS a dependency graph. Statutes produce directives,
// directives produce control objectives, objectives produce rules, rules
// constrain deployments, deployments produce audit evidence, evidence
// produces compliance reports. Critical path = longest chain to demonstrable
// compliance (targeting the June 24, 2026 Directive deadline).
//
// Run:
//   cue vet ./examples/gc-llm-governance/
//   cue eval ./examples/gc-llm-governance/ -e summary
//   cue eval ./examples/gc-llm-governance/ -e gaps.complete
//   cue eval ./examples/gc-llm-governance/ -e cpm.summary
//   cue export ./examples/gc-llm-governance/ -e cpm.critical_sequence --out json
//   cue export ./examples/gc-llm-governance/ -e compliance.shacl_report --out json

package main

import (
	"list"
	"strings"
	"strconv"

	"apercue.ca/patterns@v0"
	"apercue.ca/charter@v0"
)

// ═══ GOVERNANCE RESOURCES ════════════════════════════════════════════════════

_tasks: {
	// ── Phase 1: Foundation — Obligation Graph ─────────────────────
	"gc-llm-governance-framework": {
		name: "gc-llm-governance-framework"
		"@type": {Framework: true}
		description: "Root: constraint-first LLM governance using apercue/quicue/quicue-kg"
	}
	"directive-on-adm": {
		name: "directive-on-adm"
		"@type": {Directive: true}
		description: "TBS Directive on Automated Decision-Making (compliance deadline: 2026-06-24)"
		depends_on: {"gc-llm-governance-framework": true}
	}
	"privacy-act": {
		name: "privacy-act"
		"@type": {Statute: true}
		description: "Privacy Act — s.7 use limitation, s.8 disclosure limitation"
		depends_on: {"gc-llm-governance-framework": true}
	}
	"official-languages-act": {
		name: "official-languages-act"
		"@type": {Statute: true}
		description: "Official Languages Act — simultaneous bilingual output, equal quality"
		depends_on: {"gc-llm-governance-framework": true}
	}
	"cccs-itsap-00-041": {
		name: "cccs-itsap-00-041"
		"@type": {SecurityGuidance: true}
		description: "CCCS Generative AI guidance — 8 threat categories"
		depends_on: {"gc-llm-governance-framework": true}
	}
	"genai-guide-v2": {
		name: "genai-guide-v2"
		"@type": {Guide: true}
		description: "TBS Guide on the Use of Generative AI (v2) — FASTER principles"
		depends_on: {"directive-on-adm": true}
	}
	"faster-principles": {
		name: "faster-principles"
		"@type": {Principle: true}
		description: "FASTER: Fair, Accountable, Secure, Transparent, Educated, Relevant"
		depends_on: {"genai-guide-v2": true}
	}
	"aia-requirement": {
		name: "aia-requirement"
		"@type": {Directive: true}
		description: "Algorithmic Impact Assessment — mandatory risk assessment before deployment"
		depends_on: {"directive-on-adm": true}
	}

	// ── Phase 2: Impact Levels & Control Objectives ───────────────
	"aia-level-i": {
		name: "aia-level-i"
		"@type": {ImpactLevel: true}
		description: "AIA Level I — little/no impact, easily reversible"
		depends_on: {"aia-requirement": true}
	}
	"aia-level-ii": {
		name: "aia-level-ii"
		"@type": {ImpactLevel: true}
		description: "AIA Level II — moderate impact, likely reversible (peer review required)"
		depends_on: {"aia-level-i": true}
	}
	"aia-level-iii": {
		name: "aia-level-iii"
		"@type": {ImpactLevel: true}
		description: "AIA Level III — high impact, difficult to reverse (human-in-the-loop required)"
		depends_on: {"aia-level-ii": true}
	}
	"aia-level-iv": {
		name: "aia-level-iv"
		"@type": {ImpactLevel: true}
		description: "AIA Level IV — very high, irreversible (TB approval required)"
		depends_on: {"aia-level-iii": true}
	}
	"pii-prompt-blocking": {
		name: "pii-prompt-blocking"
		"@type": {ControlObjective: true}
		description: "Block PII from entering LLM prompts — Privacy Act s.8 compliance"
		depends_on: {"privacy-act": true}
	}
	"vendor-data-classification": {
		name: "vendor-data-classification"
		"@type": {ControlObjective: true}
		description: "Enforce data classification for LLM vendor selection"
		depends_on: {"privacy-act": true}
	}
	"bilingual-quality-parity": {
		name: "bilingual-quality-parity"
		"@type": {ControlObjective: true}
		description: "EN/FR output quality parity — OLA compliance"
		depends_on: {"official-languages-act": true}
	}
	"human-in-loop-gate": {
		name: "human-in-loop-gate"
		"@type": {ControlObjective: true}
		description: "Human review required for AIA Level III+ decisions"
		depends_on: {"aia-level-iii": true}
	}
	"peer-review-mechanism": {
		name: "peer-review-mechanism"
		"@type": {ControlObjective: true}
		description: "Qualified peer review for AIA Level II+ systems"
		depends_on: {"aia-level-ii": true}
	}
	"bias-testing-framework": {
		name: "bias-testing-framework"
		"@type": {ControlObjective: true}
		description: "Demographic bias testing per Directive Appendix C"
		depends_on: {"directive-on-adm": true}
	}

	// ── Phase 3: Compliance Rules (apercue #ComplianceRule) ──────
	"rule-pii-blocking": {
		name: "rule-pii-blocking"
		"@type": {ComplianceRule: true}
		description: "Block Protected B+ data from commercial LLM prompts"
		depends_on: {"pii-prompt-blocking": true}
	}
	"rule-classification-enforcement": {
		name: "rule-classification-enforcement"
		"@type": {ComplianceRule: true}
		description: "Enforce Unclassified/Protected A/B classification on provider selection"
		depends_on: {"vendor-data-classification": true}
	}
	"rule-bilingual-output": {
		name: "rule-bilingual-output"
		"@type": {ComplianceRule: true}
		description: "All public-facing LLM outputs must be available in both EN and FR"
		depends_on: {"bilingual-quality-parity": true}
	}
	"rule-human-review-level-iii": {
		name: "rule-human-review-level-iii"
		"@type": {ComplianceRule: true}
		description: "AIA Level III+ decisions require documented human review"
		depends_on: {"human-in-loop-gate": true}
	}
	"rule-peer-review-level-ii": {
		name: "rule-peer-review-level-ii"
		"@type": {ComplianceRule: true}
		description: "AIA Level II+ systems require qualified peer review"
		depends_on: {"peer-review-mechanism": true}
	}
	"rule-bias-demographic": {
		name: "rule-bias-demographic"
		"@type": {ComplianceRule: true}
		description: "Test for unintended demographic biases in LLM outputs"
		depends_on: {"bias-testing-framework": true}
	}
	"rule-cccs-threat-coverage": {
		name: "rule-cccs-threat-coverage"
		"@type": {ComplianceRule: true}
		description: "Address all 8 CCCS generative AI threat categories"
		depends_on: {"cccs-itsap-00-041": true}
	}
	"rule-faster-coverage": {
		name: "rule-faster-coverage"
		"@type": {ComplianceRule: true}
		description: "Demonstrate coverage of all 6 FASTER principles"
		depends_on: {"faster-principles": true}
	}

	// ── Phase 4: Knowledge Graph — Authoritative Sources ─────────
	"knowledge-graph-schema": {
		name: "knowledge-graph-schema"
		"@type": {DomainScope: true}
		description: "quicue-kg schema for authoritative knowledge grounding"
		depends_on: {"gc-llm-governance-framework": true}
	}
	"policy-fact-registry": {
		name: "policy-fact-registry"
		"@type": {PolicyFact: true}
		description: "Verified facts from statutes, directives, and guides"
		depends_on: {"knowledge-graph-schema": true}
	}
	"authoritative-source-index": {
		name: "authoritative-source-index"
		"@type": {AuthoritativeSource: true}
		description: "Source documents with SHA256 integrity and freshness dates"
		depends_on: {"knowledge-graph-schema": true}
	}
	"term-definitions-registry": {
		name: "term-definitions-registry"
		"@type": {TermDefinition: true}
		description: "Authoritative term definitions (prevents LLM-invented definitions)"
		depends_on: {"knowledge-graph-schema": true}
	}
	"domain-scope-procurement": {
		name: "domain-scope-procurement"
		"@type": {DomainScope: true}
		description: "Knowledge boundary for procurement-domain LLM deployments"
		depends_on: {"knowledge-graph-schema": true}
	}
	"domain-scope-hr": {
		name: "domain-scope-hr"
		"@type": {DomainScope: true}
		description: "Knowledge boundary for HR-domain LLM deployments"
		depends_on: {"knowledge-graph-schema": true}
	}

	// ── Phase 5: ODRL Policies & Provider Binding ────────────────
	"odrl-unclassified": {
		name: "odrl-unclassified"
		"@type": {PolicyConstraint: true}
		description: "ODRL policy for Unclassified data — commercial LLMs permitted"
		depends_on: {"rule-classification-enforcement": true}
	}
	"odrl-protected-a": {
		name: "odrl-protected-a"
		"@type": {PolicyConstraint: true}
		description: "ODRL policy for Protected A — GC-controlled infrastructure only"
		depends_on: {"rule-classification-enforcement": true}
	}
	"odrl-protected-b": {
		name: "odrl-protected-b"
		"@type": {PolicyConstraint: true}
		description: "ODRL policy for Protected B — GC cloud provider with PII blocking"
		depends_on: {"rule-classification-enforcement": true, "rule-pii-blocking": true}
	}
	"provider-gc-cloud": {
		name: "provider-gc-cloud"
		"@type": {LLMProvider: true}
		description: "GC cloud provider — GC-tenant, Protected B capable"
		depends_on: {"odrl-protected-b": true}
	}
	"provider-bedrock": {
		name: "provider-bedrock"
		"@type": {LLMProvider: true}
		description: "AWS Bedrock — GC region, Protected A capable"
		depends_on: {"odrl-protected-a": true}
	}
	"provider-self-hosted": {
		name: "provider-self-hosted"
		"@type": {LLMProvider: true}
		description: "Self-hosted LLM (Ollama/vLLM) — air-gapped, any classification"
		depends_on: {"odrl-unclassified": true}
	}

	// ── Phase 6: Deployment Models ───────────────────────────────
	"deployment-procurement-assistant": {
		name: "deployment-procurement-assistant"
		"@type": {LLMDeployment: true}
		description: "Procurement assistant — GC cloud provider, bilingual, scope-bounded"
		depends_on: {"provider-gc-cloud": true, "domain-scope-procurement": true, "rule-bilingual-output": true}
	}
	"deployment-hr-assistant": {
		name: "deployment-hr-assistant"
		"@type": {LLMDeployment: true}
		description: "HR assistant — GC cloud provider, bilingual, PII-gated"
		depends_on: {"provider-gc-cloud": true, "domain-scope-hr": true, "rule-bilingual-output": true}
	}
	"deployment-internal-search": {
		name: "deployment-internal-search"
		"@type": {LLMDeployment: true}
		description: "Internal knowledge search — self-hosted, knowledge-grounded"
		depends_on: {"provider-self-hosted": true, "knowledge-graph-schema": true}
	}
	"classification-gate": {
		name: "classification-gate"
		"@type": {ClassificationGate: true}
		description: "Runtime data classification checkpoint before LLM invocation"
		depends_on: {"rule-classification-enforcement": true}
	}
	"bilingual-gate": {
		name: "bilingual-gate"
		"@type": {BilingualGate: true}
		description: "Runtime EN/FR quality validation checkpoint"
		depends_on: {"rule-bilingual-output": true}
	}
	"human-review-gate": {
		name: "human-review-gate"
		"@type": {HumanReviewGate: true}
		description: "Human review checkpoint for AIA Level III+ decisions"
		depends_on: {"rule-human-review-level-iii": true}
	}

	// ── Phase 7: Audit & Provenance ──────────────────────────────
	"audit-sink-prov-o": {
		name: "audit-sink-prov-o"
		"@type": {AuditSink: true}
		description: "PROV-O audit trail — every LLM response traced to source knowledge"
		depends_on: {"deployment-procurement-assistant": true, "deployment-hr-assistant": true}
	}
	"smoke-test-bilingual": {
		name: "smoke-test-bilingual"
		"@type": {SmokeTest: true}
		description: "EARL smoke test — EN/FR quality parity validation"
		depends_on: {"bilingual-gate": true}
	}
	"smoke-test-pii-blocking": {
		name: "smoke-test-pii-blocking"
		"@type": {SmokeTest: true}
		description: "EARL smoke test — PII blocked from commercial LLM prompts"
		depends_on: {"classification-gate": true}
	}
	"smoke-test-scope-enforcement": {
		name: "smoke-test-scope-enforcement"
		"@type": {SmokeTest: true}
		description: "EARL smoke test — LLM stays within domain scope boundaries"
		depends_on: {"deployment-procurement-assistant": true}
	}

	// ── Phase 8: Compliance Reporting & W3C Projections ──────────
	"shacl-compliance-report": {
		name: "shacl-compliance-report"
		"@type": {ComplianceReport: true}
		description: "sh:ValidationReport — per-rule conformance for TBS/OAG auditors"
		depends_on: {"audit-sink-prov-o": true}
	}
	"vc-compliance-credential": {
		name: "vc-compliance-credential"
		"@type": {VerifiableCredential: true}
		description: "VC 2.0 credential attesting compliance (wraps SHACL report)"
		depends_on: {"shacl-compliance-report": true}
	}
	"dcat-ai-register-entry": {
		name: "dcat-ai-register-entry"
		"@type": {CatalogEntry: true}
		description: "DCAT 3 catalog entry for GC AI Register (machine-readable)"
		depends_on: {"deployment-procurement-assistant": true, "deployment-hr-assistant": true}
	}
	"owl-time-compliance-schedule": {
		name: "owl-time-compliance-schedule"
		"@type": {Schedule: true}
		description: "OWL-Time critical path schedule to June 2026 compliance deadline"
		depends_on: {"shacl-compliance-report": true}
	}
}

// ═══ GRAPH CONSTRUCTION ══════════════════════════════════════════════════════
// 52 nodes — use #GraphLite with Python-precomputed topology (ADR-007).
// CUE's recursive fixpoint times out on diamond DAGs this size.
graph: patterns.#GraphLite & {Input: _tasks, Precomputed: _precomputed}

// ═══ CRITICAL PATH ANALYSIS ══════════════════════════════════════════════════
// CPM: precomputed in Python (CUE's recursive fixpoint is too slow for 52 nodes).
// Run: python3 tools/toposort.py ./examples/gc-llm-governance/governance.cue --cue > examples/gc-llm-governance/precomputed.cue
cpm: patterns.#CriticalPathPrecomputed & {
	Graph:       graph
	Precomputed: _precomputed_cpm
}

// ═══ SINGLE POINTS OF FAILURE ════════════════════════════════════════════════
spof: patterns.#SinglePointsOfFailure & {Graph: graph}

// ═══ SHACL SHAPES — Generate NodeShapes from graph type structure ════════════
// Export: cue export ./examples/gc-llm-governance/ -e shape_export.shapes_graph --out json
shape_export: patterns.#SHACLShapes & {
	Graph:     graph
	Namespace: "https://apercue.ca/shapes/gc-governance#"
}

// ═══ SKOS TAXONOMY — Hierarchical type vocabulary ═══════════════════════════
// Export: cue export ./examples/gc-llm-governance/ -e taxonomy.taxonomy_scheme --out json
_taxonomy: patterns.#SKOSTaxonomy & {
	Graph:       graph
	SchemeTitle: "GC LLM Governance Type Taxonomy"
	Hierarchy: {
		"Obligation":  ["Statute", "Directive", "Standard", "Guidance"]
		"Control":     ["ControlObjective", "ComplianceRule"]
		"Operational": ["Provider", "Deployment", "Gate", "SmokeTest"]
		"Evidence":    ["AuditSink", "ComplianceReport", "Credential", "CatalogEntry", "Schedule"]
	}
}

// ═══ OWL Ontology — Formal vocabulary from governance types ══════════════════
// Export: cue export ./examples/gc-llm-governance/ -e _ontology.owl_ontology --out json
_ontology: patterns.#OWLOntology & {
	Graph: graph
	Spec: {
		URI:         "https://apercue.ca/ontology/gc-governance#"
		Title:       "GC LLM Governance Ontology"
		Description: "OWL vocabulary from GC LLM governance dependency graph"
	}
	Hierarchy: {
		"Obligation":  ["Statute", "Directive", "Guide", "SecurityGuidance", "Principle", "Framework"]
		"Control":     ["ControlObjective", "ComplianceRule", "ImpactLevel"]
		"Operational": ["LLMProvider", "LLMDeployment", "ClassificationGate", "BilingualGate", "HumanReviewGate"]
		"Evidence":    ["AuditSink", "ComplianceReport", "VerifiableCredential", "CatalogEntry", "Schedule", "SmokeTest"]
		"Knowledge":   ["DomainScope", "PolicyFact", "AuthoritativeSource", "TermDefinition"]
		"Policy":      ["PolicyConstraint"]
	}
}

// ═══ VoID — Graph Self-Description ═══════════════════════════════════════════
// Export: cue export ./examples/gc-llm-governance/ -e void_dataset.void_description --out json
void_dataset: patterns.#VoIDDataset & {
	Graph:      graph
	DatasetURI: "urn:gc:llm-governance:dataset"
	Title:      "GC LLM Governance Dependency Graph"
	Homepage:   "https://apercue.ca/gc-governance.html"
}

// ═══ PROV-O Plan — Charter as Provenance Plan ═══════════════════════════════
// Export: cue export ./examples/gc-llm-governance/ -e _prov_plan.plan_report --out json
_prov_plan: patterns.#ProvenancePlan & {
	Charter:    _charter
	Graph:      graph
	GateStatus: gaps.gate_status
	Agent:      "urn:gc:agent:governance-framework"
}

// ═══ DQV — Data Quality Report ══════════════════════════════════════════════
// Export: cue export ./examples/gc-llm-governance/ -e _quality.quality_report --out json
_quality: patterns.#DataQualityReport & {
	Graph:             graph
	DatasetURI:        "urn:gc:llm-governance:dataset"
	ComplianceResults: compliance.results
	GapComplete:       gaps.complete
	MissingResources:  gaps.missing_resource_count
	MissingTypes:      gaps.missing_type_count
}

// ═══ CHARTER — GC LLM Governance Completeness ═══════════════════════════════
_charter: charter.#Charter & {
	name: "gc-llm-governance"

	scope: {
		total_resources: len(_tasks)
		root: {
			"gc-llm-governance-framework": true
		}
		required_types: {
			Statute:          true
			Directive:        true
			Guide:            true
			ControlObjective: true
			ComplianceRule:   true
			PolicyConstraint: true
			LLMDeployment:    true
			AuditSink:        true
			DomainScope:      true
			PolicyFact:       true
		}
	}

	gates: {
		"obligations-mapped": {
			phase:       1
			description: "All legal/policy obligations mapped as graph nodes"
			requires: {
				"gc-llm-governance-framework": true
				"directive-on-adm":            true
				"privacy-act":                 true
				"official-languages-act":      true
				"cccs-itsap-00-041":           true
				"genai-guide-v2":              true
				"faster-principles":           true
				"aia-requirement":             true
			}
		}
		"controls-defined": {
			phase:       2
			description: "AIA impact levels + all control objectives defined"
			requires: {
				"aia-level-i":                true
				"aia-level-ii":               true
				"aia-level-iii":              true
				"aia-level-iv":               true
				"pii-prompt-blocking":        true
				"vendor-data-classification": true
				"bilingual-quality-parity":   true
				"human-in-loop-gate":         true
				"peer-review-mechanism":      true
				"bias-testing-framework":     true
			}
			depends_on: {"obligations-mapped": true}
		}
		"rules-compilable": {
			phase:       3
			description: "All compliance rules pass cue vet, SHACL report exports"
			requires: {
				"rule-pii-blocking":               true
				"rule-classification-enforcement": true
				"rule-bilingual-output":           true
				"rule-human-review-level-iii":     true
				"rule-peer-review-level-ii":       true
				"rule-bias-demographic":           true
				"rule-cccs-threat-coverage":       true
				"rule-faster-coverage":            true
			}
			depends_on: {"controls-defined": true}
		}
		"knowledge-grounded": {
			phase:       4
			description: "Authoritative knowledge graph validates, domain scopes defined"
			requires: {
				"knowledge-graph-schema":     true
				"policy-fact-registry":       true
				"authoritative-source-index": true
				"term-definitions-registry":  true
				"domain-scope-procurement":   true
				"domain-scope-hr":            true
			}
			depends_on: {"rules-compilable": true}
		}
		"policies-bound": {
			phase:       5
			description: "ODRL policies export valid JSON-LD, provider binding resolves"
			requires: {
				"odrl-unclassified":    true
				"odrl-protected-a":     true
				"odrl-protected-b":     true
				"provider-gc-cloud":    true
				"provider-bedrock":     true
				"provider-self-hosted": true
			}
			depends_on: {"knowledge-grounded": true}
		}
		"deployments-modeled": {
			phase:       6
			description: "Reference LLM deployments with full constraint binding"
			requires: {
				"deployment-procurement-assistant": true
				"deployment-hr-assistant":          true
				"deployment-internal-search":       true
				"classification-gate":              true
				"bilingual-gate":                   true
				"human-review-gate":                true
			}
			depends_on: {"policies-bound": true}
		}
		"audit-operational": {
			phase:       7
			description: "PROV-O audit trail and EARL smoke tests operational"
			requires: {
				"audit-sink-prov-o":            true
				"smoke-test-bilingual":         true
				"smoke-test-pii-blocking":      true
				"smoke-test-scope-enforcement": true
			}
			depends_on: {"deployments-modeled": true}
		}
		"compliance-demonstrable": {
			phase:       8
			description: "Full W3C projection suite — SHACL, VC, DCAT, OWL-Time"
			requires: {
				"shacl-compliance-report":      true
				"vc-compliance-credential":     true
				"dcat-ai-register-entry":       true
				"owl-time-compliance-schedule": true
			}
			depends_on: {"audit-operational": true}
		}
	}
}

// ═══ GAP ANALYSIS ════════════════════════════════════════════════════════════
gaps: charter.#GapAnalysis & {
	Charter: _charter
	Graph:   graph
}

// ═══ COMPLIANCE RULES ════════════════════════════════════════════════════════
// Structural rules enforced across the governance graph
compliance: patterns.#ComplianceCheck & {
	Graph: graph
	Rules: [
		{
			name:        "deployments-need-providers"
			description: "Every LLM deployment must depend on an LLM provider"
			match_types: {LLMDeployment: true}
			must_not_be_root: true
			severity:         "critical"
		},
		{
			name:        "providers-need-policies"
			description: "Every LLM provider must depend on a classification policy"
			match_types: {LLMProvider: true}
			must_not_be_root: true
			severity:         "critical"
		},
		{
			name:        "rules-need-objectives"
			description: "Every compliance rule must trace to a control objective"
			match_types: {ComplianceRule: true}
			must_not_be_root: true
			severity:         "critical"
		},
		{
			name:        "objectives-need-obligations"
			description: "Every control objective must trace to a statute, directive, or guide"
			match_types: {ControlObjective: true}
			must_not_be_root: true
			severity:         "critical"
		},
		{
			name:        "audit-needs-deployments"
			description: "Audit sinks must depend on deployed LLM instances"
			match_types: {AuditSink: true}
			must_not_be_root: true
			severity:         "critical"
		},
		{
			name:        "reports-need-audit"
			description: "Compliance reports must depend on audit evidence"
			match_types: {ComplianceReport: true}
			must_not_be_root: true
			severity:         "critical"
		},
	]
}

// ═══ SUMMARY ═════════════════════════════════════════════════════════════════
_summary_compliance_total: len(compliance.Rules)
_summary_compliance_passed: len([for r in compliance.results if r.passed {1}])
_summary_compliance_failed: len([for r in compliance.results if !r.passed {1}])
_summary_compliance_critical_failures: len([for r in compliance.results if !r.passed && r.severity == "critical" {1}])

summary: {
	project:           _charter.name
	total_resources:   len(_tasks)
	governance_layers: 8
	graph_valid:       graph.valid
	gap: {
		complete:  gaps.complete
		missing:   gaps.missing_resource_count
		next_gate: gaps.next_gate
	}
	scheduling: {
		total_work_days:     cpm.summary.total_duration
		critical_path_nodes: cpm.summary.critical_count
		max_slack:           cpm.summary.max_slack
	}
	single_points_of_failure: spof.summary
	compliance: {
		total:             _summary_compliance_total
		passed:            _summary_compliance_passed
		failed:            _summary_compliance_failed
		critical_failures: _summary_compliance_critical_failures
	}
}

// ═══ UNIFIED W3C PROJECTIONS ═════════════════════════════════════════════════
// Single export combining all W3C outputs.
// Export: cue export ./examples/gc-llm-governance/ -e projections --out json
projections: {
	shacl:    compliance.shacl_report
	owl_time: cpm.time_report
	odrl:     odrl_policies
	prov:     provenance
	prov_plan: _prov_plan.plan_report
	dcat:     dcat_catalog
	vc:       vc_credential.vc
	skos:     type_vocab.concept_scheme
	shapes:   shape_export.shapes_graph
	taxonomy: _taxonomy.taxonomy_scheme
	void:     void_dataset.void_description
	quality:  _quality.quality_report
	ontology: _ontology.owl_ontology
	scheduling: {
		summary:           cpm.summary
		critical_sequence: cpm.critical_sequence
	}
}

// ═══ VISUALIZATION EXPORT ════════════════════════════════════════════════════
// Export-friendly data for D3 charter visualization.
// Run: cue export ./examples/gc-llm-governance/ -e viz --out json

_depth_map: {
	for layerName, members in graph.topology {
		let _n = strconv.Atoi(strings.TrimPrefix(layerName, "layer_"))
		for rname, _ in members {
			(rname): _n
		}
	}
}

viz: {
	nodes: [
		for rname, raw in _tasks {
			id:   rname
			name: rname
			types: [for t, _ in raw["@type"] {t}]
			depth:       _depth_map[rname]
			description: raw.description
			// Phase from charter gates
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
				resources: [for r, _ in gate.requires {r}]
			}
		}
	}
	charter_summary: summary
	topology:        graph.topology
	scheduling: {
		summary:           cpm.summary
		critical_sequence: cpm.critical_sequence
	}
}
