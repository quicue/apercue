// SKOS Type Vocabulary — governance type taxonomy as SKOS ConceptScheme.
//
// Projects all resource types used in the governance charter as a
// W3C SKOS vocabulary. This makes the type system machine-readable
// and queryable.
//
// Export: cue export ./examples/gc-llm-governance/ -e type_vocab --out json

package main

import (
	"apercue.ca/vocab@v0"
	"apercue.ca/views@v0"
)

// _governance_types — domain type registry for this governance charter
_governance_types: vocab.#TypeRegistry & {
	Framework: {description: "Root governance framework definition"}
	Statute: {description: "Federal legislation creating binding obligations"}
	Directive: {description: "Treasury Board directive or mandatory policy instrument"}
	Guide: {description: "Non-binding guidance document from TBS or CCCS"}
	SecurityGuidance: {description: "CCCS security guidance for generative AI threats"}
	Principle: {description: "Named principle framework (e.g., FASTER)"}
	ImpactLevel: {description: "AIA algorithmic impact assessment level (I-IV)"}
	ControlObjective: {description: "Measurable control derived from an obligation"}
	ComplianceRule: {description: "Enforceable rule that can be tested at compile time"}
	PolicyConstraint: {description: "ODRL policy constraint per data classification level"}
	LLMProvider: {description: "Cloud or self-hosted LLM service provider"}
	LLMDeployment: {description: "Reference LLM deployment with constraint binding"}
	DomainScope: {description: "Knowledge boundary defining permitted/excluded topics"}
	PolicyFact: {description: "Verified fact from an authoritative source"}
	AuthoritativeSource: {description: "Trusted source document with integrity metadata"}
	TermDefinition: {description: "Authoritative definition preventing LLM-invented terms"}
	ClassificationGate: {description: "Runtime data classification checkpoint"}
	BilingualGate: {description: "Runtime EN/FR quality validation checkpoint"}
	HumanReviewGate: {description: "Human review checkpoint for high-impact decisions"}
	AuditSink: {description: "PROV-O audit trail collecting LLM response provenance"}
	SmokeTest: {description: "EARL smoke test validating runtime control"}
	ComplianceReport: {description: "SHACL ValidationReport for auditors"}
	VerifiableCredential: {description: "VC 2.0 credential attesting compliance"}
	CatalogEntry: {description: "DCAT 3 catalog entry for GC AI Register"}
	Schedule: {description: "OWL-Time schedule for compliance deadlines"}
}

type_vocab: views.#TypeVocabulary & {
	Registry: _governance_types
	BaseIRI:  "https://apercue.ca/gc-governance#"
}
