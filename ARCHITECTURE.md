# Architecture

apercue is a compile-time semantic web framework. Resources with typed
dependencies form a graph; CUE constraints enforce structural invariants;
projections emit standard W3C vocabularies. No runtime engine, no triplestore,
no SPARQL — the constraint lattice IS the query engine.

This document covers design principles, data flow, and the pattern catalog.
For usage, see [README.md](README.md). For individual decisions, see
[.kb/decisions/](`.kb/decisions/decisions.cue`).

## Design Principles

**Constraints over generators.** A CUE definition like `#Resource` doesn't
generate data — it constrains it. You write `graph: patterns.#Graph & {Input: _steps}`
and CUE unifies your data against the constraint lattice. If your graph has a
cycle, a dangling reference, or a missing type, evaluation fails. This is the
semantic web's "open world assumption" inverted: everything not proven valid is
rejected at compile time.

**Projections over serializers.** `cue export -e gaps.shacl_report` doesn't
"convert" your data to SHACL. The SHACL report already exists as a CUE
expression — the export just selects it. One graph produces SHACL, SKOS, EARL,
PROV-O, OWL-Time, DCAT, and Activity Streams projections simultaneously. Adding
a projection costs one comprehension, zero runtime overhead.

**Struct-as-set for O(1) membership.** Dependencies, types, and tags are
`{key: true}` structs, not arrays. Checking membership is field access, not
iteration. This also enables CUE's unification: `{A: true} & {B: true}` =
`{A: true, B: true}`, which is how graph merges work.

**ASCII-safe identifiers.** All resource names match `^[a-zA-Z][a-zA-Z0-9_.-]*$`
(enforced by `#SafeID`). This prevents zero-width characters, homoglyphs, and
RTL overrides from appearing in dependency references — critical for graphs that
cross trust boundaries during federation. See ADR-004.

## Module Layers

```
vocab/        Core types (#Resource, #TypeRegistry, @context)
  │           No imports. Foundation for everything.
  │
patterns/     Graph analysis + W3C projections
  │           Imports: vocab
  │           20 files, 75 pattern definitions
  │
charter/      Constraint-first planning (#Charter, #GapAnalysis)
  │           Imports: patterns, vocab
  │
views/        Vocabulary projections (SKOS, org)
  │           Imports: vocab
  │
examples/     Domain applications (5 examples)
  │           Imports: patterns, charter
  │
self-charter/ Project models itself (41 nodes, 8 phases)
  │           Imports: patterns, charter, vocab
  │
site/         Static site data projections
  │           Imports: vocab (specs-registry)
  │
w3c/          W3C Community Group evidence
  │           Imports: patterns, vocab
  │
tools/        Python toposort, build scripts, validation
              No CUE imports (standalone)
```

Dependencies flow strictly downward. No circular imports. `vocab/` is the root;
`tools/` is a leaf that operates on CUE output, not CUE types.

## Data Flow

A resource enters the system as a CUE struct. It flows through graph
construction, constraint checking, and projection — all at `cue eval` time.

```
Raw Resources            Graph Construction         Analysis
─────────────           ──────────────────         ────────
name: "db-01"    ───►   #Graph & {Input: _}  ───►  #CriticalPath
@type: {DB: true}       computes:                   computes:
depends_on:             · topology (layers)          · earliest/latest start
  "net-01": true        · roots / leaves             · slack per resource
time_min: 30            · depth per node             · critical path (zero-slack)
                        · ancestors (transitive)     · total duration
                        · dependents (inverse)

                            │                            │
                            ▼                            ▼
                    Charter Constraints            W3C Projections
                    ──────────────────            ────────────────
                    #GapAnalysis &                 · sh:ValidationReport
                    {Charter: _, Graph: _}        · time:Interval
                    computes:                     · skos:ConceptScheme
                    · missing resources           · earl:Assertion
                    · missing types               · prov:Entity
                    · gate satisfaction            · as:OrderedCollection
                    · next gate                   · dcat:Catalog
                    · complete: bool              · vc:VerifiableCredential
```

**Example trace** (recipe-ingredients):

```bash
# 1. Validate structure (constraints catch errors at eval time)
cue vet ./examples/recipe-ingredients/

# 2. Gap analysis — are all charter gates satisfied?
cue eval ./examples/recipe-ingredients/ -e gap_summary

# 3. Critical path — minimum cook time through dependency chain
cue export ./examples/recipe-ingredients/ -e cpm.critical_sequence --out json

# 4. SHACL report — W3C-standard validation output
cue export ./examples/recipe-ingredients/ -e gaps.shacl_report --out json
```

