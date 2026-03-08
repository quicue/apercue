#!/usr/bin/env python3
"""
apercue.ca -- External Interoperability Tests

Tests whether apercue's W3C outputs are consumable by external tools,
not just parseable by rdflib. This is the difference between conformance
and interoperability.

Scope: validates structure of the w3c/evidence 5-node example graph.
This proves the projections produce output that external tools can use,
not that every possible graph produces correct output.

Tools tested:
  - rdflib: JSON-LD parsing, RDF graph construction, SPARQL querying
  - pySHACL: External SHACL validation engine (with hand-written shapes)

Usage:
  Run from the repo root:
    python3 tools/test_interop.py

  The script exports JSON-LD from CUE into a temp directory before testing.
  Requires: rdflib, pyshacl (pip install rdflib pyshacl)
"""

import json
import subprocess
import sys
import tempfile
from pathlib import Path

from rdflib import Graph, Namespace, RDF, RDFS, OWL, XSD, URIRef, Literal
from rdflib.namespace import SKOS, DCTERMS, PROV, DCAT
from pyshacl import validate as shacl_validate

# ---------------------------------------------------------------
# Setup: export JSON-LD from CUE into a temp directory
# ---------------------------------------------------------------

REPO_ROOT = Path(__file__).parent.parent
EXPRESSIONS = [
    "shacl", "skos_taxonomy", "prov_report", "dcat_catalog",
    "odrl_policy", "time_report", "earl_report", "void_description",
    "quality_report", "owl_ontology", "annotation_collection", "schema_graph",
    "org_report",
]

EXPORT_DIR = Path(tempfile.mkdtemp(prefix="apercue-interop-"))

print(f"Exporting evidence to {EXPORT_DIR}...")
for expr in EXPRESSIONS:
    outpath = EXPORT_DIR / f"{expr}.json"
    result = subprocess.run(
        ["cue", "export", "./w3c/", "-e", f"evidence.{expr}", "--out", "json"],
        capture_output=True, text=True, cwd=REPO_ROOT,
    )
    if result.returncode != 0:
        print(f"  SKIP {expr}: {result.stderr.strip()}")
        continue
    outpath.write_text(result.stdout)

exported = list(EXPORT_DIR.glob("*.json"))
print(f"Exported {len(exported)} projections.\n")

# Namespaces
SH = Namespace("http://www.w3.org/ns/shacl#")
EARL_NS = Namespace("http://www.w3.org/ns/earl#")
ODRL = Namespace("http://www.w3.org/ns/odrl/2/")
TIME = Namespace("http://www.w3.org/2006/time#")
OA = Namespace("http://www.w3.org/ns/oa#")
DQV = Namespace("http://www.w3.org/ns/dqv#")
VOID = Namespace("http://rdfs.org/ns/void#")
ORG = Namespace("http://www.w3.org/ns/org#")
SCHEMA = Namespace("https://schema.org/")

test_results = []


def load_jsonld(filename):
    """Load a JSON-LD file into an rdflib Graph. Returns None if missing."""
    filepath = EXPORT_DIR / filename
    if not filepath.exists():
        return None
    g = Graph()
    with open(filepath) as f:
        data = json.load(f)
    g.parse(data=json.dumps(data), format="json-ld")
    return g


def test(name, passed, detail=""):
    test_results.append((name, passed, detail))
    mark = "\033[32mPASS\033[0m" if passed else "\033[31mFAIL\033[0m"
    print(f"  {mark} {name}" + (f" -- {detail}" if detail else ""))


def count_triples(g):
    return len(list(g.triples((None, None, None))))


# ===============================================================
# TEST 1: SHACL -- Parse and query the validation report
# ===============================================================
print("=== SHACL Validation Report ===")
g = load_jsonld("shacl.json")
n = count_triples(g)
test("SHACL: JSON-LD parses into RDF graph", n > 0, f"{n} triples")

reports = list(g.subjects(RDF.type, SH.ValidationReport))
test("SHACL: Contains sh:ValidationReport", len(reports) > 0,
     f"{len(reports)} report(s)")

conforms_values = list(g.objects(reports[0], SH.conforms)) if reports else []
test("SHACL: sh:conforms is present and boolean",
     len(conforms_values) == 1 and isinstance(conforms_values[0].toPython(), bool),
     f"value={conforms_values[0].toPython() if conforms_values else 'MISSING'}")

