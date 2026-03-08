// Deploy specification schemas for CUE workflow commands.
//
// Declares the toposort → vet → build pipeline contract.
// Validated at `cue vet` time.

package tools

// #DeploySpec declares a deployment pipeline.
// The pipeline is: precompute topology → validate → build → (optional sync).
#DeploySpec: {
	// CUE file to read resources from (for toposort.py)
	toposort_source: =~"\\.cue$"

	// Where to write precomputed topology
	precomputed_output: =~"\\.cue$"

	// Packages to validate after precomputation
	vet_packages: [_, ...string] // at least one

	// Build command to run after validation
	build_command: *"build" | string

	// Default port for local preview server
	serve_port: *"8384" | =~"^[0-9]+$"
}
