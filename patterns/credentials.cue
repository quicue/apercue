// Verifiable Credentials 2.0 projection — attestation of graph validation.
//
// Wraps a SHACL validation result (from #ComplianceCheck or #GapAnalysis)
// in a W3C Verifiable Credential. "This graph passed validation at time T."
//
// W3C VC 2.0 (Recommendation, 2025-05-15): digital credential expression.
//
// Export: cue export -e validation_credential.vc --out json

package patterns

import "apercue.ca/vocab"

// #ValidationCredential — Wrap a SHACL report in a Verifiable Credential.
//
// Input: a SHACL validation report (sh:conforms, sh:result).
// Output: a VC 2.0 credential attesting to the validation outcome.
//
// Note: This produces the credential DATA MODEL only. Cryptographic
// proof (signatures, zero-knowledge) requires an external VC issuer.
// The CUE projection handles the structural conformance; signing is
// a deployment concern.
#ValidationCredential: {
	// The SHACL report to wrap
	Report: {
		"@type":       "sh:ValidationReport"
		"sh:conforms": bool
		...
	}

	// Credential metadata
	Issuer:    string | *"apercue:graph-engine"
	ValidFrom: string // ISO 8601 datetime
	Subject?:  string // IRI of the graph or system under test

	vc: {
		"@context": [
			"https://www.w3.org/ns/credentials/v2",
			vocab.context["@context"],
		]
		"type": ["VerifiableCredential", "ValidationCredential"]
		"issuer":    Issuer
		"validFrom": ValidFrom

		"credentialSubject": {
			if Subject != _|_ {
				"id": Subject
			}
			"type":        "sh:ValidationReport"
			"sh:conforms": Report["sh:conforms"]

			// Include violation count for quick assessment
			let _results = *Report["sh:result"] | []
			"apercue:violationCount": len(_results)

			// Include the full report
			"apercue:validationReport": Report
		}
	}
}
