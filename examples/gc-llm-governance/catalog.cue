// DCAT 3 Catalog Entry — machine-readable entry for the GC AI Register.
//
// Each LLM deployment becomes a dcat:Dataset in the catalog.
// This is the format that would be published to the GC AI Register
// to describe automated decision systems.
//
// Export: cue export ./examples/gc-llm-governance/ -e dcat_catalog --out json

package main

import "apercue.ca/vocab@v0"

dcat_catalog: {
	"@context":            vocab.context["@context"]
	"@type":               "dcat:Catalog"
	"@id":                 "urn:gc:ai-register:llm-governance"
	"dcterms:title":       "GC LLM Governance — AI Register Entries"
	"dcterms:description": "Machine-readable catalog of LLM deployments under the Directive on Automated Decision-Making"
	"dcterms:publisher": {
		"@type":         "org:Organization"
		"dcterms:title": "Treasury Board of Canada Secretariat"
	}
	"dcterms:issued": "2026-02-21"
	"dcterms:language": ["en", "fr"]
	"dcat:dataset": [
		{
			"@type":               "dcat:Dataset"
			"@id":                 "urn:gc:deployment:procurement-assistant"
			"dcterms:title":       "Procurement Assistant"
			"dcterms:description": "Bilingual LLM assistant for GC procurement policy and process guidance"
			"dcat:keyword": ["procurement", "standing-offers", "trade-agreements", "bid-evaluation"]
			"dcterms:conformsTo": [
				{"@id": "urn:gc:directive:adm"},
				{"@id": "urn:gc:act:privacy"},
				{"@id": "urn:gc:act:official-languages"},
			]
			"dcat:contactPoint": {
				"@type":        "schema:ContactPoint"
				"schema:email": "ai-governance@tbs-sct.gc.ca"
			}
			"dcterms:publisher": {
				"@type":         "org:Organization"
				"dcterms:title": "Deploying Department"
			}
			"dcterms:spatial": "urn:gc:jurisdiction:canada"
			"dcat:distribution": {
				"@type":          "dcat:Distribution"
				"dcat:mediaType": "application/json"
				"dcterms:title":  "API endpoint"
			}
		},
		{
			"@type":               "dcat:Dataset"
			"@id":                 "urn:gc:deployment:hr-assistant"
			"dcterms:title":       "HR Assistant"
			"dcterms:description": "Bilingual LLM assistant for GC human resources policy and process guidance"
			"dcat:keyword": ["human-resources", "psea", "collective-agreements", "classification", "leave-policies"]
			"dcterms:conformsTo": [
				{"@id": "urn:gc:directive:adm"},
				{"@id": "urn:gc:act:privacy"},
				{"@id": "urn:gc:act:official-languages"},
			]
			"dcat:contactPoint": {
				"@type":        "schema:ContactPoint"
				"schema:email": "ai-governance@tbs-sct.gc.ca"
			}
			"dcterms:publisher": {
				"@type":         "org:Organization"
				"dcterms:title": "Deploying Department"
			}
			"dcterms:spatial": "urn:gc:jurisdiction:canada"
			"dcat:distribution": {
				"@type":          "dcat:Distribution"
				"dcat:mediaType": "application/json"
				"dcterms:title":  "API endpoint"
			}
		},
		{
			"@type":               "dcat:Dataset"
			"@id":                 "urn:gc:deployment:internal-search"
			"dcterms:title":       "Internal Knowledge Search"
			"dcterms:description": "Self-hosted LLM for internal knowledge search, grounded in authoritative source documents"
			"dcat:keyword": ["knowledge-search", "self-hosted", "knowledge-grounded"]
			"dcterms:conformsTo": [
				{"@id": "urn:gc:directive:adm"},
			]
			"dcat:contactPoint": {
				"@type":        "schema:ContactPoint"
				"schema:email": "ai-governance@tbs-sct.gc.ca"
			}
			"dcterms:publisher": {
				"@type":         "org:Organization"
				"dcterms:title": "Deploying Department"
			}
			"dcterms:spatial": "urn:gc:jurisdiction:canada"
			"dcat:distribution": {
				"@type":          "dcat:Distribution"
				"dcat:mediaType": "application/json"
				"dcterms:title":  "API endpoint"
			}
		},
	]
}
