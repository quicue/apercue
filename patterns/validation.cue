// Validation Patterns for Dependency Graphs
// Provides compile-time validation via CUE constraints
//
// Usage:
//   import "apercue.ca/patterns"
//
//   myValidation: patterns.#UniqueFieldValidation & {
//       _resources: myGraph.resources
//       _field: "name"
//   }
package patterns

import (
	"list"
	"strings"
	"apercue.ca/vocab"
)

// #UniqueFieldValidation ensures a field is unique across all resources
// Creates CUE evaluation errors if duplicates found
#UniqueFieldValidation: {
	// Input: resources collection and field to validate
	_resources: [string]: vocab.#Resource
	_field:     string

	// Extract field values
	_values: {
		for name, resource in _resources {
			if resource[_field] != _|_ {
				(name): resource[_field]
			}
		}
	}

	// Build list of names for iteration
	_names: [for n, _ in _values {n}]

	// Detect duplicates by comparing all pairs
	_duplicates: [
		for i, nameA in _names
		for j, nameB in _names
		if i < j && _values[nameA] == _values[nameB] {
			field:     _field
			value:     _values[nameA]
			resources: [nameA, nameB]
			message:   "Duplicate " + _field + ": '" + "\(_values[nameA])" + "' used by " + nameA + " and " + nameB
		},
	]

	// Fail validation if duplicates exist
	// Creates impossible constraint that CUE catches at eval time
	for dup in _duplicates {
		(dup.resources[0] + "_" + dup.resources[1] + "_" + _field + "_duplicate"): {
			_error: dup.message
			_fail:  true
			_fail:  false // Impossible: creates validation error
		}
	}

	// Expose results
	valid:  len(_duplicates) == 0
	issues: _duplicates
}

// #ReferenceValidation ensures references point to existing resources
// Validates at CUE evaluation time
#ReferenceValidation: {
	// Input: source resources, target collection, and reference field name
	_sources:  [string]: vocab.#Resource
	_targets:  [string]: _
	_refField: string // Field name in source that references target

	// Check each reference
	_missingRefs: [
		for sourceName, source in _sources
		if source[_refField] != _|_ {
			let ref = source[_refField]
			if _targets[ref] == _|_ {
				source:  sourceName
				field:   _refField
				target:  ref
				message: "Resource '" + sourceName + "' references non-existent " + _refField + " '" + ref + "'"
			}
		},
	]

	// Fail validation if missing references exist
	for missing in _missingRefs {
		(missing.source + "_" + _refField + "_missing_ref"): {
			_error: missing.message
			_fail:  true
			_fail:  false
		}
	}

	valid:  len(_missingRefs) == 0
	issues: _missingRefs
}

// #RequiredFieldsValidation ensures required fields are present on all resources
// Validates at CUE evaluation time
#RequiredFieldsValidation: {
	// Input: resources and list of required field names
	_resources:      [string]: vocab.#Resource
	_requiredFields: [...string]

	// Check each resource for required fields
	_missingFields: [
		for name, resource in _resources
		for field in _requiredFields
		if resource[field] == _|_ {
			resource: name
			field:    field
			message:  "Resource '" + name + "' missing required field '" + field + "'"
		},
	]

	// Fail validation if missing fields exist
	for missing in _missingFields {
		(missing.resource + "_missing_" + missing.field): {
			_error: missing.message
			_fail:  true
			_fail:  false
		}
	}

	valid:  len(_missingFields) == 0
	issues: _missingFields
}

// #DependencyValidation ensures depends_on references exist
// Specialized version of #ReferenceValidation for dependencies
#DependencyValidation: {
	// Input: resources collection
	_resources: [string]: vocab.#Resource

	// Check all depends_on references (struct-as-set: {[string]: true})
	_brokenDeps: [
		for name, resource in _resources
		if resource.depends_on != _|_
		for dep, _ in resource.depends_on
		if _resources[dep] == _|_ {
			source:     name
			dependency: dep
			message:    "Resource '" + name + "' depends on non-existent resource '" + dep + "'"
		},
	]

	// Fail validation if broken dependencies exist
	for broken in _brokenDeps {
		(broken.source + "_broken_dep_" + broken.dependency): {
			_error: broken.message
			_fail:  true
			_fail:  false
		}
	}

	valid:  len(_brokenDeps) == 0
	issues: _brokenDeps
}

