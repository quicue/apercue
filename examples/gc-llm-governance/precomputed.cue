package main

_precomputed: {
	depth: {
		"gc-llm-governance-framework": 0
		"directive-on-adm": 1
		"privacy-act": 1
		"official-languages-act": 1
		"cccs-itsap-00-041": 1
		"knowledge-graph-schema": 1
		"genai-guide-v2": 2
		"aia-requirement": 2
		"bias-testing-framework": 2
		"pii-prompt-blocking": 2
		"vendor-data-classification": 2
		"bilingual-quality-parity": 2
		"rule-cccs-threat-coverage": 2
		"policy-fact-registry": 2
		"authoritative-source-index": 2
		"term-definitions-registry": 2
		"domain-scope-procurement": 2
		"domain-scope-hr": 2
		"faster-principles": 3
		"aia-level-i": 3
		"rule-bias-demographic": 3
		"rule-pii-blocking": 3
		"rule-classification-enforcement": 3
		"rule-bilingual-output": 3
		"rule-faster-coverage": 4
		"aia-level-ii": 4
		"odrl-unclassified": 4
		"odrl-protected-a": 4
		"odrl-protected-b": 4
		"classification-gate": 4
		"bilingual-gate": 4
		"aia-level-iii": 5
		"peer-review-mechanism": 5
		"provider-self-hosted": 5
		"provider-bedrock": 5
		"provider-gc-cloud": 5
		"smoke-test-pii-blocking": 5
		"smoke-test-bilingual": 5
		"aia-level-iv": 6
		"human-in-loop-gate": 6
		"rule-peer-review-level-ii": 6
		"deployment-internal-search": 6
		"deployment-procurement-assistant": 6
		"deployment-hr-assistant": 6
		"rule-human-review-level-iii": 7
		"smoke-test-scope-enforcement": 7
		"audit-sink-prov-o": 7
		"dcat-ai-register-entry": 7
		"human-review-gate": 8
		"shacl-compliance-report": 8
		"vc-compliance-credential": 9
		"owl-time-compliance-schedule": 9
	}
	ancestors: {
		"gc-llm-governance-framework": {}
		"directive-on-adm": {"gc-llm-governance-framework": true}
		"privacy-act": {"gc-llm-governance-framework": true}
		"official-languages-act": {"gc-llm-governance-framework": true}
		"cccs-itsap-00-041": {"gc-llm-governance-framework": true}
		"knowledge-graph-schema": {"gc-llm-governance-framework": true}
		"genai-guide-v2": {"directive-on-adm": true, "gc-llm-governance-framework": true}
		"aia-requirement": {"directive-on-adm": true, "gc-llm-governance-framework": true}
		"bias-testing-framework": {"directive-on-adm": true, "gc-llm-governance-framework": true}
		"pii-prompt-blocking": {"gc-llm-governance-framework": true, "privacy-act": true}
		"vendor-data-classification": {"gc-llm-governance-framework": true, "privacy-act": true}
		"bilingual-quality-parity": {"gc-llm-governance-framework": true, "official-languages-act": true}
		"rule-cccs-threat-coverage": {"cccs-itsap-00-041": true, "gc-llm-governance-framework": true}
		"policy-fact-registry": {"gc-llm-governance-framework": true, "knowledge-graph-schema": true}
		"authoritative-source-index": {"gc-llm-governance-framework": true, "knowledge-graph-schema": true}
		"term-definitions-registry": {"gc-llm-governance-framework": true, "knowledge-graph-schema": true}
		"domain-scope-procurement": {"gc-llm-governance-framework": true, "knowledge-graph-schema": true}
		"domain-scope-hr": {"gc-llm-governance-framework": true, "knowledge-graph-schema": true}
		"faster-principles": {"directive-on-adm": true, "gc-llm-governance-framework": true, "genai-guide-v2": true}
		"aia-level-i": {"aia-requirement": true, "directive-on-adm": true, "gc-llm-governance-framework": true}
		"rule-bias-demographic": {"bias-testing-framework": true, "directive-on-adm": true, "gc-llm-governance-framework": true}
		"rule-pii-blocking": {"gc-llm-governance-framework": true, "pii-prompt-blocking": true, "privacy-act": true}
		"rule-classification-enforcement": {"gc-llm-governance-framework": true, "privacy-act": true, "vendor-data-classification": true}
		"rule-bilingual-output": {"bilingual-quality-parity": true, "gc-llm-governance-framework": true, "official-languages-act": true}
		"rule-faster-coverage": {"directive-on-adm": true, "faster-principles": true, "gc-llm-governance-framework": true, "genai-guide-v2": true}
		"aia-level-ii": {"aia-level-i": true, "aia-requirement": true, "directive-on-adm": true, "gc-llm-governance-framework": true}
		"odrl-unclassified": {"gc-llm-governance-framework": true, "privacy-act": true, "rule-classification-enforcement": true, "vendor-data-classification": true}
		"odrl-protected-a": {"gc-llm-governance-framework": true, "privacy-act": true, "rule-classification-enforcement": true, "vendor-data-classification": true}
		"odrl-protected-b": {"gc-llm-governance-framework": true, "pii-prompt-blocking": true, "privacy-act": true, "rule-classification-enforcement": true, "rule-pii-blocking": true, "vendor-data-classification": true}
		"classification-gate": {"gc-llm-governance-framework": true, "privacy-act": true, "rule-classification-enforcement": true, "vendor-data-classification": true}
		"bilingual-gate": {"bilingual-quality-parity": true, "gc-llm-governance-framework": true, "official-languages-act": true, "rule-bilingual-output": true}
		"aia-level-iii": {"aia-level-i": true, "aia-level-ii": true, "aia-requirement": true, "directive-on-adm": true, "gc-llm-governance-framework": true}
		"peer-review-mechanism": {"aia-level-i": true, "aia-level-ii": true, "aia-requirement": true, "directive-on-adm": true, "gc-llm-governance-framework": true}
		"provider-self-hosted": {"gc-llm-governance-framework": true, "odrl-unclassified": true, "privacy-act": true, "rule-classification-enforcement": true, "vendor-data-classification": true}
		"provider-bedrock": {"gc-llm-governance-framework": true, "odrl-protected-a": true, "privacy-act": true, "rule-classification-enforcement": true, "vendor-data-classification": true}
		"provider-gc-cloud": {"gc-llm-governance-framework": true, "odrl-protected-b": true, "pii-prompt-blocking": true, "privacy-act": true, "rule-classification-enforcement": true, "rule-pii-blocking": true, "vendor-data-classification": true}
		"smoke-test-pii-blocking": {"classification-gate": true, "gc-llm-governance-framework": true, "privacy-act": true, "rule-classification-enforcement": true, "vendor-data-classification": true}
		"smoke-test-bilingual": {"bilingual-gate": true, "bilingual-quality-parity": true, "gc-llm-governance-framework": true, "official-languages-act": true, "rule-bilingual-output": true}
		"aia-level-iv": {"aia-level-i": true, "aia-level-ii": true, "aia-level-iii": true, "aia-requirement": true, "directive-on-adm": true, "gc-llm-governance-framework": true}
		"human-in-loop-gate": {"aia-level-i": true, "aia-level-ii": true, "aia-level-iii": true, "aia-requirement": true, "directive-on-adm": true, "gc-llm-governance-framework": true}
		"rule-peer-review-level-ii": {"aia-level-i": true, "aia-level-ii": true, "aia-requirement": true, "directive-on-adm": true, "gc-llm-governance-framework": true, "peer-review-mechanism": true}
		"deployment-internal-search": {"gc-llm-governance-framework": true, "knowledge-graph-schema": true, "odrl-unclassified": true, "privacy-act": true, "provider-self-hosted": true, "rule-classification-enforcement": true, "vendor-data-classification": true}
		"deployment-procurement-assistant": {"bilingual-quality-parity": true, "domain-scope-procurement": true, "gc-llm-governance-framework": true, "knowledge-graph-schema": true, "odrl-protected-b": true, "official-languages-act": true, "pii-prompt-blocking": true, "privacy-act": true, "provider-gc-cloud": true, "rule-bilingual-output": true, "rule-classification-enforcement": true, "rule-pii-blocking": true, "vendor-data-classification": true}
		"deployment-hr-assistant": {"bilingual-quality-parity": true, "domain-scope-hr": true, "gc-llm-governance-framework": true, "knowledge-graph-schema": true, "odrl-protected-b": true, "official-languages-act": true, "pii-prompt-blocking": true, "privacy-act": true, "provider-gc-cloud": true, "rule-bilingual-output": true, "rule-classification-enforcement": true, "rule-pii-blocking": true, "vendor-data-classification": true}
		"rule-human-review-level-iii": {"aia-level-i": true, "aia-level-ii": true, "aia-level-iii": true, "aia-requirement": true, "directive-on-adm": true, "gc-llm-governance-framework": true, "human-in-loop-gate": true}
		"smoke-test-scope-enforcement": {"bilingual-quality-parity": true, "deployment-procurement-assistant": true, "domain-scope-procurement": true, "gc-llm-governance-framework": true, "knowledge-graph-schema": true, "odrl-protected-b": true, "official-languages-act": true, "pii-prompt-blocking": true, "privacy-act": true, "provider-gc-cloud": true, "rule-bilingual-output": true, "rule-classification-enforcement": true, "rule-pii-blocking": true, "vendor-data-classification": true}
		"audit-sink-prov-o": {"bilingual-quality-parity": true, "deployment-hr-assistant": true, "deployment-procurement-assistant": true, "domain-scope-hr": true, "domain-scope-procurement": true, "gc-llm-governance-framework": true, "knowledge-graph-schema": true, "odrl-protected-b": true, "official-languages-act": true, "pii-prompt-blocking": true, "privacy-act": true, "provider-gc-cloud": true, "rule-bilingual-output": true, "rule-classification-enforcement": true, "rule-pii-blocking": true, "vendor-data-classification": true}
		"dcat-ai-register-entry": {"bilingual-quality-parity": true, "deployment-hr-assistant": true, "deployment-procurement-assistant": true, "domain-scope-hr": true, "domain-scope-procurement": true, "gc-llm-governance-framework": true, "knowledge-graph-schema": true, "odrl-protected-b": true, "official-languages-act": true, "pii-prompt-blocking": true, "privacy-act": true, "provider-gc-cloud": true, "rule-bilingual-output": true, "rule-classification-enforcement": true, "rule-pii-blocking": true, "vendor-data-classification": true}
		"human-review-gate": {"aia-level-i": true, "aia-level-ii": true, "aia-level-iii": true, "aia-requirement": true, "directive-on-adm": true, "gc-llm-governance-framework": true, "human-in-loop-gate": true, "rule-human-review-level-iii": true}
		"shacl-compliance-report": {"audit-sink-prov-o": true, "bilingual-quality-parity": true, "deployment-hr-assistant": true, "deployment-procurement-assistant": true, "domain-scope-hr": true, "domain-scope-procurement": true, "gc-llm-governance-framework": true, "knowledge-graph-schema": true, "odrl-protected-b": true, "official-languages-act": true, "pii-prompt-blocking": true, "privacy-act": true, "provider-gc-cloud": true, "rule-bilingual-output": true, "rule-classification-enforcement": true, "rule-pii-blocking": true, "vendor-data-classification": true}
		"vc-compliance-credential": {"audit-sink-prov-o": true, "bilingual-quality-parity": true, "deployment-hr-assistant": true, "deployment-procurement-assistant": true, "domain-scope-hr": true, "domain-scope-procurement": true, "gc-llm-governance-framework": true, "knowledge-graph-schema": true, "odrl-protected-b": true, "official-languages-act": true, "pii-prompt-blocking": true, "privacy-act": true, "provider-gc-cloud": true, "rule-bilingual-output": true, "rule-classification-enforcement": true, "rule-pii-blocking": true, "shacl-compliance-report": true, "vendor-data-classification": true}
		"owl-time-compliance-schedule": {"audit-sink-prov-o": true, "bilingual-quality-parity": true, "deployment-hr-assistant": true, "deployment-procurement-assistant": true, "domain-scope-hr": true, "domain-scope-procurement": true, "gc-llm-governance-framework": true, "knowledge-graph-schema": true, "odrl-protected-b": true, "official-languages-act": true, "pii-prompt-blocking": true, "privacy-act": true, "provider-gc-cloud": true, "rule-bilingual-output": true, "rule-classification-enforcement": true, "rule-pii-blocking": true, "shacl-compliance-report": true, "vendor-data-classification": true}
	}
	dependents: {
		"gc-llm-governance-framework": {"aia-level-i": true, "aia-level-ii": true, "aia-level-iii": true, "aia-level-iv": true, "aia-requirement": true, "audit-sink-prov-o": true, "authoritative-source-index": true, "bias-testing-framework": true, "bilingual-gate": true, "bilingual-quality-parity": true, "cccs-itsap-00-041": true, "classification-gate": true, "dcat-ai-register-entry": true, "deployment-hr-assistant": true, "deployment-internal-search": true, "deployment-procurement-assistant": true, "directive-on-adm": true, "domain-scope-hr": true, "domain-scope-procurement": true, "faster-principles": true, "genai-guide-v2": true, "human-in-loop-gate": true, "human-review-gate": true, "knowledge-graph-schema": true, "odrl-protected-a": true, "odrl-protected-b": true, "odrl-unclassified": true, "official-languages-act": true, "owl-time-compliance-schedule": true, "peer-review-mechanism": true, "pii-prompt-blocking": true, "policy-fact-registry": true, "privacy-act": true, "provider-bedrock": true, "provider-gc-cloud": true, "provider-self-hosted": true, "rule-bias-demographic": true, "rule-bilingual-output": true, "rule-cccs-threat-coverage": true, "rule-classification-enforcement": true, "rule-faster-coverage": true, "rule-human-review-level-iii": true, "rule-peer-review-level-ii": true, "rule-pii-blocking": true, "shacl-compliance-report": true, "smoke-test-bilingual": true, "smoke-test-pii-blocking": true, "smoke-test-scope-enforcement": true, "term-definitions-registry": true, "vc-compliance-credential": true, "vendor-data-classification": true}
		"directive-on-adm": {"aia-level-i": true, "aia-level-ii": true, "aia-level-iii": true, "aia-level-iv": true, "aia-requirement": true, "bias-testing-framework": true, "faster-principles": true, "genai-guide-v2": true, "human-in-loop-gate": true, "human-review-gate": true, "peer-review-mechanism": true, "rule-bias-demographic": true, "rule-faster-coverage": true, "rule-human-review-level-iii": true, "rule-peer-review-level-ii": true}
		"privacy-act": {"audit-sink-prov-o": true, "classification-gate": true, "dcat-ai-register-entry": true, "deployment-hr-assistant": true, "deployment-internal-search": true, "deployment-procurement-assistant": true, "odrl-protected-a": true, "odrl-protected-b": true, "odrl-unclassified": true, "owl-time-compliance-schedule": true, "pii-prompt-blocking": true, "provider-bedrock": true, "provider-gc-cloud": true, "provider-self-hosted": true, "rule-classification-enforcement": true, "rule-pii-blocking": true, "shacl-compliance-report": true, "smoke-test-pii-blocking": true, "smoke-test-scope-enforcement": true, "vc-compliance-credential": true, "vendor-data-classification": true}
		"official-languages-act": {"audit-sink-prov-o": true, "bilingual-gate": true, "bilingual-quality-parity": true, "dcat-ai-register-entry": true, "deployment-hr-assistant": true, "deployment-procurement-assistant": true, "owl-time-compliance-schedule": true, "rule-bilingual-output": true, "shacl-compliance-report": true, "smoke-test-bilingual": true, "smoke-test-scope-enforcement": true, "vc-compliance-credential": true}
		"cccs-itsap-00-041": {"rule-cccs-threat-coverage": true}
		"knowledge-graph-schema": {"audit-sink-prov-o": true, "authoritative-source-index": true, "dcat-ai-register-entry": true, "deployment-hr-assistant": true, "deployment-internal-search": true, "deployment-procurement-assistant": true, "domain-scope-hr": true, "domain-scope-procurement": true, "owl-time-compliance-schedule": true, "policy-fact-registry": true, "shacl-compliance-report": true, "smoke-test-scope-enforcement": true, "term-definitions-registry": true, "vc-compliance-credential": true}
		"genai-guide-v2": {"faster-principles": true, "rule-faster-coverage": true}
		"aia-requirement": {"aia-level-i": true, "aia-level-ii": true, "aia-level-iii": true, "aia-level-iv": true, "human-in-loop-gate": true, "human-review-gate": true, "peer-review-mechanism": true, "rule-human-review-level-iii": true, "rule-peer-review-level-ii": true}
		"bias-testing-framework": {"rule-bias-demographic": true}
		"pii-prompt-blocking": {"audit-sink-prov-o": true, "dcat-ai-register-entry": true, "deployment-hr-assistant": true, "deployment-procurement-assistant": true, "odrl-protected-b": true, "owl-time-compliance-schedule": true, "provider-gc-cloud": true, "rule-pii-blocking": true, "shacl-compliance-report": true, "smoke-test-scope-enforcement": true, "vc-compliance-credential": true}
		"vendor-data-classification": {"audit-sink-prov-o": true, "classification-gate": true, "dcat-ai-register-entry": true, "deployment-hr-assistant": true, "deployment-internal-search": true, "deployment-procurement-assistant": true, "odrl-protected-a": true, "odrl-protected-b": true, "odrl-unclassified": true, "owl-time-compliance-schedule": true, "provider-bedrock": true, "provider-gc-cloud": true, "provider-self-hosted": true, "rule-classification-enforcement": true, "shacl-compliance-report": true, "smoke-test-pii-blocking": true, "smoke-test-scope-enforcement": true, "vc-compliance-credential": true}
		"bilingual-quality-parity": {"audit-sink-prov-o": true, "bilingual-gate": true, "dcat-ai-register-entry": true, "deployment-hr-assistant": true, "deployment-procurement-assistant": true, "owl-time-compliance-schedule": true, "rule-bilingual-output": true, "shacl-compliance-report": true, "smoke-test-bilingual": true, "smoke-test-scope-enforcement": true, "vc-compliance-credential": true}
		"rule-cccs-threat-coverage": {}
		"policy-fact-registry": {}
		"authoritative-source-index": {}
		"term-definitions-registry": {}
		"domain-scope-procurement": {"audit-sink-prov-o": true, "dcat-ai-register-entry": true, "deployment-procurement-assistant": true, "owl-time-compliance-schedule": true, "shacl-compliance-report": true, "smoke-test-scope-enforcement": true, "vc-compliance-credential": true}
		"domain-scope-hr": {"audit-sink-prov-o": true, "dcat-ai-register-entry": true, "deployment-hr-assistant": true, "owl-time-compliance-schedule": true, "shacl-compliance-report": true, "vc-compliance-credential": true}
		"faster-principles": {"rule-faster-coverage": true}
		"aia-level-i": {"aia-level-ii": true, "aia-level-iii": true, "aia-level-iv": true, "human-in-loop-gate": true, "human-review-gate": true, "peer-review-mechanism": true, "rule-human-review-level-iii": true, "rule-peer-review-level-ii": true}
		"rule-bias-demographic": {}
		"rule-pii-blocking": {"audit-sink-prov-o": true, "dcat-ai-register-entry": true, "deployment-hr-assistant": true, "deployment-procurement-assistant": true, "odrl-protected-b": true, "owl-time-compliance-schedule": true, "provider-gc-cloud": true, "shacl-compliance-report": true, "smoke-test-scope-enforcement": true, "vc-compliance-credential": true}
		"rule-classification-enforcement": {"audit-sink-prov-o": true, "classification-gate": true, "dcat-ai-register-entry": true, "deployment-hr-assistant": true, "deployment-internal-search": true, "deployment-procurement-assistant": true, "odrl-protected-a": true, "odrl-protected-b": true, "odrl-unclassified": true, "owl-time-compliance-schedule": true, "provider-bedrock": true, "provider-gc-cloud": true, "provider-self-hosted": true, "shacl-compliance-report": true, "smoke-test-pii-blocking": true, "smoke-test-scope-enforcement": true, "vc-compliance-credential": true}
		"rule-bilingual-output": {"audit-sink-prov-o": true, "bilingual-gate": true, "dcat-ai-register-entry": true, "deployment-hr-assistant": true, "deployment-procurement-assistant": true, "owl-time-compliance-schedule": true, "shacl-compliance-report": true, "smoke-test-bilingual": true, "smoke-test-scope-enforcement": true, "vc-compliance-credential": true}
		"rule-faster-coverage": {}
		"aia-level-ii": {"aia-level-iii": true, "aia-level-iv": true, "human-in-loop-gate": true, "human-review-gate": true, "peer-review-mechanism": true, "rule-human-review-level-iii": true, "rule-peer-review-level-ii": true}
		"odrl-unclassified": {"deployment-internal-search": true, "provider-self-hosted": true}
		"odrl-protected-a": {"provider-bedrock": true}
		"odrl-protected-b": {"audit-sink-prov-o": true, "dcat-ai-register-entry": true, "deployment-hr-assistant": true, "deployment-procurement-assistant": true, "owl-time-compliance-schedule": true, "provider-gc-cloud": true, "shacl-compliance-report": true, "smoke-test-scope-enforcement": true, "vc-compliance-credential": true}
		"classification-gate": {"smoke-test-pii-blocking": true}
		"bilingual-gate": {"smoke-test-bilingual": true}
		"aia-level-iii": {"aia-level-iv": true, "human-in-loop-gate": true, "human-review-gate": true, "rule-human-review-level-iii": true}
		"peer-review-mechanism": {"rule-peer-review-level-ii": true}
		"provider-self-hosted": {"deployment-internal-search": true}
		"provider-bedrock": {}
		"provider-gc-cloud": {"audit-sink-prov-o": true, "dcat-ai-register-entry": true, "deployment-hr-assistant": true, "deployment-procurement-assistant": true, "owl-time-compliance-schedule": true, "shacl-compliance-report": true, "smoke-test-scope-enforcement": true, "vc-compliance-credential": true}
		"smoke-test-pii-blocking": {}
		"smoke-test-bilingual": {}
		"aia-level-iv": {}
		"human-in-loop-gate": {"human-review-gate": true, "rule-human-review-level-iii": true}
		"rule-peer-review-level-ii": {}
		"deployment-internal-search": {}
		"deployment-procurement-assistant": {"audit-sink-prov-o": true, "dcat-ai-register-entry": true, "owl-time-compliance-schedule": true, "shacl-compliance-report": true, "smoke-test-scope-enforcement": true, "vc-compliance-credential": true}
		"deployment-hr-assistant": {"audit-sink-prov-o": true, "dcat-ai-register-entry": true, "owl-time-compliance-schedule": true, "shacl-compliance-report": true, "vc-compliance-credential": true}
		"rule-human-review-level-iii": {"human-review-gate": true}
		"smoke-test-scope-enforcement": {}
		"audit-sink-prov-o": {"owl-time-compliance-schedule": true, "shacl-compliance-report": true, "vc-compliance-credential": true}
		"dcat-ai-register-entry": {}
		"human-review-gate": {}
		"shacl-compliance-report": {"owl-time-compliance-schedule": true, "vc-compliance-credential": true}
		"vc-compliance-credential": {}
		"owl-time-compliance-schedule": {}
	}
}

