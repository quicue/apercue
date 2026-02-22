// LLM Governance Framework — compile-time compliance graphs for AI systems.
//
// A domain-specific specification built on top of the apercue core data model.
// Defines the resource types, phase architecture, W3C projection mappings,
// and conformance profiles for organizations deploying LLMs under regulatory
// frameworks including the EU AI Act, ISO/IEC 42001, and NIST AI RMF.
//
// Export:
//   cue export ./spec/llm-governance/ -e spec_html --out text > site/spec/llm-governance/index.html

package main

import "strings"

// ═══════════════════════════════════════════════════════════════════════════
// SPEC METADATA
// ═══════════════════════════════════════════════════════════════════════════

_meta: {
	title:      "LLM Governance Framework: Compile-Time Compliance Graphs for AI Systems"
	shortName:  "llm-governance"
	edDraftURI: "https://apercue.ca/spec/llm-governance/"
	latestURI:  "https://apercue.ca/spec/llm-governance/"
	github:     "https://github.com/quicue/apercue"
	editors: [{
		name: "quicue"
		url:  "https://quicue.ca"
	}]
}

// ═══════════════════════════════════════════════════════════════════════════
// STRUCTURED DATA
// ═══════════════════════════════════════════════════════════════════════════

// Domain types — each drives a row in the Domain Model table
_types: [
	{
		name:        "Obligation"
		id_format:   "OBL-NNN"
		description: "A legal or policy mandate that creates binding requirements. Maps to statutes, directives, regulations, and binding guidelines."
		constraints: "Authority (issuing body), instrument (legal basis), requirements list, optional compliance deadline."
		w3c:         "Source nodes in SHACL validation graphs. Authority maps to <code>prov:wasAttributedTo</code>."
		example:     "EU AI Act Art. 9 risk management obligation, Canadian Privacy Act s.7 use limitation."
	},
	{
		name:        "ControlObjective"
		id_format:   "CTL-NNN"
		description: "A measurable control derived from one or more obligations. Links regulatory requirements to implementable technical or process controls."
		constraints: "Obligation reference, control type (technical/process/organizational), verification method."
		w3c:         "Focus nodes in SHACL <code>sh:ValidationResult</code>. Control type maps to SKOS concept classification."
		example:     "PII blocking in LLM output (technical), human-in-the-loop review (process), bias testing cadence (organizational)."
	},
	{
		name:        "ComplianceRule"
		id_format:   "RULE-NNN"
		description: "An enforceable implementation of a control objective. Compile-time rules are CUE constraints; runtime rules are policy assertions."
		constraints: "Control reference, rule type (compile-time/runtime), enforcement mechanism."
		w3c:         "Maps to <code>sh:sourceConstraintComponent</code> in SHACL validation results."
		example:     "CUE constraint requiring bilingual output quality score ≥ 0.85, policy requiring human review for AIA Level III+."
	},
	{
		name:        "ClassificationPolicy"
		id_format:   "POL-NNN"
		description: "An ODRL 2.2 data handling policy governing information classification levels. Defines permissions, prohibitions, and obligations for data flowing through LLM systems."
		constraints: "Classification level, permitted actions, prohibited actions, duty conditions."
		w3c:         "Directly maps to <code>odrl:Policy</code> with <code>odrl:permission</code>, <code>odrl:prohibition</code>, <code>odrl:obligation</code>."
		example:     "Protected B policy prohibiting storage outside sovereign jurisdiction, Unclassified policy permitting cloud inference."
	},
	{
		name:        "DeploymentModel"
		id_format:   "DEP-NNN"
		description: "A deployment configuration for an LLM system with bound policies. Declares the provider, infrastructure, classification ceiling, and gate requirements."
		constraints: "Provider, deployment type (cloud/on-premise/hybrid), classification ceiling, required gates."
		w3c:         "Maps to <code>dcat:Distribution</code> in DCAT 3 catalog entries. Access constraints map to <code>odrl:hasPolicy</code>."
		example:     "Cloud API deployment restricted to Protected A with bilingual gate, on-premise open-weight deployment with no classification ceiling."
	},
	{
		name:        "PolicyFact"
		id_format:   "FACT-NNN"
		description: "A verified factual assertion an LLM is permitted to make. Grounds LLM output in authoritative sources to prevent hallucination."
		constraints: "Claim text, authoritative source reference, citation, confidence level (verified/derived/interpreted), language."
		w3c:         "Maps to <code>prov:Entity</code> with <code>prov:wasDerivedFrom</code> tracing to authoritative sources."
		example:     "\"The Privacy Act s.7 limits use of personal information to the purpose for which it was collected\" — verified, citing SRC-001 §7."
	},
	{
		name:        "AuthoritativeSource"
		id_format:   "SRC-NNN"
		description: "A document the governance framework trusts as ground truth. Every policy fact must trace to an authoritative source."
		constraints: "Title, URL, format, language, publisher, publication date."
		w3c:         "Maps to <code>prov:Entity</code> with role <code>prov:PrimarySource</code>. Catalog entries as <code>dcat:Dataset</code>."
		example:     "Treasury Board Directive on Automated Decision-Making (2024), EU AI Act Official Journal publication."
	},
	{
		name:        "DomainScope"
		id_format:   "SCOPE-NNN"
		description: "A knowledge boundary defining what an LLM deployment is permitted to answer. Declares permitted and excluded topics with rationale."
		constraints: "Domain name, permitted topics list, excluded topics list, rationale."
		w3c:         "Maps to SKOS <code>skos:Concept</code> with <code>skos:scopeNote</code> for boundary documentation."
		example:     "Procurement domain: permitted topics include vendor evaluation criteria; excluded topics include classified contract values."
	},
	{
		name:        "AuditRecord"
		id_format:   "AUDIT-NNN"
		description: "A provenance record linking compliance activities to agents, time periods, and evidence. Enables accountability chains from obligation to attestation."
		constraints: "Activity type, agent reference, time period, evidence artifacts."
		w3c:         "Maps to <code>prov:Activity</code> with <code>prov:wasAssociatedWith</code> (agent) and <code>prov:used</code>/<code>prov:generated</code> (artifacts)."
		example:     "Monthly bias audit by AI Ethics Board, quarterly AIA reassessment triggered by model update."
	},
	{
		name:        "TermDefinition"
		id_format:   "TERM-NNN"
		description: "An authoritative definition the LLM must use verbatim. Prevents LLM-invented definitions for terms with precise legal or technical meaning."
		constraints: "Term, definition text, authoritative source reference, language."
		w3c:         "Maps to SKOS <code>skos:Concept</code> with <code>skos:definition</code> and <code>skos:notation</code>."
		example:     "\"Personal information\" as defined in Privacy Act s.3, \"high-risk AI system\" as defined in EU AI Act Art. 6."
	},
]

