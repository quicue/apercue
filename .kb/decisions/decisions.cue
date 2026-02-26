// Architecture decisions for apercue.ca
package decisions

import "quicue.ca/kg/core@v0"

d001: core.#Decision & {
	id:        "ADR-001"
	title:     "Domain-agnostic graph engine extracted from quicue.ca"
	status:    "accepted"
	date:      "2026-02-19"
	context:   "quicue.ca's #InfraGraph and analysis patterns work for any domain, not just infrastructure. The 'Infra' prefix creates a false impression that the patterns are infrastructure-specific."
	decision:  "Extract generic patterns into apercue.ca as #Graph (renamed from #InfraGraph). Strip all infrastructure-specific fields (ip, fqdn, host, container_id, vm_id, ssh_user, hosted_on, actions, provides). Keep the core: name, @type, depends_on, description."
	rationale: "The dependency graph engine, CPM analysis, compliance checking, and W3C projections are domain-agnostic. Proving this with non-infrastructure examples (courses, recipes, supply chains) strengthens the theoretical contribution."
	consequences: [
		"apercue.ca has no infrastructure vocabulary — #TypeNames is unconstrained",
		"quicue.ca imports apercue.ca for generic patterns, adds infra-specific layers",
		"Four non-infrastructure examples prove the generality claim",
	]
	appliesTo: [{"@id": "https://apercue.ca/project/apercue"}]
}

d002: core.#Decision & {
	id:        "ADR-002"
	title:     "W3C artifacts as zero-cost projections, not separate processors"
	status:    "accepted"
	date:      "2026-02-19"
	context:   "Traditional semantic web requires separate tools for each concern: triplestore for storage, SPARQL for queries, SHACL processor for validation, serializer for JSON-LD. Each adds infrastructure and failure modes."
	decision:  "Implement W3C artifacts (SHACL ValidationReport, SKOS ConceptScheme, OWL-Time Interval, EARL Assertion) as CUE comprehensions that project from the same typed graph. No runtime infrastructure required."
	rationale: "CUE comprehensions are evaluated at constraint resolution time. A comprehension that produces sh:ValidationReport is structurally identical to a SHACL processor's output but requires zero additional infrastructure. The same graph, different -e expression."
	consequences: [
		"Every W3C artifact is a cue export expression, not a separate service",
		"Validation happens at cue vet time, not at runtime",
		"Limited to closed-world, schema-controlled DAGs (not open-world RDF reasoning)",
	]
	appliesTo: [{"@id": "https://apercue.ca/project/apercue"}]
}

d003: core.#Decision & {
	id:        "ADR-003"
	title:     "Comprehension-level filtering for list comprehensions"
	status:    "accepted"
	date:      "2026-02-19"
	context:   "CUE list comprehensions with body-level if statements produce empty structs {} instead of filtering elements. This caused bugs in #ComplianceCheck where violation lists contained {} entries without resource/check fields."
	decision:  "Always use comprehension-level if (before the body {}) for filtering. Use comprehension-level let for computed values that feed into filters. Never use body-level if to control element inclusion."
	rationale: "In CUE, if inside a body {} conditionally includes fields, not elements. When false, it produces {} (empty struct). Comprehension-level if controls whether an element is emitted at all."
	consequences: [
		"All list comprehensions in patterns/ use comprehension-level if/let",
		"#ComplianceCheck _v1, _v2, _v5 checks restructured",
		"Pattern documented as a gotcha for future CUE development",
	]
	appliesTo: [
		{"@id": "https://apercue.ca/project/apercue"},
		{"@id": "https://quicue.ca/project/quicue-ca"},
	]
}

d004: core.#Decision & {
	id:        "ADR-004"
	title:     "ASCII-safe identifiers prevent zero-width unicode injection"
	status:    "accepted"
	date:      "2026-02-19"
	context:   "Graph identifiers (resource names, type labels) are used in CUE field names, JSON keys, and HTML rendering. Zero-width unicode characters could create visually identical but structurally different identifiers, enabling injection attacks or data corruption."
	decision:  "Enforce _#SafeID (^[a-zA-Z][a-zA-Z0-9_.-]*$) and _#SafeLabel (^[a-zA-Z][a-zA-Z0-9_-]*$) constraints on all graph surfaces. CI validates with unicode rejection test fixtures."
	rationale: "Compile-time prevention is cheaper than runtime detection. CUE regex constraints make invalid identifiers impossible to construct."
	consequences: [
		"All resource names, type labels, and dependency keys are ASCII-only",
		"Unicode rejection tests in CI verify the constraints catch violations",
		"Legitimate unicode use cases (i18n labels) go in description, not name",
	]
	appliesTo: [{"@id": "https://apercue.ca/project/apercue"}]
}

