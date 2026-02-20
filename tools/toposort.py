#!/usr/bin/env python3
"""Pre-compute graph topology for CUE #Graph.Precomputed.

Reads a CUE resource map and computes topological sort, ancestors, and
dependents in O(V+E). Outputs JSON or CUE matching the Precomputed schema.

Input sources (in priority order):
  stdin (-):       JSON resource map piped in
  .json file:      JSON resource map from file
  .cue file:       Parse CUE _tasks struct directly (no cue eval needed)
  directory:       cue export <dir> -e <expr> (slow — triggers full eval)

Usage:
    # Fast: parse CUE directly (no cue binary needed for graph computation)
    python3 tools/toposort.py ./self-charter/charter.cue --cue > self-charter/precomputed.cue

    # From JSON:
    python3 tools/toposort.py tasks.json --cue > precomputed.cue

    # From stdin:
    cat tasks.json | python3 tools/toposort.py - --cue > precomputed.cue

    # Full CUE export (slow, triggers package eval):
    python3 tools/toposort.py ./self-charter/ _tasks --cue > precomputed.cue
"""

import json
import re
import subprocess
import sys
from collections import defaultdict, deque
from pathlib import Path


def parse_cue_tasks(filepath: str) -> dict:
    """Parse _tasks struct from a CUE file using regex.

    Extracts resource names and depends_on keys from the standard _tasks
    format. Works without the cue binary — pure string parsing.

    Handles the standard pattern:
        "resource-name": {
            name: "resource-name"
            "@type": {TypeA: true, TypeB: true}
            depends_on: {"dep-a": true, "dep-b": true}
            description: "..."
        }
    """
    text = Path(filepath).read_text()

    # Find the _tasks block
    tasks_match = re.search(r'_tasks:\s*\{', text)
    if not tasks_match:
        print(f"No _tasks block found in {filepath}", file=sys.stderr)
        sys.exit(1)

    resources = {}
    # Match top-level resource entries: "name": { ... }
    # We track brace depth to find complete resource blocks
    pos = tasks_match.end()
    brace_depth = 1

    while pos < len(text) and brace_depth > 0:
        # Look for a resource key
        key_match = re.match(r'\s*(?://[^\n]*\n\s*)*"([^"]+)":\s*\{', text[pos:])
        if key_match and brace_depth == 1:
            rname = key_match.group(1)
            block_start = pos + key_match.end()

            # Find the closing brace for this resource
            depth = 1
            i = block_start
            while i < len(text) and depth > 0:
                if text[i] == '{':
                    depth += 1
                elif text[i] == '}':
                    depth -= 1
                i += 1
            block = text[block_start:i - 1]

            # Extract depends_on keys
            deps = {}
            deps_match = re.search(r'depends_on:\s*\{([^}]*)\}', block)
            if deps_match:
                for dep_key in re.findall(r'"([^"]+)":\s*true', deps_match.group(1)):
                    deps[dep_key] = True

            # Extract @type keys
            types = {}
            type_match = re.search(r'"@type":\s*\{([^}]*)\}', block)
            if type_match:
                for type_key in re.findall(r'(\w+):\s*true', type_match.group(1)):
                    types[type_key] = True

            resources[rname] = {
                "name": rname,
                "@type": types,
            }
            if deps:
                resources[rname]["depends_on"] = deps

            pos = block_start + (i - 1 - block_start) + 1
        else:
            # Skip character, track braces
            if pos < len(text):
                if text[pos] == '{':
                    brace_depth += 1
                elif text[pos] == '}':
                    brace_depth -= 1
            pos += 1

    return resources