// #TypeValidation ensures @type struct contains only valid types
#TypeValidation: {
	// Input: resources and allowed types
	_resources:    [string]: vocab.#Resource
	_allowedTypes: [...string]

	// Build set of allowed types
	_typeSet: {for t in _allowedTypes {(t): true}}

	// Check each resource's types (struct-as-set)
	_invalidTypes: [
		for name, resource in _resources
		if resource["@type"] != _|_
		for t, _ in resource["@type"]
		if _typeSet[t] == _|_ {
			resource: name
			badType:  t
			message:  "Resource '" + name + "' has invalid @type '" + t + "'"
		},
	]

	valid:  len(_invalidTypes) == 0
	issues: _invalidTypes
}

// #PatternValidation ensures a string field matches a regex pattern
// Useful for validating identifiers, slugs, or structured codes
#PatternValidation: {
	// Input: resources, field name, and pattern description (for messages)
	_resources:   [string]: vocab.#Resource
	_field:       string
	_prefix:      string // Required prefix (e.g., "urn:", "http://")
	_description: string // Human-readable pattern description

	// Check each resource's field value
	_invalidValues: [
		for name, resource in _resources
		if resource[_field] != _|_
		if !strings.HasPrefix("\(resource[_field])", _prefix) {
			resource: name
			field:    _field
			value:    "\(resource[_field])"
			message:  "Resource '" + name + "' field '" + _field + "' does not match " + _description
		},
	]

	valid:  len(_invalidValues) == 0
	issues: _invalidValues
}

// ═══════════════════════════════════════════════════════════════════════════
// COMPLIANCE CHECKING (graph-aware)
// ═══════════════════════════════════════════════════════════════════════════

// #ComplianceRule — A declarative structural rule for graph resources.
//
// Each rule selects resources by type, then asserts a property.
// Set one or more assertion fields per rule.
//
// Example rules:
//   {name: "db-monitoring", match_types: {Database: true},
//    requires_dependent_type: {MonitoringService: true}, severity: "critical"}
//   {name: "no-orphan-lb", match_types: {LoadBalancer: true},
//    must_not_be_leaf: true}
//
#ComplianceRule: {
	name:        string
	description: string | *""
	severity:    *"warning" | "critical" | "info"

	// Type selector: which resources this rule applies to
	match_types: {[string]: true}

	// Assertions (all optional — set one or more)
	requires_dependent_type?:  {[string]: true} // must have a dependent of this type
	requires_dependency_type?: {[string]: true} // must depend on something of this type
	must_not_be_root?:         true              // must depend on something
	must_not_be_leaf?:         true              // something must depend on it
	min_dependents?:           int               // minimum number of dependents
	max_depth?:                int               // maximum allowed depth
}

// #Violation — a single compliance check failure.
// Common base type so list.Concat results are well-typed.
#Violation: {
	resource: string
	check:    string
	...
}

