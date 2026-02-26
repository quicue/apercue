# Course Prerequisites: University Degree as a Dependency Graph

This example demonstrates how **degree requirements are dependency graphs**. A BSc Computer Science curriculum models 12 courses across 4 types with prerequisite edges and a 3-gate charter tracking degree completion.

## The Model

The curriculum consists of **12 courses** across **4 types**:

```
Year 1 (Roots):     intro-cs ─────────────┬── data-structures ── databases
                    intro-math ────────────┤                  ├── algorithms ─── ml-intro
                                           │                  │               ├── capstone-seminar
Year 1-2:           intro-programming ─────┤                  ├── operating-systems ── networks
                         (depends on       │                  │                    ├── systems-lab
                          intro-cs)        └──────────────────┴── software-engineering ──┘
```

Each course has:
- **name**: unique identifier (e.g., `data-structures`)
- **@type**: semantic type set — `CoreCourse`, `Elective`, `LabCourse`, `Seminar`
- **depends_on**: prerequisite courses (set membership)
- **credits**: credit hours (used as CPM weight)
- **description**: human-readable course title

## Charter Gates (Degree Requirements)

| Gate | Phase | Courses Required |
|------|-------|------------------|
| `foundations` | 1 | intro-cs, intro-math, intro-programming |
| `core-complete` | 2 | data-structures, databases, operating-systems, software-engineering, algorithms, networks |
| `graduation` | 3 | ml-intro, systems-lab, capstone-seminar |

## Running the Example

```bash
cue vet ./examples/course-prereqs/

cue eval ./examples/course-prereqs/ -e summary

cue eval ./examples/course-prereqs/ -e gaps.complete

cue eval ./examples/course-prereqs/ -e cpm.summary

cue export ./examples/course-prereqs/ -e gaps.shacl_report --out json

cue export ./examples/course-prereqs/ -e cpm.time_report --out json
```

## Output Example

```
$ cue eval ./examples/course-prereqs/ -e summary

degree:          "bsc-computer-science"
total_courses:   12
graph_valid:     true
degree_complete: true
gap: {
    missing_courses: 0
    missing_types:   0
    next_gate:       ""
}
scheduling: {
    total_duration:  14
    critical_count:  4
    total_resources: 12
    max_slack:       5
}
compliance: {
    total:             2
    passed:            2
    failed:            0
    critical_failures: 0
}
```

## What It Demonstrates

- **Charter gates as degree requirements** — 3 phases enforce prerequisite ordering
- **SHACL gap analysis** — which courses are missing for each gate
- **OWL-Time scheduling** — critical path through the prerequisite chain (4 courses, 14 credits)
- **Compliance rules** — seminars and labs must have prerequisites (2 rules, both pass)
- **Domain-agnostic proof** — courses are just resources with `depends_on`; same patterns work for infrastructure, recipes, supply chains

## Patterns Used

- `patterns.#Graph` — core dependency graph (12 nodes, prerequisite edges)
- `patterns.#CriticalPath` — CPM scheduling (weighted by credit hours)
- `patterns.#ComplianceCheck` — structural validation rules
- `charter.#Charter` — degree requirement phase gates
- `charter.#GapAnalysis` — charter satisfaction (produces `sh:ValidationReport`)

## File Structure

- `courses.cue` — main example (package main)
  - `_courses` — 12 course definitions with types and prerequisites
  - `graph` — typed dependency graph
  - `cpm` — critical path analysis (weight = credits)
  - `_charter` — degree requirement gates
  - `gaps` — gap analysis (what courses remain)
  - `compliance` — structural rules (seminars/labs need prereqs)
  - `summary` — executive summary
