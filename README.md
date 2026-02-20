# apercue.ca

Compile-time W3C linked data from typed dependency graphs.

CUE comprehensions precompute all queries. CUE unification enforces all shapes.
Every W3C artifact --- JSON-LD, SHACL, DCAT, SKOS, OWL-Time --- is a zero-cost
projection of the same typed graph. No triplestore. No SPARQL. No runtime validators.
Just `cue export`.

## Quick Start

```bash
# In your CUE module
mkdir myproject && cd myproject
cue mod init example.com/myproject@v0

# Add apercue.ca as a dependency (symlink for local dev)
mkdir -p cue.mod/pkg
ln -s ~/apercue cue.mod/pkg/apercue.ca

# Define resources and run analysis
cue eval . -e summary
cue export . -e gaps.shacl_report --out json
cue export . -e cpm.time_report --out json
```

## Module Structure

```
apercue.ca@v0
├── vocab/              # Core types
│   ├── resource.cue    #   #Resource — generic typed node
│   ├── types.cue       #   #TypeRegistry — extensible type system
│   ├── context.cue     #   JSON-LD @context (13 W3C namespaces)
│   └── viz-contract.cue#   #VizData for D3/visualization
├── patterns/           # Graph analysis
│   ├── graph.cue       #   #Graph — universal dependency graph engine
│   ├── analysis.cue    #   #CriticalPath, #CycleDetector, #ConnectedComponents, #Subgraph, #GraphDiff
│   ├── validation.cue  #   #ComplianceCheck → sh:ValidationReport
│   ├── lifecycle.cue   #   #BootstrapPlan, #DriftReport, #SmokeTest → SKOS, EARL
│   ├── type-contracts.cue  # #ApplyTypeContracts, #ValidateTypes
│   └── visualization.cue  # Graphviz DOT, Mermaid, dependency matrix
├── charter/            # Constraint-first planning
│   └── charter.cue     #   #Charter, #GapAnalysis → sh:ValidationReport, #Milestone
├── views/              # Vocabulary projections
│   └── skos.cue        #   #TypeVocabulary → skos:ConceptScheme
├── w3c/                # Spec coverage index
│   └── README.md
├── examples/
│   ├── course-prereqs/     # University prerequisites (12 courses, 3 charter gates)
│   ├── recipe-ingredients/ # Beef bourguignon (17 steps, critical path)
│   ├── project-tracker/    # Software release (10 tasks, status tracking)
│   └── supply-chain/       # Laptop assembly (15 parts, 5 tiers)
└── docs/
    └── novelty.md          # What is novel (academic, practitioner, executive tones)
```

## W3C Spec Coverage

| Spec | Pattern | Status |
|------|---------|--------|
| JSON-LD 1.1 | `@context`, `@type`, `@id` | Implemented |
| SHACL | `sh:ValidationReport` | Implemented |
| SKOS | `skos:ConceptScheme` | Implemented |
| EARL | `earl:Assertion` | Implemented |
| OWL-Time | `time:Interval` | Implemented |
| Dublin Core | `dcterms:requires` | Implemented |
| PROV-O | `prov:wasDerivedFrom` | Namespace |
| schema.org | `schema:actionStatus` | Namespace |
| DCAT 3 | `dcat:Catalog` | Planned |
| ODRL 2.2 | `odrl:Policy` | Planned |
| Hydra Core | `hydra:ApiDocumentation` | Planned |

See [w3c/README.md](w3c/README.md) for full mapping details.

## How Is This Different?

**Traditional semantic web:**
```
Data → RDF Triplestore → SPARQL Queries → SHACL Validator → JSON-LD Serializer
4 runtime components, 4 failure points, 4 things to deploy and monitor
```

**apercue.ca:**
```
Data → cue export -e <projection>
1 binary, 0 servers, compile-time guarantees
```

CUE's constraint lattice subsumes both graph query (SPARQL) and shape validation
(SHACL) into a single evaluation model. If `cue vet` passes, the data is valid
and every W3C projection will conform.

## License

Apache 2.0
