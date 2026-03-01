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

# 3. W3C spec count (from README table)
SPEC_COUNT=$(grep -c '| Implemented |' README.md)
echo "W3C specs (Implemented): $SPEC_COUNT"

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
