// ODRL Policy Projections — W3C ODRL 2.2 access policies per classification.
//
// Three policies for GC data classification levels:
// - Unclassified: commercial LLMs permitted
// - Protected A: GC-controlled infrastructure only
// - Protected B: GC cloud with PII blocking mandatory
//
// Export: cue export ./examples/gc-llm-governance/ -e odrl_policies --out json

package main

import "apercue.ca/vocab@v0"

odrl_policies: {
	"@context": vocab.context["@context"]
	"@type":    "odrl:Set"
	"odrl:uid": "urn:gc:llm-governance:classification-policies"
	"odrl:policy": [
		// Unclassified — commercial LLMs permitted
		{
			"@type":         "odrl:Set"
			"odrl:uid":      "urn:gc:policy:unclassified"
			"dcterms:title": "Unclassified Data — LLM Usage Policy"
			"odrl:permission": [
				{
					"odrl:action": {"@id": "odrl:use"}
					"odrl:target": {"@id": "urn:gc:classification:unclassified"}
					"odrl:assignee": {"@id": "urn:gc:role:any-llm-provider"}
					"odrl:constraint": {
						"odrl:leftOperand": {"@id": "odrl:dateTime"}
						"odrl:operator": {"@id": "odrl:lt"}
						"odrl:rightOperand": "2026-06-24T00:00:00Z"
					}
				},
			]
			"odrl:obligation": [
				{
					"odrl:action": {"@id": "odrl:attribute"}
					"odrl:assignee": {"@id": "urn:gc:role:deploying-department"}
					"odrl:target": {"@id": "urn:gc:requirement:aia-assessment"}
				},
			]
		},
		// Protected A — GC-controlled infrastructure only
		{
			"@type":         "odrl:Set"
			"odrl:uid":      "urn:gc:policy:protected-a"
			"dcterms:title": "Protected A Data — LLM Usage Policy"
			"odrl:permission": [
				{
					"odrl:action": {"@id": "odrl:use"}
					"odrl:target": {"@id": "urn:gc:classification:protected-a"}
					"odrl:assignee": {"@id": "urn:gc:role:gc-controlled-provider"}
					"odrl:constraint": {
						"odrl:leftOperand": {"@id": "odrl:spatial"}
						"odrl:operator": {"@id": "odrl:eq"}
						"odrl:rightOperand": "urn:gc:jurisdiction:canada"
					}
				},
			]
			"odrl:prohibition": [
				{
					"odrl:action": {"@id": "odrl:transfer"}
					"odrl:target": {"@id": "urn:gc:classification:protected-a"}
					"odrl:assignee": {"@id": "urn:gc:role:commercial-provider"}
				},
			]
			"odrl:obligation": [
				{
					"odrl:action": {"@id": "odrl:attribute"}
					"odrl:assignee": {"@id": "urn:gc:role:deploying-department"}
					"odrl:target": {"@id": "urn:gc:requirement:data-classification-review"}
				},
			]
		},
		// Protected B — GC cloud with PII blocking
		{
			"@type":         "odrl:Set"
			"odrl:uid":      "urn:gc:policy:protected-b"
			"dcterms:title": "Protected B Data — LLM Usage Policy"
			"odrl:permission": [
				{
					"odrl:action": {"@id": "odrl:use"}
					"odrl:target": {"@id": "urn:gc:classification:protected-b"}
					"odrl:assignee": {"@id": "urn:gc:role:gc-cloud-provider"}
					"odrl:constraint": [
						{
							"odrl:leftOperand": {"@id": "odrl:spatial"}
							"odrl:operator": {"@id": "odrl:eq"}
							"odrl:rightOperand": "urn:gc:jurisdiction:canada"
						},
						{
							"odrl:leftOperand": {"@id": "apercue:piiBlocking"}
							"odrl:operator": {"@id": "odrl:eq"}
							"odrl:rightOperand": true
						},
					]
				},
			]
			"odrl:prohibition": [
				{
					"odrl:action": {"@id": "odrl:disclose"}
					"odrl:target": {"@id": "urn:gc:classification:protected-b"}
					"odrl:assignee": {"@id": "urn:gc:role:commercial-provider"}
				},
				{
					"odrl:action": {"@id": "odrl:transfer"}
					"odrl:target": {"@id": "urn:gc:classification:protected-b"}
					"odrl:assignee": {"@id": "urn:gc:role:non-gc-infrastructure"}
				},
			]
			"odrl:obligation": [
				{
					"odrl:action": {"@id": "odrl:reviewPolicy"}
					"odrl:assignee": {"@id": "urn:gc:role:privacy-officer"}
					"odrl:target": {"@id": "urn:gc:requirement:privacy-impact-assessment"}
				},
				{
					"odrl:action": {"@id": "odrl:attribute"}
					"odrl:assignee": {"@id": "urn:gc:role:deploying-department"}
					"odrl:target": {"@id": "urn:gc:requirement:pii-blocking-verification"}
				},
			]
		},
	]
}
