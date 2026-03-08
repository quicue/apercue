// Build specification schemas for CUE workflow commands.
//
// These schemas are importable by any downstream repo. They validate
// build configurations at `cue vet` time — before any command runs.
// Tool files (_tool.cue) unify with these to get type-checked specs.
//
// Import: import "apercue.ca/tools@v0"

package tools

// #ExportSpec declares a single CUE export task.
// Validated at vet time: paths, expressions, and output targets.
#ExportSpec: {
	// CUE package path to export from (e.g. "./self-charter/")
	package_path: =~"^\\./"

	// CUE expression to evaluate (e.g. "charter_viz")
	expression: =~"^[a-zA-Z_][a-zA-Z0-9_.]*$"

	// Output file path relative to module root
	output: =~"\\.(json|jsonld|yaml|txt)$"

	// Output format
	format: *"json" | "yaml" | "text"
}

// #PythonStep declares a Python script to run during build.
#PythonStep: {
	script: =~"\\.py$"
	args: [...string]
	// If true, failure is non-fatal (e.g. optional rendering)
	optional: *false | true
}

// #BuildSpec declares the full build pipeline for a project.
// Downstream repos unify their build config with this to get
// compile-time validation of all export paths and expressions.
#BuildSpec: {
	// Named exports — each produces one output file
	exports: [string]: #ExportSpec

	// Python steps to run after exports (e.g. report rendering)
	python_steps: [string]: #PythonStep

	// Staging configuration for public deployment
	staging: #StagingSpec | *null
}

// #StagingSpec declares which files to stage for public deployment.
#StagingSpec: {
	// Output directory for staged files
	dir: *"_public" | string

	// HTML files to copy from site/ (if they exist)
	html_files: [...=~"\\.html$"]

	// Data files to copy from site/data/ (if they exist)
	data_files: [...=~"\\.(json|jsonld)$"]

	// Additional directories to copy
	extra_dirs: [...string]
}
