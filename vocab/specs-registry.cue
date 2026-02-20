// W3C Specification Registry — single source of truth for spec coverage.
//
// Every table in README.md, w3c/README.md, site/index.html, and the ReSpec
// spec is a projection of this registry. No hardcoded spec data elsewhere.
//
// Usage:
//   import "apercue.ca/vocab@v0"
//
//   for name, spec in vocab.Specs if spec.status == "Implemented" { ... }

package vocab

// #SpecStatus — Implementation lifecycle.
#SpecStatus: "Implemented" | "Namespace" | "Downstream"

// #SpecEntry — One W3C specification and how apercue covers it.
#SpecEntry: {
	name:    string
	url:     string
	status:  #SpecStatus
	prefix?: string          // Namespace prefix in @context (e.g. "sh", "skos")

	// What apercue provides for this spec
	patterns: {[string]: true} // CUE pattern names (struct-as-set)
	files:    {[string]: true} // Source files
	exports:  {[string]: true} // cue export expressions

	// Human-readable summary of what's covered
	coverage: string
}

// Specs — The registry. Keys are W3C spec display names.
Specs: {[string]: #SpecEntry} & {
	// ── Implemented ──────────────────────────────────────────────────

	"JSON-LD 1.1": {
		name:     "JSON-LD 1.1"
		url:      "https://www.w3.org/TR/json-ld11/"
		status:   "Implemented"
		prefix:   "jsonld"
		patterns: {"context": true}
		files:    {"vocab/context.cue": true}
		exports:  {"context": true}
		coverage: "@context, @type, @id on all resources"
	}

	"SHACL": {
		name:     "SHACL"
		url:      "https://www.w3.org/TR/shacl/"
		status:   "Implemented"
		prefix:   "sh"
		patterns: {
			"#ComplianceCheck":  true
			"#GapAnalysis":      true
		}
		files: {
			"patterns/validation.cue": true
			"charter/charter.cue":     true
		}
		exports: {
			"compliance.shacl_report": true
			"gaps.shacl_report":       true
		}
		coverage: "sh:ValidationReport from compliance checks and gap analysis"
	}

	"SKOS": {
		name:     "SKOS"
		url:      "https://www.w3.org/TR/skos-reference/"
		status:   "Implemented"
		prefix:   "skos"
		patterns: {
			"#LifecyclePhasesSKOS": true
			"#TypeVocabulary":      true
		}
		files: {
			"patterns/lifecycle.cue": true
			"views/skos.cue":         true
		}
		exports: {
			"lifecycle_skos": true
			"type_vocab":     true
		}
		coverage: "skos:ConceptScheme from type vocabularies and lifecycle phases"
	}

	"EARL": {
		name:     "EARL"
		url:      "https://www.w3.org/TR/EARL10-Schema/"
		status:   "Implemented"
		prefix:   "earl"
		patterns: {"#SmokeTest": true}
		files:    {"patterns/lifecycle.cue": true}
		exports:  {"smoke.earl_report": true}
		coverage: "earl:Assertion from smoke test plans"
	}

	"OWL-Time": {
		name:     "OWL-Time"
		url:      "https://www.w3.org/TR/owl-time/"
		status:   "Implemented"
		prefix:   "time"
		patterns: {"#CriticalPath": true}
		files:    {"patterns/analysis.cue": true}
		exports:  {"cpm.time_report": true}
		coverage: "time:Interval from critical path scheduling"
	}

	// ── Namespace (prefix registered, used in @context) ──────────────

	"Dublin Core": {
		name:     "Dublin Core"
		url:      "https://www.dublincore.org/specifications/dublin-core/dcmi-terms/"
		status:   "Namespace"
		prefix:   "dcterms"
		patterns: {}
		files:    {"vocab/context.cue": true}
		exports:  {}
		coverage: "dcterms:requires maps depends_on relationships"
	}

	"PROV-O": {
		name:     "PROV-O"
		url:      "https://www.w3.org/TR/prov-o/"
		status:   "Namespace"
		prefix:   "prov"
		patterns: {}
		files:    {"vocab/context.cue": true}
		exports:  {}
		coverage: "prov:wasDerivedFrom namespace registered"
	}

	"schema.org": {
		name:     "schema.org"
		url:      "https://schema.org/"
		status:   "Namespace"
		prefix:   "schema"
		patterns: {}
		files:    {"vocab/context.cue": true}
		exports:  {}
		coverage: "schema:actionStatus for lifecycle status values"
	}

	// ── Downstream (implemented in quicue.ca) ────────────────────────

	"Hydra Core": {
		name:     "Hydra Core"
		url:      "https://www.hydra-cg.com/spec/latest/core/"
		status:   "Downstream"
		prefix:   "hydra"
		patterns: {"#HydraApiDoc": true}
		files:    {}
		exports:  {}
		coverage: "hydra:ApiDocumentation in quicue.ca operator dashboard"
	}

	"DCAT 3": {
		name:     "DCAT 3"
		url:      "https://www.w3.org/TR/vocab-dcat-3/"
		status:   "Downstream"
		prefix:   "dcat"
		patterns: {"#DCATCatalog": true}
		files:    {}
		exports:  {}
		coverage: "dcat:Catalog in quicue-kg aggregate module"
	}
}
