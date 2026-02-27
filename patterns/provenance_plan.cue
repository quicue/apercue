// PROV-O Plan projection — charters as provenance plans.
//
// A charter IS a plan: it declares what activities (gates) must happen,
// in what order (depends_on), to produce which entities (resources).
// This pattern maps charter → prov:Plan, gates → prov:Activity with
// associated prov:Entity sets.
//
// This complements #ProvenanceTrace (which maps dependency edges to
// prov:wasDerivedFrom) by adding the INTENTIONAL structure — not just
// what derived from what, but what was PLANNED to happen.
//
// W3C PROV-O (Recommendation, 2013-04-30): provenance interchange.
// Specifically uses: prov:Plan, prov:Activity, prov:Entity,
// prov:qualifiedAssociation, prov:hadPlan.
//
// Export: cue export -e prov_plan.plan_report --out json

package patterns

import "apercue.ca/vocab"

// #ProvenancePlan — Project a charter as a PROV-O Plan.
//
// Input: a charter (with gates, phases, requires) and the associated graph.
// Output: prov:Plan with prov:Activity per gate and prov:Entity per resource.
//
// The plan's temporal ordering comes from gate phases and depends_on.
// Gate satisfaction (from gap analysis) maps to prov:wasStartedBy /
// prov:wasEndedBy markers.
#ProvenancePlan: {
	// The charter structure — name, gates with phases and requires
	Charter: {
		name: string
		gates: {[string]: {
			phase:       int
			description: string
			requires: {[string]: true}
			depends_on?: {[string]: true}
		}}
		...
	}

	// The associated graph (for resource metadata)
	Graph: #AnalyzableGraph

	// Optional gap analysis results (to mark completion status)
	GateStatus?: {[string]: {satisfied: bool, ...}}

	// Optional: who created the plan
	Agent?: string

	_agent_id: string | *"apercue:planner"
	if Agent != _|_ {
		_agent_id: Agent
	}

	_plan_id: "urn:plan:" + Charter.name

	plan_report: {
		"@context": vocab.context["@context"]
		"@graph": [
			// The plan itself
			{
				"@type":         "prov:Plan"
				"@id":           _plan_id
				"dcterms:title": Charter.name
				"prov:wasAttributedTo": {"@id": _agent_id}
			},

			// Each gate as a prov:Activity with a qualified association to the plan
			for gname, gate in Charter.gates {
				"@type":         "prov:Activity"
				"@id":           "urn:gate:" + gname
				"dcterms:title": gate.description
				"apercue:phase": gate.phase

				// The plan this activity is part of
				"prov:qualifiedAssociation": {
					"@type":    "prov:Association"
					"prov:agent":   {"@id": _agent_id}
					"prov:hadPlan": {"@id": _plan_id}
				}

				// What this gate produces / requires
				"prov:used": [
					for rname, _ in gate.requires {
						{"@id": "urn:resource:" + rname}
					},
				]

				// Gate ordering via prov:wasInformedBy
				if gate.depends_on != _|_ {
					"prov:wasInformedBy": [
						for dep, _ in gate.depends_on {
							{"@id": "urn:gate:" + dep}
						},
					]
				}

				// Completion status (if gap analysis provided)
				if GateStatus != _|_ if GateStatus[gname] != _|_ {
					if GateStatus[gname].satisfied {
						"prov:wasEndedBy": {
							"@type":         "prov:Activity"
							"dcterms:title": "Gate satisfied"
						}
					}
				}
			},

			// Resources referenced by gates as prov:Entity
			for rname, res in Graph.resources {
				"@type":         "prov:Entity"
				"@id":           "urn:resource:" + rname
				"dcterms:title": rname
				if res.description != _|_ {
					"dcterms:description": res.description
				}
				// Which gate(s) require this resource
				"prov:wasGeneratedBy": [
					for gname, gate in Charter.gates if gate.requires[rname] != _|_ {
						{"@id": "urn:gate:" + gname}
					},
				]
			},

			// The agent
			{
				"@type": "prov:Agent"
				"@id":   _agent_id
			},
		]
	}

	summary: {
		plan:       Charter.name
		gates:      len(Charter.gates)
		resources:  len(Graph.resources)
		_satisfied: len([for gname, _ in Charter.gates if GateStatus != _|_ if GateStatus[gname] != _|_ if GateStatus[gname].satisfied {1}])
		satisfied_gates: _satisfied
	}
}