// Phase architecture — drives the Phase Architecture section
_phases: [
	{
		num:         1
		name:        "Obligation Graph"
		description: "Map the regulatory landscape. Identify all binding obligations (statutes, directives, standards) and their dependency relationships. Root nodes are primary legislation; dependent nodes are derived instruments."
		deliverables: "Obligation inventory, dependency DAG, authority mapping"
		w3c_output:  "JSON-LD graph with <code>dcterms:requires</code> edges"
		nist:        "GOVERN (GV-1 Policies, GV-2 Roles)"
		iso:         "§5 Leadership, §6 Planning"
		eu:          "Art. 9 Risk management system"
		uk:          "Principle 1: Safety, security, robustness"
		can:         "AIDA §5 Definitions, §7 Regulated activities"
	},
	{
		num:         2
		name:        "Impact Assessment"
		description: "Classify AI systems by risk level and determine impact tiers. EU AI Act uses four risk categories (unacceptable, high, limited, minimal). Canada's AIA uses four impact levels (I–IV). Map each deployment to its applicable tier."
		deliverables: "Risk classification matrix, AIA level assignments, high-risk system inventory"
		w3c_output:  "SHACL <code>sh:ValidationReport</code> for classification completeness"
		nist:        "MAP (MP-2 Categorize, MP-3 Benefits/Costs)"
		iso:         "§6.1 Risk assessment"
		eu:          "Art. 6 Classification rules, Annex III High-risk list"
		uk:          "Principle 3: Transparency, explainability"
		can:         "AIDA §7(1) Impact assessment requirement"
	},
	{
		num:         3
		name:        "Control Objectives"
		description: "Derive measurable controls from obligations and impact assessments. Each control objective traces to one or more obligations and specifies a verification method. Controls are typed as technical, process, or organizational."
		deliverables: "Control catalog, obligation-to-control traceability matrix, verification criteria"
		w3c_output:  "SHACL <code>sh:ValidationReport</code> for control coverage"
		nist:        "MEASURE (MS-1 Metrics, MS-2 Evaluation)"
		iso:         "§8.2 AI risk assessment"
		eu:          "Art. 9(2) Identify and analyse known/foreseeable risks"
		uk:          "Principle 2: Appropriate transparency"
		can:         "AIDA §8 Mitigation measures"
	},
	{
		num:         4
		name:        "Knowledge Grounding"
		description: "Establish the factual basis for LLM responses. Identify authoritative sources, extract verified facts, define term definitions, and set domain scope boundaries. Every fact cites its source; every term has a canonical definition."
		deliverables: "Authoritative source registry, fact inventory, term glossary, domain scopes"
		w3c_output:  "PROV-O provenance chains (<code>prov:wasDerivedFrom</code>)"
		nist:        "MAP (MP-4 Risks/Impacts)"
		iso:         "§7.5 Documented information"
		eu:          "Art. 11 Technical documentation"
		uk:          "Principle 4: Fairness"
		can:         "AIDA §11 Records and disclosure"
	},
	{
		num:         5
		name:        "Policy Engine"
		description: "Define data classification policies as machine-readable ODRL 2.2 policies. Each policy specifies permissions, prohibitions, and duties for a classification level. Policies bind to deployment models via gate requirements."
		deliverables: "Classification policies (per level), gate definitions, policy-to-deployment bindings"
		w3c_output:  "ODRL 2.2 <code>odrl:Policy</code> with permissions/prohibitions"
		nist:        "MANAGE (MG-2 Risk Response, MG-3 Risk Escalation)"
		iso:         "§8.4 AI system operation"
		eu:          "Art. 14 Human oversight, Art. 15 Accuracy/robustness"
		uk:          "Principle 5: Contestability, redress"
		can:         "AIDA §9 Measures — transparency obligations"
	},
	{
		num:         6
		name:        "Deployment Constraints"
		description: "Model how LLMs are deployed with bound policies and gate requirements. Each deployment declares its provider, infrastructure type, classification ceiling, and which compliance gates must be satisfied before activation."
		deliverables: "Deployment inventory, gate bindings, provider classification matrix"
		w3c_output:  "DCAT 3 <code>dcat:Distribution</code> catalog entries"
		nist:        "MANAGE (MG-1 Risk Monitoring)"
		iso:         "§8.3 AI system development"
		eu:          "Art. 16 Provider obligations, Art. 26 Deployer obligations"
		uk:          "Principle 1: Safety (deployment context)"
		can:         "AIDA §6 Duties of persons responsible"
	},
	{
		num:         7
		name:        "Audit & Provenance"
		description: "Establish accountability chains from obligation through control to evidence. Define audit activities, assign responsible agents, link to evidence artifacts. Provenance chains enable traceability from any compliance claim back to its regulatory source."
		deliverables: "Audit plan, agent registry, provenance chain templates, evidence catalog"
		w3c_output:  "PROV-O <code>prov:Activity</code> chains + EARL <code>earl:Assertion</code> test reports"
		nist:        "MEASURE (MS-3 Risk Communication)"
		iso:         "§9 Performance evaluation, §9.2 Internal audit"
		eu:          "Art. 12 Record-keeping, Art. 13 Transparency"
		uk:          "Principle 3: Transparency (audit trail)"
		can:         "AIDA §11 Records — audit log requirements"
	},
	{
		num:         8
		name:        "Compliance Reporting"
		description: "Produce verifiable compliance attestations as W3C Verifiable Credentials wrapping SHACL validation reports. Generate catalog entries for registration with regulatory bodies. Publish governance vocabulary as SKOS concept schemes."
		deliverables: "Verifiable Credentials, SHACL summary reports, DCAT catalog, SKOS governance vocabulary"
		w3c_output:  "VC 2.0 credentials, SKOS <code>skos:ConceptScheme</code>"
		nist:        "GOVERN (GV-6 Feedback)"
		iso:         "§10 Improvement, §10.2 Corrective action"
		eu:          "Art. 49 Registration, Art. 62 Reporting"
		uk:          "Principle 5: Redress (reporting mechanisms)"
		can:         "AIDA §12 Publication — public reporting"
	},
]

// W3C projection mappings — how each standard maps to governance
_projections: [
	{
		standard:      "SHACL"
		spec_ref:      "[[shacl]]"
		governance_use: "Compliance validation. Every control objective becomes a SHACL shape; every violation produces a <code>sh:ValidationResult</code> with severity, focus node, and remediation guidance."
		output:        "<code>sh:ValidationReport</code>"
		phases:        "2, 3, 8"
	},
	{
		standard:      "ODRL 2.2"
		spec_ref:      "[[odrl-vocab]]"
		governance_use: "Data classification enforcement. Each classification level (Unclassified, Protected A/B, Confidential, etc.) becomes an ODRL policy with permissions, prohibitions, and duty conditions."
		output:        "<code>odrl:Policy</code>"
		phases:        "5"
	},
	{
		standard:      "PROV-O"
		spec_ref:      "[[prov-o]]"
		governance_use: "Audit provenance. Links compliance activities to responsible agents, evidence artifacts, and authoritative sources. Enables end-to-end traceability from obligation to attestation."
		output:        "<code>prov:Activity</code>, <code>prov:Entity</code>, <code>prov:Agent</code>"
		phases:        "4, 7"
	},
	{
		standard:      "DCAT 3"
		spec_ref:      "[[vocab-dcat-3]]"
		governance_use: "Deployment registry. Each LLM deployment becomes a DCAT dataset with distribution metadata, access constraints, and policy references."
		output:        "<code>dcat:Dataset</code>, <code>dcat:Distribution</code>"
		phases:        "6"
	},
	{
		standard:      "VC 2.0"
		spec_ref:      "[[vc-data-model-2.0]]"
		governance_use: "Compliance attestation. Wraps SHACL validation reports in Verifiable Credentials for tamper-evident, machine-verifiable compliance claims."
		output:        "<code>VerifiableCredential</code>"
		phases:        "8"
	},
	{
		standard:      "SKOS"
		spec_ref:      "[[skos-reference]]"
		governance_use: "Governance vocabulary. Domain types, control categories, and classification levels project as SKOS concept schemes with hierarchical and associative relations."
		output:        "<code>skos:ConceptScheme</code>, <code>skos:Concept</code>"
		phases:        "8"
	},
	{
		standard:      "OWL-Time"
		spec_ref:      "[[owl-time]]"
		governance_use: "Compliance scheduling. Critical path analysis produces time intervals for each phase gate, enabling project managers to identify schedule risks and resource bottlenecks."
		output:        "<code>time:Interval</code>, <code>time:Duration</code>"
		phases:        "All"
	},
	{
		standard:      "JSON-LD"
		spec_ref:      "[[json-ld11]]"
		governance_use: "Linked data federation. The shared <code>@context</code> enables governance graphs from different organizations to merge cleanly — same vocabulary, same semantics, different data."
		output:        "<code>@context</code>, <code>@id</code>, <code>@type</code>"
		phases:        "All"
	},
]

