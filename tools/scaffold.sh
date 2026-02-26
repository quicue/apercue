#!/usr/bin/env bash
# Scaffold a new apercue domain project.
#
# Creates a minimal CUE project with graph, charter, and compliance patterns
# wired up and ready to customize.
#
# Usage:
#   bash tools/scaffold.sh <project-dir> <module-name>
#
# Example:
#   bash tools/scaffold.sh ~/myproject example.com/myproject@v0

set -euo pipefail

if [ $# -lt 2 ]; then
    echo "Usage: $0 <project-dir> <module-name>"
    echo ""
    echo "Example:"
    echo "  $0 ~/myproject example.com/myproject@v0"
    exit 1
fi

PROJECT_DIR="$1"
MODULE_NAME="$2"
APERCUE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

if [ -d "$PROJECT_DIR" ]; then
    echo "ERROR: $PROJECT_DIR already exists"
    exit 1
fi

echo "Scaffolding apercue project: $MODULE_NAME"
echo "  Directory: $PROJECT_DIR"
echo ""

mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# Initialize CUE module
cue mod init "$MODULE_NAME"

# Link apercue
mkdir -p cue.mod/pkg
ln -s "$APERCUE_DIR" cue.mod/pkg/apercue.ca

# Create main CUE file
cat > resources.cue << 'CUEFILE'
// Domain resources and dependency graph.
//
// Run:
//   cue vet .
//   cue eval . -e summary
//   cue eval . -e gaps.complete
//   cue export . -e gaps.shacl_report --out json
//   cue export . -e cpm.critical_sequence --out json

package main

import (
	"apercue.ca/patterns@v0"
	"apercue.ca/charter@v0"
)

// ═══ RESOURCES ═══════════════════════════════════════════════════════════════
// Define your domain resources here. Each needs:
//   name:       ASCII identifier (letters, numbers, hyphens, dots)
//   @type:      semantic types as struct-as-set {TypeName: true}
//   depends_on: dependencies as struct-as-set {"other-resource": true}

_resources: {
	"example-a": {
		name: "example-a"
		"@type": {Core: true}
		description: "First resource"
		time_days: 3
	}
	"example-b": {
		name: "example-b"
		"@type": {Core: true}
		depends_on: {"example-a": true}
		description: "Depends on A"
		time_days: 2
	}
	"example-c": {
		name: "example-c"
		"@type": {Extension: true}
		depends_on: {"example-b": true}
		description: "Depends on B"
		time_days: 1
	}
}

// ═══ GRAPH ═══════════════════════════════════════════════════════════════════
graph: patterns.#Graph & {Input: _resources}

cpm: patterns.#CriticalPath & {
	Graph:   graph
	Weights: {for name, r in _resources {(name): r.time_days}}
}

// ═══ CHARTER ═════════════════════════════════════════════════════════════════
_charter: charter.#Charter & {
	name: "my-project"
	scope: {
		required_types: {
			Core:      true
			Extension: true
		}
	}
	gates: {
		"core-complete": {
			phase:       1
			description: "Core resources ready"
			requires: {
				"example-a": true
				"example-b": true
			}
		}
		"all-complete": {
			phase:       2
			description: "All resources ready"
			requires: {
				"example-c": true
			}
			depends_on: {"core-complete": true}
		}
	}
}

gaps: charter.#GapAnalysis & {
	Charter: _charter
	Graph:   graph
}

// ═══ COMPLIANCE ══════════════════════════════════════════════════════════════
compliance: patterns.#ComplianceCheck & {
	Graph: graph
	Rules: [
		{
			name:             "extensions-need-deps"
			description:      "Extension resources must depend on something"
			match_types:      {Extension: true}
			must_not_be_root: true
			severity:         "critical"
		},
	]
}

// ═══ SUMMARY ═════════════════════════════════════════════════════════════════
summary: {
	charter:    _charter.name
	complete:   gaps.complete
	next_gate:  gaps.next_gate
	scheduling: cpm.summary
	graph: {
		total:     len(graph.resources)
		roots:     len([for r, _ in graph.roots {r}])
		leaves:    len([for l, _ in graph.leaves {l}])
		max_depth: len(graph.topology) - 1
	}
}
CUEFILE

# Create README
cat > README.md << 'README'
# My Project

Built with [apercue](https://github.com/quicue/apercue) — compile-time W3C
linked data from typed dependency graphs.

## Commands

```bash
# Validate graph structure
cue vet .

# Project summary
cue eval . -e summary

# Charter gap analysis
cue eval . -e gaps.complete

# W3C SHACL validation report
cue export . -e gaps.shacl_report --out json

# Critical path scheduling (OWL-Time)
cue export . -e cpm.critical_sequence --out json

# Compliance check (SHACL)
cue export . -e compliance.shacl_report --out json
```
README

# Validate
echo "Validating..."
if cue vet -c=false .; then
    echo ""
    echo "Project scaffolded and validated."
    echo ""
    cue eval . -e summary
    echo ""
    echo "Next steps:"
    echo "  1. Edit resources.cue — replace example resources with your domain"
    echo "  2. Update _charter — define your gates and required types"
    echo "  3. Run: cue eval . -e summary"
else
    echo ""
    echo "WARNING: Validation failed. Check cue.mod/pkg/apercue.ca symlink."
fi
