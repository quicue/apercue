# Adapter Catalog

Projects that import apercue patterns for domain-specific use.

## Downstream Modules

### quicue.ca

Infrastructure dependency management for the quicue ecosystem.

| | |
|---|---|
| **Module** | `quicue.ca@v0` |
| **CUE** | v0.15.4 |
| **Imports** | `apercue.ca/patterns`, `apercue.ca/vocab`, `apercue.ca/charter` |
| **Patterns used** | `#GraphLite`, `#CriticalPathPrecomputed`, `#ComplianceCheck`, `#GapAnalysis`, `#VizData` |
| **@base** | `https://infra.example.com/resources/` |
| **Nodes** | ~30 (infrastructure services, databases, networks) |

Manages infrastructure as a typed dependency graph. Uses `#GraphLite` with
Python precomputation because the graph exceeds 20 nodes.

### quicue-kg

Knowledge graph schema for structured decision records.

| | |
|---|---|
| **Module** | `quicue.ca/kg@v0` |
| **CUE** | v0.15.4 |
| **Imports** | `apercue.ca/vocab` (via vendored copy) |
| **Types defined** | `#Decision`, `#Insight`, `#Pattern`, `#Rejected`, `#Task` |
| **@base** | `urn:quicue-kg:` (planned, not yet set) |

Provides the `.kb/` schema used by all projects in the ecosystem. Each
project's `.kb/decisions/` directory contains CUE files that satisfy
`quicue.ca/kg/core@v0` types.

### cmhc-retrofit

Data centre infrastructure modeling for CMHC retrofit project.

| | |
|---|---|
| **Module** | `quicue.ca/cmhc-retrofit@v0` |
| **CUE** | v0.15.4 |
| **Imports** | `apercue.ca/patterns`, `apercue.ca/charter` (via symlinks) |
| **Patterns used** | `#Graph`, `#Charter`, `#GapAnalysis`, `#BlastRadius` |
| **@base** | `urn:datacenter:` |

Models physical infrastructure (servers, networks, storage) as a dependency
graph with zone-aware blast radius analysis.

### unified-kb

Federation of knowledge bases from multiple repositories.

| | |
|---|---|
| **Module** | local (not published) |
| **Imports** | `apercue.ca/project/kb@v0`, `quicue.ca/project/kb@v0`, `quicue.ca/cmhc-retrofit/kb@v0`, `rfam.cc/maison-613/kb@v0` |
| **Pattern** | CUE unification merge + SKOS crossref |

Merges `.kb/` entries from 4 repositories into a single federated knowledge
base. Uses `skos:exactMatch` and `skos:closeMatch` to map equivalent concepts
across domains.

## Creating an Adapter

1. **Scaffold** a new project:
   ```bash
   bash tools/scaffold.sh ~/myproject example.com/myproject@v0
   ```

2. **Define your domain types** in the `@type` struct-as-set:
   ```cue
   "my-resource": {
       name: "my-resource"
       "@type": {MyDomainType: true}
   }
   ```

3. **Choose your graph size**:
   - ≤20 nodes: use `#Graph` directly
   - \>20 nodes: use `#GraphLite` + `tools/toposort.py` precomputation

4. **Set your `@base`** for federation (ADR-017):
   Override `@base` in your context exports to avoid `@id` collisions
   when your graph merges with other domains.

5. **Add compliance rules** specific to your domain:
   ```cue
   compliance: patterns.#ComplianceCheck & {
       Graph: graph
       Rules: [{
           name: "my-rule"
           match_types: {MyDomainType: true}
           must_not_be_leaf: true
       }]
   }
   ```

See [docs/getting-started.md](getting-started.md) for the full walkthrough and
[docs/pattern-api.md](pattern-api.md) for all available patterns.
