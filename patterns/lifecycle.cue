// Lifecycle patterns — deployment, drift, verification.
//
// Composable types for the full lifecycle:
//   Bootstrap → Verify → Drift
//
// W3C alignment:
//   SKOS OrderedCollection — ordered lifecycle phases
//   EARL Assertion — test plans as linked data

package patterns

import (
	"list"
	"strings"
	"apercue.ca/vocab"
)

// #LifecyclePhase enumerates the ordered phases of a deployment lifecycle.
#LifecyclePhase: "package" | "bootstrap" | "bind" | "deploy" | "verify" | "drift"

// Ordered list for SKOS export (CUE can't iterate disjunctions).
_lifecyclePhaseList: ["package", "bootstrap", "bind", "deploy", "verify", "drift"]

// #LifecyclePhasesSKOS — W3C SKOS OrderedCollection projection.
// Exports lifecycle phases as machine-readable ordered concepts.
//
// Export: cue export ./patterns/ -e #LifecyclePhasesSKOS --out json
#LifecyclePhasesSKOS: {
	"@context":       vocab.context["@context"]
	"@type":          "skos:OrderedCollection"
	"@id":            "apercue:lifecycle/Phases"
	"skos:prefLabel": "Deployment Lifecycle Phases"
	"skos:memberList": {
		"@list": [
			for i, p in _lifecyclePhaseList {
				"@type":          "skos:Concept"
				"@id":            "apercue:lifecycle/" + p
				"skos:prefLabel": p
				"skos:notation":  "\(i)"
			},
		]
	}
}

// --- Bootstrap ---

// #BootstrapResource adds lifecycle commands and health checks to a resource.
// Open schema — unifies with any resource shape via CUE lattice.
#BootstrapResource: {
	name: string
	...

	lifecycle?: {
		create?:  string
		start?:   string
		stop?:    string
		restart?: string
		destroy?: string
		status?:  string
	}

	health?: {
		command:  string
		timeout?: string | *"30s"
		retries?: int | *3
	}

	depends_on?: {[string]: true}
}

// #BootstrapPlan computes layered creation order from dependency topology.
// Composes with #Graph: the same resources feed both graphs.
#BootstrapPlan: {
	resources: [string]: #BootstrapResource

	// Compute correct topological depth via recursive fixpoint (same as #Graph._depth).
	// Base case: no deps → 0. Recursive: max(dep depths) + 1.
	_depths: {
		for name, res in resources {
			let _deps = *res.depends_on | {}
			(name): [
				if len([for d, _ in _deps if resources[d] != _|_ {d}]) > 0 {
					list.Max([for d, _ in _deps if resources[d] != _|_ {_depths[d]}]) + 1
				},
				0,
			][0]
		}
	}

	// Computed: resources grouped by their dependency depth
	_by_layer: {
		for name, res in resources {
			"\(_depths[name])": (name): res
		}
	}

	// Output: create script with layer gates
	script: string | *strings.Join([
		"#!/usr/bin/env bash",
		"set -euo pipefail",
		"",
		for layer_str, layer_resources in _by_layer {
			let cmds = [for name, res in layer_resources if res.lifecycle != _|_ && res.lifecycle.create != _|_ {
				"echo \"Creating \(name)...\"\n\(res.lifecycle.create)"
			}]
			if len(cmds) > 0 {
				strings.Join(["echo \"=== Layer \(layer_str) ===\""]+cmds+[
					"echo \"Layer \(layer_str) complete.\"",
					"",
				], "\n")
			}
		},
	], "\n")
}

// --- Drift Detection ---

// #DriftEntry captures a single declared-vs-live divergence.
#DriftEntry: {
	resource: string
	field:    string
	declared: _
	observed: _
	severity: *"warning" | "critical" | "info"
	action?:  string // remediation command if available
}

// #DriftReport compares declared state (from CUE) against observed state.
// The report is a projection: CUE declares what SHOULD be, the live state
// is injected as JSON, and the comprehension computes divergences.
#DriftReport: {
	// Declared state — typically from the authoritative #Graph resources
	declared: [string]: {...}

	// Observed state — injected from runtime (cue export -t observed=@file.json)
	observed: [string]: {...}

	// Computed: resources in declared but not observed
	missing: {
		for name, _ in declared if observed[name] == _|_ {
			(name): true
		}
	}

	// Computed: resources in observed but not declared
	extra: {
		for name, _ in observed if declared[name] == _|_ {
			(name): true
		}
	}

	// Drift entries are provided by the consumer — CUE can't generically
	// diff arbitrary structs, so the consumer writes field-specific comparisons.
	drifts: [...#DriftEntry]

	// Summary
	summary: {
		total_declared: len(declared)
		total_observed: len(observed)
		total_missing:  len(missing)
		total_extra:    len(extra)
		total_drifted:  len(drifts)
		in_sync:        total_missing == 0 && total_extra == 0 && total_drifted == 0
	}
}

// --- Smoke Test ---

// #Check is a single verification assertion.
#Check: {
	label:    string
	command:  string
	expected: string
}

// #SmokeTest runs a list of checks and produces a pass/fail report.
#SmokeTest: {
	checks: [...#Check]
	Subject?: string // IRI of the system under test (earl:subject)

	// Output: bash script that runs all checks
	script: string | *strings.Join([
		"#!/usr/bin/env bash",
		"PASS=0; FAIL=0",
		"check() { local label=\"$1\" cmd=\"$2\" exp=\"$3\"; result=$(eval \"$cmd\" 2>&1); if echo \"$result\" | grep -q \"$exp\"; then echo \"  PASS: $label\"; PASS=$((PASS+1)); else echo \"  FAIL: $label\"; FAIL=$((FAIL+1)); fi; }",
		"",
	]+[
		for c in checks {
			"check \"\(c.label)\" \"\(c.command)\" \"\(c.expected)\""
		},
	]+[
		"",
		"echo \"\"",
		"echo \"Results: $PASS passed, $FAIL failed\"",
		"[ $FAIL -eq 0 ]",
	], "\n")

	// ── EARL report projection ────────────────────────────────────
	// W3C EARL (Working Group Note, 2017-02-02): express test plans
	// as earl:Assertion for interoperability with accessibility and
	// conformance testing frameworks.
	//
	// Outcome is earl:untested at CUE eval time (actual results come
	// from running the script). The test PLAN is the linked data.
	//
	// Export: cue export -e verify.earl_report --out json
	earl_report: {
		"@context": vocab.context["@context"]
		"@graph": [
			for c in checks {
				"@type": "earl:Assertion"
				if Subject != _|_ {
					"earl:subject": {"@id": Subject}
				}
				"earl:test": {
					"@type":           "earl:TestCriterion"
					"dcterms:title":   c.label
					"apercue:command": c.command
				}
				"earl:result": {
					"@type": "earl:TestResult"
					"earl:outcome": {"@id": "earl:untested"}
					"earl:expected": c.expected
				}
			},
		]
	}
}
