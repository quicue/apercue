// Policy Fact Registry — verified facts an LLM is permitted to assert.
//
// These are the ground truth claims for GC governance. Each fact cites
// its authoritative source. This prevents hallucination by constraining
// what the LLM can state as fact.

package main

facts: {
	fact_001: #PolicyFact & {
		id:            "FACT-001"
		claim:         "The Directive on Automated Decision-Making compliance deadline is June 24, 2026"
		source:        "SRC-001"
		citation:      "Directive on ADM, Appendix A, Effective Date"
		confidence:    "verified"
		lang:          "en"
		last_verified: "2026-02-21"
	}
	fact_002: #PolicyFact & {
		id:            "FACT-002"
		claim:         "The AIA has four impact levels: Level I (little/no impact), Level II (moderate), Level III (high), Level IV (very high)"
		source:        "SRC-006"
		citation:      "AIA Tool, Impact Level Definitions"
		confidence:    "verified"
		lang:          "en"
		last_verified: "2026-02-21"
	}
	fact_003: #PolicyFact & {
		id:            "FACT-003"
		claim:         "AIA Level III and IV systems require human-in-the-loop for all decisions"
		source:        "SRC-001"
		citation:      "Directive on ADM, Appendix C, s.6.3.3"
		confidence:    "verified"
		lang:          "en"
		last_verified: "2026-02-21"
	}
	fact_004: #PolicyFact & {
		id:            "FACT-004"
		claim:         "AIA Level II and above systems require peer review by a qualified expert"
		source:        "SRC-001"
		citation:      "Directive on ADM, Appendix C, s.6.3.2"
		confidence:    "verified"
		lang:          "en"
		last_verified: "2026-02-21"
	}
	fact_005: #PolicyFact & {
		id:            "FACT-005"
		claim:         "Sending Protected B personal information to commercial LLM vendors constitutes unlawful disclosure under Privacy Act s.8"
		source:        "SRC-002"
		citation:      "Privacy Act, s.8(1) — disclosure limitation"
		confidence:    "verified"
		lang:          "en"
		last_verified: "2026-02-21"
	}
	fact_006: #PolicyFact & {
		id:            "FACT-006"
		claim:         "All public-facing LLM outputs must be available simultaneously in English and French at equal quality"
		source:        "SRC-003"
		citation:      "Official Languages Act, Part IV — Communications with and services to the public"
		confidence:    "verified"
		lang:          "en"
		last_verified: "2026-02-21"
	}
	fact_007: #PolicyFact & {
		id:            "FACT-007"
		claim:         "Bill C-27 / AIDA (Artificial Intelligence and Data Act) was not enacted and is not law"
		source:        "SRC-005"
		citation:      "GenAI Guide v2, Legislative Context section"
		confidence:    "verified"
		lang:          "en"
		last_verified: "2026-02-21"
	}
	fact_008: #PolicyFact & {
		id:            "FACT-008"
		claim:         "The GC AI Register tracks over 400 automated decision systems across 42 federal institutions"
		source:        "SRC-007"
		citation:      "AI Strategy 2025-2027, Current State section"
		confidence:    "verified"
		lang:          "en"
		last_verified: "2026-02-21"
	}
	fact_009: #PolicyFact & {
		id:            "FACT-009"
		claim:         "CCCS identifies 8 generative AI threat categories: prompt injection, data poisoning, training data extraction, model manipulation, supply chain, denial of service, output manipulation, and privilege escalation"
		source:        "SRC-004"
		citation:      "ITSAP.00.041, Threat Categories section"
		confidence:    "verified"
		lang:          "en"
		last_verified: "2026-02-21"
	}
	fact_010: #PolicyFact & {
		id:            "FACT-010"
		claim:         "FASTER principles: Fair, Accountable, Secure, Transparent, Educated, Relevant"
		source:        "SRC-005"
		citation:      "GenAI Guide v2, FASTER Principles Framework"
		confidence:    "verified"
		lang:          "en"
		last_verified: "2026-02-21"
	}
	fact_011: #PolicyFact & {
		id:            "FACT-011"
		claim:         "GC data classification levels for LLM usage: Unclassified (commercial LLMs permitted), Protected A (GC-controlled infrastructure), Protected B (GC cloud with PII blocking)"
		source:        "SRC-001"
		citation:      "Directive on ADM, Appendix B — Data Classification Requirements"
		confidence:    "derived"
		lang:          "en"
		last_verified: "2026-02-21"
	}
	fact_012: #PolicyFact & {
		id:            "FACT-012"
		claim:         "Departments must publish an algorithmic impact assessment before deploying any automated decision system"
		source:        "SRC-008"
		citation:      "Departmental Responsibilities guide, s.4.1"
		confidence:    "verified"
		lang:          "en"
		last_verified: "2026-02-21"
	}
}
