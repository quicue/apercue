#!/usr/bin/env bash
# validate-counts.sh — Verify documentation counts match reality.
#
# Catches stale hardcoded counts in README.md, CONTRIBUTING.md,
# ARCHITECTURE.md, and docs/pattern-api.md before they ship.
#
# Usage: bash tools/validate-counts.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

FAIL=0
WARN=0

check() {
    local label="$1" actual="$2" file="$3" pattern="$4"
    if grep -qP "$pattern" "$file" 2>/dev/null; then
        echo "  PASS: $label = $actual ($file)"
    else
        echo "  FAIL: $label = $actual but not found in $file (pattern: $pattern)"
        FAIL=$((FAIL + 1))
    fi
}

check_absent() {
    local label="$1" wrong="$2" file="$3" pattern="$4"
    if grep -qP "$pattern" "$file" 2>/dev/null; then
        echo "  FAIL: $label — stale value '$wrong' found in $file"
        FAIL=$((FAIL + 1))
    fi
}

echo "=== Count Validation ==="
echo ""

# 1. Pattern file count
PATTERN_FILES=$(ls patterns/*.cue | wc -l)
echo "Pattern files: $PATTERN_FILES"
check "README pattern files" "$PATTERN_FILES" "README.md" "${PATTERN_FILES} files"

# 2. Pattern definition count
PATTERN_DEFS=$(grep -rP '^#[A-Z]\w+\s*:' patterns/*.cue | wc -l)
echo "Pattern definitions: $PATTERN_DEFS"
check "README pattern defs" "$PATTERN_DEFS" "README.md" "${PATTERN_DEFS} definitions"
check "ARCHITECTURE pattern defs" "$PATTERN_DEFS" "ARCHITECTURE.md" "${PATTERN_DEFS} pattern definitions"

# 3. W3C spec count. Source of truth: vocab/specs-registry.cue via site_spec_counts.
#    Every spec count in README, docs, w3c/*.md and site HTML must agree with it.
if command -v cue &>/dev/null; then
    SPEC_JSON=$(cue export ./site/ -e site_spec_counts --out json)
    echo "W3C specs (registry): $(echo "$SPEC_JSON" | tr -d ' \n')"
    if ! diff -q <(echo "$SPEC_JSON") site/data/spec-counts.json >/dev/null; then
        echo "  FAIL: site/data/spec-counts.json is stale (cue export ./site/ -e site_spec_counts)"
        FAIL=$((FAIL + 1))
    fi
    SPEC_FAILS=$(SPEC_JSON="$SPEC_JSON" python3 - <<'PY'
import glob, json, os, re
c = json.loads(os.environ["SPEC_JSON"])
impl, total = c["implemented"], c["total"]
files = (["README.md", "ARCHITECTURE.md", "CONTRIBUTING.md"] + glob.glob("docs/*.md")
         + glob.glob("w3c/*.md") + glob.glob("w3c/submissions/*.md")
         + glob.glob("site/*.html") + glob.glob("site/w3c/*.html"))
# "N W3C specs", "N specifications", "N W3C standards", "N W3C projections",
# "N W3C vocabulary projections", "N W3C specification outputs", "Export N projections",
# "Six of N", "N projections." (verdict lines). "N different W3C specifications".
count_re = re.compile(
    r"\b(\d+)\s+(?:different\s+)?(?:W3C\s+)?(?:vocabulary\s+)?"
    r"(?:spec(?:ification)?s\b|standards\b|specification outputs\b|projections\.)"
    r"|\b(\d+)\s+W3C\s+(?:vocabulary\s+)?projections\b"
    r"|Export\s+(\d+)\s+projections\b|\bof\s+(\d+)\s+W3C\b"
    r"|<strong>(\d+)</strong>\s*W3C specs")
nth_re = re.compile(r"\b(\d+)th\s+\(Hydra\)")
depth_re = re.compile(r"(\d+) full, (\d+) partial, (\d+) vocabulary, (\d+) structural")
# Counts that describe the playground's six tabs, not the registry.
playground_re = re.compile(r"(?:See|Six of)?\s*\b6 W3C projections\b")
bad = []
for f in sorted(set(files)):
    for i, line in enumerate(open(f, encoding="utf-8"), 1):
        for m in count_re.finditer(line):
            n = int(next(g for g in m.groups() if g))
            if n == 6 and playground_re.search(line):
                continue
            if n != impl:
                bad.append(f"{f}:{i}: '{m.group(0)}' != {impl} implemented")
        for m in nth_re.finditer(line):
            if int(m.group(1)) != total:
                bad.append(f"{f}:{i}: '{m.group(0)}' != {total} total")
        for m in depth_re.finditer(line):
            got = tuple(int(x) for x in m.groups())
            want = (c["full"], c["partial"], c["vocabulary"], c["structural"])
            if got != want:
                bad.append(f"{f}:{i}: depth breakdown {got} != {want}")
# Table rows must agree too.
rows = open("site/index.html").read().count('spec-status impl"')
if rows != impl:
    bad.append(f"site/index.html: {rows} Implemented table rows != {impl}")
rows = open("README.md").read().count("| Implemented |")
if rows != impl:
    bad.append(f"README.md: {rows} Implemented table rows != {impl}")
print("\n".join(bad))
PY
)
    if [ -n "$SPEC_FAILS" ]; then
        echo "$SPEC_FAILS" | sed 's/^/  FAIL: /'
        FAIL=$((FAIL + $(echo "$SPEC_FAILS" | wc -l)))
    else
        echo "  PASS: every spec count matches the registry"
    fi
else
    echo "  SKIP: cue not available, skipping spec count"
fi

# 4. Example count
EXAMPLE_COUNT=$(ls -d examples/*/ | wc -l)
echo "Examples: $EXAMPLE_COUNT"

