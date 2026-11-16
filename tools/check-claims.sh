#!/usr/bin/env bash
# check-claims.sh: guard public wording against claims that are false under test.
#
# 1. Banned phrases. Each one was shown false by a reproducible test
#    (see todo P0/P1.1): rule violations do not fail cue vet, and the
#    dependency closure is precomputed in Python past toy size.
# 2. W3C status wording: "accepted"/"reviewed"/"Standards committee" are not
#    what happened in any Community Group.
# 3. Generated reports (w3c/*.md) must match their CUE source.
# 4. Every link in site/w3c/index.html must resolve to a file.
#
# Usage: bash tools/check-claims.sh
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

FAIL=0
fail() { echo "  FAIL: $*"; FAIL=$((FAIL + 1)); }

FILES=(README.md ARCHITECTURE.md CONTRIBUTING.md docs/*.md w3c/*.md w3c/*.cue
       w3c/submissions/*.md site/*.html site/w3c/*.html)

BANNED=(
    'every W3C projection will conform'
    'invalid graph cannot be constructed'
    'cue vet` fails if the project is incomplete'
    'If the build passes, the data is valid'
    '1 binary'
    '0 runtime dependencies'
    'No SPARQL[.,]'
    'SPARQL-class'
    'performs the work of both SPARQL'
    'unification simultaneously performs'
    'IS the query engine'
    'enforces (all|every) shapes?'
    'Standards committee'
    'submitted to four W3C'
    'reviewed by domain experts'
)

echo "=== Banned claims ==="
for pat in "${BANNED[@]}"; do
    hits=$(grep -nIiE -- "$pat" "${FILES[@]}" 2>/dev/null || true)
    if [ -n "$hits" ]; then
        fail "banned phrase /$pat/"
        echo "$hits" | sed 's/^/        /'
    fi
done

echo "=== W3C status wording ==="
# "accepted" or "reviewed" near a CG name.
hits=$(grep -nIiE '(KG-Construct|Context Graphs?|Dataspaces|PM-KR|UORA|Community Group).{0,80}\b(accepted|reviewed)\b|\b(accepted|reviewed)\b.{0,80}(KG-Construct|Context Graphs?|Dataspaces|Community Group)' \
    "${FILES[@]}" 2>/dev/null || true)
if [ -n "$hits" ]; then
    fail "CG status uses accepted/reviewed"
    echo "$hits" | sed 's/^/        /'
fi

echo "=== Generated reports match CUE source ==="
if command -v cue &>/dev/null; then
    for pair in core_report:core-report kg_construct_report:kg-construct context_graphs_report:context-graphs; do
        expr="${pair%%:*}"; md="w3c/${pair##*:}.md"
        if ! cue export ./w3c/ -e "$expr" --out text | diff -q - "$md" >/dev/null; then
            fail "$md is stale: run cue export ./w3c/ -e $expr --out text > $md"
        fi
    done
else
    echo "  SKIP: cue not available"
fi

echo "=== site/w3c/index.html links resolve ==="
for href in $(grep -oE 'href="[^"#:]+\.html"' site/w3c/index.html | sed -E 's/href="([^"]+)"/\1/'); do
    [ -f "site/w3c/$href" ] || fail "site/w3c/index.html links missing file $href"
done

echo "=== Playground discloses JavaScript computation ==="
# The label must sit inside the output panel, before the JSON output element.
if ! python3 - <<'PY'
import re, sys
s = open("site/playground.html").read()
panel = re.search(r'<div class="json-panel">(.*?)id="json-output"', s, re.S)
sys.exit(0 if panel and 'data-computed-by="javascript"' in panel.group(1) else 1)
PY
then
    fail "site/playground.html: no data-computed-by=\"javascript\" label next to the output"
fi

echo ""
if [ "$FAIL" -gt 0 ]; then
    echo "check-claims: $FAIL failure(s)"
    exit 1
fi
echo "check-claims: all passed"
