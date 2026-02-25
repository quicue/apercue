// Cooking recipe as a typed dependency graph.
//
// Ingredients are resources. Prep steps depend on ingredients.
// Cook steps depend on prep steps. The dependency graph IS the
// recipe execution order. Charter gates = recipe completeness.
//
// Run:
//   cue eval  ./examples/recipe-ingredients/ -e gap_summary
//   cue eval  ./examples/recipe-ingredients/ -e cpm.summary
//   cue eval  ./examples/recipe-ingredients/ -e cpm.critical_sequence

package main

import (
	"apercue.ca/patterns@v0"
	"apercue.ca/charter@v0"
)

_steps: {
	// ═══ INGREDIENTS (roots — no dependencies) ═════════════════════════════════
	"beef-chuck": {
		name: "beef-chuck"
		"@type": {Protein: true}
		description: "2 lbs beef chuck, cubed"
		time_min:    0
	}
	"onions": {
		name: "onions"
		"@type": {Produce: true}
		description: "2 large yellow onions"
		time_min:    0
	}
	"carrots": {
		name: "carrots"
		"@type": {Produce: true}
		description: "4 large carrots"
		time_min:    0
	}
	"garlic": {
		name: "garlic"
		"@type": {Produce: true, Seasoning: true}
		description: "4 cloves garlic"
		time_min:    0
	}
	"red-wine": {
		name: "red-wine"
		"@type": {Liquid: true}
		description: "1 bottle Burgundy red wine"
		time_min:    0
	}
	"beef-stock": {
		name: "beef-stock"
		"@type": {Liquid: true}
		description: "2 cups beef stock"
		time_min:    0
	}
	"mushrooms": {
		name: "mushrooms"
		"@type": {Produce: true}
		description: "8 oz cremini mushrooms"
		time_min:    0
	}
	"thyme-bay": {
		name: "thyme-bay"
		"@type": {Seasoning: true}
		description: "Fresh thyme + 2 bay leaves (bouquet garni)"
		time_min:    0
	}

	// ═══ PREP STEPS ══════════════════════════════════════════════════════════════
	"dice-onions": {
		name: "dice-onions"
		"@type": {PrepStep: true}
		description: "Dice onions into 1-inch pieces"
		depends_on: {"onions": true}
		time_min: 5
	}
	"slice-carrots": {
		name: "slice-carrots"
		"@type": {PrepStep: true}
		description: "Slice carrots into 1/2-inch rounds"
		depends_on: {"carrots": true}
		time_min: 3
	}
	"mince-garlic": {
		name: "mince-garlic"
		"@type": {PrepStep: true}
		description: "Mince garlic cloves"
		depends_on: {"garlic": true}
		time_min: 2
	}
	"quarter-mushrooms": {
		name: "quarter-mushrooms"
		"@type": {PrepStep: true}
		description: "Quarter the mushrooms"
		depends_on: {"mushrooms": true}
		time_min: 3
	}

	// ═══ COOK STEPS ═════════════════════════════════════════════════════════════
	"brown-beef": {
		name: "brown-beef"
		"@type": {CookStep: true}
		description: "Sear beef in batches until deeply browned"
		depends_on: {"beef-chuck": true}
		time_min: 15
	}
	"saute-mirepoix": {
		name: "saute-mirepoix"
		"@type": {CookStep: true}
		description: "Sauté onions, carrots, garlic until softened"
		depends_on: {"dice-onions": true, "slice-carrots": true, "mince-garlic": true}
		time_min: 8
	}
	"deglaze": {
		name: "deglaze"
		"@type": {CookStep: true}
		description: "Deglaze pan with red wine, reduce by half"
		depends_on: {"brown-beef": true, "saute-mirepoix": true, "red-wine": true}
		time_min: 10
	}
	"braise": {
		name: "braise"
		"@type": {CookStep: true}
		description: "Combine everything, braise at 325°F for 2.5 hours"
		depends_on: {"deglaze": true, "beef-stock": true, "thyme-bay": true}
		time_min: 150
	}
	"finish": {
		name: "finish"
		"@type": {CookStep: true}
		description: "Add mushrooms, cook 30 min more. Season to taste."
		depends_on: {"braise": true, "quarter-mushrooms": true}
		time_min: 30
	}
}

// ═══ GRAPH ═══════════════════════════════════════════════════════════════════════
graph: patterns.#Graph & {Input: _steps}

// Critical path: what's the minimum total cook time?
cpm: patterns.#CriticalPath & {
	Graph: graph
	Weights: {for name, s in _steps {(name): s.time_min}}
}

// ═══ CHARTER — Recipe Completeness ══════════════════════════════════════════════
_charter: charter.#Charter & {
	name: "beef-bourguignon"

	scope: {
		total_resources: len(_steps)
		required_types: {
			Protein:   true
			Produce:   true
			Seasoning: true
			Liquid:    true
			PrepStep:  true
			CookStep:  true
		}
	}

	gates: {
		"mise-en-place": {
			phase:       1
			description: "All ingredients gathered and prepped"
			requires: {
				"beef-chuck":        true
				"onions":            true
				"carrots":           true
				"garlic":            true
				"red-wine":          true
				"beef-stock":        true
				"mushrooms":         true
				"thyme-bay":         true
				"dice-onions":       true
				"slice-carrots":     true
				"mince-garlic":      true
				"quarter-mushrooms": true
			}
		}
		"cooking-complete": {
			phase:       2
			description: "All cooking steps done"
			requires: {
				"brown-beef":     true
				"saute-mirepoix": true
				"deglaze":        true
				"braise":         true
				"finish":         true
			}
			depends_on: {"mise-en-place": true}
		}
	}
}

gaps: charter.#GapAnalysis & {
	Charter: _charter
	Graph:   graph
}

// Compliance check: cook steps must actually depend on something
compliance: patterns.#ComplianceCheck & {
	Graph: graph
	Rules: [
		{
			name:        "cook-steps-need-deps"
			description: "Cook steps must depend on at least one ingredient or prep step"
			match_types: {CookStep: true}
			must_not_be_root: true
			severity:         "critical"
		},
	]
}

// ═══ SUMMARY ════════════════════════════════════════════════════════════════════
gap_summary: {
	complete:          gaps.complete
	missing_resources: gaps.missing_resource_count
	missing_types:     gaps.missing_type_count
	next_gate:         gaps.next_gate
	unsatisfied_gates: len([for _, _ in gaps.unsatisfied_gates {1}])
}

scheduling_summary: cpm.summary

graph_metrics: {
	total_resources: len(graph.resources)
	max_depth:       len(graph.topology) - 1
	roots: len([for r, _ in graph.roots {r}])
	leaves: len([for l, _ in graph.leaves {l}])
	total_edges: len([for _, r in graph.resources if r.depends_on != _|_ {for _, _ in r.depends_on {1}}])
}

summary: {
	recipe:      _charter.name
	total_steps: len(_steps)
	gap:         gap_summary
	scheduling:  scheduling_summary
	graph:       graph_metrics
}
