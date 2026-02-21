// Governance Domain Types — typed knowledge graph extensions for GC LLM governance.
//
// These extend quicue-kg's core types with governance-specific constraints.
// Each type has ID format validation, mandatory fields, and CUE-enforced
// structural rules. Domain-specific to this example, not changes to quicue-kg core.

package main

// #Obligation — a legal or policy mandate that must be addressed.
// Maps to statutes, directives, guidelines that create binding requirements.
#Obligation: {
	"@type": "kg:Obligation"
	id:      =~"^OBL-\\d{3}$"
	title:   string & !=""
	authority: string & !=""   // issuing body (e.g., "Treasury Board of Canada Secretariat")
	instrument: string & !=""  // legal instrument (e.g., "Directive on Automated Decision-Making")
	requirements: [...string] & [_, ...] // at least one requirement
	effective_date?: =~"^\\d{4}-\\d{2}-\\d{2}$"
	compliance_deadline?: =~"^\\d{4}-\\d{2}-\\d{2}$"
	url?: string
	...
}

// #ControlObjective — a measurable control derived from an obligation.
// Links obligation to implementable technical/process controls.
#ControlObjective: {
	"@type": "kg:ControlObjective"
	id:      =~"^CTL-\\d{3}$"
	title:   string & !=""
	obligation_ref: =~"^OBL-\\d{3}$"  // traces to source obligation
	aia_level?: "I" | "II" | "III" | "IV"  // AIA impact level if applicable
	control_type: "technical" | "process" | "organizational"
	verification: string & !=""  // how to verify this control is in place
	...
}

// #PolicyFact — a verified fact an LLM is permitted to assert.
// Ground truth that prevents hallucination. Every fact cites its source.
#PolicyFact: {
	"@type": "kg:PolicyFact"
	id:      =~"^FACT-\\d{3}$"
	claim:   string & !=""       // the factual assertion
	source:  =~"^SRC-\\d{3}$"   // authoritative source reference
	citation: string & !=""      // specific section/paragraph
	confidence: "verified" | "derived" | "interpreted"
	lang: "en" | "fr" | "bil"   // language of the claim
	last_verified?: =~"^\\d{4}-\\d{2}-\\d{2}$"
	...
}

// #AuthoritativeSource — a document the governance framework trusts.
// Every policy fact must trace to one of these.
#AuthoritativeSource: {
	"@type": "kg:AuthoritativeSource"
	id:      =~"^SRC-\\d{3}$"
	title:   string & !=""
	url:     =~"^https?://"
	format:  "html" | "pdf" | "json" | "xml"
	lang:    "en" | "fr" | "bil"
	publisher: string & !=""
	date_published?: =~"^\\d{4}-\\d{2}-\\d{2}$"
	date_accessed?:  =~"^\\d{4}-\\d{2}-\\d{2}$"
	...
}

// #DomainScope — what a reference LLM deployment is allowed to answer.
// Permitted topics and excluded topics define the knowledge boundary.
#DomainScope: {
	"@type": "kg:DomainScope"
	id:      =~"^SCOPE-\\d{3}$"
	domain:  string & !=""    // e.g., "Procurement", "Human Resources"
	permitted_topics: [...string] & [_, ...]  // at least one permitted topic
	excluded_topics:  [...string] & [_, ...]  // at least one exclusion
	rationale: string & !=""  // why these boundaries
	...
}

// #TermDefinition — an authoritative definition the LLM must use.
// Prevents LLM-invented definitions for terms with precise legal meaning.
#TermDefinition: {
	"@type": "kg:TermDefinition"
	term:       string & !=""
	definition: string & !=""
	source:     =~"^SRC-\\d{3}$"  // authoritative source reference
	lang:       "en" | "fr"
	context?:   string  // usage context or scope note
	...
}