d005: core.#Decision & {
	id:        "ADR-005"
	title:     "Remove dead W3C namespace prefixes from @context"
	status:    "accepted"
	date:      "2026-02-20"
	context:   "The JSON-LD @context registered ODRL, OA, AS, Hydra, and DCAT namespace prefixes from an earlier design phase. None were used in any apercue projection or schema."
	decision:  "Remove all namespace prefixes that have no corresponding CUE comprehension producing output in that vocabulary. Keep only prefixes with active projections (SHACL, SKOS, OWL-Time, EARL, Dublin Core, Schema.org)."
	rationale: "Dead prefixes create false expectations of vocabulary support. JSON-LD contexts should be minimal and honest about what the system actually produces."
	consequences: [
		"@context reduced from 14 to 9 namespace prefixes",
		"PROV-O and DCAT retained as downstream (quicue.ca uses them)",
		"Any future vocabulary additions require an active projection pattern",
	]
	appliesTo: [{"@id": "https://apercue.ca/project/apercue"}]
}

d006: core.#Decision & {
	id:        "ADR-006"
	title:     "_planned status field for charter gap analysis filtering"
	status:    "accepted"
	date:      "2026-02-20"
	context:   "Charter tasks need to exist in the graph for visualization positioning, but planned (future) tasks should not satisfy gap analysis gates. Without a status field, all tasks in the graph appear complete."
	decision:  "Add _planned: bool | *false to charter tasks. Gap analysis filters to _completed_resources (where !_planned). Planned tasks appear in the graph visualization with dashed styling but don't close gates."
	rationale: "The graph topology is shared between visualization and analysis. Removing planned tasks from the graph would lose their dependency edges and depth. Filtering at the gap analysis level keeps the topology intact while correctly computing remaining work."
	consequences: [
		"Planned tasks visible in charter visualization with distinct styling",
		"Gap analysis correctly reports unsatisfied gates for planned work",
		"Completing a task = removing _planned: true, not adding new data",
	]
	appliesTo: [{"@id": "https://apercue.ca/project/apercue"}]
}

d007: core.#Decision & {
	id:        "ADR-007"
	title:     "#AnalyzableGraph interface + precomputed CPM"
	status:    "accepted"
	date:      "2026-02-20"
	context:   "#CriticalPath and analysis patterns required Graph: #Graph, forcing _path computation even with #GraphLite precomputation. CUE's recursive fixpoint for CPM forward/backward passes timed out on 38 nodes."
	decision:  "Introduce #AnalyzableGraph — minimal interface without _path requirement. Both #Graph and #GraphLite satisfy it. Precompute CPM scheduling in Python (O(V+E)). #CriticalPathPrecomputed consumes static data."
	rationale: "One graph, many lenses. The precomputed closure contains all the information; projections are cheap struct comprehensions. CUE validates schemas and produces output shapes, Python handles O(V+E) graph algorithms."
	consequences: [
		"All analysis patterns accept #AnalyzableGraph (only #DependencyChain, #ExportGraph, #VizData still need #Graph)",
		"Unified projections export: 46ms for SHACL + OWL-Time + CPM on 38 nodes",
		"Python toposort.py computes graph closure + CPM in one pass",
	]
	appliesTo: [{"@id": "https://apercue.ca/project/apercue"}]
}

d008: core.#Decision & {
	id:        "ADR-008"
	title:     "Public/private site split — operational data stays on grdn"
	status:    "accepted"
	date:      "2026-02-20"
	context:   "Charter visualization and ecosystem graphs contain real operational data: task completion status, CPM scheduling, gate satisfaction. Publishing this to the public apercue.ca site exposes internal project tracking to the internet."
	decision:  "Split build-site.sh into public (landing, spec, vocab, examples) and private (charter, ecosystem, projections) targets. CI deploys only public content to Cloudflare Pages. Private data is served from grdn network via deploy-local.sh."
	rationale: "The spec and examples are the public interface — they demonstrate capability. Charter progress and scheduling data are operational intelligence that belongs on the infrastructure owner's own network."
	consequences: [
		"Cloudflare Pages serves only generic documentation",
		"Charter, ecosystem, and projections dashboards are local-only",
		"deploy-local.sh handles full build + optional rsync to grdn target",
		"CI workflow simplified — no Python needed for public deploy",
	]
	appliesTo: [{"@id": "https://apercue.ca/project/apercue"}]
}

