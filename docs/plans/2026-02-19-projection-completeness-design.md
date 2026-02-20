# Design: Projection Completeness for apercue.ca

**Date:** 2026-02-19
**Status:** Approved
**Scope:** apercue.ca — complete the "everything is a projection" principle

## Problem

apercue.ca's thesis is that every artifact is a zero-cost projection of a single typed graph. But several artifacts violate this principle — they're hand-written with hardcoded data that duplicates what CUE already knows:

| Artifact | What's hardcoded | CUE source |
|----------|-----------------|------------|
| site/index.html example cards | "12 courses", "17 steps", etc. | Each example's `summary` export |
| site/index.html W3C table | 9 spec rows | Could be a specs-registry CUE value |
| w3c/README.md | Spec coverage table | Same as above |
| README.md W3C table | Spec coverage table | Same as above |
| README.md module structure | Example descriptions | `self-charter/` resources |
| examples/supply-chain/README.md | Hardcoded output | `cue eval` of the example |
| 3 examples missing READMEs | N/A | Should be generated |
| **spec/index.html** | Does not exist yet | Should be a CUE projection |

## Design

### Principle: CUE unifies with the ReSpec template

The ReSpec specification is not "generated from CUE" — it IS a CUE value. The HTML template unifies with type definitions. `cue export -e spec_html --out text` produces the complete HTML. This applies the same pattern as `#ExecutionPlan.script` (bash), `.notebook` (Jupyter), `.rundeck` (YAML).

### New CUE artifacts

#### 1. `vocab/specs-registry.cue` — W3C specification registry

Single source of truth for all W3C spec coverage. Drives the spec table in README, site, w3c/README, and the ReSpec spec.

```cue
#SpecEntry: {
    name:       string
    url:        string
    patterns:   [...string]
    files:      [...string]
    exports:    [...string]
    status:     "Implemented" | "Namespace" | "Downstream"
}

#SpecsRegistry: [string]: #SpecEntry

Specs: #SpecsRegistry & {
    "JSON-LD 1.1":    { ... }
    "SHACL":          { ... }
    // ...
}
```

#### 2. `site/build.cue` — Site data projections

Computes all data needed by the static site:
- Example metadata (resource count, gate count, depth, types)
- W3C spec table (from specs-registry)
- Ecosystem stats (from self-charter)

#### 3. `spec/spec.cue` — ReSpec projection

CUE definition that produces complete ReSpec HTML via string interpolation + comprehensions:
- Abstract from charter description
- Core Types section from vocab definitions (iterates #Resource, #SafeID, #SafeLabel)
- Graph Patterns section from patterns (iterates #Graph, #CriticalPath, etc.)
- W3C Mappings from specs-registry
- JSON-LD Context from vocab/context.cue
- Security section from #SafeID/#SafeLabel definitions
- Conformance classes derived from charter gates

Export: `cue export ./spec/ -e spec_html --out text > site/spec/index.html`

#### 4. `examples/meta.cue` — Example metadata aggregator

Imports each example and exports summary statistics. This requires each example to expose a standard `summary` expression.

### Build pipeline

```bash
# 1. Generate spec HTML
cue export ./spec/ -e spec_html --out text > site/spec/index.html

# 2. Regenerate ecosystem data
cue export ./self-charter/ -e eco_viz --out json > site/data/ecosystem.json

# 3. Validate everything
cue vet ./...
```

### Charter update

Add phase 6 to `self-charter/charter.cue`:

```
Phase 6 — Projection Completeness
  Resources:
    specs-registry      — W3C spec registry CUE definition
    respec-projection   — ReSpec HTML as CUE projection
    site-build          — Build pipeline for site data
    ci-regen-check      — CI verifies generated artifacts match

  Gate: "projections-complete"
    Requires: all 4 resources
    Depends on: "ship" gate
```

### What stays hand-written (intentionally)

- `site/explorer.html` — D3 visualization UX is structural, not data-driven
- `site/index.html` — Layout and design are creative work (but data inserts should be projections)
- `docs/novelty.md` — Narrative prose, not derived from data
- `self-charter/` — Source data, not a projection
- `examples/*.cue` — Source data, not a projection

### Success criteria

1. `cue export ./spec/ -e spec_html --out text` produces valid ReSpec HTML
2. W3C spec table appears in exactly one CUE definition, rendered to 3 surfaces
3. Example statistics are computed, not hardcoded
4. CI detects stale generated artifacts

## Effort

| Task | Files | Estimate |
|------|-------|----------|
| specs-registry.cue | 1 new | Small — declarative registry |
| spec/spec.cue | 1 new | Medium — HTML template + comprehensions |
| site/build.cue | 1 new | Small — aggregation |
| Charter phase 6 | 1 edit | Small |
| CI enhancement | 1 edit | Small |
| **Total** | 5 files | ~1 focused session |
