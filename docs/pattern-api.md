# Pattern API Reference

Field-level reference for all `#` types in apercue. For design context, see
[ARCHITECTURE.md](../ARCHITECTURE.md). For usage examples, see the
[examples/](../examples/) directories.

Import paths:
```cue
import (
    "apercue.ca/patterns@v0"
    "apercue.ca/charter@v0"
    "apercue.ca/vocab@v0"
    "apercue.ca/views@v0"
)
```

---

## Core Types (vocab/)

### #Resource

Universal node type. Every resource in every graph satisfies this.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | `#SafeID` | yes | ASCII identifier |
| `@type` | `{[#SafeLabel]: true}` | yes | Semantic types (struct-as-set) |
| `@id` | `string` | no | IRI, defaults to `urn:resource:{name}` |
| `depends_on` | `{[#SafeID]: true}` | no | Dependencies (struct-as-set) |
| `description` | `string` | no | Human-readable description |
| `tags` | `{[#SafeLabel]: true}` | no | Additional tags |

Open struct — domain-specific fields (e.g., `time_min`, `credits`, `zone`) pass through.

### #SafeID

`=~ "^[a-zA-Z][a-zA-Z0-9_.-]*$"`

Prevents zero-width characters, homoglyphs, RTL overrides. Applied to all
struct keys that reference resource names.

### #SafeLabel

`=~ "^[a-zA-Z][a-zA-Z0-9_-]*$"`

For type names and tags. Slightly stricter than `#SafeID` (no dots).

### #TypeRegistry

```cue
{[#SafeLabel]: #TypeEntry}
```

Domain vocabulary. Each entry has `description`, optional `requires`, `grants`,
`structural_deps`. Used by `#TypeVocabulary` for SKOS projection.

---

## Graph Construction (patterns/)

### #Graph

Full recursive graph with transitive closure. Use for ≤20 nodes.

**Input:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `Input` | `{[#SafeID]: {...}}` | yes | Resource definitions |
| `Precomputed` | `{depth, ancestors?, dependents?}` | no | Optional Python data |

**Output:**

| Field | Type | Description |
|-------|------|-------------|
| `resources` | `{[string]: #GraphResource}` | Resources with `_depth`, `_ancestors`, `_path` |
| `topology` | `{[string]: {[string]: true}}` | `layer_0`, `layer_1`, ... |
| `roots` | `{[string]: true}` | Nodes with `_depth == 0` |
| `leaves` | `{[string]: true}` | Nodes nothing depends on |
| `dependents` | `{[string]: {[string]: true}}` | Inverse of ancestors |
| `valid` | `bool` | All dependency references exist |

### #GraphLite

Fast graph for large DAGs. Requires Python precomputation.

**Input:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `Input` | `{[#SafeID]: {...}}` | yes | Resource definitions |
| `Precomputed` | `{depth, ancestors, dependents}` | **yes** | From `toposort.py` |

**Output:** Same as `#Graph` except resources lack `_path`.

### #AnalyzableGraph

Interface both `#Graph` and `#GraphLite` satisfy. All analysis patterns
accept this, never a concrete graph type.

**Required fields:**

```cue
resources:  {[string]: {name, "@type", depends_on?, _depth, _ancestors, ...}}
topology:   {[string]: {[string]: true}}
roots:      {[string]: true}
leaves:     {[string]: true}
dependents: {[string]: {[string]: true}}
```

---

## Scheduling (patterns/)

### #CriticalPath

CPM with forward/backward pass. Produces OWL-Time projection. Use for ≤20 nodes.

**Input:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `Graph` | `#AnalyzableGraph` | yes | |
| `Weights` | `{[string]: number}` | no | Duration per resource (default 1) |
| `UnitType` | `string` | no | OWL-Time unit (default `"time:unitDay"`) |

**Output:**

| Field | Type | Description |
|-------|------|-------------|
| `slack` | `{[string]: number}` | Slack per resource |
| `critical` | `{[string]: {start, finish, duration}}` | Zero-slack resources |
| `critical_sequence` | `[{resource, start, finish, duration}, ...]` | Ordered critical path |
| `total_duration` | `number` | Project duration |
| `summary` | `{total_duration, critical_count, total_resources, max_slack}` | |
| `time_report` | JSON-LD | OWL-Time `time:Interval` per resource |

### #CriticalPathPrecomputed

CPM from Python-computed scheduling. Use for >20 nodes.