d009: core.#Decision & {
	id:        "ADR-009"
	title:     "README must link to spec and show input/output pairs"
	status:    "accepted"
	date:      "2026-02-20"
	context:   "Fresh-eyes review revealed that the README never links to the spec, and no single document shows the full CUE input → W3C output journey. A new reader can run examples but cannot see what comes out without running them."
	decision:  "Add spec link to README. Add at least one inline output example (e.g., SHACL report snippet) in the README Quick Start. Spec examples should show the CUE source alongside the JSON output."
	rationale: "The 'aha moment' for apercue is seeing that one cue export command produces a valid W3C artifact. This should be visible in the first 30 seconds of reading, not after cloning and running commands."
	consequences: [
		"README gains a spec link and output preview",
		"Spec examples gain CUE input alongside JSON output",
		"New readers can evaluate the project without installing CUE",
	]
	appliesTo: [{"@id": "https://apercue.ca/project/apercue"}]
}

d010: core.#Decision & {
	id:        "ADR-010"
	title:     "Upgrade Dublin Core from Namespace to Implemented in W3C coverage"
	status:    "accepted"
	date:      "2026-02-20"
	context:   "Dublin Core is listed as 'Namespace' in the W3C coverage table, but dcterms:requires maps every depends_on edge, dcterms:title maps every name, dcterms:description maps descriptions, and dcterms:conformsTo appears in SHACL reports, EARL reports, and DCAT catalogs."
	decision:  "Upgrade Dublin Core to 'Implemented' status in the README, spec, and w3c/README.md. It is not just a namespace prefix — it provides the semantic backbone for the entire dependency model."
	rationale: "A vocabulary whose terms appear in every graph and every projection output is Implemented, not merely registered as a namespace."
	consequences: [
		"W3C coverage tables show 6 Implemented specs (was 5)",
		"Dublin Core's role in the dependency model is explicit",
	]
	appliesTo: [{"@id": "https://apercue.ca/project/apercue"}]
}

d011: core.#Decision & {
	id:        "ADR-011"
	title:     "Feature the self-charter as a first-class example"
	status:    "accepted"
	date:      "2026-02-20"
	context:   "The self-charter (apercue modelling its own development as a dependency graph with 12 resources, 4 gates, CPM scheduling) is listed in the module structure tree but never described in the README or spec. A framework that models itself is inherently credible."
	decision:  "Add a self-charter description to the README Examples section. Link to the charter.html visualization. Mention it in the spec's Examples section as the meta-example."
	rationale: "Dogfooding is the strongest proof of viability. If the patterns are good enough for the project's own planning, they are good enough for any domain."
	consequences: [
		"Self-charter becomes visible to new readers",
		"charter.html and explorer.html get traffic from README links",
		"The 'project models itself' narrative strengthens the generality claim",
	]
	appliesTo: [{"@id": "https://apercue.ca/project/apercue"}]
}

d012: core.#Decision & {
	id:        "ADR-012"
	title:     "Six new W3C projections: PROV-O, ODRL, ORG, Schema.org, VC 2.0, Activity Streams"
	status:    "accepted"
	date:      "2026-02-20"
	context:   "apercue had 6 implemented W3C projections (JSON-LD, SHACL, SKOS, EARL, OWL-Time, Dublin Core). The thesis 'everything is a projection' needed more evidence — particularly for post-2017 specs like VC 2.0 (2025) and Activity Streams 2.0 (2018)."
	decision:  "Add 6 new CUE projection patterns: #ProvenanceTrace (PROV-O), #ODRLPolicy (ODRL 2.2), #OrgStructure (W3C ORG), #SchemaOrgAlignment (schema.org), #ValidationCredential (VC 2.0), #ActivityStream (AS 2.0). Each follows the same architecture: accept #AnalyzableGraph, comprehend over resources, produce W3C-conformant JSON-LD."
	rationale: "12 implemented W3C specs from one typed graph proves the projection model is not cherry-picked. VC 2.0 is particularly compelling — SHACL validates, VC attests. Activity Streams models graph construction as a timeline, enabling changelog narratives."
	consequences: [
		"12 W3C specs implemented (was 6), 0 namespace-only (was 2)",
		"vocab/context.cue gains 4 new namespace prefixes (odrl, org, cred, as)",
		"Interactive playground (playground.html) demonstrates all 6 new projections",
		"Each projection is a separate .cue file — modular, composable, independently testable",
	]
	appliesTo: [{"@id": "https://apercue.ca/project/apercue"}]
}

