package apercue

import (
	"strings"
	"tool/cli"
	"tool/exec"
	"tool/file"

	"apercue.ca/tools@v0"
)

// ── Build specification ─────────────────────────────────────────────────
// Validated at `cue vet` time. Every path, expression, and output target
// is type-checked by tools.#BuildSpec before any command runs.

_build_spec: tools.#BuildSpec & {
	exports: {
		specs:       {package_path: "./site/", expression: "site_specs", output: "site/data/specs.json"}
		spec_counts: {package_path: "./site/", expression: "site_spec_counts", output: "site/data/spec-counts.json"}
		vocab:       {package_path: "./vocab/", expression: "context", output: "site/vocab/context.jsonld"}
		charter:     {package_path: "./self-charter/", expression: "charter_viz", output: "site/data/charter.json"}
		ecosystem:   {package_path: "./self-charter/", expression: "eco_viz", output: "site/data/ecosystem.json"}
		projections: {package_path: "./self-charter/", expression: "projections", output: "site/data/projections.json"}
		taxonomy:    {package_path: "./self-charter/", expression: "type_vocabulary", output: "site/data/taxonomy.json"}
		recipe:      {package_path: "./examples/recipe-ingredients/", expression: "viz", output: "site/data/recipe.json"}
	}
	python_steps: {
		w3c_reports: {script: "tools/render-w3c-reports.py"}
	}
	staging: {
		dir: "_public"
		html_files: ["index.html", "explorer.html", "charter.html", "playground.html", "phase7.html", "recipe.html", "plan.html"]
		data_files: ["specs.json", "ecosystem.json", "charter.json", "projections.json", "phase7-charter.json", "recipe.json", "examples.json"]
		extra_dirs: ["w3c"]
	}
}

// ── Build command ───────────────────────────────────────────────────────
// Exec wiring — references _build_spec for paths and expressions.