**Input:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `Graph` | `#AnalyzableGraph` | yes | |
| `Precomputed` | `{earliest, latest, duration}` | **yes** | From `toposort.py` |
| `UnitType` | `string` | no | Default `"time:unitDay"` |

**Output:** Same as `#CriticalPath`.

---

## Constraint Checking

### #Charter (charter/)

Declare what "done" looks like.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | `string` | yes | Charter name |
| `scope.total_resources` | `int` | no | Expected resource count |
| `scope.required_resources` | `{[string]: true}` | no | Named resources that must exist |
| `scope.required_types` | `{[string]: true}` | no | Types that must appear |
| `scope.min_depth` | `int` | no | Minimum graph depth |
| `gates` | `{[string]: #Gate}` | no | Phase gates |

### #Gate (charter/)

Phase checkpoint.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `phase` | `int` | no | Ordering hint |
| `requires` | `{[string]: true}` | yes | Resources that must exist |
| `depends_on` | `{[string]: true}` | no | Gates that must be satisfied first |
| `description` | `string` | no | |

### #GapAnalysis (charter/)

Compare charter constraints to actual graph.

**Input:**

| Field | Type | Required |
|-------|------|----------|
| `Charter` | `#Charter` | yes |
| `Graph` | `{resources, roots, topology, ...}` | yes |

**Output:**

| Field | Type | Description |
|-------|------|-------------|
| `missing_resources` | `{[string]: true}` | Resources in charter but not in graph |
| `missing_resource_count` | `int` | |
| `missing_types` | `{[string]: true}` | Types required but not present |
| `missing_type_count` | `int` | |
| `gate_status` | `{[string]: {missing, satisfied, ready}}` | Per-gate status |
| `unsatisfied_gates` | `{[string]: {...}}` | Gates with missing resources |
| `next_gate` | `string` | Lowest unsatisfied phase |
| `complete` | `bool` | All constraints satisfied |
| `shacl_report` | JSON-LD | `sh:ValidationReport` |

### #ComplianceRule (patterns/)

Declarative structural rule.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | `string` | yes | Rule identifier |
| `description` | `string` | no | |
| `severity` | `"warning" \| "critical" \| "info"` | no | Default `"warning"` |
| `match_types` | `{[string]: true}` | yes | Type selector |
| `requires_dependent_type` | `{[string]: true}` | no | |
| `requires_dependency_type` | `{[string]: true}` | no | |
| `must_not_be_root` | `true` | no | Resource must have dependencies |
| `must_not_be_leaf` | `true` | no | Something must depend on resource |
| `min_dependents` | `int` | no | |
| `max_depth` | `int` | no | |

### #ComplianceCheck (patterns/)

Evaluate rules against a graph.

**Input:**

| Field | Type | Required |
|-------|------|----------|
| `Graph` | `#AnalyzableGraph` | yes |
| `Rules` | `[...#ComplianceRule]` | yes |

**Output:**

| Field | Type | Description |
|-------|------|-------------|
| `results` | `[{name, severity, matching, violations, passed}, ...]` | Per-rule results |
| `summary` | `{total, passed, failed, critical_failures}` | |
| `shacl_report` | JSON-LD | `sh:ValidationReport` |

---

## W3C Projections (patterns/)

All projections produce JSON-LD with the shared `@context` from `vocab/context.cue`.

### #ProvenanceTrace

PROV-O projection. Resources become `prov:Entity`, dependencies become `prov:wasDerivedFrom`.

**Input:** `Graph: #AnalyzableGraph`, optional `Agent: string`
**Output:** `prov_report` — JSON-LD with `prov:Entity`, `prov:Activity`, `prov:Agent`

### #ActivityStream

Activity Streams 2.0. Topological ordering as `as:OrderedCollection` of `Create` activities.

**Input:** `Graph: #AnalyzableGraph`, optional `Actor: string`
**Output:** `stream` — JSON-LD `as:OrderedCollection`

### #DCATCatalog

DCAT 3 data catalog. Resources become `dcat:Dataset`, types become `dcat:theme`.

**Input:** `Graph: #AnalyzableGraph`, optional `Title`, `Description`, `Publisher`
**Output:** `dcat_catalog` — JSON-LD `dcat:Catalog`

### #ValidationCredential

Verifiable Credentials 2.0. Wraps a SHACL report in `vc:VerifiableCredential`.

**Input:** `Graph: #AnalyzableGraph`, SHACL report source
**Output:** `vc` — JSON-LD `vc:VerifiableCredential`

### #PolicyExpressionODRL

