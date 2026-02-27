// Data Quality Vocabulary (DQV) — quality metrics from validation.
//
// Maps compliance check results and graph health metrics to W3C DQV.
// A #ComplianceCheck already knows pass/fail — DQV wraps those results
// in a standard quality vocabulary with dimensions and metrics.
//
// W3C DQV (Vocabulary for describing quality, 2016-12-15):
// Part of the DWBP (Data on the Web Best Practices) family.
//
// Uses: dqv:QualityMeasurement, dqv:Metric, dqv:Dimension, dqv:Category
//
// Export: cue export -e quality.quality_report --out json

package patterns

import "apercue.ca/vocab"

// #DataQualityReport — Project graph validation results as DQV quality measurements.
//
// Input: a graph and its compliance/gap analysis results.
// Output: dqv:QualityMeasurement entries organized by dimension.
//
// Dimensions:
//   - Completeness: gap analysis (missing resources/types)
//   - Consistency: compliance rules (structural invariants)
//   - Accessibility: graph connectivity (roots, leaves, components)
#DataQualityReport: {
	Graph: #AnalyzableGraph

	// Dataset identifier for the quality measurements
	DatasetURI: string | *"urn:apercue:dataset"

	// Compliance results (from #ComplianceCheck)
	ComplianceResults?: [...{
		name:     string
		passed:   bool
		severity: string
		...
	}]

	// Gap analysis results (from #GapAnalysis)
	GapComplete?:      bool
	MissingResources?: int
	MissingTypes?:     int

	// ── Computed metrics ─────────────────────────────────────────

	_entity_count: len(Graph.resources)
	_root_count:   len(Graph.roots)
	_leaf_count:   len(Graph.leaves)
	_layer_count:  len(Graph.topology)

	// Dependency coverage: fraction of non-root resources (have dependencies)
	_non_roots: len([for name, _ in Graph.resources if Graph.roots[name] == _|_ {1}])
	_dep_coverage: {
		if _entity_count > 0 {
			_non_roots * 100 / _entity_count
		}
		if _entity_count == 0 {
			0
		}
	}

	// Compliance pass rate
	_compliance_total:  len(*ComplianceResults | [])
	_compliance_passed: len([for r in *ComplianceResults | [] if r.passed {1}])
	_compliance_rate: {
		if _compliance_total > 0 {
			_compliance_passed * 100 / _compliance_total
		}
		if _compliance_total == 0 {
			100
		}
	}

	// ── DQV JSON-LD output ───────────────────────────────────────

	quality_report: {
		"@context": vocab.context["@context"]
		"@graph": [
			// ── Category: Intrinsic ──────────────────────────────
			{
				"@type":          "dqv:Category"
				"@id":            "apercue:quality/Intrinsic"
				"skos:prefLabel": "Intrinsic Data Quality"
			},

			// ── Dimension: Consistency ───────────────────────────
			{
				"@type":          "dqv:Dimension"
				"@id":            "apercue:quality/Consistency"
				"skos:prefLabel": "Consistency"
				"dqv:inCategory": {"@id": "apercue:quality/Intrinsic"}
			},

			// Metric: compliance pass rate
			{
				"@type":          "dqv:Metric"
				"@id":            "apercue:quality/CompliancePassRate"
				"skos:prefLabel": "Compliance Pass Rate"
				"skos:definition": "Percentage of compliance rules that pass"
				"dqv:inDimension": {"@id": "apercue:quality/Consistency"}
			},

			// Measurement: compliance pass rate value
			{
				"@type":             "dqv:QualityMeasurement"
				"@id":               "apercue:quality/measurement/compliance-rate"
				"dqv:isMeasurementOf": {"@id": "apercue:quality/CompliancePassRate"}
				"dqv:computedOn":    {"@id": DatasetURI}
				"dqv:value":         _compliance_rate
			},

			// ── Dimension: Completeness ──────────────────────────
			{
				"@type":          "dqv:Dimension"
				"@id":            "apercue:quality/Completeness"
				"skos:prefLabel": "Completeness"
				"dqv:inCategory": {"@id": "apercue:quality/Intrinsic"}
			},

			// Metric: gap completeness
			{
				"@type":          "dqv:Metric"
				"@id":            "apercue:quality/GapCompleteness"
				"skos:prefLabel": "Charter Gap Completeness"
				"skos:definition": "Whether all charter gates are satisfied"
				"dqv:inDimension": {"@id": "apercue:quality/Completeness"}
			},

			// Measurement: gap completeness value
			{
				"@type":             "dqv:QualityMeasurement"
				"@id":               "apercue:quality/measurement/gap-completeness"
				"dqv:isMeasurementOf": {"@id": "apercue:quality/GapCompleteness"}
				"dqv:computedOn":    {"@id": DatasetURI}
				if GapComplete != _|_ {
					"dqv:value": GapComplete
				}
				if GapComplete == _|_ {
					"dqv:value": "unknown"
				}
			},

			// Metric: missing resource count
			{
				"@type":          "dqv:Metric"
				"@id":            "apercue:quality/MissingResources"
				"skos:prefLabel": "Missing Resource Count"
				"skos:definition": "Number of resources required by charter but absent from graph"
				"dqv:inDimension": {"@id": "apercue:quality/Completeness"}
			},

			// Measurement: missing resources
			{
				"@type":             "dqv:QualityMeasurement"
				"@id":               "apercue:quality/measurement/missing-resources"
				"dqv:isMeasurementOf": {"@id": "apercue:quality/MissingResources"}
				"dqv:computedOn":    {"@id": DatasetURI}
				"dqv:value":         *(MissingResources) | 0
			},

			// ── Dimension: Accessibility ─────────────────────────
			{
				"@type":          "dqv:Dimension"
				"@id":            "apercue:quality/Accessibility"
				"skos:prefLabel": "Accessibility"
				"dqv:inCategory": {"@id": "apercue:quality/Intrinsic"}
			},

			// Metric: dependency coverage
			{
				"@type":          "dqv:Metric"
				"@id":            "apercue:quality/DependencyCoverage"
				"skos:prefLabel": "Dependency Coverage"
				"skos:definition": "Percentage of resources with at least one dependency"
				"dqv:inDimension": {"@id": "apercue:quality/Accessibility"}
			},

			// Measurement: dependency coverage value
			{
				"@type":             "dqv:QualityMeasurement"
				"@id":               "apercue:quality/measurement/dep-coverage"
				"dqv:isMeasurementOf": {"@id": "apercue:quality/DependencyCoverage"}
				"dqv:computedOn":    {"@id": DatasetURI}
				"dqv:value":         _dep_coverage
			},

			// Metric: graph depth
			{
				"@type":          "dqv:Metric"
				"@id":            "apercue:quality/GraphDepth"
				"skos:prefLabel": "Graph Depth"
				"skos:definition": "Number of topology layers in the dependency graph"
				"dqv:inDimension": {"@id": "apercue:quality/Accessibility"}
			},

			// Measurement: graph depth value
			{
				"@type":             "dqv:QualityMeasurement"
				"@id":               "apercue:quality/measurement/graph-depth"
				"dqv:isMeasurementOf": {"@id": "apercue:quality/GraphDepth"}
				"dqv:computedOn":    {"@id": DatasetURI}
				"dqv:value":         _layer_count
			},
		]
	}

	summary: {
		dataset:            DatasetURI
		entity_count:       _entity_count
		compliance_rate:    _compliance_rate
		dependency_coverage: _dep_coverage
		graph_depth:        _layer_count
		complete:           *(GapComplete) | false
	}
}