# sh:result count must be consistent with sh:conforms value
results_list = list(g.objects(reports[0], SH.result)) if reports else []
conforms_val = conforms_values[0].toPython() if conforms_values else None
if conforms_val is True:
    test("SHACL: sh:conforms=true implies zero sh:result entries",
         len(results_list) == 0,
         f"{len(results_list)} result(s)")
elif conforms_val is False:
    test("SHACL: sh:conforms=false implies nonzero sh:result entries",
         len(results_list) > 0,
         f"{len(results_list)} result(s)")

# SPARQL
sparql_result = g.query("""
    PREFIX sh: <http://www.w3.org/ns/shacl#>
    SELECT ?report ?conforms WHERE {
        ?report a sh:ValidationReport ;
                sh:conforms ?conforms .
    }
""")
rows = list(sparql_result)
test("SHACL: SPARQL query returns results", len(rows) > 0, f"{len(rows)} row(s)")

# ===============================================================
# TEST 2: pySHACL -- External SHACL engine (positive + negative)
# ===============================================================
print("\n=== pySHACL External Validation ===")

# Shape: every sh:ValidationReport must have exactly one boolean sh:conforms
shacl_shapes_ttl = """
@prefix sh: <http://www.w3.org/ns/shacl#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .

<urn:shape:ValidationReportShape> a sh:NodeShape ;
    sh:targetClass sh:ValidationReport ;
    sh:property [
        sh:path sh:conforms ;
        sh:minCount 1 ;
        sh:maxCount 1 ;
        sh:datatype xsd:boolean ;
    ] .
"""
shapes_g = Graph()
shapes_g.parse(data=shacl_shapes_ttl, format="turtle")

conforms, _, rtxt = shacl_validate(g, shacl_graph=shapes_g, inference='none')
test("pySHACL: Accepts valid sh:ValidationReport", conforms,
     "conforms=True" if conforms else f"conforms=False\n{rtxt}")

# Negative: report missing sh:conforms -- must be rejected
broken_g = Graph()
broken_g.parse(data='@prefix sh: <http://www.w3.org/ns/shacl#> .\n'
               '<urn:broken:report> a sh:ValidationReport .\n', format="turtle")
neg1, _, _ = shacl_validate(broken_g, shacl_graph=shapes_g, inference='none')
test("pySHACL: Rejects report missing sh:conforms", not neg1,
     "correctly rejected" if not neg1 else "INCORRECTLY accepted")

# Negative: wrong datatype for sh:conforms -- must be rejected
broken2_g = Graph()
broken2_g.parse(data='@prefix sh: <http://www.w3.org/ns/shacl#> .\n'
                '<urn:broken:report2> a sh:ValidationReport ; sh:conforms "yes" .\n',
                format="turtle")
neg2, _, _ = shacl_validate(broken2_g, shacl_graph=shapes_g, inference='none')
test("pySHACL: Rejects non-boolean sh:conforms", not neg2,
     "correctly rejected" if not neg2 else "INCORRECTLY accepted")

# ===============================================================
# TEST 3: SKOS -- Vocabulary structure
# ===============================================================
print("\n=== SKOS Taxonomy ===")
g = load_jsonld("skos_taxonomy.json")
n = count_triples(g)
test("SKOS: JSON-LD parses into RDF graph", n > 0, f"{n} triples")

schemes = list(g.subjects(RDF.type, SKOS.ConceptScheme))
test("SKOS: Contains skos:ConceptScheme", len(schemes) > 0,
     f"{len(schemes)} scheme(s)")

concepts = list(g.subjects(RDF.type, SKOS.Concept))
test("SKOS: Contains skos:Concept instances", len(concepts) > 0,
     f"{len(concepts)} concept(s)")

# ALL concepts must have prefLabel
labeled = [c for c in concepts if list(g.objects(c, SKOS.prefLabel))]
test("SKOS: All concepts have skos:prefLabel",
     len(labeled) == len(concepts),
     f"{len(labeled)}/{len(concepts)}")

# ALL concepts must link to a scheme
in_scheme = [c for c in concepts if list(g.objects(c, SKOS.inScheme))]
test("SKOS: All concepts have skos:inScheme",
     len(in_scheme) == len(concepts),
     f"{len(in_scheme)}/{len(concepts)}")

