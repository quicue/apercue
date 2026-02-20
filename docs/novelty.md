# What Is Novel About apercue.ca

## 1. Academic Tone

### Compile-Time Linked Data: Subsumption of Graph Query and Shape Validation via Constraint-Based Evaluation

The semantic web stack traditionally separates concerns into distinct runtime layers: RDF serialization, SPARQL query evaluation, and SHACL/ShEx shape validation. Each layer introduces its own execution model, failure modes, and infrastructure requirements. This paper presents an alternative architecture in which all three concerns are subsumed by a single constraint-based evaluation framework.

The apercue module implements a typed dependency graph in CUE, a constraint-based configuration language whose evaluation semantics are rooted in lattice theory and unification. Resources are declared as typed nodes (`#Resource`) with set-valued dependency edges (`depends_on: {[string]: true}`). CUE comprehensions --- deterministic set-builder expressions evaluated at compile time --- compute transitive closures, topological orderings, critical paths, and connected components without runtime execution.

The key theoretical contribution is the observation that CUE unification simultaneously performs the work of both SPARQL graph pattern matching and SHACL constraint validation. A comprehension like `for rname, r in Graph.resources if r._ancestors[Target] != _|_ {(rname): true}` is functionally equivalent to a SPARQL property path query, but is evaluated statically by the CUE evaluator with full type safety. Similarly, structural rules expressed via `#ComplianceCheck` produce `sh:ValidationReport` documents that conform to the W3C SHACL Recommendation (2017-07-20), but the validation itself occurs at compile time through CUE's native constraint resolution rather than through a separate SHACL processor operating on an RDF graph.

The module produces valid JSON-LD (with proper `@context`, `@type`, and `@id` annotations), SKOS ConceptSchemes, OWL-Time intervals, EARL test plan assertions, and DCAT-compatible catalogue metadata --- all as zero-cost projections of the same underlying graph. No triplestore is required. No SPARQL endpoint is deployed. The `cue export` command is the only runtime.

This approach is limited to DAGs and to graphs that fit within CUE's evaluation budget. It does not replace general-purpose RDF stores for open-world reasoning or federation across organizational boundaries. What it demonstrates is that for closed-world, schema-controlled dependency graphs --- infrastructure, curricula, supply chains, project plans --- the constraint lattice is a sufficient and more parsimonious computational model.

## 2. Practitioner Tone

### You Don't Need a Triplestore to Ship W3C-Compliant Linked Data

I built a CUE module that turns typed dependency graphs into JSON-LD, SHACL reports, SKOS vocabularies, and OWL-Time intervals. No triplestore. No SPARQL. No runtime validators. Just `cue export`.

**The before:** You model your data, then load it into an RDF store, then write SPARQL queries to extract views, then run a SHACL processor to validate shapes, then serialize the results. Four moving parts, four places things break at 2 AM.

**The after:** You declare resources with `@type` and `depends_on`. CUE comprehensions compute everything --- depth, ancestors, critical path, compliance violations --- at eval time. The W3C artifacts are projections: `cue export -e compliance.shacl_report --out json` gives you a valid `sh:ValidationReport`. `cue export -e cpm.time_report --out json` gives you OWL-Time intervals. Same graph, different `cue export -e` expression, zero additional infrastructure.

The pattern works for any domain. The repo includes four non-infrastructure examples: university course prerequisites (12 courses, charter gates for degree completion), a beef bourguignon recipe (17 steps, critical path through the braise), a project task tracker (10 tasks with status-based progress), and a laptop supply chain (15 parts across 5 tiers, lead-time CPM analysis). All four use the same `#Graph`, `#Charter`, `#ComplianceCheck`, and `#CriticalPath` patterns. All four produce valid SHACL reports.

The trick is CUE's `struct-as-set` pattern: `"@type": {Database: true, Monitored: true}` gives you O(1) type membership checks and clean unification when composing constraints. Dependencies work the same way. The entire graph engine (`#Graph`) is one file that computes depth, ancestors, topology layers, roots, leaves, and pre-indexed dependents --- all through comprehensions that resolve during `cue vet`.

If you are already using CUE for configuration, you are one import away from W3C-compliant linked data. If you are not using CUE, the four examples show that the pattern applies well beyond infrastructure.

## 3. Executive Tone

### Compile-Time Standards Compliance With No New Infrastructure

apercue.ca delivers W3C-standards-compliant data artifacts --- the kind required for audit trails, procurement documentation, and interoperability mandates --- without deploying any new infrastructure. There is no database to maintain, no API server to secure, and no runtime validation service to monitor.

**What it does:** Teams declare their resources (assets, requirements, deliverables) and their dependencies in structured files. The toolchain computes all derived views --- gap analyses, compliance reports, critical path schedules, risk assessments --- at build time. The outputs conform to W3C SHACL, SKOS, OWL-Time, and JSON-LD standards. If the build passes, the data is valid. If it does not pass, the constraint violation is reported before anything is deployed.

**What it eliminates:** Runtime validation failures in production. Schema drift between systems that exchange data. Manual compliance report generation. The "it worked on my machine" class of data quality issues.

**What it costs:** Zero new servers. Zero new licences. The toolchain is a single open-source binary (`cue`). Integration into existing CI/CD pipelines is one command: `cue vet ./...`. The four included examples (academic curricula, project tracking, supply chain management, recipe workflows) demonstrate that the approach is domain-agnostic and can be adopted incrementally.

Standards compliance is not a feature bolted on after the fact. It is a structural property of the data model. When `cue vet` passes, the SHACL report will show `sh:conforms: true`. That guarantee holds at build time, every time, without human review of the output.
