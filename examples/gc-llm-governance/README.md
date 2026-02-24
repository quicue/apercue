# GC LLM Governance

Government of Canada LLM governance modeled as a 52-resource dependency graph
across 8 phases. Maps the full compliance chain from statutes and directives
through control objectives, compliance rules, provider binding, deployments,
audit evidence, and W3C-standard reporting.

Live dashboard: [apercue.ca/gc-governance.html](https://apercue.ca/gc-governance.html)

## Run

```bash
cue eval ./examples/gc-llm-governance/ -e summary
cue eval ./examples/gc-llm-governance/ -e gaps.complete
cue eval ./examples/gc-llm-governance/ -e cpm.summary
cue export ./examples/gc-llm-governance/ -e cpm.critical_sequence --out json
cue export ./examples/gc-llm-governance/ -e compliance.shacl_report --out json
```

## What it demonstrates

- Large graph (52 resources) with precomputed CPM scheduling
- ODRL classification policies for data sensitivity levels
- PROV-O provenance chains from statute through deployment
- DCAT catalog of compliance artifacts
- Verifiable Credential attestation wrapping SHACL reports
- SKOS concept scheme for governance type taxonomy
- Critical path targeting the June 24, 2026 Directive deadline
