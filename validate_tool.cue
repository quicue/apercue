package apercue

import (
	"tool/cli"
	"tool/exec"

	"apercue.ca/tools@v0"
)

// ── Validate specification ──────────────────────────────────────────────
// Validated at `cue vet` time.

_validate_spec: tools.#ValidateSpec & {
	count_script: "tools/validate-counts.sh"
	vet_packages: ["./..."]
	analyses: {
		gap_analysis: {
			package_path: "./self-charter/"
			expression:   "gaps.shacl_report"
			description:  "Gap analysis as SHACL ValidationReport"
			w3c_type:     "sh:ValidationReport"
		}
		critical_path: {
			package_path: "./self-charter/"
			expression:   "cpm.summary"
			description:  "Critical path method summary"
		}
	}
}

// ── Validate command ────────────────────────────────────────────────────

command: validate: {
	$short: "Verify documentation counts match CUE data"

	run: exec.Run & {
		cmd: ["bash", _validate_spec.count_script]
		stdout:      string
		stderr:      string
		mustSucceed: false
	}
	print: cli.Print & {
		text: run.stdout
	}
}

// ── Vet-all command ─────────────────────────────────────────────────────

command: "vet-all": {
	$short: "Run full cross-package validation"

	vet: exec.Run & {
		cmd: ["cue", "vet", _validate_spec.vet_packages[0], "-c=false"]
		stderr: string
	}
	done: cli.Print & {
		text: "All packages validated."
		$after: vet
	}
}

// ── Gap analysis command ────────────────────────────────────────────────

command: "gap-analysis": {
	$short: _validate_spec.analyses.gap_analysis.description

	shacl: exec.Run & {
		cmd: ["cue", "export",
			_validate_spec.analyses.gap_analysis.package_path,
			"-e", _validate_spec.analyses.gap_analysis.expression,
			"--out", "json"]
		stdout: string
	}
	print: cli.Print & {
		text: shacl.stdout
	}
}

// ── Critical path command ───────────────────────────────────────────────

command: "critical-path": {
	$short: _validate_spec.analyses.critical_path.description

	cpm: exec.Run & {
		cmd: ["cue", "export",
			_validate_spec.analyses.critical_path.package_path,
			"-e", _validate_spec.analyses.critical_path.expression,
			"--out", "json"]
		stdout: string
	}
	print: cli.Print & {
		text: cpm.stdout
	}
}