// #ComplianceCheck — Evaluate declarative compliance rules against a graph.
//
// Takes a #Graph and a list of #ComplianceRule, returns per-rule
// pass/fail results with specific violations.
//
// Usage:
//   compliance: #ComplianceCheck & {
//     Graph: g
//     Rules: [{
//       name: "databases-need-monitoring"
//       match_types: {Database: true}
//       requires_dependent_type: {MonitoringService: true}
//       severity: "critical"
//     }]
//   }
//   // compliance.summary.failed — number of failed rules
//   // compliance.results[0].violations — list of offending resources
//
#ComplianceCheck: {
	Graph: #AnalyzableGraph
	Rules: [...#ComplianceRule]

	results: [
		for i, rule in Rules {
			// Find resources matching this rule's type selector
			let _match = {
				for rname, r in Graph.resources {
					for t, _ in r["@type"] if rule.match_types[t] != _|_ {
						(rname): true
					}
				}
			}

			// Check: requires_dependent_type
			let _v1 = [
				for rname, _ in _match
				if rule.requires_dependent_type != _|_
				let _has = len([
					for dn, _ in Graph.dependents[rname]
					for t, _ in Graph.resources[dn]["@type"]
					if rule.requires_dependent_type[t] != _|_ {1},
				]) > 0
				if !_has {
					resource: rname
					check:    "requires_dependent_type"
				},
			]

			// Check: requires_dependency_type (direct dependencies only)
			let _v2 = [
				for rname, _ in _match
				if rule.requires_dependency_type != _|_
				let _deps = *Graph.resources[rname].depends_on | {}
				let _has = len([
					for depName, _ in _deps
					for t, _ in Graph.resources[depName]["@type"]
					if rule.requires_dependency_type[t] != _|_ {1},
				]) > 0
				if !_has {
					resource: rname
					check:    "requires_dependency_type"
				},
			]

			// Check: must_not_be_root
			let _v3 = [
				for rname, _ in _match
				if rule.must_not_be_root != _|_
				if Graph.roots[rname] != _|_ {
					{resource: rname, check: "must_not_be_root"}
				},
			]

			// Check: must_not_be_leaf
			let _v4 = [
				for rname, _ in _match
				if rule.must_not_be_leaf != _|_
				if Graph.leaves[rname] != _|_ {
					{resource: rname, check: "must_not_be_leaf"}
				},
			]

			// Check: min_dependents
			let _v5 = [
				for rname, _ in _match
				if rule.min_dependents != _|_
				let _count = len([for k, _ in Graph.dependents[rname] {k}])
				if _count < rule.min_dependents {
					resource: rname
					check:    "min_dependents"
					actual:   _count
					required: rule.min_dependents
				},
			]

			// Check: max_depth
			let _v6 = [
				for rname, _ in _match
				if rule.max_depth != _|_
				if Graph.resources[rname]._depth > rule.max_depth {
					{resource: rname, check: "max_depth", actual: Graph.resources[rname]._depth, limit: rule.max_depth}
				},
			]

			let _allViolations = list.Concat([_v1, _v2, _v3, _v4, _v5, _v6])

			name:       rule.name
			severity:   rule.severity
			matching:   len([for m, _ in _match {m}])
			violations: _allViolations
			passed:     len(_allViolations) == 0
		},
	]

	summary: {
		total:             len(Rules)
		passed:            len([for r in results if r.passed {1}])
		failed:            len([for r in results if !r.passed {1}])
		critical_failures: len([for r in results if !r.passed && r.severity == "critical" {1}])
	}

	// ── SHACL ValidationReport projection ──────────────────────────
	// W3C SHACL (Recommendation, 2017-07-20): express compliance
	// results as sh:ValidationReport for interoperability with RDF
	// validation toolchains.
	//
	// Export: cue export -e compliance.shacl_report --out json
	_severity_iri: {
		"critical": "sh:Violation"
		"warning":  "sh:Warning"
		"info":     "sh:Info"
	}

	shacl_report: {
		"@context":    vocab.context["@context"]
		"@type":       "sh:ValidationReport"
		"sh:conforms": summary.failed == 0
		"sh:result": [
			for r in results if !r.passed
			for v in r.violations {
				"@type":                          "sh:ValidationResult"
				"sh:focusNode":                   {"@id": v.resource}
				"sh:sourceConstraintComponent":   {"@id": "apercue:" + v.check}
				"sh:resultSeverity":              {"@id": _severity_iri[r.severity]}
				"sh:resultMessage":               r.name + ": " + v.check + " on " + v.resource
				"sh:sourceShape":                 {"@id": "apercue:rule/" + r.name}
			},
		]
	}
}
