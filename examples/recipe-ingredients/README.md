# Recipe Ingredients: Cooking as a Dependency Graph

This example demonstrates how **recipes are dependency graphs**. A beef bourguignon models 17 steps — from raw ingredients through prep and cooking stages — where dependencies encode what must happen before what.

## The Model

The recipe consists of **17 steps** across **6 types** and **5 layers**:

```
Ingredients (Roots):  beef-chuck    onions    carrots    garlic    red-wine  beef-stock  mushrooms  thyme-bay
                          │            │         │         │          │          │           │          │
Prep Steps:               │      dice-onions  slice    mince       │          │     quarter-mushrooms  │
                          │            │      carrots  garlic       │          │           │            │
Cook Steps:          brown-beef       └────────┴────────┘           │          │           │            │
                          │                    │                    │          │           │            │
                          └────── saute-mirepoix                   │          │           │            │
                                       │                           │          │           │            │
                                       └────── deglaze ────────────┘          │           │            │
                                                  │                           │           │            │
                                                  └──────── braise ───────────┘           │            │
                                                               │              ────────────┘      ──────┘
                                                               └──── finish
```

Each step has:
- **name**: unique identifier (e.g., `brown-beef`)
- **@type**: semantic type set — `Protein`, `Produce`, `Seasoning`, `Liquid`, `PrepStep`, `CookStep`
- **depends_on**: what must be done first (set membership)
- **time_min**: time in minutes (used as CPM weight; 0 for ingredients)
- **description**: what to do

## Charter Gates (Recipe Completeness)

| Gate | Phase | Steps Required |
|------|-------|----------------|
| `mise-en-place` | 1 | All 8 ingredients + 4 prep steps |
| `cooking-complete` | 2 | All 5 cook steps (brown, sauté, deglaze, braise, finish) |

## Running the Example

```bash
cue vet ./examples/recipe-ingredients/

cue eval ./examples/recipe-ingredients/ -e gap_summary

cue eval ./examples/recipe-ingredients/ -e cpm.summary

cue eval ./examples/recipe-ingredients/ -e cpm.critical_sequence
```

## Output Example

```
$ cue eval ./examples/recipe-ingredients/ -e summary

recipe:      "beef-bourguignon"
total_steps: 17
gap: {
    complete:          true
    missing_resources: 0
    missing_types:     0
    next_gate:         ""
    unsatisfied_gates: 0
}
scheduling: {
    total_duration:  205
    critical_count:  5
    total_resources: 17
    max_slack:       172
}
graph: {
    total_resources: 17
    max_depth:       5
    roots:           8
    leaves:          1
    total_edges:     9
}
```

## Critical Path (Minimum Cook Time)

The critical path determines the fastest possible cooking time: **205 minutes** (3 hours 25 min).

```
beef-chuck (0 min) → brown-beef (15 min) → deglaze (10 min) → braise (150 min) → finish (30 min)
```

5 steps on the critical path. Any delay on these delays the entire meal. The parallel prep work (dice onions, slice carrots, mince garlic, quarter mushrooms) has up to **172 minutes of slack** — it can be done anytime before the deglaze step.

## What It Demonstrates

- **Critical path analysis** — which steps determine total cooking time (205 min)
- **Topological layering** — parallel prep steps vs sequential cooking
- **Slack analysis** — 172 minutes of slack on vegetable prep means flexible scheduling
- **Domain-agnostic proof** — the same `#CriticalPath` pattern used for infrastructure scheduling works for recipe execution order

## Patterns Used

- `patterns.#Graph` — core dependency graph (17 nodes, prep/cook edges)
- `patterns.#CriticalPath` — CPM scheduling (weighted by time_min)
- `patterns.#ComplianceCheck` — cook steps must have dependencies
- `charter.#Charter` — recipe completeness gates
- `charter.#GapAnalysis` — charter satisfaction

## File Structure

- `recipe.cue` — main example (package main)
  - `_steps` — 17 step definitions (8 ingredients + 4 prep + 5 cook)
  - `graph` — typed dependency graph
  - `cpm` — critical path analysis (weight = time_min)
  - `_charter` — recipe completeness gates
  - `gaps` — gap analysis
  - `compliance` — structural rules (cook steps need deps)
  - `gap_summary`, `scheduling_summary`, `graph_metrics` — intermediate projections
  - `summary` — executive summary
