package main

_precomputed: {
	depth: {
		"repo-scaffold":           0
		"resource-schema":         1
		"type-registry":           1
		"jsonld-context":          1
		"viz-contract":            1
		"graph-engine":            2
		"safeid-constraints":      2
		"w3c-namespace-cleanup":   2
		"analysis-patterns":       3
		"validation-patterns":     3
		"lifecycle-patterns":      3
		"charter-module":          3
		"kb-setup":                3
		"quicue-semantic-sync":    3
		"owl-time-projection":     4
		"example-recipe":          4
		"skos-projection":         4
		"earl-projection":         4
		"shacl-projection":        4
		"example-course-prereqs":  4
		"example-project-tracker": 4
		"example-supply-chain":    4
		"docs-w3c-index":          5
		"specs-registry":          5
		"docs-readme":             5
		"docs-novelty":            5
		"github-repo":             6
		"cf-pages":                7
		"ci-workflow":             7
		"grdn-mirror":             7
		"site-build":              8
		"context-canonical-url":   8
		"ci-auto-deploy":          8
		"ci-regen-check":          9
		"charter-status-tracking": 9
		"site-data-locality":      9
		"charter-live-viz":        10
		"kb-charter-bridge":       10
		"grdn-site-deploy":        10
		"projections-dashboard":   10
		"charter-cpm-overlay":     11
	}
	ancestors: {
		"repo-scaffold": {}
		"resource-schema": {"repo-scaffold": true}
		"type-registry": {"repo-scaffold": true}
		"jsonld-context": {"repo-scaffold": true}
		"viz-contract": {"repo-scaffold": true}
		"graph-engine": {"repo-scaffold": true, "resource-schema": true}
		"safeid-constraints": {"repo-scaffold": true, "resource-schema": true}
		"w3c-namespace-cleanup": {"jsonld-context": true, "repo-scaffold": true}
		"analysis-patterns": {"graph-engine": true, "repo-scaffold": true, "resource-schema": true}
		"validation-patterns": {"graph-engine": true, "repo-scaffold": true, "resource-schema": true}
		"lifecycle-patterns": {"graph-engine": true, "repo-scaffold": true, "resource-schema": true}
		"charter-module": {"graph-engine": true, "repo-scaffold": true, "resource-schema": true}
		"kb-setup": {"graph-engine": true, "repo-scaffold": true, "resource-schema": true}
		"quicue-semantic-sync": {"jsonld-context": true, "repo-scaffold": true, "w3c-namespace-cleanup": true}
		"owl-time-projection": {"analysis-patterns": true, "graph-engine": true, "repo-scaffold": true, "resource-schema": true}
		"example-recipe": {"analysis-patterns": true, "graph-engine": true, "repo-scaffold": true, "resource-schema": true}
		"skos-projection": {"graph-engine": true, "lifecycle-patterns": true, "repo-scaffold": true, "resource-schema": true, "type-registry": true}
		"earl-projection": {"graph-engine": true, "lifecycle-patterns": true, "repo-scaffold": true, "resource-schema": true}
		"shacl-projection": {"charter-module": true, "graph-engine": true, "repo-scaffold": true, "resource-schema": true, "validation-patterns": true}
		"example-course-prereqs": {"analysis-patterns": true, "charter-module": true, "graph-engine": true, "repo-scaffold": true, "resource-schema": true, "validation-patterns": true}
		"example-project-tracker": {"analysis-patterns": true, "charter-module": true, "graph-engine": true, "repo-scaffold": true, "resource-schema": true}
		"example-supply-chain": {"analysis-patterns": true, "charter-module": true, "graph-engine": true, "repo-scaffold": true, "resource-schema": true, "validation-patterns": true}
		"docs-w3c-index": {"analysis-patterns": true, "charter-module": true, "graph-engine": true, "lifecycle-patterns": true, "owl-time-projection": true, "repo-scaffold": true, "resource-schema": true, "shacl-projection": true, "skos-projection": true, "type-registry": true, "validation-patterns": true}
		"specs-registry": {"analysis-patterns": true, "charter-module": true, "earl-projection": true, "graph-engine": true, "lifecycle-patterns": true, "owl-time-projection": true, "repo-scaffold": true, "resource-schema": true, "shacl-projection": true, "skos-projection": true, "type-registry": true, "validation-patterns": true}
		"docs-readme": {"analysis-patterns": true, "charter-module": true, "example-course-prereqs": true, "graph-engine": true, "repo-scaffold": true, "resource-schema": true, "validation-patterns": true}
		"docs-novelty": {"analysis-patterns": true, "charter-module": true, "example-course-prereqs": true, "graph-engine": true, "repo-scaffold": true, "resource-schema": true, "validation-patterns": true}
		"github-repo": {"analysis-patterns": true, "charter-module": true, "docs-readme": true, "example-course-prereqs": true, "graph-engine": true, "kb-setup": true, "repo-scaffold": true, "resource-schema": true, "validation-patterns": true}
		"cf-pages": {"analysis-patterns": true, "charter-module": true, "docs-readme": true, "example-course-prereqs": true, "github-repo": true, "graph-engine": true, "kb-setup": true, "repo-scaffold": true, "resource-schema": true, "validation-patterns": true}
		"ci-workflow": {"analysis-patterns": true, "charter-module": true, "docs-readme": true, "example-course-prereqs": true, "github-repo": true, "graph-engine": true, "kb-setup": true, "repo-scaffold": true, "resource-schema": true, "safeid-constraints": true, "validation-patterns": true}
		"grdn-mirror": {"analysis-patterns": true, "charter-module": true, "docs-readme": true, "example-course-prereqs": true, "github-repo": true, "graph-engine": true, "kb-setup": true, "repo-scaffold": true, "resource-schema": true, "validation-patterns": true}
		"site-build": {"analysis-patterns": true, "cf-pages": true, "charter-module": true, "docs-readme": true, "earl-projection": true, "example-course-prereqs": true, "github-repo": true, "graph-engine": true, "kb-setup": true, "lifecycle-patterns": true, "owl-time-projection": true, "repo-scaffold": true, "resource-schema": true, "shacl-projection": true, "skos-projection": true, "specs-registry": true, "type-registry": true, "validation-patterns": true}
		"context-canonical-url": {"analysis-patterns": true, "cf-pages": true, "charter-module": true, "docs-readme": true, "example-course-prereqs": true, "github-repo": true, "graph-engine": true, "jsonld-context": true, "kb-setup": true, "repo-scaffold": true, "resource-schema": true, "validation-patterns": true, "w3c-namespace-cleanup": true}
		"ci-auto-deploy": {"analysis-patterns": true, "cf-pages": true, "charter-module": true, "ci-workflow": true, "docs-readme": true, "example-course-prereqs": true, "github-repo": true, "graph-engine": true, "kb-setup": true, "repo-scaffold": true, "resource-schema": true, "safeid-constraints": true, "validation-patterns": true}
		"ci-regen-check": {"analysis-patterns": true, "cf-pages": true, "charter-module": true, "ci-workflow": true, "docs-readme": true, "earl-projection": true, "example-course-prereqs": true, "github-repo": true, "graph-engine": true, "kb-setup": true, "lifecycle-patterns": true, "owl-time-projection": true, "repo-scaffold": true, "resource-schema": true, "safeid-constraints": true, "shacl-projection": true, "site-build": true, "skos-projection": true, "specs-registry": true, "type-registry": true, "validation-patterns": true}
		"charter-status-tracking": {"analysis-patterns": true, "cf-pages": true, "charter-module": true, "docs-readme": true, "earl-projection": true, "example-course-prereqs": true, "github-repo": true, "graph-engine": true, "kb-setup": true, "lifecycle-patterns": true, "owl-time-projection": true, "repo-scaffold": true, "resource-schema": true, "shacl-projection": true, "site-build": true, "skos-projection": true, "specs-registry": true, "type-registry": true, "validation-patterns": true}
		"site-data-locality": {"analysis-patterns": true, "cf-pages": true, "charter-module": true, "docs-readme": true, "earl-projection": true, "example-course-prereqs": true, "github-repo": true, "graph-engine": true, "kb-setup": true, "lifecycle-patterns": true, "owl-time-projection": true, "repo-scaffold": true, "resource-schema": true, "shacl-projection": true, "site-build": true, "skos-projection": true, "specs-registry": true, "type-registry": true, "validation-patterns": true}
		"charter-live-viz": {"analysis-patterns": true, "cf-pages": true, "charter-module": true, "charter-status-tracking": true, "docs-readme": true, "earl-projection": true, "example-course-prereqs": true, "github-repo": true, "graph-engine": true, "kb-setup": true, "lifecycle-patterns": true, "owl-time-projection": true, "repo-scaffold": true, "resource-schema": true, "shacl-projection": true, "site-build": true, "skos-projection": true, "specs-registry": true, "type-registry": true, "validation-patterns": true}
		"kb-charter-bridge": {"analysis-patterns": true, "cf-pages": true, "charter-module": true, "charter-status-tracking": true, "docs-readme": true, "earl-projection": true, "example-course-prereqs": true, "github-repo": true, "graph-engine": true, "kb-setup": true, "lifecycle-patterns": true, "owl-time-projection": true, "repo-scaffold": true, "resource-schema": true, "shacl-projection": true, "site-build": true, "skos-projection": true, "specs-registry": true, "type-registry": true, "validation-patterns": true}
		"grdn-site-deploy": {"analysis-patterns": true, "cf-pages": true, "charter-module": true, "docs-readme": true, "earl-projection": true, "example-course-prereqs": true, "github-repo": true, "graph-engine": true, "grdn-mirror": true, "kb-setup": true, "lifecycle-patterns": true, "owl-time-projection": true, "repo-scaffold": true, "resource-schema": true, "shacl-projection": true, "site-build": true, "site-data-locality": true, "skos-projection": true, "specs-registry": true, "type-registry": true, "validation-patterns": true}
		"projections-dashboard": {"analysis-patterns": true, "cf-pages": true, "charter-module": true, "docs-readme": true, "earl-projection": true, "example-course-prereqs": true, "github-repo": true, "graph-engine": true, "kb-setup": true, "lifecycle-patterns": true, "owl-time-projection": true, "repo-scaffold": true, "resource-schema": true, "shacl-projection": true, "site-build": true, "site-data-locality": true, "skos-projection": true, "specs-registry": true, "type-registry": true, "validation-patterns": true}
		"charter-cpm-overlay": {"analysis-patterns": true, "cf-pages": true, "charter-live-viz": true, "charter-module": true, "charter-status-tracking": true, "docs-readme": true, "earl-projection": true, "example-course-prereqs": true, "github-repo": true, "graph-engine": true, "kb-setup": true, "lifecycle-patterns": true, "owl-time-projection": true, "repo-scaffold": true, "resource-schema": true, "shacl-projection": true, "site-build": true, "skos-projection": true, "specs-registry": true, "type-registry": true, "validation-patterns": true}
	}
	dependents: {
		"repo-scaffold": {"analysis-patterns": true, "cf-pages": true, "charter-cpm-overlay": true, "charter-live-viz": true, "charter-module": true, "charter-status-tracking": true, "ci-auto-deploy": true, "ci-regen-check": true, "ci-workflow": true, "context-canonical-url": true, "docs-novelty": true, "docs-readme": true, "docs-w3c-index": true, "earl-projection": true, "example-course-prereqs": true, "example-project-tracker": true, "example-recipe": true, "example-supply-chain": true, "github-repo": true, "graph-engine": true, "grdn-mirror": true, "grdn-site-deploy": true, "jsonld-context": true, "kb-charter-bridge": true, "kb-setup": true, "lifecycle-patterns": true, "owl-time-projection": true, "projections-dashboard": true, "quicue-semantic-sync": true, "resource-schema": true, "safeid-constraints": true, "shacl-projection": true, "site-build": true, "site-data-locality": true, "skos-projection": true, "specs-registry": true, "type-registry": true, "validation-patterns": true, "viz-contract": true, "w3c-namespace-cleanup": true}
		"resource-schema": {"analysis-patterns": true, "cf-pages": true, "charter-cpm-overlay": true, "charter-live-viz": true, "charter-module": true, "charter-status-tracking": true, "ci-auto-deploy": true, "ci-regen-check": true, "ci-workflow": true, "context-canonical-url": true, "docs-novelty": true, "docs-readme": true, "docs-w3c-index": true, "earl-projection": true, "example-course-prereqs": true, "example-project-tracker": true, "example-recipe": true, "example-supply-chain": true, "github-repo": true, "graph-engine": true, "grdn-mirror": true, "grdn-site-deploy": true, "kb-charter-bridge": true, "kb-setup": true, "lifecycle-patterns": true, "owl-time-projection": true, "projections-dashboard": true, "safeid-constraints": true, "shacl-projection": true, "site-build": true, "site-data-locality": true, "skos-projection": true, "specs-registry": true, "validation-patterns": true}
		"type-registry": {"charter-cpm-overlay": true, "charter-live-viz": true, "charter-status-tracking": true, "ci-regen-check": true, "docs-w3c-index": true, "grdn-site-deploy": true, "kb-charter-bridge": true, "projections-dashboard": true, "site-build": true, "site-data-locality": true, "skos-projection": true, "specs-registry": true}
		"jsonld-context": {"context-canonical-url": true, "quicue-semantic-sync": true, "w3c-namespace-cleanup": true}
		"viz-contract": {}
		"graph-engine": {"analysis-patterns": true, "cf-pages": true, "charter-cpm-overlay": true, "charter-live-viz": true, "charter-module": true, "charter-status-tracking": true, "ci-auto-deploy": true, "ci-regen-check": true, "ci-workflow": true, "context-canonical-url": true, "docs-novelty": true, "docs-readme": true, "docs-w3c-index": true, "earl-projection": true, "example-course-prereqs": true, "example-project-tracker": true, "example-recipe": true, "example-supply-chain": true, "github-repo": true, "grdn-mirror": true, "grdn-site-deploy": true, "kb-charter-bridge": true, "kb-setup": true, "lifecycle-patterns": true, "owl-time-projection": true, "projections-dashboard": true, "shacl-projection": true, "site-build": true, "site-data-locality": true, "skos-projection": true, "specs-registry": true, "validation-patterns": true}
		"safeid-constraints": {"ci-auto-deploy": true, "ci-regen-check": true, "ci-workflow": true}
		"w3c-namespace-cleanup": {"context-canonical-url": true, "quicue-semantic-sync": true}
		"analysis-patterns": {"cf-pages": true, "charter-cpm-overlay": true, "charter-live-viz": true, "charter-status-tracking": true, "ci-auto-deploy": true, "ci-regen-check": true, "ci-workflow": true, "context-canonical-url": true, "docs-novelty": true, "docs-readme": true, "docs-w3c-index": true, "example-course-prereqs": true, "example-project-tracker": true, "example-recipe": true, "example-supply-chain": true, "github-repo": true, "grdn-mirror": true, "grdn-site-deploy": true, "kb-charter-bridge": true, "owl-time-projection": true, "projections-dashboard": true, "site-build": true, "site-data-locality": true, "specs-registry": true}
		"validation-patterns": {"cf-pages": true, "charter-cpm-overlay": true, "charter-live-viz": true, "charter-status-tracking": true, "ci-auto-deploy": true, "ci-regen-check": true, "ci-workflow": true, "context-canonical-url": true, "docs-novelty": true, "docs-readme": true, "docs-w3c-index": true, "example-course-prereqs": true, "example-supply-chain": true, "github-repo": true, "grdn-mirror": true, "grdn-site-deploy": true, "kb-charter-bridge": true, "projections-dashboard": true, "shacl-projection": true, "site-build": true, "site-data-locality": true, "specs-registry": true}
		"lifecycle-patterns": {"charter-cpm-overlay": true, "charter-live-viz": true, "charter-status-tracking": true, "ci-regen-check": true, "docs-w3c-index": true, "earl-projection": true, "grdn-site-deploy": true, "kb-charter-bridge": true, "projections-dashboard": true, "site-build": true, "site-data-locality": true, "skos-projection": true, "specs-registry": true}
		"charter-module": {"cf-pages": true, "charter-cpm-overlay": true, "charter-live-viz": true, "charter-status-tracking": true, "ci-auto-deploy": true, "ci-regen-check": true, "ci-workflow": true, "context-canonical-url": true, "docs-novelty": true, "docs-readme": true, "docs-w3c-index": true, "example-course-prereqs": true, "example-project-tracker": true, "example-supply-chain": true, "github-repo": true, "grdn-mirror": true, "grdn-site-deploy": true, "kb-charter-bridge": true, "projections-dashboard": true, "shacl-projection": true, "site-build": true, "site-data-locality": true, "specs-registry": true}
		"kb-setup": {"cf-pages": true, "charter-cpm-overlay": true, "charter-live-viz": true, "charter-status-tracking": true, "ci-auto-deploy": true, "ci-regen-check": true, "ci-workflow": true, "context-canonical-url": true, "github-repo": true, "grdn-mirror": true, "grdn-site-deploy": true, "kb-charter-bridge": true, "projections-dashboard": true, "site-build": true, "site-data-locality": true}
		"quicue-semantic-sync": {}
		"owl-time-projection": {"charter-cpm-overlay": true, "charter-live-viz": true, "charter-status-tracking": true, "ci-regen-check": true, "docs-w3c-index": true, "grdn-site-deploy": true, "kb-charter-bridge": true, "projections-dashboard": true, "site-build": true, "site-data-locality": true, "specs-registry": true}
		"example-recipe": {}
		"skos-projection": {"charter-cpm-overlay": true, "charter-live-viz": true, "charter-status-tracking": true, "ci-regen-check": true, "docs-w3c-index": true, "grdn-site-deploy": true, "kb-charter-bridge": true, "projections-dashboard": true, "site-build": true, "site-data-locality": true, "specs-registry": true}
		"earl-projection": {"charter-cpm-overlay": true, "charter-live-viz": true, "charter-status-tracking": true, "ci-regen-check": true, "grdn-site-deploy": true, "kb-charter-bridge": true, "projections-dashboard": true, "site-build": true, "site-data-locality": true, "specs-registry": true}
		"shacl-projection": {"charter-cpm-overlay": true, "charter-live-viz": true, "charter-status-tracking": true, "ci-regen-check": true, "docs-w3c-index": true, "grdn-site-deploy": true, "kb-charter-bridge": true, "projections-dashboard": true, "site-build": true, "site-data-locality": true, "specs-registry": true}
		"example-course-prereqs": {"cf-pages": true, "charter-cpm-overlay": true, "charter-live-viz": true, "charter-status-tracking": true, "ci-auto-deploy": true, "ci-regen-check": true, "ci-workflow": true, "context-canonical-url": true, "docs-novelty": true, "docs-readme": true, "github-repo": true, "grdn-mirror": true, "grdn-site-deploy": true, "kb-charter-bridge": true, "projections-dashboard": true, "site-build": true, "site-data-locality": true}
		"example-project-tracker": {}
		"example-supply-chain": {}
		"docs-w3c-index": {}
		"specs-registry": {"charter-cpm-overlay": true, "charter-live-viz": true, "charter-status-tracking": true, "ci-regen-check": true, "grdn-site-deploy": true, "kb-charter-bridge": true, "projections-dashboard": true, "site-build": true, "site-data-locality": true, "spec-v2-update": true}
		"docs-readme": {"cf-pages": true, "charter-cpm-overlay": true, "charter-live-viz": true, "charter-status-tracking": true, "ci-auto-deploy": true, "ci-regen-check": true, "ci-workflow": true, "context-canonical-url": true, "github-repo": true, "grdn-mirror": true, "grdn-site-deploy": true, "kb-charter-bridge": true, "projections-dashboard": true, "site-build": true, "site-data-locality": true}
		"docs-novelty": {}
		"github-repo": {"cf-pages": true, "charter-cpm-overlay": true, "charter-live-viz": true, "charter-status-tracking": true, "ci-auto-deploy": true, "ci-regen-check": true, "ci-workflow": true, "context-canonical-url": true, "grdn-mirror": true, "grdn-site-deploy": true, "kb-charter-bridge": true, "projections-dashboard": true, "site-build": true, "site-data-locality": true}
		"cf-pages": {"charter-cpm-overlay": true, "charter-live-viz": true, "charter-status-tracking": true, "ci-auto-deploy": true, "ci-regen-check": true, "context-canonical-url": true, "grdn-site-deploy": true, "kb-charter-bridge": true, "projections-dashboard": true, "site-build": true, "site-data-locality": true}
		"ci-workflow": {"ci-auto-deploy": true, "ci-regen-check": true}
		"grdn-mirror": {"grdn-site-deploy": true}
		"site-build": {"charter-cpm-overlay": true, "charter-live-viz": true, "charter-status-tracking": true, "ci-regen-check": true, "grdn-site-deploy": true, "kb-charter-bridge": true, "projections-dashboard": true, "site-data-locality": true}
		"context-canonical-url": {}
		"ci-auto-deploy": {}
		"ci-regen-check": {}
		"charter-status-tracking": {"charter-cpm-overlay": true, "charter-live-viz": true, "kb-charter-bridge": true}
		"site-data-locality": {"grdn-site-deploy": true, "projections-dashboard": true}
		"charter-live-viz": {"charter-cpm-overlay": true}
		"kb-charter-bridge": {}
		"grdn-site-deploy": {}
		"projections-dashboard": {}
		"charter-cpm-overlay": {}
	}
}

