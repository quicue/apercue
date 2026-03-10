// Context event log — W3C PROV-O + OWL-Time projection of federation events.
//
// Maps #ContextEvent records to a JSON-LD graph where each event is a
// prov:Activity with a time:Instant for its timestamp. The event log
// itself is a prov:Collection containing all events.
//
// This completes the context graph layer: #FederatedMerge handles
// structural collision detection, #ProvenanceTrace handles derivation
// chains, and #ContextEventLog handles the temporal audit trail.
//
// W3C terms used:
//   prov:Activity, prov:Collection, prov:Entity, prov:Agent
//   prov:used (source domain + resources), prov:generated (target domain)
//   prov:startedAtTime, prov:wasAssociatedWith, prov:hadMember
//   time:Instant, time:inXSDDateTimeStamp
//   dcterms:type (event kind), dcterms:title, dcterms:description
//
// Extension terms (apercue:):
//   apercue:ContextEvent (class), apercue:ContextEventLog (class)
//   apercue:outcome (success/conflict/partial — no W3C equivalent)
//
// Export: cue export -e event_log.event_report --out json

package patterns

import (
	"list"
	"apercue.ca/vocab"
)

// #ContextEventLog — Project a list of context events as PROV-O + OWL-Time.
//
// Each event → prov:Activity with time:Instant.
// The log → prov:Collection containing all event activities.
// Source/target domains → prov:Entity nodes.
#ContextEventLog: {
	// The events to project
	Events: [...vocab.#ContextEvent]

	// Optional: who/what is logging these events
	Agent?: string

	_agent_id: string | *"urn:agent:federation-controller"
	if Agent != _|_ {
		_agent_id: Agent
	}

	// Collect unique domain names across all events
	_domains: {
		for _, ev in Events {
			(ev.source_domain): true
			(ev.target_domain): true
		}
	}

	event_report: {
		"@context": vocab.context["@context"]
		"@graph": list.FlattenN([
			// Each event as a prov:Activity with time:Instant
			[
				for i, ev in Events {
					"@type": ["prov:Activity", "apercue:ContextEvent"]
					"@id":           "urn:event:" + ev.source_domain + "-" + ev.target_domain + "-" + ev.type + "-\(i)"
					"dcterms:title": ev.type + ": " + ev.source_domain + " → " + ev.target_domain
					"dcterms:type":  ev.type
					"prov:startedAtTime": ev.timestamp
					"prov:wasAssociatedWith": {"@id": _agent_id}
					"apercue:outcome": ev.outcome
					// Source domain + affected resources = prov:used (inputs consumed)
					"prov:used": list.FlattenN([[
						{"@id": "urn:domain:" + ev.source_domain},
					], [
						for _, r in ev.resources {
							{"@id": "urn:resource:" + r}
						},
					]], 1)
					// Target domain = prov:generated (output produced/affected)
					"prov:generated": {"@id": "urn:domain:" + ev.target_domain}
					if ev.provenance_ref != _|_ {
						"prov:wasInformedBy": {"@id": ev.provenance_ref}
					}
					if ev.description != _|_ {
						"dcterms:description": ev.description
					}
					// OWL-Time instant for the event timestamp
					"time:hasTime": {
						"@type":                   "time:Instant"
						"@id":                     "urn:instant:" + ev.source_domain + "-" + ev.target_domain + "-\(i)"
						"time:inXSDDateTimeStamp": ev.timestamp
					}
				},
			],

			// Each unique domain as a prov:Entity
			[
				for domain, _ in _domains {
					"@type":         "prov:Entity"
					"@id":           "urn:domain:" + domain
					"dcterms:title": domain
				},
			],

			// The event log collection
			[{
				"@type": ["prov:Collection", "apercue:ContextEventLog"]
				"@id":   "urn:collection:context-event-log"
				"dcterms:title": "Context Event Log"
				"prov:hadMember": [
					for i, ev in Events {
						{"@id": "urn:event:" + ev.source_domain + "-" + ev.target_domain + "-" + ev.type + "-\(i)"}
					},
				]
			}],

			// The agent
			[{
				"@type": ["prov:Agent", "prov:SoftwareAgent"]
				"@id":   _agent_id
			}],
		], 1)
	}

	// Summary for quick inspection
	summary: {
		total_events: len(Events)
		domains:      len([for d, _ in _domains {d}])
		by_type: {
			for _, t in ["merge", "validate", "project", "export"] {
				(t): len([for _, ev in Events if ev.type == t {ev}])
			}
		}
		by_outcome: {
			for _, o in ["success", "conflict", "partial"] {
				(o): len([for _, ev in Events if ev.outcome == o {ev}])
			}
		}
	}
}
