// Module registry — all modules in this repo and their purpose
package kb

modules: {
	vocab: {
		path:        "vocab/"
		module:      "apercue.ca@v0"
		layer:       "definition"
		description: "Core schemas: #Resource, #TypeRegistry, JSON-LD @context, #VizData"
		status:      "active"
	}
	patterns: {
		path:        "patterns/"
		module:      "apercue.ca@v0"
		layer:       "definition"
		description: "Graph engine, analysis, validation, lifecycle, visualization"
		status:      "active"
		schemas: [
			"#Graph", "#CriticalPath", "#ComplianceCheck",
			"#CycleDetector", "#ConnectedComponents", "#Subgraph",
			"#GraphDiff", "#SinglePointsOfFailure",
			"#LifecyclePhasesSKOS", "#SmokeTest",
		]
	}
	charter: {
		path:        "charter/"
		module:      "apercue.ca@v0"
		layer:       "constraint"
		description: "Constraint-first planning: #Charter, #GapAnalysis, #Milestone"
		status:      "active"
		schemas:     ["#Charter", "#Gate", "#GapAnalysis", "#Milestone"]
		depends:     ["patterns"]
	}
	views: {
		path:        "views/"
		module:      "apercue.ca@v0"
		layer:       "projection"
		description: "SKOS type vocabulary projection"
		status:      "active"
		depends:     ["vocab"]
	}
	examples: {
		path:        "examples/"
		layer:       "value"
		description: "4 domain-agnostic examples proving generality"
		status:      "active"
		entries: [
			"course-prereqs",
			"recipe-ingredients",
			"project-tracker",
			"supply-chain",
		]
	}
}
