// Insights discovered during apercue.ca development
package insights

import "quicue.ca/kg/core@v0"

i001: core.#Insight & {
	id:         "INSIGHT-001"
	statement:  "CUE unification subsumes both SPARQL graph pattern matching and SHACL shape validation into a single evaluation model"
	evidence: [
		"Comprehension 'for r in resources if r._ancestors[target] != _|_' is equivalent to a SPARQL property path query",
		"Definition '#Resource & {name: string}' is equivalent to a SHACL NodeShape constraint",
		"Both resolve at cue eval time without runtime processors",
	]
	method:     "cross_reference"
	confidence: "high"
	discovered: "2026-02-19"
	implication: "A single CUE module can replace three separate runtime components (triplestore, SPARQL endpoint, SHACL validator) for closed-world dependency graphs"
}

i002: core.#Insight & {
	id:         "INSIGHT-002"
	statement:  "The charter pattern makes project completion a compile-time structural property rather than a judgment call"
	evidence: [
		"When cue vet passes and gaps.complete == true, the charter is provably satisfied",
		"The gap between declared constraints and actual data IS the remaining work, computed automatically",
		"Four examples (courses, recipes, projects, supply chains) all use the same gap analysis",
	]
	method:     "experiment"
	confidence: "high"
	discovered: "2026-02-19"
	implication: "Project planning can be expressed as CUE constraints where 'done' is a boolean computed from structural properties, not a human assessment"
}

i003: core.#Insight & {
	id:         "INSIGHT-003"
	statement:  "Non-infrastructure examples are the strongest proof that the dependency graph pattern is domain-agnostic"
	evidence: [
		"Course prerequisites, recipe ingredients, supply chains, and project tasks all use the same #Graph engine",
		"#CriticalPath computes valid CPM for credit-weighted courses and cook-time-weighted recipe steps",
		"#ComplianceCheck produces valid SHACL reports for courses ('core needs prereqs') and supply chains ('assemblies need components')",
	]
	method:     "experiment"
	confidence: "high"
	discovered: "2026-02-19"
	implication: "The 'Infra' prefix on quicue.ca patterns was limiting adoption perception — removing it and proving generality with diverse examples strengthens the theoretical contribution"
}

i004: core.#Insight & {
	id:         "INSIGHT-004"
	statement:  "The README and spec create a documentation gap where examples show output but never the CUE input that produced it, and vice versa"
	evidence: [
		"Spec Examples section shows SHACL/OWL-Time/JSON-LD output but not the CUE source",
		"README Quick Start shows cue commands but not the output",
		"Data Model section shows CUE input but not projection output",
		"A new reader cannot trace from CUE input → projection pattern → W3C output in any single document",
	]
	method:     "observation"
	confidence: "high"
	discovered: "2026-02-20"
	implication: "Documentation should show input→output pairs: the CUE resource definition alongside the W3C projection it produces. This is the 'aha moment' for new readers."
}

i005: core.#Insight & {
	id:         "INSIGHT-005"
	statement:  "W3C spec coverage in the apercue spec has drifted behind actual ecosystem capabilities"
	evidence: [
		"Spec lists PROV-O as 'Namespace' but quicue.ca has full prov_report projections on #BootstrapPlan and #DriftReport",
		"Spec lists DCAT as 'Downstream (quicue-kg)' but quicue.ca has #DCAT3Catalog, #DCATKnowledgeBase, .kb/dcat.cue",
		"Spec lists EARL only for smoke tests but quicue.ca charter.cue now has EARL evaluation reports",
		"supply-chain example already produces DCAT output but spec says DCAT is Downstream",
	]
	method:     "cross_reference"
	confidence: "high"
	discovered: "2026-02-20"
	implication: "The spec's W3C mapping tables should reflect the full ecosystem, not just apercue.ca alone. A 'downstream' spec that has full projections should be upgraded to 'implemented' in the coverage table."
}

i006: core.#Insight & {
	id:         "INSIGHT-006"
	statement:  "Dublin Core is understated as 'Namespace' when dcterms:requires is the semantic backbone of every dependency edge in every graph"
	evidence: [
		"Every depends_on field maps to dcterms:requires via the JSON-LD @context",
		"dcterms:title maps resource names",
		"dcterms:description maps resource descriptions",
		"dcterms:conformsTo is used in SHACL reports, EARL reports, and DCAT catalogs",
	]
	method:     "cross_reference"
	confidence: "high"
	discovered: "2026-02-20"
	implication: "Dublin Core should be upgraded from 'Namespace' to 'Implemented' in the W3C coverage table — it provides the semantic glue for the entire dependency model"
}

i007: core.#Insight & {
	id:         "INSIGHT-007"
	statement:  "The self-charter (apercue modelling itself as a dependency graph) is the most compelling proof-of-concept but is invisible in documentation"
	evidence: [
		"self-charter/ exists with 12 resources, 4 gates, D3 export",
		"README lists it in the module structure tree but never describes it",
		"Spec does not mention it at all",
		"Site has a charter.html page but it's not linked from the spec or README",
	]
	method:     "observation"
	confidence: "high"
	discovered: "2026-02-20"
	implication: "A framework that models its own development is inherently trustworthy — if the patterns are good enough for the project itself, they are good enough for users. This should be a featured example, not a tree-listing footnote."
}

i008: core.#Insight & {
	id:         "INSIGHT-008"
	statement:  "12 W3C specs projected from one typed graph proves the model is not cherry-picked — it spans validation (SHACL), scheduling (OWL-Time), vocabulary (SKOS), testing (EARL), provenance (PROV-O), policy (ODRL), organization (ORG), alignment (schema.org), attestation (VC 2.0), and activity logging (AS 2.0)"
	evidence: [
		"Each projection follows the identical architecture: accept graph, comprehend over resources, produce JSON-LD",
		"The 6 new projections (PROV-O, ODRL, ORG, schema.org, VC 2.0, AS 2.0) were added in one session without modifying any existing pattern",
		"VC 2.0 wraps SHACL output — projections compose with each other, not just with the graph",
	]
	method:     "experiment"
	confidence: "high"
	discovered: "2026-02-20"
	implication: "The projection architecture scales to new W3C specs without structural changes. Adding a projection is adding a file, not modifying a framework."
}

i009: core.#Insight & {
	id:         "INSIGHT-009"
	statement:  "Font consistency is a maintenance surface in multi-page static sites without shared CSS"
	evidence: [
		"4 of 5 HTML pages drifted to IBM Plex Mono + DM Sans while index.html used Fraunces",
		"Each page is self-contained (no shared stylesheet) — font changes require touching every file",
		"D3 SVG text requires hardcoded font-family strings, creating a second maintenance surface",
	]
	method:     "observation"
	confidence: "high"
	discovered: "2026-02-20"
	implication: "CSS variables (--body, --mono) reduce the surface to one place per file. But shared stylesheets or a build step that injects common CSS would be better for sites with >3 pages."
}

i010: core.#Insight & {
	id:         "INSIGHT-010"
	statement:  "The specs-registry.cue is the single source of truth for all W3C coverage surfaces"
	evidence: [
		"site/build.cue projects registry into specs.json and spec-counts.json",
		"ReSpec spec consumes the same data",
		"Landing page W3C table must manually mirror the registry (no dynamic rendering)",
		"Adding a 13th spec: write pattern, add registry entry, rebuild — everything updates",
	]
	method:     "cross_reference"
	confidence: "high"
	discovered: "2026-02-20"
	implication: "The landing page HTML table is the only surface that requires manual sync with the registry. A build step that generates the table from specs.json would eliminate the last manual dependency."
}