def load_resources(source: str, expr: str | None = None) -> dict:
    """Load resources from JSON stdin, file, CUE file, or CUE export."""
    if source == "-":
        return json.load(sys.stdin)

    if source.endswith(".json"):
        with open(source) as f:
            return json.load(f)

    if source.endswith(".cue"):
        return parse_cue_tasks(source)

    # CUE export (slow — triggers full package evaluation)
    cmd = ["cue", "export", source, "-e", expr or "_tasks", "--out", "json"]
    result = subprocess.run(cmd, capture_output=True, text=True, timeout=120)
    if result.returncode != 0:
        print(f"cue export failed: {result.stderr}", file=sys.stderr)
        sys.exit(1)
    return json.loads(result.stdout)


def toposort(resources: dict) -> tuple[list[str], dict[str, int]]:
    """Kahn's algorithm: returns (sorted order, depth map)."""
    in_degree = {name: 0 for name in resources}
    children = defaultdict(list)

    for name, r in resources.items():
        deps = r.get("depends_on", {})
        if isinstance(deps, dict):
            for dep in deps:
                children[dep].append(name)
                in_degree[name] += 1

    queue = deque()
    depth = {}
    for name, deg in in_degree.items():
        if deg == 0:
            queue.append(name)
            depth[name] = 0

    order = []
    while queue:
        node = queue.popleft()
        order.append(node)
        for child in children[node]:
            in_degree[child] -= 1
            depth[child] = max(depth.get(child, 0), depth[node] + 1)
            if in_degree[child] == 0:
                queue.append(child)

    if len(order) != len(resources):
        missing = set(resources) - set(order)
        print(f"Cycle detected! Nodes not reachable: {missing}", file=sys.stderr)
        sys.exit(2)

    return order, depth


def compute_ancestors(resources: dict, order: list[str]) -> dict[str, dict[str, bool]]:
    """Compute transitive ancestors using topological order (forward pass)."""
    ancestors = {name: {} for name in resources}

    for name in order:
        deps = resources[name].get("depends_on", {})
        if isinstance(deps, dict):
            for dep in deps:
                ancestors[name][dep] = True
                ancestors[name].update(ancestors[dep])

    return ancestors


def compute_dependents(ancestors: dict) -> dict[str, dict[str, bool]]:
    """Invert the ancestors map."""
    dependents = {name: {} for name in ancestors}
    for name, ancs in ancestors.items():
        for anc in ancs:
            dependents[anc][name] = True
    return dependents


def to_cue_struct(data: dict) -> str:
    """Format Python dict as CUE struct literal."""
    if not data:
        return "{}"
    pairs = ", ".join(f'"{k}": true' for k in sorted(data))
    return "{" + pairs + "}"


def main():
    if len(sys.argv) < 2:
        print(__doc__, file=sys.stderr)
        sys.exit(1)

    source = sys.argv[1]
    expr = sys.argv[2] if len(sys.argv) > 2 and not sys.argv[2].startswith("--") else "_tasks"
    as_cue = "--cue" in sys.argv

    resources = load_resources(source, expr)
    order, depth = toposort(resources)
    ancestors = compute_ancestors(resources, order)
    dependents = compute_dependents(ancestors)

    if as_cue:
        print("package main\n")
        print("_precomputed: {")
        print("\tdepth: {")
        for name in order:
            print(f'\t\t"{name}": {depth[name]}')
        print("\t}")
        print("\tancestors: {")
        for name in order:
            print(f'\t\t"{name}": {to_cue_struct(ancestors[name])}')
        print("\t}")
        print("\tdependents: {")
        for name in order:
            print(f'\t\t"{name}": {to_cue_struct(dependents[name])}')
        print("\t}")
        print("}")
    else:
        result = {
            "depth": depth,
            "ancestors": ancestors,
            "dependents": dependents,
        }
        json.dump(result, sys.stdout, indent=2)
        print()

    total_ancestors = sum(len(a) for a in ancestors.values())
    sys.stderr.write(f"Toposort: {len(order)} nodes, {sum(depth.values())} total depth, "
                     f"{total_ancestors} ancestor entries\n")


if __name__ == "__main__":
    main()
