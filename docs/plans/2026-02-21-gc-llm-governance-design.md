# GC LLM Governance Framework Design

**Date:** 2026-02-21
**Status:** Approved
**Scope:** Full lifecycle LLM governance using apercue.ca, quicue.ca, quicue-kg

---

## Executive Brief

### Constraint-First LLM Governance for the Government of Canada

Using apercue.ca, quicue.ca, and quicue-kg to produce enforceable, auditable AI controls.

### The Problem

The federal government faces a compliance deadline: June 24, 2026 for all existing
automated decision systems to comply with the TBS Directive on Automated Decision-Making.
Meanwhile, LLM adoption is accelerating — 400+ AI systems now catalogued in the federal
AI Register — with no standard technical mechanism to:

1. **Ground LLM outputs** in authoritative institutional knowledge (preventing hallucination
   about policy, regulation, and institutional facts)
2. **Enforce scope boundaries** at the constraint level (preventing procurement bots from
   giving legal advice, HR bots from giving financial guidance)
3. **Classify and protect data** at the prompt level (preventing Protected B information
   from leaking to commercial LLM vendors — an unlawful disclosure under the Privacy Act)
4. **Produce W3C-standard audit evidence** that satisfies TBS peer review requirements,
   OPC privacy assessments, and Official Languages Commissioner compliance checks
5. **Track provenance** of every fact an LLM asserts, from source system through knowledge
   graph to generated response

Commercial guardrail solutions (Guardrails AI, NVIDIA NeMo, AWS Bedrock Guardrails) address
runtime filtering but none produce W3C-standard compliance evidence, model GC-specific
obligations, or integrate with institutional knowledge graphs. They are black boxes that
cannot answer: "prove this LLM followed the Directive."

### The Approach

apercue.ca is a constraint-first semantic web framework that models any domain as a typed
dependency graph and projects it into 13 W3C standard vocabularies at compile time. Combined
with quicue.ca (operational infrastructure patterns) and quicue-kg (typed knowledge graph
framework), it forms a complete stack for LLM governance:

| Layer | Stack Component | Federal Mapping |
|-------|----------------|-----------------|
| Governance Constraints | apercue `#Charter`, `#ComplianceCheck`, `#GapAnalysis` | Directive on ADM, AIA levels, Privacy Act s.7-8, OLA |
| Knowledge Grounding | quicue-kg `#Decision`, `#Insight`, `#Pattern` + `#PolicyFact`, `#AuthoritativeSource` | Institutional knowledge the LLM may reference |
| Scope Enforcement | apercue `#ComplianceRule` + quicue.ca `#ODRLPolicy` | What each LLM can/cannot do, by classification and domain |
| Provider Binding | quicue.ca `#BindCluster`, `#ExecutionPlan` | Which LLM API, what parameters, what safety config |
| Runtime Audit | apercue `#ProvenanceTrace` -> PROV-O, `#SmokeTest` -> EARL, `#ComplianceCheck` -> SHACL | Response traceability, constraint violation logging |
| Compliance Reporting | SHACL, VC 2.0, OWL-Time, SKOS, DCAT projections | Standard-format reports for auditors, OPC, TBS |

### What Makes This Different

**1. Constraints are the system, not documentation.**
A `#Charter` declares what "compliant" means. `#GapAnalysis` computes what's missing.
The gap between constraints and data IS the remaining work.

**2. Every output is a W3C standard.**
SHACL for auditors. PROV-O for data officers. ODRL for procurement. EARL for QA.
VC 2.0 for inter-departmental trust. OWL-Time for scheduling. DCAT for the AI Register.

**3. No runtime infrastructure for governance.**
The governance layer runs at compile time via CUE. No SPARQL endpoint, no database,
no server. `cue export` produces complete compliance reports.

**4. Provider-agnostic LLM binding.**
quicue.ca's `#BindCluster` maps deployment types to provider configurations.
Change the provider, keep the constraints.

**5. Built on proven patterns.**
apercue models its own 43-deliverable development. quicue.ca manages production
infrastructure (30 resources, 654 commands). quicue-kg tracks decisions across 4 projects.

### GC Framework Alignment