_precomputed_cpm: {
	earliest: {
		"repo-scaffold":           0
		"resource-schema":         1
		"type-registry":           1
		"jsonld-context":          1
		"viz-contract":            1
		"graph-engine":            2
		"safeid-constraints":      2
		"w3c-namespace-cleanup":   2
		"analysis-patterns":       3
		"validation-patterns":     3
		"lifecycle-patterns":      3
		"charter-module":          3
		"kb-setup":                3
		"quicue-semantic-sync":    3
		"owl-time-projection":     4
		"example-recipe":          4
		"skos-projection":         4
		"earl-projection":         4
		"shacl-projection":        4
		"example-course-prereqs":  4
		"example-project-tracker": 4
		"example-supply-chain":    4
		"docs-w3c-index":          5
		"specs-registry":          5
		"docs-readme":             5
		"docs-novelty":            5
		"github-repo":             6
		"cf-pages":                7
		"ci-workflow":             7
		"grdn-mirror":             7
		"site-build":              8
		"context-canonical-url":   8
		"ci-auto-deploy":          8
		"ci-regen-check":          9
		"charter-status-tracking": 9
		"site-data-locality":      9
		"charter-live-viz":        10
		"kb-charter-bridge":       10
		"grdn-site-deploy":        10
		"projections-dashboard":   10
		"charter-cpm-overlay":     11
	}
	latest: {
		"repo-scaffold":           0
		"resource-schema":         1
		"type-registry":           5
		"jsonld-context":          9
		"viz-contract":            11
		"graph-engine":            2
		"safeid-constraints":      9
		"w3c-namespace-cleanup":   10
		"analysis-patterns":       3
		"validation-patterns":     3
		"lifecycle-patterns":      5
		"charter-module":          3
		"kb-setup":                5
		"quicue-semantic-sync":    11
		"owl-time-projection":     6
		"example-recipe":          11
		"skos-projection":         6
		"earl-projection":         6
		"shacl-projection":        6
		"example-course-prereqs":  4
		"example-project-tracker": 11
		"example-supply-chain":    11
		"docs-w3c-index":          11
		"specs-registry":          7
		"docs-readme":             5
		"docs-novelty":            11
		"github-repo":             6
		"cf-pages":                7
		"ci-workflow":             10
		"grdn-mirror":             10
		"site-build":              8
		"context-canonical-url":   11
		"ci-auto-deploy":          11
		"ci-regen-check":          11
		"charter-status-tracking": 9
		"site-data-locality":      10
		"charter-live-viz":        10
		"kb-charter-bridge":       11
		"grdn-site-deploy":        11
		"projections-dashboard":   11
		"charter-cpm-overlay":     11
	}
	duration: {
		"repo-scaffold":           1
		"resource-schema":         1
		"type-registry":           1
		"jsonld-context":          1
		"viz-contract":            1
		"graph-engine":            1
		"safeid-constraints":      1
		"w3c-namespace-cleanup":   1
		"analysis-patterns":       1
		"validation-patterns":     1
		"lifecycle-patterns":      1
		"charter-module":          1
		"kb-setup":                1
		"quicue-semantic-sync":    1
		"owl-time-projection":     1
		"example-recipe":          1
		"skos-projection":         1
		"earl-projection":         1
		"shacl-projection":        1
		"example-course-prereqs":  1
		"example-project-tracker": 1
		"example-supply-chain":    1
		"docs-w3c-index":          1
		"specs-registry":          1
		"docs-readme":             1
		"docs-novelty":            1
		"github-repo":             1
		"cf-pages":                1
		"ci-workflow":             1
		"grdn-mirror":             1
		"site-build":              1
		"context-canonical-url":   1
		"ci-auto-deploy":          1
		"ci-regen-check":          1
		"charter-status-tracking": 1
		"site-data-locality":      1
		"charter-live-viz":        1
		"kb-charter-bridge":       1
		"grdn-site-deploy":        1
		"projections-dashboard":   1
		"charter-cpm-overlay":     1
	}
}