# SPARQL: count must match
sparql_result = g.query("""
    PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
    SELECT ?concept ?label WHERE {
        ?concept a skos:Concept ; skos:prefLabel ?label .
    }
    ORDER BY ?label
""")
rows = list(sparql_result)
test("SKOS: SPARQL returns all concepts",
     len(rows) == len(concepts),
     f"{len(rows)} concepts: {', '.join(str(r[1]) for r in rows)}")

# pySHACL: Concept must have prefLabel + inScheme pointing to ConceptScheme
skos_shapes_ttl = """
@prefix sh: <http://www.w3.org/ns/shacl#> .
@prefix skos: <http://www.w3.org/2004/02/skos/core#> .

<urn:shape:ConceptShape> a sh:NodeShape ;
    sh:targetClass skos:Concept ;
    sh:property [ sh:path skos:prefLabel ; sh:minCount 1 ] ;
    sh:property [ sh:path skos:inScheme ; sh:minCount 1 ; sh:class skos:ConceptScheme ] .

<urn:shape:SchemeShape> a sh:NodeShape ;
    sh:targetClass skos:ConceptScheme ;
    sh:property [ sh:path skos:prefLabel ; sh:minCount 1 ] .
"""
shapes_g = Graph()
shapes_g.parse(data=skos_shapes_ttl, format="turtle")
conforms, _, rtxt = shacl_validate(g, shacl_graph=shapes_g, inference='none')
test("pySHACL: Validates SKOS (prefLabel + inScheme + class)", conforms,
     "conforms" if conforms else f"FAIL\n{rtxt}")

# ===============================================================
# TEST 4: PROV-O -- Provenance traces
# ===============================================================
print("\n=== PROV-O Provenance ===")
g = load_jsonld("prov_report.json")
n = count_triples(g)
test("PROV-O: JSON-LD parses into RDF graph", n > 0, f"{n} triples")

entities = list(g.subjects(RDF.type, PROV.Entity))
test("PROV-O: Contains prov:Entity", len(entities) > 0, f"{len(entities)} entities")

activities = list(g.subjects(RDF.type, PROV.Activity))
test("PROV-O: Contains prov:Activity", len(activities) > 0,
     f"{len(activities)} activities")

# Derivation edges must exist (the graph has dependencies)
derived = list(g.subject_objects(PROV.wasDerivedFrom))
test("PROV-O: prov:wasDerivedFrom edges present", len(derived) > 0,
     f"{len(derived)} derivation(s)")

# Non-root entities should have derivations; at most 1 root has none
entities_with_derivation = set(s for s, _ in derived)
entities_without = [e for e in entities if e not in entities_with_derivation]
test("PROV-O: At most 1 entity without derivation (root)",
     len(entities_without) <= 1,
     f"{len(entities_without)} without derivation")

# SPARQL: count must match triple-API count
sparql_result = g.query("""
    PREFIX prov: <http://www.w3.org/ns/prov#>
    SELECT ?entity ?source WHERE {
        ?entity prov:wasDerivedFrom ?source .
    }
""")
rows = list(sparql_result)
test("PROV-O: SPARQL derivation count matches",
     len(rows) == len(derived),
     f"{len(rows)} edges (expected {len(derived)})")

# pySHACL: Activity must have prov:generated (our projection includes it)
prov_shapes_ttl = """
@prefix sh: <http://www.w3.org/ns/shacl#> .
@prefix prov: <http://www.w3.org/ns/prov#> .

<urn:shape:ActivityShape> a sh:NodeShape ;
    sh:targetClass prov:Activity ;
    sh:property [ sh:path prov:generated ; sh:minCount 1 ] ;
    sh:property [ sh:path prov:wasAssociatedWith ; sh:minCount 1 ] .
"""
shapes_g = Graph()
shapes_g.parse(data=prov_shapes_ttl, format="turtle")
conforms, _, rtxt = shacl_validate(g, shacl_graph=shapes_g, inference='none')
test("pySHACL: Validates PROV-O (Activity has generated + wasAssociatedWith)",
     conforms, "conforms" if conforms else f"FAIL\n{rtxt}")

# ===============================================================
# TEST 5: DCAT -- Data catalog
# ===============================================================
print("\n=== DCAT Catalog ===")
g = load_jsonld("dcat_catalog.json")
n = count_triples(g)
test("DCAT: JSON-LD parses into RDF graph", n > 0, f"{n} triples")