Each command reads the same CUE source. No intermediate files, no build steps.
The projection you select with `-e` determines what subset of the constraint
lattice is materialized.

## Pattern Catalog

### Core Graph

| Pattern | File | Purpose |
|---------|------|---------|
| `#Graph` | graph.cue | Full recursive graph. Computes depth, ancestors, topology. Use for ≤20 nodes. |
| `#GraphLite` | graph.cue | Precomputed graph. Requires Python `toposort.py` output. Use for >20 nodes. |
| `#AnalyzableGraph` | graph.cue | Interface satisfied by both `#Graph` and `#GraphLite`. |

`#Graph` computes transitive closure via recursive struct references. CUE does
not memoize these — diamond DAGs cause exponential re-evaluation. For the
self-charter (41 nodes), Python precomputes depth/ancestors/dependents and
`#GraphLite` consumes the result. See ADR-007.

### Scheduling

| Pattern | File | Purpose |
|---------|------|---------|
| `#CriticalPath` | analysis.cue | CPM with forward/backward pass. OWL-Time projection. ≤20 nodes. |
| `#CriticalPathPrecomputed` | analysis.cue | CPM from Python-computed earliest/latest. >20 nodes. |

Both produce `slack`, `critical`, `critical_sequence`, `summary`, and
`time_report` (OWL-Time `time:Interval` per resource).

### Constraint Checking

| Pattern | File | Purpose |
|---------|------|---------|
| `#Charter` | charter.cue | Declare what "done" looks like: scope, gates, phases. |
| `#GapAnalysis` | charter.cue | Compare charter to graph. Produces `sh:ValidationReport`. |
| `#Gate` | charter.cue | Phase checkpoint with resource requirements. |
| `#ComplianceCheck` | validation.cue | Declarative structural rules. SHACL projection. |
| `#ComplianceRule` | validation.cue | Single rule: type selector + assertions. |

### W3C Projections

| Pattern | File | W3C Spec | Output Type |
|---------|------|----------|-------------|
| `#ComplianceCheck` | validation.cue | SHACL | `sh:ValidationReport` |
| `#GapAnalysis` | charter.cue | SHACL | `sh:ValidationReport` |
| `#CriticalPath` | analysis.cue | OWL-Time | `time:Interval` |
| `#TypeVocabulary` | views/skos.cue | SKOS | `skos:ConceptScheme` |
| `#LifecyclePhasesSKOS` | lifecycle.cue | SKOS | `skos:OrderedCollection` |
| `#ProvenanceTrace` | provenance.cue | PROV-O | `prov:Entity`, `prov:Activity` |
| `#ActivityStream` | activity.cue | AS 2.0 | `as:OrderedCollection` |
| `#ValidationCredential` | credentials.cue | VC 2.0 | `vc:VerifiableCredential` |
| `#CatalogDCAT` | catalog.cue | DCAT 3 | `dcat:Catalog`, `dcat:Dataset` |
| `#DCATDistribution` | catalog.cue | DCAT 3 | `dcat:Distribution`, `dcat:DataService` |
| `#SHACLShapes` | shapes.cue | SHACL | `sh:NodeShape`, `sh:PropertyShape` |
| `#SKOSTaxonomy` | taxonomy.cue | SKOS | `skos:broader`, `skos:narrower`, `skos:related` |
| `#PolicyExpressionODRL` | policy.cue | ODRL | `odrl:Policy` |
| `#OrgChart` | views/org.cue | W3C Org | `org:Organization` |
| `#VoIDDataset` | void.cue | VoID | `void:Dataset`, `void:Linkset` |
| `#ProvenancePlan` | provenance_plan.cue | PROV-O | `prov:Plan`, `prov:Activity` |
| `#DataQualityReport` | quality.cue | DQV | `dqv:QualityMeasurement`, `dqv:Metric` |
| `#AnnotationCollection` | annotation.cue | Web Annotation | `oa:Annotation`, `oa:TextualBody` |
| `#OWLOntology` | ontology.cue | RDFS/OWL | `rdfs:Class`, `owl:ObjectProperty` |

All projections share the same `@context` (defined in `vocab/context.cue`),
so their JSON-LD outputs merge cleanly — different graphs can be combined
by concatenating their `@graph` arrays under a shared context.

### Operational Analysis