command: build: {
	$short: "Build all site data from CUE exports"

	// Core exports (driven by spec)
	specs: exec.Run & {
		cmd: ["cue", "export", _build_spec.exports.specs.package_path, "-e", _build_spec.exports.specs.expression, "--out", "json"]
		stdout: string
	}
	spec_counts: exec.Run & {
		cmd: ["cue", "export", _build_spec.exports.spec_counts.package_path, "-e", _build_spec.exports.spec_counts.expression, "--out", "json"]
		stdout: string
	}
	write_specs: file.Create & {
		filename: _build_spec.exports.specs.output
		contents: specs.stdout
	}
	write_spec_counts: file.Create & {
		filename: _build_spec.exports.spec_counts.output
		contents: spec_counts.stdout
	}

	vocab_ctx: exec.Run & {
		cmd: ["cue", "export", _build_spec.exports.vocab.package_path, "-e", _build_spec.exports.vocab.expression, "--out", "json"]
		stdout: string
	}
	write_vocab: file.Create & {
		filename: _build_spec.exports.vocab.output
		contents: vocab_ctx.stdout
	}

	charter: exec.Run & {
		cmd: ["cue", "export", _build_spec.exports.charter.package_path, "-e", _build_spec.exports.charter.expression, "--out", "json"]
		stdout: string
	}
	ecosystem: exec.Run & {
		cmd: ["cue", "export", _build_spec.exports.ecosystem.package_path, "-e", _build_spec.exports.ecosystem.expression, "--out", "json"]
		stdout: string
	}
	projections_export: exec.Run & {
		cmd: ["cue", "export", _build_spec.exports.projections.package_path, "-e", _build_spec.exports.projections.expression, "--out", "json"]
		stdout: string
	}
	taxonomy: exec.Run & {
		cmd: ["cue", "export", _build_spec.exports.taxonomy.package_path, "-e", _build_spec.exports.taxonomy.expression, "--out", "json"]
		stdout: string
	}
	write_charter: file.Create & {
		filename: _build_spec.exports.charter.output
		contents: charter.stdout
	}
	write_ecosystem: file.Create & {
		filename: _build_spec.exports.ecosystem.output
		contents: ecosystem.stdout
	}
	write_projections: file.Create & {
		filename: _build_spec.exports.projections.output
		contents: projections_export.stdout
	}
	write_taxonomy: file.Create & {
		filename: _build_spec.exports.taxonomy.output
		contents: taxonomy.stdout
	}

	recipe: exec.Run & {
		cmd: ["cue", "export", _build_spec.exports.recipe.package_path, "-e", _build_spec.exports.recipe.expression, "--out", "json"]
		stdout: string
	}
	write_recipe: file.Create & {
		filename: _build_spec.exports.recipe.output
		contents: recipe.stdout
	}

	// Examples aggregation (separate packages — can't be spec-driven)
	ex_course: exec.Run & {
		cmd: ["cue", "export", "./examples/course-prereqs/", "-e", "summary", "--out", "json"]
		stdout: string
	}
	ex_project: exec.Run & {
		cmd: ["cue", "export", "./examples/project-tracker/", "-e", "summary", "--out", "json"]
		stdout: string
	}
	ex_recipe: exec.Run & {
		cmd: ["cue", "export", "./examples/recipe-ingredients/", "-e", "summary", "--out", "json"]
		stdout: string
	}
	ex_supply: exec.Run & {
		cmd: ["cue", "export", "./examples/supply-chain/", "-e", "summary", "--out", "json"]
		stdout: string
	}
	merge_examples: exec.Run & {
		cmd: ["python3", "-c", """
			import json, sys
			examples = {}
			for i in range(1, len(sys.argv), 2):
			    examples[sys.argv[i]] = json.loads(sys.argv[i+1])
			print(json.dumps(examples, indent=2))
			""",
			"course-prereqs", ex_course.stdout,
			"project-tracker", ex_project.stdout,
			"recipe-ingredients", ex_recipe.stdout,
			"supply-chain", ex_supply.stdout,
		]
		stdout: string
	}
	write_examples: file.Create & {
		filename: "site/data/examples.json"
		contents: merge_examples.stdout
	}

	// Python steps
	w3c_reports: exec.Run & {
		cmd: ["python3", _build_spec.python_steps.w3c_reports.script]
		$after: [write_specs, write_charter]
	}

	done: cli.Print & {
		text: "Build complete."
		$after: [write_specs, write_spec_counts, write_vocab,
			write_charter, write_ecosystem, write_projections,
			write_taxonomy, write_recipe, write_examples, w3c_reports]
	}
}

// ── Build-public command ────────────────────────────────────────────────
// Staging spec drives which files get copied.

command: "build-public": {
	$short: "Build and stage public site for CF Pages deployment"

	build_all: exec.Run & {
		cmd: ["cue", "cmd", "build"]
	}

	stage: exec.Run & {
		cmd: ["bash", "-c", _staging_script,
			"--", _build_spec.staging.dir, _staging_html_list, _staging_data_list]
		stdout: string
		$after: build_all
	}

	done: cli.Print & {
		text: stage.stdout
		$after: stage
	}
}

_staging_html_list: strings.Join(_build_spec.staging.html_files, " ")
_staging_data_list: strings.Join(_build_spec.staging.data_files, " ")

_staging_script: """
	set -euo pipefail
	staging="$1"; html_files="$2"; data_files="$3"
	rm -rf "$staging"
	mkdir -p "$staging/data" "$staging/vocab" "$staging/w3c"
	cp site/index.html "$staging/"
	for html in $html_files; do
		[ -f "site/$html" ] && cp "site/$html" "$staging/"
	done
	for f in $data_files; do
		[ -f "site/data/$f" ] && cp "site/data/$f" "$staging/data/"
	done
	[ -f site/vocab/context.jsonld ] && cp site/vocab/context.jsonld "$staging/vocab/"
	[ -d site/w3c ] && cp site/w3c/*.html "$staging/w3c/" 2>/dev/null || true
	echo "Staged $(find "$staging" -type f | wc -l) files to $staging/"
	"""
