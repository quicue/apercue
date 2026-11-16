#!/usr/bin/env python3
"""RDF-level tests: load the exported projections into rdflib and check
properties a reviewer would check with real tools.

  P1.3  shapes target the data's type IRIs (pyshacl validates > 0 focus
        nodes); every sh:sourceShape exists in the shapes graph;
        focus nodes are full IRIs; apercue's report agrees with pyshacl
        (same conforms, same focus nodes) on the rule shapes.
  P1.4  no IRI of the form urn:<x>:/<name> (a bare name resolved
        against @base).
  P1.5  in the merged graph each type name maps to exactly one class IRI.

Usage: python3 tests/rdf/test_rdf.py      (needs cue, rdflib, pyshacl)
"""
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from pyshacl import validate  # noqa: E402
from rdflib import Graph, Namespace, RDF, URIRef  # noqa: E402

from load import export, load  # noqa: E402

SH = Namespace("http://www.w3.org/ns/shacl#")
TYPE_BASE = "https://apercue.ca/vocab#"
RULE_BASE = TYPE_BASE + "rule/"

FAILS = []


def check(cond, msg):
    print(("  ok    " if cond else "  FAIL  ") + msg)
    if not cond:
        FAILS.append(msg)


def jsonld(doc):
    g = Graph()
    g.parse(data=json.dumps(doc), format="json-ld")
    return g


def bad_base_iris(g):
    return sorted({str(n) for n in g.all_nodes()
                   if isinstance(n, URIRef) and re.match(r"^urn:[^:]+:/", str(n))})


def test_no_base_resolved_names(graphs):
    print("P1.4 no bare names resolved against @base")
    for name, g in graphs.items():
        bad = bad_base_iris(g)
        check(not bad, f"{name}: {bad[:3] if bad else 'clean'}")


def test_one_iri_per_type(graphs, type_names):
    print("P1.5 one class IRI per type name across all projections")
    merged = Graph()
    for g in graphs.values():
        merged += g
    # IRIs used in a class position: rdf:type objects, shape targets and
    # qualified classes, VoID partitions, DCAT themes, unit subjects, and
    # anything declared owl:Class / rdfs:Class / skos:Concept.
    OWL = Namespace("http://www.w3.org/2002/07/owl#")
    RDFS = Namespace("http://www.w3.org/2000/01/rdf-schema#")
    SKOS = Namespace("http://www.w3.org/2004/02/skos/core#")
    class_preds = [RDF.type, SH.targetClass, SH["class"],
                   URIRef("http://rdfs.org/ns/void#class"),
                   URIRef("http://www.w3.org/ns/dcat#theme"),
                   URIRef("http://purl.org/dc/terms/subject"),
                   SKOS.broader, SKOS.narrower, SKOS.related, RDFS.subClassOf]
    class_iris = {o for p in class_preds for o in merged.objects(None, p)}
    class_iris |= {s for c in (OWL.Class, RDFS.Class, SKOS.Concept)
                   for s in merged.subjects(RDF.type, c)}
    # External W3C vocabularies (dcat:Dataset, void:Dataset, schema:Dataset)
    # are their own classes, not apercue type IRIs.
    external = ("http://www.w3.org/", "http://rdfs.org/", "https://schema.org/",
                "http://purl.org/", "https://www.w3.org/")
    seen = {t: set() for t in type_names}
    for n in class_iris:
        if not isinstance(n, URIRef) or str(n).startswith(external):
            continue
        local = re.split(r"[#/:]", str(n))[-1]
        if local in seen:
            seen[local].add(str(n))
    for t, iris in sorted(seen.items()):
        check(iris == {TYPE_BASE + t}, f"{t}: {sorted(iris)}")


def shacl_verdict(data_g, shapes_g):
    conforms, results_g, _ = validate(data_g, shacl_graph=shapes_g, advanced=True)
    rule_focus = set()
    for r in results_g.subjects(RDF.type, SH.ValidationResult):
        src = str(results_g.value(r, SH.sourceShape))
        # property-shape results point at the blank property shape; walk up
        parent = shapes_g.value(predicate=SH.property, object=results_g.value(r, SH.sourceShape))
        if parent is not None:
            src = str(parent)
        if src.startswith(RULE_BASE):
            rule_focus.add((src, str(results_g.value(r, SH.focusNode))))
    return conforms, rule_focus, results_g


def test_shapes_and_report(label, data_doc, shapes_doc, report_doc):
    print(f"P1.3 shapes vs data vs report: {label}")
    data_g, shapes_g = jsonld(data_doc), jsonld(shapes_doc)

    # Shapes must target classes that occur in the data.
    targets = set(shapes_g.objects(None, SH.targetClass))
    focus = {s for t in targets for s in data_g.subjects(RDF.type, t)}
    check(len(focus) > 0, f"shapes select {len(focus)} focus node(s) in the data graph")

    conforms, rule_focus, results_g = shacl_verdict(data_g, shapes_g)

    # Structural shapes must not fire on the graph they were derived from.
    structural = [r for r in results_g.subjects(RDF.type, SH.ValidationResult)
                  if not any(str(x).startswith(RULE_BASE)
                             for x in [shapes_g.value(predicate=SH.property,
                                                      object=results_g.value(r, SH.sourceShape)),
                                       results_g.value(r, SH.sourceShape)])]
    check(not structural, f"structural shapes: {len(structural)} result(s) on their own data")

    report = report_doc
    results = report.get("sh:result", [])
    ours = set()
    shape_ids = {str(s) for s in shapes_g.subjects(RDF.type, SH.NodeShape)}
    for r in results:
        src = jsonld({"@context": report["@context"], "@id": "urn:x", "urn:p": r["sh:sourceShape"]})
        src_iri = str(next(src.objects(URIRef("urn:x"), URIRef("urn:p"))))
        check(src_iri in shape_ids, f"sh:sourceShape {src_iri} exists in shapes graph")
        fid = r["sh:focusNode"]["@id"]
        check(re.match(r"^[a-z][a-z0-9+.-]*:", fid) is not None, f"focusNode {fid} is a full IRI")
        ours.add((src_iri, fid))

    check(report["sh:conforms"] == (len(rule_focus) == 0),
          f"apercue conforms={report['sh:conforms']}, pyshacl rule results={len(rule_focus)}")
    check(ours == rule_focus, f"same (shape, focus node) pairs: apercue={sorted(ours)} pyshacl={sorted(rule_focus)}")


def main():
    graphs = load()
    graph_doc = export("./w3c", "evidence.graph_jsonld")
    type_names = sorted({t.rsplit("#", 1)[-1] for n in graph_doc["@graph"] for t in n["@type"]})

    test_no_base_resolved_names(graphs)
    test_one_iri_per_type(graphs, type_names)

    test_shapes_and_report(
        "w3c evidence",
        graph_doc,
        export("./w3c", "evidence.shapes_graph"),
        export("./w3c", "evidence.shacl"),
    )
    pkg = "./tests/compliance-violation/report-only"
    test_shapes_and_report(
        "compliance-violation",
        export(pkg, "data.jsonld"),
        export(pkg, "shapes.shapes_graph"),
        export(pkg, "cc.shacl_report"),
    )

    print()
    if FAILS:
        print(f"{len(FAILS)} failure(s)")
        return 1
    print("all RDF checks passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
