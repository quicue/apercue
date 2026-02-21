# apercue.ca

Compile-time W3C linked data from typed dependency graphs.

CUE comprehensions precompute all queries. CUE unification enforces all shapes.
Every W3C artifact --- JSON-LD, SHACL, SKOS, OWL-Time --- is a zero-cost
projection of the same typed graph. No triplestore. No SPARQL. No runtime validators.
Just `cue export`.

**Live:** [apercue.ca](https://apercue.ca) | [Spec](https://apercue.ca/spec/) | [Ecosystem Explorer](https://apercue.ca/explorer.html) | [GitHub](https://github.com/quicue/apercue)

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

**What comes out** --- a SHACL validation report from one `cue export`:

```json
{
  "@type": "sh:ValidationReport",
  "sh:conforms": false,
  "dcterms:conformsTo": {"@id": "charter:v1.0-release"},
  "sh:result": [
    {
      "@type": "sh:ValidationResult",
      "sh:focusNode": {"@id": "design-api"},
      "sh:resultSeverity": {"@id": "sh:Violation"},
      "sh:resultMessage": "Required resource 'design-api' not present in graph"
    }
  ]
}
```

See the [full specification](https://apercue.ca/spec/) for all W3C projection examples.

## Module Structure

```
apercue.ca@v0
├── vocab/                  # Core types
│   ├── resource.cue        #   #Resource — generic typed node
│   ├── types.cue           #   #TypeRegistry — extensible type system
│   ├── context.cue         #   JSON-LD @context (13 W3C namespaces)
│   └── viz-contract.cue    #   #VizData for D3/visualization
├── patterns/               # Graph analysis
│   ├── graph.cue           #   #Graph — dependency graph engine (30+ patterns)
│   ├── analysis.cue        #   #CriticalPath, #CycleDetector, #ConnectedComponents, #GraphDiff
│   ├── validation.cue      #   #ComplianceCheck → sh:ValidationReport
│   ├── lifecycle.cue       #   #BootstrapPlan, #DriftReport, #SmokeTest → SKOS, EARL
│   ├── type-contracts.cue  #   #ApplyTypeContracts, #ValidateTypes
│   └── visualization.cue   #   Graphviz DOT, Mermaid, dependency matrix
├── charter/                # Constraint-first planning
│   └── charter.cue         #   #Charter, #GapAnalysis → sh:ValidationReport, #Milestone
├── views/                  # Vocabulary projections
│   └── skos.cue            #   #TypeVocabulary → skos:ConceptScheme
├── w3c/                    # Spec coverage index
│   └── README.md
├── examples/
│   ├── course-prereqs/     # University prerequisites (12 courses, 3 gates)
│   ├── recipe-ingredients/ # Beef bourguignon (17 steps, critical path)
│   ├── project-tracker/    # Software release (10 tasks, status tracking)
│   └── supply-chain/       # Laptop assembly (15 parts, 5 tiers)
├── self-charter/           # Ecosystem graph — models the project itself
│   ├── ecosystem.cue       #   12 modules/instances/services as typed resources
│   ├── charter.cue         #   4-gate charter for ecosystem completeness
│   └── export.cue          #   D3 visualization export
├── site/                   # Static site (deployed to apercue.ca via CF Pages)
│   ├── index.html          #   Landing page
│   ├── explorer.html       #   D3 ecosystem graph explorer
│   └── data/               #   Pre-computed JSON from cue export
└── docs/
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
| PROV-O | `vocab/context.cue` --- prov:wasDerivedFrom (full projections in quicue.ca) | Namespace |
| schema.org | `vocab/context.cue` --- schema:actionStatus | Namespace |
| Hydra Core | Downstream: quicue.ca operator dashboard | Downstream |

See [w3c/README.md](w3c/README.md) for full mapping details.

## Examples

Each example is a complete, working graph. Run any of them with `cue export`.

| Example | Domain | Nodes | Demonstrates |
|---------|--------|-------|-------------|
| [course-prereqs](examples/course-prereqs/) | University curriculum | 12 courses | Charter with 3 gates, SHACL gap analysis, OWL-Time scheduling |
| [recipe-ingredients](examples/recipe-ingredients/) | Cooking | 17 steps | Critical path analysis, topological layering |
| [project-tracker](examples/project-tracker/) | Software release | 10 tasks | Status tracking, milestone evaluation |
| [supply-chain](examples/supply-chain/) | Manufacturing | 15 parts | 5-tier dependency depth, compliance checks |
| [self-charter](self-charter/) | Meta — apercue itself | 12 modules | The project models its own development: 4 gates, CPM scheduling, [live visualization](https://apercue.ca/charter.html) |

```bash
# SHACL validation report
cue export ./examples/course-prereqs/ -e gaps.shacl_report --out json

# OWL-Time critical path schedule
cue export ./examples/course-prereqs/ -e cpm.time_report --out json

# Charter gap analysis
cue export ./examples/project-tracker/ -e gaps --out json

# Graphviz DOT visualization
cue export ./examples/supply-chain/ -e dot --out text
```

All output is valid W3C linked data — feed it to any JSON-LD processor.

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

## Downstream

- **[quicue.ca](https://quicue.ca)** --- Infrastructure-specific patterns (40+ types, 29 providers). Imports apercue for generic graph/charter patterns.
- **[homelab](https://github.com/quicue/homelab)** --- Homelab infrastructure instance
- **[cmhc-retrofit](https://cmhc-retrofit.quicue.ca)** --- CMHC housing retrofit graphs
- **[kg.quicue.ca](https://kg.quicue.ca)** --- Knowledge graph framework

## License

Apache 2.0