d013: core.#Decision & {
	id:        "ADR-013"
	title:     "Atkinson Hyperlegible Next/Mono as standard site font"
	status:    "accepted"
	date:      "2026-02-20"
	context:   "The site used IBM Plex Mono + DM Sans (some pages) and Fraunces (index.html). Four different font stacks across 5 HTML pages created visual inconsistency. The tour page on quique.ca had already adopted Atkinson Hyperlegible."
	decision:  "Standardize all site pages on Atkinson Hyperlegible Next (body) and Atkinson Hyperlegible Mono (code/data). Use CSS variables --body and --mono for all font-family declarations. Google Fonts only."
	rationale: "Atkinson Hyperlegible was designed for maximum legibility across vision abilities. Variable font (200-800 weights) with a distinctive personality that avoids both generic AI slop and inaccessible display choices. Mono variant provides code/data consistency."
	consequences: [
		"All 5 site pages use identical font stack via --body/--mono CSS vars",
		"Future font changes require updating one Google Fonts URL + two CSS var values",
		"D3 SVG text attributes must use full font name (can't reference CSS vars)",
		"spec/ pages now also use Atkinson Hyperlegible Mono (migrated from IBM Plex Mono)",
	]
	appliesTo: [{"@id": "https://apercue.ca/project/apercue"}]
}

d014: core.#Decision & {
	id:        "ADR-014"
	title:     "Landing page rewrite: hero stats, novel section, interactive demos"
	status:    "accepted"
	date:      "2026-02-20"
	context:   "The landing page was outdated — hero mentioned 5 specs (actually 12), W3C table showed 9 rows (actually 14), no links to playground/explorer/charter, and no articulation of what's novel about the approach."
	decision:  "Rewrite index.html with: stat bar (12 specs, 4 examples, 0 dependencies, 1 binary), interactive demos section (4 cards), What's Novel section (5 contributions), grouped W3C table (Core/Extended/Downstream), Atkinson Hyperlegible fonts."
	rationale: "The landing page is the primary shareable artifact. It must accurately reflect the project's scope and articulate its contribution. The 12-spec count is the hero metric — compile-time W3C compliance from one typed graph."
	consequences: [
		"Landing page is now accurate and shareable",
		"Interactive demos section drives traffic to playground/explorer/charter",
		"What's Novel section articulates the thesis for reviewers and peers",
		"W3C table grouped as Core (original 6) + Extended (new 6) + Downstream (2)",
	]
	appliesTo: [{"@id": "https://apercue.ca/project/apercue"}]
}

d015: core.#Decision & {
	id:        "ADR-015"
	title:     "GC LLM governance as constraint-first dependency graph"
	status:    "accepted"
	date:      "2026-02-21"
	context:   "Federal LLM deployments must comply with the Directive on Automated Decision-Making (deadline June 24, 2026), Privacy Act, Official Languages Act, and CCCS security guidance. Traditional compliance approaches treat these as separate checklists. LLMs commonly hallucinate governance rules (AIDA status, AIA requirements, PII handling)."
	decision:  "Model GC LLM governance as a 52-resource dependency graph using apercue patterns. Three interlocking layers: obligation graph (statutes/directives/controls/rules), knowledge grounding (quicue-kg typed facts with authoritative sources), operational enforcement (ODRL policies, provider binding, domain scoping). All projecting to 8 W3C vocabularies (SHACL, PROV-O, ODRL, EARL, VC 2.0, DCAT, OWL-Time, SKOS) at compile time."
	rationale: "Governance IS a dependency graph. Statutes produce directives, directives produce controls, controls produce rules, rules constrain deployments. The critical path through the graph IS the compliance timeline. apercue's projection model means one typed graph produces every W3C artifact an auditor needs — SHACL for validation, PROV-O for provenance, ODRL for access policies, VC for attestation, DCAT for the AI Register."
	consequences: [
		"52 governance resources across 8 phases with 8 gates",
		"Critical path: 14 nodes through Privacy Act -> PII blocking -> classification -> ODRL -> provider -> deployment -> audit -> SHACL -> VC",
		"Knowledge grounding: 12 verified policy facts, 8 authoritative sources, 2 domain scopes prevent hallucination",
		"ODRL policies per data classification (Unclassified/Protected A/Protected B) are machine-readable",
		"VC 2.0 credential wraps SHACL report for auditor-ready compliance attestation",
		"Uses #GraphLite + Python precomputation (52 nodes exceeds CUE recursive fixpoint limits)",
	]
	appliesTo: [
		{"@id": "https://apercue.ca/project/apercue"},
		{"@id": "https://apercue.ca/example/gc-llm-governance"},
	]
}

