// Site data projections — CUE source of truth for site content.
//
// Replaces hardcoded data in site/index.html with structured CUE values.
// Specs table is projected from the registry. Example metadata is
// aggregated by cue cmd build (separate CUE packages cannot cross-import).
//
// Exports:
//   cue export ./site/ -e site_specs --out json     → specs for site table
//   cue export ./site/ -e site_spec_counts --out json → summary counts
//
// Tags:
//   -t stage=public|private|all   → controls which site content is included
//
// Conditional files:
//   @if(private) can be used on files that should only be included in private builds.
//   Currently the public/private split is handled by file staging (HTML + data),
//   not CUE evaluation. Add @if(private) when private-only CUE definitions exist.

package site

import "apercue.ca/vocab@v0"

// ── Build configuration ─────────────────────────────────────────────────
_stage: *"all" | "public" | "private" @tag(stage,short=public|private|all)

// ── Spec table data (for site/index.html W3C section) ────────────────

site_specs: {
	for name, s in vocab.Specs {
		(name): {
			spec_name: s.name
			url:       s.url
			status:    s.status
			coverage:  s.coverage
			if s.prefix != _|_ {
				prefix: s.prefix
			}
		}
	}
}

site_spec_counts: {
	implemented: len([for _, s in vocab.Specs if s.status == "Implemented" {s}])
	namespace: len([for _, s in vocab.Specs if s.status == "Namespace" {s}])
	downstream: len([for _, s in vocab.Specs if s.status == "Downstream" {s}])
	total: len(vocab.Specs)
}
