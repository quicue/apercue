# apercue.ca

Compile-time W3C linked data from typed dependency graphs.

One typed CUE value, many W3C projections. JSON-LD, SHACL, SKOS, OWL-Time and
the rest are all derived from the same graph, with no second copy of the schema.
For graphs past a few dozen nodes the dependency closure is precomputed by `tools/toposort.py` and CUE verifies and projects it.
No triplestore or server is needed.

**Live:** [apercue.ca](https://apercue.ca/projections.html) | [Recipe Demo](https://apercue.ca/recipe.html) | [GitHub](https://github.com/quicue/apercue)

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

## Commands

```bash
cue cmd build          # Build all site data from CUE exports
cue cmd build-public   # Build and stage public site for CF Pages
cue cmd deploy         # Precompute topology, validate, build
cue cmd serve          # Local preview server (port 8384, -t port=N)
cue cmd validate       # Verify documentation counts match data
cue cmd vet-all        # Full cross-package validation
cue cmd gap-analysis   # Export SHACL gap analysis report
cue cmd critical-path  # Export CPM critical path summary
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
│   ├── resource.cue        #   #Resource: generic typed node
│   ├── types.cue           #   #TypeRegistry: extensible type system
│   ├── context.cue         #   JSON-LD @context (24 W3C namespaces)
│   ├── context_event.cue   #   #ContextEvent; federation boundary crossing type
│   └── viz-contract.cue    #   #VizData for D3/visualization
├── patterns/               # Graph analysis + W3C projections (22 files, 79 definitions)
│   ├── graph.cue           #   #Graph; dependency graph engine
│   ├── analysis.cue        #   #CriticalPath, #CycleDetector, #ConnectedComponents, #GraphDiff
│   ├── validation.cue      #   #ComplianceCheck → sh:ValidationReport
│   ├── lifecycle.cue       #   #BootstrapPlan, #DriftReport, #SmokeTest → SKOS, EARL
│   ├── provenance.cue      #   #ProvenanceTrace → prov:Entity, Generation, SoftwareAgent
│   ├── provenance_plan.cue #   #ProvenancePlan → prov:Plan from charters
│   ├── policy.cue          #   #ODRLPolicy → odrl:Set, odrl:Permission
│   ├── credentials.cue     #   #ValidationCredential → VerifiableCredential
│   ├── activity.cue        #   #ActivityStream → as:OrderedCollection
│   ├── catalog.cue         #   #DCATCatalog → dcat:Catalog, dcat:Dataset
│   ├── void.cue            #   #VoIDDataset → void:Dataset with class/property partitions
│   ├── ontology.cue        #   #OWLOntology → rdfs:Class, owl:ObjectProperty
│   ├── taxonomy.cue        #   #SKOSTaxonomy → skos:ConceptScheme with broader/narrower
│   ├── annotation.cue      #   #AnnotationCollection → oa:Annotation with motivations
│   ├── quality.cue         #   #DataQualityReport → dqv:QualityMeasurement
│   ├── shapes.cue          #   #SHACLShapes → sh:NodeShape descriptions
│   ├── federation.cue      #   #FederatedContext, #FederatedMerge; multi-domain merge
│   ├── context_event.cue   #   #ContextEventLog → prov:Activity + time:Instant audit trail
│   ├── form.cue            #   #FormProjection → UI form definitions from #TypeRegistry
│   ├── schema_alignment.cue #  #SchemaOrgAlignment → schema:additionalType
│   ├── type-contracts.cue  #   #ApplyTypeContracts, #ValidateTypes
│   └── visualization.cue   #   Graphviz DOT, Mermaid, dependency matrix
├── charter/                # Constraint-first planning
│   └── charter.cue         #   #Charter, #GapAnalysis → sh:ValidationReport, #Milestone
├── views/                  # Vocabulary projections
│   ├── skos.cue            #   #TypeVocabulary → skos:ConceptScheme
│   └── org.cue             #   #OrgChart → org:Organization, org:OrganizationalUnit
├── tools/                  # Workflow command schemas (importable by downstream)
│   ├── build.cue           #   #BuildSpec, #ExportSpec, #StagingSpec
│   ├── deploy.cue          #   #DeploySpec (toposort → vet → build pipeline)
│   └── validate.cue        #   #ValidateSpec, #AnalysisExport
├── w3c/                    # Spec coverage index
│   └── README.md
├── examples/
│   ├── course-prereqs/     # University prerequisites (12 courses, 3 gates)
│   ├── recipe-ingredients/ # Beef bourguignon (17 steps, critical path)
│   ├── project-tracker/    # Software release (10 tasks, status tracking)
│   └── supply-chain/       # Laptop assembly (14 parts, 5 tiers)
├── self-charter/           # Ecosystem graph; models the project itself
│   ├── ecosystem.cue       #   Ecosystem graph: 10 nodes, 4 gates
│   ├── charter.cue         #   Build charter: 41 tasks, 8 phases, all gates satisfied
│   └── export.cue          #   D3 visualization export
├── site/                   # Static site (deployed to apercue.ca via CF Pages)
│   ├── index.html          #   Landing page
│   ├── explorer.html       #   D3 ecosystem graph explorer
│   ├── playground.html     #   Interactive W3C projection playground
│   └── data/               #   Pre-computed JSON from cue export
├── tests/                  # Validation test suites
│   ├── federation/         #   Multi-domain merge tests (2 domains, 5 resources)
│   └── unicode-rejection/  #   SafeID / SafeLabel constraint tests
└── docs/
    ├── getting-started.md  # Standalone walkthrough; empty project to W3C exports
    ├── pattern-api.md      # Field-level reference for all 79 pattern types
    ├── api-stability.md    # Stable vs experimental classification
    ├── adapters.md         # Downstream module guide + creating adapters
    └── novelty.md          # What is novel (academic, practitioner, executive tones)
```

## W3C Spec Coverage

| Spec | CUE Pattern | Depth | Status |
|------|-------------|-------|--------|
| JSON-LD 1.1 | `vocab/context.cue` --- @context, @type, @id, namespace federation | full | Implemented |
| SHACL | `validation.cue`, `charter.cue` --- conformant sh:ValidationReport + sh:NodeShape | full | Implemented |
| SKOS | `views/skos.cue`, `taxonomy.cue` --- skos:ConceptScheme with broader/narrower | full | Implemented |
| EARL | `lifecycle.cue` --- earl:Assertion structure; every outcome is earl:untested (a test plan, not results) | partial | Projection |
| OWL-Time | `analysis.cue`, `context_event.cue` --- time:Interval from critical path; time:Instant on federation events | full | Implemented |
| PROV-O | `provenance.cue`, `context_event.cue` --- prov:Entity, Activity, Agent, Generation, Plan; prov:Collection event log for federation | full | Implemented |
| VoID | `void.cue` --- void:Dataset with class/property partitions, linkset statistics | full | Implemented |
| DCAT 3 | `catalog.cue` --- dcat:Catalog, Dataset, Distribution, DataService | full | Implemented |
| DQV | `quality.cue` --- dqv:QualityMeasurement for completeness, consistency, accessibility | full | Implemented |
| ODRL 2.2 | `policy.cue` --- odrl:Set permission/prohibition matrix by resource type | partial | Implemented |
| Activity Streams 2.0 | `activity.cue` --- as:OrderedCollection of Create activities | partial | Implemented |
| Web Annotation | `annotation.cue` --- oa:Annotation with TextualBody and W3C motivations | partial | Implemented |
| W3C Org | `views/org.cue` --- org:Organization with type-based OrganizationalUnits | partial | Implemented |
| RDFS | `ontology.cue` --- rdfs:Class, rdfs:subClassOf, rdfs:domain/range | partial | Implemented |
| Dublin Core (DCMI, not W3C) | `vocab/context.cue` --- dcterms:title, dcterms:description, dcterms:requires | vocabulary | Implemented |
| schema.org (not W3C) | `schema_alignment.cue` --- schema:additionalType mapping | vocabulary | Implemented |
| VC 2.0 | `credentials.cue` --- unsigned credential shape (v2 context) wrapping a SHACL report; no proof | structural | Projection |
| Hydra Core | quicue.ca operator dashboard | partial | Downstream |

**Depth key:** full = the spec's core classes and properties are emitted and the output parses in rdflib with the expected types (`tools/validate-w3c.py`; SHACL shapes and reports are also checked against pyshacl in `tests/rdf/`); partial = core terms, missing advanced features; vocabulary = namespace terms in @context; structural = spec-shaped JSON-LD, key features out of scope.

**Status key:** Implemented = counted; Projection = emitted in the spec's shape but not claimed (EARL has no real outcomes, VC has no proof). Headline counts include W3C specifications only: Dublin Core and schema.org are listed but not counted.

See [w3c/README.md](w3c/README.md) for full mapping details.

## Examples

Each example is a complete, working graph. Run any of them with `cue export`.

| Example | Domain | Nodes | Demonstrates |
|---------|--------|-------|-------------|
| [course-prereqs](examples/course-prereqs/) | University curriculum | 12 courses | Charter with 3 gates, SHACL gap analysis, OWL-Time scheduling |
| [recipe-ingredients](examples/recipe-ingredients/) | Cooking | 17 steps | Critical path analysis, topological layering |
| [project-tracker](examples/project-tracker/) | Software release | 10 tasks | Status tracking, milestone evaluation |
| [supply-chain](examples/supply-chain/) | Manufacturing | 14 parts | 5-tier dependency depth, compliance checks |
| [self-charter](self-charter/) | Meta: apercue itself | 41 tasks (build charter) + 10 nodes (ecosystem) | The project models its own development: 8 phases, all gates satisfied, federation event log, [live visualization](https://apercue.ca/projections.html) |

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

All output is JSON-LD; feed it to any JSON-LD processor.

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

Live visualization: [apercue.ca/projections.html](https://apercue.ca/projections.html)

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
cue (plus tools/toposort.py for large graphs), 0 servers
```

There are two failure regimes. Structural errors in the input (a dependency on
an undeclared resource, an invalid identifier) make `cue vet` fail. Compliance
rule violations and charter gaps do not by default: they appear in the SHACL
report as `sh:conforms: false` while `cue vet` still passes. Set `Enforce: true`
on `#ComplianceCheck` (critical failures) or `#GapAnalysis` (incomplete charter)
to make them fail the build. Without it, a passing `cue vet` does not mean every
projection conforms.

## Documentation

- [Getting Started](docs/getting-started.md) --- standalone walkthrough from empty project to W3C exports
- [Pattern API Reference](docs/pattern-api.md) --- field-level reference for all 79 pattern types
- [API Stability](docs/api-stability.md) --- stable vs experimental type classification
- [Adapters](docs/adapters.md) --- downstream module guide + creating your own adapter
- [ARCHITECTURE.md](ARCHITECTURE.md) --- design principles, data flow, module layers
- [CONTRIBUTING.md](CONTRIBUTING.md) --- development setup, testing, PR process

## W3C Community Group Engagement

Two W3C Community Groups have a public artifact from this project:

- **[KG-Construct](https://www.w3.org/community/kg-construct/)**: use cases contributed to the KG-Construct CG ([PR #21](https://github.com/kg-construct/use-cases/pull/21), merged 2026-02-27).
- **[Dataspaces](https://www.w3.org/community/dataspaces/)**: challenge filed as [w3c-cg/dataspaces#17](https://github.com/w3c-cg/dataspaces/issues/17) (open).

Drafted, with no public artifact:

- **[Context Graphs](https://www.w3.org/community/context-graph/)**: use case submitted to the chair and mailing list, 2026-03. It does not appear in the public list archive.
- **PM-KR** and **UORA**: drafted, not submitted.

Submission-ready files: [w3c/submissions/](w3c/submissions/)

## Downstream

- **[quicue.ca](https://quicue.ca)** --- Infrastructure-specific patterns (40+ types, 33 providers). Imports apercue for generic graph/charter patterns.
- **[cmhc-retrofit](https://cmhc-retrofit.quicue.ca)** --- CMHC housing retrofit graphs
- **[kg.quicue.ca](https://kg.quicue.ca)** --- Knowledge graph framework

See [Adapters](docs/adapters.md) for how these modules import apercue and how to create your own.

## License

Apache 2.0
