# Contributing

## Prerequisites

- [CUE](https://cuelang.org/docs/install/) v0.15.4+
- Python 3.9+ (for `toposort.py` and `validate-w3c.py`)
- `pip install rdflib pyshacl` (for W3C validation)

## Development Setup

```bash
git clone git@github.com:quicue/apercue.git
cd apercue
cue vet ./...                         # validate everything
python3 tools/validate-w3c.py -v      # W3C conformance (72 tests)
```

## Validation

Every change must pass these checks before merge. CI runs them automatically
on push to `main` and on pull requests.

```bash
# 1. All CUE packages validate (includes tools/ schemas)
cue vet ./...

# 2. Full cross-package validation
cue cmd vet-all

# 3. W3C round-trip conformance
python3 tools/validate-w3c.py -v

# 4. README smoke test — every cue command in example READMEs exits 0
#    (runs automatically in CI)

# 5. No hardcoded absolute paths in markdown
#    grep for absolute user-directory paths — must find nothing

# 6. Unicode rejection tests — #SafeID/#SafeLabel constraints hold
for f in tests/unicode-rejection/*.cue; do
    cue vet "$f" 2>/dev/null && echo "FAIL: $f" || echo "PASS: $f"
done
```

**Quick pre-commit check:**

```bash
cue vet ./... && python3 tools/validate-w3c.py
```

## Adding an Example

1. Create `examples/<name>/` with a CUE file in `package main`
2. Import patterns and charter:
   ```cue
   import (
       "apercue.ca/patterns@v0"
       "apercue.ca/charter@v0"
   )
   ```
3. Define resources as `#Resource`-compatible structs
4. Wire `graph: patterns.#Graph & {Input: _steps}` (or `#GraphLite` for >20 nodes)
5. Add a `summary` export for the build system
6. Write a README with `cue vet`, `cue eval`, and `cue export` commands in
   ` ```bash ` blocks — CI will execute every command
7. Run `cue vet ./examples/<name>/` locally before committing

## Adding a Pattern

Patterns live in `patterns/` and are imported as `apercue.ca/patterns@v0`.

1. Add the pattern to an existing file or create a new `.cue` file
2. Use `#AnalyzableGraph` as the graph interface (not `#Graph` directly) —
   this ensures your pattern works with both `#Graph` and `#GraphLite`
3. If the pattern produces W3C output, add it to `vocab/specs-registry.cue`
4. Run `cue vet ./patterns/` and verify downstream packages still validate

## Adding a W3C Projection

1. Create the projection pattern in `patterns/` (e.g., `#NewProjection`)
2. Use standard `@context` prefixes from `vocab/context.cue`
3. Add a test case to `tools/validate-w3c.py`:
   ```python
   TestCase(
       name="new-projection",
       cue_dir="./examples/some-example/",
       expression="new_projection_export",
       expected_types={"http://www.w3.org/ns/...#SomeType"},
   )
   ```
4. Register the spec in `vocab/specs-registry.cue`
5. Run `python3 tools/validate-w3c.py -v` to verify round-trip conformance

## Working with Large Graphs (>20 nodes)

CUE does not memoize recursive struct references. Graphs larger than ~20 nodes
with diamond dependencies will cause timeouts.

**Solution:** precompute with Python, validate with CUE.

```bash
# Generate precomputed topology + CPM
python3 tools/toposort.py ./path/to/data.cue --cue > precomputed.cue

# CUE validates the precomputed data against #GraphLite
cue vet ./path/to/
```

The precomputed file contains `depth`, `ancestors`, `dependents`, `earliest`,
`latest`, and `duration` maps. `#GraphLite` and `#CriticalPathPrecomputed`
consume these directly.

## Adding a Tool Spec

Tool specs live in `tools/` and are imported as `apercue.ca/tools@v0`.

1. Define the schema in `tools/` (e.g., `#MySpec`) with regex-constrained fields
2. Wire it in a `_tool.cue` file: `_my_spec: tools.#MySpec & {actual: "values"}`
3. Add `command: "my-command": { ... }` using `tool/exec`, `tool/file`, `tool/cli`
4. Run `cue vet ./...` to verify the spec catches bad values at eval time
5. Test with intentionally bad values to confirm constraints fire

Tool schemas are importable by downstream repos — they provide compile-time
validation for any project's workflow commands.

## Project Structure

See [ARCHITECTURE.md](ARCHITECTURE.md) for module layers, data flow, workflow
commands, and the full pattern catalog.

## Commit Messages

Write clear, descriptive commit messages. Focus on the "why" not the "what."
Reference ADRs when a commit implements or changes an architectural decision.

## Code Style

- Resource names: ASCII-only (`#SafeID` pattern)
- Struct-as-set for membership: `{key: true}` not `[key]`
- Comprehension-level `if` for filtering, not body-level `if`
- No hardcoded absolute paths in any `.md` file
- Tab indentation in CUE files (CUE standard)
