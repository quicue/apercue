package main

_precomputed: {
	depth: {
		"repo-scaffold": 0
		"resource-schema": 1
		"type-registry": 1
		"jsonld-context": 1
		"viz-contract": 1
		"graph-engine": 2
		"safeid-constraints": 2
		"w3c-namespace-cleanup": 2
		"analysis-patterns": 3
		"validation-patterns": 3
		"lifecycle-patterns": 3
		"charter-module": 3
		"kb-setup": 3
		"quicue-semantic-sync": 3
		"owl-time-projection": 4
		"example-recipe": 4
		"skos-projection": 4
		"earl-projection": 4
		"shacl-projection": 4
		"example-course-prereqs": 4
		"example-project-tracker": 4
		"example-supply-chain": 4
		"docs-w3c-index": 5
		"specs-registry": 5
		"docs-readme": 5
		"docs-novelty": 5
		"respec-projection": 6
		"github-repo": 6
		"cf-pages": 7
		"ci-workflow": 7
		"grdn-mirror": 7
		"site-build": 8
		"context-canonical-url": 8
		"ci-auto-deploy": 8
		"ci-regen-check": 9
		"charter-status-tracking": 9
		"charter-live-viz": 10
		"kb-charter-bridge": 10
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
		"respec-projection": {"analysis-patterns": true, "charter-module": true, "earl-projection": true, "graph-engine": true, "lifecycle-patterns": true, "owl-time-projection": true, "repo-scaffold": true, "resource-schema": true, "safeid-constraints": true, "shacl-projection": true, "skos-projection": true, "specs-registry": true, "type-registry": true, "validation-patterns": true}
		"github-repo": {"analysis-patterns": true, "charter-module": true, "docs-readme": true, "example-course-prereqs": true, "graph-engine": true, "kb-setup": true, "repo-scaffold": true, "resource-schema": true, "validation-patterns": true}
		"cf-pages": {"analysis-patterns": true, "charter-module": true, "docs-readme": true, "example-course-prereqs": true, "github-repo": true, "graph-engine": true, "kb-setup": true, "repo-scaffold": true, "resource-schema": true, "validation-patterns": true}
		"ci-workflow": {"analysis-patterns": true, "charter-module": true, "docs-readme": true, "example-course-prereqs": true, "github-repo": true, "graph-engine": true, "kb-setup": true, "repo-scaffold": true, "resource-schema": true, "safeid-constraints": true, "validation-patterns": true}
		"grdn-mirror": {"analysis-patterns": true, "charter-module": true, "docs-readme": true, "example-course-prereqs": true, "github-repo": true, "graph-engine": true, "kb-setup": true, "repo-scaffold": true, "resource-schema": true, "validation-patterns": true}
		"site-build": {"analysis-patterns": true, "cf-pages": true, "charter-module": true, "docs-readme": true, "earl-projection": true, "example-course-prereqs": true, "github-repo": true, "graph-engine": true, "kb-setup": true, "lifecycle-patterns": true, "owl-time-projection": true, "repo-scaffold": true, "resource-schema": true, "shacl-projection": true, "skos-projection": true, "specs-registry": true, "type-registry": true, "validation-patterns": true}
		"context-canonical-url": {"analysis-patterns": true, "cf-pages": true, "charter-module": true, "docs-readme": true, "example-course-prereqs": true, "github-repo": true, "graph-engine": true, "jsonld-context": true, "kb-setup": true, "repo-scaffold": true, "resource-schema": true, "validation-patterns": true, "w3c-namespace-cleanup": true}
		"ci-auto-deploy": {"analysis-patterns": true, "cf-pages": true, "charter-module": true, "ci-workflow": true, "docs-readme": true, "example-course-prereqs": true, "github-repo": true, "graph-engine": true, "kb-setup": true, "repo-scaffold": true, "resource-schema": true, "safeid-constraints": true, "validation-patterns": true}
		"ci-regen-check": {"analysis-patterns": true, "cf-pages": true, "charter-module": true, "ci-workflow": true, "docs-readme": true, "earl-projection": true, "example-course-prereqs": true, "github-repo": true, "graph-engine": true, "kb-setup": true, "lifecycle-patterns": true, "owl-time-projection": true, "repo-scaffold": true, "resource-schema": true, "safeid-constraints": true, "shacl-projection": true, "site-build": true, "skos-projection": true, "specs-registry": true, "type-registry": true, "validation-patterns": true}
		"charter-status-tracking": {"analysis-patterns": true, "cf-pages": true, "charter-module": true, "docs-readme": true, "earl-projection": true, "example-course-prereqs": true, "github-repo": true, "graph-engine": true, "kb-setup": true, "lifecycle-patterns": true, "owl-time-projection": true, "repo-scaffold": true, "resource-schema": true, "shacl-projection": true, "site-build": true, "skos-projection": true, "specs-registry": true, "type-registry": true, "validation-patterns": true}
		"charter-live-viz": {"analysis-patterns": true, "cf-pages": true, "charter-module": true, "charter-status-tracking": true, "docs-readme": true, "earl-projection": true, "example-course-prereqs": true, "github-repo": true, "graph-engine": true, "kb-setup": true, "lifecycle-patterns": true, "owl-time-projection": true, "repo-scaffold": true, "resource-schema": true, "shacl-projection": true, "site-build": true, "skos-projection": true, "specs-registry": true, "type-registry": true, "validation-patterns": true}
		"kb-charter-bridge": {"analysis-patterns": true, "cf-pages": true, "charter-module": true, "charter-status-tracking": true, "docs-readme": true, "earl-projection": true, "example-course-prereqs": true, "github-repo": true, "graph-engine": true, "kb-setup": true, "lifecycle-patterns": true, "owl-time-projection": true, "repo-scaffold": true, "resource-schema": true, "shacl-projection": true, "site-build": true, "skos-projection": true, "specs-registry": true, "type-registry": true, "validation-patterns": true}
	}
	dependents: {
		"repo-scaffold": {"analysis-patterns": true, "cf-pages": true, "charter-live-viz": true, "charter-module": true, "charter-status-tracking": true, "ci-auto-deploy": true, "ci-regen-check": true, "ci-workflow": true, "context-canonical-url": true, "docs-novelty": true, "docs-readme": true, "docs-w3c-index": true, "earl-projection": true, "example-course-prereqs": true, "example-project-tracker": true, "example-recipe": true, "example-supply-chain": true, "github-repo": true, "graph-engine": true, "grdn-mirror": true, "jsonld-context": true, "kb-charter-bridge": true, "kb-setup": true, "lifecycle-patterns": true, "owl-time-projection": true, "quicue-semantic-sync": true, "resource-schema": true, "respec-projection": true, "safeid-constraints": true, "shacl-projection": true, "site-build": true, "skos-projection": true, "specs-registry": true, "type-registry": true, "validation-patterns": true, "viz-contract": true, "w3c-namespace-cleanup": true}
		"resource-schema": {"analysis-patterns": true, "cf-pages": true, "charter-live-viz": true, "charter-module": true, "charter-status-tracking": true, "ci-auto-deploy": true, "ci-regen-check": true, "ci-workflow": true, "context-canonical-url": true, "docs-novelty": true, "docs-readme": true, "docs-w3c-index": true, "earl-projection": true, "example-course-prereqs": true, "example-project-tracker": true, "example-recipe": true, "example-supply-chain": true, "github-repo": true, "graph-engine": true, "grdn-mirror": true, "kb-charter-bridge": true, "kb-setup": true, "lifecycle-patterns": true, "owl-time-projection": true, "respec-projection": true, "safeid-constraints": true, "shacl-projection": true, "site-build": true, "skos-projection": true, "specs-registry": true, "validation-patterns": true}
		"type-registry": {"charter-live-viz": true, "charter-status-tracking": true, "ci-regen-check": true, "docs-w3c-index": true, "kb-charter-bridge": true, "respec-projection": true, "site-build": true, "skos-projection": true, "specs-registry": true}
		"jsonld-context": {"context-canonical-url": true, "quicue-semantic-sync": true, "w3c-namespace-cleanup": true}
		"viz-contract": {}
		"graph-engine": {"analysis-patterns": true, "cf-pages": true, "charter-live-viz": true, "charter-module": true, "charter-status-tracking": true, "ci-auto-deploy": true, "ci-regen-check": true, "ci-workflow": true, "context-canonical-url": true, "docs-novelty": true, "docs-readme": true, "docs-w3c-index": true, "earl-projection": true, "example-course-prereqs": true, "example-project-tracker": true, "example-recipe": true, "example-supply-chain": true, "github-repo": true, "grdn-mirror": true, "kb-charter-bridge": true, "kb-setup": true, "lifecycle-patterns": true, "owl-time-projection": true, "respec-projection": true, "shacl-projection": true, "site-build": true, "skos-projection": true, "specs-registry": true, "validation-patterns": true}
		"safeid-constraints": {"ci-auto-deploy": true, "ci-regen-check": true, "ci-workflow": true, "respec-projection": true}
		"w3c-namespace-cleanup": {"context-canonical-url": true, "quicue-semantic-sync": true}
		"analysis-patterns": {"cf-pages": true, "charter-live-viz": true, "charter-status-tracking": true, "ci-auto-deploy": true, "ci-regen-check": true, "ci-workflow": true, "context-canonical-url": true, "docs-novelty": true, "docs-readme": true, "docs-w3c-index": true, "example-course-prereqs": true, "example-project-tracker": true, "example-recipe": true, "example-supply-chain": true, "github-repo": true, "grdn-mirror": true, "kb-charter-bridge": true, "owl-time-projection": true, "respec-projection": true, "site-build": true, "specs-registry": true}
		"validation-patterns": {"cf-pages": true, "charter-live-viz": true, "charter-status-tracking": true, "ci-auto-deploy": true, "ci-regen-check": true, "ci-workflow": true, "context-canonical-url": true, "docs-novelty": true, "docs-readme": true, "docs-w3c-index": true, "example-course-prereqs": true, "example-supply-chain": true, "github-repo": true, "grdn-mirror": true, "kb-charter-bridge": true, "respec-projection": true, "shacl-projection": true, "site-build": true, "specs-registry": true}
		"lifecycle-patterns": {"charter-live-viz": true, "charter-status-tracking": true, "ci-regen-check": true, "docs-w3c-index": true, "earl-projection": true, "kb-charter-bridge": true, "respec-projection": true, "site-build": true, "skos-projection": true, "specs-registry": true}
		"charter-module": {"cf-pages": true, "charter-live-viz": true, "charter-status-tracking": true, "ci-auto-deploy": true, "ci-regen-check": true, "ci-workflow": true, "context-canonical-url": true, "docs-novelty": true, "docs-readme": true, "docs-w3c-index": true, "example-course-prereqs": true, "example-project-tracker": true, "example-supply-chain": true, "github-repo": true, "grdn-mirror": true, "kb-charter-bridge": true, "respec-projection": true, "shacl-projection": true, "site-build": true, "specs-registry": true}
		"kb-setup": {"cf-pages": true, "charter-live-viz": true, "charter-status-tracking": true, "ci-auto-deploy": true, "ci-regen-check": true, "ci-workflow": true, "context-canonical-url": true, "github-repo": true, "grdn-mirror": true, "kb-charter-bridge": true, "site-build": true}
		"quicue-semantic-sync": {}
		"owl-time-projection": {"charter-live-viz": true, "charter-status-tracking": true, "ci-regen-check": true, "docs-w3c-index": true, "kb-charter-bridge": true, "respec-projection": true, "site-build": true, "specs-registry": true}
		"example-recipe": {}
		"skos-projection": {"charter-live-viz": true, "charter-status-tracking": true, "ci-regen-check": true, "docs-w3c-index": true, "kb-charter-bridge": true, "respec-projection": true, "site-build": true, "specs-registry": true}
		"earl-projection": {"charter-live-viz": true, "charter-status-tracking": true, "ci-regen-check": true, "kb-charter-bridge": true, "respec-projection": true, "site-build": true, "specs-registry": true}
		"shacl-projection": {"charter-live-viz": true, "charter-status-tracking": true, "ci-regen-check": true, "docs-w3c-index": true, "kb-charter-bridge": true, "respec-projection": true, "site-build": true, "specs-registry": true}
		"example-course-prereqs": {"cf-pages": true, "charter-live-viz": true, "charter-status-tracking": true, "ci-auto-deploy": true, "ci-regen-check": true, "ci-workflow": true, "context-canonical-url": true, "docs-novelty": true, "docs-readme": true, "github-repo": true, "grdn-mirror": true, "kb-charter-bridge": true, "site-build": true}
		"example-project-tracker": {}
		"example-supply-chain": {}
		"docs-w3c-index": {}
		"specs-registry": {"charter-live-viz": true, "charter-status-tracking": true, "ci-regen-check": true, "kb-charter-bridge": true, "respec-projection": true, "site-build": true}
		"docs-readme": {"cf-pages": true, "charter-live-viz": true, "charter-status-tracking": true, "ci-auto-deploy": true, "ci-regen-check": true, "ci-workflow": true, "context-canonical-url": true, "github-repo": true, "grdn-mirror": true, "kb-charter-bridge": true, "site-build": true}
		"docs-novelty": {}
		"respec-projection": {}
		"github-repo": {"cf-pages": true, "charter-live-viz": true, "charter-status-tracking": true, "ci-auto-deploy": true, "ci-regen-check": true, "ci-workflow": true, "context-canonical-url": true, "grdn-mirror": true, "kb-charter-bridge": true, "site-build": true}
		"cf-pages": {"charter-live-viz": true, "charter-status-tracking": true, "ci-auto-deploy": true, "ci-regen-check": true, "context-canonical-url": true, "kb-charter-bridge": true, "site-build": true}
		"ci-workflow": {"ci-auto-deploy": true, "ci-regen-check": true}
		"grdn-mirror": {}
		"site-build": {"charter-live-viz": true, "charter-status-tracking": true, "ci-regen-check": true, "kb-charter-bridge": true}
		"context-canonical-url": {}
		"ci-auto-deploy": {}
		"ci-regen-check": {}
		"charter-status-tracking": {"charter-live-viz": true, "kb-charter-bridge": true}
		"charter-live-viz": {}
		"kb-charter-bridge": {}
	}
}
