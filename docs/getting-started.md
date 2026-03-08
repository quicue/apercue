# Getting Started

Build a typed dependency graph, validate it against a charter, and export
W3C-standard JSON-LD — all from CUE, no runtime.

## Prerequisites

- [CUE](https://cuelang.org/docs/install/) v0.15.4+

> **CUE commands quick reference:**
>
> - `cue vet` — validate constraints (no output means pass)
> - `cue eval` — evaluate and print human-readable CUE output
> - `cue export` — evaluate and produce strict JSON/YAML

## 1. Create a project

```bash
mkdir myproject && cd myproject
cue mod init example.com/myproject@v0
```

Link apercue as a dependency (until OCI registry publish):

```bash
mkdir -p cue.mod/pkg
ln -s /path/to/apercue cue.mod/pkg/apercue.ca
```

## 2. Define resources

Create `tasks.cue`:

```cue
package main

import (
    "apercue.ca/patterns@v0"
    "apercue.ca/charter@v0"
)

// Your resources: name, @type, and optional depends_on.
_tasks: {
    "design": {
        name: "design"
        "@type": {Planning: true}
        description: "Write the design doc"
        time_days: 3
    }
    "implement": {
        name: "implement"
        "@type": {Development: true}
        depends_on: {"design": true}
        description: "Build the feature"
        time_days: 5
    }
    "test": {
        name: "test"
        "@type": {QA: true}
        depends_on: {"implement": true}
        description: "Run test suite"
        time_days: 2
    }
    "deploy": {
        name: "deploy"
        "@type": {Operations: true}
        depends_on: {"test": true}
        description: "Ship to production"
        time_days: 1
    }
}
```

Every resource needs `name` (ASCII-safe) and `@type` (struct-as-set).
Dependencies are `depends_on: {"other-resource": true}`.

`@type` and `depends_on` use **struct-as-set** — `{Key: true}` instead of arrays.
This gives O(1) membership testing, clean merging via CUE unification, and no
duplicates. When you see `resource["@type"]["Planning"] != _|_` in pattern code,
that's a field existence check — CUE's `_|_` ("bottom") means undefined.

## 3. Build the graph

Add graph construction below your resources:

```cue
// Build the graph — computes depth, topology, roots, leaves
graph: patterns.#Graph & {Input: _tasks}

// Critical path — what's the minimum time through the dependency chain?
cpm: patterns.#CriticalPath & {
    Graph: graph
    Weights: {for name, t in _tasks {(name): t.time_days}}
}
```

Validate:

```bash
cue vet .
```

If `cue vet` passes, your graph is a valid DAG with no dangling references.

## 4. Add a charter

A charter declares what "done" looks like:

```cue
_charter: charter.#Charter & {
    name: "feature-release"
    scope: {
        required_types: {
            Planning:    true
            Development: true
            QA:          true
            Operations:  true
        }
    }
    gates: {
        "planning-done": {
            phase: 1
            description: "Design approved"
            requires: {"design": true}
        }
        "release-ready": {
            phase: 2
            description: "All tasks complete"
            requires: {
                "implement": true
                "test":      true
                "deploy":    true
            }
            depends_on: {"planning-done": true}
        }
    }
}

gaps: charter.#GapAnalysis & {
    Charter: _charter
    Graph:   graph
}
```

## 5. Query

```bash
# Is the charter satisfied?
cue eval . -e gaps.complete
# → true

# What's the critical path duration?
cue eval . -e cpm.summary
# → total_duration: 11, critical_count: 4

# Critical path sequence
cue export . -e cpm.critical_sequence --out json

# SHACL validation report (W3C standard)
cue export . -e gaps.shacl_report --out json

# OWL-Time scheduling (W3C standard)
cue export . -e cpm.time_report --out json
```

Every `-e` expression selects a different projection of the same graph.
No intermediate files, no build steps.

## 6. Add compliance rules

```cue
compliance: patterns.#ComplianceCheck & {
    Graph: graph
    Rules: [
        {
            name:            "ops-needs-deps"
            description:     "Operations tasks must depend on something"
            match_types:     {Operations: true}
            must_not_be_root: true
            severity:        "critical"
        },
    ]
}
```

```bash
cue export . -e compliance.shacl_report --out json
```

## 7. Add workflow commands

For projects that need repeatable build/deploy/validate pipelines, import
the tool schemas from `apercue.ca/tools@v0`:

Create a `build_tool.cue` (note: must be `_tool.cue` suffix for `cue cmd`):

```cue
package main

import (
    "tool/exec"
    "tool/file"
    "tool/cli"

    "apercue.ca/tools@v0"
)

_build_spec: tools.#BuildSpec & {
    exports: {
        main: {
            package_path: "./"
            expression:   "cpm.time_report"
            output:       "output/schedule.json"
        }
    }
}

command: build: {
    $short: "Export scheduling data"

    run: exec.Run & {
        cmd: ["cue", "export",
            _build_spec.exports.main.package_path,
            "-e", _build_spec.exports.main.expression,
            "--out", "json"]
        stdout: string
    }
    write: file.Create & {
        filename: _build_spec.exports.main.output
        contents: run.stdout
    }
    done: cli.Print & {
        text: "Build complete."
        $after: write
    }
}
```

The `#BuildSpec` constraint validates all paths and expressions at `cue vet`
time. A typo like `package_path: "no-dot-slash"` fails immediately with a
clear error — before the command ever runs.

```bash
cue cmd build
```

## What's next

- See [examples/](../examples/) for domain-specific graphs (courses, recipes,
  supply chains, governance frameworks)
- See [ARCHITECTURE.md](../ARCHITECTURE.md) for design principles, workflow commands, and module layers
- See [docs/pattern-api.md](pattern-api.md) for the full pattern type reference
- See [docs/adapters.md](adapters.md) for downstream module guide and creating adapters
- See [CONTRIBUTING.md](../CONTRIBUTING.md) for development setup

## Scaling past small graphs

`#Graph` computes transitive closure (ancestors, descendants) recursively in CUE.
This works well for graphs up to ~30 nodes with simple topologies. For dense
diamond-shaped DAGs above ~35 nodes, evaluation time grows exponentially.

**The fix: `#GraphLite` with precomputed data.**

```bash
# Generate precomputed depth/ancestors/dependents
python3 tools/toposort.py your-file.cue

# This creates precomputed.cue — feed it to #GraphLite instead of #Graph
```

```cue
// Instead of:
// graph: patterns.#Graph & {Input: _tasks}

// Use:
graph: patterns.#GraphLite & {
    Input:       _tasks
    Precomputed: _precomputed
}
```

`#GraphLite` accepts the same interface as `#Graph` (both satisfy `#AnalyzableGraph`)
so all downstream patterns — `#CriticalPath`, `#GapAnalysis`, `#ComplianceCheck` —
work with either. The self-charter in this repo uses `#GraphLite` with 40+ nodes and
evaluates in ~33ms.