_precomputed_cpm: {
	earliest: {
		"gc-llm-governance-framework": 0
		"directive-on-adm": 1
		"privacy-act": 1
		"official-languages-act": 1
		"cccs-itsap-00-041": 1
		"knowledge-graph-schema": 1
		"genai-guide-v2": 2
		"aia-requirement": 2
		"bias-testing-framework": 2
		"pii-prompt-blocking": 2
		"vendor-data-classification": 2
		"bilingual-quality-parity": 2
		"rule-cccs-threat-coverage": 2
		"policy-fact-registry": 2
		"authoritative-source-index": 2
		"term-definitions-registry": 2
		"domain-scope-procurement": 2
		"domain-scope-hr": 2
		"faster-principles": 3
		"aia-level-i": 3
		"rule-bias-demographic": 3
		"rule-pii-blocking": 3
		"rule-classification-enforcement": 3
		"rule-bilingual-output": 3
		"rule-faster-coverage": 4
		"aia-level-ii": 4
		"odrl-unclassified": 4
		"odrl-protected-a": 4
		"odrl-protected-b": 4
		"classification-gate": 4
		"bilingual-gate": 4
		"aia-level-iii": 5
		"peer-review-mechanism": 5
		"provider-self-hosted": 5
		"provider-bedrock": 5
		"provider-gc-cloud": 5
		"smoke-test-pii-blocking": 5
		"smoke-test-bilingual": 5
		"aia-level-iv": 6
		"human-in-loop-gate": 6
		"rule-peer-review-level-ii": 6
		"deployment-internal-search": 6
		"deployment-procurement-assistant": 6
		"deployment-hr-assistant": 6
		"rule-human-review-level-iii": 7
		"smoke-test-scope-enforcement": 7
		"audit-sink-prov-o": 7
		"dcat-ai-register-entry": 7
		"human-review-gate": 8
		"shacl-compliance-report": 8
		"vc-compliance-credential": 9
		"owl-time-compliance-schedule": 9
	}
	latest: {
		"gc-llm-governance-framework": 0
		"directive-on-adm": 2
		"privacy-act": 1
		"official-languages-act": 3
		"cccs-itsap-00-041": 8
		"knowledge-graph-schema": 4
		"genai-guide-v2": 7
		"aia-requirement": 3
		"bias-testing-framework": 8
		"pii-prompt-blocking": 2
		"vendor-data-classification": 2
		"bilingual-quality-parity": 4
		"rule-cccs-threat-coverage": 9
		"policy-fact-registry": 9
		"authoritative-source-index": 9
		"term-definitions-registry": 9
		"domain-scope-procurement": 5
		"domain-scope-hr": 5
		"faster-principles": 8
		"aia-level-i": 4
		"rule-bias-demographic": 9
		"rule-pii-blocking": 3
		"rule-classification-enforcement": 3
		"rule-bilingual-output": 5
		"rule-faster-coverage": 9
		"aia-level-ii": 5
		"odrl-unclassified": 7
		"odrl-protected-a": 8
		"odrl-protected-b": 4
		"classification-gate": 8
		"bilingual-gate": 8
		"aia-level-iii": 6
		"peer-review-mechanism": 8
		"provider-self-hosted": 8
		"provider-bedrock": 9
		"provider-gc-cloud": 5
		"smoke-test-pii-blocking": 9
		"smoke-test-bilingual": 9
		"aia-level-iv": 9
		"human-in-loop-gate": 7
		"rule-peer-review-level-ii": 9
		"deployment-internal-search": 9
		"deployment-procurement-assistant": 6
		"deployment-hr-assistant": 6
		"rule-human-review-level-iii": 8
		"smoke-test-scope-enforcement": 9
		"audit-sink-prov-o": 7
		"dcat-ai-register-entry": 9
		"human-review-gate": 9
		"shacl-compliance-report": 8
		"vc-compliance-credential": 9
		"owl-time-compliance-schedule": 9
	}
	duration: {
		"gc-llm-governance-framework": 1
		"directive-on-adm": 1
		"privacy-act": 1
		"official-languages-act": 1
		"cccs-itsap-00-041": 1
		"knowledge-graph-schema": 1
		"genai-guide-v2": 1
		"aia-requirement": 1
		"bias-testing-framework": 1
		"pii-prompt-blocking": 1
		"vendor-data-classification": 1
		"bilingual-quality-parity": 1
		"rule-cccs-threat-coverage": 1
		"policy-fact-registry": 1
		"authoritative-source-index": 1
		"term-definitions-registry": 1
		"domain-scope-procurement": 1
		"domain-scope-hr": 1
		"faster-principles": 1
		"aia-level-i": 1
		"rule-bias-demographic": 1
		"rule-pii-blocking": 1
		"rule-classification-enforcement": 1
		"rule-bilingual-output": 1
		"rule-faster-coverage": 1
		"aia-level-ii": 1
		"odrl-unclassified": 1
		"odrl-protected-a": 1
		"odrl-protected-b": 1
		"classification-gate": 1
		"bilingual-gate": 1
		"aia-level-iii": 1
		"peer-review-mechanism": 1
		"provider-self-hosted": 1
		"provider-bedrock": 1
		"provider-gc-cloud": 1
		"smoke-test-pii-blocking": 1
		"smoke-test-bilingual": 1
		"aia-level-iv": 1
		"human-in-loop-gate": 1
		"rule-peer-review-level-ii": 1
		"deployment-internal-search": 1
		"deployment-procurement-assistant": 1
		"deployment-hr-assistant": 1
		"rule-human-review-level-iii": 1
		"smoke-test-scope-enforcement": 1
		"audit-sink-prov-o": 1
		"dcat-ai-register-entry": 1
		"human-review-gate": 1
		"shacl-compliance-report": 1
		"vc-compliance-credential": 1
		"owl-time-compliance-schedule": 1
	}
}
