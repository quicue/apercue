# Project Tracker: Software Release as a Dependency Graph

This example demonstrates the **self-hosting pattern**: track project work using the same charter + graph pattern the project implements. 10 tasks across 5 types model a software release pipeline with status tracking via `schema:actionStatus`.

## The Model

The release consists of **10 tasks** across **5 types** and **4 layers**:

```
Design (Roots):     design-api ──────────┬── impl-auth ──────┬── impl-frontend ── test-e2e ─┐
                    design-ui ───────────┘      │             │       │                      │
                                                ├── impl-crud ┤       │                      │
                                                │             │       │                      │
                                                │       test-api ─────┘                      │
                                                │          │                                 │
                                                │       setup-ci                             │
                                                │          │                                 │
                                                └── write-docs ──────────── deploy-staging ──┘
```

Each task has:
- **name**: unique identifier (e.g., `impl-auth`)
- **@type**: semantic type set — `Design`, `Implementation`, `Test`, `Documentation`, `DevOps`
- **depends_on**: task dependencies (set membership)
- **weight**: effort estimate in story points (used for progress tracking)
- **status**: `"pending"`, `"active"`, `"done"`, or `"failed"` (schema:actionStatus)
- **description**: what the task involves

## Charter Gates (Release Milestones)

| Gate | Phase | Tasks Required |
|------|-------|----------------|
| `design-complete` | 1 | design-api, design-ui |
| `implementation-complete` | 2 | impl-auth, impl-crud, impl-frontend |
| `quality-gate` | 3 | test-api, test-e2e, write-docs |
| `ship` | 4 | setup-ci, deploy-staging |

## Running the Example

```bash
cue vet ./examples/project-tracker/

cue eval ./examples/project-tracker/ -e summary

cue eval ./examples/project-tracker/ -e cpm.summary

cue export ./examples/project-tracker/ -e gaps --out json
```

## Output Example

```
$ cue eval ./examples/project-tracker/ -e summary

release:     "v1.0-release"
total_tasks: 10
gap: {
    complete:      false
    missing_count: 10
    next_gate:     "design-complete"
}
scheduling: {
    total:      33
    completed:  0
    remaining:  33
    percentage: 0
}
graph: {
    resources:  10
    max_depth:  4
    edges:      8
    root_count: 2
    leaf_count: 1
}
```

## Dual-Graph Pattern

This example uses **two graphs** from the same task data:

1. **`plan`** — full task graph (all 10 tasks regardless of status)
2. **`progress`** — only tasks with `status: "done"` (for gap analysis)

The charter's `#GapAnalysis` runs against the progress graph, so it reports which tasks are missing from the "done" set. As tasks move from `pending` to `done`, the gap shrinks and gates satisfy.

## What It Demonstrates

- **Status tracking** — tasks have `schema:actionStatus` tags (`pending`, `active`, `done`, `failed`)
- **Charter gap analysis** — which tasks remain for each milestone
- **Weighted progress** — 33 total story points, percentage tracks completion
- **Self-hosting** — track project work using the same charter pattern the project implements
- **Dual-graph pattern** — full plan graph for scheduling, filtered progress graph for gap analysis

## Patterns Used

- `patterns.#Graph` — core dependency graph (used twice: plan + progress)
- `patterns.#GraphMetrics` — graph topology metrics
- `charter.#Charter` — release milestone gates
- `charter.#GapAnalysis` — charter satisfaction against progress graph

## File Structure

- `tasks.cue` — main example (package main)
  - `_tasks` — 10 task definitions with types, weights, and status
  - `plan` — full task graph (all tasks)
  - `progress` — filtered graph (done tasks only)
  - `cpm` — weighted progress tracking (total/completed/remaining)
  - `_charter` — release milestone gates
  - `gaps` — gap analysis (plan vs progress)
  - `metrics` — graph topology metrics
  - `summary` — executive summary
