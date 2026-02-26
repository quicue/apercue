# API Stability

Classification of public types by stability level. Stable types will not have
breaking changes within the `@v0` major version. Experimental types may change.

## Stable

These types have proven interfaces used by multiple examples and downstream
projects. Field names, constraints, and output shapes are fixed.

### vocab/
| Type | Since | Notes |
|------|-------|-------|
| `#Resource` | v0.1 | Universal node type |
| `#SafeID` | v0.1 | ASCII identifier constraint |
| `#SafeLabel` | v0.1 | Type/tag name constraint |
| `#TypeRegistry` | v0.1 | Domain vocabulary |
| `context` | v0.1 | JSON-LD @context template |

### patterns/
| Type | Since | Notes |
|------|-------|-------|
| `#AnalyzableGraph` | v0.3 | Canonical graph interface |
| `#Graph` | v0.1 | Full recursive graph (≤20 nodes) |
| `#GraphLite` | v0.3 | Precomputed graph (>20 nodes) |
| `#CriticalPath` | v0.2 | CPM with OWL-Time projection |
| `#CriticalPathPrecomputed` | v0.3 | CPM from Python precomputation |
| `#ComplianceCheck` | v0.2 | Structural rules → SHACL report |
| `#ComplianceRule` | v0.2 | Declarative structural rule |
| `#BlastRadius` | v0.2 | Impact analysis |
| `#DeploymentPlan` | v0.2 | Layer-by-layer startup |
| `#SinglePointsOfFailure` | v0.2 | Redundancy analysis |
| `#CycleDetector` | v0.2 | DAG validation |
| `#GraphMetrics` | v0.2 | Summary statistics |
| `#VizData` | v0.3 | D3-compatible export |

### charter/
| Type | Since | Notes |
|------|-------|-------|
| `#Charter` | v0.1 | Constraint-first planning |
| `#Gate` | v0.1 | Phase checkpoint |
| `#GapAnalysis` | v0.1 | Charter vs. graph → SHACL |

### views/
| Type | Since | Notes |
|------|-------|-------|
| `#TypeVocabulary` | v0.2 | Type registry → SKOS |

## Experimental

These types work correctly but their interfaces may evolve.

### patterns/
| Type | Since | Notes |
|------|-------|-------|
| `#FederatedContext` | v0.8 | Namespace enforcement for federation |
| `#FederatedMerge` | v0.8 | Multi-domain graph merge |
| `#ProvenanceTrace` | v0.4 | PROV-O projection |
| `#ActivityStream` | v0.4 | AS 2.0 projection |
| `#DCATCatalog` | v0.6 | DCAT 3 projection |
| `#ValidationCredential` | v0.4 | VC 2.0 wrapper |
| `#PolicyExpressionODRL` | v0.4 | ODRL projection |
| `#LifecyclePhasesSKOS` | v0.3 | Lifecycle → SKOS |
| `#BootstrapPlan` | v0.3 | Startup script generator |
| `#DriftReport` | v0.3 | Declared vs. observed |
| `#SmokeTest` | v0.3 | Check runner → EARL |
| `#ConnectedComponents` | v0.3 | Subgraph detection |
| `#Subgraph` | v0.3 | Induced subgraph extraction |
| `#GraphDiff` | v0.3 | Structural delta |
| `#CompoundRiskAnalysis` | v0.3 | Multi-target risk |
| `#ZoneAwareBlastRadius` | v0.3 | Zone-grouped impact |
| `#HealthStatus` | v0.3 | Health propagation |
| `#SchemaOrgAlignment` | v0.4 | schema.org mappings |
| `#OrgChart` | v0.4 | W3C Org projection |

## Publishing

The module is `apercue.ca@v0` with `source: kind: "self"` (no external
dependencies for core packages). To use apercue in your project:

**Current (symlink):**
```bash
mkdir -p cue.mod/pkg
ln -s /path/to/apercue cue.mod/pkg/apercue.ca
```

**Future (OCI registry):**
```bash
cue mod get apercue.ca@v0
```

OCI registry publishing requires CUE v0.16+ and a registry endpoint.
The module structure is already compatible — no changes needed when
the registry becomes available.
