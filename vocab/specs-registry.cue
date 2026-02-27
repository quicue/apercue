// W3C Specification Registry — single source of truth for spec coverage.
//
// Every table in README.md, w3c/README.md, and site/index.html is a
// projection of this registry. No hardcoded spec data elsewhere.
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
	prefix?: string // Namespace prefix in @context (e.g. "sh", "skos")

	// What apercue provides for this spec
	patterns: {[string]: true} // CUE pattern names (struct-as-set)
	files: {[string]: true} // Source files
	exports: {[string]: true} // cue export expressions

	// Human-readable summary of what's covered
	coverage: string
}

// Specs — The registry. Keys are W3C spec display names.
Specs: {[string]: #SpecEntry} & {
	// ── Implemented ──────────────────────────────────────────────────

	"JSON-LD 1.1": {
		name:   "JSON-LD 1.1"
		url:    "https://www.w3.org/TR/json-ld11/"
		status: "Implemented"
		prefix: "jsonld"
		patterns: {"context": true}
		files: {"vocab/context.cue": true}
		exports: {"context": true}
		coverage: "@context, @type, @id on all resources"
	}

	"SHACL": {
		name:   "SHACL"
		url:    "https://www.w3.org/TR/shacl/"
		status: "Implemented"
		prefix: "sh"
		patterns: {
			"#ComplianceCheck": true
			"#GapAnalysis":     true
			"#SHACLShapes":     true
		}
		files: {
			"patterns/validation.cue": true
			"patterns/shapes.cue":     true
			"charter/charter.cue":     true
		}
		exports: {
			"compliance.shacl_report":     true
			"gaps.shacl_report":           true
			"shape_export.shapes_graph":   true
		}
		coverage: "sh:ValidationReport from compliance/gap analysis + sh:NodeShape generation from graph types"
	}

	"SKOS": {
		name:   "SKOS"
		url:    "https://www.w3.org/TR/skos-reference/"
		status: "Implemented"
		prefix: "skos"
		patterns: {
			"#LifecyclePhasesSKOS": true
			"#TypeVocabulary":      true
			"#SKOSTaxonomy":        true
		}
		files: {
			"patterns/lifecycle.cue": true
			"patterns/taxonomy.cue":  true
			"views/skos.cue":         true
		}
		exports: {
			"lifecycle_skos":          true
			"type_vocab":              true
			"taxonomy.taxonomy_scheme": true
		}
		coverage: "skos:ConceptScheme from type vocabularies, lifecycle phases, and hierarchical taxonomies with broader/narrower"
	}

	"EARL": {
		name:   "EARL"
		url:    "https://www.w3.org/TR/EARL10-Schema/"
		status: "Implemented"
		prefix: "earl"
		patterns: {"#SmokeTest": true}
		files: {"patterns/lifecycle.cue": true}
		exports: {"smoke.earl_report": true}
		coverage: "earl:Assertion from smoke test plans"
	}

	"OWL-Time": {
		name:   "OWL-Time"
		url:    "https://www.w3.org/TR/owl-time/"
		status: "Implemented"
		prefix: "time"
		patterns: {"#CriticalPath": true}
		files: {"patterns/analysis.cue": true}
		exports: {"cpm.time_report": true}
		coverage: "time:Interval from critical path scheduling"
	}

	"Dublin Core": {
		name:   "Dublin Core"
		url:    "https://www.dublincore.org/specifications/dublin-core/dcmi-terms/"
		status: "Implemented"
		prefix: "dcterms"
		patterns: {"context": true}
		files: {"vocab/context.cue": true}
		exports: {"context": true}
		coverage: "dcterms:title, dcterms:description, dcterms:requires on all resources"
	}

	"PROV-O": {
		name:   "PROV-O"
		url:    "https://www.w3.org/TR/prov-o/"
		status: "Implemented"
		prefix: "prov"
		patterns: {
			"#ProvenanceTrace": true
			"#ProvenancePlan":  true
		}
		files: {
			"patterns/provenance.cue":      true
			"patterns/provenance_plan.cue":  true
		}
		exports: {
			"provenance.prov_report":     true
			"_prov_plan.plan_report":     true
		}
		coverage: "prov:Entity + prov:wasDerivedFrom from dependency edges; prov:Plan from charter gates with prov:Activity per gate"
	}

	"schema.org": {
		name:   "schema.org"
		url:    "https://schema.org/"
		status: "Implemented"
		prefix: "schema"
		patterns: {"#SchemaOrgAlignment": true}
		files: {"patterns/schema_alignment.cue": true}
		exports: {"schema_view.schema_graph": true}
		coverage: "schema:additionalType annotations via configurable type mapping"
	}

	"ODRL 2.2": {
		name:   "ODRL 2.2"
		url:    "https://www.w3.org/TR/odrl-model/"
		status: "Implemented"
		prefix: "odrl"
		patterns: {"#ODRLPolicy": true}
		files: {"patterns/policy.cue": true}
		exports: {"access_policy.odrl_policy": true}
		coverage: "odrl:Set policies with permissions/prohibitions by resource type"
	}

	"Activity Streams 2.0": {
		name:   "Activity Streams 2.0"
		url:    "https://www.w3.org/TR/activitystreams-core/"
		status: "Implemented"
		prefix: "as"
		patterns: {"#ActivityStream": true}
		files: {"patterns/activity.cue": true}
		exports: {"activity_stream.stream": true}
		coverage: "as:OrderedCollection of Create activities from topology layers"
	}

	"Verifiable Credentials 2.0": {
		name:   "Verifiable Credentials 2.0"
		url:    "https://www.w3.org/TR/vc-data-model-2.0/"
		status: "Implemented"
		prefix: "cred"
		patterns: {"#ValidationCredential": true}
		files: {"patterns/credentials.cue": true}
		exports: {"validation_credential.vc": true}
		coverage: "VerifiableCredential wrapping SHACL validation attestation"
	}

	"W3C Org": {
		name:   "W3C Org"
		url:    "https://www.w3.org/TR/vocab-org/"
		status: "Implemented"
		prefix: "org"
		patterns: {"#OrgStructure": true}
		files: {"views/org.cue": true}
		exports: {"structure.org_report": true}
		coverage: "org:Organization with type-based OrganizationalUnits"
	}

	"VoID": {
		name:   "VoID"
		url:    "https://www.w3.org/TR/void/"
		status: "Implemented"
		prefix: "void"
		patterns: {"#VoIDDataset": true}
		files: {"patterns/void.cue": true}
		exports: {"void_dataset.void_description": true}
		coverage: "void:Dataset with class/property partitions, linkset statistics, and vocabulary usage"
	}

	"DQV": {
		name:   "DQV"
		url:    "https://www.w3.org/TR/vocab-dqv/"
		status: "Implemented"
		prefix: "dqv"
		patterns: {"#DataQualityReport": true}
		files: {"patterns/quality.cue": true}
		exports: {"_quality.quality_report": true}
		coverage: "dqv:QualityMeasurement for completeness, consistency, and accessibility dimensions"
	}

	// ── Downstream (implemented in quicue.ca) ────────────────────────

	"Hydra Core": {
		name:   "Hydra Core"
		url:    "https://www.hydra-cg.com/spec/latest/core/"
		status: "Downstream"
		prefix: "hydra"
		patterns: {"#HydraApiDoc": true}
		files: {}
		exports: {}
		coverage: "hydra:ApiDocumentation in quicue.ca operator dashboard"
	}

	"DCAT 3": {
		name:   "DCAT 3"
		url:    "https://www.w3.org/TR/vocab-dcat-3/"
		status: "Implemented"
		prefix: "dcat"
		patterns: {
			"#DCATCatalog":      true
			"#DCATDistribution": true
		}
		files: {"patterns/catalog.cue": true}
		exports: {"catalog.dcat_catalog": true}
		coverage: "dcat:Catalog with dcat:Dataset, dcat:Distribution, dcat:DataService, and dcat:theme from @type"
	}
}