ODRL permission/prohibition policies from graph constraints.

**Input:** `Graph: #AnalyzableGraph`
**Output:** `odrl_policy` — JSON-LD `odrl:Policy`

### #LifecyclePhasesSKOS

Static SKOS OrderedCollection of lifecycle phases (package → bootstrap → bind → deploy → verify → drift).

**Input:** none
**Output:** JSON-LD `skos:OrderedCollection`

### #TypeVocabulary (views/)

Project a type registry as SKOS ConceptScheme.

**Input:** `Registry: vocab.#TypeRegistry`, optional `BaseIRI: string`
**Output:** `concept_scheme` — JSON-LD `skos:ConceptScheme` with `skos:Concept` per type

### #OrgChart (views/)

Org ontology projection for hierarchical resources.

**Input:** `Graph: #AnalyzableGraph`
**Output:** `org_structure` — JSON-LD `org:Organization`

---

## Operational Analysis (patterns/)

### #BlastRadius

Impact of a single resource failing.

**Input:** `Graph: #AnalyzableGraph`, `Target: string`
**Output:**

| Field | Type | Description |
|-------|------|-------------|
| `affected` | `{[string]: true}` | All impacted resources |
| `rollback_order` | `[...string]` | Deepest first, target last |
| `startup_order` | `[...string]` | Reverse of rollback |
| `safe_peers` | `{[string]: true}` | Unaffected resources |

### #ZoneAwareBlastRadius

Blast radius grouped by zone/location.

**Input:** `Graph`, `Target`, `Zones: {[string]: string}` (resource → zone)
**Output:** Same as `#BlastRadius` plus `by_zone`, `zone_risk`

### #CompoundRiskAnalysis

Risk from multiple simultaneous changes.

**Input:** `Graph`, `Targets: [...string]`
**Output:** `compound_risk` (resource → affecting targets), `all_affected`

### #DeploymentPlan

Layer-by-layer startup sequence with gates.

**Input:** `Graph: #AnalyzableGraph`
**Output:** `layers: [{layer, resources, gate}, ...]`, `startup_sequence`, `shutdown_sequence`

### #RollbackPlan

Safe rollback when deployment fails at layer N.

**Input:** `Graph`, `FailedAt: int`
**Output:** `sequence` (rollback order), `safe` (below failed layer)

### #SinglePointsOfFailure

Resources with dependents but no same-type peer at their layer.

**Input:** `Graph: #AnalyzableGraph`
**Output:** `risks: [{name, dependents, types, depth}, ...]`

### #CycleDetector

Validate DAG before graph construction. Bounded BFS (32-hop reach).

**Input:** `Input: {[string]: {name, depends_on?, ...}}`
**Output:** `cycles: [{resource, via}, ...]`, `has_cycles: bool`, `acyclic: bool`

### #ConnectedComponents

Find weakly connected subgraphs / orphans.

**Input:** `Graph: #AnalyzableGraph`
**Output:** `components`, `isolated`, `count`, `is_connected: bool`

### #Subgraph

Extract induced subgraph.

**Input:** `Graph`, `Roots?` or `Target?`, optional `Radius`, `Mode: "descendants" | "ancestors" | "both"`
**Output:** `selected: {[string]: true}`, `edges`

### #GraphDiff

Structural delta between two graph versions.

**Input:** `Before: #AnalyzableGraph`, `After: #AnalyzableGraph`
**Output:** `added_nodes`, `removed_nodes`, `type_changes`, `added_edges`, `removed_edges`, `has_changes: bool`

---

## Validation Helpers (patterns/)

### #DependencyValidation

All `depends_on` references point to existing resources.

**Input:** Resource map
**Output:** `valid: bool`, `issues: [...]`

### #TypeValidation

`@type` values are in the allowed set.

**Input:** Resource map, allowed types
**Output:** `valid: bool`, `issues: [...]`

### #UniqueFieldValidation

No duplicate values in a given field across all resources.

### #ReferenceValidation

Forward references (e.g., `depends_on` targets) all resolve.

### #RequiredFieldsValidation

Mandatory fields present on all resources.

---

## Lifecycle & Drift (patterns/)

### #BootstrapPlan

Compute creation order from topology. Produces a bash script with layer gates.

**Input:** `resources: {[string]: #BootstrapResource}`
**Output:** `script: string`

### #DriftReport

Compare declared state against observed state.

**Input:** `declared`, `observed` resource maps, `drifts: [...#DriftEntry]`
**Output:** `missing`, `extra`, `summary: {in_sync: bool, ...}`