| Pattern | File | Purpose |
|---------|------|---------|
| `#BlastRadius` | analysis.cue | Impact of a single resource failing. |
| `#ZoneAwareBlastRadius` | analysis.cue | Blast radius grouped by zone/location. |
| `#CompoundRiskAnalysis` | analysis.cue | Risk from multiple simultaneous changes. |
| `#DeploymentPlan` | analysis.cue | Layer-by-layer startup with gates. |
| `#RollbackPlan` | analysis.cue | Safe rollback if deployment fails at layer N. |
| `#SinglePointsOfFailure` | analysis.cue | Resources with no same-layer/type redundancy. |
| `#CycleDetector` | analysis.cue | Validates DAG (bounded BFS, 32-hop). |
| `#ConnectedComponents` | analysis.cue | Weakly connected subgraphs / orphans. |
| `#Subgraph` | analysis.cue | Extract induced subgraph by roots/target/radius. |
| `#GraphDiff` | analysis.cue | Structural delta between two graph versions. |

### Validation

| Pattern | File | Purpose |
|---------|------|---------|
| `#DependencyValidation` | validation.cue | All `depends_on` references exist. |
| `#TypeValidation` | validation.cue | `@type` values in allowed set. |
| `#UniqueFieldValidation` | validation.cue | No duplicate values in a field. |
| `#ReferenceValidation` | validation.cue | Forward references resolve. |
| `#RequiredFieldsValidation` | validation.cue | Mandatory fields present. |

### Federation

| Pattern | File | Purpose |
|---------|------|---------|
| `#FederatedContext` | federation.cue | Wrap a graph with non-default `@base` namespace. Produces namespaced JSON-LD. |
| `#FederatedMerge` | federation.cue | Validate and merge multiple federated contexts. Collision detection via unification. |

## Performance Model

CUE is a constraint language, not a general-purpose runtime. Three things to
know:

1. **No memoization.** Recursive struct references re-evaluate on every access.
   Wide topologies handle 60+ nodes natively. Dense diamond DAGs hit limits at
   ~35-40 nodes for full transitive closure. Solution: Python precomputes
   topology, CUE validates the precomputed result. See `tools/toposort.py`.

2. **Comprehension-level vs. body-level `if`.** A comprehension-level `if`
   filters elements out entirely. A body-level `if` produces an empty struct
   `{}` that unifies with everything — it doesn't filter, it just becomes
   invisible. This matters for correct `#ComplianceCheck` and `#GapAnalysis`
   implementations. See ADR-003.

3. **Projection cost is zero.** A CUE expression like `gaps.shacl_report`
   is lazy — it only evaluates when selected with `-e`. You can define 12
   projections and only pay for the one you export. This is why "zero-cost
   projections" is accurate, not marketing.

## Federation Model

Each domain uses a unique `@base` URI prefix in its `@context`:

```
apercue.ca      → urn:apercue:
quicue-kg       → urn:quicue-kg:
cmhc-retrofit   → urn:cmhc-retrofit:
gc-governance   → urn:gc-governance:
```

When graphs from different domains merge, their `@id` values are globally
unique because each is scoped to its domain's URN namespace. A resource
`urn:apercue:graph-engine` cannot collide with `urn:quicue-kg:graph-engine`
even though both are named `graph-engine`. See ADR-017.

`#FederatedContext` enforces non-default `@base` at the CUE type level
(`Namespace: string & !="urn:resource:"`). `#FederatedMerge` validates
multiple contexts can merge safely — namespace and `@id` collision detection
uses CUE unification (if two domains claim the same namespace, the struct
produces conflicting values and evaluation fails). See ADR-018 and
`patterns/federation.cue`.

## Build Pipeline

```
tools/toposort.py           Python precomputes graph topology + CPM
        │                   (only needed for >20-node graphs)
        ▼
self-charter/precomputed.cue   CUE-formatted precomputed data
        │
        ▼
cue vet ./...               Validates all packages
        │
        ▼
tools/build-site.sh         Orchestrates cue export → JSON
        │                   Modes: all | public | local | stage
        ▼
site/data/*.json            D3-consumable JSON artifacts
site/vocab/context.jsonld   Canonical JSON-LD context
        │
        ▼
_public/                    Staged for Cloudflare Pages (public only)
grdn network                Private dashboards (charter, explorer, projections)
```

Public site contains only framework documentation, specs, and sanitized
examples. Operational data (charter status, ecosystem graphs) stays on the
private network. See ADR-008.

## CI Pipeline

The CI workflow (`validate.yml`) runs:

1. `cue vet ./...` — all packages must validate
2. `python3 tools/validate-w3c.py` — JSON-LD round-trip conformance (67 tests)
3. README smoke test — every `cue` command in example READMEs must exit 0
4. Hardcoded path check — no absolute paths to user directories in markdown
5. Unicode rejection tests — `#SafeID` / `#SafeLabel` constraints hold

All five must pass before merge.
