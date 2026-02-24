// University course prerequisites as a typed dependency graph.
//
// Proves that apercue patterns work for any domain — courses are
// resources, prerequisites are depends_on edges, degree requirements
// are charter gates.
//
// Run:
//   cue vet ./examples/course-prereqs/
//   cue eval ./examples/course-prereqs/ -e summary
//   cue eval ./examples/course-prereqs/ -e gaps.complete
//   cue eval ./examples/course-prereqs/ -e cpm.summary
//   cue export ./examples/course-prereqs/ -e gaps.shacl_report --out json

package main

import (
	"apercue.ca/patterns@v0"
	"apercue.ca/charter@v0"
)

// Type vocabulary for this domain
_types: {
	CoreCourse: true
	Elective:   true
	LabCourse:  true
	Seminar:    true
}

// ═══ COURSES ═══════════════════════════════════════════════════════
_courses: {
	"intro-cs": {
		name: "intro-cs"
		"@type": {CoreCourse: true}
		description: "Introduction to Computer Science"
		credits:     3
	}
	"intro-math": {
		name: "intro-math"
		"@type": {CoreCourse: true}
		description: "Discrete Mathematics"
		credits:     3
	}
	"data-structures": {
		name: "data-structures"
		"@type": {CoreCourse: true}
		description: "Data Structures and Algorithms"
		depends_on: {"intro-cs": true, "intro-math": true}
		credits: 3
	}
	"intro-programming": {
		name: "intro-programming"
		"@type": {CoreCourse: true, LabCourse: true}
		description: "Introduction to Programming"
		depends_on: {"intro-cs": true}
		credits: 4
	}
	"databases": {
		name: "databases"
		"@type": {CoreCourse: true}
		description: "Database Systems"
		depends_on: {"data-structures": true}
		credits: 3
	}
	"operating-systems": {
		name: "operating-systems"
		"@type": {CoreCourse: true}
		description: "Operating Systems"
		depends_on: {"data-structures": true, "intro-programming": true}
		credits: 3
	}
	"software-engineering": {
		name: "software-engineering"
		"@type": {CoreCourse: true}
		description: "Software Engineering Principles"
		depends_on: {"data-structures": true, "intro-programming": true}
		credits: 3
	}
	"networks": {
		name: "networks"
		"@type": {CoreCourse: true}
		description: "Computer Networks"
		depends_on: {"operating-systems": true}
		credits: 3
	}
	"algorithms": {
		name: "algorithms"
		"@type": {CoreCourse: true}
		description: "Advanced Algorithms"
		depends_on: {"data-structures": true, "intro-math": true}
		credits: 3
	}
	"ml-intro": {
		name: "ml-intro"
		"@type": {Elective: true}
		description: "Introduction to Machine Learning"
		depends_on: {"algorithms": true, "intro-programming": true}
		credits: 3
	}
	"systems-lab": {
		name: "systems-lab"
		"@type": {LabCourse: true, Elective: true}
		description: "Systems Programming Lab"
		depends_on: {"operating-systems": true}
		credits: 4
	}
	"capstone-seminar": {
		name: "capstone-seminar"
		"@type": {Seminar: true}
		description: "Capstone Research Seminar"
		depends_on: {"software-engineering": true, "algorithms": true}
		credits: 3
	}
}

// ═══ GRAPH ═════════════════════════════════════════════════════════
graph: patterns.#Graph & {Input: _courses}

// Critical path: longest prerequisite chain
cpm: patterns.#CriticalPath & {
	Graph: graph
	Weights: {for name, c in _courses {(name): c.credits}}
}

// ═══ CHARTER — Degree Requirements ════════════════════════════════
_charter: charter.#Charter & {
	name: "bsc-computer-science"

	scope: {
		total_resources: 12
		root: {"intro-cs": true, "intro-math": true}
		required_types: {
			CoreCourse: true
			Elective:   true
			LabCourse:  true
			Seminar:    true
		}
	}

	gates: {
		"foundations": {
			phase:       1
			description: "Core foundations complete"
			requires: {
				"intro-cs":          true
				"intro-math":        true
				"intro-programming": true
			}
		}
		"core-complete": {
			phase:       2
			description: "All core courses taken"
			requires: {
				"data-structures":      true
				"databases":            true
				"operating-systems":    true
				"software-engineering": true
				"algorithms":           true
				"networks":             true
			}
			depends_on: {"foundations": true}
		}
		"graduation": {
			phase:       3
			description: "Degree requirements satisfied"
			requires: {
				"ml-intro":         true
				"systems-lab":      true
				"capstone-seminar": true
			}
			depends_on: {"core-complete": true}
		}
	}
}

// Gap analysis — what courses are still needed?
gaps: charter.#GapAnalysis & {
	Charter: _charter
	Graph:   graph
}

// Compliance: structural rules about the course graph
compliance: patterns.#ComplianceCheck & {
	Graph: graph
	Rules: [
		{
			name:        "seminars-need-prereqs"
			description: "Seminar courses must have prerequisites"
			match_types: {Seminar: true}
			must_not_be_root: true
			severity:         "warning"
		},
		{
			name:        "labs-need-prereqs"
			description: "Lab courses must have prerequisites"
			match_types: {LabCourse: true}
			must_not_be_root: true
			severity:         "warning"
		},
	]
}

// ═══ SUMMARY ═══════════════════════════════════════════════════════
// Hidden intermediaries to avoid incomplete field references
_summary_compliance_total: len(compliance.Rules)
_summary_compliance_passed: len([for r in compliance.results if r.passed {1}])
_summary_compliance_failed: len([for r in compliance.results if !r.passed {1}])
_summary_compliance_critical_failures: len([for r in compliance.results if !r.passed && r.severity == "critical" {1}])

summary: {
	degree:          _charter.name
	total_courses:   len(_courses)
	graph_valid:     graph.valid
	degree_complete: gaps.complete
	gap: {
		missing_courses: gaps.missing_resource_count
		missing_types:   gaps.missing_type_count
		next_gate:       gaps.next_gate
	}
	scheduling: cpm.summary
	compliance: {
		total:             _summary_compliance_total
		passed:            _summary_compliance_passed
		failed:            _summary_compliance_failed
		critical_failures: _summary_compliance_critical_failures
	}
}
