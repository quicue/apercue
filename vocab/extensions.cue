// Extension Vocabulary — formal OWL/RDFS definitions for apercue: terms.
//
// These are the terms in the https://apercue.ca/vocab# namespace that have
// no W3C equivalent. Each term is defined with rdfs:domain, rdfs:range,
// rdfs:label, and rdfs:comment — sufficient for OWL reasoners and SPARQL
// endpoint self-description.
//
// The vocabulary is organized by the pattern that introduces each term.
// Terms are only defined here if they appear in pattern output (projections).
// Internal CUE fields (prefixed with _) are not vocabulary terms.
//
// Export: cue export ./vocab/ -e extensions_owl --out json
//
// Integration: merge when publishing quicue.ca@v0.2.0 or deploying
// dereferenceable IRIs at https://apercue.ca/vocab#

package vocab

// #ExtensionTerm — Schema for one vocabulary term definition.
#ExtensionTerm: {
	"@id":          string
	"@type":        "owl:DatatypeProperty" | "owl:ObjectProperty" | "owl:Class" | "rdfs:Class"
	"rdfs:label":   string
	"rdfs:comment": string
	"rdfs:domain"?: {"@id": string}
	"rdfs:range"?:  {"@id": string}
	// Which pattern introduces this term
	"rdfs:isDefinedBy": {"@id": string}
}

// Extension term definitions — one per apercue: term in pattern output.
_extension_terms: [...#ExtensionTerm] & [
	// ── Critical Path Method (patterns/analysis.cue) ────────────────

	{
		"@id":          "apercue:slack"
		"@type":        "owl:DatatypeProperty"
		"rdfs:label":   "slack"
		"rdfs:comment": "Float slack (total float) in days for a scheduled resource. Zero slack indicates the resource is on the critical path. Computed by backward pass minus forward pass in CPM."
		"rdfs:domain":  {"@id": "time:Interval"}
		"rdfs:range":   {"@id": "xsd:integer"}
		"rdfs:isDefinedBy": {"@id": "apercue:pattern/CriticalPath"}
	},
	{
		"@id":          "apercue:isCritical"
		"@type":        "owl:DatatypeProperty"
		"rdfs:label":   "is critical"
		"rdfs:comment": "Whether this resource lies on the critical path (slack == 0). Equivalent to the CPM definition: a task is critical iff its total float is zero."
		"rdfs:domain":  {"@id": "time:Interval"}
		"rdfs:range":   {"@id": "xsd:boolean"}
		"rdfs:isDefinedBy": {"@id": "apercue:pattern/CriticalPath"}
	},

	// ── Activity Stream (patterns/activity.cue) ─────────────────────

	{
		"@id":          "apercue:depth"
		"@type":        "owl:DatatypeProperty"
		"rdfs:label":   "topological depth"
		"rdfs:comment": "Layer index from topological sort of the dependency DAG. Roots are depth 0. Used to order resources in Activity Streams output by construction sequence."
		"rdfs:domain":  {"@id": "as:Object"}
		"rdfs:range":   {"@id": "xsd:integer"}
		"rdfs:isDefinedBy": {"@id": "apercue:pattern/ActivityStream"}
	},

	// ── Lifecycle (patterns/lifecycle.cue) ───────────────────────────

	{
		"@id":          "apercue:command"
		"@type":        "owl:DatatypeProperty"
		"rdfs:label":   "test command"
		"rdfs:comment": "Shell command string that executes a smoke test for this resource. Used in EARL test plans to define what earl:TestCriterion evaluates."
		"rdfs:domain":  {"@id": "earl:TestCase"}
		"rdfs:range":   {"@id": "xsd:string"}
		"rdfs:isDefinedBy": {"@id": "apercue:pattern/SmokeTest"}
	},

	// ── Provenance Plan (patterns/provenance_plan.cue) ──────────────

	{
		"@id":          "apercue:phase"
		"@type":        "owl:DatatypeProperty"
		"rdfs:label":   "gate phase"
		"rdfs:comment": "Numeric phase index for a charter gate within a PROV-O plan. Gates are ordered by phase; resources within a phase have no ordering constraint."
		"rdfs:domain":  {"@id": "prov:Activity"}
		"rdfs:range":   {"@id": "xsd:integer"}
		"rdfs:isDefinedBy": {"@id": "apercue:pattern/ProvenancePlan"}
	},

	// ── Lifecycle Phases (patterns/lifecycle.cue) ────────────────────

	{
		"@id":          "apercue:lifecycle/Phases"
		"@type":        "rdfs:Class"
		"rdfs:label":   "Deployment Lifecycle Phase Collection"
		"rdfs:comment": "SKOS OrderedCollection of deployment lifecycle phases (plan, provision, configure, deploy, verify, monitor, decommission). Used as a fixed vocabulary for resource lifecycle status."
		"rdfs:isDefinedBy": {"@id": "apercue:pattern/LifecyclePhasesSKOS"}
	},

	// ── Validation Rules (patterns/validation.cue) ──────────────────

	{
		"@id":          "apercue:rule"
		"@type":        "rdfs:Class"
		"rdfs:label":   "Compliance Rule"
		"rdfs:comment": "Named compliance rule that produces SHACL validation results. Each rule defines a check (e.g., type coverage, orphan detection, dependency integrity) that evaluates against graph resources. sh:sourceShape references instances of this class."
		"rdfs:isDefinedBy": {"@id": "apercue:pattern/ComplianceCheck"}
	},

	// ── Context Events (patterns/context_event.cue) ─────────────────

	{
		"@id":          "apercue:ContextEvent"
		"@type":        "rdfs:Class"
		"rdfs:label":   "Context Event"
		"rdfs:comment": "A timestamped record of a federation boundary crossing. Append-only audit trail entry recording merges, validations, projections, or exports across domain boundaries."
		"rdfs:isDefinedBy": {"@id": "apercue:pattern/ContextEventLog"}
	},
	{
		"@id":          "apercue:ContextEventLog"
		"@type":        "rdfs:Class"
		"rdfs:label":   "Context Event Log"
		"rdfs:comment": "A prov:Collection of ContextEvent activities forming the temporal audit trail of federation operations."
		"rdfs:isDefinedBy": {"@id": "apercue:pattern/ContextEventLog"}
	},
	{
		"@id":          "apercue:outcome"
		"@type":        "owl:DatatypeProperty"
		"rdfs:label":   "event outcome"
		"rdfs:comment": "Result of the federation operation: success, conflict, or partial. No W3C property covers this: earl:outcome has its own enum (passed/failed), prov:value is too generic."
		"rdfs:domain":  {"@id": "apercue:ContextEvent"}
		"rdfs:range":   {"@id": "xsd:string"}
		"rdfs:isDefinedBy": {"@id": "apercue:pattern/ContextEventLog"}
	},

	// ── Form Projection (patterns/form.cue) ─────────────────────────

	{
		"@id":          "apercue:FormDefinition"
		"@type":        "rdfs:Class"
		"rdfs:label":   "Form Definition"
		"rdfs:comment": "A UI form definition generated from CUE type metadata. Contains field definitions with names, types, and constraints derived from #TypeRegistry entries."
		"rdfs:isDefinedBy": {"@id": "apercue:pattern/FormProjection"}
	},
	{
		"@id":          "apercue:fields"
		"@type":        "owl:ObjectProperty"
		"rdfs:label":   "form fields"
		"rdfs:comment": "Ordered list of field definitions for a FormDefinition. Each field has a name, type, required flag, and optional help text."
		"rdfs:domain":  {"@id": "apercue:FormDefinition"}
		"rdfs:isDefinedBy": {"@id": "apercue:pattern/FormProjection"}
	},
]

