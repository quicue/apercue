// Validation specification schemas for CUE workflow commands.
//
// Declares what validation checks a project supports.
// Validated at `cue vet` time.

package tools

// #ValidateSpec declares the validation pipeline for a project.
#ValidateSpec: {
	// Script-based validation (e.g. count checks)
	count_script: *null | =~"\\.(sh|py)$"

	// Packages to vet (with -c flag for concrete check)
	vet_packages: [...=~"^\\./"]

	// Named analysis exports
	analyses: [string]: #AnalysisExport
}

// #AnalysisExport declares a single analysis projection.
#AnalysisExport: {
	// CUE package path
	package_path: =~"^\\./"

	// CUE expression to evaluate
	expression: =~"^[a-zA-Z_][a-zA-Z0-9_.]*$"

	// Human-readable description
	description: string

	// Expected output type (for documentation)
	w3c_type: *"" | string
}