### #SmokeTest

Run checks and produce EARL test report.

**Input:** `checks: [...#Check]`, optional `Subject`
**Output:** `script: string`, `earl_report` — JSON-LD `earl:Assertion` per check

---

## Visualization (patterns/)

### #VizData

D3-compatible graph data for the explorer page.

**Input:** `Graph: #Graph`, `Resources: {[string]: {...}}`
**Output:**

```cue
data: {
    nodes:       [{id, name, types, depth, ancestors, dependents, risk_score}, ...]
    edges:       [{source, target}, ...]
    topology:    {layer_N: {[string]: true}, ...}
    criticality: [{name, dependents}, ...]
    spof:        [{name, dependents, types, depth}, ...]
    coupling:    [{name, dependent_pct}, ...]
    metrics:     {total_resources, root_count, leaf_count, max_depth, total_edges}
}
```

---

## Query Helpers (patterns/)

### #ImpactQuery

All resources affected if target fails.

**Input:** `Graph`, `Target`
**Output:** `affected: {[string]: true}`, `affected_count`

### #DependencyChain

Full path to root for a resource. Requires `#Graph` (not `#GraphLite`) for `_path`.

**Input:** `Graph: #Graph`, `Target`
**Output:** `path: [...string]`, `depth`, `ancestors`

### #GroupByType

Resources grouped by `@type`.

**Input:** `Graph`
**Output:** `groups: {[string]: {[string]: true}}`, `counts: {[string]: int}`

### #CriticalityRank

Rank by transitive dependent count.

**Input:** `Graph`
**Output:** `ranked: [{name, dependents}, ...]`

### #RiskScore

`direct_dependents × (transitive_dependents + 1)`.

**Input:** `Graph`
**Output:** `ranked: [{name, direct, transitive, score}, ...]`

### #GraphMetrics

Summary statistics.

**Input:** `Graph`
**Output:** `total_resources`, `root_count`, `leaf_count`, `max_depth`, `total_edges`

### #HealthStatus

Propagate health through the graph.

**Input:** `Graph`, `Status: {[string]: "healthy" | "degraded" | "down"}`
**Output:** `propagated: {[string]: status}`, `summary: {healthy, degraded, down}`

---

## W3C Projection Patterns (Added Feb 2026)

### #SHACLShapes (`patterns/shapes.cue`)

Generate SHACL NodeShape and PropertyShape definitions from graph structure.

**Input:**
- `Graph: #AnalyzableGraph`
- `Namespace: string` — shape IRI prefix (e.g., `"https://apercue.ca/shapes/recipe#"`)

**Output:**
- `shapes_graph` — JSON-LD with `sh:NodeShape` per `@type`, `sh:PropertyShape` for name/description/depends_on
- `summary` — `type_count`, `property_count`

### #SKOSTaxonomy (`patterns/taxonomy.cue`)

Hierarchical SKOS ConceptScheme from graph types with broader/narrower/related.

**Input:**
- `Graph: #AnalyzableGraph`
- `SchemeTitle?: string`
- `Hierarchy?: #TypeHierarchy` — `{parent: [children]}` for `skos:broader`

**Output:**
- `taxonomy_scheme` — JSON-LD `skos:ConceptScheme` with `skos:Concept` per type, `skos:broader`/`narrower` from hierarchy, `skos:related` from co-occurrence
- `summary` — `total_concepts`, `with_broader`, `related_pairs`

### #VoIDDataset (`patterns/void.cue`)

Graph self-description as a VoID dataset.

**Input:**
- `Graph: #AnalyzableGraph`
- `DatasetURI: string` | `*"urn:apercue:dataset"`
- `Title?, Homepage?, SparqlEndpoint?, DataDump?: string`

**Output:**
- `void_description` — JSON-LD `void:Dataset` with entity/triple/class counts, `void:classPartition` per type, `void:propertyPartition`, `void:Linkset` for dependency edges
- `summary` — `entities`, `triples`, `classes`, `links`, `properties`

### #ProvenancePlan (`patterns/provenance_plan.cue`)

Charter gates as PROV-O Plan with Activity per gate.

**Input:**
- `Charter` — with `gates` (from `charter.#Charter`)
- `Graph: #AnalyzableGraph`
- `GateStatus?: {[string]: {satisfied: bool, ...}}` — from gap analysis
- `Agent?: string`

