package apercue

import (
	"tool/cli"
	"tool/exec"
	"tool/file"

	"apercue.ca/tools@v0"
)

// ── Deploy specification ────────────────────────────────────────────────
// Validated at `cue vet` time.

_deploy_spec: tools.#DeploySpec & {
	toposort_source:    "./self-charter/charter.cue"
	precomputed_output: "self-charter/precomputed.cue"
	vet_packages: ["./self-charter/"]
	build_command: "build"
	serve_port:    *"8384" | string @tag(port)
}

// ── Deploy command ──────────────────────────────────────────────────────

command: deploy: {
	$short: "Precompute topology, validate, and build all site data"

	toposort: exec.Run & {
		cmd: ["python3", "tools/toposort.py", _deploy_spec.toposort_source, "--cue"]
		stdout: string
	}
	write_precomputed: file.Create & {
		filename: _deploy_spec.precomputed_output
		contents: toposort.stdout
	}

	vet: exec.Run & {
		cmd: ["cue", "vet", _deploy_spec.vet_packages[0]]
		$after: write_precomputed
	}

	build_all: exec.Run & {
		cmd: ["cue", "cmd", _deploy_spec.build_command]
		$after: vet
	}

	done: cli.Print & {
		text: "Deploy build complete. Use 'cue cmd serve' to preview or rsync to target."
		$after: build_all
	}
}

// ── Serve command ───────────────────────────────────────────────────────

command: serve: {
	$short: "Serve site locally for preview"

	info: cli.Print & {
		text: "Starting server on port " + _deploy_spec.serve_port + " — serving site/ directory"
	}
	server: exec.Run & {
		cmd: ["python3", "-m", "http.server", _deploy_spec.serve_port, "-d", "site"]
		$after: info
	}
}
