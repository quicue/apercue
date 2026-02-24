// Site data projections — CUE source of truth for site content.
//
// Replaces hardcoded data in site/index.html with structured CUE values.
// Specs table is projected from the registry. Example metadata is
// aggregated by tools/build-site.sh (separate CUE packages cannot
// cross-import).
//
// Exports:
//   cue export ./site/ -e site_specs --out json     → specs for site table
//   cue export ./site/ -e site_spec_counts --out json → summary counts

package site

import ( "apercue.ca/vocab@v0"

	// ── Spec table data (for site/index.html W3C section) ────────────────
)

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
