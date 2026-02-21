// Activity Streams 2.0 projection — graph construction as a stream of activities.
//
// Models graph resource creation as an AS2 OrderedCollection.
// Each resource at each topology layer becomes a Create activity,
// ordered by dependency depth (layer 0 first).
//
// W3C Activity Streams 2.0 (Recommendation, 2017-05-23): activity vocabulary.
//
// Export: cue export -e activity_stream.stream --out json

package patterns

import "apercue.ca/vocab"

// #ActivityStream — Project graph construction as an Activity Streams 2.0 collection.
//
// The graph's topological ordering becomes a timeline of Create activities.
// Resources at layer 0 are created first; each subsequent layer depends on
// the previous one being complete.
#ActivityStream: {
	Graph: #AnalyzableGraph

	// Optional: the actor performing the activities
	Actor?: string

	_actor: {
		"type": "Application"
		"name": string | *"apercue"
		if Actor != _|_ {
			"id":   Actor
			"name": Actor
		}
	}

	// Build ordered items from topology layers
	_items: [
		for layer_key, layer_resources in Graph.topology
		for name, _ in layer_resources {
			let res = Graph.resources[name]
			{
				"type":   "Create"
				"actor":  _actor
				"object": {
					"type":          "Object"
					"id":            "urn:resource:" + name
					"name":          name
					"apercue:depth": res._depth
					"apercue:types": res["@type"]
					if res.description != _|_ {
						"summary": res.description
					}
				}
				if res.depends_on != _|_ {
					"context": [
						for dep, _ in res.depends_on {
							{"type": "Link", "href": "urn:resource:" + dep}
						},
					]
				}
			}
		},
	]

	stream: {
		"@context": [
			"https://www.w3.org/ns/activitystreams",
			vocab.context["@context"],
		]
		"type":       "OrderedCollection"
		"totalItems": len(Graph.resources)
		"summary":    "Graph construction activity stream"

		"orderedItems": _items
	}
}