d017: core.#Decision & {
	id:        "ADR-017"
	title:     "@id namespacing convention for multi-domain federation"
	status:    "accepted"
	date:      "2026-02-26"
	context:   "Multiple repositories (apercue, quicue-kg, downstream domain modules) share the same @context and produce resources with @id URIs. The default @base is 'urn:resource:', so a resource named 'auth_service' in two different graphs produces the same @id, causing silent collision when graphs are merged."
	decision:  "Each domain sets @base to its own namespace URI (e.g., urn:apercue:, urn:quicue-kg:, urn:datacenter:). The default urn:resource: is safe for single-repo use. Federation requires distinct @base values. No CUE enforcement yet — document the convention, enforce with #FederatedContext in Phase 8."
	rationale: "Namespace partitioning is the standard linked data solution to @id collision. CUE's @context override makes this trivial — each module provides its own context with a distinct @base. Enforcement is deferred because the convention is sufficient for the current 3-repo ecosystem."
	consequences: [
		"Each repo's context.cue overrides @base with its own namespace URI",
		"Merged graphs have globally unique @id values (namespace + local name)",
		"Phase 8 #FederatedContext will enforce non-default @base at the CUE type level",
		"Single-repo users are unaffected — urn:resource: remains the default",
	]
	appliesTo: [
		{"@id": "https://apercue.ca/project/apercue"},
		{"@id": "https://quicue.ca/project/quicue-ca"},
	]
}

d018: core.#Decision & {
	id:        "ADR-018"
	title:     "#FederatedContext and #FederatedMerge — compile-time federation safety"
	status:    "accepted"
	date:      "2026-02-26"
	context:   "ADR-017 established @base namespacing as a convention. With 4+ repos in the ecosystem (apercue, quicue-kg, cmhc-retrofit, unified-kb), convention alone is insufficient — a typo in @base or a duplicate namespace goes undetected until rdflib or a triple store encounters the collision at import time."
	decision:  "#FederatedContext wraps a graph with a non-default @base namespace (enforced via CUE constraint !=\"urn:resource:\"). #FederatedMerge takes multiple FederatedContext instances and uses CUE unification to detect collisions: each namespace maps to its owning domain, and each @id maps to its source. Conflicting values fail at cue vet time."
	rationale: "CUE unification is the cheapest possible collision detector. If two domains claim the same namespace, the _namespace_ownership struct produces conflicting string values and evaluation fails — no runtime checks, no external validators, no additional dependencies. Cross-domain edges are validated via comprehension-level if filters (ADR-003)."
	consequences: [
		"Any repo joining federation must wrap its graph in #FederatedContext with a unique namespace",
		"Merged JSON-LD concatenates @graph arrays with fully-qualified @id values",
		"Cross-domain edges are declared externally and validated against both source graphs",
		"W3C validation (rdflib round-trip) extended to cover federation test fixtures",
		"Collision detection is zero-cost — it's a CUE constraint, not a runtime check",
	]
	appliesTo: [
		{"@id": "https://apercue.ca/project/apercue"},
	]
}

d016: core.#Decision & {
	id:        "ADR-016"
	title:     "README run commands are the test suite -- CI must execute them"
	status:    "accepted"
	date:      "2026-02-25"
	context:   "End-to-end audit revealed 5 broken cue commands across READMEs and CUE file headers. Fields were renamed (gaps.summary -> gap_summary), expressions referenced patterns never instantiated (-e dot), and a stray cue.mod isolated test files from the root module. None of these were caught because CI only runs cue vet, not the documented commands."
	decision:  "Treat README bash code blocks as executable tests. CI must parse each example README, extract cue commands from ```bash blocks, execute them, and verify exit codes. CUE file header comments with Run: sections are also test cases."
	rationale: "The commands users copy from READMEs are the most important interface. If they break silently, the documentation is worse than absent -- it actively misleads. The fix is cheap: a shell script that extracts and runs the commands. The cost of not doing it was 5 bugs shipped to main."
	consequences: [
		"CI pipeline gains a README command smoke test step",
		"README edits become testable -- changing an -e expression is a test change",
		"CUE file header Run: comments should match README commands exactly",
		"New examples must include working commands or CI fails",
	]
	appliesTo: [
		{"@id": "https://apercue.ca/project/apercue"},
	]
}