# 5. Self-charter resource count
if command -v cue &>/dev/null; then
    SELF_CHARTER_NODES=$(cue export ./self-charter/ -e ecosystem --out json 2>/dev/null \
        | python3 -c "import json,sys; print(len(json.load(sys.stdin).get('graph',{}).get('resources',{})))" 2>/dev/null || echo "?")
    echo "Self-charter nodes: $SELF_CHARTER_NODES"
    if [ "$SELF_CHARTER_NODES" != "?" ]; then
        check "README self-charter nodes" "$SELF_CHARTER_NODES" "README.md" "${SELF_CHARTER_NODES} nodes"
    fi
    # self-charter holds two graphs: the build charter (tasks) and the ecosystem (nodes).
    # Any line that mentions self-charter must use "N tasks" for the charter and
    # "N nodes" for the ecosystem, with the real numbers.
    SELF_CHARTER_TASKS=$(cue eval ./self-charter/ -e 'len(graph.resources)' 2>/dev/null || echo "?")
    echo "Self-charter build tasks: $SELF_CHARTER_TASKS"
    SC_FAILS=$(NODES="$SELF_CHARTER_NODES" TASKS="$SELF_CHARTER_TASKS" python3 - <<'PY'
import glob, os, re
nodes, tasks = os.environ["NODES"], os.environ["TASKS"]
files = ["README.md", "ARCHITECTURE.md", "CONTRIBUTING.md"] + glob.glob("docs/*.md") + glob.glob("site/*.html")
bad = []
for f in files:
    for i, line in enumerate(open(f, encoding="utf-8"), 1):
        if not re.search(r"self-charter|ecosystem\.cue|charter\.cue\s+#", line):
            continue
        for n in re.findall(r"\b(\d+)[ -]nodes?\b", line):
            if n != nodes:
                bad.append(f"{f}:{i}: '{n} nodes' but the ecosystem graph has {nodes}")
        for n in re.findall(r"\b(\d+)[ -]tasks?\b", line):
            if n != tasks:
                bad.append(f"{f}:{i}: '{n} tasks' but the build charter has {tasks}")
print("\n".join(bad))
PY
)
    if [ -n "$SC_FAILS" ]; then
        echo "$SC_FAILS" | sed 's/^/  FAIL: /'
        FAIL=$((FAIL + $(echo "$SC_FAILS" | wc -l)))
    fi
else
    echo "  SKIP: cue not available, skipping self-charter node count"
fi

# 6. Namespace prefix count (IRIs in context.cue)
NS_COUNT=$(grep -cP '^\s+"[a-z]+":' vocab/context.cue 2>/dev/null || echo "?")
echo "Namespace prefixes: $NS_COUNT"
if [ "$NS_COUNT" != "?" ]; then
    check "README namespace count" "$NS_COUNT" "README.md" "${NS_COUNT} W3C namespaces"
fi

# 7. W3C test count (run the actual tests if python3 + rdflib available)
if python3 -c "import rdflib" 2>/dev/null; then
    TEST_OUTPUT=$(python3 tools/validate-w3c.py 2>&1 | tail -1)
    # Extract "All N validations passed"
    TEST_COUNT=$(echo "$TEST_OUTPUT" | grep -oP 'All \K\d+' || echo "?")
    echo "W3C test count: $TEST_COUNT"
    if [ "$TEST_COUNT" != "?" ]; then
        check "CONTRIBUTING test count" "$TEST_COUNT" "CONTRIBUTING.md" "${TEST_COUNT} tests"
    fi
else
    echo "  SKIP: rdflib not available, skipping W3C test count"
fi

echo ""
echo "=== Summary ==="
if [ "$FAIL" -gt 0 ]; then
    echo "FAILED: $FAIL count(s) are stale"
    echo ""
    echo "Fix: Update the hardcoded counts in the listed files to match reality."
    echo "Then re-run: bash tools/validate-counts.sh"
    exit 1
else
    echo "All counts match."
    exit 0
fi