catalogs = list(g.subjects(RDF.type, DCAT.Catalog))
test("DCAT: Contains dcat:Catalog", len(catalogs) > 0, f"{len(catalogs)} catalog(s)")

datasets = list(g.subjects(RDF.type, DCAT.Dataset))
test("DCAT: Contains dcat:Dataset", len(datasets) > 0, f"{len(datasets)} dataset(s)")

# Use namespace constant, not hardcoded URI
has_dataset = list(g.subject_objects(DCAT.dataset))
test("DCAT: dcat:dataset links present", len(has_dataset) > 0,
     f"{len(has_dataset)} link(s)")

# All datasets must be linked to a catalog
linked = set(o for _, o in has_dataset)
unlinked = [d for d in datasets if d not in linked]
test("DCAT: All datasets linked to catalog",
     len(unlinked) == 0,
     f"{len(unlinked)} unlinked" if unlinked else f"all {len(datasets)} linked")

# SPARQL
sparql_result = g.query("""
    PREFIX dcat: <http://www.w3.org/ns/dcat#>
    PREFIX dcterms: <http://purl.org/dc/terms/>
    SELECT ?dataset ?title WHERE {
        ?catalog a dcat:Catalog ; dcat:dataset ?dataset .
        OPTIONAL { ?dataset dcterms:title ?title }
    }
""")
rows = list(sparql_result)
test("DCAT: SPARQL catalog query works", len(rows) > 0,
     f"{len(rows)} datasets in catalog")

# ===============================================================
# TEST 6: ODRL -- Policy
# ===============================================================
print("\n=== ODRL Policy ===")
g = load_jsonld("odrl_policy.json")
n = count_triples(g)
test("ODRL: JSON-LD parses into RDF graph", n > 0, f"{n} triples")

policies = list(g.subjects(RDF.type, ODRL.Set))
test("ODRL: Contains odrl:Set", len(policies) > 0, f"{len(policies)} policy(ies)")

permissions = list(g.subjects(RDF.type, ODRL.Permission))
test("ODRL: Contains odrl:Permission", len(permissions) > 0,
     f"{len(permissions)} permission(s)")

# Every permission must have an action
perms_with_action = [p for p in permissions if list(g.objects(p, ODRL.action))]
test("ODRL: All permissions have odrl:action",
     len(perms_with_action) == len(permissions),
     f"{len(perms_with_action)}/{len(permissions)}")

# SPARQL count must match
sparql_result = g.query("""
    PREFIX odrl: <http://www.w3.org/ns/odrl/2/>
    SELECT ?permission ?action WHERE {
        ?permission a odrl:Permission ; odrl:action ?action .
    }
""")
rows = list(sparql_result)
test("ODRL: SPARQL permission count matches",
     len(rows) == len(permissions),
     f"{len(rows)} pairs (expected {len(permissions)})")

# ===============================================================
# TEST 7: OWL-Time -- Temporal intervals
# ===============================================================
print("\n=== OWL-Time Scheduling ===")
g = load_jsonld("time_report.json")
n = count_triples(g)
test("OWL-Time: JSON-LD parses into RDF graph", n > 0, f"{n} triples")

intervals = list(g.subjects(RDF.type, TIME.Interval))
test("OWL-Time: Contains time:Interval", len(intervals) > 0,
     f"{len(intervals)} interval(s)")

# ALL intervals must have beginning and duration
has_beginning = [i for i in intervals if list(g.objects(i, TIME.hasBeginning))]
test("OWL-Time: All intervals have time:hasBeginning",
     len(has_beginning) == len(intervals),
     f"{len(has_beginning)}/{len(intervals)}")

has_duration = [i for i in intervals if list(g.objects(i, TIME.hasDuration))]
test("OWL-Time: All intervals have time:hasDuration",
     len(has_duration) == len(intervals),
     f"{len(has_duration)}/{len(intervals)}")

# SPARQL count must match
sparql_result = g.query("""
    PREFIX time: <http://www.w3.org/2006/time#>
    SELECT ?interval ?begin ?end WHERE {
        ?interval a time:Interval ;
                  time:hasBeginning ?bNode ; time:hasEnd ?eNode .
        ?bNode time:inXSDDecimal ?begin .
        ?eNode time:inXSDDecimal ?end .
    }
    ORDER BY ?begin
""")
rows = list(sparql_result)
test("OWL-Time: SPARQL schedule count matches",
     len(rows) == len(intervals),
     f"{len(rows)} intervals (expected {len(intervals)})")

