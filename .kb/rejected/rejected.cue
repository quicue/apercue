// Rejected approaches for apercue.ca
package rejected

import "quicue.ca/kg/core@v0"

r001: core.#Rejected & {
	id:        "REJ-001"
	approach:  "Use flat keyed objects (resource names as JSON keys) in OWL-Time projection output"
	reason:    "JSON-LD processors cannot resolve bare JSON object keys as named RDF subjects. rdflib produced 0 triples from OWL-Time output that used {resource_name: {time:hasBeginning: ...}} — the resource names vanish because they are property names, not @id values. Meanwhile SHACL, PROV-O, and Activity Streams projections using @graph arrays round-tripped correctly."
	date:      "2026-02-26"
	alternative: "Use @graph array with @id on each item: {@graph: [{@id: urn:resource:name, @type: time:Interval, ...}]}. This is the same pattern used by all other projections. Flat keyed output remains valid CUE but is not JSON-LD conformant."
	related: {"INSIGHT-014": true, "ADR-002": true}
}