// OWL ontology projection of the extension vocabulary.
extensions_owl: {
	"@context": context["@context"] & {
		"owl":  "http://www.w3.org/2002/07/owl#"
		"rdfs": "http://www.w3.org/2000/01/rdf-schema#"
		"xsd":  "http://www.w3.org/2001/XMLSchema#"
		"rdf":  "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	}
	"@type": "owl:Ontology"
	"@id":   "https://apercue.ca/vocab"
	"rdfs:label": "apercue Extension Vocabulary"
	"rdfs:comment": "Formal definitions for terms in the apercue: namespace that extend W3C vocabularies. These terms cover critical path scheduling (CPM), graph topology, lifecycle management, compliance validation, and federation event logging — domains where no existing W3C property exists."
	"owl:versionInfo": "0.1.0"
	"owl:imports": [
		{"@id": "http://www.w3.org/2006/time"},
		{"@id": "https://www.w3.org/ns/activitystreams"},
		{"@id": "http://www.w3.org/ns/prov"},
		{"@id": "http://www.w3.org/ns/earl"},
		{"@id": "http://www.w3.org/ns/shacl"},
	]
	"@graph": _extension_terms
}

// Summary for quick reference.
extensions_summary: {
	total_terms:       len(_extension_terms)
	datatype_properties: len([for t in _extension_terms if t["@type"] == "owl:DatatypeProperty" {t}])
	classes:           len([for t in _extension_terms if t["@type"] == "rdfs:Class" {t}])
	patterns_covered: {
		for t in _extension_terms {
			(t["rdfs:isDefinedBy"]["@id"]): true
		}
	}
}