# ===============================================================
# TEST 8: EARL -- Test assertions
# ===============================================================
print("\n=== EARL Test Report ===")
g = load_jsonld("earl_report.json")
n = count_triples(g)
test("EARL: JSON-LD parses into RDF graph", n > 0, f"{n} triples")

assertions = list(g.subjects(RDF.type, EARL_NS.Assertion))
test("EARL: Contains earl:Assertion", len(assertions) > 0,
     f"{len(assertions)} assertion(s)")

earl_results = list(g.subjects(RDF.type, EARL_NS.TestResult))
test("EARL: Contains earl:TestResult", len(earl_results) > 0,
     f"{len(earl_results)} result(s)")

# Every assertion must have a result
asserts_with_result = [a for a in assertions if list(g.objects(a, EARL_NS.result))]
test("EARL: All assertions have earl:result",
     len(asserts_with_result) == len(assertions),
     f"{len(asserts_with_result)}/{len(assertions)}")

# ===============================================================
# TEST 9: VoID -- Dataset description
# ===============================================================
print("\n=== VoID Dataset Description ===")
g = load_jsonld("void_description.json")
n = count_triples(g)
test("VoID: JSON-LD parses into RDF graph", n > 0, f"{n} triples")

void_ds = list(g.subjects(RDF.type, VOID.Dataset))
test("VoID: Contains void:Dataset", len(void_ds) > 0, f"{len(void_ds)} dataset(s)")

vocabs = list(g.objects(None, VOID.vocabulary))
test("VoID: void:vocabulary present", len(vocabs) > 0,
     f"{len(vocabs)} vocabularies referenced")

# ===============================================================
# TEST 10: DQV -- Data quality
# ===============================================================
print("\n=== DQV Quality Report ===")
g = load_jsonld("quality_report.json")
n = count_triples(g)
test("DQV: JSON-LD parses into RDF graph", n > 0, f"{n} triples")

measurements = list(g.subjects(RDF.type, DQV.QualityMeasurement))
test("DQV: Contains dqv:QualityMeasurement", len(measurements) > 0,
     f"{len(measurements)} measurement(s)")

# ===============================================================
# TEST 11: Web Annotation -- oa:Annotation
# ===============================================================
print("\n=== Web Annotation ===")
g = load_jsonld("annotation_collection.json")
n = count_triples(g)
test("OA: JSON-LD parses into RDF graph", n > 0, f"{n} triples")

annotations = list(g.subjects(RDF.type, OA.Annotation))
test("OA: Contains oa:Annotation", len(annotations) > 0,
     f"{len(annotations)} annotation(s)")

# ALL annotations must have body and target (W3C Web Annotation spec)
has_body = [a for a in annotations if list(g.objects(a, OA.hasBody))]
test("OA: All annotations have oa:hasBody",
     len(has_body) == len(annotations),
     f"{len(has_body)}/{len(annotations)}")

has_target = [a for a in annotations if list(g.objects(a, OA.hasTarget))]
test("OA: All annotations have oa:hasTarget",
     len(has_target) == len(annotations),
     f"{len(has_target)}/{len(annotations)}")

# ===============================================================
# TEST 12: OWL -- Ontology
# ===============================================================
print("\n=== OWL Ontology ===")
g = load_jsonld("owl_ontology.json")
n = count_triples(g)
test("OWL: JSON-LD parses into RDF graph", n > 0, f"{n} triples")

ontologies = list(g.subjects(RDF.type, OWL.Ontology))
test("OWL: Contains owl:Ontology", len(ontologies) > 0,
     f"{len(ontologies)} ontology(ies)")

classes = list(g.subjects(RDF.type, OWL.Class))
if not classes:
    classes = list(g.subjects(RDF.type, RDFS.Class))
test("OWL: Contains owl:Class or rdfs:Class", len(classes) > 0,
     f"{len(classes)} class(es)")

# ===============================================================
# TEST 13: schema.org
# ===============================================================
print("\n=== schema.org ===")
g = load_jsonld("schema_graph.json")
n = count_triples(g)
test("schema.org: JSON-LD parses into RDF graph", n > 0, f"{n} triples")

# rdf:type must carry schema.org URIs
schema_types = set()
for s, p, o in g.triples((None, RDF.type, None)):
    if str(o).startswith("https://schema.org/"):
        schema_types.add(str(o).replace("https://schema.org/", "schema:"))
