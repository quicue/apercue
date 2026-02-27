// Federation patterns — multi-domain graph merge with namespace safety.
//
// #FederatedContext wraps a graph with a domain-specific @base namespace,
// ensuring all @id values are globally unique. #FederatedMerge validates
// that multiple contexts can be safely combined.
//
// ADR-017: @id namespacing convention for multi-domain federation.
//
// Usage:
//   ctx_a: patterns.#FederatedContext & {
//       Domain:    "apercue"
//       Namespace: "urn:apercue:"
//       Graph:     my_graph
//   }
//   ctx_b: patterns.#FederatedContext & {
//       Domain:    "quicue-kg"
//       Namespace: "urn:quicue-kg:"
//       Graph:     kg_graph
//   }
//   merged: patterns.#FederatedMerge & {
//       Sources: {apercue: ctx_a, "quicue-kg": ctx_b}
//   }

package patterns

import (
	"list"
	"apercue.ca/vocab"
)

// #FederatedContext — Wrap a graph with namespace enforcement.
//
// Requires a non-default @base URI. Produces JSON-LD with correctly
// namespaced @id values. Use this for any graph that participates in
// multi-domain federation.
#FederatedContext: {
	// Domain identifier (e.g., "apercue", "quicue-kg")
	Domain: _#SafeID

	// Namespace URI — MUST NOT be the default "urn:resource:"
	Namespace: string & !="urn:resource:"

	// The underlying graph (already computed)
	Graph: #AnalyzableGraph

	// Context with domain-specific @base.
	// Cannot unify with vocab.context (its @base is concrete "urn:resource:"),
	// so we reconstruct with the domain namespace injected.
	context: {
		"@context": {
			"@base": Namespace

			// W3C namespace prefixes (from vocab.context)
			"dcterms": "http://purl.org/dc/terms/"
			"prov":    "http://www.w3.org/ns/prov#"
			"dcat":    "http://www.w3.org/ns/dcat#"
			"sh":      "http://www.w3.org/ns/shacl#"
			"skos":    "http://www.w3.org/2004/02/skos/core#"
			"schema":  "https://schema.org/"
			"time":    "http://www.w3.org/2006/time#"
			"earl":    "http://www.w3.org/ns/earl#"
			"odrl":    "http://www.w3.org/ns/odrl/2/"
			"org":     "http://www.w3.org/ns/org#"
			"cred":    "https://www.w3.org/2018/credentials#"
			"as":      "https://www.w3.org/ns/activitystreams#"
			"void":    "http://rdfs.org/ns/void#"
			"dqv":     "http://www.w3.org/ns/dqv#"
			"oa":      "http://www.w3.org/ns/oa#"
			"rdfs":    "http://www.w3.org/2000/01/rdf-schema#"
			"owl":     "http://www.w3.org/2002/07/owl#"
			"xsd":     "http://www.w3.org/2001/XMLSchema#"
			"apercue": "https://apercue.ca/vocab#"
			"charter": "https://apercue.ca/charter#"

			// Field mappings
			"name":        "dcterms:title"
			"description": "dcterms:description"
			"depends_on": {
				"@id":   "dcterms:requires"
				"@type": "@id"
			}
			"status": {
				"@id":   "schema:actionStatus"
				"@type": "@id"
			}
			"tags": {
				"@id":        "dcterms:subject"
				"@container": "@set"
			}
		}
	}

	// Fully-qualified @id for each resource
	ids: {
		for name, _ in Graph.resources {
			(name): Namespace + name
		}
	}

	// JSON-LD export with correct namespace
	jsonld: {
		"@context": context["@context"]
		"@graph": [
			for name, res in Graph.resources {
				"@type": [for t, _ in res["@type"] {t}]
				"@id": Namespace + name
				"dcterms:title": name
				if res.depends_on != _|_ {
					"dcterms:requires": [
						for dep, _ in res.depends_on {
							{"@id": Namespace + dep}
						},
					]
				}
			},
		]
	}
}

// #FederatedMerge — Validate and merge multiple federated contexts.
//
// Collision detection uses CUE unification: if two domains claim the
// same namespace, the _namespace_ownership struct produces conflicting
// string values and CUE fails at eval time. No runtime checks needed.
#FederatedMerge: {
	// Named federated contexts
	Sources: {[_#SafeID]: #FederatedContext}

	// Cross-domain edges (optional — for inter-domain dependencies)
	CrossEdges: [...{source_domain: _#SafeID, source: _#SafeID, target_domain: _#SafeID, target: _#SafeID}] | *[]

	// ── Namespace collision detection ──────────────────────────────
	// Maps each namespace to its owning domain. If two domains use
	// the same namespace, CUE unification fails with a conflict.
	_namespace_ownership: {
		for domain, ctx in Sources {
			(ctx.Namespace): domain
		}
	}

	// ── @id collision detection ────────────────────────────────────
	// Maps each fully-qualified @id to its source domain. If two
	// domains produce the same @id, this struct has conflicting values.
	_id_ownership: {
		for domain, ctx in Sources {
			for name, id in ctx.ids {
				(id): domain
			}
		}
	}

	// ── Cross-edge validation ──────────────────────────────────────
	// Comprehension-level if filters (ADR-003): body-level if would
	// produce empty structs instead of filtering them out.
	_cross_edge_errors: [
		for _, edge in CrossEdges
		if Sources[edge.source_domain] == _|_ {
			error: "source domain '" + edge.source_domain + "' not in Sources"
		},
		for _, edge in CrossEdges
		if Sources[edge.target_domain] == _|_ {
			error: "target domain '" + edge.target_domain + "' not in Sources"
		},
		for _, edge in CrossEdges
		if Sources[edge.source_domain] != _|_
		if Sources[edge.source_domain].Graph.resources[edge.source] == _|_ {
			error: "resource '" + edge.source + "' not found in domain '" + edge.source_domain + "'"
		},
		for _, edge in CrossEdges
		if Sources[edge.target_domain] != _|_
		if Sources[edge.target_domain].Graph.resources[edge.target] == _|_ {
			error: "resource '" + edge.target + "' not found in domain '" + edge.target_domain + "'"
		},
	]

	// ── Merged JSON-LD ─────────────────────────────────────────────
	// Concatenate @graph arrays from all sources. Each resource keeps
	// its domain-specific @id, so no collisions.
	merged_jsonld: {
		"@context": vocab.context["@context"]
		"@graph": list.FlattenN([
			for _, ctx in Sources {
				ctx.jsonld["@graph"]
			},
		], 1)
	}

	// ── Cross-edge JSON-LD ─────────────────────────────────────────
	// Cross-domain dependencies as dcterms:requires links between
	// fully-qualified @id values from different namespaces.
	_cross_edge_triples: [
		for _, edge in CrossEdges
		if Sources[edge.source_domain] != _|_
		if Sources[edge.target_domain] != _|_ {
			"@id":              Sources[edge.source_domain].Namespace + edge.source
			"dcterms:requires": {"@id": Sources[edge.target_domain].Namespace + edge.target}
		},
	]

	// ── Summary ────────────────────────────────────────────────────
	summary: {
		source_count:     len([for d, _ in Sources {d}])
		total_resources: len(list.FlattenN([for _, ctx in Sources {[for n, _ in ctx.Graph.resources {n}]}], 1))
		cross_edges:      len(CrossEdges)
		cross_edge_errors: len(_cross_edge_errors)
		namespaces: {
			for domain, ctx in Sources {
				(domain): ctx.Namespace
			}
		}
		valid: len(_cross_edge_errors) == 0
	}
}
