# apercue.ca

Compile-time W3C linked data from typed dependency graphs.

CUE comprehensions precompute all queries. CUE unification enforces all shapes.
Every W3C artifact --- JSON-LD, SHACL, SKOS, OWL-Time --- is a zero-cost
projection of the same typed graph. No triplestore. No SPARQL. No runtime validators.
Just `cue export`.

**Live:** [apercue.ca](https://apercue.ca) | [GC Governance Demo](https://apercue.ca/gc-governance.html) | [Recipe Demo](https://apercue.ca/recipe.html) | [GitHub](https://github.com/quicue/apercue)

## Quick Start

```bash
# Clone and explore
git clone https://github.com/quicue/apercue
cd apercue

# Run any example
cue eval ./examples/course-prereqs/ -e summary
cue export ./examples/course-prereqs/ -e gaps.shacl_report --out json
cue export ./examples/course-prereqs/ -e cpm.time_report --out json

# Use in your own project
mkdir myproject && cd myproject
cue mod init example.com/myproject@v0
mkdir -p cue.mod/pkg
ln -s ~/apercue cue.mod/pkg/apercue.ca
```

**What comes out** --- from the same graph, different `-e` expressions produce different W3C standards:

```bash
cue eval ./examples/course-prereqs/ -e summary
```
```
degree:          "bsc-computer-science"
total_courses:   12
graph_valid:     true
degree_complete: true
scheduling: {
    total_duration:  14
    critical_count:  4
}
```

```bash
cue export ./examples/course-prereqs/ -e gaps.shacl_report --out json
```
```json
{
  "@type": "sh:ValidationReport",
  "sh:conforms": true,
  "dcterms:conformsTo": {"@id": "charter:bsc-computer-science"}
}
```

The input is 12 courses with `name`, `@type`, and `depends_on`. The same data produces SHACL validation, OWL-Time scheduling, SKOS type taxonomies, and EARL test assertions. See the [pattern API reference](docs/pattern-api.md) for all W3C projection details.

## Module Structure

```
apercue.ca@v0
├── vocab/                  # Core types
│   ├── resource.cue        #   #Resource — generic typed node
│   ├── types.cue           #   #TypeRegistry — extensible type system
│   ├── context.cue         #   JSON-LD @context (19 W3C namespaces)
│   └── viz-contract.cue    #   #VizData for D3/visualization
├── patterns/               # Graph analysis + W3C projections
│   ├── graph.cue           #   #Graph — dependency graph engine (30+ patterns)
│   ├── analysis.cue        #   #CriticalPath, #CycleDetector, #ConnectedComponents, #GraphDiff
│   ├── validation.cue      #   #ComplianceCheck → sh:ValidationReport
│   ├── lifecycle.cue       #   #BootstrapPlan, #DriftReport, #SmokeTest → SKOS, EARL
│   ├── provenance.cue      #   #ProvenanceTrace → prov:Entity, prov:wasDerivedFrom
│   ├── policy.cue          #   #ODRLPolicy → odrl:Set, odrl:Permission
│   ├── credentials.cue     #   #ValidationCredential → VerifiableCredential
│   ├── activity.cue        #   #ActivityStream → as:OrderedCollection
│   ├── catalog.cue         #   #DCATCatalog → dcat:Catalog, dcat:Dataset
│   ├── federation.cue      #   #FederatedContext, #FederatedMerge — multi-domain merge
│   ├── schema_alignment.cue #  #SchemaOrgAlignment → schema:additionalType
│   ├── type-contracts.cue  #   #ApplyTypeContracts, #ValidateTypes
│   └── visualization.cue   #   Graphviz DOT, Mermaid, dependency matrix
├── charter/                # Constraint-first planning
│   └── charter.cue         #   #Charter, #GapAnalysis → sh:ValidationReport, #Milestone
├── views/                  # Vocabulary projections
│   ├── skos.cue            #   #TypeVocabulary → skos:ConceptScheme
│   └── org.cue             #   #OrgChart → org:Organization, org:OrganizationalUnit
├── w3c/                    # Spec coverage index
│   └── README.md
├── examples/
│   ├── course-prereqs/     # University prerequisites (12 courses, 3 gates)
│   ├── recipe-ingredients/ # Beef bourguignon (17 steps, critical path)
│   ├── project-tracker/    # Software release (10 tasks, status tracking)
│   ├── supply-chain/       # Laptop assembly (14 parts, 5 tiers)
│   └── gc-llm-governance/  # GC LLM governance (52 nodes, ODRL policies, DCAT catalog)
├── self-charter/           # Ecosystem graph — models the project itself
│   ├── ecosystem.cue       #   10 modules/instances/services as typed resources
│   ├── charter.cue         #   4-gate charter for ecosystem completeness
│   └── export.cue          #   D3 visualization export
├── site/                   # Static site (deployed to apercue.ca via CF Pages)
│   ├── index.html          #   Landing page
│   ├── explorer.html       #   D3 ecosystem graph explorer
│   ├── playground.html     #   Interactive W3C projection playground (6 projections)
│   └── data/               #   Pre-computed JSON from cue export
├── tests/                  # Validation test suites
│   ├── federation/         #   Multi-domain merge tests (2 domains, 5 resources)
│   └── unicode-rejection/  #   SafeID / SafeLabel constraint tests
└── docs/
    ├── getting-started.md  # Standalone walkthrough — empty project to W3C exports
    ├── pattern-api.md      # Field-level reference for all 75 pattern types
    ├── api-stability.md    # Stable vs experimental classification
    ├── adapters.md         # Downstream module guide + creating adapters
    └── novelty.md          # What is novel (academic, practitioner, executive tones)
```

## W3C Spec Coverage

| Spec | CUE Pattern | Status |
|------|-------------|--------|
| JSON-LD 1.1 | `vocab/context.cue` --- @context, @type, @id | Implemented |
| SHACL | `validation.cue`, `charter.cue` --- sh:ValidationReport | Implemented |
| SKOS | `views/skos.cue`, `lifecycle.cue` --- skos:ConceptScheme | Implemented |
| EARL | `lifecycle.cue` --- earl:Assertion test plans | Implemented |
| OWL-Time | `analysis.cue` --- time:Interval scheduling | Implemented |
| Dublin Core | `vocab/context.cue` --- dcterms:requires (every edge), dcterms:title, dcterms:conformsTo | Implemented |
| PROV-O | `provenance.cue` --- prov:Entity, prov:wasDerivedFrom derivation chains | Implemented |
| ODRL 2.2 | `policy.cue` --- odrl:Policy, odrl:Permission, odrl:Prohibition | Implemented |
| ORG | `views/org.cue` --- org:Organization, org:OrganizationalUnit by @type | Implemented |
| schema.org | `schema_alignment.cue` --- schema:additionalType mapping | Implemented |
| VC 2.0 | `credentials.cue` --- VerifiableCredential wrapping SHACL reports | Implemented |
| DCAT 3 | `catalog.cue` --- dcat:Catalog, dcat:Dataset per resource | Implemented |
| Activity Streams 2.0 | `activity.cue` --- as:OrderedCollection of graph construction | Implemented |
| VoID | `void.cue` --- void:Dataset with class/property partitions, linkset statistics | Implemented |
| DQV | `quality.cue` --- dqv:QualityMeasurement for completeness, consistency, accessibility | Implemented |
| Web Annotation | `annotation.cue` --- oa:Annotation with TextualBody and W3C motivations | Implemented |
| RDFS/OWL | `ontology.cue` --- rdfs:Class, owl:ObjectProperty from graph type hierarchy | Implemented |
| Hydra Core | Downstream: quicue.ca operator dashboard | Downstream |

See [w3c/README.md](w3c/README.md) for full mapping details.

## Examples

Each example is a complete, working graph. Run any of them with `cue export`.

| Example | Domain | Nodes | Demonstrates |
|---------|--------|-------|-------------|
| [course-prereqs](examples/course-prereqs/) | University curriculum | 12 courses | Charter with 3 gates, SHACL gap analysis, OWL-Time scheduling |
| [recipe-ingredients](examples/recipe-ingredients/) | Cooking | 17 steps | Critical path analysis, topological layering |
| [project-tracker](examples/project-tracker/) | Software release | 10 tasks | Status tracking, milestone evaluation |
| [supply-chain](examples/supply-chain/) | Manufacturing | 14 parts | 5-tier dependency depth, compliance checks |
| [gc-llm-governance](examples/gc-llm-governance/) | GC AI governance | 52 nodes | ODRL policies, DCAT catalog, compliance rules, fact registry |
| [self-charter](self-charter/) | Meta — apercue itself | 12 modules | The project models its own development: 4 gates, CPM scheduling, [live visualization](https://apercue.ca/charter.html) |

```bash
# SHACL validation report
cue export ./examples/course-prereqs/ -e gaps.shacl_report --out json

# OWL-Time critical path schedule
cue export ./examples/course-prereqs/ -e cpm.time_report --out json

# Charter gap analysis
cue export ./examples/project-tracker/ -e gaps --out json

# Supply-chain critical sequence
cue export ./examples/supply-chain/ -e cpm.critical_sequence --out json
```

All output is valid W3C linked data — feed it to any JSON-LD processor.

## Self-Charter

apercue models its own development as a typed dependency graph. The
[self-charter](self-charter/) defines 10 ecosystem components (modules,
instances, services) with 4 gates tracking maturity from foundation through
full ecosystem. CPM scheduling computes the critical path. Gap analysis
reports what remains.

```bash
cue eval ./self-charter/ -e ecosystem.summary
cue eval ./self-charter/ -e ecosystem.gaps.complete
```

Live visualization: [apercue.ca/charter.html](https://apercue.ca/charter.html)

This is the proof that the framework works: the project that defines charter
patterns uses those same patterns to track itself.

## How Is This Different?

**Traditional semantic web:**
```
Data → RDF Triplestore → SPARQL Queries → SHACL Validator → JSON-LD Serializer
5 runtime components, 5 failure points, 5 things to deploy and monitor
```

**apercue.ca:**
```
Data → cue export -e <projection>
1 binary, 0 servers, compile-time guarantees
```

CUE's constraint lattice subsumes both graph query (SPARQL) and shape validation
(SHACL) into a single evaluation model. If `cue vet` passes, the data is valid
and every W3C projection will conform.

## Documentation

- [Getting Started](docs/getting-started.md) --- standalone walkthrough from empty project to W3C exports
- [Pattern API Reference](docs/pattern-api.md) --- field-level reference for all 75 pattern types
- [API Stability](docs/api-stability.md) --- stable vs experimental type classification
- [Adapters](docs/adapters.md) --- downstream module guide + creating your own adapter
- [ARCHITECTURE.md](ARCHITECTURE.md) --- design principles, data flow, module layers
- [CONTRIBUTING.md](CONTRIBUTING.md) --- development setup, testing, PR process

## W3C Community Group Engagement

The graph output is valid JSON-LD conforming to W3C specifications. This has been submitted as use cases to several W3C Community Groups:

- **[KG-Construct](https://www.w3.org/community/kg-construct/)** — CUE as a declarative KG construction language ([use cases — merged](https://github.com/kg-construct/use-cases/pull/21))
- **[Dataspaces](https://www.w3.org/community/dataspaces/)** — Compile-time data governance as a lightweight dataspace primitive ([challenge](https://github.com/w3c-cg/dataspaces/issues/17))
- **[Context Graphs](https://www.w3.org/community/context-graph/)** — Multi-context resource identity via struct-as-set types
- **[Physical Asset Attestation (UORA)](https://www.w3.org/community/uora/)** — Asset lifecycle attestation via typed dependency graphs

Submission-ready files: [w3c/submissions/](w3c/submissions/)

## Downstream

- **[quicue.ca](https://quicue.ca)** --- Infrastructure-specific patterns (40+ types, 29 providers). Imports apercue for generic graph/charter patterns.
- **[cmhc-retrofit](https://cmhc-retrofit.quicue.ca)** --- CMHC housing retrofit graphs
- **[kg.quicue.ca](https://kg.quicue.ca)** --- Knowledge graph framework

See [Adapters](docs/adapters.md) for how these modules import apercue and how to create your own.

## License

Apache 2.0