test("schema.org: rdf:type uses schema.org URIs", len(schema_types) > 0,
     f"{', '.join(sorted(schema_types))}")

# schema:additionalType must also be present
additional = list(g.subject_objects(SCHEMA.additionalType))
test("schema.org: schema:additionalType present", len(additional) > 0,
     f"{len(additional)} annotations")

# ===============================================================
# TEST 14: Cross-spec SPARQL -- merged graph
# ===============================================================
print("\n=== Cross-Spec SPARQL (Merged Graph) ===")
merged = Graph()
for f in EXPORT_DIR.glob("*.json"):
    try:
        with open(f) as fh:
            data = json.load(fh)
        merged.parse(data=json.dumps(data), format="json-ld")
    except Exception:
        pass

total_triples = count_triples(merged)
test("Merged: All specs parse into single graph", total_triples > 0,
     f"{total_triples} total triples")

# INTERSECTION: find resources typed as BOTH prov:Entity AND dcat:Dataset
sparql_result = merged.query("""
    PREFIX prov: <http://www.w3.org/ns/prov#>
    PREFIX dcat: <http://www.w3.org/ns/dcat#>
    SELECT DISTINCT ?resource WHERE {
        ?resource a prov:Entity .
        ?resource a dcat:Dataset .
    }
""")
rows = list(sparql_result)
test("Cross-spec: Same @id is both prov:Entity and dcat:Dataset",
     len(rows) > 0,
     f"{len(rows)} resources with both types")

# Verify the cross-typed resources use urn:resource: scheme
if rows:
    sample = str(rows[0][0])
    test("Cross-spec: Shared resource uses urn:resource: @id",
         sample.startswith("urn:resource:"), sample)

# Namespace inventory
ns_prefixes = {
    "http://www.w3.org/ns/shacl": "sh",
    "http://www.w3.org/2004/02/skos": "skos",
    "http://www.w3.org/ns/prov": "prov",
    "http://www.w3.org/ns/dcat": "dcat",
    "http://www.w3.org/ns/odrl": "odrl",
    "http://www.w3.org/2006/time": "time",
    "http://www.w3.org/ns/earl": "earl",
    "http://rdfs.org/ns/void": "void",
    "http://www.w3.org/ns/dqv": "dqv",
    "http://www.w3.org/ns/oa": "oa",
    "http://purl.org/dc/terms": "dcterms",
    "https://schema.org": "schema",
    "http://www.w3.org/2002/07/owl": "owl",
    "http://www.w3.org/2000/01/rdf-schema": "rdfs",
    "http://www.w3.org/ns/org": "org",
}
ns_set = set()
for s, p, o in merged.triples((None, None, None)):
    for term in [s, p, o]:
        t = str(term)
        for prefix, name in ns_prefixes.items():
            if t.startswith(prefix):
                ns_set.add(name)
                break

test("Cross-spec: W3C namespaces in merged graph",
     len(ns_set) >= 10, f"{len(ns_set)} namespaces: {', '.join(sorted(ns_set))}")

# ===============================================================
# TEST 15: Serialization formats (triplestore-ready)
# ===============================================================
print("\n=== Serialization Formats ===")

turtle_output = merged.serialize(format="turtle")
test("Serialize: Turtle", len(turtle_output) > 100, f"{len(turtle_output)} chars")

nt_output = merged.serialize(format="nt")
nt_lines = [l for l in nt_output.strip().split("\n") if l.strip()]
test("Serialize: N-Triples count matches",
     len(nt_lines) == total_triples,
     f"{len(nt_lines)} lines (expected {total_triples})")

try:
    rdfxml_output = merged.serialize(format="xml")
    test("Serialize: RDF/XML", len(rdfxml_output) > 100, f"{len(rdfxml_output)} chars")
except Exception as e:
    test("Serialize: RDF/XML", False, str(e))

# ===============================================================
# SUMMARY
# ===============================================================
print("\n" + "=" * 60)
passed = sum(1 for _, p, _ in test_results if p)
failed = sum(1 for _, p, _ in test_results if not p)
total = len(test_results)
print(f"  TOTAL: {passed}/{total} passed, {failed} failed")

if failed > 0:
    print("\n  FAILURES:")
    for name, p, detail in test_results:
        if not p:
            print(f"    FAIL {name}: {detail}")

print("=" * 60)
sys.exit(0 if failed == 0 else 1)
