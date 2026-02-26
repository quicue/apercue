#!/usr/bin/env bash
# Deploy private site data to local grdn network.
#
# Builds charter, ecosystem, and projections from CUE,
# then syncs the full site (including private data) to
# a local target.
#
# Usage:
#   ./tools/deploy-local.sh              # build only
#   ./tools/deploy-local.sh serve        # build + start local server
#   ./tools/deploy-local.sh sync TARGET  # build + rsync to TARGET
#
# The sync target should be an rsync-compatible path, e.g.:
#   root@172.20.1.10:/var/www/apercue/   (tulip via Caddy)
#   /srv/apercue/                        (local directory)
#
# Environment:
#   APERCUE_LOCAL_TARGET  — default sync target (overridden by CLI arg)
#   APERCUE_LOCAL_PORT    — local server port (default: 8384)

set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

log() { echo "[$1] $2"; }

# ── Step 1: Regenerate precomputed data ─────────────────────
log "CPM" "Running toposort.py..."
python3 tools/toposort.py ./self-charter/charter.cue --cue 2>/dev/null > self-charter/precomputed.cue

# ── Step 2: Validate ────────────────────────────────────────
log "VET" "Validating self-charter..."
cue vet ./self-charter/

# ── Step 3: Build all site data (public + private) ──────────
log "BUILD" "Exporting all site data..."
mkdir -p site/data site/vocab

# Private data
cue export ./self-charter/ -e charter_viz --out json > site/data/charter.json
cue export ./self-charter/ -e eco_viz --out json > site/data/ecosystem.json
cue export ./self-charter/ -e projections --out json > site/data/projections.json

# Public data (also needed for local site)
bash tools/build-site.sh specs 2>&1 | sed 's/^/  /'
bash tools/build-site.sh vocab 2>&1 | sed 's/^/  /'

log "OK" "Site data regenerated ($(find site/data -name '*.json' | wc -l) JSON files)"

# ── Step 4: Action ──────────────────────────────────────────
case "${1:-build}" in
    build)
        log "DONE" "Data ready in site/. Use 'serve' or 'sync TARGET' to deploy."
        ;;
    serve)
        port="${APERCUE_LOCAL_PORT:-8384}"
        log "SERVE" "Starting local server on port $port..."
        exec python3 -m http.server "$port" --directory site --bind 0.0.0.0
        ;;
    sync)
        target="${2:-${APERCUE_LOCAL_TARGET:-}}"
        if [ -z "$target" ]; then
            echo "ERROR: No sync target. Provide as argument or set APERCUE_LOCAL_TARGET."
            exit 1
        fi
        log "SYNC" "Syncing to $target..."
        rsync -avz --delete site/ "$target"
        log "DONE" "Deployed to $target"
        ;;
    *)
        echo "Usage: $0 {build|serve|sync TARGET}"
        exit 1
        ;;
esac