// Competitive landscape — approaches to LLM governance
_approaches: [
	{
		category:    "Runtime Guardrails"
		examples:    "Guardrails AI, NVIDIA NeMo Guardrails, OneShield"
		approach:    "Neural-symbolic systems that filter prompts and responses in real time. Define \"RAIL\" specifications, initialize guards, wrap LLM calls."
		strengths:   "Real-time enforcement, prompt injection defense, response filtering, model-agnostic."
		limitations: "Reactive (post-deployment), no compile-time guarantees, rules defined per-call rather than per-graph, limited regulatory traceability."
		complement:  "Compile-time governance defines the policy graph; runtime guardrails enforce it at inference time. Guardrails AI's RAIL specs can be generated from ODRL policies."
	},
	{
		category:    "AI Governance Platforms"
		examples:    "Credo AI, FairNow, Arthur AI, Harmonic Security"
		approach:    "Dashboard-driven governance with risk assessment workflows, bias monitoring, compliance reporting, and EU AI Act / NIST alignment tools."
		strengths:   "Executive visibility, automated risk scoring, regulatory reporting templates, continuous monitoring."
		limitations: "Governance logic lives in the platform, not in the code. Compliance state is a dashboard metric rather than a structural invariant. Difficult to version-control or diff."
		complement:  "Graph-based governance provides the structural model that platforms can visualize. SHACL reports export to any dashboard that consumes W3C data."
	},
	{
		category:    "LLMOps Observability"
		examples:    "LangSmith, MLflow, Arize AI, Weights & Biases, Helicone"
		approach:    "Trace-level logging of prompts, completions, tool calls, and evaluation metrics. Focus on debugging, cost tracking, and performance optimization."
		strengths:   "Deep operational visibility, experiment tracking, evaluation frameworks, cost management, production debugging."
		limitations: "Observability answers \"what happened\" — not \"what should have happened.\" No policy model, no regulatory mapping, no compile-time validation."
		complement:  "Observability platforms provide the runtime evidence that PROV-O audit chains reference. Trace IDs become <code>prov:Entity</code> artifacts in the governance graph."
	},
	{
		category:    "Standards Frameworks"
		examples:    "NIST AI RMF, ISO/IEC 42001, EU AI Act, Canadian AIDA"
		approach:    "Regulatory and voluntary frameworks that define governance functions (Govern, Map, Measure, Manage), management system requirements, and risk classification tiers."
		strengths:   "Authoritative, comprehensive, internationally recognized. Provide the \"what\" of AI governance."
		limitations: "Frameworks define requirements, not implementations. Organizations must bridge the gap between framework clauses and operational controls. No standard machine-readable format."
		complement:  "The LLM Governance Framework implements these standards as a dependency graph. Each phase maps to specific framework clauses. The regulatory crosswalk (§7) provides the mapping."
	},
	{
		category:    "Compile-Time Governance (this specification)"
		examples:    "apercue LLM Governance Framework"
		approach:    "Declarative dependency graph where obligations flow through controls to rules to policies to deployments to audit. CUE constraints enforce structural invariants at evaluation time. W3C projections produce machine-readable compliance artifacts."
		strengths:   "Version-controlled, diffable, compile-time validated. One graph yields 8 W3C standard outputs. Regulatory crosswalk is structural, not narrative. Impossible to deploy without satisfying the graph."
		limitations: "Requires CUE expertise. Compile-time model cannot enforce runtime behavior (prompt injection, response quality). Graph complexity grows with regulatory scope."
		complement:  "Compile-time governance is the policy layer; runtime tools (guardrails, observability) are the enforcement and monitoring layers. Together they provide end-to-end coverage."
	},
]

// ═══════════════════════════════════════════════════════════════════════════
// HTML HELPERS — comprehension-driven table generation
// ═══════════════════════════════════════════════════════════════════════════

_typeRows: strings.Join([for t in _types {
	"        <tr>\n" +
	"          <td><strong>" + t.name + "</strong></td>\n" +
	"          <td><code>" + t.id_format + "</code></td>\n" +
	"          <td>" + t.description + "</td>\n" +
	"          <td>" + t.w3c + "</td>\n" +
	"        </tr>"
}], "\n")

_typeDetailSections: strings.Join([for t in _types {
	"      <section id=\"type-" + strings.ToLower(strings.Replace(t.name, " ", "-", -1)) + "\">\n" +
	"        <h3>" + t.name + " <code>" + t.id_format + "</code></h3>\n" +
	"        <p>" + t.description + "</p>\n" +
	"        <p><strong>Constraints:</strong> " + t.constraints + "</p>\n" +
	"        <p><strong>W3C mapping:</strong> " + t.w3c + "</p>\n" +
	"        <p><em>Example:</em> " + t.example + "</p>\n" +
	"      </section>"
}], "\n\n")

_phaseRows: strings.Join([for p in _phases {
	"        <tr>\n" +
	"          <td><strong>" + p.name + "</strong></td>\n" +
	"          <td>" + p.description + "</td>\n" +
	"          <td>" + p.deliverables + "</td>\n" +
	"          <td>" + p.w3c_output + "</td>\n" +
	"        </tr>"
}], "\n")

_crosswalkRows: strings.Join([for p in _phases {
	"        <tr>\n" +
	"          <td><strong>Phase " + strings.Join(["\(p.num)"], "") + ": " + p.name + "</strong></td>\n" +
	"          <td>" + p.eu + "</td>\n" +
	"          <td>" + p.iso + "</td>\n" +
	"          <td>" + p.uk + "</td>\n" +
	"          <td>" + p.can + "</td>\n" +
	"          <td>" + p.nist + "</td>\n" +
	"        </tr>"
}], "\n")

_projectionRows: strings.Join([for pr in _projections {
	"        <tr>\n" +
	"          <td><strong>" + pr.standard + "</strong> " + pr.spec_ref + "</td>\n" +
	"          <td>" + pr.governance_use + "</td>\n" +
	"          <td>" + pr.output + "</td>\n" +
	"          <td>" + pr.phases + "</td>\n" +
	"        </tr>"
}], "\n")

