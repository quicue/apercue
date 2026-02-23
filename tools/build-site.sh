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

build_vocab() {
    echo "Building JSON-LD context..."
    mkdir -p site/vocab
    cue export ./vocab/ -e context --out json > site/vocab/context.jsonld
    echo "  site/vocab/context.jsonld"
}

build_projections() {
    echo "Building unified projections..."
    cue export ./self-charter/ -e projections --out json > site/data/projections.json
    echo "  site/data/projections.json"
}

build_llm_governance_spec() {
    echo "Building LLM governance spec HTML..."
    mkdir -p site/spec/llm-governance
    cue export ./spec/llm-governance/ -e spec_html --out text > site/spec/llm-governance/index.html
    echo "  site/spec/llm-governance/index.html ($(wc -l < site/spec/llm-governance/index.html) lines)"
}

build_phase7() {
    echo "Building phase7 charter data..."
    local phase7_dir="${PHASE7_DIR:-$HOME/phase7}"
    local site_data
    site_data="$(pwd)/site/data"
    if [ ! -d "$phase7_dir" ]; then
        echo "  SKIP: $phase7_dir not found (set PHASE7_DIR to override)"
        return 0
    fi
    (cd "$phase7_dir" && cue export . -e charter_viz --out json) > "$site_data/phase7-charter.json"
    echo "  site/data/phase7-charter.json ($(wc -l < "$site_data/phase7-charter.json") lines)"
}

build_gc_governance() {
    echo "Building GC LLM governance data..."
    # Viz data for D3 charter viewer
    cue export ./examples/gc-llm-governance/ -e viz --out json > site/data/gc-llm-governance.json
    echo "  site/data/gc-llm-governance.json ($(wc -l < site/data/gc-llm-governance.json) lines)"
    # SHACL compliance report
    cue export ./examples/gc-llm-governance/ -e compliance.shacl_report --out json > site/data/gc-llm-governance-shacl.json
    echo "  site/data/gc-llm-governance-shacl.json"
    # CPM critical path sequence
    cue export ./examples/gc-llm-governance/ -e cpm.critical_sequence --out json > site/data/gc-llm-governance-cpm.json
    echo "  site/data/gc-llm-governance-cpm.json"
    # W3C projections bundle
    cue export ./examples/gc-llm-governance/ -e projections --out json > site/data/gc-llm-governance-projections.json
    echo "  site/data/gc-llm-governance-projections.json"
}

stage_public() {
    echo "Staging public site for deploy..."
    local staging="${1:-_public}"
    rm -rf "$staging"
    mkdir -p "$staging/data" "$staging/spec" "$staging/vocab"
    # Public HTML — landing page, spec, and interactive demos
    cp site/index.html "$staging/"
    [ -f site/spec/index.html ] && cp site/spec/index.html "$staging/spec/"
    if [ -d site/spec/llm-governance ]; then
        mkdir -p "$staging/spec/llm-governance"
        cp site/spec/llm-governance/index.html "$staging/spec/llm-governance/"
    fi
    for html in explorer.html charter.html playground.html gc-governance.html phase7.html phase7-spec.html; do
        [ -f "site/$html" ] && cp "site/$html" "$staging/"
    done
    # Public data — W3C coverage (no operational data)
    [ -f site/data/specs.json ] && cp site/data/specs.json "$staging/data/"
    # GC governance demo data (sanitized example, not operational)
    for f in gc-llm-governance.json gc-llm-governance-projections.json gc-llm-governance-shacl.json gc-llm-governance-cpm.json phase7-charter.json; do
        [ -f "site/data/$f" ] && cp "site/data/$f" "$staging/data/"
    done
    # Vocab — JSON-LD context
    [ -f site/vocab/context.jsonld ] && cp site/vocab/context.jsonld "$staging/vocab/"
    echo "  Staged to $staging/ ($(find "$staging" -type f | wc -l) files)"
}

case "${1:-all}" in
    specs)          build_specs ;;
    examples)       build_examples ;;
    ecosystem)      build_ecosystem ;;
    charter)        build_charter ;;
    spec-html)      build_spec_html ;;
    vocab)          build_vocab ;;
    projections)    build_projections ;;
    gc-governance)  build_gc_governance ;;
    llm-gov-spec)   build_llm_governance_spec ;;
    phase7)         build_phase7 ;;
    public)
        build_specs
        build_examples
        build_gc_governance
        build_phase7
        build_spec_html
        build_llm_governance_spec
        build_vocab
        echo "Done. Public site data regenerated."
        ;;
    local)
        build_ecosystem
        build_charter
        build_projections
        build_gc_governance
        build_phase7
        echo "Done. Local/private site data regenerated."
        ;;
    stage)
        build_specs
        build_examples
        build_gc_governance
        build_phase7
        build_spec_html
        build_llm_governance_spec
        build_vocab
        stage_public "${2:-_public}"
        echo "Done. Public site staged for deploy."
        ;;
    all)
        build_specs
        build_examples
        build_ecosystem
        build_charter
        build_spec_html
        build_llm_governance_spec
        build_vocab
        build_projections
        build_gc_governance
        build_phase7
        echo "Done. All site data regenerated."
        ;;
    *)
        echo "Usage: $0 {all|public|local|stage [dir]|specs|examples|ecosystem|charter|phase7|spec-html|llm-gov-spec|vocab|projections|gc-governance}"
        exit 1
        ;;
esac
