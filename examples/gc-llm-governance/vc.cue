// VC 2.0 Compliance Credential — verifiable credential wrapping SHACL report.
//
// Wraps the compliance SHACL ValidationReport in a W3C Verifiable Credential 2.0
// envelope. This is the machine-readable attestation that the governance framework
// passes all structural compliance rules.
//
// Export: cue export ./examples/gc-llm-governance/ -e vc_credential --out json

package main

import "apercue.ca/patterns@v0"

vc_credential: patterns.#ValidationCredential & {
	Report:    compliance.shacl_report
	Issuer:    "urn:gc:agent:governance-framework"
	ValidFrom: "2026-02-21T00:00:00Z"
	Subject:   "urn:gc:llm-governance:charter"
}
