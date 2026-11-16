"""Shared helper: export apercue projections and load them into rdflib."""
import json
import subprocess

from rdflib import Graph

# Every JSON-LD projection exported by the w3c evidence package.
PROJECTIONS = [
    "shacl", "time_report", "odrl_policy", "prov_report", "dcat_catalog",
    "activity_stream", "verifiable_credential", "skos_taxonomy_scheme",
    "skos_taxonomy_collection", "void_description", "owl_ontology",
    "earl_report", "schema_graph", "org_report", "annotation_collection",
    "shapes_graph", "graph_jsonld",
]


def export(pkg, expr):
    out = subprocess.run(["cue", "export", pkg, "-e", expr, "--out", "json"],
                         capture_output=True, text=True, check=True)
    return json.loads(out.stdout)


def load(pkg="./w3c", prefix="evidence.", names=PROJECTIONS):
    """Return {name: rdflib.Graph}; names missing from the package are skipped."""
    graphs = {}
    for n in names:
        try:
            doc = export(pkg, prefix + n)
        except subprocess.CalledProcessError:
            continue
        g = Graph()
        g.parse(data=json.dumps(doc), format="json-ld")
        graphs[n] = g
    return graphs
