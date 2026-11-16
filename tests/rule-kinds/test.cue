// Every #ComplianceRule kind, on a graph where each rule has both passing
// and failing resources. tests/rdf/test_rdf.py compiles the rules to SHACL
// and checks apercue and pyshacl report the same (shape, focus node) pairs,
// on this graph and on mutations of it.
package test

import "apercue.ca/patterns@v0"

// Input is in input.cue so the mutation harness can replace it.


_g: patterns.#Graph & {"Input": Input}

Rules: [
	{name: "svc-not-root", match_types: {Service: true}, must_not_be_root: true},
	{name: "svc-not-leaf", match_types: {Service: true}, must_not_be_leaf: true},
	{name: "store-two-dependents", match_types: {Database: true, Cache: true}, min_dependents: 2},
	{name: "svc-needs-db", match_types: {Service: true}, requires_dependency_type: {Database: true}},
	{name: "svc-needs-store", match_types: {Service: true, Frontend: true}, requires_dependency_type: {Database: true, Cache: true}},
	{name: "store-monitored", match_types: {Database: true, Cache: true}, requires_dependent_type: {Monitor: true}},
	{name: "front-reaches-db", match_types: {Frontend: true, Monitor: true}, requires_transitive_dependency_type: {Database: true}},
]

cc: patterns.#ComplianceCheck & {Graph: _g, "Rules": Rules}
data: patterns.#DataGraph & {Graph: _g}
shapes: patterns.#SHACLShapes & {Graph: _g, RuleShapes: cc.rule_shapes}