**Output:**
- `plan_report` — JSON-LD with `prov:Plan`, `prov:Activity` per gate, `prov:Entity` for charter, `prov:Agent`
- `summary` — `gates`, `satisfied`, `pending`

### #DataQualityReport (`patterns/quality.cue`)

DQV quality metrics from compliance/gap analysis.

**Input:**
- `Graph: #AnalyzableGraph`
- `DatasetURI: string` | `*"urn:apercue:dataset"`
- `ComplianceResults?: [...]` — from `#ComplianceCheck`
- `GapComplete?: bool`, `MissingResources?: int`, `MissingTypes?: int` — from `#GapAnalysis`

**Output:**
- `quality_report` — JSON-LD with `dqv:QualityMeasurement` per metric across 3 dimensions (Completeness, Consistency, Accessibility)
- `summary` — `dimensions`, `measurements`, `overall_score`

### #AnnotationCollection (`patterns/annotation.cue`)

Web Annotation model for graph resource notes.

**Input:**
- `Graph: #AnalyzableGraph`
- `Annotations: [...#ResourceAnnotation]` — target (resource name), body (text), motivation, optional creator/tags

**Output:**
- `annotation_collection` — JSON-LD with `oa:Annotation` per entry, `oa:TextualBody`, W3C motivations (13 standard values)
- `summary` — `total`, `by_motivation`, `distinct_targets`

### #OWLOntology (`patterns/ontology.cue`)

Formal OWL vocabulary from graph type hierarchy.

**Input:**
- `Graph: #AnalyzableGraph`
- `Spec: #OntologySpec` — URI, Title, Description, Version
- `Hierarchy?: {[string]: [...string]}` — parent→children for `rdfs:subClassOf`
- `IncludeIndividuals: bool` | `*false`

**Output:**
- `owl_ontology` — JSON-LD with `owl:Ontology` metadata, `rdfs:Class` per type, `owl:ObjectProperty` for depends_on, optional `owl:NamedIndividual` per resource
- `summary` — `ontology_uri`, `classes`, `properties`, optionally `individuals`

### #DCATDistribution (`patterns/catalog.cue`)

Extended DCAT with Distribution and DataService entries.

**Input:**
- `Graph: #AnalyzableGraph`
- `Title, Description?: string`
- `Distributions: [...{title, format, downloadURL, mediaType?}]`
- `DataServices: [...{title, endpointURL, description?}]`

**Output:**
- `dcat_catalog` — JSON-LD `dcat:Catalog` with `dcat:Distribution` and `dcat:DataService` entries alongside `dcat:Dataset`

---

## Federation (`patterns/federation.cue`)

### #FederatedContext

Wrap a graph with a domain-specific `@base` namespace for multi-domain federation.
Each resource gets a globally unique `@id` scoped to the domain's URN. See ADR-017.

**Input:**
- `Domain: _#SafeID` — domain identifier (e.g., `"apercue"`, `"quicue-kg"`)
- `Namespace: string & !="urn:resource:"` — URI prefix (e.g., `"urn:apercue:"`)
- `Graph: #AnalyzableGraph` — the underlying computed graph

**Output:**
- `context` — `@context` with domain-specific `@base` and all W3C namespace prefixes
- `ids: {[string]: string}` — fully-qualified `@id` per resource (e.g., `"urn:apercue:graph-engine"`)
- `jsonld` — complete JSON-LD export with namespaced `@id` values and `dcterms:requires` edges

**Key constraint:** `Namespace` must not be `"urn:resource:"` (the default). This forces
explicit namespace choice, preventing accidental `@id` collisions during federation.

### #FederatedMerge

Validate and merge multiple `#FederatedContext` sources. Collision detection uses CUE
unification — if two domains claim the same namespace or produce the same `@id`, evaluation
fails at compile time. See ADR-018.

**Input:**
- `Sources: {[_#SafeID]: #FederatedContext}` — named federated contexts
- `CrossEdges: [...{source_domain, source, target_domain, target}]` — optional inter-domain dependencies

**Output:**
- `merged_jsonld` — concatenated `@graph` arrays under the shared `@context`
- `summary` — `source_count`, `total_resources`, `cross_edges`, `cross_edge_errors`, `namespaces`, `valid`

**Collision detection (zero-cost):**
- `_namespace_ownership` — maps `Namespace → domain`; duplicate namespaces cause CUE unification conflict
- `_id_ownership` — maps `@id → domain`; duplicate `@id` values cause conflict
- `_cross_edge_errors` — validates all cross-edge references resolve (uses comprehension-level `if` per ADR-003)
