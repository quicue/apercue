// A Service with no dependencies, under a critical must_not_be_root rule.
// report-only: cue vet must pass and the report must say it does not conform.
// enforce:     cue vet must fail.
package test

import "apercue.ca/patterns@v0"

_g: patterns.#Graph & {Input: {
	db: {name: "db", "@type": {Database: true}}
	svc: {name: "svc", "@type": {Service: true}}
}}

cc: patterns.#ComplianceCheck & {
	Graph:   _g
	Enforce: true
	Rules: [{
		name:             "service-needs-dependency"
		match_types:      {Service: true}
		must_not_be_root: true
		severity:         "critical"
	}]
}
