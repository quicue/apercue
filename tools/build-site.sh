#!/usr/bin/env bash
# Build site data from CUE exports.
#
# Aggregates example summaries (separate CUE packages) and spec data
# into site/data/ for consumption by the static site.
#
# Usage:
#   ./tools/build-site.sh          # build all
#   ./tools/build-site.sh specs    # specs only
#   ./tools/build-site.sh examples # examples only

set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

build_specs() {
    echo "Building specs data..."
    cue export ./site/ -e site_specs --out json > site/data/specs.json
    cue export ./site/ -e site_spec_counts --out json > site/data/spec-counts.json
    echo "  site/data/specs.json ($(wc -l < site/data/specs.json) lines)"
    echo "  site/data/spec-counts.json"
}

build_examples() {
    echo "Building example metadata..."
    local tmpfile
    tmpfile=$(mktemp)
    echo "{" > "$tmpfile"
    local first=true
    for dir in examples/*/; do
        name=$(basename "$dir")
        if [ "$first" = true ]; then
            first=false
        else
            echo "," >> "$tmpfile"
        fi
        echo "  \"$name\": $(cue export "./$dir" -e summary --out json)" >> "$tmpfile"
    done
    echo "}" >> "$tmpfile"
    mv "$tmpfile" site/data/examples.json
    echo "  site/data/examples.json ($(wc -l < site/data/examples.json) lines)"
}

build_ecosystem() {
    echo "Building ecosystem data..."
    cue export ./self-charter/ -e eco_viz --out json > site/data/ecosystem.json
    echo "  site/data/ecosystem.json ($(wc -l < site/data/ecosystem.json) lines)"
}

build_charter() {
    echo "Building charter data..."
    cue export ./self-charter/ -e charter_viz --out json > site/data/charter.json
    echo "  site/data/charter.json ($(wc -l < site/data/charter.json) lines)"
}

build_spec_html() {
    echo "Building spec HTML..."
    mkdir -p site/spec
    cue export ./spec/ -e spec_html --out text > site/spec/index.html
    echo "  site/spec/index.html ($(wc -l < site/spec/index.html) lines)"
}

case "${1:-all}" in
    specs)     build_specs ;;
    examples)  build_examples ;;
    ecosystem) build_ecosystem ;;
    charter)   build_charter ;;
    spec-html) build_spec_html ;;
    all)
        build_specs
        build_examples
        build_ecosystem
        build_charter
        build_spec_html
        echo "Done. All site data regenerated."
        ;;
    *)
        echo "Usage: $0 {all|specs|examples|ecosystem|charter|spec-html}"
        exit 1
        ;;
esac