| GC Requirement | Implementation |
|---------------|---------------|
| Directive on ADM — AIA | `#ComplianceCheck` with AIA impact level rules; SHACL report |
| Directive on ADM — Peer Review | `#SmokeTest` -> EARL; `#ComplianceCheck` -> SHACL |
| Directive on ADM — Bias Testing | `#ComplianceRule` with demographic match_types |
| Directive on ADM — Human-in-loop | ODRL `odrl:prohibit` on autonomous decisions at Level III+ |
| Privacy Act s.7-8 | `#ComplianceRule` blocking PII by classification; ODRL prohibitions |
| Official Languages Act | `#ComplianceRule` for bilingual output; `#SmokeTest` for quality parity |
| CCCS ITSAP.00.041 | `#ComplianceRule` per threat category; `#BlastRadius` for supply chain |
| FASTER Principles | Each principle maps to `#ComplianceRule` set; aggregate SHACL report |
| AI Register | DCAT 3 catalog export — machine-readable registration |
| Data Classification | `#ODRLPolicy` per classification level; provider binding respects classification |

### Target Audiences

| Audience | Deliverable |
|----------|------------|
| TBS/OCIO | SHACL compliance reports; DCAT catalog for AI Register |
| CDOs/CIOs | Charter with gap analysis; OWL-Time critical path to June 2026 |
| Privacy Officers | PROV-O provenance chains; ODRL policies; PIA evidence |
| Security (CSO/CCCS) | Compliance rules for CCCS threats; blast radius analysis |
| Procurement | ODRL policies for vendor requirements; VC 2.0 credentials |
| Official Languages | Bilingual compliance rules; EARL test evidence |
| Auditors (OAG) | All above in W3C-standard, machine-readable formats |

---

## Knowledge Graph Design

Three interlocking knowledge graphs:

### Graph 1: Governance Obligations (`obligations/`)

Models every enforceable requirement as a typed node.

**New quicue-kg types:**

| Type | Extends | Purpose |
|------|---------|---------|
| `#Obligation` | `core.#Decision` | Legal/policy requirement with authority and enforcement |
| `#ControlObjective` | `core.#Pattern` | Technical control satisfying obligations |
| `#ComplianceMapping` | `core.#Insight` | Evidence linking controls to obligations |

### Graph 2: Authoritative Knowledge (`knowledge/`)

Facts an LLM is permitted to reference.

**New quicue-kg types:**

| Type | Extends | Purpose |
|------|---------|---------|
| `#PolicyFact` | `core.#Insight` | Verified fact with mandatory evidence and source |
| `#AuthoritativeSource` | `ext.#SourceFile` | Ground truth document with SHA256 and freshness |
| `#DomainScope` | `core.#Pattern` | Boundary of what an LLM deployment may answer |
| `#TermDefinition` | `core.#Insight` | Authoritative term definition |

### Graph 3: LLM Deployments (`deployments/`)

Each LLM deployment as an infrastructure resource (quicue.ca patterns).

---

## Charter: gc-llm-governance

### Scope

- **Total resources:** 52
- **Root:** `gc-llm-governance-framework`
- **Required types:** Statute, Directive, Guide, ControlObjective, ComplianceRule, PolicyConstraint, LLMDeployment, AuditSink, DomainScope, PolicyFact
- **Min depth:** 4

### Phase 1: Foundation — Obligation Graph (8 resources)

| Resource | @type | depends_on |
|----------|-------|------------|
| `gc-llm-governance-framework` | Framework | (root) |
| `directive-on-adm` | Directive | gc-llm-governance-framework |
| `privacy-act` | Statute | gc-llm-governance-framework |
| `official-languages-act` | Statute | gc-llm-governance-framework |
| `cccs-itsap-00-041` | SecurityGuidance | gc-llm-governance-framework |
| `genai-guide-v2` | Guide | directive-on-adm |
| `faster-principles` | Principle | genai-guide-v2 |
| `aia-requirement` | Directive | directive-on-adm |

**Gate: `obligations-mapped`**

### Phase 2: Impact Levels & Control Objectives (10 resources)

| Resource | @type | depends_on |
|----------|-------|------------|
| `aia-level-i` | ImpactLevel | aia-requirement |
| `aia-level-ii` | ImpactLevel | aia-level-i |
| `aia-level-iii` | ImpactLevel | aia-level-ii |
| `aia-level-iv` | ImpactLevel | aia-level-iii |
| `pii-prompt-blocking` | ControlObjective | privacy-act |
| `vendor-data-classification` | ControlObjective | privacy-act |
| `bilingual-quality-parity` | ControlObjective | official-languages-act |
| `human-in-loop-gate` | ControlObjective | aia-level-iii |
| `peer-review-mechanism` | ControlObjective | aia-level-ii |
| `bias-testing-framework` | ControlObjective | directive-on-adm |

