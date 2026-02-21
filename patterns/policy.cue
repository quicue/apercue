// Policy projection — W3C ODRL 2.2 from dependency graphs.
//
// Maps resources to odrl:Asset and type-based rules to permissions/prohibitions.
// Policies are declared as CUE structs; the projection produces conformant ODRL JSON-LD.
//
// W3C ODRL 2.2 (Recommendation, 2018-02-15): rights expression language.
//
// Export: cue export -e access_policy.odrl_policy --out json

package patterns

import "apercue.ca/vocab"

// #PolicyRule — a single permission or prohibition.
#PolicyRule: {
	action:    string
	assignee?: string
	target?:   string // resource name or @type; if omitted, applies to all
	duty?: {
		action: string
	}
}

// #ODRLPolicy — Project resource access rules as an ODRL 2.2 Policy.
//
// Declare permissions and prohibitions by resource type or name.
// The projection maps each rule to the matching resources in the graph.
#ODRLPolicy: {
	Graph: #AnalyzableGraph

	// Policy metadata
	PolicyID: string | *"apercue:graph-policy"
	Profile?: string

	// Rules — user declares these
	permissions:  [...#PolicyRule]
	prohibitions: [...#PolicyRule]

	odrl_policy: {
		"@context": vocab.context["@context"]
		"@type":    "odrl:Set"
		"odrl:uid": PolicyID
		if Profile != _|_ {
			"odrl:profile": Profile
		}

		"odrl:permission": [
			for rule in permissions {
				_entry: {
					"odrl:action": {"@id": "odrl:" + rule.action}
					if rule.assignee != _|_ {
						"odrl:assignee": {"@id": rule.assignee}
					}
					// If target is a resource name, link directly
					if rule.target != _|_ if Graph.resources[rule.target] != _|_ {
						"odrl:target": {"@id": "urn:resource:" + rule.target}
					}
					// If target is a @type, expand to all matching resources
					if rule.target != _|_ if Graph.resources[rule.target] == _|_ {
						"odrl:target": [
							for name, res in Graph.resources if res["@type"][rule.target] != _|_ {
								{"@id": "urn:resource:" + name}
							},
						]
					}
					if rule.duty != _|_ {
						"odrl:duty": {
							"odrl:action": {"@id": "odrl:" + rule.duty.action}
						}
					}
				}
				_entry
			},
		]

		"odrl:prohibition": [
			for rule in prohibitions {
				_entry: {
					"odrl:action": {"@id": "odrl:" + rule.action}
					if rule.assignee != _|_ {
						"odrl:assignee": {"@id": rule.assignee}
					}
					if rule.target != _|_ if Graph.resources[rule.target] != _|_ {
						"odrl:target": {"@id": "urn:resource:" + rule.target}
					}
					if rule.target != _|_ if Graph.resources[rule.target] == _|_ {
						"odrl:target": [
							for name, res in Graph.resources if res["@type"][rule.target] != _|_ {
								{"@id": "urn:resource:" + name}
							},
						]
					}
				}
				_entry
			},
		]
	}
}