_approachSections: strings.Join([for a in _approaches {
	"      <section id=\"approach-" + strings.ToLower(strings.Replace(a.category, " ", "-", -1)) + "\">\n" +
	"        <h3>" + a.category + "</h3>\n" +
	"        <p><strong>Examples:</strong> " + a.examples + "</p>\n" +
	"        <p><strong>Approach:</strong> " + a.approach + "</p>\n" +
	"        <p><strong>Strengths:</strong> " + a.strengths + "</p>\n" +
	"        <p><strong>Limitations:</strong> " + a.limitations + "</p>\n" +
	"        <div class=\"note-box\">\n" +
	"          <strong>Complementary use:</strong> " + a.complement + "\n" +
	"        </div>\n" +
	"      </section>"
}], "\n\n")

// ═══════════════════════════════════════════════════════════════════════════
// HTML DOCUMENT
// ═══════════════════════════════════════════════════════════════════════════

spec_html: """
	<!DOCTYPE html>
	<html lang="en">
	<head>
	  <meta charset="utf-8">
	  <meta name="description" content="A compile-time governance framework for LLM compliance, producing 8 W3C standard outputs from a single dependency graph. Maps to EU AI Act, ISO/IEC 42001, NIST AI RMF.">
	  <title>\(_meta.title)</title>
	  <script src="https://www.w3.org/Tools/respec/respec-w3c" class="remove" defer></script>
	  <script class="remove">
	    var respecConfig = {
	      specStatus: "unofficial",
	      shortName: "\(_meta.shortName)",
	      edDraftURI: "\(_meta.edDraftURI)",
	      editors: [{ name: "\(_meta.editors[0].name)", url: "\(_meta.editors[0].url)" }],
	      github: "\(_meta.github)",
	      latestVersion: "\(_meta.latestURI)",
	      noRecTrack: true,
	      localBiblio: {
	        "CUE": {
	          title: "The CUE Data Constraint Language",
	          href: "https://cuelang.org/docs/reference/spec/",
	          publisher: "CUE Authors"
	        },
	        "EU-AI-ACT": {
	          title: "Regulation (EU) 2024/1689 — Artificial Intelligence Act",
	          href: "https://eur-lex.europa.eu/eli/reg/2024/1689/oj",
	          publisher: "European Parliament and Council",
	          date: "2024-06-13"
	        },
	        "ISO-42001": {
	          title: "ISO/IEC 42001:2023 — AI Management System",
	          href: "https://www.iso.org/standard/81230.html",
	          publisher: "ISO/IEC JTC 1/SC 42"
	        },
	        "NIST-AI-RMF": {
	          title: "AI Risk Management Framework (AI RMF 1.0)",
	          href: "https://www.nist.gov/artificial-intelligence/executive-order-safe-secure-and-trustworthy-artificial-intelligence",
	          publisher: "National Institute of Standards and Technology",
	          date: "2023-01-26"
	        },
	        "CAN-AIDA": {
	          title: "Artificial Intelligence and Data Act (AIDA)",
	          href: "https://ised-isde.canada.ca/site/innovation-better-canada/en/artificial-intelligence-and-data-act",
	          publisher: "Innovation, Science and Economic Development Canada"
	        },
	        "UK-AI-REG": {
	          title: "A pro-innovation approach to AI regulation",
	          href: "https://www.gov.uk/government/publications/ai-regulation-a-pro-innovation-approach",
	          publisher: "UK Department for Science, Innovation and Technology",
	          date: "2024-02-06"
	        },
	        "TBS-ADM": {
	          title: "Directive on Automated Decision-Making",
	          href: "https://www.tbs-sct.canada.ca/pol/doc-eng.aspx?id=32592",
	          publisher: "Treasury Board of Canada Secretariat"
	        },
	        "AU-AI-ETHICS": {
	          title: "Australia's AI Ethics Principles",
	          href: "https://www.industry.gov.au/publications/australias-artificial-intelligence-ethics-framework",
	          publisher: "Australian Government Department of Industry"
	        }
	      }
	    };
	  </script>
	  <style>
	    table.def { border-collapse: collapse; width: 100%; margin: 1em 0; }
	    table.def th, table.def td { border: 1px solid #ddd; padding: 8px 12px; text-align: left; vertical-align: top; }
	    table.def th { background: #f5f5f5; font-size: 0.9em; }
	    table.def td:first-child { white-space: nowrap; }
	    dt code { font-size: 1.05em; color: #005a9c; }
	    dd { margin-bottom: 1em; }
	    .count { display: inline-block; background: #005a9c; color: white;
	      border-radius: 3px; padding: 1px 6px; font-size: 0.85em; margin-left: 4px; }
	    pre.json { background: #f8f8f8; border: 1px solid #ddd; border-radius: 3px;
	      padding: 12px 16px; overflow-x: auto; font-size: 0.85em; line-height: 1.5; }
	    .note-box { background: #e8f4fd; border-left: 4px solid #005a9c;
	      padding: 12px 16px; margin: 1em 0; font-size: 0.9em; }
	    .warn-box { background: #fff8e8; border-left: 4px solid #e6a817;
	      padding: 12px 16px; margin: 1em 0; font-size: 0.9em; }
	    .site-nav { background: #0a0e14; padding: 8px 24px; font-family: 'IBM Plex Mono', monospace;
	      font-size: 11px; display: flex; gap: 20px; border-bottom: 1px solid #1e2733; }
	    .site-nav a { color: #5c6978; text-decoration: none; transition: color 0.2s; }
	    .site-nav a:hover { color: #3ddc84; }
	    .site-nav .current { color: #3ddc84; }
	    .phase-flow { display: flex; flex-wrap: wrap; gap: 4px; align-items: center; margin: 1.5em 0; }
	    .phase-flow .phase { background: #f0f4f8; border: 1px solid #d0d7de; border-radius: 6px;
	      padding: 6px 12px; font-size: 0.85em; font-weight: 600; }
	    .phase-flow .arrow { color: #8b949e; font-size: 1.2em; }
	  </style>
	</head>
	<body>
	  <nav class="site-nav">
	    <a href="../../index.html">Home</a>
	    <a href="../../charter.html">Charter</a>
	    <a href="../index.html">Core Spec</a>
	    <a class="current">LLM Governance</a>
	    <a href="../../gc-governance.html">GC Example</a>
	    <a href="\(_meta.github)">GitHub</a>
	  </nav>

	  <!-- ═══ ABSTRACT ════════════════════════════════════════════ -->
	  <section id="abstract">
	    <p>This specification defines a compile-time governance framework for
	    organizations deploying LLMs under regulatory
	    frameworks including the EU AI Act [[EU-AI-ACT]], ISO/IEC 42001
	    [[ISO-42001]], the UK AI regulatory framework [[UK-AI-REG]], and
	    Canada's Directive on Automated Decision-Making [[TBS-ADM]].</p>

	    <p>The framework models LLM governance as a typed dependency graph
	    where regulatory obligations flow through control objectives, compliance
	    rules, classification policies, and deployment constraints to produce
	    verifiable compliance artifacts. A single graph definition yields
	    8 W3C standard outputs: SHACL [[shacl]] validation reports,
	    ODRL [[odrl-vocab]] classification policies, PROV-O [[prov-o]]
	    provenance chains, DCAT [[vocab-dcat-3]] deployment catalogs,
	    Verifiable Credentials [[vc-data-model-2.0]] attestations,
	    SKOS [[skos-reference]] governance vocabularies,
	    OWL-Time [[owl-time]] scheduling intervals, and JSON-LD [[json-ld11]]
	    linked data.</p>

	    <p>This specification builds on the
	    <a href="../index.html">apercue core specification</a>, which defines
	    the underlying data model, graph patterns, and W3C projection
	    mechanisms. The LLM Governance Framework is a domain-specific
	    application of those patterns to the AI compliance domain.</p>
	  </section>

	  <!-- ═══ STATUS ══════════════════════════════════════════════ -->
	  <section id="sotd">
	    <p>This is an unofficial specification produced by the
	    <a href="\(_meta.github)">apercue.ca</a> project. It is generated
	    from CUE source via
	    <code>cue export ./spec/llm-governance/ -e spec_html --out text</code>.</p>
	    <p>The specification is informed by the regulatory frameworks referenced
	    in the bibliography. Cross-references to specific articles and clauses
	    are provided for traceability; the framework is designed to accommodate
	    regulatory evolution without structural changes.</p>
	  </section>

	  <!-- ═══ INTRODUCTION ══════════════════════════════════════════ -->
	  <section id="introduction">
	    <h2>Introduction</h2>

	    <section id="regulatory-landscape">
	      <h3>The Regulatory Landscape</h3>
	      <p>Organizations deploying LLMs in 2025–2026 face a converging set
	      of regulatory requirements:</p>
	      <ul>
	        <li>The <strong>EU AI Act</strong> [[EU-AI-ACT]] (fully applicable
	        August 2026 for high-risk systems) requires risk classification,
	        technical documentation, human oversight, and registration with
	        national authorities.</li>
	        <li><strong>ISO/IEC 42001</strong> [[ISO-42001]] provides a certifiable
	        AI management system framework with planning, operation, performance
	        evaluation, and improvement clauses.</li>
	        <li>The <strong>UK AI regulatory framework</strong> [[UK-AI-REG]]
	        establishes five principles — safety, transparency, fairness,
	        accountability, contestability — enforced by existing sectoral
	        regulators.</li>
	        <li>Canada's <strong>Directive on Automated Decision-Making</strong>
	        [[TBS-ADM]] requires Algorithmic Impact Assessments and imposes
	        transparency and recourse obligations scaled by impact level (I–IV).
	        The proposed <strong>AIDA</strong> [[CAN-AIDA]] would extend these
	        requirements to the private sector.</li>
	        <li>Australia's <strong>AI Ethics Principles</strong>
	        [[AU-AI-ETHICS]] define eight voluntary principles that are
	        expected to become mandatory through sectoral regulation.</li>
	        <li>The <strong>NIST AI RMF</strong> [[NIST-AI-RMF]] provides a
	        four-function governance model (Govern, Map, Measure, Manage)
	        widely adopted as a baseline in North America.</li>
	      </ul>
	      <p>These frameworks share common structural elements — risk assessment,
	      control objectives, documentation requirements, audit trails, and
	      reporting obligations — but express them in different vocabularies
	      with different clause numbering.</p>
	    </section>

	    <section id="the-problem">
	      <h3>The Compliance Challenge</h3>
	      <p>Current approaches to LLM governance fall into three categories:</p>
	      <ol>
	        <li><strong>Document-driven compliance:</strong> Policies written in
	        natural language documents (Word, PDF, wiki). Cannot be validated
	        automatically. Drift from implementation is invisible until audit.</li>
	        <li><strong>Platform-driven compliance:</strong> SaaS governance
	        platforms with dashboards, risk scores, and reporting templates.
	        Compliance state is a metric in a platform rather than a structural
	        property of the system. Difficult to version-control or diff.</li>
	        <li><strong>Runtime enforcement:</strong> Guardrail systems that
	        filter prompts and responses at inference time. Essential for
	        operational safety but reactive — they detect violations rather
	        than preventing them structurally.</li>
	      </ol>
	      <p>None of these approaches provide <em>compile-time governance</em>:
	      a model where regulatory requirements are expressed as structural
	      constraints that must be satisfied before the system can be deployed.
	      A model that is version-controlled, diffable, auditable, and
	      machine-verifiable.</p>
	    </section>

	    <section id="the-approach">
	      <h3>Compile-Time Governance</h3>
	      <p>This specification defines LLM governance as a typed dependency
	      graph. Obligations flow through controls to rules to policies to
	      deployments to audit. The graph is expressed in CUE [[CUE]] and
	      validated at evaluation time. Phase gates prevent advancement until
	      predecessor deliverables are complete. W3C projections produce
	      machine-readable compliance artifacts — not as a reporting layer
	      on top of the system, but as structural properties of the graph
	      itself.</p>

	      <div class="phase-flow">
	        <span class="phase">1. Obligations</span>
	        <span class="arrow">&rarr;</span>
	        <span class="phase">2. Impact</span>
	        <span class="arrow">&rarr;</span>
	        <span class="phase">3. Controls</span>
	        <span class="arrow">&rarr;</span>
	        <span class="phase">4. Knowledge</span>
	        <span class="arrow">&rarr;</span>
	        <span class="phase">5. Policies</span>
	        <span class="arrow">&rarr;</span>
	        <span class="phase">6. Deployment</span>
	        <span class="arrow">&rarr;</span>
	        <span class="phase">7. Audit</span>
	        <span class="arrow">&rarr;</span>
	        <span class="phase">8. Reporting</span>
	      </div>

	      <p>The result: an organization cannot claim compliance without the
	      graph validating. The compliance state is not a dashboard metric —
	      it is a structural invariant enforced by the type system.</p>
	    </section>
	  </section>

	  <!-- ═══ TERMINOLOGY ═══════════════════════════════════════════ -->
	  <section id="terminology">
	    <h2>Terminology</h2>
	    <dl>
	      <dt><dfn>Obligation</dfn></dt>
	      <dd>A binding regulatory or policy requirement. Obligations are root
	      nodes in the governance graph — they create the requirements that all
	      downstream resources must satisfy.</dd>

	      <dt><dfn>Control Objective</dfn></dt>
	      <dd>A measurable control derived from one or more obligations. Controls
	      specify <em>what</em> must be enforced without prescribing
	      <em>how</em>.</dd>

	      <dt><dfn>Compliance Rule</dfn></dt>
	      <dd>An enforceable implementation of a control objective. Rules specify
	      the mechanism — CUE constraints for compile-time enforcement, policy
	      assertions for runtime enforcement.</dd>

	      <dt><dfn>Classification Policy</dfn></dt>
	      <dd>An ODRL 2.2 policy governing data handling at a specific
	      classification level. Defines what actions are permitted, prohibited,
	      and obligatory for data flowing through LLM systems.</dd>

	      <dt><dfn>Phase Gate</dfn></dt>
	      <dd>A checkpoint in the governance graph that requires all predecessor
	      deliverables to be satisfied before downstream work can proceed.
	      Phase gates enforce sequential discipline in the compliance
	      lifecycle.</dd>

	      <dt><dfn>Conformance Profile</dfn></dt>
	      <dd>A jurisdiction- or organization-specific configuration that declares
	      which obligations, resource types, and phase gates apply. Profiles
	      enable the same framework to serve different regulatory contexts.</dd>

	      <dt><dfn>Knowledge Grounding</dfn></dt>
	      <dd>The practice of anchoring LLM responses to verified factual
	      assertions drawn from authoritative sources. Every grounded fact
	      cites its source, classification, and verification date.</dd>

	      <dt><dfn>Deployment Model</dfn></dt>
	      <dd>A configuration describing how an LLM is deployed with bound
	      policies. Deployment models declare provider, infrastructure type,
	      classification ceiling, and required compliance gates.</dd>

	      <dt><dfn>Provenance Chain</dfn></dt>
	      <dd>A PROV-O linked sequence of activities, agents, and entities
	      that traces a compliance claim from its regulatory source through
	      control implementation to audit evidence.</dd>

	      <dt><dfn>Compile-Time Governance</dfn></dt>
	      <dd>A governance model where compliance constraints are structural
	      properties of the system definition, enforced at evaluation time
	      (CUE unification), before any runtime behavior occurs.</dd>
	    </dl>
	  </section>

	  <!-- ═══ DOMAIN MODEL ═════════════════════════════════════════ -->
	  <section id="domain-model">
	    <h2>Domain Model</h2>
	    <p>The LLM Governance Framework defines 10 resource types that model
	    the compliance lifecycle from regulatory obligation to verifiable
	    attestation. Each type has an ID format convention, CUE-enforced
	    structural constraints, and a mapping to one or more W3C
	    vocabularies.</p>

	    <table class="def">
	      <thead>
	        <tr><th>Type</th><th>ID Format</th><th>Description</th><th>W3C Mapping</th></tr>
	      </thead>
	      <tbody>
	\(_typeRows)
	      </tbody>
	    </table>

	\(_typeDetailSections)

	    <section id="type-relationships">
	      <h3>Resource Relationships</h3>
	      <p>Resources are connected by <code>depends_on</code> edges that
	      map to <code>dcterms:requires</code> in JSON-LD. The canonical
	      dependency flow is:</p>
	      <pre class="example" title="Canonical dependency flow">
	Obligation
	  &rarr; ControlObjective (depends_on: obligation)
	    &rarr; ComplianceRule (depends_on: control)
	      &rarr; ClassificationPolicy (depends_on: rules it enforces)
	        &rarr; DeploymentModel (depends_on: policies, gates)
	          &rarr; AuditRecord (depends_on: deployment, controls)
	            &rarr; VerifiableCredential (depends_on: audit evidence)

	Knowledge Grounding (parallel track):
	  AuthoritativeSource
	    &rarr; PolicyFact (depends_on: source)
	    &rarr; TermDefinition (depends_on: source)
	  DomainScope (depends_on: obligations, sources)</pre>
	      <p>This flow is not prescriptive — organizations MAY introduce
	      additional dependency edges to model their specific governance
	      topology. The framework requires only that the graph is a
	      directed acyclic graph (DAG) and that all <code>depends_on</code>
	      references resolve.</p>
	    </section>
	  </section>

	  <!-- ═══ PHASE ARCHITECTURE ═══════════════════════════════════ -->
	  <section id="phase-architecture">
	    <h2>Phase Architecture</h2>
	    <p>The governance lifecycle is organized into 8 sequential phases.
	    Each phase produces specific deliverables and W3C projection outputs.
	    Phase gates enforce ordering — Phase N+1 cannot proceed until Phase N's
	    gate is satisfied.</p>

	    <table class="def">
	      <thead>
	        <tr><th>Phase</th><th>Description</th><th>Deliverables</th><th>W3C Output</th></tr>
	      </thead>
	      <tbody>
	\(_phaseRows)
	      </tbody>
	    </table>

	    <section id="phase-gates">
	      <h3>Phase Gate Model</h3>
	      <p>Each phase gate is a CUE constraint that validates completeness.
	      A gate is <em>satisfied</em> when all required resources for that
	      phase are present in the graph and pass structural validation. Gates
	      are implemented using the apercue <code>#Charter</code> pattern:</p>
	      <pre class="example" title="Phase gate definition (CUE)">
	_charter: charter.#Charter &amp; {
	  name: "my-llm-governance"
	  gates: {
	    "obligation-graph": {
	      phase: 1
	      requires: {
	        "gc-llm-framework": true
	        "privacy-act": true
	        "ai-act-art9": true
	      }
	    }
	    "impact-assessment": {
	      phase: 2
	      requires: {
	        "aia-level-classification": true
	        "risk-matrix": true
	      }
	    }
	    // ... phases 3–8
	  }
	}</pre>
	      <p>Gap analysis (<code>#GapAnalysis</code>) computes the delta between
	      the charter and the current graph, producing a SHACL
	      <code>sh:ValidationReport</code> where each missing resource is a
	      <code>sh:Violation</code>.</p>
	    </section>
	  </section>

	  <!-- ═══ W3C PROJECTIONS ══════════════════════════════════════ -->
	  <section id="projections">
	    <h2>W3C Projection Mappings</h2>
	    <p>Each W3C projection serves a specific governance function. The same
	    graph produces all projections — no separate data entry, no
	    synchronization, no drift between compliance artifacts.</p>

	    <table class="def">
	      <thead>
	        <tr><th>Standard</th><th>Governance Use</th><th>Output Type</th><th>Phases</th></tr>
	      </thead>
	      <tbody>
	\(_projectionRows)
	      </tbody>
	    </table>

	    <section id="projection-pipeline">
	      <h3>Projection Pipeline</h3>
	      <p>All projections are produced by <code>cue export</code> from the
	      same CUE module. No intermediate transformation or post-processing
	      is required:</p>
	      <pre class="example" title="Export commands for all projections">
	# SHACL compliance report
	cue export ./my-governance/ -e compliance.shacl_report --out json

	# ODRL classification policies
	cue export ./my-governance/ -e projections.odrl --out json

	# PROV-O provenance chains
	cue export ./my-governance/ -e projections.prov --out json

	# DCAT deployment catalog
	cue export ./my-governance/ -e projections.dcat --out json

	# Verifiable Credentials
	cue export ./my-governance/ -e projections.vc --out json

	# SKOS governance vocabulary
	cue export ./my-governance/ -e projections.skos --out json

	# OWL-Time scheduling
	cue export ./my-governance/ -e cpm.time_report --out json

	# All projections (bundled)
	cue export ./my-governance/ -e projections --out json</pre>
	    </section>
	  </section>

	  <!-- ═══ CONFORMANCE PROFILES ═════════════════════════════════ -->
	  <section id="conformance">
	    <h2>Conformance Profiles</h2>
	    <p>A <a>conformance profile</a> adapts the generic framework to a
	    specific regulatory jurisdiction or organizational context. Profiles
	    declare which obligations apply, which resource types are required,
	    and which phase gates must be satisfied.</p>

	    <section id="profile-definition">
	      <h3>Profile Definition</h3>
	      <p>A conformance profile is a CUE value that specifies:</p>
	      <ol>
	        <li><strong>Applicable obligations:</strong> Which regulatory
	        instruments bind this organization (EU AI Act, Canadian AIDA,
	        UK principles, etc.).</li>
	        <li><strong>Required resource types:</strong> Which domain types
	        (§3) must be present in the governance graph.</li>
	        <li><strong>Phase gates:</strong> Which phase gates (§4.1) must
	        be satisfied, and what resources each gate requires.</li>
	        <li><strong>Classification levels:</strong> Which data classification
	        levels apply (and therefore which ODRL policies are needed).</li>
	        <li><strong>Audit cadence:</strong> How frequently audit activities
	        must be recorded in the provenance chain.</li>
	      </ol>
	      <pre class="example" title="Conformance profile skeleton (CUE)">
	_profile: {
	  name: "eu-ai-act-high-risk"
	  jurisdiction: "EU"
	  applicable_frameworks: ["EU-AI-ACT", "ISO-42001"]
	  required_types: {
	    Obligation: true
	    ControlObjective: true
	    ComplianceRule: true
	    DeploymentModel: true
	    AuditRecord: true
	  }
	  classification_levels: ["public", "internal", "confidential"]
	  audit_cadence: "quarterly"
	  gates: {
	    // Phase gate definitions per §4.1
	  }
	}</pre>
	    </section>

	    <section id="gc-federal-profile">
	      <h3>Reference Implementation: GC Federal Profile</h3>
	      <p>The <a href="../../gc-governance.html">GC LLM Governance</a>
	      example implements a conformance profile for the Government of Canada.
	      This profile binds:</p>
	      <ul>
	        <li><strong>Obligations:</strong> Privacy Act, Official Languages Act,
	        TBS Directive on Automated Decision-Making [[TBS-ADM]], CCCS
	        security guidance.</li>
	        <li><strong>Impact levels:</strong> AIA Levels I–IV as defined by
	        the Directive.</li>
	        <li><strong>Classification levels:</strong> Unclassified, Protected A,
	        Protected B (with ODRL policies for each).</li>
	        <li><strong>Domain types:</strong> All 10 types defined in §3,
	        including PolicyFact and TermDefinition for bilingual knowledge
	        grounding.</li>
	        <li><strong>Phase gates:</strong> All 8 phases with 52 resources.</li>
	      </ul>
	      <p>The GC profile demonstrates that a jurisdiction-specific
	      governance charter can produce all 8 W3C projections from a single
	      CUE module with no custom code — only domain-specific resource
	      definitions.</p>
	    </section>

	    <section id="creating-profiles">
	      <h3>Creating Custom Profiles</h3>
	      <p>Organizations SHOULD create conformance profiles that reflect
	      their specific regulatory obligations. The recommended process:</p>
	      <ol>
	        <li>Identify applicable regulatory frameworks (§1.1).</li>
	        <li>Map framework requirements to obligation resources (Phase 1).</li>
	        <li>Determine required classification levels for ODRL policies.</li>
	        <li>Define phase gates with required resources per phase.</li>
	        <li>Run <code>cue vet</code> to validate the profile against
	        the domain type constraints.</li>
	        <li>Run gap analysis to identify remaining work.</li>
	      </ol>
	      <p>Profiles for different jurisdictions can be composed — an
	      organization operating in both the EU and Canada can merge
	      obligations from both the EU AI Act and AIDA profiles, with
	      CUE unification automatically deduplicating shared controls.</p>
	    </section>
	  </section>

	  <!-- ═══ REGULATORY CROSSWALK ═════════════════════════════════ -->
	  <section id="regulatory-crosswalk">
	    <h2>Regulatory Crosswalk</h2>
	    <p>The following table maps each governance phase to specific clauses,
	    articles, and principles across five regulatory frameworks. This
	    crosswalk demonstrates that the 8-phase architecture covers the
	    substantive requirements of each framework — one graph satisfies
	    multiple regulatory regimes simultaneously.</p>

	    <table class="def">
	      <thead>
	        <tr>
	          <th>Phase</th>
	          <th>EU AI Act [[EU-AI-ACT]]</th>
	          <th>ISO/IEC 42001 [[ISO-42001]]</th>
	          <th>UK Framework [[UK-AI-REG]]</th>
	          <th>Canada [[TBS-ADM]]</th>
	          <th>NIST AI RMF [[NIST-AI-RMF]]</th>
	        </tr>
	      </thead>
	      <tbody>
	\(_crosswalkRows)
	      </tbody>
	    </table>

	    <div class="note-box">
	      <strong>Crosswalk methodology:</strong> Mappings are based on
	      substantive alignment of requirements, not lexical similarity.
	      A phase maps to a framework clause when the phase's deliverables
	      would satisfy or materially contribute to the clause's requirements.
	      Organizations SHOULD validate mappings against their specific
	      regulatory obligations with qualified legal counsel.
	    </div>

	    <section id="crosswalk-eu">
	      <h3>EU AI Act Alignment</h3>
	      <p>The EU AI Act [[EU-AI-ACT]] uses a risk-based classification
	      system. High-risk AI systems (Annex III) face the most stringent
	      requirements. The framework's 8 phases map to EU AI Act requirements
	      as follows:</p>
	      <ul>
	        <li><strong>Risk classification</strong> (Art. 6, Annex III) is
	        addressed in Phase 2 (Impact Assessment). Each LLM deployment
	        receives a risk classification that determines downstream
	        requirements.</li>
	        <li><strong>Quality management</strong> (Art. 17) spans Phases 3–6,
	        with control objectives, compliance rules, and deployment
	        constraints forming the quality management system.</li>
	        <li><strong>Technical documentation</strong> (Art. 11) is produced
	        as a structural property of the graph — the graph <em>is</em> the
	        documentation.</li>
	        <li><strong>Record-keeping</strong> (Art. 12) maps to Phase 7
	        provenance chains. PROV-O activities with timestamps and agent
	        attributions satisfy the logging requirements.</li>
	        <li><strong>Registration</strong> (Art. 49) maps to Phase 8 DCAT
	        catalog entries, which provide the structured metadata needed
	        for EU database registration.</li>
	      </ul>
	      <div class="warn-box">
	        <strong>August 2026 deadline:</strong> High-risk AI system
	        requirements under the EU AI Act become fully applicable on
	        2 August 2026. Organizations deploying LLMs classified as
	        high-risk under Annex III MUST have conforming governance
	        systems in place by this date.
	      </div>
	    </section>

	    <section id="crosswalk-commonwealth">
	      <h3>Commonwealth Alignment</h3>
	      <p>Commonwealth jurisdictions (UK, Canada, Australia) share a
	      principles-based approach to AI governance that complements the
	      EU's rules-based framework:</p>
	      <ul>
	        <li>The <strong>UK framework</strong> [[UK-AI-REG]] assigns enforcement
	        to existing sectoral regulators (ICO, FCA, Ofcom, CMA) applying
	        five cross-cutting principles. The governance graph's phase gates
	        map to these principles, enabling organizations to demonstrate
	        compliance to multiple regulators from the same data.</li>
	        <li><strong>Canada's TBS Directive</strong> [[TBS-ADM]] requires
	        Algorithmic Impact Assessments (AIA) with impact levels I–IV.
	        Phase 2 directly models AIA level assignments; higher impact
	        levels trigger additional control requirements in Phases 3–5.</li>
	        <li><strong>Australia's AI Ethics Principles</strong>
	        [[AU-AI-ETHICS]] define eight principles (human/societal wellbeing,
	        fairness, privacy, reliability, transparency, contestability,
	        accountability, human oversight) that map across Phases 1, 3, 5,
	        and 7.</li>
	      </ul>
	      <p>The key advantage of graph-based governance for Commonwealth
	      jurisdictions: principles-based regulation requires organizations
	      to <em>demonstrate</em> how they satisfy principles, not merely
	      check boxes. The provenance chains (Phase 7) and verifiable
	      credentials (Phase 8) provide this evidence structurally.</p>
	    </section>
	  </section>

	  <!-- ═══ COMPETITIVE LANDSCAPE ════════════════════════════════ -->
	  <section id="landscape" class="informative">
	    <h2>Approaches to LLM Governance</h2>
	    <p>LLM governance is addressed by multiple categories of tools and
	    frameworks. This section describes five approaches, their strengths
	    and limitations, and how they complement each other. Effective
	    governance typically requires tools from multiple categories.</p>

	\(_approachSections)

	    <section id="landscape-summary">
	      <h3>Summary: Complementary Layers</h3>
	      <p>No single approach covers the full governance lifecycle. The
	      recommended architecture combines:</p>
	      <ol>
	        <li><strong>Compile-time governance</strong> (this specification)
	        for structural compliance — the policy graph that must validate
	        before deployment.</li>
	        <li><strong>Runtime guardrails</strong> for operational safety —
	        prompt/response filtering at inference time.</li>
	        <li><strong>Observability platforms</strong> for operational
	        visibility — traces, metrics, and cost tracking that feed
	        back into the provenance chain.</li>
	        <li><strong>Governance platforms</strong> for executive
	        reporting — dashboards that consume W3C projection output
	        (SHACL reports, DCAT catalogs) from the compile-time layer.</li>
	      </ol>
	      <p>The compile-time layer produces machine-readable artifacts
	      (JSON-LD, SHACL, ODRL, PROV-O) that the other layers can consume.
	      This creates a governance data pipeline rather than isolated
	      tools.</p>
	    </section>
	  </section>

	  <!-- ═══ SECURITY ══════════════════════════════════════════════ -->
	  <section id="security">
	    <h2>Security Considerations</h2>

	    <section id="sec-classification">
	      <h3>Data Classification</h3>
	      <p>Governance graphs contain resource descriptions that reference
	      regulatory obligations, control implementations, and deployment
	      configurations. While the graph itself does not contain protected
	      data, the <em>structure</em> of the graph reveals organizational
	      compliance posture — which obligations are satisfied, which controls
	      are in place, and which deployments exist.</p>
	      <p>Organizations SHOULD classify governance graph exports according
	      to their information classification policy. ODRL policies defined
	      in Phase 5 SHOULD apply to the governance data itself, not only
	      to the LLM data it governs.</p>
	    </section>

	    <section id="sec-supply-chain">
	      <h3>Supply Chain Integrity</h3>
	      <p>The governance graph references external authoritative sources
	      (URLs in <code>AuthoritativeSource</code> resources). These
	      references SHOULD be validated for integrity:</p>
	      <ul>
	        <li>Source URLs SHOULD use HTTPS.</li>
	        <li>Source content SHOULD be archived or checksummed at the time
	        of fact extraction.</li>
	        <li>The <code>date_accessed</code> field SHOULD be populated to
	        enable temporal verification.</li>
	      </ul>
	    </section>

	    <section id="sec-identifiers">
	      <h3>Identifier Constraints</h3>
	      <p>All resource identifiers inherit the <code>#SafeID</code> and
	      <code>#SafeLabel</code> constraints from the
	      <a href="../index.html#identifier-constraints">core specification</a>.
	      Domain type ID formats (e.g., <code>OBL-NNN</code>,
	      <code>CTL-NNN</code>) provide additional structural validation
	      via CUE regex constraints.</p>
	    </section>
	  </section>

	  <!-- ═══ PRIVACY ══════════════════════════════════════════════ -->
	  <section id="privacy">
	    <h2>Privacy Considerations</h2>
	    <p>Governance graphs for LLM systems raise specific privacy concerns:</p>
	    <ul>
	      <li><strong>Policy facts</strong> may contain verbatim text from
	      legal instruments. While this text is typically public, the
	      <em>selection</em> of facts reveals organizational focus areas.</li>
	      <li><strong>Domain scopes</strong> declare permitted and excluded
	      topics, which may reveal sensitive organizational boundaries
	      (e.g., excluded topics in an HR scope).</li>
	      <li><strong>Audit records</strong> reference agents (people or teams)
	      responsible for compliance activities. Agent identifiers SHOULD
	      use role-based references (e.g., "AI Ethics Board") rather than
	      personal identifiers where possible.</li>
	      <li><strong>Deployment models</strong> may reveal provider
	      relationships and infrastructure choices. Organizations operating
	      in regulated sectors SHOULD consider whether deployment metadata
	      constitutes commercially sensitive information.</li>
	    </ul>
	    <p>The <a href="../index.html#privacy">core specification's privacy
	    guidance</a> on <code>@id</code> values and public export applies
	    to governance graphs. Organizations SHOULD use the public/private
	    deployment split to ensure governance graphs with operational detail
	    are not inadvertently published.</p>
	  </section>

	  <!-- ═══ REFERENCES ═══════════════════════════════════════════ -->
	  <section id="references" class="informative">
	    <h2>References</h2>
	    <section id="normative-references">
	      <h3>Normative References</h3>
	      <ul>
	        <li>[[EU-AI-ACT]] — Regulation (EU) 2024/1689, Artificial Intelligence Act</li>
	        <li>[[ISO-42001]] — ISO/IEC 42001:2023, AI Management System</li>
	        <li>[[shacl]] — Shapes Constraint Language, W3C Recommendation</li>
	        <li>[[odrl-vocab]] — ODRL Vocabulary &amp; Expression 2.2, W3C Recommendation</li>
	        <li>[[prov-o]] — PROV-O: The PROV Ontology, W3C Recommendation</li>
	        <li>[[vocab-dcat-3]] — DCAT 3, W3C Recommendation</li>
	        <li>[[vc-data-model-2.0]] — Verifiable Credentials Data Model 2.0, W3C Recommendation</li>
	        <li>[[skos-reference]] — SKOS Simple Knowledge Organization System, W3C Recommendation</li>
	        <li>[[owl-time]] — Time Ontology in OWL, W3C Recommendation</li>
	        <li>[[json-ld11]] — JSON-LD 1.1, W3C Recommendation</li>
	        <li>[[RFC2119]] — Key words for use in RFCs, BCP 14</li>
	        <li>[[CUE]] — The CUE Data Constraint Language</li>
	      </ul>
	    </section>
	    <section id="informative-references">
	      <h3>Informative References</h3>
	      <ul>
	        <li>[[NIST-AI-RMF]] — AI Risk Management Framework 1.0, NIST</li>
	        <li>[[CAN-AIDA]] — Artificial Intelligence and Data Act, Canada</li>
	        <li>[[UK-AI-REG]] — A pro-innovation approach to AI regulation, UK DSIT</li>
	        <li>[[TBS-ADM]] — Directive on Automated Decision-Making, TBS Canada</li>
	        <li>[[AU-AI-ETHICS]] — Australia's AI Ethics Principles</li>
	        <li><a href="https://www.dublincore.org/specifications/dublin-core/dcmi-terms/">Dublin Core Terms</a> — DCMI Metadata Terms</li>
	        <li><a href="https://schema.org/">schema.org</a> — Structured data vocabulary</li>
	        <li><a href="https://www.w3.org/TR/EARL10-Schema/">EARL 1.0</a> — Evaluation and Report Language, W3C Note</li>
	      </ul>
	    </section>
	  </section>

	</body>
	</html>
	"""