**Gate: `controls-defined`** (depends on obligations-mapped)

### Phase 3: Compliance Rules (8 resources)

| Resource | @type | depends_on |
|----------|-------|------------|
| `rule-pii-blocking` | ComplianceRule | pii-prompt-blocking |
| `rule-classification-enforcement` | ComplianceRule | vendor-data-classification |
| `rule-bilingual-output` | ComplianceRule | bilingual-quality-parity |
| `rule-human-review-level-iii` | ComplianceRule | human-in-loop-gate |
| `rule-peer-review-level-ii` | ComplianceRule | peer-review-mechanism |
| `rule-bias-demographic` | ComplianceRule | bias-testing-framework |
| `rule-cccs-threat-coverage` | ComplianceRule | cccs-itsap-00-041 |
| `rule-faster-coverage` | ComplianceRule | faster-principles |

**Gate: `rules-compilable`** (depends on controls-defined)

### Phase 4: Knowledge Graph — Authoritative Sources (6 resources)

| Resource | @type | depends_on |
|----------|-------|------------|
| `knowledge-graph-schema` | DomainScope | gc-llm-governance-framework |
| `policy-fact-registry` | PolicyFact | knowledge-graph-schema |
| `authoritative-source-index` | AuthoritativeSource | knowledge-graph-schema |
| `term-definitions-registry` | TermDefinition | knowledge-graph-schema |
| `domain-scope-procurement` | DomainScope | knowledge-graph-schema |
| `domain-scope-hr` | DomainScope | knowledge-graph-schema |

**Gate: `knowledge-grounded`** (depends on rules-compilable)

### Phase 5: ODRL Policies & Provider Binding (6 resources)

| Resource | @type | depends_on |
|----------|-------|------------|
| `odrl-unclassified` | PolicyConstraint | rule-classification-enforcement |
| `odrl-protected-a` | PolicyConstraint | rule-classification-enforcement |
| `odrl-protected-b` | PolicyConstraint | rule-classification-enforcement, rule-pii-blocking |
| `provider-azure-openai` | LLMProvider | odrl-protected-b |
| `provider-bedrock` | LLMProvider | odrl-protected-a |
| `provider-self-hosted` | LLMProvider | odrl-unclassified |

**Gate: `policies-bound`** (depends on knowledge-grounded)

### Phase 6: Deployment Models (6 resources)

| Resource | @type | depends_on |
|----------|-------|------------|
| `deployment-procurement-assistant` | LLMDeployment | provider-azure-openai, domain-scope-procurement, rule-bilingual-output |
| `deployment-hr-assistant` | LLMDeployment | provider-azure-openai, domain-scope-hr, rule-bilingual-output |
| `deployment-internal-search` | LLMDeployment | provider-self-hosted, knowledge-graph-schema |
| `classification-gate` | ClassificationGate | rule-classification-enforcement |
| `bilingual-gate` | BilingualGate | rule-bilingual-output |
| `human-review-gate` | HumanReviewGate | rule-human-review-level-iii |

**Gate: `deployments-modeled`** (depends on policies-bound)

### Phase 7: Audit & Provenance (4 resources)

| Resource | @type | depends_on |
|----------|-------|------------|
| `audit-sink-prov-o` | AuditSink | deployment-procurement-assistant, deployment-hr-assistant |
| `smoke-test-bilingual` | SmokeTest | bilingual-gate |
| `smoke-test-pii-blocking` | SmokeTest | classification-gate |
| `smoke-test-scope-enforcement` | SmokeTest | deployment-procurement-assistant |

**Gate: `audit-operational`** (depends on deployments-modeled)

### Phase 8: Compliance Reporting & W3C Projections (4 resources)

| Resource | @type | depends_on |
|----------|-------|------------|
| `shacl-compliance-report` | ComplianceReport | audit-sink-prov-o |
| `vc-compliance-credential` | VerifiableCredential | shacl-compliance-report |
| `dcat-ai-register-entry` | CatalogEntry | deployment-procurement-assistant, deployment-hr-assistant |
| `owl-time-compliance-schedule` | Schedule | shacl-compliance-report |

**Gate: `compliance-demonstrable`** (depends on audit-operational)

### Critical Path (11 nodes)

gc-llm-governance-framework -> directive-on-adm -> aia-requirement -> aia-level-iii
-> human-in-loop-gate -> rule-human-review-level-iii -> human-review-gate
-> deployment-procurement-assistant -> audit-sink-prov-o -> shacl-compliance-report
-> vc-compliance-credential
